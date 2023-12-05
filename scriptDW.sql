-- CRIAÇÂO DA DIMENSÂO PRODUTO

DROP TABLE projetointegrador.DimProduct;
CREATE TABLE IF NOT EXISTS projetointegrador.DimProduct(
	product_id INT,
	product_ak UUID, -- rowguid
	product_name VARCHAR(50),
	product_color VARCHAR(50),
	product_subcategory VARCHAR(50), -- production.tabela = productsubcategory
	product_category VARCHAR(50), -- production.tabela = productcategory
	list_price NUMERIC(10,2),
	standard_cost NUMERIC(10,2)
);

INSERT INTO projetointegrador.DimProduct 
(product_id,product_ak, product_name, product_color,list_price,standard_cost, product_subcategory,
 product_category)
(SELECT p.productid,p.rowguid,quote_literal(p.name),quote_literal(p.color),p.listprice,
 p.standardcost,quote_literal(s.name),quote_literal(c.name) 
 FROM production.product p
FULL OUTER JOIN production.productsubcategory s ON p.productsubcategoryid = s.productsubcategoryid
FULL OUTER JOIN production.productcategory c ON s.productcategoryid = c.productcategoryid);

SELECT * from projetointegrador.dimproduct;

--------------------------------------------------
-- DIMENSÂO TERRITORY

DROP TABLE projetointegrador.DimTerritory
CREATE TABLE IF NOT EXISTS projetointegrador.DimTerritory(
	territory_id SERIAL PRIMARY KEY,
	territory_ak UUID, -- rowguid
	territory_name VARCHAR(50),
	territory_country_region_code VARCHAR(3),
	territory_group VARCHAR(50)
);

INSERT INTO projetointegrador.DimTerritory
(territory_id, territory_ak, territory_name, territory_country_region_code,
 territory_group)
(SELECT territoryid,rowguid,quote_literal(name),countryregioncode, "group"
FROM sales.salesterritory);

SELECT * FROM projetointegrador.DimTerritory

--------------------------------------------------
-- DIMENSÂO CUSTOMER

DROP TABLE projetointegrador.DimCustomer
CREATE TABLE IF NOT EXISTS projetointegrador.DimCustomer(
	customer_id SERIAL PRIMARY KEY,	-- humanresources.tabela = Employee
	customer_ak UUID, -- rowguid -- humanresources.tabela = Employee
	customer_birth_date DATE, -- humanresources.tabela = Employee
	customer_marital_status CHAR(1), -- humanresources.tabela = Employee
	customer_gender CHAR(1), -- humanresources.tabela = Employee
	customer_territory_name VARCHAR(50), -- sales.tabela = salesterritory
	territory_country_region_code VARCHAR(3), -- sales.tabela = salesterritory
	territory_group VARCHAR(50) -- sales.tabela = salesterritory
);

INSERT INTO projetointegrador.DimCustomer 
(customer_id,customer_ak, customer_birth_date, customer_marital_status,customer_gender,
 customer_territory_name, territory_country_region_code, territory_group)
(SELECT h.businessentityid,h.rowguid,h.birthdate,h.maritalstatus,h.gender,
st.name, st.countryregioncode, st.group
FROM sales.salesterritory st
FULL OUTER JOIN sales.salesperson sp ON st.territoryid = sp.territoryid
FULL OUTER JOIN humanresources.employee h ON sp.businessentityid = h.businessentityid);

SELECT * FROM projetointegrador.DimCustomer

--------------------------------------------------
-- DIMENSÂO SPECIAL OFFER

DROP TABLE projetointegrador.DimSpecialOffer

CREATE TABLE IF NOT EXISTS projetointegrador.DimSpecialOffer(
	special_offer_id SERIAL PRIMARY KEY,
	special_offer_ak UUID, --rowguid
	special_description VARCHAR(255),
	discount_pct NUMERIC(10,2),
	special_offer_type VARCHAR(50),
	special_offer_category VARCHAR(50),
	special_offer_start_date TIMESTAMP,
	special_offer_end_date TIMESTAMP,
	special_offer_min_qty INT,
	special_offer_max_qty INT
);

INSERT INTO projetointegrador.DimSpecialOffer
(special_offer_id, special_offer_ak, special_description, discount_pct,special_offer_type,
 special_offer_category, special_offer_start_date, special_offer_end_date, special_offer_min_qty,
special_offer_max_qty)
(SELECT specialofferid,rowguid, description, discountpct, "type", category, startdate, enddate,
 minqty, maxqty
FROM sales.specialoffer);

SELECT * FROM projetointegrador.DimSpecialOffer

