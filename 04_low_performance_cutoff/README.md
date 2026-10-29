# 📊 매거진형 에디토리얼 저성과 Cutoff 기준 수립

> 반복 전시되는 **매거진형 에디토리얼 콘텐츠**의 성과를 객관적으로 판단하기 위해 Full Engagement 분포를 분석하고,  
> 저성과 Cutoff와 반복 저성과 에디토리얼을 관리하기 위한 **3-Out 운영 기준 제안**

---

## 1. Project Overview

서비스 내에서는 여러 앱과 콘텐츠를 하나의 주제로 큐레이션해 소개하는 **매거진형 에디토리얼 콘텐츠**를 운영하고 있으며, 기존 에디토리얼이 여러 주차에 걸쳐 반복적으로 재사용되는 경우가 있었습니다.

하지만 일부 에디토리얼은 반복 전시에도 사용자 반응을 나타내는 **Full Engagement가 지속적으로 낮게 나타났고**, 어느 수준부터 저성과 에디토리얼로 판단할 것인지에 대한 명확한 기준이 없는 상태였습니다.

주간 리포팅 내 분석 과정에서 이를 개선하기 위해 먼저 다음과 같은 운영안을 제안했습니다.

```text
Full Engagement 2,000 이하
        +
동일 에디토리얼 3회 누적
        ↓
반복 전시 제외 또는
재사용 우선순위 하향 검토
```

이후 기획팀에서 해당 기준을 실제 에디토리얼 재사용 정책으로 활용하기 전, **2,000이라는 Cutoff가 전체 에디토리얼 성과 분포에서 적정한 수준인지 데이터 기반 검증을 요청**했습니다.

이에 26년 W01~W20의 에디토리얼별 Full Engagement를 분석하고, 실제 전시일수를 반영한 일평균 성과를 기준으로 Percentile, Histogram, CDF, KDE 분석을 수행했습니다.

분석 결과 **하위 25% 지점이 Full Engagement 1,965**로 확인되었으며, 이는 최초 제안했던 2,000과 매우 근접한 수준이었습니다.

따라서 **P25인 1,965 이하를 저성과 에디토리얼 Cutoff 후보로 정의하고, 동일 에디토리얼이 해당 기준에 반복적으로 도달할 경우 재사용 우선순위를 조정하는 3-Out 운영안을 제안**했습니다.

- **분석 기간:** 2026-01-01 ~ 2026-05-20, W01~W20
- **분석 대상:** 주차별 매거진형 에디토리얼 Full Engagement
- **분석 범위:** 한국
- **핵심 지표:** Full Engagement
- **분석 도구:** SQL, Amazon Athena, Python, Pandas, Matplotlib, Seaborn
- **Cutoff 후보:** 하위 25%, **Full Engagement 1,965 이하**
- **운영안:** 동일 에디토리얼이 저성과 기준에 3회 도달할 경우 반복 전시 제외 또는 재사용 우선순위 하향 검토

---

## 2. Key Achievements

- **📉 저성과 에디토리얼 판단 기준 정량화**
  - 명확한 수치 기준이 없었던 저성과 에디토리얼을 Full Engagement 분포와 Percentile을 이용해 정량화했습니.
  - 하위 25% 지점인 **1,965**를 저성과 Cutoff 후보로 도출했습니다.

- **💡 기존 운영 제안의 데이터 기반 검증**
  - 주간 리포트에서 먼저 제안했던 **Full Engagement 2,000 이하** 기준이 실제 전체 에디토리얼 분포의 P25인 1,965와 근접함을 확인했습니다.
  - 경험적 운영 제안을 실제 장기간 성과 데이터로 재검증했습니다.

- **🔁 반복 저성과를 반영한 관리 기준 설계**
  - 한 번의 저성과만으로 에디토리얼을 제외하지 않고, 동일 에디토리얼이 Cutoff 이하 성과를 **3회 기록했을 때 관리 대상으로 보는 3-Out 방식**을 제안했습니다.

