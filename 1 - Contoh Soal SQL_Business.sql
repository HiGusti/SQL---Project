1. Soal:
   Perusahaan ingin mengetahui total penjualan berdasarkan kategori produk selama periode tertentu. 
   Buatlah query untuk menampilkan total penjualan, jumlah transaksi, dan rata-rata penjualan per transaksi untuk setiap kategori produk.

   Jawaban:
   ```sql
   SELECT 
      pc.Name AS ProductCategory,
      SUM(sod.LineTotal) AS TotalSales,
      COUNT(sod.SalesOrderDetailID) AS TotalTransactions,
      AVG(sod.LineTotal) AS AvgSalesPerTransaction
   FROM Sales.SalesOrderDetail sod
   JOIN Production.Product p ON sod.ProductID = p.ProductID
   JOIN Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
   WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
   GROUP BY pc.Name
   ORDER BY TotalSales DESC;
   ```

2. Soal:
   Perusahaan ingin mengetahui 5 produk teratas yang memberikan kontribusi terbesar terhadap total penjualan. 
   Buatlah query untuk menampilkan nama produk, total penjualan, dan persentase kontribusi terhadap total penjualan.

   Jawaban:
   ```sql
   WITH TopProducts AS (
      SELECT 
         p.Name AS ProductName,
         SUM(sod.LineTotal) AS TotalSales,
         SUM(SUM(sod.LineTotal)) OVER() AS TotalSalesAll,
         SUM(sod.LineTotal) * 100.0 / SUM(SUM(sod.LineTotal)) OVER() AS SalesPercentage
      FROM Sales.SalesOrderDetail sod
      JOIN Production.Product p ON sod.ProductID = p.ProductID
      WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
      GROUP BY p.Name
      ORDER BY TotalSales DESC
      OFFSET 0 ROWS
      FETCH FIRST 5 ROWS ONLY
   )
   SELECT 
      ProductName,
      TotalSales,
      ROUND(SalesPercentage, 2) AS SalesPercentage
   FROM TopProducts;
   ```

3. Soal:
   Perusahaan ingin mengetahui performa penjualan berdasarkan wilayah. Buatlah query untuk menampilkan total penjualan, jumlah pelanggan, dan rata-rata penjualan per pelanggan untuk setiap wilayah.

   Jawaban:
   ```sql
   SELECT 
      st.Name AS StateName,
      SUM(sod.LineTotal) AS TotalSales,
      COUNT(DISTINCT so.CustomerID) AS TotalCustomers,
      SUM(sod.LineTotal) / COUNT(DISTINCT so.CustomerID) AS AvgSalesPerCustomer
   FROM Sales.SalesOrderDetail sod
   JOIN Sales.SalesOrderHeader so ON sod.SalesOrderID = so.SalesOrderID
   JOIN Person.Address pa ON so.ShipToAddressID = pa.AddressID
   JOIN Person.StateProvince st ON pa.StateProvinceID = st.StateProvinceID
   WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
   GROUP BY st.Name
   ORDER BY TotalSales DESC;
   ```

4. Soal:
   Perusahaan ingin mengetahui tren penjualan per bulan selama periode tertentu. Buatlah query untuk menampilkan total penjualan, jumlah transaksi, dan rata-rata penjualan per transaksi untuk setiap bulan.

   Jawaban:
   ```sql
   SELECT 
      MONTH(sod.ModifiedDate) AS Month,
      YEAR(sod.ModifiedDate) AS Year,
      SUM(sod.LineTotal) AS TotalSales,
      COUNT(sod.SalesOrderDetailID) AS TotalTransactions,
      SUM(sod.LineTotal) / COUNT(sod.SalesOrderDetailID) AS AvgSalesPerTransaction
   FROM Sales.SalesOrderDetail sod
   WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
   GROUP BY MONTH(sod.ModifiedDate), YEAR(sod.ModifiedDate)
   ORDER BY Year, Month;
   ```

5. Soal:
   Perusahaan ingin mengetahui profil pelanggan berdasarkan jenis kelamin dan status pernikahan. 
   Buatlah query untuk menampilkan jumlah pelanggan, total penjualan, dan rata-rata penjualan per pelanggan 
   untuk setiap kombinasi jenis kelamin dan status pernikahan.

   Jawaban:
   ```sql
   SELECT 
      CASE p.Gender 
         WHEN 'M' THEN 'Male'
         WHEN 'F' THEN 'Female'
         ELSE 'Unknown'
      END AS Gender,
      CASE p.MaritalStatus
         WHEN 'S' THEN 'Single'
         WHEN 'M' THEN 'Married'
         WHEN 'D' THEN 'Divorced'
         ELSE 'Unknown'
      END AS MaritalStatus,
      COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
      SUM(sod.LineTotal) AS TotalSales,
      SUM(sod.LineTotal) / COUNT(DISTINCT c.CustomerID) AS AvgSalesPerCustomer
   FROM Sales.SalesOrderDetail sod
   JOIN Sales.SalesOrderHeader so ON sod.SalesOrderID = so.SalesOrderID
   JOIN Sales.Customer c ON so.CustomerID = c.CustomerID
   JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
   WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
   GROUP BY 
      CASE p.Gender WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE 'Unknown' END,
      CASE p.MaritalStatus WHEN 'S' THEN 'Single' WHEN 'M' THEN 'Married' WHEN 'D' THEN 'Divorced' ELSE 'Unknown' END
   ORDER BY Gender, MaritalStatus;
   ```

6. Soal:
   Perusahaan ingin mengetahui produk-produk yang penjualannya meningkat atau menurun dibandingkan tahun sebelumnya. 
   Buatlah query untuk menampilkan nama produk, total penjualan tahun ini, total penjualan tahun lalu, dan persentase perubahan penjualan.

   Jawaban:
   ```sql
   WITH CurrentYearSales AS (
      SELECT 
         p.Name AS ProductName,
         SUM(sod.LineTotal) AS CurrentYearSales
      FROM Sales.SalesOrderDetail sod
      JOIN Production.Product p ON sod.ProductID = p.ProductID
      WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
      GROUP BY p.Name
   ), PreviousYearSales AS (
      SELECT 
         p.Name AS ProductName,
         SUM(sod.LineTotal) AS PreviousYearSales
      FROM Sales.SalesOrderDetail sod
      JOIN Production.Product p ON sod.ProductID = p.ProductID
      WHERE sod.ModifiedDate BETWEEN '2014-01-01' AND '2014-12-31'
      GROUP BY p.Name
   )
   SELECT 
      cys.ProductName,
      cys.CurrentYearSales,
      pys.PreviousYearSales,
      CASE 
         WHEN pys.PreviousYearSales = 0 THEN 'N/A'
         ELSE ROUND(100.0 * (cys.CurrentYearSales - pys.PreviousYearSales) / pys.PreviousYearSales, 2)
      END AS SalesChangePercentage
   FROM CurrentYearSales cys
   LEFT JOIN PreviousYearSales pys ON cys.ProductName = pys.ProductName
   ORDER BY SalesChangePercentage DESC;
   ```

