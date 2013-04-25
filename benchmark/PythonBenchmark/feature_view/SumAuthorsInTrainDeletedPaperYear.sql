-- feature 'papers deleted per year'
CREATE VIEW SumAuthorsInTrainDeletedPaperYear AS (
SELECT t.AuthorId AS AuthorId,
       count(t.*) AS PaperPerYear,
       p.Year AS Year 
FROM TrainDeleted t
LEFT OUTER JOIN paper p on t.PaperId = p.Id
GROUP BY t.AuthorId, p.year)
