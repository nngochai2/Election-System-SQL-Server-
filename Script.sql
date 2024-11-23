USE s3978281
GO

---------------------------------------------------------------------------- DDL for table creations --------------------------------------------------------------------
CREATE TABLE [dbo].[ElectionMaster]
(
    [election_serial_no]            BIGINT PRIMARY KEY,
    [election_date]                 DATE NOT NULL,
    [election_type]                 VARCHAR(100),
    [total_divisions]               INT,
    [total_registered_voters]       INT,
    [voter_register_deadline]       DATE NOT NULL,
    [candidate_nominate_deadline]   DATE NOT NULL,
    [declare_result_deadline]       DATE NOT NULL,
);

-- Insert data for 2019 and 2022 elections
INSERT INTO [dbo].[ElectionMaster] 
(election_serial_no, election_date, election_type, total_divisions, total_registered_voters, voter_register_deadline, candidate_nominate_deadline, declare_result_deadline)
VALUES 
(20190518, '2019-05-18', 'General Election', 151, 16424248, '2019-04-18', '2019-04-23', '2019-06-15'),
(20220521, '2022-05-21', 'General Election', 151, 17228900, '2022-04-18', '2022-04-21', '2022-06-28');

CREATE TABLE [dbo].[ElectoralDivision]
(
    [electoral_division_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [division_name] VARCHAR(100) NOT NULL,
    [current_mp_name] VARCHAR(100),
    [current_mp_party] VARCHAR(100),
    [total_registered_voters] INT,
);

CREATE TABLE [dbo].[VoterRegistry]
(
    [voter_id]              INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [first_name]            VARCHAR(50) NOT NULL,
    [middle_name]           VARCHAR(50),
    [last_name]             VARCHAR(50) NOT NULL,
    [date_of_birth]         DATE NOT NULL,
    [residential_address]   VARCHAR(255) NOT NULL,
    [postal_address]        VARCHAR(255),
    [contact_phone]         VARCHAR(15),
    [email_address]         VARCHAR(100),
    [electoral_division_id] INT NOT NULL,
    FOREIGN KEY (electoral_division_id) REFERENCES [dbo].[ElectoralDivision](electoral_division_id),
);

CREATE TABLE [dbo].[IssuanceRecord]
(
  [issuance_id]          INT PRIMARY KEY IDENTITY(1,1),
  [voter_id]             INT NOT NULL,
  [election_event_id]    BIGINT NOT NULL,
  [issuance_timestamp]   DATETIME NOT NULL,
  [polling_station_name] VARCHAR(100),
  FOREIGN KEY (voter_id) REFERENCES [dbo].[VoterRegistry](voter_id),
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id)
);

CREATE TABLE [dbo].[ElectionEvent]
(
  [election_event_id]       BIGINT NOT NULL PRIMARY KEY,
  [election_serial_no]      BIGINT NOT NULL,
  [electoral_division_id]   INT,
  [number_of_candidates]    INT,
  [number_of_votes_cast]    INT,
  [number_of_valid_votes]   INT,
  [current_status]          VARCHAR(50),
  [swing_percentage]        DECIMAL(5,2),
  FOREIGN KEY (election_serial_no) REFERENCES [dbo].[ElectionMaster](election_serial_no),
  FOREIGN KEY (electoral_division_id) REFERENCES [dbo].[ElectoralDivision](electoral_division_id)
);

INSERT INTO ElectionEvent (election_event_id, election_serial_no, electoral_division_id)
VALUES (20220521001, 20220521, 1);  -- Assuming electoral_division_id 1 for this example

-- Personal version
CREATE TABLE [dbo].[Ballot]
(
  [ballot_id]           INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [election_event_id]   BIGINT NOT NULL,
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id)
);

-- Demonstration version (populated by import wizard)
CREATE TABLE [dbo].[Ballot] (
    [BallotID]       INT           NOT NULL PRIMARY KEY,
    [Candidate13321] VARCHAR (MAX) NULL,
    [Candidate17846] VARCHAR (MAX) NULL,
    [Candidate17258] VARCHAR (MAX) NULL,
    [Candidate20645] VARCHAR (MAX) NULL,
    [Candidate10268] VARCHAR (MAX) NULL,
    [Candidate20553] VARCHAR (MAX) NULL,
    [election_event_id] BIGINT,
    FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id)
);

select * from Ballot

