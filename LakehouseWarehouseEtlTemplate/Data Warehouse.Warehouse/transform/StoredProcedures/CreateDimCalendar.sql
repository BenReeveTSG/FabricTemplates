CREATE PROC transform.CreateDimCalendar
AS
    TRUNCATE TABLE dbo.Dim_Calendar

    DECLARE @StartDate  date = DATEFROMPARTS(YEAR(GETDATE()) - 3, 01, 01)

    DECLARE @CutoffDate date = DATEADD(mm, 6, GETDATE())--DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate))

    DECLARE @CurrentFinancialYearStart CHAR(8) = CONCAT(CASE WHEN DATEPART(MONTH, GETDATE()) < 4 THEN DATEPART(YEAR, GETDATE()) - 1 ELSE DATEPART(YEAR, GETDATE()) END, '0401')

    DECLARE @CurrentFinancialYearEnd CHAR(8) = CONCAT(CASE WHEN DATEPART(MONTH, GETDATE()) < 4 THEN DATEPART(YEAR, GETDATE()) ELSE DATEPART(YEAR, GETDATE()) + 1 END, '0331')

    ;WITH d(d) AS 
    (
        SELECT 
            CalendarDate 
        
        FROM 
            generic.CalendarDates

        WHERE CalendarDate BETWEEN @StartDate AND @CutoffDate
    ),
        src AS
    (
    SELECT
        CONVERT(date, d) AS Date,
        DATEPART(DAY,       d) AS Day,
        DATENAME(WEEKDAY,   d) AS DayName,
        DATEPART(WEEK,      d) AS Week,
        --TheISOWeek      = DATEPART(ISO_WEEK,  d),
        DATEPART(WEEKDAY,   d) AS DayOfWeek,
		CASE 
			WHEN DATEPART(WEEKDAY,d) IN (CASE @@DATEFIRST WHEN 1 THEN 6 WHEN 7 THEN 1 END,7) THEN 1 
			ELSE 0 
		END AS IsWeekend,
        DATEPART(MONTH, d) AS Month,
        DATENAME(MONTH, d) AS MonthName,
        DATEPART(Quarter, d) AS Quarter,
        DATEPART(YEAR, d) AS Year,
        DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS FirstOfMonth,
        DATEFROMPARTS(YEAR(d), 12, 31) AS LastOfYear,
        DATEPART(DAYOFYEAR, d) AS DayOfYear,
        CASE 
			WHEN DATEPART(MONTH, d) >=4 THEN DATEPART(MONTH, d) - 3 
			ELSE DATEPART(MONTH,     d) + 9 
		END AS FinancialPeriod,
        CASE 
			WHEN DATEPART(MONTH, d) >=4 THEN DATEPART(QUARTER, d) - 1 
			ELSE 4 
		END AS FinancialQuarter,
        CASE 
			WHEN DATEPART(MONTH, d) < 4 THEN CONCAT(DATEPART(YEAR, d) - 1, '-', DATEPART(YEAR, d)) 
			ELSE CONCAT(DATEPART(YEAR, d), '-', DATEPART(YEAR, d) +1) 
		END AS FinancialYear,
        CASE 
			WHEN CONVERT(date, d) BETWEEN @CurrentFinancialYearStart AND @CurrentFinancialYearEnd THEN 1 
			ELSE 0 
		END AS InTheFinancialYTD

    FROM d
    ),
    dim AS
    (
    SELECT
        CAST(CAST([Date] AS DATETIME) AS FLOAT) DateKey, 
        Date, 
        Day,
        CONVERT(char(2), CASE WHEN Day / 10 = 1 THEN 'th' ELSE 
                                CASE RIGHT(Day, 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
                                WHEN '3' THEN 'rd' ELSE 'th' END END) AS DaySuffix,
        DayName,
        DayOfWeek,
        CONVERT(tinyint, ROW_NUMBER() OVER (PARTITION BY FirstOfMonth, DayOfWeek ORDER BY Date)) AS DayOfWeekInMonth,
        DayOfYear,
        IsWeekend,           
        CASE 
            WHEN IsWeekend = 0 THEN ROW_NUMBER() OVER (PARTITION BY Year, Month ORDER BY IsWeekend ASC, Date ASC) 
        END AS WorkingDayOfMonth,
        Week,
        --TheISOweek,
        DATEADD(DAY, 1 - DayOfWeek, Date) AS FirstOfWeek,
        DATEADD(DAY, 6, DATEADD(DAY, 1 - DayOfWeek, Date)) AS LastOfWeek,
        CONVERT(tinyint, DENSE_RANK() OVER (PARTITION BY Year, Month ORDER BY Week)) AS WeekOfMonth,
        Month,
        MonthName,
        LEFT(MonthName, 3) AS MonthNameShort,
        FirstOfMonth,
        MAX(Date) OVER (PARTITION BY Year, Month) AS LastOfMonth,
        DATEADD(MONTH, 1, FirstOfMonth) AS FirstOfNextMonth,
        DATEADD(DAY, -1, DATEADD(MONTH, 2, FirstOfMonth)) AS LastOfNextMonth,
        Quarter,
        MIN(Date) OVER (PARTITION BY Year, Quarter) AS FirstOfQuarter,
        MAX(Date) OVER (PARTITION BY Year, Quarter) AS LastOfQuarter,
        Year,
        -- TheISOYear          = TheYear - CASE WHEN TheMonth = 1 AND TheISOWeek > 51 THEN 1 
        --                         WHEN TheMonth = 12 AND TheISOWeek = 1  THEN -1 ELSE 0 END,      
        DATEFROMPARTS(Year, 1,  1) AS FirstOfYear,
        LastOfYear,
        CAST(CONCAT(CASE WHEN DATEPART(MONTH, Date) < 4 THEN DATEPART(YEAR, Date) - 1 ELSE DATEPART(YEAR, Date) END, '0401') AS DATE) AS FirstOfFinancialYear,
        CAST(CONCAT(CASE WHEN DATEPART(MONTH, Date) >= 4 THEN DATEPART(YEAR, Date) + 1 ELSE DATEPART(YEAR, Date) END, '0331') AS DATE) AS LastOfFinancialYear,
        FinancialPeriod,
        FinancialQuarter,
        FinancialYear,
        InTheFinancialYTD,
        CASE
            WHEN InTheFinancialYTD = 1 THEN 'Current'
            ELSE FinancialYear
        END AS FinancialYearFilter,
        DATEDIFF(mm, Date, GETDATE()) AS MonthsAgo,
        CAST(LEFT(@CurrentFinancialYearStart, 4) AS INT) -  CAST(LEFT(FinancialYear, 4) AS INT) AS FinancialYearsAgo,
        CONVERT(bit, CASE WHEN (Year % 400 = 0) OR (Year % 4 = 0 AND Year % 100 <> 0) THEN 1 ELSE 0 END) AS IsLeapYear,
        CASE WHEN DATEPART(WEEK,     LastOfYear) = 53 THEN 1 ELSE 0 END AS Has53Weeks,
        CASE WHEN DATEPART(ISO_WEEK, LastOfYear) = 53 THEN 1 ELSE 0 END AS Has53ISOWeeks,
        CONVERT(char(2), CONVERT(char(8), Date, 101)) + CONVERT(char(4), Year) AS MMYYYY,
        CONVERT(char(10), Date, 101) AS Style101,
        CONVERT(char(10), Date, 103) AS Style103,
        CONVERT(char(8),  Date, 112) AS Style112,
        CONVERT(char(10), Date, 120) AS Style120
    FROM src
    )

    INSERT INTO dbo.Dim_Calendar
    (
        DateKey, 
        Date, 
        Day,
        DaySuffix,
        DayName,
        DayOfWeek,
        DayOfWeekInMonth,
        DayOfYear,
        IsWeekend,           
        WorkingDayOfMonth,
        Week,
        FirstOfWeek,
        LastOfWeek,
        WeekOfMonth,
        Month,
        MonthName,
        MonthNameShort,
        FirstOfMonth,
        LastOfMonth,
        FirstOfNextMonth,
        LastOfNextMonth,
        Quarter,
        FirstOfQuarter,
        LastOfQuarter,
        Year,   
        FirstOfYear,
        LastOfYear,
        FirstOfFinancialYear,
        LastOfFinancialYear,
        FinancialPeriod,
        FinancialQuarter,
        FinancialYear,
        InTheFinancialYTD,
        FinancialYearFilter,
        MonthsAgo,
        FinancialYearsAgo,
        IsLeapYear,
        Has53Weeks,
        Has53ISOWeeks,
        MMYYYY,
        Style101,
        Style103,
        Style112,
        Style120
    )

    SELECT
        DateKey, 
        Date, 
        Day,
        DaySuffix,
        DayName,
        DayOfWeek,
        DayOfWeekInMonth,
        DayOfYear,
        IsWeekend,           
        WorkingDayOfMonth,
        Week,
        FirstOfWeek,
        LastOfWeek,
        WeekOfMonth,
        Month,
        MonthName,
        MonthNameShort,
        FirstOfMonth,
        LastOfMonth,
        FirstOfNextMonth,
        LastOfNextMonth,
        Quarter,
        FirstOfQuarter,
        LastOfQuarter,
        Year,   
        FirstOfYear,
        LastOfYear,
        FirstOfFinancialYear,
        LastOfFinancialYear,
        FinancialPeriod,
        FinancialQuarter,
        FinancialYear,
        InTheFinancialYTD,
        FinancialYearFilter,
        MonthsAgo,
        FinancialYearsAgo,
        IsLeapYear,
        Has53Weeks,
        Has53ISOWeeks,
        MMYYYY,
        Style101,
        Style103,
        Style112,
        Style120

    FROM dim