GO
CREATE PROCEDURE [dbo].[primaryVoteCount] (
    @election_serial_no         AS BIGINT,
    @electoral_division_name    AS VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

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
    INSERT INTO [dbo].[PrefCountRecord] (election_event_id, count_status, preference_aggregate)
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