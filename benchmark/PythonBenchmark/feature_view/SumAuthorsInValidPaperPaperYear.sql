-- feature 'papers in validpaper per year'
CREATE VIEW SumAuthorsInValidPaperPaperYear AS (
SELECT t.AuthorId AS AuthorId,
       count(t.*) AS PaperPerYear,
       p.Year AS Year 
FROM ValidPaper t
LEFT OUTER JOIN paper p on t.PaperId = p.Id
GROUP BY t.AuthorId, p.year)