7. Soal:
   Perusahaan ingin mengetahui produk-produk yang penjualannya tinggi namun memiliki tingkat pengembalian yang tinggi. 
   Buatlah query untuk menampilkan nama produk, total penjualan, jumlah pengembalian, dan persentase pengembalian terhadap penjualan.

   Jawaban:
   ```sql
   SELECT 
      p.Name AS ProductName,
      SUM(sod.LineTotal) AS TotalSales,
      SUM(CASE WHEN soh.Status = 3 THEN sod.LineTotal ELSE 0 END) AS TotalReturns,
      ROUND(100.0 * SUM(CASE WHEN soh.Status = 3 THEN sod.LineTotal ELSE 0 END) / SUM(sod.LineTotal), 2) AS ReturnPercentage
   FROM Sales.SalesOrderDetail sod
   JOIN Production.Product p ON sod.ProductID = p.ProductID
   JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
   WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
   GROUP BY p.Name
   HAVING SUM(sod.LineTotal) > 100000 AND ROUND(100.0 * SUM(CASE WHEN soh.Status = 3 THEN sod.LineTotal ELSE 0 END) / SUM(sod.LineTotal), 2) > 5
   ORDER BY ReturnPercentage DESC;
   ```

8. Soal:
   Perusahaan ingin mengetahui produk-produk yang penjualannya dipengaruhi oleh hari libur. 
   Buatlah query untuk menampilkan nama produk, total penjualan pada hari libur, total penjualan di hari biasa, dan persentase penjualan pada hari libur.

   Jawaban:
   ```sql
   WITH HolidaySales AS (
      SELECT 
         p.Name AS ProductName,
         SUM(CASE WHEN DATEPART(dw, sod.ModifiedDate) IN (1, 7) THEN sod.LineTotal ELSE 0 END) AS HolidaySales,
         SUM(CASE WHEN DATEPART(dw, sod.ModifiedDate) NOT IN (1, 7) THEN sod.LineTotal ELSE 0 END) AS RegularDaySales
      FROM Sales.SalesOrderDetail sod
      JOIN Production.Product p ON sod.ProductID = p.ProductID
      WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
      GROUP BY p.Name
   )
   SELECT 
      ProductName,
      HolidaySales,
      RegularDaySales,
      ROUND(100.0 * HolidaySales / (HolidaySales + RegularDaySales), 2) AS HolidaySalesPercentage
   FROM HolidaySales
   ORDER BY HolidaySalesPercentage DESC;
   ```

9. Soal:
   Perusahaan ingin mengetahui produk-produk yang memiliki tingkat ketersediaan (stok) rendah dan membutuhkan perhatian khusus. 
   Buatlah query untuk menampilkan nama produk, stok saat ini, dan jumlah hari stok tersisa berdasarkan rata-rata penjualan per hari.

   Jawaban:
   ```sql
   WITH ProductSales AS (
      SELECT 
         p.ProductID,
         p.Name AS ProductName,
         SUM(sod.LineTotal) AS TotalSales,
         COUNT(sod.SalesOrderDetailID) AS TotalTransactions,
         SUM(sod.LineTotal) / COUNT(sod.SalesOrderDetailID) AS AvgSalesPerTransaction
      FROM Sales.SalesOrderDetail sod
      JOIN Production.Product p ON sod.ProductID = p.ProductID
      WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
      GROUP BY p.ProductID, p.Name
   ), ProductInventory AS (
      SELECT 
         p.ProductID,
         p.Name AS ProductName,
         p.SafetyStockLevel,
         p.ReorderPoint,
         p.StandardCost,
         p.ListPrice,
         p.UnitsInStock
      FROM Production.Product p
   )
   SELECT 
      ps.ProductName,
      pi.UnitsInStock,
      CASE 
         WHEN ps.AvgSalesPerTransaction = 0 THEN 'Infinite'
         ELSE CAST(pi.UnitsInStock / (ps.TotalSales * 1.0 / ps.TotalTransactions) AS INT)
      END AS DaysOfStock
   FROM ProductSales ps
   JOIN ProductInventory pi ON ps.ProductID = pi.ProductID
   WHERE pi.UnitsInStock <= pi.ReorderPoint
   ORDER BY DaysOfStock;
   ```

10. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki margin keuntungan yang tinggi. 
	Buatlah query untuk menampilkan nama produk, harga jual, harga pokok, dan persentase margin keuntungan.

    Jawaban:
    ```sql
    SELECT 
       p.Name AS ProductName,
       p.ListPrice AS SalesPrice,
       p.StandardCost AS CostPrice,
       ROUND(100.0 * (p.ListPrice - p.StandardCost) / p.StandardCost, 2) AS ProfitMargin
    FROM Production.Product p
    WHERE p.ProductSubcategoryID IS NOT NULL
    ORDER BY ProfitMargin DESC;
    ```

