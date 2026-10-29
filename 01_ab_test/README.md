# 운영 기준 전환 A/B Test

> 기존 매출 중심 운영 기준과 신규 사용자 활성도 기반 기준을 비교하여,  
> **Click → Download 전환율(CVR)과 다운로드 성과 개선 여부를 검증한 A/B Test 프로젝트**

---

## 1. Project Overview

글로벌 앱마켓 내 전시 영역은 콘텐츠 노출을 통한 다운로드 확대를 주요 목표로 운영되고 있었습니다.
다만 실험 대상 구좌의 기존 앱리스트 선정 기준은 매출 지표 중심으로 구성되어 있어, 운영 목표와 선정 기준 간 정합성을 검토할 필요가 있었습니다.

이에 **신규 사용자 활성도를 반영한 운영 기준이 기존 기준보다 실제 다운로드 전환에 유리한지 검증**하기 위해 한국과 브라질을 대상으로 A/B Test를 설계하고 분석했습니다.

| 항목 | 내용 |
|---|---|
| 분석 목적 | 신규 운영 기준의 CVR 및 Download 개선 여부 검증 |
| 실험 국가 | Korea / Brazil |
| 실험 기간 | Korea 8주 / Brazil 4주 |
| 기존 기준 | ARPU 기반 |
| 신규 기준 | NAU 비율 기반 |
| 핵심 지표 | CVR = Download / Click |
| 가드레일 지표 | 전시 Download |
| 분석 도구 | SQL, Python |
| 통계 검정 | Proportion Z-Test, Fisher Exact Test |

---

## 2. Problem

전시 구좌의 운영 목표는 **다운로드 확대**였지만, 기존 앱리스트 선정 기준은 매출 관련 지표를 중심으로 구성되어 있었습니다.

운영 목표와 선정 기준 사이의 정합성을 높이기 위해 신규 사용자 활성도를 나타내는 **NAU 비율**을 주요 변수로 활용한 새로운 선정 기준을 검토했습니다.

```text
NAU Ratio = NAU / AU
```

단순히 NAU가 높은 콘텐츠를 선택할 경우 전체 사용자 규모가 큰 콘텐츠가 유리해질 수 있기 때문에, **전체 사용자 대비 신규 사용자의 비중**을 기준으로 비교했습니다.

### Hypothesis

**H0**

> 운영 기준을 ARPU 기반에서 NAU 기반으로 변경해도 CVR에는 차이가 없다.

**H1**

> 운영 기준을 ARPU 기반에서 NAU 기반으로 변경하면 CVR이 증가한다.

---

## 3. Experiment Design

단말군별 사용자 규모나 기본 행동 성향의 차이가 운영 기준의 효과로 해석되는 것을 줄이기 위해 **Cross-over 방식의 A/B Test**를 적용했습니다.

### Korea

`2025-07-17 ~ 2025-09-10 / 8 Weeks`

| Period | Device Group A | Device Group B |
|---|---|---|
| First 4 Weeks | NAU | ARPU |
| Last 4 Weeks | ARPU | NAU |

### Brazil

`2025-07-31 ~ 2025-08-27 / 4 Weeks`

| Period | Device Group A | Device Group B |
|---|---|---|
| First 2 Weeks | NAU | ARPU |
| Last 2 Weeks | ARPU | NAU |

실험 전·후반에 NAU와 ARPU 기준을 교차 적용하여 **특정 단말군의 사용자 규모나 기본적인 클릭·다운로드 성향이 결과에 미치는 영향을 완화**했습니다.

또한 실험군과 대조군에서 운영되는 앱리스트의 구성 조건을 가능한 동일하게 유지하여 **운영 기준 외 변수의 영향을 최소화**했습니다.

---

## 4. Metric Design

### Primary Metric

#### CVR

```text
CVR = Download / Click
```

사용자가 콘텐츠를 클릭한 이후 실제 다운로드까지 이어지는 비율로, 신규 선정 기준이 다운로드 전환에 미치는 영향을 판단하는 핵심 지표로 사용했습니다.

### Guardrail Metric

#### Download

CVR만 개선되고 실제 다운로드 볼륨이 감소하는 상황을 방지하기 위해 **전시 구좌에서 발생한 Download 수를 함께 확인**했습니다.

### Supporting Metrics

추가적으로 아래 지표를 함께 확인했습니다.

```text
CTR = Click / Impression

IPM = Download / Impression × 1,000
```

---

## 5. Data Processing

분석 과정은 크게 다음과 같이 구성했습니다.

```text
Athena SQL
    ↓
실험 대상 로그 추출
    ↓
Impression / Click / Download 집계
    ↓
실험 기간 및 단말군 기준 매핑
    ↓
Cross-over 기준을 반영하여 NAU / ARPU 그룹 재분류
    ↓
국가별 성과 지표 계산
    ↓
통계 검정
```

### SQL

SQL을 활용해 NAU 기반 운영 기준 산출에 필요한 콘텐츠별 성과 지표를 추출했습니다.

주요 처리 항목:

- 국가 × 콘텐츠 단위 데이터 구성
- NAU / AU 집계
- NAU Ratio 산출
- Download 집계
- Revenue / PU / ARPPU 산출

