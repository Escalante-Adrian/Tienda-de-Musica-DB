-- 1) Listar todos los socios que contengan Peréz en cualquiera de sus apellidos
SELECT *
FROM SOCIOS
WHERE APELLIDO1 like 'Perez'
OR APELLIDO2 like 'Perez';

-- 2) Listar todos los vinilos
SELECT *
FROM COPIAS
WHERE TIPO like 'VIN';

-- 3) Mostrar cuantos dias dura cada prestamo
SELECT ID_SOCIO, DATEDIFF(FECHA_TOPE, FECHA_PRESTAMO) as DIAS
FROM PRESTAMO;

-- 4) Mostrar cuantos dias llevan de retraso los que fueron devueltos tarde
SELECT ID_SOCIO, DATEDIFF(FECHA_TOPE, FECHA_DEVOLUCION) AS diferencia_dias
FROM PRESTAMO
WHERE FECHA_DEVOLUCION IS NOT NULL
AND DATEDIFF(FECHA_TOPE, FECHA_DEVOLUCION) > 0;

-- 5) Listar cuantos albumes hay de cada genero
SELECT GENERO, COUNT(*) AS CANTIDAD
FROM ALBUM
GROUP BY GENERO;

-- 6) Listar cuantas copias hay de cada tipo
SELECT TIPO, COUNT(*) AS CANTIDAD
FROM COPIAS
GROUP BY TIPO;

-- 7) Listar los generos que tienen mas de 3 albumes
SELECT GENERO, COUNT(*) AS CANTIDAD
FROM ALBUM
GROUP BY GENERO
HAVING COUNT(*) > 3;

-- 8) Ordenar a los socios de forma descendente en base al DNI
SELECT DNI, NOMBRE1, APELLIDO1
FROM SOCIOS
ORDER BY DNI DESC;

-- 9) Ordenar a las distribuidoras de forma alfabetica
SELECT NOMBRE_DSTR
FROM DISTRIBUIDORA
ORDER BY NOMBRE_DSTR ASC;

-- 10) Ordenar los albumes en base al año de lanzamiento
SELECT ID_ALBUM AS ID, TITULO, ARTISTA, ANIO
FROM ALBUM
ORDER BY ANIO ASC;

-- 11) Mostrar promedio de precio de las copias
SELECT AVG(PRECIO) AS PROMEDIO_PRECIO
FROM PRESTAMO;

-- 12) Mostrar el promedio de la diferencia de dias entre la fecha del prestamo y el tope
SELECT AVG(DATEDIFF(FECHA_TOPE, FECHA_PRESTAMO))
FROM PRESTAMO;

-- 13) Mostrar la persona con el DNI mas bajo
SELECT MIN(DNI) AS DNI_MAS_BAJO
FROM SOCIOS;

-- 14) Obtener todos los prestamos con el nombre del socio, el album y las fechas de los prestamos
SELECT S.NOMBRE1, S.APELLIDO1, A.TITULO, P.FECHA_PRESTAMO
FROM PRESTAMO P
INNER JOIN SOCIOS S ON P.ID_SOCIO = S.ID_SOCIO
INNER JOIN COPIAS C ON P.ID_COPIA = C.ID_COPIA
INNER JOIN ALBUM A ON C.ALBUM = A.ID_ALBUM;

-- 15) Mostrar album, su genero y el tipo de copia
SELECT A.ID_ALBUM, A.GENERO, T.DESCRIPCION AS TIPO
FROM COPIAS C 
INNER JOIN ALBUM A ON C.ALBUM = A.ID_ALBUM
INNER JOIN TIPO T ON C.TIPO = T.ID_TIPO;

-- 16) Mostrar el album mas antiguo
SELECT *
FROM ALBUM
WHERE ANIO = (
    SELECT MIN(ANIO)
    FROM ALBUM
);

