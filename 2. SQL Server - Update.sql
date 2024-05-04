select * from sepatu_adidas

-- mengubah data pada 1 kolom
update sepatu_adidas
set year_model = 2010
where product_id = 'MTA-00001'

-- mengubah data pada beberapa kolom
update sepatu_adidas
set year_model = 2020, category_id = 4
where product_id = 'MTA-00002'

-- update dengan manambahkan nama kolom pada data yang akan di update
update sepatu_adidas
set year_model = year_model + 5
where product_id = 'MTA-00003'

-- apabila update tidak menggunakan where clause
update sepatu_adidas
set category_id = 2

select * from sepatu_adidas