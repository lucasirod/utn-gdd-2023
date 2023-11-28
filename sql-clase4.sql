

/*----------------------OPERADORES DE CONJUNTOS---------------------------------

UNION:				UNION / UNION ALL

Las columnas de las tablas que uno tienen que ser del mismo tipo y tener la misma cantidad de columnas

INTERSECCION:		INTERSECT



RESTA:				EXCEPT / MINUS (Segun motor)

LA CANTIDAD DE COLUMNAS RESULTANTES NO VARIAN, SOLO CAMBIAN LAS FILAS

*/


-- Consulta 46
--los que compraron en 2011 y en 2012
SELECT DISTINCT c.* FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2011
--39 filas

INTERSECT

SELECT DISTINCT c.* FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2012
--66 filas

ORDER BY clie_razon_social-- el order se hace al final del operador de conjunto

--La interseccion sera máximo 39 filas


-- Consulta 47
--clientes que compraron en 2011 y no compraron en 2012
SELECT DISTINCT c.* FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2011
EXCEPT
SELECT DISTINCT c.* FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2012
ORDER BY c.clie_razon_social

-- Consulta 48
-- los que compraron en 2011 mas de 15 veces o en 2012 mas de 30 veces
SELECT c.clie_codigo, c.clie_razon_social FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2011
GROUP BY c.clie_codigo, c.clie_razon_social
HAVING COUNT(*) > 15
UNION
SELECT c.clie_codigo, c.clie_razon_social FROM Cliente c INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY c.clie_codigo, c.clie_razon_social
HAVING COUNT(*) > 30
ORDER BY c.clie_razon_social

-- Consulta 49
SELECT c.clie_razon_social AS nombre, c.clie_telefono AS Telefono FROM Cliente c 
UNION ALL
-- relleno el segundo campo con nulo para que se pueda unir
SELECT CONCAT(e.empl_apellido, ',', SPACE(1), e.empl_nombre) AS nombre, NULL  FROM empleado e 
ORDER BY 1

-- Consulta 50
SELECT Meses.Mes as Mes, ISNULL(SUM(f.fact_total),0) as Total 
FROM 
(SELECT 1 as Mes 
UNION SELECT 2 AS Mes
UNION SELECT 3 AS Mes
UNION SELECT 4 AS Mes
UNION SELECT 5 AS Mes
UNION SELECT 6 AS Mes
UNION SELECT 7 AS Mes
UNION SELECT 8 AS Mes
UNION SELECT 9 AS Mes
UNION SELECT 10 AS Mes
UNION SELECT 11 AS Mes
UNION SELECT 12 AS Mes) AS Meses
--meses lo pongo como tabla dominante de facturas
LEFT OUTER JOIN Factura f ON Meses.Mes = MONTH(f.fact_fecha) AND YEAR(f.fact_fecha) = 2010
GROUP BY Meses.Mes
ORDER BY Meses.Mes
--tengo 12 filas una por cada mes, si no hay facturas en algun mes en 2010 me devolvera cero


-- Consulta 51
--CUANDO USO TOP CON UNION TENGO QUE RESPETAR LA PRECEDENCIA CON PARENTESIS
SELECT * FROM cliente 
WHERE clie_codigo IN (
--primeros 5 del alfabeto
SELECT TOP 5 clie_codigo FROM cliente ORDER BY clie_razon_social
)
UNION
SELECT * FROM cliente 
WHERE clie_codigo IN (
--ultimos 5 del alfabeto
SELECT TOP 5 clie_codigo FROM cliente ORDER BY clie_razon_social DESC
)
ORDER BY clie_razon_social


----------- DEVOLVER UN VALOR QUE ENUMERE LAS FILAS -----------------


-- Consulta 52

SELECT ROW_NUMBER() OVER (ORDER BY p.prod_familia, p.prod_codigo) AS orden,
p.prod_codigo, p.prod_detalle, p.prod_familia, f.fami_detalle 
FROM Producto p 
INNER JOIN Familia f ON p.prod_familia = f.fami_id 

-- Consulta 53
SELECT * FROM (
SELECT ROW_NUMBER() OVER (ORDER BY p.prod_familia, p.prod_codigo) AS orden,
p.prod_codigo, p.prod_detalle, p.prod_familia, f.fami_detalle 
FROM Producto p 
INNER JOIN Familia f ON p.prod_familia = f.fami_id 
) SS 
WHERE orden BETWEEN 10 AND 15

