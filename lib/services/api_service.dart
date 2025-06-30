import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../models/search_result.dart';

class ApiService {
  // 실제 API 엔드포인트로 변경하세요
  static const String baseUrl = 'https://api.example.com';
  
  Future<List<SearchResult>> search(String query) async {
    try {
      // 실제 API 호출 (현재는 더미 데이터 반환)
      // final response = await http.get(
      //   Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer YOUR_API_KEY', // 필요시 추가
      //   },
      // );
      
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return _parseSearchResults(data);
      // } else {
      //   throw Exception('검색 요청 실패: ${response.statusCode}');
      // }
      
      // 더미 데이터 반환 (실제 구현시 위 주석 해제)
      await Future.delayed(const Duration(seconds: 1)); // 로딩 시뮬레이션
      return _getDummySearchResults(query);
      
    } catch (e) {
      throw Exception('검색 중 오류 발생: $e');
    }
  }

  List<SearchResult> _getDummySearchResults(String query) {
    return [
      SearchResult(
        title: '$query에 대한 검색 결과 1',
        content: '이것은 $query에 대한 첫 번째 검색 결과의 내용입니다. HTML에서 파싱된 텍스트 내용이 여기에 표시됩니다.',
        url: 'https://example.com/result1',
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SearchResult(
        title: '$query 관련 정보',
        content: '$query에 대한 두 번째 검색 결과입니다. HTML 파싱을 통해 추출된 텍스트가 여기에 나타납니다.',
        url: 'https://example.com/result2',
        publishedDate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      SearchResult(
        title: '$query 상세 분석',
        content: '$query에 대한 상세한 분석 내용이 여기에 표시됩니다. HTML 태그가 제거된 순수 텍스트만 포함됩니다.',
        url: 'https://example.com/result3',
        publishedDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  // HTML 파싱 함수 (더미 구현)
  String parseHtmlContent(String htmlString) {
    try {
      // HTML 파싱
      final document = html.parse(htmlString);
      
      // 스크립트와 스타일 태그 제거
      final scripts = document.querySelectorAll('script');
      final styles = document.querySelectorAll('style');
      for (var script in scripts) {
        script.remove();
      }
      for (var style in styles) {
        style.remove();
      }
      
      // 텍스트 추출
      final text = document.body?.text ?? '';
      
      // 불필요한 공백 제거 및 정리
      return text
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
          
    } catch (e) {
      // 파싱 실패시 원본 HTML 반환 (태그 제거)
      return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    }
  }

  // 실제 API 응답 파싱 함수 (더미 구현)
  List<SearchResult> _parseSearchResults(Map<String, dynamic> data) {
    // 실제 API 응답 구조에 맞게 수정하세요
    final results = data['results'] as List? ?? [];
    return results.map((item) => SearchResult.fromJson(item)).toList();
  }

  // 웹 페이지에서 직접 검색 (선택적 기능)
  Future<List<SearchResult>> searchFromWebPage(String query) async {
    try {
      // 예시: Google 검색 결과 페이지에서 데이터 추출
      final response = await http.get(
        Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        return _parseGoogleSearchResults(response.body, query);
      } else {
        throw Exception('웹 페이지 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('웹 페이지 검색 중 오류: $e');
    }
  }

  // Google 검색 결과 파싱 (더미 구현)
  List<SearchResult> _parseGoogleSearchResults(String htmlContent, String query) {
    // 실제 구현시 Google 검색 결과 페이지의 HTML 구조를 분석하여 파싱 로직 작성
    // 현재는 더미 데이터 반환
    return _getDummySearchResults(query);
  }
} 