-- 17) Mostrar el dni mas alto y a que persona le pertenece
SELECT NOMBRE1, APELLIDO1, DNI
FROM SOCIOS
WHERE DNI = (
    SELECT MAX(DNI)
    FROM SOCIOS
);

-- 18) Mostrar los socios que tengan una cantidad de dias de prestamo mayor al promedio

SELECT S.ID_SOCIO, NOMBRE1, APELLIDO1, DNI, EMAIL
FROM SOCIOS S
WHERE ID_SOCIO IN (
    SELECT P.ID_SOCIO
    FROM PRESTAMO P
    WHERE DATEDIFF(FECHA_TOPE, FECHA_PRESTAMO) > (
        SELECT AVG(DATEDIFF(FECHA_TOPE, FECHA_PRESTAMO))
        FROM PRESTAMO
    )
);

-- ======= Consultas avanzadas =======

-- Auxiliar para ver las ID
SELECT ID_ALBUM, TITULO FROM ALBUM;
SELECT ID_TIPO, DESCRIPCION FROM TIPO;
SELECT ID_DISTRIBUIDORA, NOMBRE_DSTR FROM DISTRIBUIDORA;
SELECT ID_ESTADO, DESCRIPCION FROM ESTADO;

-- Ver las copias que estan disponibles
SELECT C.ID_COPIA, A.TITULO, C.ESTADO
FROM COPIAS C
LEFT JOIN PRESTAMO P ON C.ID_COPIA = P.ID_COPIA AND P.FECHA_DEVOLUCION IS NULL
JOIN ALBUM A ON C.ALBUM = A.ID_ALBUM
WHERE P.ID_COPIA IS NULL;

-- Agregar socio - Ingresar en el formato: Nom1, Nom2, Ape1, Ape2, DNI, EMAIL, TELEFONO, Calle, Numero y Cod Postal

DELIMITER //

CREATE PROCEDURE AgregarSocio (
    IN p_nombre1 VARCHAR(50),
    IN p_nombre2 VARCHAR(50),
    IN p_apellido1 VARCHAR(50),
    IN p_apellido2 VARCHAR(50),
    IN p_dni INT,
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_calle VARCHAR(100),
    IN p_numero VARCHAR(5),
    IN p_cod_postal VARCHAR(6)
)

BEGIN
    INSERT INTO SOCIOS (NOMBRE1, NOMBRE2, APELLIDO1, APELLIDO2, DNI, EMAIL, TELEFONO, CALLE, NUMERO, COD_POSTAL)
    VALUES (p_nombre1, p_nombre2, p_apellido1, p_apellido2, p_dni, p_email, p_telefono, p_calle, p_numero, p_cod_postal);
END //

DELIMITER ;

-- Ejemplo de agregar socio
CALL AgregarSocio('Adrian', 'Ariel', 'Escalante', NULL, 48678090, 'adrianescalante778@gmail.com', '1136649632','General Cesar Diaz', '4527', '1407');

-- Agregar copia
DELIMITER //

CREATE PROCEDURE AgregarCopia(
    IN p_tipo VARCHAR(3),
    IN p_album INT,
    IN p_distribuidora INT,
    IN p_estado VARCHAR(3),
    IN p_observaciones VARCHAR(255)
)
BEGIN
    INSERT INTO COPIAS (TIPO, ALBUM, DISTRIBUIDORA, ESTADO, OBSERVACIONES)
    VALUES (p_tipo, p_album, p_distribuidora, p_estado, p_observaciones);
END //

DELIMITER ;

-- Ejemplo AgregarCopia
CALL AgregarCopia('DVD', 5, 2, 'REG', NULL);

-- Realizar prestamo
DELIMITER //