-- Consulta 54
-- Con la particion en algun momento dado arranco de cero la cuenta del row_number (cada vez que cambie la familia arrancame de cero)
SELECT p.prod_familia, f.fami_detalle, ROW_NUMBER() OVER (PARTITION BY p.prod_familia ORDER BY p.prod_codigo) AS orden, 
p.prod_codigo ,p.prod_detalle 
FROM Producto p
INNER JOIN Familia f ON p.prod_familia = f.fami_id 




/*
10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo.
*/


--LOS 10 MAS VENDIDOS (pero falta unir con 10 menos vendidos)
SELECT TOP 10 p.prod_codigo, p.prod_detalle, sum(i.item_cantidad) as cantidad_vendida, (
	-- cliente que mas unidades compro del producto
	SELECT top 1 C2.clie_razon_social
	FROM Item_Factura I2 
	INNER JOIN Factura F2 ON f2.fact_tipo=i2.item_tipo and f2.fact_sucursal=I2.item_sucursal and f2.fact_numero=i2.item_numero
	INNER JOIN Cliente C2 ON F2.fact_cliente=C2.clie_codigo
	WHERE I2.item_producto = p.prod_codigo
	GROUP BY C2.clie_codigo,C2.clie_razon_social
	ORDER BY sum(i2.item_cantidad) DESC
) as cliente_que_mas_compro
FROM Producto P
INNER JOIN Item_Factura I on i.item_producto=p.prod_codigo
GROUP BY p.prod_codigo, p.prod_detalle
order by sum(i.item_cantidad) desc


-- SOLUCION CON LOS 10 MAS VENDIDOS Y LOS 10 MENOS VENDIDOS
SELECT p.prod_codigo, p.prod_detalle, (

	-- cliente que mas unidades compro del producto
	SELECT top 1 F2.fact_cliente
	FROM Item_Factura I2 
	INNER JOIN Factura F2 ON f2.fact_tipo=i2.item_tipo and f2.fact_sucursal=I2.item_sucursal and f2.fact_numero=i2.item_numero
	WHERE I2.item_producto = p.prod_codigo
	GROUP BY F2.fact_cliente
	ORDER BY sum(i2.item_cantidad) DESC

) AS cliente_que_mas_compro
FROM Producto P
WHERE P.prod_codigo IN (

	-- Codigo de 10 productos mas vendidos
	SELECT TOP 10 p.prod_codigo
	FROM Producto P
	INNER JOIN Item_Factura I on i.item_producto=p.prod_codigo
	GROUP BY p.prod_codigo, p.prod_detalle
	order by sum(i.item_cantidad) desc

) or P.prod_codigo IN(
	
	-- Codigo de 10 productos menos vendidos
	SELECT TOP 10 p.prod_codigo
	FROM Producto P
	INNER JOIN Item_Factura I on i.item_producto=p.prod_codigo
	GROUP BY p.prod_codigo, p.prod_detalle
	order by sum(i.item_cantidad) ASC

)



-- Solucion del profe con UNION
SELECT p.prod_codigo, p.prod_detalle
,(SELECT TOP 1 f.fact_cliente FROM Factura f JOIN item_factura it ON it.item_numero = f.fact_numero 
AND it.item_sucursal = f.fact_sucursal AND it.item_tipo = f.fact_tipo WHERE it.item_producto = p.prod_codigo
GROUP BY f.fact_cliente ORDER BY SUM(item_cantidad) DESC) AS cliente,
'Menos Vendidos' AS Rango
FROM producto p 
WHERE p.prod_codigo IN (SELECT TOP 10 item_producto FROM item_factura GROUP BY item_producto ORDER BY SUM(item_cantidad))
UNION ALL
SELECT p.prod_codigo, p.prod_detalle
,(SELECT TOP 1 f.fact_cliente FROM Factura f JOIN item_factura it ON it.item_numero = f.fact_numero 
AND it.item_sucursal = f.fact_sucursal AND it.item_tipo = f.fact_tipo WHERE it.item_producto = p.prod_codigo
GROUP BY f.fact_cliente ORDER BY SUM(item_cantidad) DESC) AS cliente,
'Mas Vendidos' AS Rango
FROM producto p 
WHERE p.prod_codigo IN (SELECT TOP 10 item_producto FROM item_factura GROUP BY item_producto ORDER BY SUM(item_cantidad) DESC)



