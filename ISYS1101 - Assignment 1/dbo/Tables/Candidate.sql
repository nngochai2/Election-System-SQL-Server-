CREATE TABLE [dbo].[Candidate]
(
  [candidate_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [candidate_name] VARCHAR(100) NOT NULL,
  [contact_name] VARCHAR(100),
  [contact_phone] VARCHAR(15),
  [contact_email] VARCHAR(100),
  [political_party_code] CHAR(5),
  [election_event_id] INT NOT NULL,
  FOREIGN KEY (political_party_code) REFERENCES [dbo].[PoliticalParty](party_code),
  FOREIGN KEY (election_event_id) REFERENCES [dbo].[ElectionEvent](election_event_id),
)