CREATE PROCEDURE AgregarPrestamo(
    IN p_fecha_prestamo DATE,
    IN p_fecha_devolucion DATE,
    IN p_fecha_tope DATE,
    IN p_precio DECIMAL(6,2),
    IN p_observaciones VARCHAR(255),
    IN p_id_socio INT,
    IN p_id_copia INT
)
BEGIN
    INSERT INTO PRESTAMO (FECHA_PRESTAMO, FECHA_DEVOLUCION, FECHA_TOPE, PRECIO,OBSERVACIONES, ID_SOCIO, ID_COPIA)
    VALUES (p_fecha_prestamo, p_fecha_devolucion, p_fecha_tope, p_precio, p_observaciones, p_id_socio, p_id_copia);
END //

DELIMITER ;

-- Prueba
CALL AgregarPrestamo('2025-11-02', NULL, '2025-11-07', 1700, NULL, 31, 8);


-- Devolver el prestamo

DELIMITER //

CREATE PROCEDURE DevolverPrestamo (
    IN p_id_prestamo INT
)
BEGIN
    UPDATE PRESTAMO
    SET FECHA_DEVOLUCION = CURDATE()
    WHERE ID_PRESTAMO = p_id_prestamo;
END //

DELIMITER ;

-- Ejemplos de Devolver el prestamo
CALL AgregarPrestamo('2025-11-02', NULL, '2025-11-07', 1700, NULL, 31, 8);
SELECT * FROM PRESTAMO;
CALL DevolverPrestamo(32);

-- Ver datos de un socio en especifico
DELIMITER //

CREATE PROCEDURE VerDatosSocio(IN p_id_socio INT)
BEGIN
    SELECT *
    FROM vista_socio
    WHERE ID_SOCIO = p_id_socio;
END //

DELIMITER ;


-- FUNCIONES
-- Calcular el precio del prestamo
DELIMITER //
CREATE OR REPLACE FUNCTION fnPrecioBase(pIdPrestamo INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE dias INT DEFAULT 0;
    DECLARE precio DECIMAL(10,2) DEFAULT 0;

    SELECT 
        DATEDIFF(p.fecha_tope, p.fecha_prestamo),
        p.precio
    INTO dias, precio
    FROM prestamo p
    WHERE p.id_prestamo = pIdPrestamo;

    IF dias < 0 THEN
        SET dias = 0;
    END IF;

    RETURN dias * precio;
END //
DELIMITER ;

-- Probar el calculo de dias
SELECT fnPrecioBase(32) AS Precio_Base;

-- Calcular multa (dias de atraso y añadirle 20% extra)
DELIMITER //
CREATE OR REPLACE FUNCTION fnMulta(pIdPrestamo INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE diasRetraso INT DEFAULT 0;
    DECLARE precio DECIMAL(10,2) DEFAULT 0;

    SELECT 
        DATEDIFF(p.fecha_devolucion, p.fecha_tope),
        p.precio
    INTO diasRetraso, precio
    FROM prestamo p
    WHERE p.id_prestamo = pIdPrestamo;

    IF diasRetraso > 0 THEN
        RETURN diasRetraso * precio * 1.20;
    END IF;

    RETURN 0;
END //
DELIMITER ;

--Probarlo
SELECT fnMulta(32) AS Valor_De_Multa;

-- Calcular precio final
DELIMITER //
CREATE OR REPLACE FUNCTION fnTotalPrestamo(pIdPrestamo INT)
RETURNS DECIMAL(10,2)
BEGIN
    RETURN fnPrecioBase(pIdPrestamo) + fnMulta(pIdPrestamo);
END //
DELIMITER ;

-- Probar los 3
SELECT fnPrecioBase(32), fnMulta(32), fnTotalPrestamo(32);






-- ======= VISTAS ======
-- Vista para ver los socios
CREATE OR REPLACE VIEW vista_socio AS
SELECT
    ID_SOCIO,
    CONCAT(NOMBRE1, ' ', IFNULL(NOMBRE2, ''), ' ', APELLIDO1, ' ', IFNULL(APELLIDO2, '')) AS Nombre_Completo,
    DNI,
    EMAIL,
    TELEFONO,
    CONCAT(CALLE, ' ', NUMERO, ', CP ', COD_POSTAL) AS Direccion
FROM SOCIOS;

SELECT * FROM vista_socio; -- Probar vista

-- Vista para ver los prestamos
CREATE VIEW vista_prestamos AS
SELECT
    p.ID_PRESTAMO AS Nro,
    CONCAT(s.APELLIDO1, ' ', s.NOMBRE1) AS Socio,
    a.TITULO AS Titulo,
    p.fecha_prestamo,
    p.fecha_devolucion,
    DATEDIFF(p.fecha_devolucion, p.fecha_tope) AS Dias_Atraso,
    p.observaciones AS Estado,
    fnPrecioBase(p.id_prestamo) AS Precio_Base,
    fnMulta(p.id_prestamo) AS Multa,
    fnTotalPrestamo(p.id_prestamo) AS Total
FROM prestamo p
JOIN socios s ON p.id_socio = s.id_socio
JOIN copias c ON p.id_copia = c.id_copia
JOIN album a ON c.album = a.id_album;

SELECT * FROM vista_prestamos ORDER BY Nro; -- Probar vista








-- ======= USUARIOS =======

-- Usuario admin
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON tiendamusical.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;

-- Usuario socio
CREATE USER 'socio'@'localhost' IDENTIFIED BY 'socio123';
GRANT EXECUTE ON PROCEDURE tiendamusical.AgregarSocio TO 'socio'@'localhost';
GRANT EXECUTE ON PROCEDURE tiendamusical.VerDatosSocio TO 'socio'@'localhost';
GRANT SELECT ON tiendamusical.socios TO 'socio'@'localhost';
FLUSH PRIVILEGES;



-- ======= TRIGGERS =======
-- Evitar prestar una copia que aun no ha sido devuelta
DELIMITER //

CREATE OR REPLACE TRIGGER ValidarPrestamo

BEFORE INSERT ON PRESTAMO
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) 
        FROM PRESTAMO 
        WHERE ID_COPIA = NEW.ID_COPIA 
          AND FECHA_DEVOLUCION IS NULL) > 0 THEN
        SET NEW.ID_COPIA = NULL;
    END IF;
