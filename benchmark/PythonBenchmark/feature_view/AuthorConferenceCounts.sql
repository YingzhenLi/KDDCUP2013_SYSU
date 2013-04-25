-- #paper the author published in per conference
CREATE VIEW AuthorConferenceCounts AS (
SELECT AuthorId, ConferenceId, Count(*) AS Count
FROM PaperAuthor pa
LEFT OUTER JOIN Paper p on pa.PaperId=p.Id
GROUP BY AuthorId, ConferenceId)
