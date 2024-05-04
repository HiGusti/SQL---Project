--untuk menambahkan di daftar pencarian
create schema shoes_product
go

--Select : menampilkan data
	select * from shoes_product

--Where : mencari data
	select * from shoes_product
	where category_id = 2

--update : menambahkan data
	update shoes_product
	set category_id = 3
	where product_id = 'MTA-00008'



delete from "Script_1".product_oase 
where code_product = 'BP001_HM66'

insert into "Script_1".product_oase (code_product, item_product , qty ,unit_price )
	
values ('BP001_HM66','HM_66_BackFIlm',1,150000);

--operator
select * from "Script_1".data_penjualan_oase dpo 

select * from "Script_1".data_penjualan_oase dpo 
where code_product like 'BP001%' --menggunakan (%) sebagaikode 

select * from "Script_1".data_penjualan_oase dpo 
where unit_price != 300000 -- (!=) filter selain dari

select code_product , warna from "Script_1".data_penjualan_oase dpo 
where warna is null 

--distinct, orderby, limit, as
select distinct code_product from "Script_1".data_penjualan_oase dpo -- mengeliminasi duplikat

select * from "Script_1".data_penjualan_oase dpo 
order by item_product -- fungsinya untuk mengurutkan

select * from "Script_1".data_penjualan_oase dpo 
limit 5

select * from "Script_1".product_oase po 
limit 5

select code_product as cp --alias ngga pake string
from "Script_1".data_penjualan_oase dpo 

--JOIN menggabungkan 2 tabel
select * from "Script_1".product_oase po  inner join "Script_1".data_penjualan_oase dpo 
on dpo.code_product = po.code_product  
