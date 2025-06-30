import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/daangn_api_service.dart';
import '../models/job_result.dart';
import '../models/region.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController(text: '15000');
  final DaangnApiService _apiService = DaangnApiService();
  
  Set<JobResult> _searchResults = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  // 지역 선택 관련
  Region? _selectedRegion;
  SubRegion? _selectedSubRegion;
  
  // 필터 옵션
  bool _showOnlyDaangnJobs = false;

  @override
  void initState() {
    super.initState();
    // 기본 지역 설정 (서울특별시)
    _selectedRegion = RegionData.regions.first;
    // 기본 동 설정 (선택 안함)
    _selectedSubRegion = _selectedRegion!.subRegions.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minSalaryController.dispose();
    super.dispose();
  }

  void _onRegionChanged(Region? region) {
    setState(() {
      _selectedRegion = region;
      _selectedSubRegion = null;
    });
  }

  void _onSubRegionChanged(SubRegion? subRegion) {
    setState(() {
      _selectedSubRegion = subRegion;
    });
  }

  int? parseKoreanMoney(String text) {
    // 1. '1만 5,000원' → '1만5000'
    String cleaned = text.replaceAll(' ', '');
    int total = 0;

    // 만 단위 처리
    final manMatch = RegExp(r'(\d+)만').firstMatch(cleaned);
    if (manMatch != null) {
      total += int.parse(manMatch.group(1)!) * 10000;
      cleaned = cleaned.replaceFirst(RegExp(r'(\d+)만'), '');
    }

    // 천 단위 처리 (옵션)
    final chunMatch = RegExp(r'(\d+)천').firstMatch(cleaned);
    if (chunMatch != null) {
      total += int.parse(chunMatch.group(1)!) * 1000;
      cleaned = cleaned.replaceFirst(RegExp(r'(\d+)천'), '');
    }

    // 나머지 숫자
    final numMatch = RegExp(r'(\d{1,3}(,\d{3})*)').firstMatch(cleaned);
    if (numMatch != null) {
      total += int.parse(numMatch.group(1)!.replaceAll(',', ''));
    }

    return total > 0 ? total : null;
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = {};
    });
    try {
      if (_selectedRegion == null || _selectedSubRegion == null) {
        setState(() {
          _errorMessage = '지역을 선택해주세요.';
          _isLoading = false;
        });
        return;
      }
      final minSalary = int.tryParse(_minSalaryController.text.replaceAll(',', ''));
      if (_selectedSubRegion!.code == 'all') {
        // 전체 동 검색: 동별로 바로바로 추가
        final parent = _selectedRegion!;
        for (final sub in parent.subRegions) {
          if (sub.code == 'all') continue;
          var results = await _apiService.searchJobs(
            _searchController.text.trim(),
            sub,
            showOnlyDaangnJobs: _showOnlyDaangnJobs,
          );
          // 최소금액 필터 적용
          if (minSalary != null) {
            results = results.where((job) {
              final salary = parseKoreanMoney(job.salary);
              return salary != null && salary >= minSalary;
            }).toList();
          }
          setState(() {
            _searchResults.addAll(results);
          });
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        // 단일 동 검색
        var results = await _apiService.searchJobs(
          _searchController.text.trim(),
          _selectedSubRegion!,
          showOnlyDaangnJobs: _showOnlyDaangnJobs,
        );
        // 최소금액 필터 적용
        if (minSalary != null) {
          results = results.where((job) {
            final salary = parseKoreanMoney(job.salary);
            return salary != null && salary >= minSalary;
          }).toList();
        }
        setState(() {
          _searchResults.addAll(results);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      // URL이 유효한지 확인
      if (!uri.hasScheme) {
        final httpsUri = Uri.parse('https://$url');
        if (await canLaunchUrl(httpsUri)) {
          await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
          return;
        }
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // 브라우저 앱이 없는 경우 기본 브라우저로 시도
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('링크를 열 수 없습니다. 브라우저 앱을 설치해주세요.'),
              action: SnackBarAction(
                label: 'URL 복사',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL이 클립보드에 복사되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('링크 열기 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('당근마켓 알바 검색'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 검색/필터 전체 영역을 ExpansionTile로 감싼다
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: const Text(
                '검색 및 필터 옵션',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              initiallyExpanded: true,
              children: [
                // 지역 선택 영역
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '지역 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 시/도 선택 드롭다운
                      DropdownButtonFormField<Region>(
                        value: _selectedRegion,
                        decoration: InputDecoration(
                          labelText: '시/도',
                          hintText: '시/도를 선택하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                        items: RegionData.regions.map((region) {
                          return DropdownMenuItem<Region>(
                            value: region,
                            child: Text(region.name),
                          );
                        }).toList(),
                        onChanged: (Region? newValue) {
                          setState(() {
                            _selectedRegion = newValue;
                            _selectedSubRegion = newValue?.subRegions.first;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // 동 선택 드롭다운
                      DropdownButtonFormField<SubRegion>(
                        value: _selectedSubRegion,
                        decoration: InputDecoration(
                          labelText: '동 선택',
                          hintText: '검색할 동을 선택하거나 "선택 안함"으로 전체 동 검색',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        items: _selectedRegion?.subRegions.map((subRegion) {
                          return DropdownMenuItem<SubRegion>(
                            value: subRegion,
                            child: Text(subRegion.name),
                          );
                        }).toList() ?? [],
                        onChanged: (SubRegion? newValue) {
                          setState(() {
                            _selectedSubRegion = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // 검색 입력 영역
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '검색어를 입력하세요 (선택사항, 예: 엑셀, 서빙, 주방보조...)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _performSearch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('검색'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 필터 옵션
                Row(
                  children: [
                    const Text(
                      '이웃알바만 보기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _showOnlyDaangnJobs,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyDaangnJobs = value;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      '최소 금액(원):',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _minSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '예: 15000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          // 에러 메시지
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          
          // 검색 결과
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '지역을 선택하고 검색 버튼을 눌러주세요\n"선택 안함"으로 전체 동 검색도 가능합니다',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults.toList()[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _launchUrl(result.url),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 제목 (클릭 가능한 링크 스타일)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            result.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // 회사명
                                    if (result.company.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.business, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.company,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    
                                    // 위치
                                    if (result.location.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.location,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    
                                    // 급여
                                    if (result.salary.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.salary,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    
                                    // 근무 일정
                                    if (result.workSchedule.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule, size: 16, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              result.workSchedule,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    
                                    // 근무 기간
                                    if (result.workPeriod.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.workPeriod,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    
                                    // 설명
                                    if (result.description.isNotEmpty) ...[
                                      Text(
                                        result.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    const SizedBox(height: 12),
                                    
                                    // 클릭 안내 메시지
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.phone_android, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            '클릭하여 당근마켓 앱에서 보기',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 