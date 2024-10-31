INSERT INTO LecturasTemperatura (DispositivoId, Temperatura, FechaLectura) VALUES
(1, 72.5, '2024-10-01 08:30:00'),
(2, 80.2, '2024-10-02 09:00:00'),
(1, 15.4, '2024-10-03 10:15:00'),
(3, -2.0, '2024-10-04 11:00:00'),
(4, 76.8, '2024-10-05 12:00:00'),
(2, 74.9, '2024-10-06 13:00:00'),
(3, 78.1, '2024-10-07 14:00:00'),
(4, -1.5, '2024-10-08 15:30:00'),
(1, 79.6, '2024-10-09 16:00:00'),
(2, 0.1, '2024-10-10 17:00:00');

INSERT INTO AlertasTemperatura (DispositivoId, Temperatura, FechaAlerta, Mensaje) VALUES
(2, 80.2, '2024-10-02 09:00:00', 'Temperatura Alta'),
(3, -2.0, '2024-10-04 11:00:00', 'Temperatura Baja'),
(4, 76.8, '2024-10-05 12:00:00', 'Temperatura Alta'),
(3, 78.1, '2024-10-07 14:00:00', 'Temperatura Alta'),
(4, -1.5, '2024-10-08 15:30:00', 'Temperatura Baja'),
(1, 79.6, '2024-10-09 16:00:00', 'Temperatura Alta');

DELIMITER //

CREATE PROCEDURE MonitorearTemperaturas()
BEGIN
#variables para almacenar los datos de cada lectura en el cursor
   DECLARE DispositivoIdV INT;
   DECLARE TemperaturaV DECIMAL(5,2);
   DECLARE FechaLecturaV DATETIME;
   DECLARE done INT DEFAULT FALSE;#controla el fin del cursor
   DECLARE MensajeV VARCHAR(255);

   -- declaro cursor para seleccionar las ultimas 100 lecturas
   DECLARE cursor_lecturas CURSOR FOR
   SELECT DispositivoId, Temperatura, FechaLectura
   FROM LecturasTemperatura
   ORDER BY FechaLectura DESC
   LIMIT 100;

#declaro y creo un handler que se activa cuando no se encuentran mas registros al intentar hacer FETCH en el cursor
#NOT FOUND es la condicion que indica que el cursor ha llegado al final de los registros, luego ejecuta set done=true
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

   OPEN cursor_lecturas;

   -- leer el primer registro, el cursor se abrio y se empieza a recorrer con FETCH para obtener el primer registr
   FETCH cursor_lecturas INTO DispositivoIdV, TemperaturaV, FechaLecturaV;

   
   START TRANSACTION; -- inicia, se utiliza START TRANSACTION para asegurar que todas las alertas se inserten correctamente, y COMMIT confirma la transaccion

   -- bucle para recorrer cada registro
   WHILE NOT done DO
      BEGIN
         
         IF TemperaturaV > 75 THEN
            SET MensajeV = 'Temperatura Alta';
            INSERT INTO AlertasTemperatura (DispositivoId, Temperatura, FechaAlerta, Mensaje)-- instruccion SQL INSERT que permite agregar un nuevo registro en la tabla
            VALUES (DispositivoIdV, TemperaturaV, FechaLecturaV, MensajeV);
         ELSEIF TemperaturaV < 0 THEN
            SET MensajeV = 'Temperatura Baja';
            INSERT INTO AlertasTemperatura (DispositivoId, Temperatura, FechaAlerta, Mensaje)
            VALUES (DispositivoIdV, TemperaturaV, FechaLecturaV, MensajeV);
         END IF;

         -- avanza al siguiente registro del cursor
         FETCH cursor_lecturas INTO DispositivoIdV, TemperaturaV, FechaLecturaV;
      END;
   END WHILE;

   -- confirmar transaccin 
   COMMIT;

   CLOSE cursor_lecturas;
END//

DELIMITER ;

