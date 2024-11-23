CREATE TABLE [dbo].[ElectionMaster]
(
  election_id INT PRIMARY KEY IDENTITY(1,1),
  election_name VARCHAR(100) NOT NULL,
  total_registered_voters INT NOT NULL,
  number_of_electorates INT NOT NULL,
  election_declaration_date DATE NOT NULL,
  election_date DATE NOT NULL,
  voter_registration_deadline DATE NOT NULL,
  candidate_application_deadline DATE NOT NULL,
  result_declaration_deadline DATE NOT NULL,
)
