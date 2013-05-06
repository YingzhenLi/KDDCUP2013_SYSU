-- coauthor of deleted paper
-- NOTE: may be fake because we do not know if the coauthor-ship is confirmed/deleted!
CREATE VIEW TrainDeletedCoAuthors AS (
SELECT pa1.AuthorId Author1, 
       pa2.AuthorId Author2, 
       COUNT(*) AS NumPapersTogether
FROM PaperAuthor pa1,
     PaperAuthor pa2
WHERE pa1.PaperId=pa2.PaperId
  AND pa1.AuthorId != pa2.AuthorId
  AND pa1.AuthorId IN (
      SELECT DISTINCT AuthorId
          FROM TrainDeleted)
      GROUP BY pa1.AuthorId, pa2.AuthorId)

-- if we need the deleted coauthor-ships:
-- CREATE VIEW TrainDeletedCoAuthors AS (
-- SELECT td1.AuthorId Author1, 
--        td2.AuthorId Author2, 
--        COUNT(*) AS NumPapersTogether
-- FROM TrainDeleted td1,
--      TrainDeleted td2
-- WHERE td1.PaperId=td2.PaperId
--   AND td1.AuthorId != td2.AuthorId
-- GROUP BY td1.AuthorId, td2.AuthorId)
