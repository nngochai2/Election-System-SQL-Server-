CREATE TABLE [dbo].[BallotPreferences]
(
  [ballot_id] INT NOT NULL,
  [candidate_id] INT NOT NULL,
  [preference_order] INT,
  PRIMARY KEY (ballot_id, candidate_id),
  FOREIGN KEY (ballot_id) REFERENCES [dbo].[Ballot](ballot_id),
  FOREIGN KEY (candidate_id) REFERENCES [dbo].[Candidate](candidate_id)
)