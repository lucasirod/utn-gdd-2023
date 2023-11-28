

------------- FUNCIONES DE MOTOR ---------------
-- Reciben parametros y devuelven un valor
-- Se pueden usar en SELECT - ORDER, WHERE - HAVING, GROUP BY y en un nuevo valor de un campo (UPDATE)


-- Consulta 15
-- ISNULL: Si el primer parametro es nulo, devolveme el segundo parametro, sino devolve el mismo
-- Si el campo es numerico, el segundo parametro debe ser el mismo tipo, o sea numerico
SELECT clie_codigo, clie_razon_social, clie_vendedor,
ISNULL(clie_vendedor, 0) AS Vendedor
FROM Cliente 
WHERE clie_limite_credito < 50



------------- FUNCIONES DE MOTOR Y OPERADORES PARA NUMERICOS -------------

-- OPERADORES ARITMETICOS: +,-,*,/

-- Consulta 16
-- ROUND: Redondea el primer parametro con la cantidad de decimales del segundo parametro
SELECT fact_tipo, fact_sucursal, fact_numero, fact_total AS Pesos, 
ROUND(fact_total / 70, 2) AS Dolares 
FROM Factura

-- Consulta 17
-- ABS: Si el parametro es positivo o cero lo deja igual, sino lo hace positivo
select fact_tipo, fact_sucursal, fact_numero, fact_total, fact_total_impuestos,
ABS(fact_total), ABS(fact_total_impuestos)
FROM Factura 
WHERE fact_tipo = 'A' AND fact_sucursal = '0003' AND fact_numero = '00091007'



----------- FUNCIONES DE MOTOR PARA FECHAS -------------------

--	MONTH	devuelve mes (entero)
--	YEAR	devuelve año (entero)
--	DAY		devuelve dia (entero)
-- DATEDIFF(dias meses o años,fecha1,fecha2) => devuelve fecha2-fecha1 en meses, dias o años depende lo q le ponga
-- DATEADD(dias meses o años,fecha1,fecha2) => devuelve fecha2+fecha1 en meses, dias o años depende lo q le ponga

-- Consulta 18
SELECT MONTH(fact_fecha) AS Mes, SUM(fact_total) AS Total --,COUNT(*)
FROM Factura
WHERE YEAR(fact_fecha) = 2011
GROUP BY MONTH(fact_fecha)
HAVING COUNT(*) > 15
ORDER BY MONTH(fact_fecha)

-- Consulta 19
SELECT empl_codigo, empl_nombre, empl_apellido, 
DATEDIFF(YEAR,empl_nacimiento,empl_ingreso) AS edadIngreso -- Edad = ingreso - nacimiento
FROM Empleado 
ORDER BY 4

-- Consulta 20
SELECT fact_fecha, DATEADD(DAY, 45, fact_fecha) -- Le sumo 45 DIAS => fecha +45
FROM Factura WHERE YEAR(fact_fecha) = 2010




----------- FUNCIONES DE MOTOR PARA STRINGS -------------------

--	UPPER		Pasa a mayuscula
--	RTRIM		Saca espacios a la derecha (ya que sino me deja la cantidad de espacios del char, aunque no se completen todos)
--	CONCAT		Concatena strings
--	SPACE		Agrega una cantidad de espacios especifica
--	CHARINDEX	Busca la primera cadena en lo segundo y devuelve el indice donde comienza la cadena. Si no lo encontro devuelve cero.
--	LEN			Longitud de una cadena. El len de cadena vacia devuelve cero, el len de nulo devuelve nulo
--	SUBSTRING(columna,desde el caracter,hasta el caracter)

-- Consulta 21
SELECT CONCAT(RTRIM(UPPER(empl_apellido)),',',SPACE(1),UPPER(empl_nombre)) AS Empleado, empl_tareas, -- APELLIDO, NOMBRE
CHARINDEX('Jefe',empl_tareas)
FROM Empleado

-- Consulta 22
SELECT prod_codigo, prod_detalle
FROM Producto
ORDER BY LEN(prod_detalle) DESC, 1

-- Consulta 23
SELECT prod_codigo, LTRIM(SUBSTRING(prod_detalle,9,42)) AS [Tipo de Linterna]--,prod_detalle
FROM Producto WHERE prod_detalle LIKE 'LINTERNA%'
ORDER BY 2


-------------FUNCIONES DE CONVERSION Y CASTEOS ------------------

--	CONVERT		Convierte a datetime, el 120 es la forma de escribir la forma que quiero
--	CAST		Convierte a otro tipo de dato
--	REPLICATE	Va a replicar el primer parametro tantas veces como lo segundo y se lo pone al tercer valor

-- Consulta 24
UPDATE factura SET fact_fecha = CONVERT(DATETIME,'03-30-2017', 120)
WHERE fact_tipo = 'A' AND fact_sucursal = '0003' AND fact_numero = '00091007'
--antes: 2011-11-08 00:00:00
--despues: 2017-03-30 00:00:00


-- Consulta 25
SELECT fact_numero, CAST(fact_numero AS INT)
FROM Factura 

-- Consulta 26
SELECT fact_tipo, fact_sucursal, fact_numero, fact_total,
CONCAT(REPLICATE('0', 10 - LEN(CAST(fact_total AS VARCHAR))),CAST(fact_total AS VARCHAR))
FROM Factura





----------------- JOIN ENTRE TABLAS -----------------
-- Se ponen en la clausula FROM junto con el ON que significa la clave que voy a relacionar

