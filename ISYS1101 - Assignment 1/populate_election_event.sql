INSERT INTO [dbo].[ElectionEvent] (election_event_id, election_serial_no, electoral_division_id, number_of_candidates, number_of_votes_cast, number_of_valid_votes, current_status, swing_percentage)
SELECT 
    (em.election_serial_no * 1000) + ROW_NUMBER() OVER (PARTITION BY em.election_serial_no ORDER BY ed.electoral_division_id) as election_event_id,
    em.election_serial_no,
    ed.electoral_division_id,
    ABS(CHECKSUM(NEWID()) % 6) + 5, -- Random number of candidates between 5 and 10
    ABS(CHECKSUM(NEWID()) % 50000) + 80000, -- Random number of votes cast between 80,000 and 130,000
    0, -- We'll update this later
    'Not counted yet',
    (ABS(CHECKSUM(NEWID()) % 1000) / 100.0) - 5 -- Random swing between -5% and +5%
FROM ElectoralDivision ed
CROSS JOIN ElectionMaster em;

-- Update the number_of_valid_votes to be slightly less than number_of_votes_cast
UPDATE ElectionEvent
SET number_of_valid_votes = number_of_votes_cast - (ABS(CHECKSUM(NEWID()) % 500) + 100); -- Subtract a random number between 100 and 600

-- Populate one event
INSERT INTO [dbo].[ElectionEvent](election_event_id, election_serial_no, electoral_division_id, number_of_candidates, number_of_votes_cast, number_of_valid_votes, current_status, swing_percentage)
VALUES 