- **🤝 분석 결과의 운영 기준 연결**
  - Percentile 결과를 단순 리포팅하는 데 그치지 않고, 에디토리얼 재사용 여부와 우선순위를 판단할 수 있는 운영 기준으로 구체화했습니다.

---

## 3. Problem Definition

### 기존 운영의 문제

매거진형 에디토리얼이 반복적으로 재사용되는 상황에서 일부 에디토리얼은 여러 번 전시되어도 Full Engagement가 낮게 나타났습니다.

하지만 당시에는 다음과 같은 질문에 답할 수 있는 기준이 명확하지 않았습니다.

```text
어느 정도의 성과부터
'저성과 에디토리얼'이라고 볼 것인가?

        ↓

한 번 성과가 낮으면
재사용을 중단할 것인가?

        ↓

반복적으로 낮은 성과를 보이는 에디토리얼을
어떤 기준으로 관리할 것인가?
```

단순히 평균보다 낮다는 이유만으로 저성과 에디토리얼을 정의하면 전체 성과 분포의 형태를 충분히 반영하지 못할 수 있습니다.

또한 에디토리얼마다 실제 전시 기간이 서로 달라 단순 Full Engagement 합계만 비교할 경우 **장기간 전시된 에디토리얼이 구조적으로 유리해지는 문제**가 있었습니다.

따라서 다음 두 가지가 필요했습니다.

1. **전시 기간 차이를 보정한 동일 기준의 성과 비교**
2. **전체 에디토리얼 성과 분포를 기반으로 한 객관적인 저성과 Cutoff 설정**

---

## 4. Data Preparation

### 4.1 에디토리얼별 Full Engagement 집계

SQL을 이용해 매거진형 에디토리얼별 Full Engagement를 주차 단위로 집계했습니다.

Full Engagement는 사용자 행동 로그를 기반으로 정의한 사용자 참여 KPI이며, 에디토리얼 단위의 Unique User 기준으로 산출했습니다.

```text
사용자 행동 로그
        ↓
1Depth / 2Depth 행동 집계
        ↓
Full Engagement 사용자 정의
        ↓
주차 × 에디토리얼별 Unique User 집계
```

공개 Repository에서는 실제 데이터베이스명, 내부 이벤트명, 실제 에디토리얼 ID 및 사용자 식별 정보는 제거하고 동일한 분석 구조를 재현할 수 있도록 익명화합니다.

---

### 4.2 실제 전시일수 보정

에디토리얼마다 한 주 전체를 전시한 경우도 있고, 주중에 전시를 시작하거나 종료한 경우도 있었습니다.

따라서 각 에디토리얼의 운영 기간과 해당 주차의 시작일과 종료일을 비교해 **실제 전시일수**를 계산했습니다.

```python
df["Actual Start Date"] = (
    df[
        [
            "Life Start Date",
            "Week Start Date",
        ]
    ]
    .max(axis=1)
)

df["Actual End Date"] = (
    df[
        [
            "Life End Date",
            "Week End Date",
        ]
    ]
    .min(axis=1)
)

df["Display Days"] = (
    df["Actual End Date"]
    - df["Actual Start Date"]
).dt.days + 1
```

이후 총 Full Engagement를 실제 전시일수로 나누어 에디토리얼별 **일평균 Full Engagement**를 계산했습니다.

```python
df["Full Engagement(Avg.)"] = (
    df["Full Engagement"]
    / df["Display Days"]
)
```

이를 통해 실제 전시 기간이 서로 다른 에디토리얼도 동일한 기준에서 비교할 수 있도록 했습니다.

---

## 5. Distribution Analysis

전체 에디토리얼의 일평균 Full Engagement 분포를 확인한 결과, **일부 고성과 에디토리얼이 매우 높은 값을 기록하는 Long-tail 형태**가 나타났습니다.

```text
다수의 저·중성과 에디토리얼
────────────────────▶
                     일부 고성과 에디토리얼
                     ───────────────▶
```

즉 평균값 하나만으로 저성과 기준을 설정할 경우 소수 고성과 에디토리얼의 영향을 크게 받을 가능성이 있었습니다.

