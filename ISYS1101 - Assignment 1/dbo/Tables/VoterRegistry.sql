CREATE TABLE [dbo].[VoterRegistry]
(
  [voter_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [first_name] VARCHAR(50) NOT NULL,
  [middle_name] VARCHAR(50),
  [last_name] VARCHAR(50) NOT NULL,
  [date_of_birth] DATE NOT NULL,
  [residential_address] VARCHAR(255) NOT NULL,
  [postal_address] VARCHAR(255),
  [contact_phone] VARCHAR(15),
  [email_address] VARCHAR(100),
  [electoral_division_id] INT NOT NULL,
  FOREIGN KEY (electoral_division_id) REFERENCES [dbo].[ElectoralDivision](electoral_division_id),
)
