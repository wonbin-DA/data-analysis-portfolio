-- 04_low_performance_cutoff
-- 매거진형 에디토리얼 Full Engagement 주차별 집계
-- 원본 구조를 유지하되 내부 식별 정보는 공개용 값으로 치환

WITH params AS (
SELECT
    DATE '2026-01-01' AS start_dt, -- 주차 시작일
    DATE '2026-01-07' AS end_dt,   -- 주차 종료일

    ARRAY[
        'editorial_001', 'editorial_002', 'editorial_003',
        'editorial_004', 'editorial_005', 'editorial_006'
    ] AS componentkey, -- Componentid

    ARRAY[
        'set_001', 'set_002', 'set_003', 'set_004', 'URL'
    ] AS setid, -- 1/2Depth Setid

    ARRAY[
        'excluded_user_001', 'excluded_user_002', 'excluded_user_003'
    ] AS banned_guid, -- 제외 Guid

    ARRAY['000'] AS country_code -- 공개용 국가 코드
)

,base_T1 AS (
SELECT DISTINCT
      date
    , mcc
    , mnc
    , modelName
    , screenType
    , contentType
    , logName
    , componentid
    , promotionType
    , indexInList
    , productId
    , bannerType
    , bannerLinkedUrl
    , productSetId
    , SUBSTR(dateTime, 1, 12) AS datetime
    , hashedImei
    , guid
    , clickType
    , clientVersion
    , downloadTryTypeName
    , paymentStopReasonTypeName
    , issuccess
    , utminfo
    , screenpath
    , CASE
        WHEN utminfo LIKE '%channel=editorial_home%' THEN 'editorial_1st'
        WHEN utminfo LIKE '%channel=editorial_detail%' THEN 'editorial_2nd'
        ELSE NULL
      END AS channel
    , CASE
        WHEN STRPOS(utminfo, 'componentId=editorial_theme_001') > 0 THEN 'editorial_theme_001'
        ELSE NULL
      END AS componentKey
FROM "AwsDataCatalog"."analytics"."theme_event_log" AS aa
CROSS JOIN params AS p
WHERE 1=1
AND CONTAINS(p.country_code, aa.mcc)
AND NOT CONTAINS(p.banned_guid, aa.guid)
AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
AND logName IN ('download_click', 'free_download_click', 'paid_download_click')
AND STRPOS(utminfo, 'componentId=editorial_theme_001') > 0
)

,base_T2 AS (
SELECT DISTINCT
      date
    , mcc
    , mnc
    , modelName
    , screenType
    , contentType
    , logName
    , componentid
    , promotionType
    , indexInList
    , productId
    , bannerType
    , bannerLinkedUrl
    , productSetId
    , SUBSTR(dateTime, 1, 12) AS datetime
    , hashedImei
    , guid
    , clickType
    , clientVersion
    , downloadTryTypeName
    , paymentStopReasonTypeName
    , issuccess
    , utminfo
    , screenpath
    , 'editorial_2nd' AS channel
    , CASE
        WHEN STRPOS(utminfo, 'componentId=editorial_theme_002') > 0 THEN 'editorial_theme_002'
        ELSE NULL
      END AS componentKey
FROM "AwsDataCatalog"."analytics"."theme_event_log" AS aa
CROSS JOIN params AS p
WHERE 1=1
AND CONTAINS(p.country_code, aa.mcc)
AND NOT CONTAINS(p.banned_guid, aa.guid)
-- 특정 에디토리얼 예외 기간 구조 유지
AND CAST(date AS DATE) BETWEEN DATE('2026-01-05') AND DATE('2026-01-07')
AND logName IN ('download_click', 'free_download_click', 'paid_download_click')
AND STRPOS(utminfo, 'componentId=editorial_theme_002') > 0
)

,base_T AS (
SELECT * FROM base_T1
UNION ALL
SELECT * FROM base_T2
)