11. Soal:
    Perusahaan ingin mengetahui tren pertumbuhan penjualan berdasarkan kategori produk setiap tahunnya. 
	Buatlah query untuk menampilkan nama kategori produk, total penjualan per tahun, dan persentase perubahan penjualan tahun ke tahun.

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          pc.Name AS ProductCategoryName,
          YEAR(sod.ModifiedDate) AS SalesYear,
          SUM(sod.LineTotal) AS TotalSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2015-12-31'
       GROUP BY pc.Name, YEAR(sod.ModifiedDate)
    ), SalesTrend AS (
       SELECT 
          ProductCategoryName,
          SalesYear,
          TotalSales,
          LAG(TotalSales, 1) OVER (PARTITION BY ProductCategoryName ORDER BY SalesYear) AS PrevYearSales
       FROM ProductSales
    )
    SELECT 
       ProductCategoryName,
       SalesYear,
       TotalSales,
       CASE 
          WHEN PrevYearSales IS NULL THEN 'N/A'
          ELSE ROUND(100.0 * (TotalSales - PrevYearSales) / PrevYearSales, 2)
       END AS SalesGrowthPercentage
    FROM SalesTrend
    ORDER BY ProductCategoryName, SalesYear;
    ```

12. Soal:
    Perusahaan ingin mengetahui pertumbuhan pelanggan baru berdasarkan segmen geografis setiap tahunnya. 
	Buatlah query untuk menampilkan nama negara, jumlah pelanggan baru per tahun, dan persentase pertumbuhan pelanggan baru tahun ke tahun.

    Jawaban:
    ```sql
    WITH NewCustomers AS (
       SELECT 
          sp.CountryRegionName,
          YEAR(c.ModifiedDate) AS CustomerYear,
          COUNT(DISTINCT c.CustomerID) AS NewCustomerCount
       FROM Sales.Customer c
       JOIN Person.StateProvince sp ON c.StateProvinceID = sp.StateProvinceID
       WHERE c.ModifiedDate BETWEEN '2013-01-01' AND '2015-12-31'
       GROUP BY sp.CountryRegionName, YEAR(c.ModifiedDate)
    ), CustomerTrend AS (
       SELECT 
          CountryRegionName,
          CustomerYear,
          NewCustomerCount,
          LAG(NewCustomerCount, 1) OVER (PARTITION BY CountryRegionName ORDER BY CustomerYear) AS PrevYearNewCustomers
       FROM NewCustomers
    )
    SELECT 
       CountryRegionName,
       CustomerYear,
       NewCustomerCount,
       CASE 
          WHEN PrevYearNewCustomers IS NULL THEN 'N/A'
          ELSE ROUND(100.0 * (NewCustomerCount - PrevYearNewCustomers) / PrevYearNewCustomers, 2)
       END AS NewCustomerGrowthPercentage
    FROM CustomerTrend
    ORDER BY CountryRegionName, CustomerYear;
    ```

13. Soal:
    Perusahaan ingin mengetahui pertumbuhan penjualan produk baru setiap tahunnya. 
	Buatlah query untuk menampilkan nama produk, tahun peluncuran, total penjualan per tahun, dan persentase pertumbuhan penjualan tahun ke tahun.

    Jawaban:
    ```sql
    WITH NewProducts AS (
       SELECT 
          p.Name AS ProductName,
          p.ProductNumber,
          p.ModifiedDate AS LaunchDate,
          YEAR(p.ModifiedDate) AS LaunchYear,
          SUM(sod.LineTotal) AS TotalSales
       FROM Production.Product p
       JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
       WHERE p.ModifiedDate BETWEEN '2013-01-01' AND '2015-12-31'
       GROUP BY p.Name, p.ProductNumber, p.ModifiedDate
    ), ProductSalesTrend AS (
       SELECT 
          ProductName,
          ProductNumber,
          LaunchYear,
          LaunchDate,
          TotalSales,
          LAG(TotalSales, 1) OVER (PARTITION BY ProductNumber ORDER BY LaunchYear) AS PrevYearSales
       FROM NewProducts
    )
    SELECT 
       ProductName,
       LaunchYear,
       TotalSales,
       CASE 
          WHEN PrevYearSales IS NULL THEN 'N/A'
          ELSE ROUND(100.0 * (TotalSales - PrevYearSales) / PrevYearSales, 2)
       END AS SalesGrowthPercentage
    FROM ProductSalesTrend
    ORDER BY ProductName, LaunchYear;
    ```
14. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi pertumbuhan tinggi berdasarkan tren penjualan dan ketersediaan stok. 
	Buatlah query untuk menampilkan nama produk, total penjualan, sisa stok, dan persentase pertumbuhan potensial.

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales,
          SUM(sod.LineTotal) / COUNT(sod.SalesOrderDetailID) AS AvgSalesPerTransaction
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), ProductInventory AS (
       SELECT 
          p.Name AS ProductName,
          p.UnitsInStock,
          p.ReorderPoint
       FROM Production.Product p
    )
    SELECT 
       ps.ProductName,
       ps.TotalSales,
       pi.UnitsInStock,
       CASE 
          WHEN pi.UnitsInStock <= pi.ReorderPoint THEN 'High'
          WHEN ps.AvgSalesPerTransaction > 100 THEN 'High'
          ELSE 'Low'
       END AS GrowthPotential
    FROM ProductSales ps
    JOIN ProductInventory pi ON ps.ProductName = pi.ProductName
    ORDER BY GrowthPotential DESC, ps.TotalSales DESC;
    ```

15. Soal:
    Perusahaan ingin mengetahui produk-produk yang paling banyak terjual berdasarkan segmen pelanggan. 
	Buatlah query untuk menampilkan nama produk, jumlah penjualan per segmen pelanggan, dan persentase kontribusi penjualan per segmen.

    Jawaban:
    ```sql
    WITH CustomerSales AS (
       SELECT 
          p.Name AS ProductName,
          CASE 
             WHEN c.CustomerType = 'S' THEN 'Individual'
             WHEN c.CustomerType = 'I' THEN 'Corporate'
          END AS CustomerSegment,
          SUM(sod.LineTotal) AS TotalSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name, CASE WHEN c.CustomerType = 'S' THEN 'Individual' ELSE 'Corporate' END
    ), SegmentSummary AS (
       SELECT 
          ProductName,
          CustomerSegment,
          TotalSales,
          SUM(TotalSales) OVER (PARTITION BY ProductName) AS TotalProductSales
       FROM CustomerSales
    )
    SELECT 
       ProductName,
       CustomerSegment,
       TotalSales,
       ROUND(100.0 * TotalSales / TotalProductSales, 2) AS SegmentSalesPercentage
    FROM SegmentSummary
    ORDER BY ProductName, SegmentSalesPercentage DESC;
    ```

16. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki tingkat pertumbuhan penjualan yang tinggi di pasar internasional. 
	Buatlah query untuk menampilkan nama produk, total penjualan di pasar internasional, persentase pertumbuhan penjualan di pasar internasional, 
	dan perbandingan dengan total penjualan domestik.

    Jawaban:
    ```sql
    WITH InternationalSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(CASE WHEN sp.CountryRegionName <> 'United States' THEN sod.LineTotal ELSE 0 END) AS InternationalSales,
          SUM(CASE WHEN sp.CountryRegionName = 'United States' THEN sod.LineTotal ELSE 0 END) AS DomesticSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       JOIN Person.StateProvince sp ON soh.ShipToStateProvinceID = sp.StateProvinceID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), SalesTrend AS (
       SELECT 
          ProductName,
          InternationalSales,
          DomesticSales,
          LAG(InternationalSales, 1) OVER (PARTITION BY ProductName ORDER BY ProductName) AS PrevYearInternationalSales
       FROM InternationalSales
    )
    SELECT 
       ProductName,
       InternationalSales,
       CASE 
          WHEN PrevYearInternationalSales IS NULL THEN 'N/A'
          ELSE ROUND(100.0 * (InternationalSales - PrevYearInternationalSales) / PrevYearInternationalSales, 2)
       END AS InternationalSalesGrowthPercentage,
       DomesticSales,
       ROUND(100.0 * InternationalSales / (InternationalSales + DomesticSales), 2) AS InternationalSalesPercentage
    FROM SalesTrend
    ORDER BY InternationalSalesGrowthPercentage DESC;
    ```
17. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki tingkat profitabilitas tinggi berdasarkan margin keuntungan. 
	Buatlah query untuk menampilkan nama produk, harga jual, biaya produksi, margin keuntungan, dan persentase margin keuntungan.

    Jawaban:
    ```sql
    WITH ProductCost AS (
       SELECT 
          p.Name AS ProductName,
          p.ListPrice AS SalesPrice,
          p.StandardCost AS ProductionCost,
          (p.ListPrice - p.StandardCost) AS Profit,
          ROUND(100.0 * (p.ListPrice - p.StandardCost) / p.ListPrice, 2) AS ProfitMarginPercentage
       FROM Production.Product p
    )
    SELECT 
       ProductName,
       SalesPrice,
       ProductionCost,
       Profit,
       ProfitMarginPercentage
    FROM ProductCost
    ORDER BY ProfitMarginPercentage DESC;
    ```

18. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki tingkat perputaran stok (inventory turnover) yang tinggi. 
	Buatlah query untuk menampilkan nama produk, total penjualan, jumlah stok, dan tingkat perputaran stok.

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), ProductInventory AS (
       SELECT 
          p.Name AS ProductName,
          p.UnitsInStock
       FROM Production.Product p
    )
    SELECT 
       ps.ProductName,
       ps.TotalSales,
       pi.UnitsInStock,
       CASE 
          WHEN pi.UnitsInStock = 0 THEN 'Infinite'
          ELSE ROUND(ps.TotalSales / pi.UnitsInStock, 2)
       END AS InventoryTurnover
    FROM ProductSales ps
    JOIN ProductInventory pi ON ps.ProductName = pi.ProductName
    ORDER BY InventoryTurnover DESC;
    ```

19. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki tingkat kepuasan pelanggan yang tinggi. 
	Buatlah query untuk menampilkan nama produk, total penjualan, dan rata-rata nilai rating dari pelanggan.

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), ProductRatings AS (
       SELECT 
          p.Name AS ProductName,
          AVG(pr.Rating) AS AverageRating
       FROM Production.Product p
       LEFT JOIN Production.ProductReview pr ON p.ProductID = pr.ProductID
       GROUP BY p.Name
    )
    SELECT 
       ps.ProductName,
       ps.TotalSales,
       pr.AverageRating
    FROM ProductSales ps
    LEFT JOIN ProductRatings pr ON ps.ProductName = pr.ProductName
    ORDER BY pr.AverageRating DESC;
    ```

20. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi untuk dijual secara online. 
	Buatlah query untuk menampilkan nama produk, total penjualan offline, total penjualan online, dan persentase penjualan online.

    Jawaban:
    ```sql
    WITH OfflineSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(CASE WHEN soh.OnlineOrderFlag = 0 THEN sod.LineTotal ELSE 0 END) AS OfflineSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), OnlineSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(CASE WHEN soh.OnlineOrderFlag = 1 THEN sod.LineTotal ELSE 0 END) AS OnlineSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), TotalSales AS (
       SELECT 
          os.ProductName,
          os.OnlineSales,
          os.OnlineSales + os.OfflineSales AS TotalSales
       FROM OnlineSales os
       LEFT JOIN OfflineSales os2 ON os.ProductName = os2.ProductName
    )
    SELECT 
       ProductName,
       OfflineSales,
       OnlineSales,
       ROUND(100.0 * OnlineSales / TotalSales, 2) AS OnlineSalesPercentage
    FROM TotalSales
    ORDER BY OnlineSalesPercentage DESC;
    ```

21. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki tingkat penjualan yang stabil atau konsisten. 
	Buatlah query untuk menampilkan nama produk, rata-rata penjualan per bulan, dan standar deviasi penjualan per bulan.

    Jawaban:
    ```sql
    WITH MonthlyProductSales AS (
       SELECT 
          p.Name AS ProductName,
          MONTH(sod.ModifiedDate) AS SalesMonth,
          SUM(sod.LineTotal) AS MonthlySales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name, MONTH(sod.ModifiedDate)
    ), ProductSalesStats AS (
       SELECT 
          ProductName,
          AVG(MonthlySales) AS AvgMonthlySales,
          STDEV(MonthlySales) AS StdDevMonthlySales
       FROM MonthlyProductSales
       GROUP BY ProductName
    )
    SELECT 
       ProductName,
       AvgMonthlySales,
       StdDevMonthlySales,
       CASE 
          WHEN StdDevMonthlySales / AvgMonthlySales < 0.2 THEN 'Stable'
          ELSE 'Volatile'
       END AS SalesConsistency
    FROM ProductSalesStats
    ORDER BY SalesConsistency, AvgMonthlySales DESC;
    ```