따라서 평균값 자체보다 **전체 에디토리얼 중 해당 성과가 어느 위치에 해당하는지를 보여주는 Percentile**을 Cutoff 판단 기준으로 사용했습니다.

---

### 5.1 Histogram

전체적인 Full Engagement 분포와 저성과 영역을 확인했습니다.

```python
plt.figure(figsize=(12, 6))

sns.histplot(
    fe,
    bins=30,
    edgecolor="black",
    linewidth=1.2,
)

plt.xlabel("Full Engagement (Daily Avg.)")
plt.ylabel("Editorial Count")

plt.show()
```

Histogram을 통해 다수의 에디토리얼이 상대적으로 낮은 성과 영역에 위치하고, 일부 고성과 에디토리얼이 오른쪽 꼬리를 형성하는 분포를 확인했습니다.

---

### 5.2 Cumulative Distribution

특정 Full Engagement 값 이하의 에디토리얼이 전체에서 어느 정도 비중을 차지하는지 확인하기 위해 누적 분포를 분석했습니다.

```python
x = np.sort(fe)
y = np.arange(
    1,
    len(x) + 1,
) / len(x)

plt.figure(figsize=(12, 6))

sns.lineplot(
    x=x,
    y=y,
    linewidth=1.5,
)

plt.xlabel("Full Engagement (Daily Avg.)")
plt.ylabel("Cumulative Ratio")

plt.show()
```

누적 분포에서도 **하위 25% 이후부터 Full Engagement 증가폭이 본격적으로 확대되는 흐름**을 확인했습니다.

이는 P25 이하 영역을 전체 에디토리얼 중 상대적인 저성과 그룹으로 구분할 수 있는 근거로 활용했습니다.

---

### 5.3 KDE

에디토리얼 성과가 주로 분포하는 구간과 Percentile 위치를 함께 확인하기 위해 KDE를 활용했습니다.

```python
plt.figure(figsize=(12, 6))

sns.kdeplot(
    fe,
    linewidth=1,
    fill=True,
)

plt.xlabel("Full Engagement (Daily Avg.)")
plt.ylabel("Density")

plt.show()
```

밀도 분포를 통해 주요 에디토리얼이 분포하는 영역과 상대적으로 성과가 낮은 구간을 함께 확인했습니다.

---

## 6. Percentile Analysis

전체 에디토리얼의 일평균 Full Engagement를 기준으로 주요 Percentile을 계산했습니다.

```python
percentiles = {
    "P10": np.percentile(fe, 10),
    "P25": np.percentile(fe, 25),
    "Median(P50)": np.percentile(fe, 50),
    "P75": np.percentile(fe, 75),
    "P90": np.percentile(fe, 90),
}

percentile_df = pd.DataFrame(
    {
        "Percentile": percentiles.keys(),
        "Full Engagement": percentiles.values(),
    }
)

percentile_df
```

분석 결과는 다음과 같았습니다.

| Percentile | Full Engagement (Daily Avg.) |
|---|---:|
| P10 | 792 |
| **P25** | **1,965** |
| Median, P50 | 3,117 |
| P75 | 5,168 |
| P90 | 9,271 |

하위 25%에 해당하는 **1,965 이하 구간은 전체 에디토리얼 가운데 상대적으로 성과가 낮은 그룹**으로 확인되었습니다.

또한 실제 성과 분포에서도 해당 구간 이후부터 Full Engagement 값이 본격적으로 증가하는 흐름을 보여, **P25 = 1,965를 운영상 저성과 Cutoff 후보로 활용할 수 있는 수준**으로 판단했습니다.

이 값은 주간 리포트에서 사전에 제안했던 **Full Engagement 2,000 이하 기준과도 매우 근접한 수준**으로, 기존 운영 제안이 전체 에디토리얼 성과 분포에서도 저성과 구간을 구분하는 기준으로 활용 가능한지 확인할 수 있었습니다.

---

## 7. 3-Out Policy Proposal & Final Decision

Cutoff만으로 운영할 경우 한 번의 일시적인 저성과만으로도 에디토리얼이 관리 대상이 될 수 있습니다.

