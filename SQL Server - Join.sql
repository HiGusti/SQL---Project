
--JOIN menggabungkan 2 tabel
select * from "Script_1".product_oase po  inner join "Script_1".data_penjualan_oase dpo 
on dpo.code_product = po.code_product  