공개 코드에서는 실제 업무 데이터베이스명, 테이블명, 콘텐츠 ID 등 내부 정보를 익명화했습니다.

### Sample Data

분석 로직 재현을 위해 공개용으로 생성한 합성 샘플 데이터를 사용합니다.

> 일별 수치는 실제 회사 데이터를 사용하지 않았으며, 국가별 최종 집계값은 포트폴리오에 공개한 분석 결과와 동일하게 구성했습니다.

### Python

Python에서는 추출 데이터를 기반으로:

- 데이터 전처리 및 병합
- 실험 기간별 그룹 매핑
- Cross-over 이후 NAU / ARPU 기준 재분류
- 국가별 지표 집계
- CVR / CTR / IPM 계산
- 통계 검정
- 결과 시각화

를 수행했습니다.

---

## 6. Statistical Test

핵심 지표인 CVR은 **Download / Click 형태의 비율 지표**이므로 두 집단의 비율 차이를 검정했습니다.

### Proportion Z-Test

표본이 충분한 구간에서는 이항분포의 정규근사를 이용한 **Proportion Z-Test**를 적용했습니다.

```text
H0 : CVR_NAU = CVR_ARPU
H1 : CVR_NAU > CVR_ARPU
```

### Fisher Exact Test

빈도가 낮은 구간에서도 결과를 확인할 수 있도록 **Fisher Exact Test를 함께 적용하여 검정 결과를 교차 확인**했습니다.

유의수준은:

```text
α = 0.05
```

로 설정했습니다.

---

## 7. Results

### Korea

| Metric | ARPU | NAU | Change |
|---|---:|---:|---:|
| Impression | 92,250 | 92,108 | - |
| Click | 1,821 | 2,003 | +10% |
| Download | 135 | 229 | **+70%** |
| CTR | 1.97% | 2.17% | +10% |
| CVR | 7.41% | **11.43%** | **+54%** |
| IPM | 1.463 | 2.486 | - |

CVR:

```text
7.41% → 11.43%
+4.02%p / +54%
```

통계 검정 결과:

```text
Proportion Z-Test p-value = 0.000012
Fisher Exact Test p-value = 0.000013
```

---

### Brazil

| Metric | ARPU | NAU | Change |
|---|---:|---:|---:|
| Impression | 507,287 | 518,231 | - |
| Click | 5,302 | 7,253 | +37% |
| Download | 825 | 1,956 | **+137%** |
| CTR | 1.05% | 1.40% | +32% |
| CVR | 15.56% | **26.97%** | **+73%** |
| IPM | 1.626 | 3.774 | - |

CVR:

```text
15.56% → 26.97%
+11.41%p / +73%
```

두 검정 모두 `p < 0.05`로 나타나 귀무가설을 기각했습니다.

---

## 8. Interpretation

두 국가 모두에서 신규 NAU 기반 운영 기준의 CVR이 기존 ARPU 기반 기준보다 높게 나타났습니다.

특히 단순 전환율 개선에 그치지 않고 실제 Download 역시 증가했습니다.

```text
Korea
CVR       +54%
Download  +70%

Brazil
CVR       +73%
Download +137%
```

따라서 **신규 운영 기준이 클릭 이후 다운로드 전환뿐 아니라 실제 다운로드 볼륨 측면에서도 기존 기준보다 유리한 방향임을 확인**했습니다.

또한 실험 결과가 서비스 전반의 변화에 따른 것인지 확인하기 위해 다른 주요 고정 구좌의 다운로드 성과도 비교했습니다. 다른 구좌의 다운로드 증감률은 -3~+4% 수준에 그친 반면,
실험 구좌는 한국 70%, 브라질 137% 증가해 신규 선정 기준의 효과를 뒷받침하는 근거로 판단했습니다.

---

## 9. Decision

A/B Test 결과를 기반으로 **NAU 비율을 반영한 신규 기준을 정식 운영 기준으로 전환**했습니다.

분석은 단순 성과 비교에서 종료하지 않고:

```text
문제 정의
→ 가설 설정
→ 실험 설계
→ 데이터 추출
→ 통계 검정
→ 결과 해석
→ 운영 기준 변경
```

까지 연결했습니다.

이 프로젝트를 통해 **데이터 분석 결과를 실제 운영 의사결정에 연결하는 전 과정을 경험**했습니다.

---

## 10. Repository Information

### SQL

NAU 기반 운영 기준 산출을 위한 콘텐츠별 NAU, AU, Download, Revenue 지표 추출 및 가공

### Python

데이터 전처리, 성과 지표 계산, 시각화 및 통계 검정

### Sample Data

분석 로직 재현을 위해 실제 업무 데이터 대신 익명화·가공한 예제 데이터를 사용합니다.

> 실제 회사 데이터, 내부 테이블명, 사용자 식별자, 콘텐츠 ID 및 운영 관련 민감 정보는 포함하지 않습니다.

---

## Tech Stack

`SQL` `Amazon Athena` `Python` `Pandas` `NumPy` `Statsmodels` `SciPy` `Matplotlib` `Seaborn`

---

[← Back to Data Analysis Portfolio](../)
