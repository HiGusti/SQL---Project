--untuk menambahkan di daftar pencarian
create schema shoes_product
go

--Select : menampilkan data
	select * from shoes_product

--Where : mencari data
	select * from shoes_product
	where category_id = 2

--Like : 
	select * from shoes_product 
	where model_year like '%2007%' --(%) sebagai kode 

--!= : filter selain dari
	select * from shoes_product  
	where category_id != 3 -- (!=) filter selain dari

--is null : untuk menampilkan data kosong
	select code_product , warna from shoes_product
	where warna is null

--update : menambahkan data
	update shoes_product
	set category_id = 3
	where product_id = 'MTA-00008'

--delete : menghapus data
	delete from shoes_product 
	where product_name = 'Adidas PureBoost'

--distinct : untuk eliminasi data duplikat
	select distinct shoes_product from product_name 

--order by : mengurutkan/sortir data 
	select * from shoes_product 
	order by product_name

--limit (untuk SQL server menggunakan TOP)
	select top 3 * from shoes_product

--as : alias atau untuk mengubah nama kolom
	select product_name as nama_produk
	from shoes_product 

