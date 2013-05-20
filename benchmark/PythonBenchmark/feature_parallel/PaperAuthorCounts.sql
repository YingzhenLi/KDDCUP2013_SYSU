SELECT pac.Count AS NumAuthorsWithPaper
FROM ##DataTable## t
LEFT OUTER JOIN Paper p ON t.PaperId=p.Id
LEFT OUTER JOIN PaperAuthorCounts pac
    ON pac.PaperId=t.PaperId