--------------------------------------------------
-- DIMENSÂO DATE

--Iniciando a dimensão calendario
DROP TABLE projetointegrador.DimDate;
CREATE TABLE IF NOT EXISTS projetointegrador.DimDate(
	Data Date,
	ano INT,
	mes INT,
	diaano INT,
	diames INT,
	semanaano INT,
	semanames INT,
	diasemananome VARCHAR(15),
	mesnome VARCHAR(15),
	trimestre INT
);

SELECT * FROM projetointegrador.DimDate
-- A maior data esta em Birthdate e a menor data esta em specialoffer.enddate
-- Declarando o range de datas

DO $$
DECLARE
    rangeStart DATE := '1951-01-01';
    rangeEnd DATE := '2014-12-31';
    dataContexto DATE;
BEGIN
    dataContexto := rangeStart;

    WHILE dataContexto <= rangeEnd LOOP
        INSERT INTO projetointegrador.DimDate (
            Data,
            ano,
            mes,
            diaano,
            diames,
            semanaano,
            semanames,
            diasemananome,
            mesnome,
            trimestre
        ) VALUES (
            dataContexto,
            EXTRACT(YEAR FROM dataContexto),
            EXTRACT(MONTH FROM dataContexto),
            EXTRACT(DOY FROM dataContexto),
            EXTRACT(DAY FROM dataContexto),
            EXTRACT(WEEK FROM dataContexto),
            EXTRACT(WEEK FROM dataContexto) - EXTRACT(WEEK FROM TO_DATE(TO_CHAR(dataContexto, 'YYYY-MM-01'), 'YYYY-MM-DD')) + 1,
            CASE
                WHEN EXTRACT(DOW FROM dataContexto) = 0 THEN 'Domingo'
                WHEN EXTRACT(DOW FROM dataContexto) = 1 THEN 'Segunda-Feira'
                WHEN EXTRACT(DOW FROM dataContexto) = 2 THEN 'Terça-Feira'
                WHEN EXTRACT(DOW FROM dataContexto) = 3 THEN 'Quarta-Feira'
                WHEN EXTRACT(DOW FROM dataContexto) = 4 THEN 'Quinta-Feira'
                WHEN EXTRACT(DOW FROM dataContexto) = 5 THEN 'Sexta-Feira'
                WHEN EXTRACT(DOW FROM dataContexto) = 6 THEN 'Sábado'
            END,
            CASE
                WHEN EXTRACT(MONTH FROM dataContexto) = 1 THEN 'Janeiro'
                WHEN EXTRACT(MONTH FROM dataContexto) = 2 THEN 'Fevereiro'
                WHEN EXTRACT(MONTH FROM dataContexto) = 3 THEN 'Março'
                WHEN EXTRACT(MONTH FROM dataContexto) = 4 THEN 'Abril'
                WHEN EXTRACT(MONTH FROM dataContexto) = 5 THEN 'Maio'
                WHEN EXTRACT(MONTH FROM dataContexto) = 6 THEN 'Junho'
                WHEN EXTRACT(MONTH FROM dataContexto) = 7 THEN 'Julho'
                WHEN EXTRACT(MONTH FROM dataContexto) = 8 THEN 'Agosto'
                WHEN EXTRACT(MONTH FROM dataContexto) = 9 THEN 'Setembro'
                WHEN EXTRACT(MONTH FROM dataContexto) = 10 THEN 'Outubro'
                WHEN EXTRACT(MONTH FROM dataContexto) = 11 THEN 'Novembro'
                WHEN EXTRACT(MONTH FROM dataContexto) = 12 THEN 'Dezembro'
            END,
            CASE
                WHEN EXTRACT(MONTH FROM dataContexto) IN (1, 2, 3) THEN 1
                WHEN EXTRACT(MONTH FROM dataContexto) IN (4, 5, 6) THEN 2
                WHEN EXTRACT(MONTH FROM dataContexto) IN (7, 8, 9) THEN 3
                WHEN EXTRACT(MONTH FROM dataContexto) IN (10, 11, 12) THEN 4
            END
        );

        dataContexto := dataContexto + INTERVAL '1 day';
    END LOOP;
END $$;

--------------------------------------------------
-- FATO INTERNET SALES

DROP TABLE projetointegrador.FactInternetSales
CREATE TABLE IF NOT EXISTS projetointegrador.FactInternetSales(
	sales_order_id SERIAL PRIMARY KEY,
	product_id INT,
	product_name VARCHAR(50),
	custumer_id INT,
	customer_marital_status CHAR(1),
	customer_gender CHAR(1),
	territory_id INT,
	territory_name VARCHAR(50),
	special_offer_id INT,
	special_offer_type VARCHAR(50),
	special_offer_category VARCHAR(50),
	sales_order_ak UUID,
	order_date TIMESTAMP,
	due_date TIMESTAMP,
	ship_date TIMESTAMP,
	subtotal NUMERIC(10,2), 
	order_qty INT, 
	unit_price NUMERIC(10,2), 
	unit_price_discount NUMERIC(10,2)
);

