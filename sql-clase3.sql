


-- Consulta 33
SELECT * 
FROM cliente c LEFT OUTER JOIN Factura f --la tabla de cliente sera la dominante
ON c.clie_codigo = f.fact_cliente

-- Consulta 34
SELECT c.clie_codigo, c.clie_razon_social, SUM(ISNULL(f.fact_total,0)) AS [Total facturado]
FROM cliente c LEFT OUTER JOIN Factura f
ON c.clie_codigo = f.fact_cliente 
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
GROUP BY c.clie_codigo, c.clie_razon_social
ORDER BY 3 DESC, 2


------------------ ORDEN EN FILTRADO CON JOINS -----------------

-- Consulta 35

-- CASO ERRONEO - filtro DESPUES de join
-- Si yo quiero filtrar por las facturas de 2012, si hago primero el LEFT OUTER JOIN clientes con facturas y despues filtro por 2012: 
-- Si un cliente me compro en 2011 pasara el join pero luego se filtrara, y no es lo que quiero, yo quiero que los que me compraron en el
-- 2012 aparezcan, CON UN CERO, pero que aparezcan (por eso hago left join)
SELECT c.clie_codigo, c.clie_razon_social, SUM(ISNULL(f.fact_total,0)) AS [Total facturado]
FROM cliente c LEFT OUTER JOIN Factura f
ON c.clie_codigo = f.fact_cliente 
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
AND YEAR(F.fact_fecha) = 2012 -- filtro despues del join
GROUP BY c.clie_codigo, c.clie_razon_social
ORDER BY 3 DESC, 2

-- CASO OK - filtro ANTES del join
-- Cambiar el orden. Que primero filtre por el año 2012 y despues filtre con LEFT OUTER JOIN
SELECT c.clie_codigo, c.clie_razon_social, SUM(ISNULL(f.fact_total,0)) AS [Total facturado]
FROM cliente c LEFT OUTER JOIN Factura f
--si lo pongo en el ON, hace primero ese filtro y despues el JOIN 
ON c.clie_codigo = f.fact_cliente AND YEAR(F.fact_fecha) = 2012 
-- despues del JOIN aplica el filtro
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
GROUP BY c.clie_codigo, c.clie_razon_social
ORDER BY 3 DESC, 2



-- Consulta 36
SELECT p.prod_codigo, p.prod_detalle, i.item_cantidad, f.fact_numero, f.fact_fecha  
FROM Producto p 
LEFT OUTER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
LEFT OUTER JOIN factura f ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
AND YEAR(fact_fecha) = 2012
WHERE p.prod_codigo IN ('00000830','00000101')
ORDER BY 5,1



-------------- SUBSELECTS ----------------
-- Es un select adentro de otro. Se pueden poner en el WHERE o HAVING, tambien en el FROM a esa tabla que devuelve.
-- Absorve el contexto del select "padre"

-- SELECT CORRELACIONADOS:
-- Tienen dependencia en el FROM principal, por si solos no se pueden ejecutar. Se pueden poner en WHERE, HAVING, SELECT y ORDER BY
	

-- Consulta 37
SELECT * FROM Factura
WHERE factura.fact_cliente IN (
SELECT clie_codigo FROM Cliente WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
)

-- TOP: Se ejecuta despues del ORDER BY, al final de todo

-- Consulta 38
SELECT TOP 5 * FROM cliente 
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
ORDER BY clie_razon_social 

