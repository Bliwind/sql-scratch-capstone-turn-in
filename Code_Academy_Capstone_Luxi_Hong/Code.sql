WITH 
 months AS
 (
 SELECT 
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
 UNION
 SELECT 
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
 UNION
 SELECT
   '2017-03-01' AS first_day,
   '2017-03-31' AS last_day
   ),
 cross_join AS
   (
   SELECT *
   FROM subscriptions
   CROSS JOIN months
   ),
 status AS 
   (
   SELECT id, first_day AS month,
   CASE
     WHEN segment = 87 AND subscription_start < first_day
     AND (
       subscription_end > first_day
       OR subscription_end IS NULL
       ) 
     THEN 1 ELSE 0 END AS is_active_87,
   CASE
     WHEN segment = 30 AND subscription_start < first_day
     AND (
       subscription_end > first_day
       OR subscription_end IS NULL
       ) 
     THEN 1 ELSE 0 END AS is_active_30,
   CASE 
     WHEN (subscription_end BETWEEN first_day AND last_day)
     AND segment = 87 
     THEN 1 ELSE 0 END AS is_canceled_87,
   CASE
     WHEN (subscription_end BETWEEN first_day AND last_day)
     AND segment = 30 
     THEN 1 ELSE 0 END AS is_canceled_30
   FROM cross_join),
 status_aggregate AS
   (
   SELECT 
     month,
     SUM(is_active_87) AS sum_active_87,
     SUM(is_active_30) AS sum_active_30,
     SUM(is_canceled_87) AS sum_canceled_87,
     SUM(is_canceled_30) AS sum_canceled_30
   FROM status
   GROUP BY month)
   SELECT month, 1.0 * sum_canceled_87/ sum_active_87 AS churn_rate_87, 1.0*sum_canceled_30/ sum_active_30 AS churn_rate_30
   FROM status_aggregate;
   
   
   --bonus question: code for large number of segments
   
   WITH 
 months AS
 (
 SELECT 
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
 UNION
 SELECT 
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
 UNION
 SELECT
   '2017-03-01' AS first_day,
   '2017-03-31' AS last_day
   ),
cross_join AS
   (
   SELECT *
   FROM subscriptions
   CROSS JOIN months
   ),
status AS 
   (
   SELECT id, segment, first_day AS month,
    CASE
     WHEN subscription_start < first_day
     AND (
       subscription_end > first_day
       OR subscription_end IS NULL
       ) 
     AND first_day = '2017-01-01'  
     THEN 1 ELSE 0 
    END AS is_active_Jan,
    CASE
     WHEN subscription_start < first_day
     AND (
       subscription_end > first_day
       OR subscription_end IS NULL
       ) 
     AND first_day = '2017-02-01'  
     THEN 1 ELSE 0 
    END AS is_active_Feb,
    CASE
     WHEN subscription_start < first_day
     AND (
       subscription_end > first_day
       OR subscription_end IS NULL
       ) 
     AND first_day = '2017-03-01'  
     THEN 1 ELSE 0 
    END AS is_active_Mar,
   CASE 
     WHEN (subscription_end BETWEEN first_day AND last_day)
     AND first_day = '2017-01-01'
     THEN 1 ELSE 0 
   END AS is_canceled_Jan,
   CASE 
     WHEN (subscription_end BETWEEN first_day AND last_day)
     AND first_day = '2017-02-01'
     THEN 1 ELSE 0 
   END AS is_canceled_Feb,
   CASE 
     WHEN (subscription_end BETWEEN first_day AND last_day)
     AND first_day = '2017-03-01'
     THEN 1 ELSE 0 
   END AS is_canceled_Mar
   FROM cross_join),
status_aggregate AS
   (
   SELECT 
     segment,
     SUM(is_active_Jan) AS sum_active_Jan,
     SUM(is_active_Feb) AS sum_active_Feb,
     SUM(is_active_Mar) AS sum_active_Mar,
     SUM(is_canceled_Jan) AS sum_canceled_Jan,
     SUM(is_canceled_Feb) AS sum_canceled_Feb,
     SUM(is_canceled_Mar) AS sum_canceled_Mar
    FROM status
   GROUP BY segment)
SELECT segment, 1.0 * sum_canceled_Jan/ sum_active_Jan AS churn_rate_Jan,
   1.0 * sum_canceled_Feb/ sum_active_Feb AS churn_rate_Feb,
   1.0 * sum_canceled_Mar/ sum_active_Mar AS churn_rate_Mar
FROM status_aggregate
GROUP BY segment;