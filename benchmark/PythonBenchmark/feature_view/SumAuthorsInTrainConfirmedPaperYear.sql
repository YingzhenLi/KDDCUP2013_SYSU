-- feature 'papers confirmed per year'
CREATE VIEW SumAuthorsInTrainConfirmedPaperYear AS (
SELECT t.AuthorId AS AuthorId,
       count(t.*) AS PaperPerYear,
       p.Year AS Year 
FROM TrainConfirmed t
LEFT OUTER JOIN paper p on t.PaperId = p.Id
GROUP BY t.AuthorId, p.year)
