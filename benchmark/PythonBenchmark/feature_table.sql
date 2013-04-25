-- #paper the author published in per journal
SELECT AuthorId, JournalId, Count(*) AS Count
INTO AuthorJournalCounts
FROM PaperAuthor pa
LEFT OUTER JOIN Paper p on pa.PaperId=p.Id
GROUP BY AuthorId, JournalId;
-- #paper the author published in per conference
SELECT AuthorId, ConferenceId, Count(*) AS Count
INTO AuthorConferenceCounts
FROM PaperAuthor pa
LEFT OUTER JOIN Paper p on pa.PaperId=p.Id
GROUP BY AuthorId, ConferenceId;
-- #paper the author published
SELECT AuthorId, Count(*) AS Count
INTO AuthorPaperCounts
FROM PaperAuthor
GROUP BY AuthorId;
-- #author of the paper
SELECT PaperId, Count(*) AS Count
INTO PaperAuthorCounts
FROM PaperAuthor
GROUP BY PaperId;
-- coauthor of confirmed (or deleted) paper
WITH CoAuthors AS (
    SELECT pa1.AuthorId Author1, 
           pa2.AuthorId Author2, 
           COUNT(*) AS NumPapersTogether
    FROM PaperAuthor pa1,
         PaperAuthor pa2
    WHERE pa1.PaperId=pa2.PaperId
      AND pa1.AuthorId != pa2.AuthorId
      AND pa1.AuthorId IN (
          SELECT DISTINCT AuthorId
          FROM ##DataTable##)
      GROUP BY pa1.AuthorId, pa2.AuthorId)
SELECT t.AuthorId,
       t.PaperId, 
       SUM(NumPapersTogether) AS Sum
INTO SumPapersIn##DataTable##WithCoAuthors
FROM ##DataTable## t
LEFT OUTER JOIN PaperAuthor pa ON t.PaperId=pa.PaperId
LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
WHERE pa.AuthorId != t.AuthorId
  AND ca.Author1 = t.AuthorId
GROUP BY t.AuthorId, t.PaperId;
-- feature 'papers confirmed (or deleted) per year'
SELECT t.AuthorId AS AuthorId,
       count(t.*) AS PaperPerYear,
       p.Year AS Year 
INTO SumAuthorIn##DataTable##PaperYear
FROM ##DataTable## t
LEFT OUTER JOIN paper p on t.PaperId = p.Id
GROUP BY t.AuthorId, p.year)
