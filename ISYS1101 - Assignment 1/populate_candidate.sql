-- Clear existing data if any
DELETE FROM Candidate;

-- Select a random division from the 2022 election
DECLARE @RandomElectionEventId BIGINT;
SELECT TOP 1 @RandomElectionEventId = election_event_id
FROM ElectionEvent
WHERE election_serial_no = 20220521
ORDER BY NEWID();

-- Generate 12 candidates for the selected division
INSERT INTO Candidate (candidate_name, contact_name, contact_phone, contact_email, political_party_code, election_event_id)
VALUES 
-- Labor candidates
('Sarah Johnson', 'Sarah Johnson', '0412345678', 'sarah.johnson@alp.org.au', 'ALP', @RandomElectionEventId),
('Michael Wong', 'Michael Wong', '0423456789', 'michael.wong@alp.org.au', 'ALP', @RandomElectionEventId),

-- Liberal candidates
('Emily Thompson', 'Emily Thompson', '0434567890', 'emily.thompson@liberal.org.au', 'LPA', @RandomElectionEventId),
('David Chen', 'David Chen', '0445678901', 'david.chen@liberal.org.au', 'LPA', @RandomElectionEventId),

-- Greens candidate
('Jessica Green', 'Jessica Green', '0456789012', 'jessica.green@greens.org.au', 'GRN', @RandomElectionEventId),

-- Nationals candidate
('Robert Brown', 'Robert Brown', '0467890123', 'robert.brown@nationals.org.au', 'NAT', @RandomElectionEventId),

-- One Nation candidate
('Patricia White', 'Patricia White', '0478901234', 'patricia.white@onenation.com.au', 'ONP', @RandomElectionEventId),

-- United Australia Party candidate
('George Yellow', 'George Yellow', '0489012345', 'george.yellow@uap.org.au', 'UAP', @RandomElectionEventId),

-- Independent candidates
('Amanda Lee', 'Amanda Lee', '0490123456', 'amanda.lee@independent.com', 'IND', @RandomElectionEventId),
('Thomas O''Brien', 'Thomas O''Brien', '0401234567', 'thomas.obrien@independent.com', 'IND', @RandomElectionEventId),
('Sophia Nguyen', 'Sophia Nguyen', '0412345678', 'sophia.nguyen@independent.com', 'IND', @RandomElectionEventId),
('James Smith', 'James Smith', '0423456789', 'james.smith@independent.com', 'IND', @RandomElectionEventId);

-- Verify the data
SELECT * FROM PoliticalParty;

SELECT c.*, ed.division_name, pp.party_name
FROM Candidate c
JOIN ElectionEvent ee ON c.election_event_id = ee.election_event_id
JOIN ElectoralDivision ed ON ee.electoral_division_id = ed.electoral_division_id
JOIN PoliticalParty pp ON c.political_party_code = pp.party_code
ORDER BY pp.party_name, c.candidate_name;

-- Count candidates per party
SELECT pp.party_name, COUNT(*) AS CandidateCount
FROM Candidate c
JOIN PoliticalParty pp ON c.political_party_code = pp.party_code
GROUP BY pp.party_name
ORDER BY CandidateCount DESC;

-- Show the division for which candidates were created
SELECT DISTINCT ed.division_name
FROM Candidate c
JOIN ElectionEvent ee ON c.election_event_id = ee.election_event_id
JOIN ElectoralDivision ed ON ee.electoral_division_id = ed.electoral_division_id;