22. Soal:
    Perusahaan ingin mengetahui pola pembelian produk berdasarkan segmen pelanggan. 
	Buatlah query untuk menampilkan nama produk, jumlah pembelian per segmen pelanggan, dan persentase pembelian per segmen.

    Jawaban:
    ```sql
    WITH CustomerPurchases AS (
       SELECT 
          p.Name AS ProductName,
          CASE WHEN c.CustomerType = 'S' THEN 'Individual' ELSE 'Corporate' END AS CustomerSegment,
          COUNT(sod.SalesOrderDetailID) AS TotalPurchases
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name, CASE WHEN c.CustomerType = 'S' THEN 'Individual' ELSE 'Corporate' END
    ), ProductSegmentSummary AS (
       SELECT 
          ProductName,
          CustomerSegment,
          TotalPurchases,
          SUM(TotalPurchases) OVER (PARTITION BY ProductName) AS TotalProductPurchases
       FROM CustomerPurchases
    )
    SELECT 
       ProductName,
       CustomerSegment,
       TotalPurchases,
       ROUND(100.0 * TotalPurchases / TotalProductPurchases, 2) AS SegmentPurchasePercentage
    FROM ProductSegmentSummary
    ORDER BY ProductName, SegmentPurchasePercentage DESC;
    ```

23. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki tingkat penjualan terbaik berdasarkan jumlah penjualan dan pertumbuhan penjualan. 
	Buatlah query untuk menampilkan nama produk, total penjualan tahun 2015, total penjualan tahun 2016, dan persentase pertumbuhan penjualan.

    Jawaban:
    ```sql
    WITH Sales2015 AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS Sales2015
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), Sales2016 AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS Sales2016
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2016-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), SalesGrowth AS (
       SELECT 
          s15.ProductName,
          s15.Sales2015,
          s16.Sales2016,
          ROUND(100.0 * (s16.Sales2016 - s15.Sales2015) / s15.Sales2015, 2) AS SalesGrowthPercentage
       FROM Sales2015 s15
       LEFT JOIN Sales2016 s16 ON s15.ProductName = s16.ProductName
    )
    SELECT 
       ProductName,
       Sales2015,
       Sales2016,
       SalesGrowthPercentage
    FROM SalesGrowth
    ORDER BY SalesGrowthPercentage DESC, Sales2016 DESC;
    ```

24. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi untuk ditingkatkan penjualannya 
	berdasarkan kombinasi antara total penjualan dan pertumbuhan penjualan. Buatlah query untuk menampilkan nama produk, 
	total penjualan, pertumbuhan penjualan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH Sales2015 AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS Sales2015
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), Sales2016 AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS Sales2016
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2016-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), SalesGrowth AS (
       SELECT 
          s15.ProductName,
          s15.Sales2015,
          s16.Sales2016,
          ROUND(100.0 * (s16.Sales2016 - s15.Sales2015) / s15.Sales2015, 2) AS SalesGrowthPercentage
       FROM Sales2015 s15
       LEFT JOIN Sales2016 s16 ON s15.ProductName = s16.ProductName
    ), SalesCategories AS (
       SELECT 
          ProductName,
          Sales2015,
          Sales2016,
          SalesGrowthPercentage,
          CASE 
             WHEN Sales2016 < 1000000 AND SalesGrowthPercentage < 10 THEN 'Low'
             WHEN (Sales2016 >= 1000000 AND Sales2016 < 5000000) OR (SalesGrowthPercentage >= 10 AND SalesGrowthPercentage < 20) THEN 'Medium'
             ELSE 'High'
          END AS SalesGrowthCategory
       FROM SalesGrowth
    )
    SELECT 
       ProductName,
       Sales2015,
       Sales2016,
       SalesGrowthPercentage,
       SalesGrowthCategory
    FROM SalesCategories
    ORDER BY SalesGrowthCategory DESC, Sales2016 DESC;
    ```

25. Soal:
    Perusahaan ingin mengetahui dampak promosi penjualan terhadap pertumbuhan bisnis. Buatlah query untuk menampilkan nama produk, 
	total penjualan sebelum promosi, total penjualan selama promosi, dan persentase perubahan penjualan.

    Jawaban:
    ```sql
    WITH PrePromotionSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(CASE WHEN sod.ModifiedDate < '2015-07-01' THEN sod.LineTotal ELSE 0 END) AS PrePromotionSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), PromotionSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(CASE WHEN sod.ModifiedDate >= '2015-07-01' THEN sod.LineTotal ELSE 0 END) AS PromotionSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2015-01-01' AND '2015-12-31'
       GROUP BY p.Name
    ), SalesImpact AS (
       SELECT 
          ps.ProductName,
          ps.PrePromotionSales,
          prs.PromotionSales,
          ROUND(100.0 * (prs.PromotionSales - ps.PrePromotionSales) / ps.PrePromotionSales, 2) AS SalesChangePercentage
       FROM PrePromotionSales ps
       LEFT JOIN PromotionSales prs ON ps.ProductName = prs.ProductName
    )
    SELECT 
       ProductName,
       PrePromotionSales,
       PromotionSales,
       SalesChangePercentage
    FROM SalesImpact
    ORDER BY SalesChangePercentage DESC;
    ```

26. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi penjualan yang tinggi di masa depan. 
	Buatlah query untuk menampilkan nama produk, total penjualan, pertumbuhan penjualan per tahun, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH YearlySales AS (
       SELECT 
          p.Name AS ProductName,
          YEAR(sod.ModifiedDate) AS SalesYear,
          SUM(sod.LineTotal) AS YearlySales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name, YEAR(sod.ModifiedDate)
    ), SalesGrowth AS (
       SELECT 
          ProductName,
          SUM(YearlySales) AS TotalSales,
          ROUND(100.0 * (MAX(YearlySales) - MIN(YearlySales)) / MIN(YearlySales), 2) AS SalesGrowthPercentage
       FROM YearlySales
       GROUP BY ProductName
    ), SalesCategories AS (
       SELECT 
          ProductName,
          TotalSales,
          SalesGrowthPercentage,
          CASE 
             WHEN TotalSales < 1000000 AND SalesGrowthPercentage < 20 THEN 'Low'
             WHEN (TotalSales >= 1000000 AND TotalSales < 5000000) OR (SalesGrowthPercentage >= 20 AND SalesGrowthPercentage < 50) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM SalesGrowth
    )
    SELECT 
       ProductName,
       TotalSales,
       SalesGrowthPercentage,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

27. Soal:
    Perusahaan ingin mengetahui tren penjualan produk berdasarkan kategori dan subkategori. 
	Buatlah query untuk menampilkan nama kategori, nama subkategori, total penjualan per tahun, dan grafik penjualan per tahun.

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          pc.Name AS CategoryName,
          ps.Name AS SubcategoryName,
          YEAR(sod.ModifiedDate) AS SalesYear,
          SUM(sod.LineTotal) AS TotalSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name, ps.Name, YEAR(sod.ModifiedDate)
    ), YearlySalesTrend AS (
       SELECT 
          CategoryName,
          SubcategoryName,
          SalesYear,
          TotalSales,
          ROW_NUMBER() OVER (PARTITION BY CategoryName, SubcategoryName ORDER BY SalesYear) AS RowNum
       FROM ProductSales
    )
    SELECT 
       CategoryName,
       SubcategoryName,
       SalesYear,
       TotalSales,
       CASE RowNum
          WHEN 1 THEN NULL
          ELSE ROUND(100.0 * (TotalSales - LAG(TotalSales, 1) OVER (PARTITION BY CategoryName, SubcategoryName ORDER BY SalesYear)) / LAG(TotalSales, 1) 
		  OVER (PARTITION BY CategoryName, SubcategoryName ORDER BY SalesYear), 2)
       END AS YearOverYearGrowth
    FROM YearlySalesTrend
    ORDER BY CategoryName, SubcategoryName, SalesYear;
    ```
