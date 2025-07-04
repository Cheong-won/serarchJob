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
  final DaangnApiService _apiService = DaangnApiService();
  
  Set<JobResult> _searchResults = {};
  bool _isLoading = false;
  bool _isSearchCancelled = false; // 검색 중지 플래그
  String? _errorMessage;
  
  // 지역 선택 관련
  Region? _selectedRegion;
  SubRegion? _selectedSubRegion;
  List<Gu> _selectedGus = []; // 단일 구에서 다수 구로 변경
  
  // 필터 옵션
  bool _showOnlyDaangnJobs = true;
  int _selectedMinSalary = 0; // 기본값 0원
  
  // ExpansionTile 상태 제어
  bool _isFilterExpanded = true;
  
  // 최소 금액 옵션
  static const List<int> _minSalaryOptions = [0, 10000, 15000, 20000];

  @override
  void initState() {
    super.initState();
    // '서울특별시'를 기본 선택값으로 지정
    _selectedRegion = RegionData.regions.firstWhere(
      (region) => region.code == 'seoul',
      orElse: () => RegionData.regions.first,
    );
    if (_selectedRegion!.gus != null && _selectedRegion!.gus!.isNotEmpty) {
      // 성북구, 중랑구, 노원구, 강북구를 기본 선택
      final selectedGuNames = ['성북구', '중랑구', '노원구', '강북구'];
      _selectedGus = _selectedRegion!.gus!.where((gu) => selectedGuNames.contains(gu.name)).toList();
      
      // 동 선택은 '선택 안함'으로
      final noneDong = SubRegion(name: '선택 안함 (전체 동)', code: 'all');
      _selectedSubRegion = noneDong;
    } else {
      _selectedSubRegion = _selectedRegion!.subRegions?.first;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onRegionChanged(Region? region) {
    setState(() {
      _selectedRegion = region;
      _selectedGus = []; // 구 선택 초기화
      if (region?.gus != null && region!.gus!.isNotEmpty) {
        // 전체 구 옵션을 기본으로 선택
        final allGu = Gu(name: '선택 안함 (전체 구)', code: 'all', dongs: [SubRegion(name: '선택 안함 (전체 동)', code: 'all')]);
        _selectedGus = [allGu];
        _selectedSubRegion = allGu.dongs.first;
      } else {
        _selectedSubRegion = region?.subRegions?.first;
      }
    });
  }

  void _onGuChanged(Gu gu, bool? isSelected) {
    setState(() {
      if (gu.code == 'all') {
        // '선택 안함' 토글 기능
        if (isSelected == true) {
          // 모든 구 선택
          _selectedGus = [gu, ...(_selectedRegion!.gus ?? [])];
        } else {
          // 모든 구 해제 (선택 안함도 해제)
          _selectedGus = [];
        }
      } else {
        // 개별 구 선택/해제
        if (isSelected == true) {
          // '선택 안함' 제거하고 해당 구 추가
          _selectedGus.removeWhere((g) => g.code == 'all');
          if (!_selectedGus.contains(gu)) {
            _selectedGus.add(gu);
          }
        } else {
          // 구 선택 해제
          _selectedGus.remove(gu);
        }
      }
      
      // 동 선택 업데이트
      if (_selectedGus.isEmpty) {
        // 아무것도 선택되지 않으면 동도 선택 안함으로
        final noneDong = SubRegion(name: '선택 안함 (전체 동)', code: 'all');
        _selectedSubRegion = noneDong;
      } else if (_selectedGus.length == 1 && _selectedGus.first.code == 'all') {
        _selectedSubRegion = _selectedGus.first.dongs.first;
      } else {
        // 다수 구 선택 시 동 선택은 '선택 안함'으로
        final noneDong = SubRegion(name: '선택 안함 (전체 동)', code: 'all');
        _selectedSubRegion = noneDong;
      }
    });
  }

  void _onSubRegionChanged(SubRegion? subRegion) {
    setState(() {
      _selectedSubRegion = subRegion;
    });
  }

  // 구 다중 선택 다이얼로그
  void _showGuSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('구/시 선택'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 전체 선택/해제 버튼
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setDialogState(() {
                                _selectedGus = [Gu(name: '선택 안함 (전체 구)', code: 'all', dongs: [SubRegion(name: '선택 안함 (전체 동)', code: 'all')]), ...(_selectedRegion!.gus ?? [])];
                              });
                            },
                            child: const Text('전체 선택'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setDialogState(() {
                                _selectedGus = [];
                              });
                            },
                            child: const Text('전체 해제'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 개별 구 체크박스
                    ...(_selectedRegion!.gus ?? []).map((gu) => CheckboxListTile(
                      title: Text(gu.name),
                      value: _selectedGus.contains(gu),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedGus.removeWhere((g) => g.code == 'all');
                            if (!_selectedGus.contains(gu)) {
                              _selectedGus.add(gu);
                            }
                          } else {
                            _selectedGus.remove(gu);
                          }
                        });
                      },
                      dense: true,
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 동 선택 업데이트
                    if (_selectedGus.isEmpty) {
                      final noneDong = SubRegion(name: '선택 안함 (전체 동)', code: 'all');
                      _selectedSubRegion = noneDong;
                    } else if (_selectedGus.length == 1 && _selectedGus.first.code == 'all') {
                      _selectedSubRegion = _selectedGus.first.dongs.first;
                    } else {
                      final noneDong = SubRegion(name: '선택 안함 (전체 동)', code: 'all');
                      _selectedSubRegion = noneDong;
                    }
                    setState(() {}); // UI 업데이트
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 검색 중지 메서드
  void _cancelSearch() {
    setState(() {
      _isSearchCancelled = true;
      _isLoading = false;
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
    // 이미 검색 중이면 중지
    if (_isLoading) {
      _cancelSearch();
      return;
    }

    print('=== 검색 디버깅 ===');
    print('선택된 시/도: \\${_selectedRegion?.name} (code: \\${_selectedRegion?.code})');
    print('선택된 구/시: \\${_selectedGus.map((g) => g.name).join(', ')}');
    print('선택된 동: \\${_selectedSubRegion?.name} (code: \\${_selectedSubRegion?.code})');
    
    setState(() {
      _isLoading = true;
      _isSearchCancelled = false;
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
      final minSalary = _selectedMinSalary;
      if (_selectedSubRegion!.code == 'all') {
        // 전체 동 검색
        if (_selectedRegion!.code == 'all') {
          // 전체 지역 검색 (모든 시/도의 모든 동을 검색)
          for (final region in RegionData.regions) {
            if (_isSearchCancelled) break; // 검색 중지 체크
            if (region.code == 'all') continue; // 전체 지역 옵션은 건너뛰기
            
            if (region.gus != null) {
              // 3단계 구조 (시/도 -> 구 -> 동)
              for (final gu in region.gus!) {
                if (_isSearchCancelled) break; // 검색 중지 체크
                if (gu.code == 'all') continue; // 전체 구 옵션은 건너뛰기
                for (final dong in gu.dongs) {
                  if (_isSearchCancelled) break; // 검색 중지 체크
                  if (dong.code == 'all') continue;
                  var results = await _apiService.searchJobs(
                    _searchController.text.trim(),
                    dong,
                    showOnlyDaangnJobs: _showOnlyDaangnJobs,
                  );
                  // 최소금액 필터 적용
                  if (minSalary != null) {
                    results = results.where((job) {
                      final salary = parseKoreanMoney(job.salary);
                      return salary != null && salary >= minSalary;
                    }).toList();
                  }
                  if (!_isSearchCancelled) {
                    setState(() {
                      _searchResults.addAll(results);
                    });
                  }
                }
                if (_isSearchCancelled) break; // 검색 중지 체크
              }
            } else if (region.subRegions != null) {
              // 2단계 구조 (시/도 -> 동)
              for (final sub in region.subRegions!) {
                if (_isSearchCancelled) break; // 검색 중지 체크
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
                if (!_isSearchCancelled) {
                  setState(() {
                    _searchResults.addAll(results);
                  });
                }
              }
            }
            if (_isSearchCancelled) break; // 검색 중지 체크
          }
        } else if (_selectedGus.isNotEmpty && _selectedGus.first.code != 'all') {
          // 특정 구의 전체 동 검색
          for (final gu in _selectedGus) {
            if (_isSearchCancelled) break; // 검색 중지 체크
            if (gu.code == 'all') continue;
            for (final dong in gu.dongs) {
              if (_isSearchCancelled) break; // 검색 중지 체크
              if (dong.code == 'all') continue;
              var results = await _apiService.searchJobs(
                _searchController.text.trim(),
                dong,
                showOnlyDaangnJobs: _showOnlyDaangnJobs,
              );
              // 최소금액 필터 적용
              if (minSalary != null) {
                results = results.where((job) {
                  final salary = parseKoreanMoney(job.salary);
                  return salary != null && salary >= minSalary;
                }).toList();
              }
              if (!_isSearchCancelled) {
                setState(() {
                  _searchResults.addAll(results);
                });
              }
            }
            if (_isSearchCancelled) break; // 검색 중지 체크
          }
        } else if (_selectedGus.isNotEmpty && _selectedGus.first.code == 'all') {
          // 전체 구 검색 (시/도의 모든 구에 대해 검색)
          final parent = _selectedRegion!;
          for (final gu in parent.gus ?? []) {
            if (_isSearchCancelled) break; // 검색 중지 체크
            if (gu.code == 'all') continue; // 전체 구 옵션은 건너뛰기
            for (final dong in gu.dongs) {
              if (_isSearchCancelled) break; // 검색 중지 체크
              if (dong.code == 'all') continue;
              var results = await _apiService.searchJobs(
                _searchController.text.trim(),
                dong,
                showOnlyDaangnJobs: _showOnlyDaangnJobs,
              );
              // 최소금액 필터 적용
              if (minSalary != null) {
                results = results.where((job) {
                  final salary = parseKoreanMoney(job.salary);
                  return salary != null && salary >= minSalary;
                }).toList();
              }
              if (!_isSearchCancelled) {
                setState(() {
                  _searchResults.addAll(results);
                });
              }
            }
            if (_isSearchCancelled) break; // 검색 중지 체크
          }
        } else {
          // 시/도 전체 동 검색 (기존 2단계 구조용)
          final parent = _selectedRegion!;
          for (final sub in parent.subRegions ?? []) {
            if (_isSearchCancelled) break; // 검색 중지 체크
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
            if (!_isSearchCancelled) {
              setState(() {
                _searchResults.addAll(results);
              });
            }
          }
        }
        if (!_isSearchCancelled) {
          setState(() {
            _isLoading = false;
            // 여기서 한 번만 정렬
            List<JobResult> sortedResults = _searchResults.toList()
              ..sort((a, b) {
                if (a.postedDate == null && b.postedDate == null) return 0;
                if (a.postedDate == null) return 1;
                if (b.postedDate == null) return -1;
                return b.postedDate!.compareTo(a.postedDate!);
              });
            _searchResults = sortedResults.toSet();
          });
        }
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
        if (!_isSearchCancelled) {
          setState(() {
            _searchResults.addAll(results);
          });
        }
      }
    } catch (e) {
      if (!_isSearchCancelled) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
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

  // 시간 차이로 '몇시간 전' 등 표시 함수 추가
  String timeAgoFromDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}초 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _isFilterExpanded = !_isFilterExpanded;
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('당근마켓 알바 검색'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            // 검색/필터 전체 영역을 ExpansionPanelList로 교체
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ExpansionPanelList(
                expansionCallback: (panelIndex, isExpanded) {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ListTile 대신 Container 사용
                      child: const Row(
                        children: [
                          Icon(Icons.tune, color: Colors.orange, size: 20), // 아이콘 추가
                          SizedBox(width: 8),
                          Text(
                            '검색 및 필터 옵션',
                            style: TextStyle(
                              fontSize: 15, // 16에서 15로 줄임
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 지역 선택 영역
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '지역 선택',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // 시/도 선택 드롭다운
                                DropdownButtonFormField<Region>(
                                  value: _selectedRegion,
                                  decoration: InputDecoration(
                                    labelText: '시/도',
                                    hintText: '시/도를 선택하세요',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    prefixIcon: const Icon(Icons.location_city, size: 20),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    isDense: true,
                                  ),
                                  items: RegionData.regions.map((region) {
                                    return DropdownMenuItem<Region>(
                                      value: region,
                                      child: Text(region.name),
                                    );
                                  }).toList(),
                                  onChanged: _onRegionChanged,
                                ),
                                const SizedBox(height: 4),
                                // 구(시) 선택 드롭다운 (다중 선택 가능)
                                if (_selectedRegion?.gus != null && _selectedRegion!.gus!.isNotEmpty)
                                  DropdownButtonFormField<String>(
                                    value: _selectedGus.isEmpty ? 'all' : 'multiple',
                                    decoration: InputDecoration(
                                      labelText: '구/시 선택',
                                      hintText: '구/시를 선택하세요 (다중 선택 가능)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      prefixIcon: const Icon(Icons.apartment, size: 20),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      isDense: true,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('선택 안함 (전체 구)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'multiple',
                                        child: Text(_selectedGus.isEmpty 
                                          ? '구를 선택하세요' 
                                          : '${_selectedGus.length}개 구 선택됨'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == 'all') {
                                        // 전체 구 선택
                                        final allGu = Gu(name: '선택 안함 (전체 구)', code: 'all', dongs: [SubRegion(name: '선택 안함 (전체 동)', code: 'all')]);
                                        setState(() {
                                          _selectedGus = [allGu, ...(_selectedRegion!.gus ?? [])];
                                          _selectedSubRegion = allGu.dongs.first;
                                        });
                                      } else if (value == 'multiple') {
                                        // 다중 선택 다이얼로그 표시
                                        _showGuSelectionDialog();
                                      }
                                    },
                                  ),
                                if (_selectedRegion?.gus != null && _selectedRegion!.gus!.isNotEmpty)
                                  const SizedBox(height: 4),
                                // 동 선택 드롭다운
                                Builder(
                                  builder: (context) {
                                    final noneDong = SubRegion(name: '선택 안함 (전체 동)', code: 'all');
                                    List<SubRegion> dongList;
                                    
                                    if (_selectedGus.length == 1 && _selectedGus.first.code == 'all') {
                                      // '선택 안함'이 선택된 경우
                                      dongList = _selectedGus.first.dongs;
                                    } else if (_selectedGus.length == 1 && _selectedGus.first.code != 'all') {
                                      // 특정 구 하나만 선택된 경우
                                      dongList = [noneDong, ..._selectedGus.first.dongs.where((d) => d.code != 'all')];
                                    } else {
                                      // 다수 구가 선택된 경우
                                      dongList = [noneDong];
                                    }
                                    
                                    return DropdownButtonFormField<SubRegion>(
                                      value: dongList.contains(_selectedSubRegion) ? _selectedSubRegion : noneDong,
                                      decoration: InputDecoration(
                                        labelText: '동 선택',
                                        hintText: '검색할 동을 선택하거나 "선택 안함"으로 전체 동 검색',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        prefixIcon: const Icon(Icons.location_on, size: 20),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        isDense: true,
                                      ),
                                      items: dongList.map((subRegion) {
                                        return DropdownMenuItem<SubRegion>(
                                          value: subRegion,
                                          child: Text(subRegion.name),
                                        );
                                      }).toList(),
                                      onChanged: _onSubRegionChanged,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 검색 입력 영역
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: '검색어를 입력하세요 (선택사항, 예: 엑셀, 서빙, 주방보조...)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.search, size: 20),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _performSearch(),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: _performSearch,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: _isLoading ? Colors.red : null,
                                ),
                                child: _isLoading
                                    ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          ),
                                          SizedBox(width: 6),
                                          Text('중지', style: TextStyle(color: Colors.white, fontSize: 13)),
                                        ],
                                      )
                                    : const Text('검색', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 필터 옵션
                          Row(
                            children: [
                              const Text(
                                '이웃알바만 보기',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text(
                                '최소 금액:',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _selectedMinSalary,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  ),
                                  items: _minSalaryOptions.map((salary) {
                                    return DropdownMenuItem<int>(
                                      value: salary,
                                      child: Text(salary == 0 ? '0원 (전체)' : '${salary.toStringAsFixed(0)}원', style: TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMinSalary = value ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                        ],
                      ),
                    ),
                    isExpanded: _isFilterExpanded,
                    canTapOnHeader: true,
                  ),
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
                          itemCount: _searchResults.where((r) => r.postedDate != null).length,
                          itemBuilder: (context, index) {
                            final filteredResults = _searchResults.where((r) => r.postedDate != null).toList();
                            final result = filteredResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _launchUrl(result.url),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                                      
                                      // 주요 정보를 가로로 배치
                                      Row(
                                        children: [
                                          // 위치 (동이름)
                                          if (result.location.isNotEmpty) ...[
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      result.location,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          
                                          // 급여
                                          if (result.salary.isNotEmpty) ...[
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.attach_money, size: 14, color: Colors.orange),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      result.salary,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.orange,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          
                                          // 회사명
                                          if (result.company.isNotEmpty) ...[
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.business, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      result.company,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      
                                      // 등록 시간 (몇시간 전 등)
                                      if (result.postedDate != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
                                            const SizedBox(width: 4),
                                            Text(
                                              timeAgoFromDateTime(result.postedDate!),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      
                                      const SizedBox(height: 6),
                                      
                                      // 근무 정보를 가로로 배치
                                      Row(
                                        children: [
                                          // 근무 일정
                                          if (result.workSchedule.isNotEmpty) ...[
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.schedule, size: 14, color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      result.workSchedule,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.blue,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          
                                          // 근무 기간
                                          if (result.workPeriod.isNotEmpty) ...[
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.calendar_today, size: 14, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      result.workPeriod,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.green,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // 클릭 안내 메시지 (작게)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.phone_android, size: 14, color: Colors.blue),
                                            SizedBox(width: 4),
                                            Text(
                                              '클릭하여 당근마켓 앱에서 보기',
                                              style: TextStyle(
                                                fontSize: 11,
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
      ),
    );
  }
} 