,raw_t AS (
SELECT
      year_week
    , date
    , channel
    , componentKey
    , ctr_type
    , user_id
FROM (
    SELECT
          SUBSTRING(CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 3, 2)
          || 'Y W'
          || LPAD(CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 2, '0') AS year_week
        , date
        , channel
        , componentKey
        , 'download' AS ctr_type
        , CASE
            WHEN clientVersion >= 300
                AND screenPath IS NOT NULL
                AND logName = 'download_click'
                AND downloadTryTypeName IN ('download', 'redownload', 'update', 'purchase')
                AND hashedImei IS NOT NULL THEN guid

            WHEN clientVersion < 300
                AND clientVersion >= 200
                AND logName = 'download_click'
                AND downloadTryTypeName IN ('download', 'redownload', 'update', 'purchase')
                AND hashedImei IS NOT NULL THEN guid

            WHEN clientVersion <= 100
                AND logName IN ('free_download_click', 'paid_download_click')
                AND hashedImei IS NOT NULL THEN guid
            ELSE NULL
          END AS user_id
    FROM base_T
)
WHERE user_id IS NOT NULL
)

-- Grid Type 조건
,base_grid AS (
SELECT DISTINCT
      date
    , mcc
    , mnc
    , modelName
    , screenType
    , contentType
    , logName
    , componentid
    , promotionType
    , indexInList
    , productId
    , bannerType
    , bannerLinkedUrl
    , productSetId
    , SUBSTR(dateTime, 1, 12) AS datetime
    , hashedImei
    , guid
    , clickType
    , clientVersion
    , downloadTryTypeName
    , paymentStopReasonTypeName
    , issuccess
    , utminfo
    , screenpath
    , 'editorial_2nd' AS channel
    , CASE
        WHEN STRPOS(utminfo, 'componentId=editorial_grid_001') > 0 THEN 'editorial_grid_001'
        ELSE NULL
      END AS componentKey
FROM "AwsDataCatalog"."analytics"."theme_event_log" AS aa
CROSS JOIN params AS p
WHERE 1=1
AND CONTAINS(p.country_code, aa.mcc)
AND NOT CONTAINS(p.banned_guid, aa.guid)
AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
AND logName IN (
    'download_click', 'free_download_click', 'paid_download_click',
    'product_list_item_click', 'curated_item_click', 'popup_item_click'
)
AND contentType IN ('CONTENT_TYPE_A', 'CONTENT_TYPE_B')
AND STRPOS(utminfo, 'componentId=editorial_grid_001') > 0
)

,raw_grid AS (
SELECT *
FROM base_grid
WHERE componentid IS NULL

UNION ALL

SELECT *
FROM base_grid
WHERE componentid IN ('editorial_grid_001')
)

,raw_g AS (
SELECT
      year_week
    , date
    , channel
    , componentKey
    , ctr_type
    , user_id
FROM (
    SELECT
          SUBSTRING(CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 3, 2)
          || 'Y W'
          || LPAD(CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 2, '0') AS year_week
        , date
        , channel
        , componentKey
        , CASE
            WHEN logName IN ('download_click', 'free_download_click', 'paid_download_click') THEN 'download'
            WHEN logName IN ('product_list_item_click', 'curated_item_click', 'popup_item_click') THEN 'click'
            ELSE NULL
          END AS ctr_type
        , CASE
            WHEN clientVersion >= 300
                AND screenPath IS NOT NULL
                AND logName = 'download_click'
                AND downloadTryTypeName IN ('download', 'redownload', 'update', 'purchase')
                AND hashedImei IS NOT NULL THEN guid

            WHEN clientVersion < 300
                AND clientVersion >= 200
                AND logName = 'download_click'
                AND downloadTryTypeName IN ('download', 'redownload', 'update', 'purchase')
                AND hashedImei IS NOT NULL THEN guid

            WHEN clientVersion <= 100
                AND logName IN ('free_download_click', 'paid_download_click')
                AND hashedImei IS NOT NULL THEN guid

            WHEN clientVersion >= 200
                AND logName IN ('product_list_item_click', 'curated_item_click', 'popup_item_click')
                AND screenType IN (
                    'PRODUCT_LIST_A', 'PRODUCT_LIST_B', 'PRODUCT_LIST_C',
                    'PRODUCT_LIST_D', 'PRODUCT_LIST_E'
                ) THEN guid
            ELSE NULL
          END AS user_id
    FROM raw_grid
)
WHERE user_id IS NOT NULL
)