29. Soal:
    Perusahaan ingin mengetahui wilayah penjualan mana yang memiliki potensi penjualan yang tinggi. 
	Buatlah query untuk menampilkan nama wilayah, total penjualan, pertumbuhan penjualan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH RegionalSales AS (
       SELECT 
          sp.Name AS StateProvinceName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       JOIN Person.Address pa ON soh.BillToAddressID = pa.AddressID
       JOIN Person.StateProvince sp ON pa.StateProvinceID = sp.StateProvinceID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY sp.Name
    ), SalesCategories AS (
       SELECT 
          StateProvinceName,
          TotalSales,
          SalesGrowthPercentage,
          CASE 
             WHEN TotalSales < 5000000 AND SalesGrowthPercentage < 10 THEN 'Low'
             WHEN (TotalSales >= 5000000 AND TotalSales < 20000000) OR (SalesGrowthPercentage >= 10 AND SalesGrowthPercentage < 20) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM RegionalSales
    )
    SELECT 
       StateProvinceName,
       TotalSales,
       SalesGrowthPercentage,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

30. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki penjualan terbaik berdasarkan gabungan antara total penjualan, 
	pertumbuhan penjualan, dan jumlah pelanggan. Buatlah query untuk menampilkan nama produk, total penjualan, pertumbuhan penjualan, jumlah pelanggan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), UniqueCustomers AS (
       SELECT 
          p.Name AS ProductName,
          COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), SalesCategories AS (
       SELECT 
          ps.ProductName,
          ps.TotalSales,
          ps.SalesGrowthPercentage,
          uc.UniqueCustomers,
          CASE 
             WHEN ps.TotalSales < 1000000 AND ps.SalesGrowthPercentage < 20 AND uc.UniqueCustomers < 1000 THEN 'Low'
             WHEN (ps.TotalSales >= 1000000 AND ps.TotalSales < 5000000) OR (ps.SalesGrowthPercentage >= 20 AND ps.SalesGrowthPercentage < 50) 
			 OR (uc.UniqueCustomers >= 1000 AND uc.UniqueCustomers < 5000) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales ps
       LEFT JOIN UniqueCustomers uc ON ps.ProductName = uc.ProductName
    )
    SELECT 
       ProductName,
       TotalSales,
       SalesGrowthPercentage,
       UniqueCustomers,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

31. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi untuk ditingkatkan penjualannya berdasarkan 
	kombinasi antara total penjualan, pertumbuhan penjualan, dan margin keuntungan. Buatlah query untuk menampilkan nama produk, total penjualan, 
	pertumbuhan penjualan, margin keuntungan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), ProductMargin AS (
       SELECT 
          p.Name AS ProductName,
          ROUND(100.0 * (p.ListPrice - p.StandardCost) / p.ListPrice, 2) AS ProfitMargin
       FROM Production.Product p
    ), SalesCategories AS (
       SELECT 
          ps.ProductName,
          ps.TotalSales,
          ps.SalesGrowthPercentage,
          pm.ProfitMargin,
          CASE 
             WHEN ps.TotalSales < 1000000 AND ps.SalesGrowthPercentage < 20 AND pm.ProfitMargin < 30 THEN 'Low'
             WHEN (ps.TotalSales >= 1000000 AND ps.TotalSales < 5000000) OR (ps.SalesGrowthPercentage >= 20 AND ps.SalesGrowthPercentage < 50) 
			 OR (pm.ProfitMargin >= 30 AND pm.ProfitMargin < 50) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales ps
       LEFT JOIN ProductMargin pm ON ps.ProductName = pm.ProductName
    )
    SELECT 
       ProductName,
       TotalSales,
       SalesGrowthPercentage,
       ProfitMargin,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

32. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi penjualan yang tinggi di masa depan dengan 
	memperhitungkan faktor harga jual, biaya produksi, dan jumlah pelanggan. Buatlah query untuk menampilkan nama produk, 
	total penjualan, pertumbuhan penjualan, margin keuntungan, jumlah pelanggan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), UniqueCustomers AS (
       SELECT 
          p.Name AS ProductName,
          COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), ProductMargin AS (
       SELECT 
          p.Name AS ProductName,
          ROUND(100.0 * (p.ListPrice - p.StandardCost) / p.ListPrice, 2) AS ProfitMargin
       FROM Production.Product p
    ), SalesCategories AS (
       SELECT 
          ps.ProductName,
          ps.TotalSales,
          ps.SalesGrowthPercentage,
          pm.ProfitMargin,
          uc.UniqueCustomers,
          CASE 
             WHEN ps.TotalSales < 1000000 AND ps.SalesGrowthPercentage < 20 AND pm.ProfitMargin < 30 AND uc.UniqueCustomers < 1000 THEN 'Low'
             WHEN (ps.TotalSales >= 1000000 AND ps.TotalSales < 5000000) OR (ps.SalesGrowthPercentage >= 20 AND ps.SalesGrowthPercentage < 50) 
			 OR (pm.ProfitMargin >= 30 AND pm.ProfitMargin < 50) OR (uc.UniqueCustomers >= 1000 AND uc.UniqueCustomers < 5000) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales ps
       LEFT JOIN ProductMargin pm ON ps.ProductName = pm.ProductName
       LEFT JOIN UniqueCustomers uc ON ps.ProductName = uc.ProductName
    )
    SELECT 
       ProductName,
       TotalSales,
       SalesGrowthPercentage,
       ProfitMargin,
       UniqueCustomers,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

