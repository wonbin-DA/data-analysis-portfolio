# Data Analysis Portfolio

실무에서 수행한 데이터 분석 프로젝트를 기반으로  
SQL, Python, 통계 검정, KPI 설계 및 데이터 품질 관리 과정을 정리한 코드 포트폴리오입니다.

---

## Projects

### 01. 운영 기준 전환 A/B Test

`SQL` `Python` `A/B Testing` `Statistics`

- 한국·브라질 대상 Cross-over A/B Test 설계 및 분석
- Click → Download CVR을 핵심 지표로 운영 기준 성과 비교
- Proportion Z-Test 기반 통계 검정 및 Fisher Exact Test 보조 검증
- 분석 결과를 기반으로 신규 운영 기준 전환

[프로젝트 보기](./01_ab_test/)

---

### 02. Engagement KPI 설계 및 운영 지표화

`SQL` `Amazon Athena` `KPI Design` `Event Log Analysis`

- 단순 AU의 한계를 보완하기 위한 행동 기반 사용자 참여 지표 설계
- 1Depth / 2Depth 행동 로그를 기반으로 **Full / 1Depth / 2Depth Engagement** 정의
- Full Engagement를 대표 KPI로 설정하고 사용자 행동 조합 기반 집계 로직 구현
- 고객사와 지표 정의를 협의한 뒤 정기 성과 리포트 지표로 반영

[프로젝트 보기](./02_engagement_kpi/)

---

### 03. Session Time 이상치 제거 기준 검증 및 운영 적용

`Python` `EDA` `Data Quality` `Outlier Analysis`

- Session Time 장기 로그가 평균 및 분포에 미치는 영향 분석
- 전체 로그 중 **300초 초과 로그 약 0.56%** 확인
- Scroll Depth 조건, 1초 미만 로그 제외 등 대안 기준 비교 검토
- 분석 결과를 기반으로 **300초 초과 로그 제외 기준 유지 및 고객사 통계 시스템 산출 기준에 반영**

[프로젝트 보기](./03_sessiontime_quality/)

---
