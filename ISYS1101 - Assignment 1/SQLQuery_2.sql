USE s3978281
GO

CREATE TABLE [week7].[inventoryy] 
(
  inventory_id DECIMAL(7),
  film_id DECIMAL(5),
  store_id DECIMAL(3),
  last_update DATETIME
);


CREATE TABLE [week7].[film] (
  film_id DECIMAL(5),
  title VARCHAR(255),
  description VARCHAR(1000),
  release_year DECIMAL(4),
  language_id DECIMAL(3),
  original_language_id DECIMAL(3),
  rental_duration DECIMAL(3),
  rental_rate DECIMAL(4,2),
  length DECIMAL(5),
  replacement_cost DECIMAL(5,2),
  rating VARCHAR(6),
  special_features VARCHAR(100),
  last_update DATETIME
);

CREATE TABLE [week7].[customer] 
(
  customer_id DECIMAL(5),
  store_id DECIMAL(3),
  first_name VARCHAR(45),
  last_name VARCHAR(45),
  email VARCHAR(50),
  address_id DECIMAL(5),
  active CHAR(1),
  create_date DATETIME,
  last_update DATETIME
);

CREATE TABLE [week7].[rental]
(
    RENTAL_ID DECIMAL(10), 
	RENTAL_DATE DATETIME, 
	INVENTORY_ID DECIMAL(7), 
	CUSTOMER_ID DECIMAL(5), 
	RETURN_DATE DATETIME, 
	STAFF_ID DECIMAL(5), 
	LAST_UPDATE DATETIME
);


CREATE TABLE [week7].[DIRECTOR]
(
    DIRNUMB INTEGER NOT NULL ,
    DIRNAME CHAR(20),
    DIRBORN SMALLINT,
    DIRDIED SMALLINT,
    PRIMARY KEY    (DIRNUMB)
);


CREATE TABLE [week7].[STAR]
(
    STARNUMB INTEGER NOT NULL ,
    STARNAME CHAR(20),
    BRTHPLCE CHAR(20),
    STARBORN SMALLINT,
    STARDIED SMALLINT,
    PRIMARY KEY    (STARNUMB)
);


CREATE TABLE [week7].[MOVIE]
(
    MVNUMB INTEGER NOT NULL ,
    MVTITLE CHAR(30),
    YRMDE SMALLINT,
    MVTYPE CHAR(6),
    CRIT SMALLINT,
    MPAA CHAR(2),
    NOMS SMALLINT,
    AWRD SMALLINT,
    DIRNUMB INTEGER,
    PRIMARY KEY (MVNUMB),
    FOREIGN KEY (DIRNUMB) REFERENCES [week7].[DIRECTOR](DIRNUMB)
);


CREATE TABLE [week7].[MOVSTAR]
(
    MVNUMB INTEGER NOT NULL ,
    STARNUMB INTEGER NOT NULL ,
    PRIMARY KEY (MVNUMB, STARNUMB),
    FOREIGN KEY (MVNUMB) REFERENCES [week7].MOVIE(MVNUMB),
    FOREIGN KEY (STARNUMB) REFERENCES [week7].STAR(STARNUMB)
);


CREATE TABLE [week7].[MEMBER]
(
    MMBNUMB INTEGER NOT NULL ,
    MMBNAME CHAR(20),
    MMBADDR CHAR(20),
    MMBCTY CHAR(10),
    MMBST CHAR(2),
    NUMRENT SMALLINT,
    BONUS SMALLINT,
    JOINDATE DATE,
    PRIMARY KEY (MMBNUMB)
);

CREATE TABLE [week7].[BORROW]
(
    TXNUMB INTEGER NOT NULL ,
    MVNUMB INTEGER,
    BORDTE DATE,
    MMBNUMB INTEGER,
    PRIMARY KEY (TXNUMB),
    FOREIGN KEY (MVNUMB) REFERENCES [week7].MOVIE(MVNUMB),
    FOREIGN KEY (MMBNUMB) REFERENCES [week7].MEMBER(MMBNUMB)
);


CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY table_name, row_count DESC
DROP TABLE #counts

