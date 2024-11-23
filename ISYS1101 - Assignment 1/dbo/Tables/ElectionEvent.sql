CREATE TABLE [dbo].[ElectionEvent]
(
  [election_event_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [election_id] INT NOT NULL,
  [electoral_division_id] INT NOT NULL,
  [number_of_candidates] INT NOT NULL,
  [number_of_votes_cast] INT,
  [number_of_valid_votes] INT,
  [result_status] VARCHAR(50),
  [swing_percentage] DECIMAL(5,2),
  FOREIGN KEY (election_id) REFERENCES [dbo].[ElectionMaster](election_id),
  FOREIGN KEY (electoral_division_id) REFERENCES [dbo].[ElectoralDivision](electoral_division_id)
)
