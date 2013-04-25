-- #paper the author published in per journal
CREATE VIEW AuthorJournalCounts AS (
SELECT AuthorId, JournalId, Count(*) AS Count
FROM PaperAuthor pa
LEFT OUTER JOIN Paper p on pa.PaperId=p.Id
GROUP BY AuthorId, JournalId)
