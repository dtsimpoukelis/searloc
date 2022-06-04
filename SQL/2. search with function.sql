-- **********************************************************
-- **                 SEARLOC EXAMPLE                      **
-- **********************************************************
-- **        SEARCH WITH FUNCTION searloc.match            **
-- **********************************************************

-- CREATES A AUXILARY FUNCTION FOR THE EXAMPLE USE
CREATE FUNCTION ICD10_search(@SearchFor NVARCHAR(MAX) ) 
RETURNS @R TABLE (
  SearchFo NVARCHAR(MAX),
  ID INT,
  SearchedText NVARCHAR(MAX),
  TextBold NVARCHAR(MAX),
  score INT
)
AS 
BEGIN
INSERT @R
SELECT TOP 6 
  @SearchFor,
  id, 
  ISNULL(Code, '') + ' ' + ISNULL(Name, '') ,
  searloc.match_selection(@SearchFor, ISNULL(Code, '') + ' ' + ISNULL(Name, ''), '<b>', '</b>'),
  searloc.match(@SearchFor, ISNULL(Code, '') + ' ' + ISNULL(Name, '') ) 
FROM ICD10
WHERE searloc.match(@SearchFor, ISNULL(Code, '') + ' ' + ISNULL(Name, '') ) >= 750
ORDER BY 5 DESC 
RETURN
END

GO


-- LETS GO SEARCHING
SELECT * FROM dbo.ICD10_search(N'fever')  -- whole word
SELECT * FROM dbo.ICD10_search(N'fev') -- prefix
SELECT * FROM dbo.ICD10_search(N'fver') -- something missing
SELECT * FROM dbo.ICD10_search(N'ever') -- something missing also
SELECT * FROM dbo.ICD10_search(N'feber') -- something is pronounced nearly
SELECT * FROM dbo.ICD10_search(N'b20.2') -- search code exaclty
SELECT * FROM dbo.ICD10_search(N'b20.') -- search code prefix
SELECT * FROM dbo.ICD10_search(N'sindrom carc')   
SELECT * FROM dbo.ICD10_search(N'a21 ocu')
