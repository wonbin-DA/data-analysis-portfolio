                       'PRODUCT_LIST_B',
                       'PRODUCT_LIST_C',
                       'PRODUCT_LIST_D',
                       'PRODUCT_LIST_E'
                 ) THEN guid
            ELSE NULL
        END AS user_id
      FROM raw_grid
)
WHERE user_id IS NOT NULL
)

,theme_final AS(
SELECT
*
FROM raw_g
UNION ALL
SELECT * FROM raw_t 
)

,base_a as (
select 
SUBSTRING(
    CAST(YEAR_OF_WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) as VARCHAR),
    3,
    2
)
|| 'Y W'
|| LPAD(
    CAST(WEEK(DATE_ADD('day', -3, CAST(date AS DATE))) as VARCHAR),
    2,
    '0'
) AS year_week,
date,
case 
    when (set_id IN ('set_001', 'set_002', 'set_003', 'set_004', 'set_005'))
         AND (item_pos = 0)
         AND (ctr_type = 'download') THEN 'editorial_2nd'
    when channel in ('editorial_home') then 'editorial_1st'
    when channel in ('editorial_detail', 'content_list') then 'editorial_2nd'
    else channel
end as channel,
componentid,
CASE 
    WHEN (ctr_type = 'download')
         and (buttonstatus IN ('RESUME_MANUAL','RESUME_AUTO')) THEN 'resume_DL'
    ELSE ctr_type
END AS ctr_type,
guid
from "AwsDataCatalog"."analytics"."app_event_log" AS aa
CROSS JOIN params AS p
WHERE 1=1
AND CAST(date AS DATE) BETWEEN start_dt AND end_dt
AND NOT CONTAINS(p.banned_guid, aa.guid)
AND CONTAINS(p.componentkey, aa.componentid)
AND CONTAINS(p.country_code, aa.mcc)
AND guid is not null
AND channel in ('editorial_home', 'editorial_detail', 'content_list')
AND ctr_type IN ('impression', 'click', 'download', 'enter_detail')
)

,raw AS (
SELECT * FROM base_a where ctr_type NOT IN ('resume_DL')
UNION ALL
SELECT * FROM theme_final
)

-- 1Depth / 2Depth 행동 집계
,aggregated AS (
SELECT
guid,
year_week,
date,
componentid,
ARRAY_AGG(DISTINCT ctr_type)
    FILTER(where channel = 'editorial_1st') as first_ctrs,
ARRAY_AGG(DISTINCT ctr_type)
    FILTER(where channel = 'editorial_2nd') as second_ctrs
FROM raw
GROUP BY 1,2,3,4
)

-- Engagement 조건 적용
,labeled_ AS (
SELECT *,
    CASE
        WHEN
        (CONTAINS(first_ctrs, 'click') OR CONTAINS(first_ctrs, 'download'))
        OR
        (CONTAINS(second_ctrs, 'click') OR CONTAINS(second_ctrs, 'download'))
        THEN guid
    END AS full_engagement_guid,

    CASE
        WHEN
        (CONTAINS(first_ctrs, 'download'))
        AND
        second_ctrs IS NULL
        THEN guid
    END AS first_engagement_guid,

    CASE    
        WHEN
        (CONTAINS(first_ctrs, 'click'))
        AND
        (CONTAINS(second_ctrs, 'click') OR CONTAINS(second_ctrs, 'download'))
        THEN guid
    END AS second_depth_engagement_guid
FROM aggregated
)

select
year_week,
componentid,
count(distinct full_engagement_guid) as full_cnt,
COUNT(distinct first_engagement_guid) AS first_cnt,
count(distinct second_depth_engagement_guid) as second_cnt
from labeled_
where (second_depth_engagement_guid is not null)
   OR (full_engagement_guid is not null)
   OR (first_engagement_guid IS NOT NULL)
group by 1,2
;
