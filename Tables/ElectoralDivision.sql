CREATE TABLE [dbo].[ElectoralDivision]
(
  [electoral_division_id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [division_name] VARCHAR(100) NOT NULL,
  [state] VARCHAR(50),
  [population] INT,
  [current_mp_name] VARCHAR(100),
  [current_mp_party] VARCHAR(100),
  [total_registered_voters] INT,
)
