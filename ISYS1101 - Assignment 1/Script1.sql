DECLARE @ElectionSerialNo BIGINT = 20220521;
DECLARE @VotesPerDivision INT = 1000; -- Adjust this number as needed

-- Insert ballots for each electoral division
INSERT INTO [dbo].[Ballot] ([election_event_id])
SELECT TOP (@VotesPerDivision * (SELECT COUNT(DISTINCT electoral_division_id) FROM [dbo].[ElectionEvent] WHERE election_serial_no = @ElectionSerialNo))
    ee.[election_event_id]
FROM 
    [dbo].[ElectionEvent] ee
    CROSS JOIN (SELECT TOP (@VotesPerDivision) n = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM master.dbo.spt_values) nums
WHERE 
    ee.[election_serial_no] = @ElectionSerialNo
ORDER BY 
    NEWID();

-- Now, let's create preferences for each ballot
;WITH CandidateRanking AS (
    SELECT 
        c.[candidate_id],
        c.[election_event_id],
        ROW_NUMBER() OVER (PARTITION BY c.[election_event_id] ORDER BY NEWID()) AS random_rank
    FROM 
        [dbo].[Candidate] c
        JOIN [dbo].[ElectionEvent] ee ON c.[election_event_id] = ee.[election_event_id]
    WHERE 
        ee.[election_serial_no] = @ElectionSerialNo
)
INSERT INTO [dbo].[BallotPreferences] ([ballot_id], [candidate_id], [preference_order])
SELECT 
    b.[ballot_id],
    cr.[candidate_id],
    cr.[random_rank]
FROM 
    [dbo].[Ballot] b
    CROSS APPLY (
        SELECT TOP (SELECT COUNT(*) FROM CandidateRanking WHERE election_event_id = b.election_event_id)
            [candidate_id], [random_rank]
        FROM CandidateRanking
        WHERE election_event_id = b.election_event_id
        ORDER BY NEWID()
    ) cr;

-- Verify the data
SELECT TOP 10 * FROM [dbo].[Ballot];

SELECT TOP 50 * FROM [dbo].[BallotPreferences] ORDER BY ballot_id, preference_order;

-- Count of ballots per division
SELECT 
    ed.[division_name],
    COUNT(b.[ballot_id]) AS ballot_count
FROM 
    [dbo].[Ballot] b
    JOIN [dbo].[ElectionEvent] ee ON b.[election_event_id] = ee.[election_event_id]
    JOIN [dbo].[ElectoralDivision] ed ON ee.[electoral_division_id] = ed.[electoral_division_id]
WHERE 
    ee.[election_serial_no] = @ElectionSerialNo
GROUP BY 
    ed.[division_name]
ORDER BY 
    ed.[division_name];