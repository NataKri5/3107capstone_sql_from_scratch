1. Get familiar with Codeflix 

1.1 Streaming since December 2016

SELECT MIN(subscription_start) AS first_subscription, 
MAX(subscription_start) AS last_subscription 
FROM subscriptions;

1.2 The first hundred rows: Segmenting

SELECT * 
FROM subscriptions 
LIMIT 100; 

SELECT DISTINCT segment 
FROM subscriptions;



2. What is the overall churn trend since the company started?  

2.1 Overall Churn Rate

WITH months AS 
 (SELECT
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
  UNION
  SELECT
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
  UNION 
  SELECT
   '2017-03-01' AS first_day, 
   '2017-03-31' AS last_day),
cross_join AS 
 (SELECT * 
  FROM subscriptions
  CROSS JOIN months), 
status AS 
 (SELECT 
   id, 
   first_day AS month,
   CASE 
    WHEN (subscription_start < first_day)
     AND ((subscription_end > first_day)
      OR (subscription_end is NULL))
    THEN 1 
    ELSE 0 
   END AS is_active,
   CASE 
    WHEN (subscription_end BETWEEN first_day AND last_day)
    THEN 1 
    ELSE 0 
   END AS is_canceled
  FROM cross_join),
status_aggregate AS 
	(SELECT 
          SUM(is_active) AS sum_active,
	  SUM(is_canceled) AS sum_canceled
         FROM status
	)
SELECT 
 ROUND(1.0*sum_canceled/sum_active, 4) AS churn_rate
FROM status_aggregate;

2.2 Monthly Churn Rate

WITH months AS 
 (SELECT
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
  UNION
  SELECT
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
  UNION 
  SELECT
   '2017-03-01' AS first_day, 
   '2017-03-31' AS last_day),
cross_join AS 
 (SELECT * 
  FROM subscriptions
  CROSS JOIN months), 
status AS 
 (SELECT 
   id, 
   first_day AS month,
   CASE 
    WHEN (subscription_start < first_day)
     AND ((subscription_end > first_day)
      OR (subscription_end is NULL))
    THEN 1 
    ELSE 0 
   END AS is_active,
   CASE 
    WHEN (subscription_end BETWEEN first_day AND last_day)
    THEN 1 
    ELSE 0 
   END AS is_canceled
  FROM cross_join),
status_aggregate AS 
	(SELECT 
   	  month, 
  SUM(is_active) AS sum_active,
  SUM(is_canceled) AS sum_canceled
       FROM status
       GROUP BY month)
SELECT 
 month, 
 ROUND(1.0*sum_canceled/sum_active, 4) AS churn_rate
FROM status_aggregate;

3. Compare the churn rates between segments 

3.1 Battle of the segments

WITH months AS 
 (SELECT
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
  UNION
  SELECT
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
  UNION 
  SELECT
   '2017-03-01' AS first_day, 
   '2017-03-31' AS last_day),
cross_join AS 
 (SELECT * 
  FROM subscriptions
  CROSS JOIN months), 
status AS 
 (SELECT 
   id, 
   first_day AS month,
   CASE 
    WHEN (subscription_start < first_day)
     AND (
     (subscription_end > first_day)
     OR (subscription_end is NULL)
     ) 
     AND (segment = '87') 
    THEN 1 
    ELSE 0 
   END AS is_active_87,
   CASE 
    WHEN (subscription_start < first_day)
     AND (
     (subscription_end > first_day)
     OR (subscription_end is NULL)
     ) 
     AND (segment = '30') 
    THEN 1 
    ELSE 0 
   END AS is_active_30,
   CASE 
    WHEN (subscription_end BETWEEN first_day AND last_day)
     AND (segment = '87') 
    THEN 1 
    ELSE 0 
   END AS is_canceled_87,
   CASE 
    WHEN (subscription_end BETWEEN first_day AND last_day)
     AND (segment = '30') 
    THEN 1 
    ELSE 0 
   END AS is_canceled_30
  FROM cross_join),
status_aggregate AS 
	(SELECT 
          SUM(is_active_87) AS sum_active_87,
 	  SUM(is_active_30) AS sum_active_30,
   	  SUM(is_canceled_87) AS sum_canceled_87,
   	  SUM(is_canceled_30) AS sum_canceled_30
         FROM status)
SELECT 
ROUND(1.0*sum_canceled_87/sum_active_87, 4) AS churn_87, 
ROUND(1.0*sum_canceled_30/sum_active_30, 4) AS churn_30
FROM STATUS_aggregate;



3.2 More segments

WITH months AS 
 (SELECT
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
  UNION
  SELECT
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
  UNION 
  SELECT
   '2017-03-01' AS first_day, 
   '2017-03-31' AS last_day),
cross_join AS 
 (SELECT * 
  FROM subscriptions
  CROSS JOIN months), 
status AS 
 (SELECT 
   segment,
   id, 
   first_day AS month,
   CASE 
    WHEN (subscription_start < first_day)
     AND (
     (subscription_end > first_day)
     OR (subscription_end is NULL)
     ) 
    THEN 1 
    ELSE 0 
   END AS is_active,
  CASE 
    WHEN (subscription_end BETWEEN first_day AND last_day)
    THEN 1 
    ELSE 0 
   END AS is_canceled
  FROM cross_join),
status_aggregate AS 
	(SELECT 
   	segment,
   	SUM(is_active) AS sum_active,
 	SUM(is_canceled) AS sum_canceled
   FROM status
  GROUP BY segment)
SELECT 
 segment, 
 ROUND(1.0*sum_canceled/sum_active,4) AS churn_rate
FROM status_aggregate;

3.3 Monthly Churn Rate per Segment

WITH months AS 
 (SELECT
   '2017-01-01' AS first_day,
   '2017-01-31' AS last_day
  UNION
  SELECT
   '2017-02-01' AS first_day,
   '2017-02-28' AS last_day
  UNION 
  SELECT
   '2017-03-01' AS first_day, 
   '2017-03-31' AS last_day),
cross_join AS 
 (SELECT * 
  FROM subscriptions
  CROSS JOIN months), 
status AS 
 (SELECT 
   segment,
   id, 
   first_day AS month,
   CASE 
    WHEN (subscription_start < first_day)
     AND (
     (subscription_end > first_day)
     OR (subscription_end is NULL)
     ) 
    THEN 1 
    ELSE 0 
   END AS is_active,
  CASE 
    WHEN (subscription_end BETWEEN first_day AND last_day)
    THEN 1 
    ELSE 0 
   END AS is_canceled
  FROM cross_join),
status_aggregate AS 
	(SELECT 
   	month, 
    segment,
   	SUM(is_active) AS sum_active,
 	SUM(is_canceled) AS sum_canceled
   FROM status
  GROUP BY segment, month)
SELECT 
 month, 
 segment, 
 ROUND(1.0*sum_canceled/sum_active, 4) AS churn_rate
FROM status_aggregate;








