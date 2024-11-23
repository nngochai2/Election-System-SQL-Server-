CREATE TABLE [dbo].[FinalTwoCandidateResult]
(
  [election_event_id] INT PRIMARY KEY,
  [candidate_one_id] INT NOT NULL,
  [candidate_one_final_tally] INT NOT NULL,
  [candidate_two_id] INT NOT NULL,
  [candidate_two_final_tally] INT NOT NULL,
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id),
  FOREIGN KEY (candidate_one_id) REFERENCES [dbo].[Candidate](candidate_id),
  FOREIGN KEY (candidate_two_id) REFERENCES [dbo].[Candidate](candidate_id)
)