/*
11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.
*/

SELECT fam.fami_detalle, 
COUNT(distinct p.prod_codigo) as Cantidad_dif_de_productos, 
--Suponiendo que el monto sin impuestos es fact-total - fact-total-impuestos
--SUM(fac.fact_total - fac.fact_total_impuestos) as Monto_sin_impuestos
--Suponiendo que el monto sin impuestos es cant*precio
SUM(i.item_cantidad * i.item_precio) as Monto_sin_impuestos
FROM Item_Factura I
INNER JOIN Producto P on i.item_producto=p.prod_codigo
INNER JOIN Familia Fam on Fam.fami_id=p.prod_familia
INNER JOIN Factura Fac on fac.fact_tipo=i.item_tipo and fac.fact_sucursal=i.item_sucursal and fac.fact_numero=i.item_numero
WHERE fam.fami_id IN (
	--familias que tuvieron una venta superior a 20000 pesos para el año 2012
	SELECT fam2.fami_id
	FROM Item_Factura I2
	INNER JOIN Producto P2 on i2.item_producto=p2.prod_codigo
	INNER JOIN Familia Fam2 on Fam2.fami_id=p2.prod_familia
	INNER JOIN Factura Fac2 on fac2.fact_tipo=i2.item_tipo and fac2.fact_sucursal=i2.item_sucursal and fac2.fact_numero=i2.item_numero
	WHERE YEAR(fac2.fact_fecha) = '2012'
	group by fam2.fami_id, fam2.fami_detalle
	HAVING SUM(i2.item_cantidad * i2.item_precio) > '20000'
)
group by fam.fami_id, fam.fami_detalle
order by count(distinct p.prod_codigo) desc


-- SOLUCION DEL PROFE
SELECT f.fami_detalle, COUNT(DISTINCT(p.prod_codigo)) AS [productos_vendidos], SUM(it.item_precio*it.item_cantidad) AS [venta] 
FROM familia f
INNER JOIN producto p ON p.prod_familia = f.fami_id
INNER JOIN item_factura it ON it.item_producto = p.prod_codigo
GROUP BY f.fami_id, f.fami_detalle
HAVING f.fami_id IN (
	SELECT p.prod_familia FROM producto p 
	INNER JOIN item_factura it ON it.item_producto = p.prod_codigo
	INNER JOIN factura f ON it.item_numero = f.fact_numero AND it.item_tipo = f.fact_tipo 
	AND it.item_sucursal = f.fact_sucursal 
	WHERE YEAR(f.fact_fecha) = 2012
	GROUP BY p.prod_familia
	HAVING SUM(it.item_precio*it.item_cantidad) > 20000
)
ORDER BY 2 DESC


/*
12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.
*/

SELECT p.prod_detalle, 
count(distinct fac.fact_cliente) as cant_compradores, 
--MI MANERA:
--AVG(i.item_precio) as precio_prom,
--MANERA DEL PROFE:  
SUM(item_cantidad * item_precio) / SUM(item_cantidad) as precio_prom,
(
	-- cantidad de depositos en los que hay stock de p.prod_codigo
	SELECT COUNT(distinct d.depo_codigo)
	FROM Stock S
	inner join DEPOSITO D on s.stoc_deposito=d.depo_codigo
	where  s.stoc_cantidad > 0 and s.stoc_producto = p.prod_codigo
	 
) as cantidad_depositos_stock,
(
	--stock actual del producto en todos los depositos
	SELECT ISNULL(SUM(s2.stoc_cantidad),0)
	FROM Stock S2
	inner join DEPOSITO D2 on s2.stoc_deposito=d2.depo_codigo
	where  s2.stoc_cantidad > 0 and s2.stoc_producto = p.prod_codigo

) as stock_todos_depos
FROM Item_Factura I
INNER JOIN Producto P on i.item_producto=p.prod_codigo
INNER JOIN Factura Fac on fac.fact_tipo=i.item_tipo and fac.fact_sucursal=i.item_sucursal and fac.fact_numero=i.item_numero
where YEAR(fac.fact_fecha) = '2012'
GROUP BY P.prod_codigo,p.prod_detalle
ORDER BY SUM(I.item_cantidad * I.item_precio) DESC 
--OJO, No confundir cantidad vendida (I.item_cantidad) con monto total (I.item_cantidad * I.item_precio)