33. Soal:
    Perusahaan ingin mengetahui tren penjualan produk berdasarkan kategori dan subkategori, 
	serta membandingkan pertumbuhan penjualan antar kategori dan subkategori. Buatlah query untuk menampilkan nama kategori, nama subkategori, total penjualan 
	per tahun, dan grafik perbandingan pertumbuhan penjualan per tahun antar kategori dan subkategori.

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          pc.Name AS CategoryName,
          ps.Name AS SubcategoryName,
          YEAR(sod.ModifiedDate) AS SalesYear,
          SUM(sod.LineTotal) AS TotalSales
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name, ps.Name, YEAR(sod.ModifiedDate)
    ), CategorySalesGrowth AS (
       SELECT 
          CategoryName,
          SalesYear,
          TotalSales,
          ROUND(100.0 * (TotalSales - LAG(TotalSales, 1) OVER (PARTITION BY CategoryName ORDER BY SalesYear)) / LAG(TotalSales, 1) 
		  OVER (PARTITION BY CategoryName ORDER BY SalesYear), 2) AS CategorySalesGrowthPercentage
       FROM ProductSales
    ), SubcategorySalesGrowth AS (
       SELECT 
          CategoryName,
          SubcategoryName,
          SalesYear,
          TotalSales,
          ROUND(100.0 * (TotalSales - LAG(TotalSales, 1) OVER (PARTITION BY CategoryName, SubcategoryName ORDER BY SalesYear)) / LAG(TotalSales, 1) 
		  OVER (PARTITION BY CategoryName, SubcategoryName ORDER BY SalesYear), 2) AS SubcategorySalesGrowthPercentage
       FROM ProductSales
    )
    SELECT 
       cs.CategoryName,
       cs.SubcategoryName,
       cs.SalesYear,
       cs.TotalSales AS SubcategoryTotalSales,
       csg.TotalSales AS CategoryTotalSales,
       cs.SubcategorySalesGrowthPercentage,
       csg.CategorySalesGrowthPercentage
    FROM SubcategorySalesGrowth cs
    LEFT JOIN CategorySalesGrowth csg ON cs.CategoryName = csg.CategoryName AND cs.SalesYear = csg.SalesYear
    ORDER BY cs.CategoryName, cs.SubcategoryName, cs.SalesYear;
    ```

34. Soal:
    Perusahaan ingin mengetahui produk-produk yang memiliki potensi penjualan yang tinggi di masa depan dengan memperhitungkan 
	faktor harga jual, biaya produksi, jumlah pelanggan, dan volume penjualan. Buatlah query untuk menampilkan nama produk, total penjualan, 
	pertumbuhan penjualan, margin keuntungan, jumlah pelanggan, volume penjualan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage,
          SUM(sod.OrderQty) AS TotalQuantitySold
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), UniqueCustomers AS (
       SELECT 
          p.Name AS ProductName,
          COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY p.Name
    ), ProductMargin AS (
       SELECT 
          p.Name AS ProductName,
          ROUND(100.0 * (p.ListPrice - p.StandardCost) / p.ListPrice, 2) AS ProfitMargin
       FROM Production.Product p
    ), SalesCategories AS (
       SELECT 
          ps.ProductName,
          ps.TotalSales,
          ps.SalesGrowthPercentage,
          ps.TotalQuantitySold,
          pm.ProfitMargin,
          uc.UniqueCustomers,
          CASE 
             WHEN ps.TotalSales < 1000000 AND ps.SalesGrowthPercentage < 20 AND pm.ProfitMargin < 30 
			 AND uc.UniqueCustomers < 1000 AND ps.TotalQuantitySold < 10000 THEN 'Low'
             WHEN (ps.TotalSales >= 1000000 AND ps.TotalSales < 5000000) OR (ps.SalesGrowthPercentage >= 20 
			 AND ps.SalesGrowthPercentage < 50) OR (pm.ProfitMargin >= 30 AND pm.ProfitMargin < 50) OR (uc.UniqueCustomers >= 1000 
			 AND uc.UniqueCustomers < 5000) OR (ps.TotalQuantitySold >= 10000 AND ps.TotalQuantitySold < 50000) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales ps
       LEFT JOIN ProductMargin pm ON ps.ProductName = pm.ProductName
       LEFT JOIN UniqueCustomers uc ON ps.ProductName = uc.ProductName
    )
    SELECT 
       ProductName,
       TotalSales,
       SalesGrowthPercentage,
       TotalQuantitySold,
       ProfitMargin,
       UniqueCustomers,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

35. Soal:
    Perusahaan ingin mengetahui kategori produk mana yang memiliki potensi penjualan yang paling tinggi. 
	Buatlah query untuk menampilkan nama kategori, total penjualan, pertumbuhan penjualan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          pc.Name AS CategoryName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name
    ), SalesCategories AS (
       SELECT 
          CategoryName,
          TotalSales,
          SalesGrowthPercentage,
          CASE 
             WHEN TotalSales < 5000000 AND SalesGrowthPercentage < 20 THEN 'Low'
             WHEN (TotalSales >= 5000000 AND TotalSales < 20000000) OR (SalesGrowthPercentage >= 20 AND SalesGrowthPercentage < 50) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales
    )
    SELECT 
       CategoryName,
       TotalSales,
       SalesGrowthPercentage,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

36. Soal:
    Perusahaan ingin mengetahui sub-kategori produk mana yang memiliki potensi penjualan yang paling tinggi 
	berdasarkan total penjualan, pertumbuhan penjualan, dan jumlah pelanggan. Buatlah query untuk menampilkan nama kategori, 
	nama sub-kategori, total penjualan, pertumbuhan penjualan, jumlah pelanggan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          pc.Name AS CategoryName,
          ps.Name AS SubcategoryName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name, ps.Name
    ), UniqueCustomers AS (
       SELECT 
          pc.Name AS CategoryName,
          ps.Name AS SubcategoryName,
          COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name, ps.Name
    ), SalesCategories AS (
       SELECT 
          ps.CategoryName,
          ps.SubcategoryName,
          ps.TotalSales,
          ps.SalesGrowthPercentage,
          uc.UniqueCustomers,
          CASE 
             WHEN ps.TotalSales < 1000000 AND ps.SalesGrowthPercentage < 20 AND uc.UniqueCustomers < 1000 THEN 'Low'
             WHEN (ps.TotalSales >= 1000000 AND ps.TotalSales < 5000000) OR (ps.SalesGrowthPercentage >= 20 
			 AND ps.SalesGrowthPercentage < 50) OR (uc.UniqueCustomers >= 1000 AND uc.UniqueCustomers < 5000) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales ps
       LEFT JOIN UniqueCustomers uc ON ps.CategoryName = uc.CategoryName AND ps.SubcategoryName = uc.SubcategoryName
    )
    SELECT 
       CategoryName,
       SubcategoryName,
       TotalSales,
       SalesGrowthPercentage,
       UniqueCustomers,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

37. Soal:
    Perusahaan ingin mengetahui wilayah penjualan mana yang memiliki potensi penjualan yang tinggi berdasarkan total penjualan, 
	pertumbuhan penjualan, dan jumlah pelanggan. Buatlah query untuk menampilkan nama wilayah, total penjualan, pertumbuhan penjualan, 
	jumlah pelanggan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH RegionalSales AS (
       SELECT 
          sp.Name AS StateProvinceName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       JOIN Person.Address pa ON soh.BillToAddressID = pa.AddressID
       JOIN Person.StateProvince sp ON pa.StateProvinceID = sp.StateProvinceID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY sp.Name
    ), UniqueCustomers AS (
       SELECT 
          sp.Name AS StateProvinceName,
          COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
       FROM Sales.SalesOrderHeader soh
       JOIN Person.Address pa ON soh.BillToAddressID = pa.AddressID
       JOIN Person.StateProvince sp ON pa.StateProvinceID = sp.StateProvinceID
       WHERE soh.OrderDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY sp.Name
    ), SalesCategories AS (
       SELECT 
          rs.StateProvinceName,
          rs.TotalSales,
          rs.SalesGrowthPercentage,
          uc.UniqueCustomers,
          CASE 
             WHEN rs.TotalSales < 5000000 AND rs.SalesGrowthPercentage < 20 AND uc.UniqueCustomers < 1000 THEN 'Low'
             WHEN (rs.TotalSales >= 5000000 AND rs.TotalSales < 20000000) OR (rs.SalesGrowthPercentage >= 20 
			 AND rs.SalesGrowthPercentage < 50) OR (uc.UniqueCustomers >= 1000 AND uc.UniqueCustomers < 5000) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM RegionalSales rs
       LEFT JOIN UniqueCustomers uc ON rs.StateProvinceName = uc.StateProvinceName
    )
    SELECT 
       StateProvinceName,
       TotalSales,
       SalesGrowthPercentage,
       UniqueCustomers,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```

