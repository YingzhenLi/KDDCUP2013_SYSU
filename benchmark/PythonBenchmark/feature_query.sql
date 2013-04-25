SELECT t.AuthorId,
       t.PaperId,
       ajc.Count As NumSameJournal, 
       acc.Count AS NumSameConference,
       apc.Count AS NumPapersWithAuthor,
       pac.Count AS NumAuthorsWithPaper,
       CASE WHEN coauth.Sum > 0 THEN coauth.Sum
            ELSE 0 
       END AS SumPapersWithCoAuthors,
       -- feature 'paper confirmed (or deleted) this year'
       sapy.PaperPerYear
FROM ##DataTable## t
LEFT OUTER JOIN Paper p ON t.PaperId=p.Id
LEFT OUTER JOIN AuthorJournalCounts ajc
    ON ajc.AuthorId=t.AuthorId
  AND ajc.JournalId = p.JournalId
LEFT OUTER JOIN AuthorConferenceCounts acc
    ON acc.AuthorId=t.AuthorId
   AND acc.ConferenceId = p.ConferenceId
LEFT OUTER JOIN AuthorPaperCounts apc
    ON apc.AuthorId=t.AuthorId
LEFT OUTER JOIN PaperAuthorCounts pac
    ON pac.PaperId=t.PaperId
LEFT OUTER JOIN SumPapersIn##DataTable##WithCoAuthors coauth
    ON coauth.AuthorId=t.AuthorId
   AND coauth.PaperId=t.PaperId
-- feature 'paper confirmed (or deleted) this year' table
LEFT OUTER JOIN SumAuthorsIn##DataTable##PaperYear sapy
    ON sapy.Year = p.Year
