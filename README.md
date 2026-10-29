# 📊 Data Analysis Portfolio

실무에서 수행한 데이터 분석 프로젝트를 기반으로  
**문제 정의 → 데이터 추출 → 분석 및 검증 → 운영 의사결정** 과정을 정리한 코드 포트폴리오입니다.

SQL과 Python을 활용한 사용자 행동 분석, A/B Test, KPI 설계, 데이터 품질 기준 수립 등의 프로젝트를 담고 있습니다.

> 실제 업무 데이터와 내부 식별 정보는 공개하지 않으며, 코드와 데이터는 분석 구조를 확인할 수 있도록 익명화하거나 공개용 Sample Data로 재구성했습니다.

---

## 📁 Projects

### 01. 🧪 운영 기준 전환 A/B Test

`SQL` `Python` `A/B Testing` `Statistics`

기존 운영 기준과 신규 기준의 성과 차이를 검증하고 실제 운영 기준 전환 여부를 판단한 프로젝트입니다.

- 한국·브라질 대상 **Cross-over A/B Test** 설계 및 분석
- Click → Download **CVR**을 핵심 지표로 설정
- Proportion Z-Test 기반 통계 검정 및 Fisher Exact Test 보조 검증
- 한국 CVR **7.41% → 11.43% (+54%)**
- 브라질 CVR **15.56% → 26.97% (+73%)**
- 분석 결과를 기반으로 신규 운영 기준 전환

### 🔗 [프로젝트 상세 보기](./01_ab_test/)

---

### 02. 📐 Engagement KPI 설계 및 운영 지표화

`SQL` `Amazon Athena` `KPI Design` `Event Log Analysis`

단순 AU만으로 설명하기 어려운 사용자 참여 수준을 행동 로그 기반 KPI로 설계한 프로젝트입니다.

- 1Depth / 2Depth 행동 로그를 기반으로 사용자 참여 수준 정의
- **Full / 1Depth / 2Depth Engagement** 지표 설계
- Full Engagement를 대표 KPI로 설정
- 사용자 행동 조합 기반 집계 로직 구현
- 고객사와 지표 정의를 협의한 뒤 정기 성과 리포트 지표로 반영

### 🔗 [프로젝트 상세 보기](./02_engagement_kpi/)

---

### 03. 🔍 Session Time 이상치 제거 기준 수립 및 시스템 적용

`Python` `EDA` `Data Quality` `Outlier Analysis`

2Depth 상세 콘텐츠의 Session Time 로그를 분석해 반복 적용 가능한 데이터 품질 기준을 수립한 프로젝트입니다.

- Session Time 분포 및 Scroll Depth별 사용자 행동 분석
- EDA를 기반으로 **300초 초과 로그 제외 기준 수립**
- Scroll Depth 조건 및 1초 미만 로그 제외 등 대안 기준 비교
- 추가 분석을 통해 기존 **300초 초과 제외 기준 유지**
- 내부 통계 시스템의 Session Time 산출 기준으로 반영

### 🔗 [프로젝트 상세 보기](./03_sessiontime_quality/)

---

### 04. 📉 Full Engagement 기반 저성과 Cutoff 기준 수립

`SQL` `Python` `EDA` `Percentile Analysis` `Policy Design`

반복 전시되는 매거진형 에디토리얼의 성과 분포를 분석해 저성과 판단 기준을 검토한 프로젝트입니다.

- W01~W20 에디토리얼별 Full Engagement 데이터 집계
- 실제 전시일수를 반영한 **일평균 Full Engagement** 산출
- Histogram, CDF, KDE 기반 성과 분포 분석
- P10 / P25 / P50 / P75 / P90 Percentile 비교
- 하위 25% 기준값 **1,965**를 저성과 Cutoff 후보로 제시
- 동일 에디토리얼의 반복 저성과 여부를 확인하는 **3-Out 기준 검토**

### 🔗 [프로젝트 상세 보기](./04_low_performance_cutoff/)

---

## 🔐 Data & Security

본 저장소의 프로젝트는 실제 실무 경험을 기반으로 작성했으며,  
회사 내부 데이터 및 보안 정보가 노출되지 않도록 다음 원칙을 적용했습니다.

- 실제 사용자 및 콘텐츠 식별자 제거
- 내부 DB 및 테이블명 익명화
- 공개가 어려운 이벤트명 및 운영 정보 치환
- 실제 원천 데이터 대신 구조와 분포를 재현한 **Sample Data** 사용
- 실제 분석 로직과 의사결정 과정은 가능한 범위에서 원본 구조 유지