38. Soal:
    Perusahaan ingin mengetahui kombinasi produk-kategori yang memiliki potensi penjualan yang tinggi berdasarkan total penjualan, 
	pertumbuhan penjualan, margin keuntungan, dan jumlah pelanggan. Buatlah query untuk menampilkan nama kategori, nama produk, total penjualan, 
	pertumbuhan penjualan, margin keuntungan, jumlah pelanggan, dan kategori potensi penjualan (Low, Medium, High).

    Jawaban:
    ```sql
    WITH ProductSales AS (
       SELECT 
          pc.Name AS CategoryName,
          p.Name AS ProductName,
          SUM(sod.LineTotal) AS TotalSales,
          ROUND(100.0 * (MAX(sod.LineTotal) - MIN(sod.LineTotal)) / MIN(sod.LineTotal), 2) AS SalesGrowthPercentage
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name, p.Name
    ), UniqueCustomers AS (
       SELECT 
          pc.Name AS CategoryName,
          p.Name AS ProductName,
          COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
       FROM Sales.SalesOrderDetail sod
       JOIN Production.Product p ON sod.ProductID = p.ProductID
       JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
       JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
       JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
       WHERE sod.ModifiedDate BETWEEN '2013-01-01' AND '2016-12-31'
       GROUP BY pc.Name, p.Name
    ), ProductMargin AS (
       SELECT 
          p.Name AS ProductName,
          ROUND(100.0 * (p.ListPrice - p.StandardCost) / p.ListPrice, 2) AS ProfitMargin
       FROM Production.Product p
    ), SalesCategories AS (
       SELECT 
          ps.CategoryName,
          ps.ProductName,
          ps.TotalSales,
          ps.SalesGrowthPercentage,
          pm.ProfitMargin,
          uc.UniqueCustomers,
          CASE 
             WHEN ps.TotalSales < 1000000 AND ps.SalesGrowthPercentage < 20 AND pm.ProfitMargin < 30 
			 AND uc.UniqueCustomers < 1000 THEN 'Low'
             WHEN (ps.TotalSales >= 1000000 AND ps.TotalSales < 5000000) OR (ps.SalesGrowthPercentage >= 20 
			 AND ps.SalesGrowthPercentage < 50) OR (pm.ProfitMargin >= 30 AND pm.ProfitMargin < 50) OR (uc.UniqueCustomers >= 1000 
			 AND uc.UniqueCustomers < 5000) THEN 'Medium'
             ELSE 'High'
          END AS SalesPotentialCategory
       FROM ProductSales ps
       LEFT JOIN ProductMargin pm ON ps.ProductName = pm.ProductName
       LEFT JOIN UniqueCustomers uc ON ps.CategoryName = uc.CategoryName AND ps.ProductName = uc.ProductName
    )
    SELECT 
       CategoryName,
       ProductName,
       TotalSales,
       SalesGrowthPercentage,
       ProfitMargin,
       UniqueCustomers,
       SalesPotentialCategory
    FROM SalesCategories
    ORDER BY SalesPotentialCategory DESC, TotalSales DESC;
    ```
