DROP DATABASE IF EXISTS sistema_evaluaciones;
CREATE DATABASE sistema_evaluaciones;
USE sistema_evaluaciones;

CREATE TABLE USUARIO (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    CONSTRAINT chk_usuario_rol CHECK (rol IN ('Estudiante', 'Docente'))
);

CREATE TABLE ESTUDIANTE (
    id_usuario INT PRIMARY KEY,
    grado VARCHAR(20) NOT NULL DEFAULT '11',
    CONSTRAINT chk_estudiante_grado CHECK (grado IN ('6', '7', '8', '9', '10', '11')),
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE DOCENTE (
    id_usuario INT PRIMARY KEY,
    asignatura VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE EVALUACION (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    tiempoLimite INT NOT NULL,
    fechaCreacion DATE NOT NULL
);

CREATE TABLE COMPETENCIA (
    id_competencia INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    componente VARCHAR(100) NOT NULL
);

CREATE TABLE PREGUNTA (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    enunciado TEXT NOT NULL,
    explicacion TEXT,
    nivelDificultad VARCHAR(50) NOT NULL CHECK (nivelDificultad IN ('Fácil', 'Medio', 'Difícil')),
    id_competencia INT NOT NULL,
    FOREIGN KEY (id_competencia) REFERENCES COMPETENCIA(id_competencia)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE EVALUACION_PREGUNTA (
    id_evaluacion INT NOT NULL,
    id_pregunta INT NOT NULL,
    ordenPregunta INT NOT NULL,
    PRIMARY KEY (id_evaluacion, id_pregunta),
    FOREIGN KEY (id_evaluacion) REFERENCES EVALUACION(id_evaluacion)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_pregunta) REFERENCES PREGUNTA(id_pregunta)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE OPCION (
    id_opcion INT AUTO_INCREMENT PRIMARY KEY,
    letra CHAR(1) NOT NULL,
    texto TEXT NOT NULL,
    esCorrecta BOOLEAN NOT NULL,
    id_pregunta INT NOT NULL,
    UNIQUE (id_opcion, id_pregunta),
    UNIQUE (id_pregunta, letra),
    FOREIGN KEY (id_pregunta) REFERENCES PREGUNTA(id_pregunta)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE RESULTADO (
    id_resultado INT AUTO_INCREMENT PRIMARY KEY,
    puntaje DOUBLE NOT NULL,
    porcentaje DOUBLE NOT NULL,
    fechaRealizacion DATE NOT NULL,
    fechaHoraInicio DATETIME NOT NULL,
    fechaHoraFin DATETIME,
    id_estudiante INT NOT NULL,
    id_evaluacion INT NOT NULL,
    FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_evaluacion) REFERENCES EVALUACION(id_evaluacion)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE RESPUESTA (
    id_respuesta INT AUTO_INCREMENT PRIMARY KEY,
    id_resultado INT NOT NULL,
    id_pregunta INT NOT NULL,
    id_opcion INT,
    fechaHoraRespuesta DATETIME NOT NULL,
    UNIQUE (id_resultado, id_pregunta),
    FOREIGN KEY (id_resultado) REFERENCES RESULTADO(id_resultado)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_pregunta) REFERENCES PREGUNTA(id_pregunta)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_opcion, id_pregunta)
    REFERENCES OPCION(id_opcion, id_pregunta)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_pregunta_competencia ON PREGUNTA(id_competencia);
CREATE INDEX idx_pregunta_dificultad ON PREGUNTA(nivelDificultad);
CREATE INDEX idx_resultado_estudiante ON RESULTADO(id_estudiante);
CREATE INDEX idx_resultado_evaluacion ON RESULTADO(id_evaluacion);

-- =========================================================
-- DATOS BASE DEL SIMULACRO (EVALUACIÓN, COMPETENCIAS Y PREGUNTAS)
-- Las tablas USUARIO, DOCENTE, ESTUDIANTE, RESULTADO y RESPUESTA
-- inician completamente limpias para registros reales desde la web.
-- =========================================================

INSERT INTO EVALUACION (titulo, descripcion, tiempoLimite, fechaCreacion) VALUES
('Simulacro Prueba Saber 11 - Matemáticas',
'Evaluación tipo ICFES con enfoque en razonamiento cuantitativo, geometría y estadística',
60, '2026-10-01');

INSERT INTO COMPETENCIA (nombre, componente) VALUES
('Razonamiento y Argumentación', 'Numérico-Variacional'),
('Ejecución y Planteamiento', 'Geométrico-Métrico'),
('Interpretación y Representación', 'Aleatorio');

-- 3 PREGUNTAS INICIALES (IDs 1 al 3)
INSERT INTO PREGUNTA (enunciado, explicacion, nivelDificultad, id_competencia) VALUES
('En una institución educativa, el 40% de los estudiantes de grado 11 practica fútbol, el 30% practica baloncesto y un 10% practica ambos deportes. Si se selecciona un estudiante al azar, ¿cuál es la probabilidad de que no practique ninguno de estos dos deportes?',
'Unión = 40% + 30% - 10% = 60%. Complemento = 100% - 60% = 40%.',
'Medio', 3),

('Un tanque cilíndrico utilizado para almacenar agua en una zona rural tiene un radio basal de 2 metros y una altura de 5 metros. Si se desea duplicar únicamente su capacidad de almacenamiento manteniendo el radio intacto, la altura del nuevo tanque debe ser:',
'El volumen del cilindro es V = pi * r^2 * h. Duplicar el volumen implica duplicar la altura.',
'Difícil', 2),

('En una tienda de ropa se anuncia un descuento del 30% en toda la mercancía. Adicionalmente, si el pago se realiza en efectivo, se otorga un 10% de descuento sobre el precio ya rebajado. Si una prenda cuesta inicialmente $100.000, el precio final pagado en efectivo es:',
'Primer descuento: 30.000. Segundo descuento: 7.000. Precio final: 63.000.',
'Fácil', 1);

INSERT INTO EVALUACION_PREGUNTA (id_evaluacion, id_pregunta, ordenPregunta) VALUES
(1, 1, 1),
(1, 2, 2),
(1, 3, 3);

INSERT INTO OPCION (letra, texto, esCorrecta, id_pregunta) VALUES
('A', '20%', FALSE, 1),
('B', '30%', FALSE, 1),
('C', '40%', TRUE, 1),
('D', '60%', FALSE, 1),
('A', '2.5 metros', FALSE, 2),
('B', '10 metros', TRUE, 2),
('C', '25 metros', FALSE, 2),
('D', '20 metros', FALSE, 2),
('A', '60.000', FALSE, 3),
('B', '63.000', TRUE, 3),
('C', '65.000', FALSE, 3),
('D', '70.000', FALSE, 3);

-- =========================================================
-- 50 PREGUNTAS ADICIONALES PARA MATEMATECH (IDs 4 AL 53)
-- =========================================================

CREATE TABLE nuevas_preguntas_temp (
    id INT PRIMARY KEY,
    enunciado TEXT NOT NULL,
    explicacion TEXT,
    dificultad VARCHAR(20) NOT NULL,
    competencia INT NOT NULL,
    A TEXT NOT NULL,
    B TEXT NOT NULL,
    C TEXT NOT NULL,
    D TEXT NOT NULL,
    correcta CHAR(1) NOT NULL
);

INSERT INTO nuevas_preguntas_temp VALUES
(4,'Una tienda vende un cuaderno a $8.000. Si se compran 5 cuadernos, ¿cuánto se paga?','Se multiplica 8.000 por 5.','Fácil',1,'$30.000','$35.000','$40.000','$45.000','C'),
(5,'Un estudiante obtuvo 36 respuestas correctas de un total de 40. ¿Qué porcentaje obtuvo?','36 dividido entre 40 y multiplicado por 100 da 90%.','Fácil',1,'80%','85%','90%','95%','C'),
(6,'Una camiseta cuesta $80.000 y tiene un descuento del 25%. ¿Cuál es su precio final?','El descuento es 20.000. Se resta al precio inicial.','Medio',1,'$55.000','$60.000','$65.000','$70.000','B'),
(7,'Un automóvil recorre 180 kilómetros en 3 horas. ¿Cuál es su velocidad promedio?','180 dividido entre 3 es igual a 60 km/h.','Fácil',1,'40 km/h','50 km/h','60 km/h','70 km/h','C'),
(8,'Si 3 cuadernos cuestan $12.000, ¿cuánto cuestan 7 cuadernos al mismo precio unitario?','Cada cuaderno cuesta 4.000. Multiplicando por 7 se obtiene 28.000.','Medio',1,'$24.000','$26.000','$28.000','$30.000','C'),
(9,'Una población de 2.000 habitantes aumenta un 10%. ¿Cuántos habitantes tendrá?','El 10% de 2.000 es 200. Se suman los 200 habitantes.','Fácil',1,'2.100','2.200','2.300','2.400','B'),
(10,'Un número aumentado en 15 es igual a 42. ¿Cuál es el número?','Se resta 15 a 42.','Fácil',1,'25','27','29','30','B'),
(11,'Una familia gasta 3/4 de sus ingresos de $2.000.000. ¿Cuánto dinero le queda?','Tres cuartas partes son 1.500.000. Quedan 500.000.','Medio',1,'$400.000','$500.000','$600.000','$700.000','B'),
(12,'Si una cantidad se duplica y luego se le suman 8 unidades, se obtiene 30. ¿Cuál era la cantidad inicial?','2x + 8 = 30. Entonces x = 11.','Medio',1,'9','10','11','12','C'),
(13,'Un producto cuesta $150.000 y aumenta su precio un 20%. ¿Cuál es el nuevo precio?','El 20% de 150.000 es 30.000.','Fácil',1,'$160.000','$170.000','$180.000','$190.000','C'),
(14,'En una clase hay 18 mujeres y 12 hombres. ¿Qué fracción representa a los hombres?','Hay 30 estudiantes. La fracción es 12/30 = 2/5.','Medio',1,'1/5','2/5','3/5','4/5','B'),
(15,'Un trabajador gana $50.000 diarios durante 6 días. ¿Cuánto recibe?','50.000 multiplicado por 6.','Fácil',1,'$250.000','$280.000','$300.000','$350.000','C'),
(16,'Si 5x = 45, ¿cuál es el valor de x?','Se divide 45 entre 5.','Fácil',1,'7','8','9','10','C'),
(17,'Una botella contiene 2,5 litros de agua. ¿Cuántos mililitros contiene?','Un litro equivale a 1.000 mililitros.','Fácil',1,'250','1.500','2.000','2.500','D'),
(18,'Un estudiante ahorra $15.000 cada semana durante 8 semanas. ¿Cuánto ahorra?','15.000 multiplicado por 8.','Fácil',1,'$100.000','$110.000','$120.000','$130.000','C'),
(19,'Si el 40% de una cantidad es 80, ¿cuál es la cantidad total?','80 dividido entre 0,40 es 200.','Medio',1,'160','180','200','220','C'),
(20,'Una tienda vende un producto a $90.000 después de aplicar un descuento del 10%. ¿Cuál era su precio original?','90.000 representa el 90% del precio original. 90.000 / 0,9 = 100.000.','Difícil',1,'$95.000','$100.000','$105.000','$110.000','B'),
(21,'Si una cantidad aumenta de 50 a 65, ¿cuál fue el porcentaje de aumento?','El aumento fue 15. Se divide 15 entre 50 y se multiplica por 100.','Medio',1,'20%','25%','30%','35%','C'),
(22,'La suma de tres números consecutivos es 36. ¿Cuál es el número del medio?','Los números son 11, 12 y 13.','Medio',1,'10','11','12','13','C'),
(23,'Un terreno rectangular mide 12 metros de largo y 8 metros de ancho. ¿Cuál es su área?','Área = largo por ancho = 96 metros cuadrados.','Fácil',2,'80 m²','88 m²','96 m²','100 m²','C'),
(24,'Un cuadrado tiene lados de 9 centímetros. ¿Cuál es su perímetro?','Se multiplica 9 por 4.','Fácil',2,'18 cm','27 cm','36 cm','45 cm','C'),
(25,'Un triángulo tiene una base de 10 cm y una altura de 6 cm. ¿Cuál es su área?','Área = base por altura dividido entre 2.','Medio',2,'20 cm²','25 cm²','30 cm²','60 cm²','C'),
(26,'Una caja tiene 4 cm de largo, 3 cm de ancho y 5 cm de alto. ¿Cuál es su volumen?','Volumen = 4 por 3 por 5 = 60 cm³.','Medio',2,'12 cm³','30 cm³','60 cm³','80 cm³','C'),
(27,'Una escalera de 5 metros se apoya en una pared. Su base está a 3 metros de la pared. ¿A qué altura llega?','Por Pitágoras: altura² = 25 - 9 = 16. La altura es 4 metros.','Difícil',2,'2 m','3 m','4 m','5 m','C'),
(28,'Una circunferencia tiene un radio de 7 cm. Usando pi = 3,14, ¿cuál es aproximadamente su longitud?','Longitud = 2 por pi por radio = 43,96 cm.','Medio',2,'21,98 cm','43,96 cm','49 cm','153,86 cm','B'),
(29,'Un cilindro tiene radio de 2 cm y altura de 10 cm. Usando pi = 3,14, ¿cuál es su volumen?','V = pi por radio al cuadrado por altura = 125,6 cm³.','Difícil',2,'62,8 cm³','100 cm³','125,6 cm³','150 cm³','C'),
(30,'Un jardín cuadrado tiene un área de 64 m². ¿Cuánto mide cada lado?','La raíz cuadrada de 64 es 8.','Fácil',2,'6 m','7 m','8 m','9 m','C'),
(31,'Un mapa utiliza una escala de 1:100.000. Si dos lugares están separados por 3 cm en el mapa, ¿cuál es la distancia real?','3 cm representan 300.000 cm, equivalentes a 3 km.','Medio',2,'1 km','2 km','3 km','4 km','C'),
(32,'Una piscina rectangular mide 15 metros de largo y 6 metros de ancho. ¿Cuál es su área?','15 por 6 = 90 m².','Fácil',2,'60 m²','75 m²','90 m²','100 m²','C'),
(33,'Un terreno triangular tiene base de 12 m y altura de 8 m. ¿Cuál es su área?','12 por 8 dividido entre 2 = 48 m².','Medio',2,'36 m²','42 m²','48 m²','96 m²','C'),
(34,'Un cubo tiene aristas de 4 cm. ¿Cuál es su volumen?','4 elevado a la tercera potencia es 64.','Medio',2,'16 cm³','32 cm³','48 cm³','64 cm³','D'),
(35,'Una rueda tiene un diámetro de 20 cm. Usando pi = 3,14, ¿cuál es su circunferencia?','C = pi por diámetro = 62,8 cm.','Medio',2,'31,4 cm','40 cm','62,8 cm','100 cm','C'),
(36,'Una habitación mide 5 m de largo y 4 m de ancho. Si cada baldosa cubre 1 m², ¿cuántas baldosas se necesitan?','El área es 20 m².','Fácil',2,'9','16','20','25','C'),
(37,'En una encuesta, 12 estudiantes prefieren fútbol, 8 baloncesto y 5 voleibol. ¿Cuántos estudiantes participaron?','Se suman las tres cantidades: 12 + 8 + 5 = 25.','Fácil',3,'20','23','25','30','C'),
(38,'Las notas de un estudiante son 3, 4, 5 y 4. ¿Cuál es su promedio?','La suma es 16 y se divide entre 4.','Fácil',3,'3','3,5','4','4,5','C'),
(39,'En una bolsa hay 3 bolas rojas y 7 azules. ¿Cuál es la probabilidad de sacar una bola roja?','Hay 3 casos favorables de 10 posibles.','Medio',3,'10%','20%','30%','70%','C'),
(40,'Las ventas de una tienda fueron 10, 15, 20 y 15 unidades. ¿Cuál es la moda?','El número 15 aparece dos veces.','Fácil',3,'10','15','17','20','B'),
(41,'Un grupo tiene edades de 12, 14, 16, 18 y 20 años. ¿Cuál es la mediana?','El valor central de los datos ordenados es 16.','Medio',3,'14','15','16','18','C'),
(42,'En un curso de 40 estudiantes, 10 usan bicicleta para llegar. ¿Qué porcentaje representan?','10 dividido entre 40 y multiplicado por 100.','Fácil',3,'20%','25%','30%','40%','B'),
(43,'Un dado de seis caras se lanza una vez. ¿Cuál es la probabilidad de obtener un número par?','Los resultados pares son 2, 4 y 6: tres de seis.','Medio',3,'1/6','1/3','1/2','2/3','C'),
(44,'Las temperaturas registradas fueron 20, 22, 24, 26 y 28 grados. ¿Cuál es el rango?','Se resta el menor valor al mayor: 28 - 20 = 8.','Fácil',3,'6','7','8','9','C'),
(45,'En una gráfica circular, un sector representa el 25% del total. ¿Cuántos grados ocupa?','25% de 360 grados equivale a 90 grados.','Medio',3,'45°','90°','120°','180°','B'),
(46,'Una encuesta muestra que 60 de 100 personas prefieren el transporte público. ¿Qué porcentaje no lo prefiere?','100% - 60% = 40%.','Fácil',3,'20%','30%','40%','60%','C'),
(47,'Los resultados de cinco estudiantes son 2, 3, 3, 4 y 8. ¿Cuál es la media?','La suma es 20. Se divide entre 5.','Medio',3,'3','4','5','6','B'),
(48,'En una caja hay 4 fichas verdes, 3 amarillas y 3 rojas. ¿Cuál es la probabilidad de sacar una ficha amarilla?','Hay 3 fichas amarillas de un total de 10.','Medio',3,'20%','30%','40%','50%','B'),
(49,'Una gráfica muestra que las ventas fueron 100, 120, 150 y 130 unidades en cuatro meses. ¿En qué mes se vendió más?','El valor máximo es 150, correspondiente al tercer mes.','Fácil',3,'Primer mes','Segundo mes','Tercer mes','Cuarto mes','C'),
(50,'En un grupo de 50 estudiantes, 20 practican fútbol, 15 baloncesto y 15 voleibol. ¿Qué porcentaje practica baloncesto?','15 dividido entre 50 y multiplicado por 100 es 30%.','Medio',3,'20%','25%','30%','35%','C'),
(51,'Una encuesta registra 80 respuestas. Si el 75% respondió afirmativamente, ¿cuántas personas respondieron sí?','80 por 0,75 = 60.','Medio',3,'40','50','60','70','C'),
(52,'Los datos son 5, 7, 7, 8, 9 y 12. ¿Cuál es la mediana?','Se promedian los dos valores centrales: (7 + 8) / 2 = 7,5.','Difícil',3,'7','7,5','8','8,5','B'),
(53,'En una clase hay 18 mujeres y 12 hombres. Si se elige una persona al azar, ¿cuál es la probabilidad de seleccionar un hombre?','12 dividido entre 30 es 0,4, equivalente al 40%.','Medio',3,'20%','30%','40%','60%','C');

-- Insertar las 50 preguntas
INSERT INTO PREGUNTA (enunciado, explicacion, nivelDificultad, id_competencia)
SELECT enunciado, explicacion, dificultad, competencia
FROM nuevas_preguntas_temp
ORDER BY id;

-- Incorporar las 50 preguntas al simulacro principal
INSERT INTO EVALUACION_PREGUNTA (id_evaluacion, id_pregunta, ordenPregunta)
SELECT 1, P.id_pregunta, N.id
FROM nuevas_preguntas_temp N
INNER JOIN PREGUNTA P ON P.enunciado = N.enunciado
WHERE P.id_pregunta >= 4;

-- Agregar las 4 opciones exactas por cada pregunta nueva
INSERT INTO OPCION (letra, texto, esCorrecta, id_pregunta)
SELECT 'A', N.A, (N.correcta = 'A'), P.id_pregunta
FROM nuevas_preguntas_temp N INNER JOIN PREGUNTA P ON P.enunciado = N.enunciado
WHERE P.id_pregunta >= 4
UNION ALL
SELECT 'B', N.B, (N.correcta = 'B'), P.id_pregunta
FROM nuevas_preguntas_temp N INNER JOIN PREGUNTA P ON P.enunciado = N.enunciado
WHERE P.id_pregunta >= 4
UNION ALL
SELECT 'C', N.C, (N.correcta = 'C'), P.id_pregunta
FROM nuevas_preguntas_temp N INNER JOIN PREGUNTA P ON P.enunciado = N.enunciado
WHERE P.id_pregunta >= 4
UNION ALL
SELECT 'D', N.D, (N.correcta = 'D'), P.id_pregunta
FROM nuevas_preguntas_temp N INNER JOIN PREGUNTA P ON P.enunciado = N.enunciado
WHERE P.id_pregunta >= 4;

-- Eliminar la tabla auxiliar limpia
DROP TABLE nuevas_preguntas_temp;

-- =========================================================
-- CONSULTAS DE VERIFICACIÓN
-- =========================================================
SELECT COUNT(*) AS total_preguntas FROM PREGUNTA;
SELECT COUNT(*) AS total_opciones FROM OPCION;
SELECT COUNT(*) AS total_usuarios FROM USUARIO;


