create table primary_operators ( 
	id bigserial not null primary key,
	msisdn character varying (20),
  operator character varying (20),
	create_date timestamp without time zone default now(), 
	comment character varying (40)
);

create INDEX on primary_operators ( msisdn ); 
	
