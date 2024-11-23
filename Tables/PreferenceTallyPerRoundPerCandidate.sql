CREATE TABLE [dbo].[PreferenceTallyPerRoundPerCandidate]
(
  [pref_count_round_id] INT NOT NULL,
  [candidate_id] INT NOT NULL,
  [tally] INT NOT NULL,
  PRIMARY KEY (pref_count_round_id, candidate_id),
  FOREIGN KEY (pref_count_round_id) REFERENCES [dbo].[PrefCountRecord](pref_count_round_id),
  FOREIGN KEY (candidate_id) REFERENCES [dbo].[Candidate](candidate_id)
)
