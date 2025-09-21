import 'dart:convert';
import 'package:brotli/brotli.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart';
import '../models/job_result.dart';
import '../models/region.dart';
// ignore: duplicate_import
import 'package:brotli/brotli.dart';

class DaangnApiService {
  static const String baseUrl = 'https://www.daangn.com';

  Future<List<JobResult>> searchJobs(
    String query,
    SubRegion region, {
    Region? parentRegion,
    bool showOnlyDaangnJobs = false,
  }) async {
    try {
      // "선택 안함"(전체 동)일 때
      if (region.code == 'all' && parentRegion != null) {
        List<JobResult> allResults = [];
        Set<String> seenTitles = {};
        for (final sub in parentRegion.subRegions ?? []) {
          if (sub.code == 'all') continue; // "선택 안함"은 제외
          print('하위 지역 검색: ${sub.name} (${sub.code})');
          final results = await searchJobs(
            query,
            sub,
            showOnlyDaangnJobs: showOnlyDaangnJobs,
          );
          print('${sub.name}에서 ${results.length}개 결과 발견');

          for (final job in results) {
            if (!seenTitles.contains(job.title)) {
              allResults.add(job);
              seenTitles.add(job.title);
            }
          }
        }

        print('전체 동 검색 완료 - 총 ${allResults.length}개 결과 (중복 제거 후)');
        return allResults;
      }

      // URL 인코딩
      final encodedQuery = Uri.encodeComponent(query);
      final regionParam = '${region.name}-${region.code}';
      final encodedRegion = Uri.encodeComponent(regionParam);
      final url = '$baseUrl/kr/jobs/?in=$encodedRegion&search=$encodedQuery';

      print('API 호출 URL: $url');
      print('인코딩된 검색어: $encodedQuery');
      print('인코딩된 지역: $encodedRegion');

      final startTime = DateTime.now();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ko-KR,ko;q=0.9,en;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('API 응답 시간: ${duration.inMilliseconds}ms');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 헤더: ${response.headers}');

      if (response.statusCode == 200) {
        String body;

        try {
          final encoding = response.headers['content-encoding'] ?? '';
          print("👉 Content-Encoding: $encoding");

          if (encoding.contains('br')) {
            // Brotli 압축 해제
            try {
              final decodedBytes = brotli.decode(response.bodyBytes);
              body = utf8.decode(decodedBytes, allowMalformed: true);
              print("✅ Brotli 해제 성공");
            } catch (e) {
              print("⚠️ Brotli 해제 실패, fallback: $e");
              body = utf8.decode(response.bodyBytes, allowMalformed: true);
            }
          } else if (encoding.contains('gzip')) {
            // http 패키지가 gzip은 자동 처리해줄 때가 많음
            body = utf8.decode(response.bodyBytes, allowMalformed: true);
            print("✅ gzip 또는 자동 해제된 데이터");
          } else {
            // 평문 처리
            body = utf8.decode(response.bodyBytes, allowMalformed: true);
            print("✅ 평문 UTF-8 처리");
          }
        } catch (e) {
          print("❌ decodeResponse 최종 실패: $e");
          body = utf8.decode(response.bodyBytes, allowMalformed: true);
        }

        print('응답 본문 크기: ${body.length} 문자');
        print(
          '응답 본문 미리보기: ${body.substring(0, body.length > 500 ? 500 : body.length)}...',
        );

        return _parseJobResults(body, query, showOnlyDaangnJobs);
      } else {
        print('❌ API 요청 실패: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        throw Exception('API 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API 호출 오류: $e');
      print('오류 스택 트레이스: ${StackTrace.current}');
      throw Exception('검색 중 오류가 발생했습니다: $e');
    }
  }

  List<JobResult> _parseJobResults(
    String htmlContent,
    String query,
    bool showOnlyDaangnJobs,
  ) {
    try {
      print('=== HTML 파싱 시작 ===');
      print('검색어: "$query"');
      print('이웃알바만 보기: $showOnlyDaangnJobs');

      final document = html.parse(htmlContent);
      final List<JobResult> results = [];

      // _11bsp580 클래스를 가진 div 요소들을 찾기
      final jobContainers = document.querySelectorAll('div._11bsp580');

      print('찾은 job 컨테이너 개수: ${jobContainers.length}');

      if (jobContainers.isEmpty) {
        print('⚠️ job 컨테이너를 찾을 수 없습니다. 다른 선택자를 시도합니다...');
      }

      for (int i = 0; i < jobContainers.length; i++) {
        final container = jobContainers[i];
        print('\n--- 컨테이너 ${i + 1} 파싱 시작 ---');

        // 각 컨테이너 안의 모든 a 태그 찾기
        final linkElements = container.querySelectorAll('a');
        print('컨테이너 ${i + 1}에서 찾은 a 태그 개수: ${linkElements.length}');

        if (linkElements.isEmpty) {
          print('❌ a 태그를 찾을 수 없습니다');
          continue;
        }

        // 각 a 태그에서 정보 추출
        for (int j = 0; j < linkElements.length; j++) {
          final linkElement = linkElements[j];
          print('\n--- a 태그 ${j + 1} 파싱 시작 ---');

          try {
            // a 태그의 href 속성에서 URL 추출
            final href = linkElement.attributes['href'] ?? '';
            final url =
                (href.startsWith('http://') || href.startsWith('https://'))
                ? href
                : '$baseUrl$href';
            print('URL: $url');

            // 제목 추출 - 다양한 방법 시도
            String title = '';
            print('\n--- 제목 추출 시도 ---');

            // 방법 1: abyzch1 클래스의 span
            final titleElement1 = linkElement.querySelector(
              'span[class*="abyzch1"]',
            );
            if (titleElement1 != null) {
              title = _extractText(titleElement1)?.trim() ?? '';
              print('방법 1 (abyzch1): "$title"');
            }

            // 회사명과 위치 추출 (_1pwsqmm0 클래스의 첫 번째 span)
            String company = '';
            String location = '';
            String timeAgoText = '';
            DateTime? postedDate;
            print('\n--- 회사명/위치 추출 ---');

            final companyLocationElement = linkElement.querySelector(
              '._1pwsqmm0',
            );
            if (companyLocationElement != null) {
              final spans = companyLocationElement.querySelectorAll('span');
              if (spans.isNotEmpty) {
                // 회사명: 첫 번째 span
                company = _extractText(spans.first)?.trim() ?? '';
              }
              final dongSpans = companyLocationElement.querySelectorAll(
                'span._1pwsqmmd',
              );
              // 동정보
              if (dongSpans.isNotEmpty) {
                final innerSpans = dongSpans[0].querySelectorAll('span');
                if (innerSpans.length > 1) {
                  location = _extractText(innerSpans[1])?.trim() ?? '';
                }
              }
              // 등록시간
              if (dongSpans.length > 1) {
                final timeTag = dongSpans[1].querySelector('time');
                if (timeTag != null) {
                  timeAgoText = _extractText(timeTag)?.trim() ?? '';
                  final datetimeAttr = timeTag.attributes['datetime'];
                  ;
                  if (datetimeAttr != null) {
                    postedDate = DateTime.tryParse(datetimeAttr);
                    if (postedDate != null) {
                      final now = DateTime.now();
                      final diff = now.difference(postedDate!);
                      if (diff.inDays >= 1) {
                        // 1일 이상은 건너뜀
                        continue;
                      }
                    }
                  }
                }
              }
            }

            // 급여 및 근무 일정 추출 (두 번째 _1pwsqmm0 클래스)
            String salary = '';
            String workSchedule = '';
            print('\n--- 급여/근무 일정 추출 ---');

            final salaryElements = linkElement.querySelectorAll('._1pwsqmm0');
            print('급여 관련 요소 개수: ${salaryElements.length}');

            if (salaryElements.length > 1) {
              final spans = salaryElements[1].querySelectorAll('span');
              if (spans.isNotEmpty) {
                // 급여: 첫 번째 span
                salary = _extractText(spans.first)?.trim() ?? '';
                print('추출된 급여: "$salary"');
                // 근무 일정: 두 번째, 세 번째 _1pwsqmmd span의 두 번째 자식 span
                final scheduleSpans = salaryElements[1].querySelectorAll(
                  'span._1pwsqmmd',
                );
                if (scheduleSpans.length >= 2) {
                  final daySpan = scheduleSpans[0].querySelectorAll('span');
                  final timeSpan = scheduleSpans[1].querySelectorAll('span');
                  final day = (daySpan.length > 1)
                      ? _extractText(daySpan[1])?.trim() ?? ''
                      : '';
                  final time = (timeSpan.length > 1)
                      ? _extractText(timeSpan[1])?.trim() ?? ''
                      : '';
                  workSchedule = [
                    day,
                    time,
                  ].where((t) => t.isNotEmpty).join(' ');
                  print('근무 일정: "$workSchedule"');
                }
              }
            }

            // 결과가 유효한 경우에만 추가
            if (title.isNotEmpty) {
              // 이웃알바만 보기 옵션이 활성화된 경우 필터링
              bool shouldInclude =
                  !showOnlyDaangnJobs ||
                  (showOnlyDaangnJobs && company == '이웃알바');
              print('\n--- 필터링 ---');
              print(
                '필터링 조건: showOnlyDaangnJobs=$showOnlyDaangnJobs, company="$company", shouldInclude=$shouldInclude',
              );

              if (shouldInclude) {
                // 설명은 제목과 회사 정보를 조합
                String description = '';

                results.add(
                  JobResult(
                    title: title,
                    company: company,
                    location: location,
                    salary: salary,
                    workSchedule: workSchedule,
                    workPeriod: '',
                    description: description,
                    url: url,
                    postedDate: postedDate,
                    timeAgoText: timeAgoText,
                  ),
                );

                print('✅ 결과 추가됨: $title - $company - $salary');
              } else {
                print('❌ 필터링으로 인해 제외됨');
              }
            } else {
              print('❌ 제목이 비어있어 결과에서 제외됨');
            }
          } catch (e) {
            print('❌ 개별 a 태그 파싱 오류: $e');
            continue;
          }
        }
      }

      print('\n=== 파싱 완료 ===');
      print('총 파싱된 결과 개수: ${results.length}');
      return results;
    } catch (e) {
      print('❌ HTML 파싱 오류: $e');
      throw Exception('HTML 파싱 중 오류가 발생했습니다: $e');
    }
  }

  // HTML에서 텍스트 추출 (보조 함수)
  String? _extractText(Element? element) {
    if (element == null) return null;

    // 스크립트와 스타일 태그 제거
    final scripts = element.querySelectorAll('script');
    final styles = element.querySelectorAll('style');
    for (var script in scripts) {
      script.remove();
    }
    for (var style in styles) {
      style.remove();
    }

    return element.text?.trim();
  }

  // 제목에서 "이웃알바에서 .....(동이름)" 형태 제거
  String _cleanTitle(String title) {
    // "이웃알바에서"로 시작하는 경우
    if (title.startsWith('이웃알바에서 ')) {
      // "이웃알바에서 " 부분 제거
      title = title.substring('이웃알바에서 '.length);
    }

    // 마지막에 "(동이름)" 형태가 있는 경우 제거
    final lastParenthesisIndex = title.lastIndexOf('(');
    if (lastParenthesisIndex != -1) {
      final lastClosingParenthesisIndex = title.lastIndexOf(')');
      if (lastClosingParenthesisIndex > lastParenthesisIndex) {
        // 괄호 부분 제거
        title = title.substring(0, lastParenthesisIndex).trim();
      }
    }

    return title;
  }
}