-- Clean up the data
-- Identify rows with non-numeric data
SELECT * FROM [dbo].[Ballot]
    WHERE ISNUMERIC(ballot_id) = 0
        OR ISNUMERIC()

CREATE TABLE [dbo].[BallotPreferences]
(
  [ballot_id] INT NOT NULL,
  [candidate_id] INT NOT NULL,
  [preference_order] INT,
  PRIMARY KEY (ballot_id, candidate_id),
  FOREIGN KEY (ballot_id) REFERENCES [dbo].[Ballot](ballot_id),
  FOREIGN KEY (candidate_id) REFERENCES [dbo].[Candidate](candidate_id)
);

CREATE TABLE [dbo].[Candidate]
(
  [candidate_id]            INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [candidate_name]          VARCHAR(100) NOT NULL,
  [contact_name]            VARCHAR(100),
  [contact_phone]           VARCHAR(15),
  [contact_email]           VARCHAR(100),
  [political_party_code]    VARCHAR(10),
  [election_event_id]       BIGINT NOT NULL,
  FOREIGN KEY (political_party_code) REFERENCES [dbo].[PoliticalParty](party_code),
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id),
);

CREATE TABLE [dbo].[PoliticalParty] 
(
  [party_code]              VARCHAR(10) PRIMARY KEY,
  [party_name]              VARCHAR(100) NOT NULL,
  [party_logo]              VARCHAR(255), -- Link to the image of the logo
  [party_postal_address]    VARCHAR(255),
  [party_secretary]         VARCHAR(100),
  [contact_person_name]     VARCHAR(100),
  [contact_person_phone]    VARCHAR(15),
  [contact_person_email]    VARCHAR(100),
);

CREATE TABLE [dbo].[PrefCountRecord]
(
  [round_number]            INT NOT NULL, -- Partial key
  [election_event_id]       BIGINT NOT NULL,
  [count_status]            VARCHAR(50),
  [preference_aggregate]    INT,
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id),
  PRIMARY KEY (election_event_id, round_number) -- Composite primary key
);

CREATE TABLE [dbo].[PreferenceTallyPerRoundPerCandidate]
(
  [candidate_id]        INT NOT NULL,
  [tally]               INT NOT NULL,
  [election_event_id]   BIGINT NOT NULL,
  [round_number]        INT NOT NULL,
  PRIMARY KEY (election_event_id, round_number, candidate_id), -- Composite key
  FOREIGN KEY (election_event_id, round_number) REFERENCES [dbo].[PrefCountRecord](election_event_id, round_number),
  FOREIGN KEY (candidate_id) REFERENCES [dbo].[Candidate](candidate_id)
)

-- drop constraints
DECLARE @DropConstraints NVARCHAR(max) = ''
SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys
EXECUTE sp_executesql @DropConstraints;
GO

-- drop tables
DECLARE @DropTables NVARCHAR(max) = ''
SELECT @DropTables += 'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES
EXECUTE sp_executesql @DropTables;
GO


-------------------------------------------------------------------------- TASK 2.1 ------------------------------------------------------------------------------------
SELECT 
    ed.division_name AS [Division], 
    COUNT(vr.voter_id) AS [Total Voters]
FROM [dbo].[ElectoralDivision] ed
JOIN [dbo].[VoterRegistry] vr ON ed.electoral_division_id = vr.electoral_division_id
GROUP BY ed.division_name
ORDER BY [Total Voters] DESC;

-- Index creation
CREATE NONCLUSTERED INDEX idx_voter_registry_division ON [dbo].[VoterRegistry](electoral_division_id);
CREATE NONCLUSTERED INDEX idx_electoral_division ON [dbo].[ElectoralDivision](electoral_division_id);

CREATE NONCLUSTERED INDEX IX_VoterRegistry_ElectoralDivision_Covering
ON [dbo].[VoterRegistry] (electoral_division_id)
INCLUDE (voter_id);

-- Drop index commands to compare the estimated plans
DROP INDEX [dbo].[VoterRegistry].idx_voter_registry_division
DROP INDEX [dbo].[VoterRegistry].IX_VoterRegistry_ElectoralDivision_Covering

-- Alternate query (1st attemp - worse performance)
SELECT ed.division_name AS [Division],
    (
        -- Using subquery
        SELECT COUNT(*)
        FROM [dbo].[VoterRegistry] vr 
        WHERE vr.electoral_division_id = ed.electoral_division_id
    ) AS [Total Voters]
