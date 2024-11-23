CREATE TABLE [dbo].[PoliticalParty] 
(
  [party_code] CHAR(5) PRIMARY KEY,
  [party_name] VARCHAR(100) NOT NULL,
  [party_logo] VARCHAR(255), -- Link to the image of the logo
  [party_postal_address] VARCHAR(255),
  [party_secretary] VARCHAR(100),
  [contact_person_name] VARCHAR(100),
  [contact_person_phone] VARCHAR(15),
  [contact_person_email] VARCHAR(100),
)