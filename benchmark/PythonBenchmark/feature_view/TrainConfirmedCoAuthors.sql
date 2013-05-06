-- coauthor of confirmed paper
-- NOTE: may be fake because we do not know if the coauthor-ship is confirmed/deleted!
CREATE VIEW TrainConfirmedCoAuthors AS (
SELECT pa1.AuthorId Author1, 
       pa2.AuthorId Author2, 
       COUNT(*) AS NumPapersTogether
FROM PaperAuthor pa1,
     PaperAuthor pa2
WHERE pa1.PaperId=pa2.PaperId
  AND pa1.AuthorId != pa2.AuthorId
  AND pa1.AuthorId IN (
      SELECT DISTINCT AuthorId
          FROM TrainConfirmed)
      GROUP BY pa1.AuthorId, pa2.AuthorId)

-- if we need the confirmed coauthor-ships:
-- CREATE VIEW TrainConfirmedCoAuthors AS (
-- SELECT tc1.AuthorId Author1, 
--        tc2.AuthorId Author2, 
--        COUNT(*) AS NumPapersTogether
-- FROM TrainConfirmed tc1,
--      TrainConfirmed tc2
-- WHERE tc1.PaperId=tc2.PaperId
--   AND tc1.AuthorId != tc2.AuthorId
-- GROUP BY tc1.AuthorId, tc2.AUthorId)
