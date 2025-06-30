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
      name: '서울특별시',
      code: 'seoul',
      gus: [
        Gu(
          name: '강남구',
          code: 'gangnam',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
            SubRegion(name: '역삼동', code: '6035'),
            SubRegion(name: '청담동', code: '386'),
            SubRegion(name: '대치동', code: '6032'),
            SubRegion(name: '논현동', code: '6031'),
            SubRegion(name: '압구정동', code: '385'),
            SubRegion(name: '삼성동', code: '6034'),
            SubRegion(name: '신사동', code: '382'),
            SubRegion(name: '도곡동', code: '6033'),
            SubRegion(name: '개포동', code: '6030'),
            SubRegion(name: '일원동', code: '6037'),
            SubRegion(name: '자곡동', code: '6038'),
            SubRegion(name: '수서동', code: '403'),
            SubRegion(name: '세곡동', code: '399'),
            SubRegion(name: '율현동', code: '6036'),
          ],
        ),
        Gu(
          name: '강동구',
          code: 'gangdong',
          dongs: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
            SubRegion(name: '천호동', code: '6044'),
            SubRegion(name: '길동', code: '448'),
            SubRegion(name: '상일동', code: '434'),
            SubRegion(name: '성내동', code: '6042'),
            SubRegion(name: '강일동', code: '433'),
            SubRegion(name: '암사동', code: '6043'),
            SubRegion(name: '둔촌동', code: '6040'),
            SubRegion(name: '명일동', code: '6041'),
            SubRegion(name: '고덕동', code: '6039'),
          ],
        ),
        Gu(
          name: '강북구',
          code: 'gangbuk',
          dongs: [
            SubRegion(name: '미아동', code: '142'),
            SubRegion(name: '수유동', code: '6046'),
            SubRegion(name: '삼각산동', code: '145'),
            SubRegion(name: '삼양동', code: '141'),
            SubRegion(name: '번동', code: '6045'),
            SubRegion(name: '송중동', code: '143'),
            SubRegion(name: '인수동', code: '153'),
            SubRegion(name: '송천동', code: '144'),
            SubRegion(name: '우이동', code: '152'),
          ],
        ),
        Gu(
          name: '노원구',
          code: 'nowon',
          dongs: [
            SubRegion(name: '상계동', code: '6073'),
            SubRegion(name: '공릉동', code: '6072'),
            SubRegion(name: '중계동', code: '6075'),
            SubRegion(name: '월계동', code: '6074'),
            SubRegion(name: '하계동', code: '6076'),
          ],
        ),
        Gu(
          name: '성북구',
          code: 'seongbuk',
          dongs: [
            SubRegion(name: '종암동', code: '133'),
            SubRegion(name: '길음동', code: '6145'),
            SubRegion(name: '석관동', code: '139'),
            SubRegion(name: '장위동', code: '6178'),
            SubRegion(name: '하월곡동', code: '6180'),
            SubRegion(name: '정릉동', code: '6179'),
            SubRegion(name: '돈암동', code: '6146'),
            SubRegion(name: '안암동', code: '125'),
            SubRegion(name: '성북동', code: '120'),
            SubRegion(name: '상월곡동', code: '6171'),
            SubRegion(name: '동선동', code: '122'),
            SubRegion(name: '삼선동', code: '121'),
            SubRegion(name: '보문동', code: '126'),
          ],
        ),
        Gu(
          name: '동대문구',
          code: 'dongdaemun',
          dongs: [
            SubRegion(name: '장안동', code: '6085'),
            SubRegion(name: '이문동', code: '6084'),
            SubRegion(name: '답십리동', code: '6081'),
            SubRegion(name: '휘경동', code: '6087'),
            SubRegion(name: '전농동', code: '6086'),
            SubRegion(name: '제기동', code: '89'),
            SubRegion(name: '용두동', code: '6083'),
            SubRegion(name: '회기동', code: '97'),
            SubRegion(name: '청량리동', code: '96'),
            SubRegion(name: '신설동', code: '6082'),
            SubRegion(name: '용신동', code: '88'),
          ],
        ),
      ],
    ),
    Region(
      name: '경기도',
      code: 'gyeonggi',
      subRegions: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
            SubRegion(name: '정자동', code: '1339'),
            SubRegion(name: '삼평동', code: '1351'),
            SubRegion(name: '백현동', code: '1352'),
            SubRegion(name: '구미동', code: '1355'),
            SubRegion(name: '판교동', code: '1350'),
            SubRegion(name: '서현동', code: '4502'),
            SubRegion(name: '금곡동', code: '1353'),
            SubRegion(name: '야탑동', code: '4505'),
            SubRegion(name: '분당동', code: '1335'),
            SubRegion(name: '운중동', code: '1356'),
            SubRegion(name: '이매동', code: '4507'),
            SubRegion(name: '수내동', code: '4504'),
            SubRegion(name: '대장동', code: '4500'),
            SubRegion(name: '궁내동', code: '4499'),
            SubRegion(name: '율동', code: '4506'),
            SubRegion(name: '석운동', code: '4503'),
            SubRegion(name: '하산운동', code: '4508'),
            SubRegion(name: '동원동', code: '4501'),
            SubRegion(name: '성남동', code: '1323'),
            SubRegion(name: '하대원동', code: '1332'),
            SubRegion(name: '금광동', code: '4520'),
            SubRegion(name: '중앙동', code: '1324'),
            SubRegion(name: '도촌동', code: '1333'),
            SubRegion(name: '상대원동', code: '4521'),
            SubRegion(name: '은행동', code: '4523'),
            SubRegion(name: '여수동', code: '4522'),
            SubRegion(name: '갈현동', code: '4519'),
            SubRegion(name: '위례동', code: '3971'),
            SubRegion(name: '창곡동', code: '4517'),
            SubRegion(name: '태평동', code: '4518'),
            SubRegion(name: '신흥동', code: '4514'),
            SubRegion(name: '복정동', code: '1318'),
            SubRegion(name: '단대동', code: '1315'),
            SubRegion(name: '양지동', code: '1317'),
            SubRegion(name: '고등동', code: '1320'),
            SubRegion(name: '시흥동', code: '1321'),
            SubRegion(name: '산성동', code: '1316'),
            SubRegion(name: '신촌동', code: '1319'),
            SubRegion(name: '수진동', code: '4513'),
            SubRegion(name: '심곡동', code: '4515'),
            SubRegion(name: '금토동', code: '4509'),
            SubRegion(name: '사송동', code: '4511'),
            SubRegion(name: '상적동', code: '4512'),
            SubRegion(name: '오야동', code: '4516'),
            SubRegion(name: '둔전동', code: '4510'),
        SubRegion(name: '인창동', code: '1581'),
        SubRegion(name: '갈매동', code: '1579'),
        SubRegion(name: '수택동', code: '4455'),
        SubRegion(name: '교문동', code: '4453'),
        SubRegion(name: '토평동', code: '4457'),
        SubRegion(name: '동구동', code: '1580'),
        SubRegion(name: '아천동', code: '4456'),
        SubRegion(name: '사노동', code: '4454'),
        SubRegion(name: '화도읍', code: '1590'),
        SubRegion(name: '진접읍', code: '1589'),
        SubRegion(name: '별내동', code: '1604'),
        SubRegion(name: '다산동', code: '4470'),
        SubRegion(name: '호평동', code: '1598'),
        SubRegion(name: '와부읍', code: '1588'),
        SubRegion(name: '오남읍', code: '1593'),
        SubRegion(name: '평내동', code: '1599'),
        SubRegion(name: '퇴계원읍', code: '1597'),
        SubRegion(name: '진건읍', code: '1592'),
        SubRegion(name: '금곡동', code: '1600'),
        SubRegion(name: '별내면', code: '1594'),
        SubRegion(name: '수동면', code: '1595'),
        SubRegion(name: '도농동', code: '4471'),
        SubRegion(name: '조안면', code: '1596'),
        SubRegion(name: '일패동', code: '4475'),
        SubRegion(name: '지금동', code: '4476'),
        SubRegion(name: '삼패동', code: '4472'),
        SubRegion(name: '양정동', code: '1601'),
        SubRegion(name: '수석동', code: '4473'),
        SubRegion(name: '이패동', code: '4474'),
      ],
    ),
    Region(
      name: '인천광역시',
      code: 'incheon',
      subRegions: [
            SubRegion(name: '선택 안함 (전체 동)', code: 'all'),
        SubRegion(name: '구월동', code: '6496'),
        SubRegion(name: '논현동', code: '6498'),
        SubRegion(name: '간석동', code: '6494'),
        SubRegion(name: '만수동', code: '6500'),
        SubRegion(name: '서창동', code: '6501'),
        SubRegion(name: '논현고잔동', code: '909'),
        SubRegion(name: '고잔동', code: '6495'),
        SubRegion(name: '남촌동', code: '6497'),
        SubRegion(name: '도림동', code: '6499'),
        SubRegion(name: '남촌도림동', code: '906'),
        SubRegion(name: '장수동', code: '6504'),
        SubRegion(name: '수산동', code: '6502'),
        SubRegion(name: '운연동', code: '6503'),
        SubRegion(name: '작전동', code: '6489'),
        SubRegion(name: '계산동', code: '6472'),
        SubRegion(name: '작전서운동', code: '942'),
        SubRegion(name: '효성동', code: '6493'),
        SubRegion(name: '병방동', code: '6481'),
        SubRegion(name: '임학동', code: '6488'),
        SubRegion(name: '동양동', code: '6476'),
        SubRegion(name: '용종동', code: '6486'),
        SubRegion(name: '박촌동', code: '6479'),
        SubRegion(name: '귤현동', code: '6473'),
        SubRegion(name: '서운동', code: '6483'),
        SubRegion(name: '방축동', code: '6480'),
        SubRegion(name: '오류동', code: '6485'),
        SubRegion(name: '이화동', code: '6487'),
        SubRegion(name: '다남동', code: '6475'),
        SubRegion(name: '하야동', code: '6492'),
        SubRegion(name: '갈현동', code: '6471'),
        SubRegion(name: '상야동', code: '6482'),
        SubRegion(name: '둑실동', code: '6477'),
        SubRegion(name: '평동', code: '6491'),
        SubRegion(name: '선주지동', code: '6484'),
        SubRegion(name: '목상동', code: '6478'),
        SubRegion(name: '노오지동', code: '6474'),
        SubRegion(name: '강화읍', code: '969'),
        SubRegion(name: '선원면', code: '970'),
        SubRegion(name: '길상면', code: '972'),
        SubRegion(name: '불은면', code: '971'),
        SubRegion(name: '양도면', code: '974'),
        SubRegion(name: '화도면', code: '973'),
        SubRegion(name: '하점면', code: '976'),
        SubRegion(name: '송해면', code: '978'),
        SubRegion(name: '내가면', code: '975'),
        SubRegion(name: '삼산면', code: '980'),
        SubRegion(name: '양사면', code: '977'),
        SubRegion(name: '교동면', code: '979'),
        SubRegion(name: '서도면', code: '981'),
        SubRegion(name: '송림동', code: '6506'),
        SubRegion(name: '송현동', code: '6507'),
        SubRegion(name: '만석동', code: '843'),
        SubRegion(name: '화수동', code: '6509'),
        SubRegion(name: '창영동', code: '6508'),
        SubRegion(name: '금곡동', code: '6505'),
        SubRegion(name: '화평동', code: '6510'),
        SubRegion(name: '도화동', code: '865'),
        SubRegion(name: '관교동', code: '874'),
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