-- script to create DimTime table
DECLARE full_time TIME;
DECLARE counter INT64;
DECLARE time_as_string STRING;
SET full_time = '00:00:00';
SET counter = 0;
SET time_as_string = '000000';

CREATE OR REPLACE TABLE {project_id}.{dataset_id}.{table_name} (
  time_id STRING NOT NULL,
  time_as_string STRING,
  full_time TIME,
  hour INT64,
  minute INT64,
  second INT64,
  am_pm STRING NOT NULL,
  notation12 STRING,
  notation24 STRING,
  PRIMARY KEY (time_id) NOT ENFORCED
);

WHILE counter < 86400 DO
  INSERT INTO {project_id}.{dataset_id}.{table_name} (
    time_id,
    time_as_string,
    full_time,
    hour,
    minute,
    second,
    am_pm,
    notation12,
    notation24
  )
  VALUES (
    Generate_UUID(),
    time_as_string,
    full_time,
    EXTRACT(HOUR FROM full_time),
    EXTRACT(MINUTE FROM full_time),
    EXTRACT(SECOND FROM full_time),
    CASE WHEN (EXTRACT(HOUR FROM full_time) < 12) THEN 'AM' ELSE 'PM' END,
    FORMAT_TIME('%r', full_time),
    FORMAT_TIME('%H:%M:%S', full_time)
  );

  -- Raise full_time with one second
  SET full_time = TIME_ADD(full_time, INTERVAL 1 SECOND);

  -- Raise time_as_string with the hhmmss format
  SET time_as_string = FORMAT_TIME('%H%M%S', full_time);
  
  SET counter = counter + 1;
END WHILE;