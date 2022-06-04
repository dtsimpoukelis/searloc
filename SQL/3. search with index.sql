-- **********************************************************
-- **                 SEARLOC EXAMPLE                      **
-- **********************************************************
-- **           SEARCH WITH INDEX (VERY FAST)              **
-- **********************************************************

-- CREATES A SEARLOC INDEX FOR FASTER PROCESS
EXEC searloc.create_index 'icd10', 'code, name', null, null, 'rebuild' 
GO
 
-- CREATES A AUXILARY FUNCTION FOR THE EXAMPLE USE
CREATE FUNCTION ICD10_search_fast(@SearchFor NVARCHAR(MAX) ) 
RETURNS @R TABLE (
  SearchFo NVARCHAR(MAX),
  ID INT,
  SearchedText NVARCHAR(MAX),
  TextBold NVARCHAR(MAX),
  score INT
)
AS 
BEGIN
DECLARE @UserID BIGINT
SET @UserID = 1 --...
INSERT @R
SELECT TOP 6 
  @SearchFor,
  s.id, 
  (SELECT ISNULL(Code, '') + ' ' + ISNULL(Name, '') FROM ICD10 WHERE ID=s.id) ,
  searloc.match_selection(@SearchFor, (SELECT ISNULL(Code, '') + ' ' + ISNULL(Name, '') FROM ICD10 WHERE ID=s.id), '<b>', '</b>') ,
  s.score
FROM searloc.search('icd10', @SearchFor, 6, @UserID) s
ORDER BY 5 DESC 
RETURN
END

GO

-- LETS GO SEARCHING
SELECT * FROM dbo.ICD10_search_fast(N'fever')  -- whole word
SELECT * FROM dbo.ICD10_search_fast(N'fev') -- prefix
SELECT * FROM dbo.ICD10_search_fast(N'fver') -- something missing
SELECT * FROM dbo.ICD10_search_fast(N'ever') -- something missing also
SELECT * FROM dbo.ICD10_search_fast(N'feber') -- something is pronounced nearly
SELECT * FROM dbo.ICD10_search_fast(N'b20.2') -- search code exaclty
SELECT * FROM dbo.ICD10_search_fast(N'b20.') -- search code prefix
SELECT * FROM dbo.ICD10_search_fast(N'sindrom carc')   
SELECT * FROM dbo.ICD10_search_fast(N'a21 ocu')
GO 


-- AUTO COMPLETE TEXT WHEN TYPING
SELECT searloc.suggest('icd10', N'fever heart inv', 1)  -- WILL RETURN 'involvement' ( suggestion for last word 'inv' )
 