-- INNER JOIN		Solo deja los que tienen asociacion con la otra tabla. 
-- OUTER JOIN		Elijo tabla dominada y tabla dominante. La tabla dominante si no encuentra registros en la dominada completa con null, no quedan registros sin asociar con la dominada
	-- LEFT OUTER JOIN si la dominante es la izquierda
	-- RIGHT OUTER JOIN si la dominante es la derecha
-- FULL OUTER JOIN	No hay dominada y dominante, todos los registros deben tener asociacion, si no tiene completo con null


-- Consulta 27

-- Esto es producto cartesiano, todos contra todos:::
SELECT *
FROM Producto, Rubro
WHERE Producto.prod_envase = 3

-- Aca solo deja aquellos que prod_rubro = rubr_id
SELECT *
FROM Producto INNER JOIN Rubro
ON Producto.prod_rubro = rubr_id
WHERE Producto.prod_envase = 3


-- Consulta 28
SELECT COUNT(*) as cantidad, rubr_detalle  
FROM Producto p INNER JOIN Rubro r 
ON p.prod_rubro = r.rubr_id
WHERE p.prod_envase = 3
GROUP BY r.rubr_id, r.rubr_detalle 
HAVING COUNT(*) < 3
ORDER BY COUNT(*) DESC, r.rubr_id

-- Consulta 29
SELECT e.empl_codigo, e.empl_apellido, e.empl_nombre, 
CONCAT(RTRIM(j.empl_apellido), ',' , SPACE(1), j.empl_nombre)  AS Supervisor
FROM empleado e INNER JOIN empleado j -- Le pongo alias para diferencias las tablas
ON e.empl_jefe = j.empl_codigo

-- Consulta 30
-- la tabla producto tiene 2192 registros
-- el resultado de la query me da 2189 registros, eso es porque hay 3 registros que tienen rubro en nul o envase en nulo
SELECT p.prod_codigo, p.prod_detalle, p.prod_precio, r.rubr_detalle AS Rubro, e.enva_detalle AS Envase
FROM Producto p
--como tengo 3 tablas necesito 2 inner joins, uno rubro-producto y otro producto-envase
INNER JOIN Rubro r ON p.prod_rubro = r.rubr_id 
INNER JOIN Envases e ON p.prod_envase = e.enva_codigo
ORDER BY 2



-- Consulta 31
SELECT i.*   
FROM Factura f INNER JOIN Item_Factura i ON
--Como estoy joineando una tabla que tiene clave primaria compuesta tengo que involucrar todos los campos
f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
WHERE YEAR(fact_fecha) = 2011
 
  
-- Consulta 32
SELECT Producto.prod_detalle AS Producto, Componente.prod_detalle AS Componente, Composicion.comp_cantidad AS Cantidad 
FROM Composicion
INNER JOIN Producto ON Composicion.comp_producto = Producto.prod_codigo 
INNER JOIN Producto Componente ON Composicion.comp_componente = Componente.prod_codigo  
ORDER BY 1






-- EJERCICIOS QUE PODEMOS HACER DESPUES DE ESTA CLASE


-- Ejercicio 3
-- Realizar una consulta que muestre código de producto, nombre de producto y el stock
-- total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
-- nombre del artículo de menor a mayor.

--2190 en tabla de productos, cuando busque stock total tengo q tener lo mismo
SELECT P.prod_codigo,P.prod_detalle
FROM Producto P
ORDER BY P.prod_detalle

--1373 productos porque hay algunos que no tiene stock y hay algunos que tienen stock en mas de un almacen
SELECT P.prod_codigo,P.prod_detalle
FROM Producto P -- uso producto dominante para traer producto que tenga stock
INNER JOIN stock s ON p.prod_codigo = s.stoc_producto
GROUP BY p.prod_codigo, p.prod_detalle
ORDER BY P.prod_detalle

-- Quiero que si no tiene stock, que me quede el stock en cero pero se muestre, cambio por LEFT OUTER JOIN
SELECT P.prod_codigo,P.prod_detalle,SUM(ISNULL(s.stoc_cantidad,0)) as totalStock
FROM Producto P
LEFT OUTER JOIN stock s ON p.prod_codigo = s.stoc_producto
GROUP BY p.prod_codigo, p.prod_detalle
ORDER BY P.prod_detalle

--Resumen:
	-- tengo 2190 productos en total
	-- tengo 1373 productos con stock en al menos un almacen
	-- al final con left outer join le sumo los que no tienen stock y vuelvo a 2190 productos


-- Ejercicio 2
-- Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
-- cantidad vendida.

SELECT p.prod_codigo,p.prod_detalle, COUNT(I.item_cantidad) as 'Cantidad vendida'
FROM Item_Factura I
INNER JOIN Factura F ON I.item_tipo = F.fact_tipo AND I.item_sucursal = F.fact_sucursal AND I.item_numero = F.fact_numero
INNER JOIN Producto P ON I.item_producto = P.prod_codigo
GROUP BY P.prod_codigo,p.prod_detalle
ORDER BY SUM(i.item_cantidad) desc


-- Ejercicio 7
-- Generar una consulta que muestre para cada artículo código, detalle, mayor precio
-- menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
-- 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
-- stock

SELECT p.prod_codigo, p.prod_detalle, MAX(i.item_precio) AS [mayor precio], MIN(i.item_precio) AS [menor precio],
CONVERT(DECIMAL(6,2),ROUND((MAX(i.item_precio) - MIN(i.item_precio)) * 100 / MIN(i.item_precio),2)) porcentaje
FROM producto p
INNER JOIN item_factura i ON i.item_producto = p.prod_codigo
INNER JOIN STOCK s ON s.stoc_producto = p.prod_codigo
GROUP BY p.prod_codigo, p.prod_detalle
HAVING SUM(ISNULL(s.stoc_cantidad,0)) > 0
