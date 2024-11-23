CREATE TABLE [dbo].[PrefCountRecord]
(
  [pref_count_round_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [election_event_id] INT NOT NULL,
  [round_number] INT NOT NULL,
  [count_status] VARCHAR(50),
  [preference_aggregate] INT,
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id),
)