-- Consulta 39
SELECT * FROM
(SELECT TOP 5 * FROM cliente 
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%') SS -- SI HAGO UN FROM A UN SUBSELECT SI O SI TENGO QUE PONERLE NOMBRE
ORDER BY clie_razon_social 

-- Consulta 40
UPDATE Factura
SET fact_total = (
SELECT SUM(i.item_cantidad * i.item_precio) FROM Item_Factura i WHERE item_tipo = 'A' AND item_sucursal = '0003' AND item_numero = '00096722'
)
WHERE fact_tipo = 'A' AND fact_sucursal = '0003' AND fact_numero = '00096722'

-- Consulta 41
UPDATE Factura
SET fact_total = (SELECT SUM(i.item_cantidad * i.item_precio) FROM Item_Factura i WHERE i.item_tipo = Factura.fact_tipo AND item_sucursal = Factura.fact_sucursal AND item_numero = Factura.fact_numero)
WHERE fact_total IS NULL

-- Consulta 42
SELECT clie_vendedor, MAX(clie_limite_credito) AS clie_limite_credito
FROM Cliente 
WHERE clie_vendedor IS NOT NULL
GROUP BY clie_vendedor 
ORDER BY clie_vendedor

-- Consulta 43
SELECT *
FROM Cliente C1
WHERE clie_vendedor IS NOT NULL
AND clie_limite_credito = (
SELECT MAX(clie_limite_credito) FROM Cliente C2 WHERE C1.clie_vendedor = C2.clie_vendedor
)
ORDER BY clie_vendedor


--------------- EXISTS & NOT EXISTS -------------------
-- Trabajan unicamente con subselects
-- Verdadero si devuelve filas


-- Consulta 44
-- clientes que compraron en 2011 y no compraron en 2012
SELECT DISTINCT c.* 
FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2011
AND NOT EXISTS (SELECT 1 FROM Factura f2 WHERE f2.fact_cliente = c.clie_codigo AND YEAR(f2.fact_fecha) = 2012)
ORDER BY clie_razon_social 

-- Consulta 45
SELECT 
f1.fact_cliente,
SUM(i.item_cantidad) AS Cantidad,
(SELECT SUM(f2.fact_total) FROM Factura F2 WHERE YEAR(f2.fact_fecha) = 2011 AND f2.fact_cliente = f1.fact_cliente) AS Importe
FROM Factura f1 INNER JOIN Item_Factura i ON
f1.fact_tipo = i.item_tipo AND f1.fact_sucursal = i.item_sucursal AND f1.fact_numero = i.item_numero
WHERE YEAR(f1.fact_fecha) = 2011
GROUP BY f1.fact_cliente  
ORDER BY 3




-- EJERCICIOS QUE PODEMOS HACER DESPUES DE ESTA CLASE


/* 3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.
*/


--mal: porque los productos sin stock no se muestran
SELECT  P.prod_codigo,p.prod_detalle,s.stoc_cantidad
FROM Producto P INNER JOIN Stock S ON S.stoc_producto=P.prod_codigo
GROUP BY  P.prod_codigo,p.prod_detalle,s.stoc_cantidad
ORDER BY p.prod_detalle ASC

--OK: se muestran los productos aunque no tengan stock
SELECT  P.prod_codigo,p.prod_detalle,ISNULL(s.stoc_cantidad,0)
FROM Producto P 
LEFT OUTER JOIN Stock S ON P.prod_codigo = S.stoc_producto
GROUP BY  P.prod_codigo,p.prod_detalle,s.stoc_cantidad
ORDER BY p.prod_detalle ASC


/* 4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.
*/


/*
MAL: Ojo aca, con el inner join a Stock lo que estoy haciendo es, los registros que ya tenia (que era la cantidad de productos)
se multiplica por la cantidad de veces que lo tengo en stock. Es decir que la sumatoria no va a decir la 
cantidad de articulos que lo componen, sino la cantidad de articulos que componen toooodo el stock que tenga 
(se multiplica la composicion de un producto por el stock)
*/
SELECT  P.prod_codigo,p.prod_detalle,SUM(ISNULL(C.comp_cantidad,0))
FROM Producto P 
LEFT OUTER JOIN Composicion C ON P.prod_codigo = C.comp_producto
INNER JOIN Stock S ON P.prod_codigo = S.stoc_producto --> maaaaaal
GROUP BY P.prod_codigo,p.prod_detalle


--Sigo pensando para ver el promedio de stock por deposito, llego a un subselect:
SELECT avg(s.stoc_cantidad) FROM Stock S where S.stoc_producto = '00006404'


--Lo inserto en la query correcta
SELECT  P.prod_codigo,p.prod_detalle,SUM(ISNULL(C.comp_cantidad,0)) as componentes, 
(SELECT avg(s.stoc_cantidad) FROM Stock S where S.stoc_producto = P.prod_codigo) as stockProm
FROM Producto P 
LEFT OUTER JOIN Composicion C ON P.prod_codigo = C.comp_producto
GROUP BY P.prod_codigo,p.prod_detalle
HAVING (SELECT avg(s.stoc_cantidad) FROM Stock S where S.stoc_producto = P.prod_codigo) > 100



/*
5: Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
*/

-- ventas 2012 para los productos mostrando lo que me pide
SELECT p.prod_codigo, p.prod_detalle, SUM(i.item_cantidad)
FROM Producto P
INNER JOIN Item_Factura I ON P.prod_codigo=i.item_producto -- PK=FK
INNER JOIN Factura F ON F.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero=i.item_numero --todas PK=FK
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY p.prod_codigo, p.prod_detalle


-- armo la query de ventas de 2011 para un el producto '00010220'
SELECT SUM(i.item_cantidad) as VENTAS_2011
FROM Item_Factura I
INNER JOIN Factura F ON F.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero=i.item_numero --todas PK=FK
WHERE YEAR(f.fact_fecha) = 2011 AND I.item_producto = '00010220'


-- combino ambas querys
SELECT p.prod_codigo, p.prod_detalle, SUM(i.item_cantidad)
FROM Producto P
INNER JOIN Item_Factura I ON P.prod_codigo=i.item_producto -- PK=FK
INNER JOIN Factura F ON F.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero=i.item_numero --todas PK=FK
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY p.prod_codigo, p.prod_detalle
HAVING sum(i.item_cantidad) > ISNULL((

SELECT SUM(i2.item_cantidad) as VENTAS_2011
FROM Item_Factura I2
INNER JOIN Factura F2 ON F2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero=i2.item_numero --todas PK=FK
WHERE YEAR(f2.fact_fecha) = 2011 AND I2.item_producto = P.prod_codigo --EL PRODUCTO DE LA QUERY PADRE

),0) --Le ponemos el isnull porque no puede comparar > a nulo





/*
8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.
*/


SELECT P.prod_detalle, 
MAX(S.stoc_cantidad) as [Stock maximo] , 
count(*) as [Cantidad de depositos en los que esta]
FROM Producto P
INNER JOIN Stock S ON P.prod_codigo = S.stoc_producto
WHERE S.stoc_cantidad > 0
GROUP BY P.prod_codigo, p.prod_detalle
HAVING COUNT(*) = (SELECT COUNT(*) FROM DEPOSITO)




/*
9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.
*/

SELECT s.empl_codigo AS [codigo jefe], e.empl_codigo AS [codigo empleado], 
concat(rtrim(e.empl_apellido),',',rtrim(e.empl_nombre)) AS nombre,
(
SELECT COUNT(*) FROM deposito d WHERE d.depo_encargado = e.empl_codigo OR d.depo_encargado = s.empl_codigo
) as [depositos asignados]
FROM empleado e INNER JOIN empleado s ON e.empl_jefe = s.empl_codigo 


--depositos que el jefe 1 y el empleado 2 tienen asignados:
SELECT * FROM deposito d WHERE d.depo_encargado in(1,2)

--cantidad de depositos que el jefe 1 y el empleado 2 tienen asignados:
SELECT COUNT(*) FROM deposito d WHERE d.depo_encargado in(1,2) --que el empleado sea el 1 o el 2




/*
15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
juntos dichos productos. Los distintos pares no deben retornarse más de una vez.


Ejemplo de lo que retornaría la consulta:
PROD1| DETALLE1			 | PROD2| DETALLE2			 | VECES
_____|___________________|______|____________________|_______
1731 | MARLBORO KS		 | 1718 | PHILIPS MORRIS KS  | 507
1718 | PHILIPS MORRIS KS | 1705 | PHILIPS MORRIS BOX | 10562
*/


--pares de productos que se vendieron juntos mas de 500 veces
SELECT i1.item_producto,p1.prod_detalle, i2.item_producto,p2.prod_detalle,count(*) AS VECES
FROM Item_Factura I1
-- joineo productos de la misma factura, pero pueden ser diferentes
INNER JOIN Item_Factura I2 ON 
I1.item_sucursal=I2.item_sucursal AND I2.item_numero=I1.item_numero AND I1.item_tipo=I2.item_tipo
--traigo ademas los datos de codigo y detalle de cada producto
INNER JOIN Producto P1 on p1.prod_codigo=I1.item_producto
INNER JOIN Producto P2 on p2.prod_codigo=I2.item_producto
--con esto saco la relacion de cada producto con si mismo y todos los inversos (puede ser < o >)
where i1.item_producto<i2.item_producto 
group by i1.item_producto,p1.prod_detalle, i2.item_producto,p2.prod_detalle
--mas de 500 veces
having count(*) > 500
order by count(*)

--el i1.item_producto<i2.item_producto se podria poner en el having y tendría el mismo resultado,
--pero no seria performante porque se tomo el trabajo de agrupar y despues filtras, cuando se podria haber
--ahorrado agrupaciones si se lo ponia en el where




/*
6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.
*/

SELECT ISNULL(SUM(s1.stoc_cantidad),0) FROM stock s1 
	INNER JOIN producto p1 ON s1.stoc_producto = p1.prod_codigo 
	WHERE p1.prod_rubro = '0043' 

SELECT R.rubr_id, r.rubr_detalle,ISNULL(SUM(s.stoc_cantidad),0)
FROM Producto P
INNER JOIN Stock S ON S.stoc_producto=P.prod_codigo
INNER JOIN Rubro R ON R.rubr_id=P.prod_rubro
group by R.rubr_id, r.rubr_detalle


SELECT R.rubr_id, 
r.rubr_detalle, 
(
	--Cantidad de productos de un rubro (R.rubr_id)
	SELECT COUNT(*)
	FROM Producto P2
	INNER JOIN Rubro R2 ON R2.rubr_id=P2.prod_rubro
	WHERE R2.rubr_id = R.rubr_id
) AS Cantidad_productos_del_rubro,
 ISNULL(SUM(S.stoc_cantidad),0) as Stock_del_rubro
FROM Producto P
INNER JOIN Stock S ON S.stoc_producto=P.prod_codigo
INNER JOIN Rubro R ON R.rubr_id=P.prod_rubro
WHERE s.stoc_cantidad > (
	--stock de articulo ‘00000000’ en el depósito ‘00’
	SELECT S2.stoc_cantidad
	FROM Stock S2
	WHERE s2.stoc_producto='00000000' AND s2.stoc_deposito='00'
)
group by R.rubr_id, r.rubr_detalle
-- MAAAAAAAAAAL PORQUE TUVE EN CUENTA EL STOCK DEL RUBRO EN VEZ DEL STOCK DEL PRODUCTO
/*HAVING ISNULL(SUM(s.stoc_cantidad),0) > (
	--stock de articulo ‘00000000’ en el depósito ‘00’
	SELECT S2.stoc_cantidad
	FROM Stock S2
	WHERE s2.stoc_producto='00000000' AND s2.stoc_deposito='00'
)*/



SELECT r.rubr_id, r.rubr_detalle, COUNT(*) AS cantidad, 
(
	SELECT ISNULL(SUM(s1.stoc_cantidad),0) FROM stock s1 
	INNER JOIN producto p1 ON s1.stoc_producto = p1.prod_codigo 
	WHERE p1.prod_rubro = r.rubr_id 
	AND s1.stoc_cantidad > (
		SELECT stoc_cantidad FROM STOCK s2
		WHERE s2.stoc_deposito = '00' AND s2.stoc_producto = '00000000'
		)
) AS stock
FROM rubro R 
INNER JOIN producto p ON r.rubr_id = p.prod_rubro
GROUP BY r.rubr_id, r.rubr_detalle


