-- Database: Proyecto4

-- DROP DATABASE "Proyecto4";

CREATE DATABASE "Proyecto4"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

create schema aplicada

create table aplicada.clientes(
	id_cliente serial primary key,
	cedula varchar(12),
	nombre varchar(20),
	apellido_uno varchar(20),
	apellido_dos varchar(20),
	fecha_ins date default CURRENT_TIMESTAMP);

create table aplicada.ordenes(
		id serial primary key, 
		id_producto int, 
		cantidad int, 
		fecha date, 
		id_cliente int,
		FOREIGN KEY (id_producto)references aplicada.productos (id),
		FOREIGN KEY (id_cliente) references aplicada.clientes(id_cliente));
	
create table aplicada.productos(
		id serial primary key, 
		nombre varchar(60), 
		precio int);

CREATE TABLE aplicada.telefonos(
ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
NUMERO INT,
ID_CLIENTE INT,
FECHA_INS DATE,
FOREIGN KEY (ID_CLIENTE) REFERENCES aplicada.clientes(id_cliente) ON DELETE CASCADE
);

CREATE TABLE aplicada.direcciones(
ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
DIRECCIONES VARCHAR(200),
ID_CLIENTE INT,
FECHA_INS DATE,
FOREIGN KEY (ID_CLIENTE) REFERENCES aplicada.clientes (id_cliente) ON DELETE CASCADE
);

CREATE TABLE aplicada.correos(
ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
CORREO VARCHAR(100),
ID_CLIENTE INT,
FECHA_INS DATE,
FOREIGN KEY (ID_CLIENTE) REFERENCES aplicada.clientes (id_cliente) ON DELETE CASCADE
);

CREATE TABLE aplicada.tarjetas(
ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
NUM_TARJETA VARCHAR(50),
ID_CLIENTE INT,
FECHA_INS DATE,
FOREIGN KEY (ID_CLIENTE) REFERENCES aplicada.clientes (id_cliente) ON DELETE CASCADE
);
-- ASIGNA FKs DE PRODUCTOS Y CLIENTES A ORDENES, EJECUTAR HASTA TENER INSERTADOS LOS CLIEBTES, PRODUCTOS Y ORDENES --
create function SP_ASIGNAR_FKS()
returns text
as $$
DECLARE CONTADOR INT = 1; RANDOM INT;
BEGIN
WHILE @CONTADOR < 1001 loop

select floor(random() * 999 + 1)::int into RANDOM;
UPDATE aplicada.ordenes SET id_cliente = RANDOM WHERE id = (SELECT id FROM (SELECT id,ROW_NUMBER() OVER (ORDER BY id) AS RN FROM aplicada.ordenes) XD WHERE XD.RN = CONTADOR);
select floor(random() * 999 + 1)::int into RANDOM;
UPDATE aplicada.ordenes SET id_producto = RANDOM WHERE id = (SELECT id FROM (SELECT id,ROW_NUMBER() OVER (ORDER BY id) AS RN FROM aplicada.ordenes) XD WHERE XD.RN = CONTADOR);

SELECT CONTADOR+1 INTO CONTADOR;
END loop;
return 'Listo';
END;$$
language plpgsql

SELECT SP_ASIGNAR_FKS() -- EJECUTA LA FUNCION DE LAS FKs
-- FUNCION PARA EXTRAER LOS DATOS A LA SEGUNDA FUENTE EXCEL --
create function SP_EXTRAER_EXCEL()
returns text
as $$
DECLARE cursor1 CURSOR FOR SELECT * FROM aplicada.ordenes;id int;id_producto int;cantidad int;fecha date;id_cliente int;tarjeta varchar(10);
BEGIN
CREATE TEMP TABLE temporal(
id int,
id_producto int,
cantidad int,
fecha date,
id_cliente int,
pago varchar(10)
);
OPEN cursor1;
LOOP
      FETCH cursor1 INTO id,id_producto,cantidad,fecha,id_cliente,tarjeta;
      IF NOT FOUND THEN EXIT; END IF;

      if tarjeta then
	  insert into temporal values (id,id_producto,cantidad,fecha,id_cliente,'TARJETA');
	  else
	  insert into temporal values (id,id_producto,cantidad,fecha,id_cliente,'EFECTIVO');
	  end if;

   END LOOP;
CLOSE cursor1;
COPY temporal TO 'D:\ordenes.xlsx' DELIMITER '*' CSV HEADER;
drop table temporal;

return 'xD';

END;$$
language plpgsql

SELECT SP_EXTRAER_EXCEL() -- EJECUTA EL METODO DE EXTRACCION A EXCEL


