-- script to create DimTime table in SQL Server
DROP TABLE IF EXISTS dbo.DimTime;
DECLARE @full_time TIME;
DECLARE @counter INT;
DECLARE @time_as_string VARCHAR(6);

SET @full_time = '00:00:00';
SET @counter = 0;
SET @time_as_string = '000000';

CREATE TABLE dbo.DimTime (
  time_id INT NOT NULL,
  time_as_string VARCHAR(6),
  full_time TIME(0),
  hour INT,
  minute INT,
  second INT,
  am_pm VARCHAR(2) NOT NULL,
  notation12 VARCHAR(20),
  notation24 VARCHAR(20),
  PRIMARY KEY (time_id)
);

WHILE @counter < 86400
BEGIN
  INSERT INTO dbo.DimTime (
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
    DATEPART(HOUR, @full_time)*10000+DATEPART(MINUTE, @full_time)*100+DATEPART(SECOND, @full_time),
    @time_as_string,
    @full_time,
    DATEPART(HOUR, @full_time),
    DATEPART(MINUTE, @full_time),
    DATEPART(SECOND, @full_time),
    CASE WHEN (DATEPART(HOUR, @full_time) < 12) THEN 'AM' ELSE 'PM' END,
    CONVERT(VARCHAR(20), @full_time, 22),
    CONVERT(VARCHAR(20), @full_time, 108)
  );

  -- Raise full_time with one second
  SET @full_time = DATEADD(SECOND, 1, @full_time);

  -- Raise time_as_string with the hhmmss format
  SET @time_as_string = REPLACE(CONVERT(VARCHAR(8),@full_time, 108),':','');

  SET @counter = @counter + 1;
END;

SELECT * FROM dbo.DimTime
ORDER BY time_as_string;