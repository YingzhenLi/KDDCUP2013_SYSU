-- #paper the author published
CREATE VIEW AuthorPaperCounts AS (
SELECT AuthorId, Count(*) AS Count
FROM PaperAuthor
GROUP BY AuthorId)