FROM [dbo].[ElectoralDivision] ed
ORDER BY [Total Voters] DESC;

-- Alternate query (2nd attempt - similar performance)
-- Using a CTE to aggregate the voters first
WITH VoterCounts AS (
    SELECT 
        electoral_division_id, 
        COUNT(voter_id) AS [Total_Voters]
    FROM 
        [dbo].[VoterRegistry]
    GROUP BY 
        electoral_division_id
)
SELECT 
    ed.division_name AS [Division],
    vc.Total_Voters
FROM [dbo].[ElectoralDivision] ed
    LEFT JOIN VoterCounts vc ON ed.electoral_division_id = vc.electoral_division_id
ORDER BY vc.Total_Voters DESC;

-------------------------------------------------------------------------- TASK 2.2 ------------------------------------------------------------------------------------
SELECT 
    ed.division_name AS [Electorate], 
    c.candidate_name AS [Candidate Name], 
    pp.party_name AS [Political Party]
FROM [dbo].[Candidate] c
    JOIN [dbo].[ElectionEvent] ee ON c.election_event_id = ee.election_event_id
    JOIN [dbo].[ElectoralDivision] ed ON ee.electoral_division_id = ed.electoral_division_id
    JOIN [dbo].[PoliticalParty] pp ON c.political_party_code = pp.party_code
WHERE ee.election_serial_no = 20220521
ORDER BY ed.division_name, NEWID();

-- Index on ElectionEvent.election_serial_no for filtering
CREATE NONCLUSTERED INDEX IX_ElectionEvent_SerialNo ON [dbo].[ElectionEvent](election_serial_no);

-- Index on Candidate.election_event_id for joining
CREATE NONCLUSTERED INDEX IX_Candidate_ElectionEventID ON [dbo].[Candidate](election_event_id);

-- Index on ElectoralDivision.electoral_division_id for joining
CREATE NONCLUSTERED INDEX IX_ElectoralDivision_DivisionID ON [dbo].[ElectoralDivision](electoral_division_id);

-- Index on PoliticalParty.party_code for joining
CREATE NONCLUSTERED INDEX IX_PoliticalParty_Code ON [dbo].[PoliticalParty](party_code);

-------------------------------------------------------------------------- TASK 2.3 -------------------------------------------------------------------------------------
SELECT vr.first_name, vr.last_name, vr.residential_address
FROM [dbo].[VoterRegistry] vr
WHERE vr.voter_id NOT IN (
    SELECT DISTINCT ir.voter_id
    FROM [dbo].[IssuanceRecord] ir
    JOIN [dbo].[ElectionEvent] ee ON ir.election_event_id = ee.election_event_id
    WHERE ee.election_event_id IN ('20220521', '20190518')
);

-- Index on VoterRegistry.voter_id to avoid the Clustered Index Scan
CREATE NONCLUSTERED INDEX IX_VoterRegistry_VoterID ON [dbo].[VoterRegistry](voter_id);

-- Index on IssuanceRecord.voter_id to avoid the Index Scan in the subquery
CREATE NONCLUSTERED INDEX IX_IssuanceRecord_VoterID ON [dbo].[IssuanceRecord](voter_id);

-- Index on ElectionEvent.election_event_id for efficient filtering in the subquery
CREATE NONCLUSTERED INDEX IX_ElectionEvent_EventID ON [dbo].[ElectionEvent](election_event_id);

DROP INDEX [dbo].[VoterRegistry].IX_VoterRegistry_VoterID
DROP INDEX [dbo].[IssuanceRecord].IX_IssuanceRecord_VoterID
DROP INDEX [dbo].[ElectionEvent].IX_ElectionEvent_EventID

-- Alternative query using LEFT JOIN
SELECT vr.first_name, vr.last_name, vr.residential_address
FROM [dbo].[VoterRegistry] vr
LEFT JOIN (
    SELECT DISTINCT ir.voter_id
    FROM [dbo].[IssuanceRecord] ir 
    JOIN [dbo].[ElectionEvent] ee ON ir.election_event_id = ee.election_event_id
    WHERE ee.election_event_id IN ('20220521', '20190518')
    GROUP BY ir.voter_id 
    HAVING COUNT(DISTINCT ee.election_event_id) = 2
) AS voted_voters ON vr.voter_id = voted_voters.voter_id
WHERE voted_voters.voter_id IS NULL;

