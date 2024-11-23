CREATE TABLE [dbo].[Ballot]
(
  [ballot_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [election_event_id] INT NOT NULL,
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id)
)