,theme_final AS (
SELECT * FROM raw_g
UNION ALL
SELECT * FROM raw_t
)

,base_a AS (
SELECT
      SUBSTRING(CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 3, 2)
      || 'Y W'
      || LPAD(CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 2, '0') AS year_week
    , date
    , CASE
        WHEN set_id IN ('set_001', 'set_002', 'set_003', 'set_004', 'set_005')
            AND item_pos = 0
            AND ctr_type = 'download' THEN 'editorial_2nd'
        WHEN channel IN ('editorial_home') THEN 'editorial_1st'
        WHEN channel IN ('editorial_detail', 'content_list') THEN 'editorial_2nd'
        ELSE channel
      END AS channel
    , componentid
    , CASE
        WHEN ctr_type = 'download'
            AND buttonstatus IN ('RESUME_MANUAL', 'RESUME_AUTO') THEN 'resume_DL'
        ELSE ctr_type
      END AS ctr_type
    , guid
FROM "AwsDataCatalog"."analytics"."app_event_log" AS aa
CROSS JOIN params AS p
WHERE 1=1
AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
AND NOT CONTAINS(p.banned_guid, aa.guid)
AND CONTAINS(p.componentkey, aa.componentid)
AND CONTAINS(p.country_code, aa.mcc)
AND guid IS NOT NULL
AND channel IN ('editorial_home', 'editorial_detail', 'content_list')
AND ctr_type IN ('impression', 'click', 'download', 'enter_detail')
)

,raw AS (
SELECT *
FROM base_a
WHERE ctr_type NOT IN ('resume_DL')

UNION ALL

SELECT *
FROM theme_final
)

-- 1Depth / 2Depth 행동 집계
,aggregated AS (
SELECT
      guid
    , year_week
    , date
    , componentid
    , ARRAY_AGG(DISTINCT ctr_type)
        FILTER(WHERE channel = 'editorial_1st') AS first_ctrs
    , ARRAY_AGG(DISTINCT ctr_type)
        FILTER(WHERE channel = 'editorial_2nd') AS second_ctrs
FROM raw
GROUP BY 1,2,3,4
)

-- Engagement 조건 적용
,labeled_ AS (
SELECT
      *
    , CASE
        WHEN (CONTAINS(first_ctrs, 'click') OR CONTAINS(first_ctrs, 'download'))
          OR (CONTAINS(second_ctrs, 'click') OR CONTAINS(second_ctrs, 'download'))
        THEN guid
      END AS full_engagement_guid
    , CASE
        WHEN CONTAINS(first_ctrs, 'download')
         AND second_ctrs IS NULL
        THEN guid
      END AS first_engagement_guid
    , CASE
        WHEN CONTAINS(first_ctrs, 'click')
         AND (CONTAINS(second_ctrs, 'click') OR CONTAINS(second_ctrs, 'download'))
        THEN guid
      END AS second_depth_engagement_guid
FROM aggregated
)

SELECT
      year_week
    , componentid
    , COUNT(DISTINCT full_engagement_guid) AS full_cnt
    , COUNT(DISTINCT first_engagement_guid) AS first_cnt
    , COUNT(DISTINCT second_depth_engagement_guid) AS second_cnt
FROM labeled_
WHERE second_depth_engagement_guid IS NOT NULL
   OR full_engagement_guid IS NOT NULL
   OR first_engagement_guid IS NOT NULL
GROUP BY 1,2;