INSERT INTO projetointegrador.FactInternetSales
(product_id, product_name, 
 custumer_id, customer_marital_status, customer_gender,
 territory_id, territory_name, 
 special_offer_id, special_offer_type, special_offer_category,
 sales_order_ak, order_date, due_date, ship_date, subtotal, order_qty, unit_price,unit_price_discount)
 (SELECT DISTINCT p.productid, p.name, 
  e.businessentityid, e.maritalstatus, e.gender,
  st.territoryid, st.name,
  sod.specialofferid, sof.type, sof.category,
 so.rowguid, so.orderdate, so.duedate, so.shipdate, so.subtotal, sod.orderqty, sod.unitprice,
 sod.unitpricediscount
 FROM sales.salesorderheader so
JOIN sales.salesorderdetail sod ON sod.salesorderid = so.salesorderid
JOIN sales.salesterritory st ON st.territoryid = so.territoryid 
JOIN sales.salesperson sp ON sp.territoryid = st.territoryid
JOIN humanresources.employee e ON e.businessentityid = sp.businessentityid
JOIN sales.specialofferproduct sop ON sop.specialofferid = sod.specialofferid
JOIN sales.specialoffer sof ON sof.specialofferid = sop.specialofferid
JOIN production.product p ON p.productid = sop.productid);

SELECT * FROM projetointegrador.FactInternetSales  LIMIT 500
SELECT COUNT(*) FROM projetointegrador.FactInternetSales
SELECT sales_order_ak, count(sales_order_ak) as countagem FROM projetointegrador.FactInternetSales
GROUP BY sales_order_ak LIMIT 100

-- 57.015.775 registros JOIN
-- 57.016.283 registros FULL OUTER JOIN
-- 52.202.649 registros unicos utilizando SELECT DISTINC

------------------------------------------
-- EXPORTANDO TABELAS

-- NO TERMINAL DIGITE OS SEGUINTES COMANDOS:

-- psql -h localhost -U postgres -d Adventureworks

-- SET search_path TO projetointegrador;

-- SUBSTITUIR CAMINHO PELO USUARIO DO COMPUTADOR
 
COPY projetointegrador.FactInternetSales TO 
'C:\Users\usuario\AppData\Local\Temp\dimdate.csv' CSV HEADER;

COPY projetointegrador.FactInternetSales TO 
'C:\Users\usuario\AppData\Local\Temp\dimspecialoffer.csv' CSV HEADER;

COPY projetointegrador.FactInternetSales TO 
'C:\Users\usuario\AppData\Local\Temp\dimcustumer.csv' CSV HEADER;

COPY projetointegrador.FactInternetSales TO 
'C:\Users\usuario\AppData\Local\Temp\dimterritory.csv' CSV HEADER;

COPY projetointegrador.FactInternetSales TO 
'C:\Users\usuario\AppData\Local\Temp\dimproduct.csv' CSV HEADER;
 
COPY projetointegrador.FactInternetSales TO 
'C:\Users\usuario\AppData\Local\Temp\factinternetsales.csv' CSV HEADER;

------------------------------------------------
-- TESTE DE AMOSTRA


-- AMOSTRA SIMPLES

-- SELECT * FROM projetointegrador.DimProduct
-- ORDER BY RANDOM()
-- LIMIT 1849;


-- AMOSTRA ESTRATIFICADA
-- select territory_name from projetointegrador.FactInternetSales group by territory_name
-- 10 territórios

WITH strata AS (
  SELECT *, NTILE(10) OVER (ORDER BY territory_name) AS stratum
  FROM projetointegrador.FactInternetSales
), samples AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY stratum ORDER BY random()) AS row_num
  FROM strata
)
SELECT * FROM samples WHERE row_num <= 1849;

-- DIGITAR NO TERMINAL
\copy (WITH strata AS (SELECT *, NTILE(10) OVER (ORDER BY territory_name) AS stratum FROM projetointegrador.FactInternetSales), samples AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY stratum ORDER BY random()) AS row_num FROM strata)SELECT * FROM samples WHERE row_num <= 1849) TO 'C:\\Users\\usuario\\AppData\\Local\\Temp\\amostra_fato_estratificada.csv' WITH CSV HEADER;