-- Alternative query using NOT EXISTS (same performance)
SELECT vr.first_name, vr.last_name, vr.residential_address
FROM [dbo].[VoterRegistry] vr
WHERE NOT EXISTS (
    SELECT 1
    FROM [dbo].[IssuanceRecord] ir
    JOIN [dbo].[ElectionEvent] ee ON ir.election_event_id = ee.election_event_id
    WHERE ir.voter_id = vr.voter_id
    AND ee.election_event_id IN ('20220521', '20190518')
);

--------------------------------------------------------------------------- TASK 3 ------------------------------------------------------------------------------------

-- HASH PARTITIONING ON 'VoterRegistry' TABLE (In PostgreSQL)
CREATE TABLE VoterRegistry 
(
    voter_id            INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    first_name          VARCHAR(50) NOT NULL,
    middle_name         VARCHAR(50),
    last_name           VARCHAR(50) NOT NULL,
    date_of_birth       DATE NOT NULL,
    residential_address VARCHAR(255) NOT NULL,
    postal_address      VARCHAR(255),
    contact_phone       VARCHAR(15),
    email_address       VARCHAR(100),
    electoral_division_id INT NOT NULL,
    FOREIGN KEY (electoral_division_id) REFERENCES ElectoralDivision(electoral_division_id)
) PARTITION BY HASH (electoral_division_id);

-- Create partitions
CREATE TABLE VoterRegistry_p1 PARTITION OF VoterRegistry
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE VoterRegistry_p2 PARTITION OF VoterRegistry
FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE VoterRegistry_p3 PARTITION OF VoterRegistry
FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE VoterRegistry_p4 PARTITION OF VoterRegistry
FOR VALUES WITH (MODULUS 4, REMAINDER 3);


-- RANGE PARTITIONING ON 'IssuanceRecord' TABLE

-- Create partition function
CREATE PARTITION FUNCTION pf_IssuanceRecord (BIGINT)
AS RANGE LEFT FOR VALUES (20250101, 20280101, 20310101, 20340101); -- Assumming these are the values for election_event_id

-- Create partition scheme
CREATE PARTITION SCHEME ps_IssuanceRecord
AS PARTITION pf_IssuanceRecord TO (part1, part2, part3, part4);

-- Create 'Ballot' table with partition scheme
CREATE TABLE [dbo].[IssuanceRecord]
(
  [issuance_id]          INT PRIMARY KEY IDENTITY(1,1),
  [voter_id]             INT NOT NULL,
  [election_event_id]    BIGINT NOT NULL,
  [issuance_timestamp]   DATETIME NOT NULL,
  [polling_station_name] VARCHAR(100),
  FOREIGN KEY (voter_id) REFERENCES [dbo].[VoterRegistry](voter_id),
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id)
) ON ps_IssuanceRecord(election_event_id);


-- HASH PARTITIONING ON 'BallotPreferences' TABLE (In PostgreSQL)
CREATE TABLE BallotPreferences
(
    ballot_id        INT NOT NULL,
    candidate_id     INT NOT NULL,
    preference_order INT,
    PRIMARY KEY (ballot_id, candidate_id),
    FOREIGN KEY (ballot_id) REFERENCES Ballot(ballot_id),
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id)
) PARTITION BY HASH (ballot_id);

-- Create partitions
CREATE TABLE BallotPreferences_p1 PARTITION OF BallotPreferences
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE BallotPreferences_p2 PARTITION OF BallotPreferences
FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE BallotPreferences_p3 PARTITION OF BallotPreferences
FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE BallotPreferences_p4 PARTITION OF BallotPreferences
FOR VALUES WITH (MODULUS 4, REMAINDER 3);

--------------------------------------------------------------------------- TASK 4 ------------------------------------------------------------------------------------

GO
CREATE OR ALTER FUNCTION [dbo].[previouslyVoted]
(
    @voter_id                   INT,
    @election_code              BIGINT,
    @electoral_division_name    VARCHAR(100)
)
RETURNS BIT
AS 
BEGIN
    DECLARE @hasVoted BIT; -- Represents True (1) and False (0)

    SELECT @hasVoted = CASE WHEN EXISTS (
        SELECT 1
        FROM [dbo].[IssuanceRecord] ir
        JOIN [dbo].[ElectionEvent] ee ON ir.election_event_id = ee.election_event_id
        JOIN [dbo].[ElectoralDivision] ed ON ee.electoral_division_id = ed.electoral_division_id
        WHERE ir.voter_id = @voter_id
            AND ee.election_serial_no = @election_code
            AND ed.division_name = @electoral_division_name
    ) THEN 1 -- True (the voter has already voted)
    ELSE 0 -- False (the voter has not voted)
    END

    RETURN @hasVoted
