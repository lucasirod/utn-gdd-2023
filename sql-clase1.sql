--CONSULTAS DE CLASE

USE [GD2015C1] 
GO


------------------------ SELECT ----------------------------

-- Consulta 1
-- Trae todos los registros de una tabla
-- *: todas las columnas
SELECT * FROM Cliente


-- Consulta 2
-- Trae solo algunas columnas de una tabla
SELECT clie_codigo, clie_razon_social, clie_telefono, clie_domicilio 
FROM Cliente

-- Consulta 3
-- Elimino duplicados, solo distintos. Todos los datos (incluido el nulo) me los trae solo una vez
SELECT DISTINCT clie_vendedor
FROM Cliente

-- Consulta 4
-- Elimino duplicados agrupando por dos columnas
SELECT DISTINCT fact_cliente, fact_vendedor 
FROM Factura

-- Consulta 5
-- Le cambio nombre a la columna con AS. Si quiero ponerle espacio tengo que ponerlo entre corchetes o comillas.
SELECT clie_razon_social AS [Razon Social], clie_telefono AS Telefono, clie_codigo 
FROM Cliente


-- Consulta 6
-- CASE: Se ponen ciertas condiciones, a la primera que se cumpla devuelve lo que diga THEN. 
-- Si no se cumple sigue a la siguiente
SELECT clie_razon_social AS [Razon Social], clie_telefono AS Telefono, clie_codigo,
CASE WHEN clie_limite_credito < 100 THEN 'Poco'						--Si el limite fuese <100, escribir Poco
	 WHEN clie_limite_credito BETWEEN 100 AND 4000 THEN 'Moderado'	--Si el limite fuese <100 y >400, escribir Moderado
	 WHEN clie_limite_credito > 4000 THEN 'Alto'					--Si el limite fuese >100, escribir Alto
	 END AS Credito, clie_domicilio 
FROM Cliente
-- En este caso las condiciones contemplan todos los casos posibles, si tengo valores que no entran puedo poner un ELSE luego de los WHEN.
	-- ELSE "Valor Inesperado"
-- Si no pongo else y todas dan falsas lo mostraria directo como NULL.



----------------- OPERADORES LÓGICOS Y DE COMPARACIÓN -------------------------------
-- Ponerle una o mas condiciones para filtrar la data

------- OPERADORES LOGICOS
-- AND
-- OR
--Precedencia: el OR es un +, y el AND es un *, el + tiene prioridad sobre el *

-------	OPERADORES DE COMPARACIÓN
-- Trabajan con valores, es decir, NULL = Falso
-- OJOOOO: NO EXISTE EL = NULL o != NULL, dara falso para todos, usar el IS NULL o IS NOT NULL

--	=				igual
--	!=				distinto
--	>=				mayor o igual
--	>				mayor
--	<				menor
--	<=				menor o igual
--	IN				En lista de valores (le paso array con () separador por coma)
--	NOT IN			No esta en lista de valores
--	IS NULL			Si es nulo
--	IS NOT NULL		No es nulo
--	BETWEEN			Entre ciertos valores
--	NOT BETWEEN		No esta entre ciertos valores
--	LIKE			Se ajusta a un patron (para strings)
--	EXISTS			

--:::OPERADOR LIKE:::
-- LIKE( Empieza con , Termina con , Contiene a)
-- %				cualquier cosa
-- _				si o si un caracter y solo un caracter
-- ejemplos
	-- MARCE% :		Empieza con
	-- %MARCE :		Termina con
	-- %MARCE%:		Contiene a
	-- MARCE_ :		Si o si un caracter y solo un caracter siguiente de MARCE


-- Consulta 7
SELECT * FROM Cliente
WHERE clie_codigo != '00000'					--codigo distinto de cero
AND clie_limite_credito BETWEEN 3000 AND 5000	--credito entre 3000 y 5000
AND clie_telefono IS NULL						-- sin telefono
AND clie_vendedor IN (3,4)						-- que este a cargo del vendedor 3 o 4
AND clie_razon_social LIKE '%MAR%'				-- que la razon social contenga la silaba MAR con algo adelante y algo atras

-- Consulta 8
SELECT * FROM Cliente
WHERE clie_razon_social LIKE '%MARISOL%' AND (clie_vendedor = 3 OR clie_vendedor = 7)





----------------------- FUNCIONES SUMARIZADAS --------------------------
-- Para un conjunto de filas devuelve un valor, por eso devuelve una sola fila
-- SE EJECUTAN DESPUES DEL WHERE, GROUP BY O HAVING

-- COUNT(*)					Cuenta todos los registros de una tabla
-- COUNT(campo)				Cantidad de registros donde el campo sea no nulo
-- COUNT(DISTINCT campo)	Cantidad de registros donde el campo sea no nulo, sin duplicados
-- MIN(campo)				Minimo de un campo. Si no hay registros es Nulo
-- MAX(campo)				Maximo de un campo. Si no hay registros es Nulo
-- SUM(campo)				Sumatoria de registros (solo numericos). La cuenta la hace con los que tiene valor, no tiene en cuenta nulo. Dara Nulo si no hay registros con valor
-- AVG(campo)				Promedio de registros (solo numericos). No tiene en cuenta si el campo es nulo para el promedio. Nulo si no hay registros


-- Consulta 9
SELECT COUNT(*) AS Cantidad,									-- cantidad de filas (despues de aplicar el where)
	   COUNT(clie_vendedor) AS Vendedores,						-- cantidad que tienen vendedor
       COUNT(DISTINCT clie_vendedor) AS Vendedores_Distintos,	-- cantidad de vendedores distintos
	   MIN(clie_limite_credito) AS Minimo,						-- credito minimo
	   MAX(clie_limite_credito) AS Maximo,						-- credito maximo
	   AVG(clie_limite_credito) AS Promedio						-- credito promedio
