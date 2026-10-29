/*
===============================================================================
Engagement KPI
===============================================================================
Purpose
- 1Depth / 2Depth 사용자 행동 로그 통합
- 사용자별 행동 조합 기반 Engagement User 분류
- Full / 1Depth / 2Depth Engagement Weekly Unique User 산출

Public Repository Notice
- 실제 업무 DB명, 테이블명, 사용자 식별자, 콘텐츠 ID,
  국가코드, 이벤트명 및 운영 관련 값은 공개용으로 익명화
- Engagement 분류 및 집계 로직은 실제 분석 구조 기반
===============================================================================
*/

WITH params AS (
    SELECT
        DATE '2026-01-01' AS start_dt,
        DATE '2026-01-07' AS end_dt,
        ARRAY['content_001', 'content_002'] AS componentkey,
        ARRAY['set_001'] AS setid,
        CAST(ARRAY[] AS ARRAY(VARCHAR)) AS banned_user,
        ARRAY['000'] AS country_code
)

-- Auxiliary Content Log
,base_T AS (
    SELECT DISTINCT
        date, country_code, network_code, device_model, screen_type, content_type,
        event_name, content_id, promotion_type, item_position, product_id,
        banner_type, linked_url, product_set_id, SUBSTR(event_time, 1, 12) AS datetime,
        device_hash, user_id, click_type, client_version, download_type,
        payment_stop_reason, is_success, tracking_info, screen_path,
        CASE
            WHEN tracking_info LIKE '%channel=content_home%' THEN 'depth_1'
            WHEN tracking_info LIKE '%channel=content_detail%' THEN 'depth_2'
            ELSE NULL
        END AS channel,
        CASE
            WHEN STRPOS(tracking_info, 'componentId=theme_content_001') > 0
                THEN 'theme_content_001'
            ELSE NULL
        END AS componentKey
    FROM "sample_catalog"."sample_schema"."auxiliary_event_log" AS aa
    CROSS JOIN params AS p
    WHERE 1=1
      AND CONTAINS(p.country_code, aa.country_code)
      AND NOT CONTAINS(p.banned_user, aa.user_id)
      AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
      AND event_name IN ('download_click', 'free_download_click', 'paid_download_click')
      AND STRPOS(tracking_info, 'componentId=theme_content_001') > 0
)

,raw_t AS (
    SELECT year_week, date, channel, componentKey, ctr_type, user_id
    FROM (
        SELECT
            SUBSTRING(
                CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 3, 2
            ) || 'Y W' ||
            LPAD(
                CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 2, '0'
            ) AS year_week,
            date,
            channel,
            componentKey,
            'download' AS ctr_type,
            CASE
                WHEN client_version >= 300030000
                     AND screen_path IS NOT NULL
                     AND event_name = 'download_click'
                     AND download_type IN ('download', 'redownload', 'update', 'purchase')
                     AND device_hash IS NOT NULL THEN user_id
                WHEN client_version < 300030000
                     AND client_version >= 300020000
                     AND event_name = 'download_click'
                     AND download_type IN ('download', 'redownload', 'update', 'purchase')
                     AND device_hash IS NOT NULL THEN user_id
                WHEN client_version <= 300010000
                     AND event_name IN ('free_download_click', 'paid_download_click')
                     AND device_hash IS NOT NULL THEN user_id
                ELSE NULL
            END AS user_id
        FROM base_T
    )
    WHERE user_id IS NOT NULL
)

-- Grid Type
,base_grid AS (
    SELECT DISTINCT
        date, country_code, network_code, device_model, screen_type, content_type,
        event_name, content_id, promotion_type, item_position, product_id,
        banner_type, linked_url, product_set_id, SUBSTR(event_time, 1, 12) AS datetime,
        device_hash, user_id, click_type, client_version, download_type,
        payment_stop_reason, is_success, tracking_info, screen_path,
        'depth_2' AS channel,
        CASE
            WHEN STRPOS(tracking_info, 'componentId=grid_content_001') > 0
                THEN 'grid_content_001'
            ELSE NULL
        END AS componentKey
    FROM "sample_catalog"."sample_schema"."auxiliary_event_log" AS aa
    CROSS JOIN params AS p
    WHERE 1=1
      AND CONTAINS(p.country_code, aa.country_code)
      AND NOT CONTAINS(p.banned_user, aa.user_id)
      AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
      AND event_name IN (
          'download_click', 'free_download_click', 'paid_download_click',
          'product_list_click', 'curated_item_click', 'content_popup_click'
      )
      AND content_type IN ('Category_A', 'Category_B')
      AND STRPOS(tracking_info, 'componentId=grid_content_001') > 0
)

,raw_grid AS (
    SELECT *
    FROM base_grid
    WHERE content_id IS NULL

    UNION ALL

    SELECT *
    FROM base_grid
    WHERE content_id IN ('grid_content_001')
)

,raw_g AS (
    SELECT year_week, date, channel, componentKey, ctr_type, user_id
    FROM (
        SELECT
            SUBSTRING(
                CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 3, 2
            ) || 'Y W' ||
            LPAD(
                CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 2, '0'
            ) AS year_week,
            date,
            channel,
            componentKey,
            CASE
                WHEN event_name IN ('download_click', 'free_download_click', 'paid_download_click')
                    THEN 'download'
                WHEN event_name IN ('product_list_click', 'curated_item_click', 'content_popup_click')
                    THEN 'click'
                ELSE NULL
            END AS ctr_type,
            CASE
                WHEN client_version >= 300030000
                     AND screen_path IS NOT NULL
                     AND event_name = 'download_click'
                     AND download_type IN ('download', 'redownload', 'update', 'purchase')
                     AND device_hash IS NOT NULL THEN user_id
                WHEN client_version < 300030000
                     AND client_version >= 300020000
                     AND event_name = 'download_click'
                     AND download_type IN ('download', 'redownload', 'update', 'purchase')
                     AND device_hash IS NOT NULL THEN user_id
                WHEN client_version <= 300010000
                     AND event_name IN ('free_download_click', 'paid_download_click')
                     AND device_hash IS NOT NULL THEN user_id
                WHEN client_version >= 300020000
                     AND event_name IN ('product_list_click', 'curated_item_click', 'content_popup_click')
                     AND screen_type IN (
                         'PRODUCT_LIST_A', 'PRODUCT_LIST_B', 'PRODUCT_LIST_C',
                         'PRODUCT_LIST_D', 'PRODUCT_LIST_E'
                     ) THEN user_id
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

-- Main Content Log
,base_a AS (
    SELECT
        SUBSTRING(
            CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 3, 2
        ) || 'Y W' ||
        LPAD(
            CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) AS VARCHAR), 2, '0'
        ) AS year_week,
        date,
        CASE
            WHEN set_id IN ('set_001')
                 AND item_position = 0
                 AND ctr_type = 'download' THEN 'depth_2'
            WHEN channel IN ('content_home') THEN 'depth_1'
            WHEN channel IN ('content_detail', 'content_list') THEN 'depth_2'
            ELSE channel
        END AS channel,
        content_id,
        CASE
            WHEN ctr_type = 'download'
                 AND button_status IN ('RESUME_MANUAL', 'RESUME_AUTO') THEN 'resume_DL'
            ELSE ctr_type
        END AS ctr_type,
        user_id
    FROM "sample_catalog"."sample_schema"."content_event_log" AS aa
    CROSS JOIN params AS p
    WHERE 1=1
      AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
      AND NOT CONTAINS(p.banned_user, aa.user_id)
      AND CONTAINS(p.componentkey, aa.content_id)
      AND CONTAINS(p.country_code, aa.country_code)
      AND user_id IS NOT NULL
      AND channel IN ('content_home', 'content_detail', 'content_list')
      AND ctr_type IN ('impression', 'click', 'download', 'enter_content')
)

-- Main + Auxiliary Log
,raw AS (
    SELECT *
    FROM base_a
    WHERE ctr_type NOT IN ('resume_DL')

    UNION ALL

    SELECT * FROM theme_final
)

-- 사용자 × 날짜 × 콘텐츠 단위 1Depth / 2Depth 행동 집계
,aggregated AS (
    SELECT
        user_id,
        year_week,
        date,
        content_id,
        ARRAY_AGG(DISTINCT ctr_type)
            FILTER (WHERE channel = 'depth_1') AS first_ctrs,
        ARRAY_AGG(DISTINCT ctr_type)
            FILTER (WHERE channel = 'depth_2') AS second_ctrs
    FROM raw
    GROUP BY 1,2,3,4
)

-- Engagement Labeling
,labeled_ AS (
    SELECT *,
        CASE
            WHEN (CONTAINS(first_ctrs, 'click') OR CONTAINS(first_ctrs, 'download'))
              OR (CONTAINS(second_ctrs, 'click') OR CONTAINS(second_ctrs, 'download'))
            THEN user_id
        END AS full_engagement_user,

        CASE
            WHEN CONTAINS(first_ctrs, 'download')
             AND second_ctrs IS NULL
            THEN user_id
        END AS first_engagement_user,

        CASE
            WHEN CONTAINS(first_ctrs, 'click')
             AND (CONTAINS(second_ctrs, 'click') OR CONTAINS(second_ctrs, 'download'))
            THEN user_id
        END AS second_depth_engagement_user
    FROM aggregated
)

-- Weekly Engagement KPI
SELECT
    year_week,
    COUNT(DISTINCT full_engagement_user) AS full_engagement,
    COUNT(DISTINCT first_engagement_user) AS first_engagement,
    COUNT(DISTINCT second_depth_engagement_user) AS two_depth_engagement
FROM labeled_
WHERE full_engagement_user IS NOT NULL
   OR first_engagement_user IS NOT NULL
   OR second_depth_engagement_user IS NOT NULL
GROUP BY 1
ORDER BY 1;