END //

DELIMITER ;

-- Limitar a 3 prestamos activos por socio
DELIMITER //

CREATE OR REPLACE TRIGGER LimiteDePrestamos
BEFORE INSERT ON PRESTAMO
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) 
        FROM PRESTAMO 
        WHERE ID_SOCIO = NEW.ID_SOCIO 
          AND FECHA_DEVOLUCION IS NULL) >= 3 THEN
        SET NEW.ID_SOCIO = NULL;
    END IF;
END //

DELIMITER ;

-- ======= CURSORES =======
-- Colocar en observaciones el estado de los prestamos
DELIMITER //

CREATE PROCEDURE ActualizarEstadoPrestamos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_fecha_dev DATE;
    DECLARE v_fecha_tope DATE;

    DECLARE cur CURSOR FOR
        SELECT id_prestamo, fecha_devolucion, fecha_tope
        FROM prestamo;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_id, v_fecha_dev, v_fecha_tope;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Caso 1: Devuelto
        IF v_fecha_dev IS NOT NULL THEN
            UPDATE prestamo
            SET observaciones = 'Devuelto'
            WHERE id_prestamo = v_id;

        -- Caso 2: Atrasado
        ELSEIF v_fecha_tope < CURDATE() THEN
            UPDATE prestamo
            SET observaciones = CONCAT('Atrasado desde ', v_fecha_tope)
            WHERE id_prestamo = v_id;

        -- Caso 3: Pendiente (no devuelto y aun no pasó la fecha tope)
        ELSE
            UPDATE prestamo
            SET observaciones = 'Pendiente devolución'
            WHERE id_prestamo = v_id;
        END IF;

    END LOOP;

    CLOSE cur;
END;
//

DELIMITER ;

-- Probar cursor
CALL ActualizarEstadoPrestamos();