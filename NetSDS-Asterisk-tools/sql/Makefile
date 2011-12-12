all:
	pg_dump -U asterisk -c >./express.sql
	pg_dump -C -s -U asterisk >./asterisk2.sql
	diff asterisk2.sql asterisk.sql 
