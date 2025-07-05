class Region {
  final String name;
  final String code;
  final List<Gu>? gus; // 서울 등 3단계 지역만 사용
  final List<SubRegion>? subRegions; // 기존 방식(2단계)

  Region({
    required this.name,
    required this.code,
    this.gus,
    this.subRegions,
  });
}

class Gu {
  final String name;
  final String code;
  final List<SubRegion> dongs;

  Gu({
    required this.name,
    required this.code,
    required this.dongs,
  });
}

class SubRegion {
  final String name;
  final String code;

  SubRegion({
    required this.name,
    required this.code,
  });

  @override
  String toString() {
    return '$name-$code';
  }
}

// 지역 코드 데이터
class RegionData {
  static final List<Region> regions = [   
     Region(
      name: '선택 안함 (전체 시/도)',
      code: 'all',
      gus: [
        Gu(
          name: '선택 안함 (전체 구)',
          code: 'all',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
      // subRegions: null, // 또는 생략
    ),

    Region(
      name: '서울특별시-',
      code: 'seoul',
      gus: [
        Gu(
          name: '강남구',
          code: 'gangnam',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '강동구',
          code: 'gangdong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '강북구',
          code: 'gangbuk',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '노원구',
          code: 'nowon',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '성북구',
          code: 'seongbuk',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '동대문구',
          code: 'dongdaemun',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '중랑구',
          code: 'jungnang',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '광진구',
          code: 'gwangjin',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '성동구',
          code: 'seongdong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '송파구',
          code: 'songpa',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '구로구',
          code: 'guro',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '중구',
          code: 'jung',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
            SubRegion(name: '신당동', code: '28'),
            SubRegion(name: '약수동', code: '30'),
            SubRegion(name: '황학동', code: '34'),
            SubRegion(name: '명동', code: '23'),
            SubRegion(name: '중림동', code: '35'),
            SubRegion(name: '다산동', code: '29'),
            SubRegion(name: '청구동', code: '31'),
            SubRegion(name: '회현동', code: '22'),
            SubRegion(name: '태평로', code: '6397'),
            SubRegion(name: '예장동', code: '6368'),
            SubRegion(name: '동화동', code: '33'),
            SubRegion(name: '만리동', code: '6350'),
            SubRegion(name: '필동', code: '24'),
            SubRegion(name: '흥인동', code: '6405'),
            SubRegion(name: '장충동', code: '25'),
            SubRegion(name: '남대문로', code: '6342'),
            SubRegion(name: '을지로', code: '6375'),
            SubRegion(name: '서소문동', code: '6362'),
            SubRegion(name: '순화동', code: '6365'),
            SubRegion(name: '광희동', code: '26'),
            SubRegion(name: '무교동', code: '6353'),
            SubRegion(name: '충무로', code: '6394'),
            SubRegion(name: '소공동', code: '21'),
            SubRegion(name: '정동', code: '6387'),
            SubRegion(name: '오장동', code: '6369'),
            SubRegion(name: '다동', code: '6348'),
            SubRegion(name: '남창동', code: '6346'),
            SubRegion(name: '묵정동', code: '6355'),
            SubRegion(name: '쌍림동', code: '6366'),
            SubRegion(name: '북창동', code: '6359'),
            SubRegion(name: '충정로', code: '6396'),
            SubRegion(name: '남산동', code: '6344'),
            SubRegion(name: '인현동', code: '6380'),
            SubRegion(name: '장교동', code: '6382'),
            SubRegion(name: '입정동', code: '6381'),
            SubRegion(name: '수하동', code: '6364'),
            SubRegion(name: '봉래동', code: '6358'),
            SubRegion(name: '무학동', code: '6354'),
            SubRegion(name: '수표동', code: '6363'),
            SubRegion(name: '주교동', code: '6388'),
            SubRegion(name: '초동', code: '6390'),
            SubRegion(name: '의주로', code: '6377'),
            SubRegion(name: '남학동', code: '6347'),
            SubRegion(name: '저동', code: '6386'),
            SubRegion(name: '예관동', code: '6367'),
            SubRegion(name: '산림동', code: '6360'),
            SubRegion(name: '삼각동', code: '6361'),
            SubRegion(name: '방산동', code: '6356'),
            SubRegion(name: '주자동', code: '6389'),
          ],
        ),
      ],
    ),
    Region(
      name: '경기도',
      code: 'gyeonggi',
      gus: [
        Gu(
          name: '선택 안함 (전체 구)',
          code: 'all',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '성남시',
          code: 'seongnam',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '남양주시',
          code: 'namyangju',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '광명시',
          code: 'gwangmyeong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '하남시',
          code: 'hanam',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '평택시',
          code: 'pyeongtaek',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '용인시',
          code: 'yongin',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '인천광역시',
      code: 'incheon',
      subRegions: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
      ],
    ),
    Region(
      name: '충청북도',
      code: 'chungbuk',
      gus: [
        Gu(
          name: '선택 안함 (전체 구)',
          code: 'all',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '제천시',
          code: 'jecheon',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '음성군',
          code: 'eumseong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '옥천군',
          code: 'okcheon',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '영동군',
          code: 'yeongdong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '괴산군',
          code: 'goesan',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '단양군',
          code: 'danyang',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '보은군',
          code: 'boeun',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '충청남도',
      code: 'chungnam',
      gus: [
        Gu(
          name: '당진시',
          code: 'dangjin',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '공주시',
          code: 'gongju',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '논산시',
          code: 'nonsan',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '계룡시',
          code: 'gyeryong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '금산군',
          code: 'geumsan',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '대전광역시',
      code: 'daejeon',
      gus: [
        Gu(
          name: '동구',
          code: 'donggu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '서구',
          code: 'seogu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '대덕구',
          code: 'daedeokgu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '대구광역시',
      code: 'daegu',
      gus: [
        Gu(
          name: '선택 안함 (전체 구)',
          code: 'all',
          dongs: [SubRegion(name: '선택 안함 (전체 동)', code: 'all')],
        ),
        Gu(
          name: '달서구',
          code: 'dalseo',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '달성군',
          code: 'dalseong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '동구',
          code: 'donggu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '남구',
          code: 'namgu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '군위군',
          code: 'gunwi',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '경상남도',
      code: 'gyeongnam',
      gus: [
        Gu(
          name: '함양군',
          code: 'hamyang',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '강원특별자치도',
      code: 'gangwon',
      gus: [
        Gu(
          name: '동해시',
          code: 'donghae',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
    Region(
      name: '부산광역시',
      code: 'busan',
      gus: [
        Gu(
          name: '기장군',
          code: 'gijang',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '강서구',
          code: 'gangseo',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '남구',
          code: 'namgu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '금정구',
          code: 'geumjeong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '동래구',
          code: 'dongnae',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
        Gu(
          name: '동구',
          code: 'donggu',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
          ],
        ),
      ],
    ),
  ];

  static SubRegion? findSubRegionByName(String regionName, String subRegionName) {
    for (var region in regions) {
      if (region.name == regionName) {
        return region.subRegions?.firstWhere(
          (sub) => sub.name == subRegionName,
          orElse: () => SubRegion(name: '', code: ''),
        );
      }
    }
    return null;
  }
} 