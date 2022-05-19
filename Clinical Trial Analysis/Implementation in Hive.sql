-- Databricks notebook source
CREATE EXTERNAL TABLE clinicaltrial_2021(
id STRING,
sponsor STRING,
status STRING,
start_date STRING,
completion_date STRING,
type STRING ,
submission STRING,
conditions STRING,
interventions STRING) USING CSV
OPTIONS (path "dbfs:/FileStore/tables/clinicaltrial_2021.csv",
        delimiter "|",
        header "true");

SELECT * FROM clinicaltrial_2021

-- COMMAND ----------

CREATE EXTERNAL TABLE mesh(
term STRING,
tree STRING) USING CSV
OPTIONS (path "dbfs:/FileStore/tables/mesh.csv",
        delimiter ",",
        header "true");

SELECT * FROM mesh

-- COMMAND ----------

CREATE EXTERNAL TABLE pharma(
company STRING,
parent_company STRING) USING CSV
OPTIONS (path "dbfs:/FileStore/tables/pharma.csv",
        delimiter ",",
        header "true");
        
SELECT * FROM pharma

-- COMMAND ----------

-- Task-1
SELECT COUNT(DISTINCT id) AS Number_Of_Studies
FROM clinicaltrial_2021

-- COMMAND ----------

-- Task-2
SELECT type, COUNT(type) AS Frequency
FROM clinicaltrial_2021
GROUP BY type
ORDER BY COUNT(type) DESC

-- COMMAND ----------

-- Task-3
SELECT _Conditions, count(*) Frequency
FROM clinicaltrial_2021
LATERAL VIEW EXPLODE(SPLIT(conditions, ',')) as _Conditions
GROUP BY _Conditions
ORDER BY COUNT(_Conditions) DESC
LIMIT 5

-- COMMAND ----------

-- Task-4
CREATE OR REPLACE TEMP VIEW Conditions
AS (SELECT _Conditions, id
    FROM clinicaltrial_2021
    LATERAL VIEW EXPLODE(SPLIT(conditions, ',')) as _Conditions)

-- COMMAND ----------

-- Task-4
SELECT LEFT(tree,3) as Root,COUNT(*) as Frequency
FROM Conditions
INNER JOIN mesh
ON Conditions._Conditions=mesh.term
GROUP BY Root
ORDER BY COUNT(*) DESC
LIMIT 5

-- COMMAND ----------

-- Task-5
SELECT sponsor,COUNT(*) AS Frequency
FROM clinicaltrial_2021
WHERE sponsor NOT IN (SELECT parent_company
                      FROM pharma) 
GROUP BY sponsor
ORDER BY COUNT(*) DESC
LIMIT 10

-- COMMAND ----------

-- Task-6
CREATE OR REPLACE TEMP VIEW clinicaltrial_v
AS (SELECT id,
           sponsor,
           status,
           to_date(from_unixtime(unix_timestamp(start_date,'MMM yyyy'),'yyyy-MM-dd HH:mm:ss')) as start_date,
           to_date(from_unixtime(unix_timestamp(completion_date,'MMM yyyy'),'yyyy-MM-dd HH:mm:ss')) as completion_date,
           type,
           to_date(from_unixtime(unix_timestamp(submission,'MMM yyyy'),'yyyy-MM-dd HH:mm:ss')) as sumbission,
           conditions,
           interventions
    FROM clinicaltrial_2021)

-- COMMAND ----------

-- Task-6
SELECT completion_date AS Date,COUNT(*) AS Submissions
FROM clinicaltrial_v
WHERE status="Completed" and completion_date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY Date
ORDER BY Date
