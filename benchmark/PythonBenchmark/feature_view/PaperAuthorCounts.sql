-- #author of the paper
CREATE VIEW PaperAuthorCounts AS (
SELECT PaperId, Count(*) AS Count
FROM PaperAuthor
GROUP BY PaperId)
