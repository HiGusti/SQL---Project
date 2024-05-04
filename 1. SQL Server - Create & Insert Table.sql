create schema production
go

--create table : membuat sebuah tabel database
create Table shoes_product (
	product_id varchar (20) not null,
	product_name varchar (100) not null,
	category_id int not null,
	model_year smallint not null,
	primary key (product_id)
);

--insert data table : menambahkan data pada tabel
insert into shoes_product (product_id,product_name,category_id,model_year)
values
	('MTA-00001', 'Adidas Samba', 01, 2001),
	('MTA-00002', 'Adidas Ultra Boost', 02, 2002),
	('MTA-00003', 'Adidas Gazele', 01, 2003),
	('MTA-00004', 'Adidas Predator', 01, 2004),
	('MTA-00005', 'Adidas Adizero Adios Pro', 03, 2005),
	('MTA-00006', 'Adidas Supernova Stride', 03, 2006),
	('MTA-00007', 'Adidas PureBoost', 02, 2007),
	('MTA-00008', 'Adidas Ultrabounce', 02, 2008);