-- SOLUCION DEL PROFESOR
SELECT p.prod_detalle, SUM(item_cantidad * item_precio) / SUM(item_cantidad) AS [importe promedio], 
COUNT(*) AS [cantidad de clientes],
(
SELECT COUNT(DISTINCT s.stoc_deposito) 
FROM stock s 
WHERE s.stoc_cantidad > 0 AND s.stoc_producto = p.prod_codigo
) AS [cantidad de depositos],
(
SELECT ISNULL(SUM(s.stoc_cantidad),0) 
FROM stock s 
WHERE s.stoc_cantidad > 0 AND s.stoc_producto = p.prod_codigo
) AS [stock actual]
FROM Producto p
INNER JOIN Item_Factura i on  i.item_producto = p.prod_codigo
INNER JOIN Factura f on f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY p.prod_codigo, p.prod_detalle
ORDER BY SUM(i.item_precio * i.item_cantidad) DESC



/*
13. Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.
*/
-- precioUnitComp1 * cantComp1 + precioUnitComp2 * cantComp2


SELECT P.prod_detalle,
P.prod_precio,
SUM(P2.prod_precio * C.comp_cantidad) AS sumatoria_precios_cant
FROM Composicion C
INNER JOIN Producto P on C.comp_producto = P.prod_codigo --el producto
INNER JOIN Producto P2 on C.comp_componente = p2.prod_codigo --el componente
GROUP BY P.prod_codigo, P.prod_detalle, P.prod_precio
-- HAVING COUNT(*) > 2 -> MAAAAl porque los componentes pueden tener mas de una unidad
-- ORDER BY COUNT(*) DESC
-- un producto con dos componentes pero tienen cant 1u y 2u son 3 productos que lo componen
-- CONCLUSION: Es con el SUM porque dice productos, NO productos distintos.
HAVING SUM(C.comp_cantidad) > 2 --OK
ORDER BY SUM(C.comp_cantidad) DESC



/*
14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna
*/


SELECT c.clie_codigo,
-- Aca usamos el concat porque la clave es triple y el distinct solo me deja un campo
count(distinct concat(f.fact_tipo,f.fact_sucursal,f.fact_numero)) as Cant_facturas,
avg(f.fact_total) as Prom_compra,
count(distinct i.item_producto) as Productos_dif,
max(f.fact_total) as Mayor_compra
FROM Item_Factura I
INNER JOIN Factura F on f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
INNER JOIN Cliente C on f.fact_cliente=C.clie_codigo
WHERE YEAR(F.fact_fecha) = YEAR(GETDATE())
group by c.clie_codigo
order by count(distinct concat(f.fact_tipo,f.fact_sucursal,f.fact_numero)) desc



--SOLUCION DEL PROFESOR TENIENDO EN CUENTA TODOS LOS CLIENTES (Habra campos nulos)
SELECT c.clie_codigo,
count(distinct concat(f.fact_tipo,f.fact_sucursal,f.fact_numero)) as Cant_facturas,
avg( ISNULL(f.fact_total,0)/*para cuando es nulo*/ ) as Prom_compra,
count(distinct i.item_producto) as Productos_dif,
max( ISNULL(f.fact_total,0)/*para cuando es nulo*/ ) as Mayor_compra
FROM  Cliente C
LEFT OUTER JOIN Factura F on f.fact_cliente=C.clie_codigo AND YEAR(F.fact_fecha) = YEAR(GETDATE())
LEFT OUTER JOIN Item_Factura I on f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
group by c.clie_codigo
order by count(distinct concat(f.fact_tipo,f.fact_sucursal,f.fact_numero)) desc

-- La condicion se la pongo en el join y no en el where porque:

-- CASO 1: 
-- Primero filtra las facturas de 2017
-- Despues me hace el left join con la tabla dominante cliente

SELECT *
FROM  Cliente C
LEFT OUTER JOIN Factura F on f.fact_cliente=C.clie_codigo AND YEAR(F.fact_fecha) = '2017'

-- CASO 2:
-- Primero hace el left join de cliente dominante con factura dominada
-- Despues filtra por año 2017

SELECT *
FROM  Cliente C
LEFT OUTER JOIN Factura F on f.fact_cliente=C.clie_codigo
WHERE YEAR(F.fact_fecha) = '2017'