END;
GO -- 'GO' statements were used on top and at the bottom to ensure the that the CREATE function is the only one in the bash

GO
CREATE OR ALTER PROCEDURE [dbo].[TestPreviouslyVoted]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE 
        @voter_id_1 BIGINT, 
        @voter_id_2 BIGINT, 
        @election_event_id BIGINT, 
        @electoral_division_id BIGINT;
    DECLARE @result BIT;

    BEGIN
        PRINT 'Starting TestPreviouslyVoted procedure...';

        -- Find an existing electoral division
        SELECT TOP 1 @electoral_division_id = electoral_division_id 
        FROM [dbo].[ElectoralDivision];
        PRINT 'Selected electoral_division_id: ' + CAST(@electoral_division_id AS VARCHAR(20));

        -- Find an existing election event
        SELECT TOP 1 @election_event_id = election_event_id 
        FROM [dbo].[ElectionEvent];
        PRINT 'Selected election_event_id: ' + CAST(@election_event_id AS VARCHAR(20));

        -- Find or create two voters
        SELECT TOP 1 @voter_id_1 = voter_id 
        FROM [dbo].[VoterRegistry]
        WHERE electoral_division_id = @electoral_division_id;

        -- If the specified votoer does not exist, create a new one
        IF @voter_id_1 IS NULL
            BEGIN
                INSERT INTO [dbo].[VoterRegistry] (first_name, last_name, date_of_birth, residential_address, electoral_division_id)
                -- Placeholder data
                VALUES ('John', 'Doe', '1980-01-01', '123 Main St, Anytown', @electoral_division_id);
                -- Returns the last identiy value inserted into an id column
                SET @voter_id_1 = SCOPE_IDENTITY();
                PRINT 'Created new voter with id: ' + CAST(@voter_id_1 AS VARCHAR(20));
            END
        ELSE
            BEGIN
                PRINT 'Found existing voter with id: ' + CAST(@voter_id_1 AS VARCHAR(20));
            END

        -- Find/Create 2nd voter
        SELECT TOP 1 @voter_id_2 = voter_id 
        FROM [dbo].[VoterRegistry]
        WHERE electoral_division_id = @electoral_division_id AND voter_id != @voter_id_1;

        IF @voter_id_2 IS NULL
            BEGIN
                INSERT INTO [dbo].[VoterRegistry] (first_name, last_name, date_of_birth, residential_address, electoral_division_id)
                -- Placeholder data
                VALUES ('Jane', 'Smith', '1985-05-05', '456 Elm St, Anytown', @electoral_division_id);
                SET @voter_id_2 = SCOPE_IDENTITY();
                PRINT 'Created new voter with id: ' + CAST(@voter_id_2 AS VARCHAR(20));
            END
        ELSE
            BEGIN
                PRINT 'Found existing voter with id: ' + CAST(@voter_id_2 AS VARCHAR(20));
            END

        -- Ensure voter 1 has voted
        IF NOT EXISTS (
            SELECT 1 
            FROM [dbo].[IssuanceRecord] 
            WHERE [voter_id] = @voter_id_1
            AND [election_event_id] = @election_event_id
        )
            BEGIN
                INSERT INTO [dbo].[IssuanceRecord] (voter_id, election_event_id, issuance_timestamp)
                VALUES (@voter_id_1, @election_event_id, GETDATE());
                PRINT 'Created issuance record for voter: ' + CAST(@voter_id_1 AS VARCHAR(20));
            END
        ELSE
            BEGIN
                PRINT 'Issuance record already exists for voter: ' + CAST(@voter_id_1 AS VARCHAR(20));
            END

        -- Get the election serial number
        DECLARE @election_serial_no BIGINT;
        SELECT @election_serial_no = election_serial_no 
        FROM [dbo].[ElectionEvent] 
        WHERE election_event_id = @election_event_id;
        PRINT 'Selected election_serial_no: ' + CAST(@election_serial_no AS VARCHAR(20));

        -- Get the electoral division name
        DECLARE @electoral_division_name VARCHAR(100);
        SELECT @electoral_division_name = division_name 
        FROM [dbo].[ElectoralDivision] 
        WHERE electoral_division_id = @electoral_division_id;
        PRINT 'Selected electoral_division_name: ' + @electoral_division_name;

        -- Test with a voter who has voted
        PRINT 'Testing previouslyVoted for voter who should have voted...';
        EXEC @result = dbo.previouslyVoted @voter_id_1, @election_serial_no, @electoral_division_name;
        PRINT 'Voter ' + CAST(@voter_id_1 AS VARCHAR(20)) + ' (should have voted): ' + CASE WHEN @result = 1 THEN 'Has voted' ELSE 'Has not voted' END;
        
        -- Test with a voter who has not voted
        PRINT 'Testing previouslyVoted for voter who should not have voted...';
        EXEC @result = dbo.previouslyVoted @voter_id_2, @election_serial_no, @electoral_division_name;
        PRINT 'Voter ' + CAST(@voter_id_2 AS VARCHAR(20)) + ' (should not have voted): ' + CASE WHEN @result = 1 THEN 'Has voted' ELSE 'Has not voted' END;

        PRINT 'TestPreviouslyVoted procedure completed successfully.';
    END