FROM Cliente
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'			-- que no sea consumidor final


-- Consulta 10
SELECT SUM(fact_total) AS [Total Vendido]
FROM Factura





--------- GROUP BY & HAVING ----------------

-- GROUP BY		
	-- Agrupo columnas. CUANDO AGRUPO Y APLICO SUMARIZADAS, SE HACE UN REGISTRO CON UNA SUMARIZADA PARA CADA GRUPO.  
	-- Si agrupo un conjunto vacio de datos, no devuelve nada, y las sumarizadas no se hacen.
-- HAVING
	-- El WHERE eran condiciones para las filas que DESPUES se transformaran en grupos con el GROUP BY
	-- Es como el WHERE pero para filtrar sobre filas ya agrupadas

-- IMPORTANTE::::
-- Una vez que agrupamos por uno o mas campos, pueden usarse en el SELECT solo funciones sumarizadas o datos que fueron agrupados.
-- Esto es porque se "transforma" todo en una sola fila. 

-- Asi como en el WHERE puedo poner condiciones para filtrar los datos de las filas, 
-- en el HAVING puedo poner condiciones para las funciones sumarizadas
-- También puedo filtrar por campos que no muestre

--EJEMPLO
	-- Me traigo los clientes
	SELECT *
	FROM Cliente
	WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
	AND clie_limite_credito between 3500 and 3600


	-- Con el GROUP BY agrupo la cantidad de cada vendedor
	SELECT COUNT(*) AS Cantidad,
		   clie_vendedor
	FROM Cliente
	WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
	AND clie_limite_credito between 3500 and 3600
	GROUP BY clie_vendedor

	-- Si quisiese mostrar la razon social, me da ERROR, porque no la agrupe para mostrarla
	SELECT COUNT(*) AS Cantidad,
		   clie_vendedor,
		   clie_razon_social
	FROM Cliente
	WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
	AND clie_limite_credito between 3500 and 3600
	GROUP BY clie_vendedor --ERRROOOORRR




-- Consulta 11
SELECT COUNT(*) AS Cantidad,
       clie_vendedor
FROM Cliente
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
AND clie_limite_credito between 3500 and 3600
GROUP BY clie_vendedor
-- Hasta aca tenia al vendedor con la cantidad
-- Voy a filtrar eso por los vendedores que el promedio de su credito de menor a 3550
HAVING AVG(clie_limite_credito) < 3550

--Esto anduvo OK porque AVG es una funcion sumarizada y se aplica sobre lo ya agrupado. Si yo hubiese hecho 
	-- HAVING clie_limite_credito < 3550
-- Me tiraba error porque me estoy refiriendo a una sola columna, que no puedo porque cuando agrupe ya perdi esos datos




------------------ ORDENAMIENTO ---------------------
-- Va a ser lo último que se ejecute
-- De las columnas que mostre (LAS DEL SELECT) pongo el ordenamiento ASC o DESC. El orden me dira que se ordena primero.
-- Puedo poner la tabla por su nombre, por alias, por numero de aparicion en el select, etc

-- ORDER BY
	-- DESC		Descendente
	-- ASC		Ascendente (es el default)

-- Si hay nulos, en ascendente van al principio de todo y en descendente al final de todo


-- Consulta 12
SELECT COUNT(*) AS Cantidad,
       clie_vendedor as vendedor
FROM Cliente
WHERE clie_razon_social NOT LIKE 'CONSUMIDOR FINAL%'
AND clie_limite_credito between 3500 and 3600
GROUP BY clie_vendedor
HAVING AVG(clie_limite_credito) < 5550
ORDER BY COUNT(*) DESC, clie_vendedor

-- Consulta 13 
SELECT * FROM cliente 
order by clie_vendedor, clie_limite_credito, clie_codigo



--------- ORDEN DE EJECUCIÓN  ----------------------

-- Primero necesito las columnas a mostrar con todos los registros
	--	1)	SELECT				OBLIGATORIO
	--	2)	FROM				OBLIGATORIO

-- Una vez que se las columnas puedo filtar sobre esos datos
	--	3)	WHERE				OPCIONAL

-- Recien ahora puedo agruparlas por alguna columna
	--	4)	GROUP BY			OPCIONAL

-- Una vez que tengo los grupos hechos, puedo poner una condicion a una funcion de ese grupo
	--	5)	HAVING				OPCIONAL

-- Recien cuando se lo que se va a mostrar puedo ordenar
	--	6)	ORDER BY			OPCIONAL




--------- CREACION DE TABLAS -------------

-- Consulta 14
CREATE table hist_Producto (
prod_codigo char(8), 
total_vendido numeric(15,2)
)



--------- INSERCION, DELETE Y UPDATE DE DATOS EN TABLAS -----------
INSERT INTO Hist_Producto (prod_codigo, total_vendido)
SELECT item_producto, SUM(item_cantidad)
FROM item_factura
GROUP BY item_producto 


--DELETE FROM TABLA
--WHERE columna = 305

--UPDATE tabla SET columna = 'asda'
--WHERE otracolumna = 567


--------- TRANSACCIONES -----------
-- Conjunto de operaciones SQL que se ejecutan atomicamente.
-- Si no defino nada, en SQL cada linea de SQL es considerada una transacción, o se completa todo o no se hace nada.




-- EJERCICIOS QUE PODEMOS HACER DESPUES DE ESTA CLASE


-- Ejercicio 1
-- Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
-- igual a $ 1000 ordenado por código de cliente

SELECT C.clie_codigo AS 'Codigo', C.clie_razon_social AS 'Razon Social'
FROM Cliente C
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo


