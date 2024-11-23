-- Write your own SQL object definition here, and it'll be included in your package.
-- Populate VoterRegistry with 1000 sample voters
INSERT INTO VoterRegistry (first_name, middle_name, last_name, date_of_birth, residential_address, postal_address, contact_phone, email_address, electoral_division_id)
SELECT TOP 1000
    'FirstName' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR),
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'MiddleName' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR) ELSE NULL END,
    'LastName' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 18250, GETDATE()), -- Random date of birth (18-70 years old)
    CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR) + ' Main St, City' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR),
    CASE WHEN ABS(CHECKSUM(NEWID())) % 5 = 0 THEN CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR) + ' Postal St, City' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR) ELSE NULL END,
    '(555)' + CAST(ABS(CHECKSUM(NEWID())) % 10000000 AS VARCHAR),
    'email' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR) + '@example.com',
    (ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM ElectoralDivision)) + 1
FROM sys.objects;

-- Create IssuanceRecord entries for these voters
INSERT INTO IssuanceRecord (voter_id, election_event_id, issuance_timestamp, polling_station_name)
SELECT 
    vr.voter_id,
    ee.election_event_id,
    DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % (60 * 12), '2022-05-21 08:00:00'), -- Random time between 8 AM and 8 PM on election day
    'Polling Station ' + CAST(ABS(CHECKSUM(NEWID())) % 20 + 1 AS VARCHAR)
FROM 
    (SELECT TOP 1000 voter_id FROM VoterRegistry ORDER BY NEWID()) vr
CROSS JOIN 
    (SELECT TOP 1 election_event_id FROM ElectionEvent WHERE election_serial_no = 20220521 ORDER BY NEWID()) ee;

-- Verify the data
SELECT TOP 10 * FROM VoterRegistry;
SELECT TOP 10 * FROM IssuanceRecord;

-- Count the total number of entries
SELECT COUNT(*) AS TotalVoters FROM VoterRegistry;
SELECT COUNT(*) AS TotalIssuanceRecords FROM IssuanceRecord;