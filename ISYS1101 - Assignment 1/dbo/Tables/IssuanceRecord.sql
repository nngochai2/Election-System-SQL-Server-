CREATE TABLE [dbo].[IssuanceRecord]
(
  [issuance_id] INT PRIMARY KEY IDENTITY(1,1),
  [voter_id] INT NOT NULL,
  [election_event_id] INT NOT NULL,
  [issuance_timestamp] DATETIME NOT NULL,
  [polling_station_name] VARCHAR(100),
  FOREIGN KEY (voter_id) REFERENCES [dbo].[VoterRegistry](voter_id),
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id)
)