에디토리얼 성과는 전시 시점과 사용자 반응에 따라 변동될 수 있기 때문에, **단일 저성과보다 반복적인 저성과 여부를 함께 확인하는 방식**을 검토했습니다.

이에 다음과 같은 3-Out 운영 기준을 제안했습니다.

```text
Full Engagement ≤ 1,965 (P25)
        ↓
       1-Out

재전시 후 동일 기준 이하
        ↓
       2-Out

재전시 후 동일 기준 이하
        ↓
       3-Out

반복 전시 제외
또는
재사용 우선순위 하향 검토
```

이 방식은 한 번의 저성과만으로 에디토리얼을 즉시 제외하지 않으면서, **반복적으로 낮은 성과를 보이는 에디토리얼을 관리 대상으로 식별하기 위한 기준**입니다.

최종적으로 **P25인 Full Engagement 1,965 이하를 저성과 Cutoff 후보로 제시하고, 동일 에디토리얼이 해당 기준에 3회 도달할 경우 반복 전시 제외 또는 재사용 우선순위 하향을 검토하는 운영안을 제안**했습니다.

### 판단 근거

- 전체 에디토리얼 Full Engagement가 Long-tail 형태의 분포를 보임
- Percentile 기준이 전체 분포 내 상대적 성과 위치를 판단하기에 적합
- 밀도 및 누적 분포에서 P25 이하가 주요 성과 구간 이전의 저성과 영역으로 확인
- 하위 25% 기준값이 **1,965**로 확인
- 기존에 제안했던 **2,000 이하 기준과 실제 P25 값이 근접**
- 1회 저성과보다 반복 저성과를 기준으로 관리하는 방식이 보다 보수적인 운영 방식이라고 판단

> **💡 Policy Insight**  
> Cutoff는 에디토리얼을 즉시 제외하기 위한 절대 기준이 아니라, 반복적인 저성과를 탐지해 재사용 여부를 검토하기 위한 운영 판단 기준으로 제안했습니다.

---

## 8. Outcome

이 프로젝트를 통해 매거진형 에디토리얼의 성과를 단순히 높고 낮음으로 평가하는 것이 아니라, **전체 성과 분포에서의 상대적 위치를 기준으로 저성과 영역을 정량화했습니다.**

또한 주간 리포트에서 사전에 제안했던 운영 기준을 실제 장기간 데이터로 검증하고, **P25 기반 Cutoff와 반복 저성과 횟수를 결합해 에디토리얼 재사용 판단에 활용할 수 있는 운영 기준으로 구체화했습니다.**

---

## 9. Repository Information

본 Repository는 실제 회사 데이터와 내부 운영 정보를 포함하지 않고, 분석 구조를 재현할 수 있도록 공개용으로 구성합니다.

### SQL

```text
sql/
└── full_engagement_extract.sql
```

주차 × 에디토리얼 단위 Full Engagement를 산출하기 위한 공개용 SQL입니다.

실제 데이터베이스명, 내부 이벤트명, 실제 에디토리얼 ID, 사용자 식별값 및 서비스 관련 정보는 익명화합니다.

### Python

```text
python/
└── cutoff_analysis.ipynb
```

다음 분석 과정을 포함합니다.

- 에디토리얼별 실제 전시일수 산출
- 일평균 Full Engagement 계산
- Percentile 분석
- Histogram
- CDF
- KDE
- Cutoff 후보 검토

### Sample Data

```text
sample_data/
└── sample_engagement.csv
```

실제 회사 데이터를 사용하지 않고 분석 로직을 재현할 수 있도록 생성한 합성 에디토리얼 성과 데이터입니다.

> 실제 회사 데이터, 고객사명, 내부 데이터베이스명, 실제 에디토리얼명 및 ID, 사용자 식별 정보와 운영 관련 민감 정보는 포함하지 않습니다.

---

## Tech Stack

`SQL` `Amazon Athena` `Python` `Pandas` `NumPy` `Matplotlib` `Seaborn` `EDA` `Percentile Analysis` `Distribution Analysis` `Policy Design`

---

[← Back to Data Analysis Portfolio](../)
