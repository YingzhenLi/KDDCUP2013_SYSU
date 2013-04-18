KDDCUP2013/samples
==================

1. The benchmark code (see ben's repo) resulted in some error and I will try to fixed it in these two days. Tell me if you run the code successfully.

2. We have 200,000+ of authors and millions of papers.

3. See 'psql_data_structure' to get the data structures in the postgreSQL database.

4. See 'example' to get a typical dataset of some author.
	i.	The author has 153 publications in the database, but actually only 76 DISTINCT papers.
	ii.	He only select 12 of them as confirmed one, but 80 of them as 'delected', including the ovelapped.

5. I think it's no need to extract the small sample set out... by using the postgreSQL shell we can check the data easily (the grammar is nearly exact as the SQL execpt no system tables like oracle), here's the documentation site: 

http://www.postgresql.org/docs/9.2/static/

6. Yes I think random forest (or additive forest) may work, but we need to design each tree in it. In fact it can be viewed as a recommendation problem! 

Any other ideas edit this file and re-push it, or email me, or find me at renren.

by Yingzhen Li Apr 18 2013