END
GO

-- Execute the test driver
PRINT 'Executing TestPreviouslyVoted procedure...';
EXEC [dbo].[TestPreviouslyVoted];
PRINT 'Execution of TestPreviouslyVoted procedure completed.';

--------------------------------------------------------------------------- TASK 5 ------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [dbo].[primaryVoteCount] (
    @election_serial_no         AS BIGINT,
    @electoral_division_name    AS VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON; -- The count won't be returned

    DECLARE @election_event_id BIGINT;

    -- Get the election_event_id based on the election serial number
    SELECT @election_event_id = [election_event_id]
    FROM [dbo].[ElectionEvent]
    WHERE [election_serial_no] = @election_serial_no
    AND [electoral_division_id] = (
        SELECT [electoral_division_id]
        FROM [dbo].[ElectoralDivision]
        WHERE [division_name] = @electoral_division_name
    );

    -- Check for potential error during the variable input
    IF @election_event_id IS NULL 
        BEGIN
            RAISERROR('Invalid election_serial_no or electoral_division_name', 16, 1);
            RETURN;
        END
    
    -- Insert a new record into PrefCountRecord for this round
    INSERT INTO [dbo].[PrefCountRecord] (election_event_id, round_number, count_status, preference_aggregate)
    VALUES (@election_event_id, 1, 'In Progress', 0) -- First round of the election event

    -- Create a temp table for vote counting
    CREATE TABLE #tempResults
    (
        candidate_id INT,
        first_preference_votes INT
    )

    -- Extract the first preference votes for the given election event and division
    INSERT INTO #tempResults (candidate_id, first_preference_votes)
    SELECT bp.candidate_id, COUNT(bp.candidate_id) AS vote_count
    FROM [dbo].[BallotPreferences] bp
        INNER JOIN [dbo].[Ballot] b ON bp.ballot_id = b.ballot_id
        INNER JOIN [dbo].[ElectionEvent] ee ON b.election_event_id = ee.election_event_id
        INNER JOIN [dbo].[IssuanceRecord] ir ON ir.election_event_id = ee.election_event_id
        INNER JOIN [dbo].[VoterRegistry] vr ON vr.voter_id = ir.voter_id
        INNER JOIN [dbo].[ElectoralDivision] ed ON vr.electoral_division_id = ed.electoral_division_id
    WHERE ee.election_event_id = ed.electoral_division_id
    AND ed.division_name = @electoral_division_name
    AND bp.preference_order = 1 -- Counting the first preferences
    GROUP BY bp.candidate_id;

    -- Insert the tally of first preference votes into PreferenceTallyPerRoundPerCandidate table
    INSERT INTO [dbo].[PreferenceTallyPerRoundPerCandidate] (election_event_id, round_number, candidate_id, tally)
    SELECT @election_event_id, 1, candidate_id, first_preference_votes -- 1 represents the first round
    FROM #tempResults

    -- Update the PrefCountRecord table with the aggregat of preferences
    UPDATE [dbo].[PrefCountRecord]
    SET [preference_aggregate] = (
        SELECT SUM(first_preference_votes)
        FROM #tempResults
    ),
    [count_status] = 'Completed'
    WHERE [election_event_id] = @election_event_id 
        AND [round_number] = 1;
    
    -- Return the updated results
    SELECT c.candidate_name, t.tally AS first_preference_votes
    FROM [dbo].[PreferenceTallyPerRoundPerCandidate] t 
        JOIN [dbo].[Candidate] c ON t.candidate_id = c.candidate_id
    WHERE t.[election_event_id] = @election_event_id
        AND t.[round_number] = 1
    ORDER BY t.tally DESC;

    -- Clean up
    DROP TABLE #tempResults
END
GO

----------------------------------------------------------------------------- BONUS TASK ------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE [dbo].[distributePreferences] 
(
    @election_serial_no         AS BIGINT,
    @electoral_division_name    AS VARCHAR(100)
)
AS
BEGIN 
    SET NOCOUNT ON;
    DECLARE
        @election_event_id INT,
        @round_number INT = 1,
        @total_votes INT,
        @winner_threshold INT,
        @eliminated_candidate_id INT,
        @winner_candidate_id INT = NULL;

    -- Get the election_event_id based on the election_serial_no and electoral_division_name
    SELECT @election_event_id = ee.election_event_id
    FROM [dbo].[ElectionEvent] ee 
    JOIN [dbo].[ElectoralDivision] ed ON ee.electoral_division_id = ed.electoral_division_id
    WHERE ee.election_serial_no = @election_serial_no
    AND ed.division_name = @electoral_division_name;

    IF @election_event_id IS NULL
        BEGIN 
            RAISERROR('Invalid election_serial_no or electoral_division_name', 16, 1);
            RETURN;
        END

    -- Calculate total valid votes
    SELECT @total_votes = SUM(tally)
    FROM [dbo].[PreferenceTallyPerRoundPerCandidate]
    WHERE election_event_id = @election_event_id AND round_number = 1;

    -- Set the threhold to determine the winner (more than 50% of total valid votes)
    SET @winner_threshold = @total_votes / 2 + 1;

    -- Begin the loop to process rounds until a winner is determined
    WHILE @winner_candidate_id IS NULL
    BEGIN 
        -- Find the candidate with the lowest votes 
        SELECT TOP 1 @eliminated_candidate_id = candidate_id
        FROM [dbo].[PreferenceTallyPerRoundPerCandidate]
        WHERE election_event_id = @election_event_id AND round_number = @round_number
        AND tally > 0
        ORDER BY tally ASC;
    
    -- Redistribute votes from the eliminated candidate
    UPDATE prc
    SET tally = prc.tally + ISNULL(votes_to_redistribute.redistributed_votes, 0)
    FROM [dbo].[PreferenceTallyPerRoundPerCandidate] prc
    LEFT JOIN (
        -- Calculate the number of votes to redistribute to the next preference
        SELECT
            next_preference.candidate_id,
            COUNT(*) AS redistributed_votes
        FROM [dbo].[BallotPreferences] eliminated
        CROSS APPLY (
            -- Find the next available preference for the ballots
            SELECT TOP 1 bp.candidate_id
            FROM [dbo].[BallotPreferences] bp
            WHERE bp.ballot_id = eliminated.ballot_id
            AND bp.preference_order > eliminated.preference_order
            -- Ensure the candidate has not been eliminated already
            AND bp.candidate_id NOT IN (
                SELECT candidate_id
                FROM [dbo].[PreferenceTallyPerRoundPerCandidate]
                WHERE election_event_id = @election_event_id
                AND round_number = @round_number
                AND tally = 0
            )
            ORDER BY bp.preference_order
        ) next_preference
        WHERE eliminated.candidate_id = @eliminated_candidate_id
        GROUP BY next_preference.candidate_id
    ) votes_to_redistribute ON prc.candidate_id = votes_to_redistribute.candidate_id
    WHERE prc.election_event_id = @election_event_id
    AND prc.round_number = @round_number
    AND prc.candidate_id != @eliminated_candidate_id

    -- Set eliminated candidate's tally to 0
    UPDATE [dbo].[PreferenceTallyPerRoundPerCandidate]
    SET tally = 0
    WHERE election_event_id = @election_event_id
    AND round_number = @round_number
    AND candidate_id = @eliminated_candidate_id

    -- Check for the winner 
    SELECT @winner_candidate_id = candidate_id 
    FROM [dbo].[PreferenceTallyPerRoundPerCandidate]
    WHERE election_event_id = @election_event_id
    AND round_number = @round_number
    AND tally >= @winner_threshold

    -- If there is no winner for this round, start a new round
    IF @winner_candidate_id IS NULL
    BEGIN 
        -- Increment the round number for the next round
        SET @round_number = @round_number + 1

        -- Copy the results to next round
        INSERT INTO [dbo].[PreferenceTallyPerRoundPerCandidate] (election_event_id, round_number, candidate_id, tally)
        SELECT election_event_id, @round_number, candidate_id, tally
        FROM [dbo].[PreferenceTallyPerRoundPerCandidate]
        WHERE election_event_id = @election_event_id AND round_number = @round_number - 1;

        -- Insert new PrefCountRecord for the new row
        INSERT INTO [dbo].[PrefCountRecord] (election_event_id, round_number, count_status, preference_aggregate)
        VALUES (@election_event_id, @round_number, 'In Progress', @total_votes)
    END
    ELSE   
        -- If a winner is found, update the PrefCountRound table to mark the round as completed
        BEGIN
            UPDATE [dbo].[PrefCountRecord]
            SET count_status = 'Completed'
            WHERE [election_event_id] = @election_event_id
            AND [round_number] = @round_number
        END
    END

    -- Return the final results of the election, listing the candidates and their status
    SELECT c.candidate_name, t.tally,
        CASE WHEN c.candidate_id = @winner_candidate_id 
            THEN 'Winner' ELSE 'Eliminated' END AS status
    FROM [dbo].[PreferenceTallyPerRoundPerCandidate] t 
    JOIN [dbo].[Candidate] c ON t.candidate_id = c.candidate_id
    WHERE t.election_event_id = @election_event_id 
    AND t.round_number = @round_number
    ORDER BY t.tally DESC;
END;
GO

-- Preparatory queries to find valid input parameters
DECLARE @test_election_serial_no BIGINT;
DECLARE @test_electoral_division_name VARCHAR(100);

-- Get the most recent election_serial_no
SELECT TOP 1 @test_election_serial_no = election_serial_no
FROM ElectionMaster
ORDER BY election_date DESC;

-- Get a random electoral division name
SELECT TOP 1 @test_electoral_division_name = division_name
FROM ElectoralDivision
ORDER BY NEWID();

-- Print the test parameters
PRINT 'Test Parameters:';
PRINT 'election_serial_no: ' + CAST(@test_election_serial_no AS VARCHAR(20));
PRINT 'electoral_division_name: ' + @test_electoral_division_name;

-- Test Task 5: primaryVoteCount procedure
PRINT 'Testing primaryVoteCount procedure:';
BEGIN TRY
    EXEC primaryVoteCount 
        @election_serial_no = @test_election_serial_no, 
        @electoral_division_name = @test_electoral_division_name;
    PRINT 'primaryVoteCount executed successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error in primaryVoteCount:';
    PRINT ERROR_MESSAGE();
END CATCH

-- Test Bonus Task: distributePreferences procedure
PRINT 'Testing distributePreferences procedure:';
BEGIN TRY
    EXEC distributePreferences
        @election_serial_no = @test_election_serial_no, 
        @electoral_division_name = @test_electoral_division_name;
    PRINT 'distributePreferences executed successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error in distributePreferences:';
    PRINT ERROR_MESSAGE();
    
    -- Additional error information
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'Not within procedure');
    
    -- Check if the election event exists
    IF NOT EXISTS (SELECT 1 FROM ElectionEvent WHERE election_serial_no = @test_election_serial_no)
        PRINT 'The specified election_serial_no does not exist in ElectionEvent table.';
    
    -- Check if the electoral division exists
    IF NOT EXISTS (SELECT 1 FROM ElectoralDivision WHERE division_name = @test_electoral_division_name)
        PRINT 'The specified electoral_division_name does not exist in ElectoralDivision table.';
    
    -- Print the first few rows of relevant tables for debugging
    PRINT 'First 5 rows of ElectionEvent:';
    SELECT TOP 5 * FROM ElectionEvent;
    
    PRINT 'First 5 rows of ElectoralDivision:';
    SELECT TOP 5 * FROM ElectoralDivision;
END CATCH

