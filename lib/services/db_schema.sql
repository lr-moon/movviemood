BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Resenas" (
	"id_resena"	INTEGER,
	"id_user"	INTEGER NOT NULL,
	"titulo"	TEXT NOT NULL,
	"critica"	TEXT NOT NULL,
	"calificacion"	INTEGER NOT NULL CHECK("calificacion" >= 1 AND "calificacion" <= 5),
	"imagen_url"	TEXT,
	PRIMARY KEY("id_resena" AUTOINCREMENT),
	FOREIGN KEY("id_user") REFERENCES "Usuarios"("id_user") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Usuarios" (
	"id_user"	INTEGER,
	"email"	TEXT NOT NULL UNIQUE,
	"contrasena"	TEXT NOT NULL,
	PRIMARY KEY("id_user" AUTOINCREMENT)
);

INSERT INTO Usuarios (email, contrasena) VALUES
('monserrat.lopez@example.com', 'Monse1234!'),

('carlos.ramirez@example.com', 'CarRam2024#'),
('sofia.garcia@example.com', 'SofiG_2025'),
('andres.mendoza@example.com', 'AndMend_99'),
('valeria.torres@example.com', 'ValTor#88'),
('juan.perez@example.com', 'Juanito_01!'),
('mariana.santos@example.com', 'MariSan2023'),
('ricardo.morales@example.com', 'Ricky_M@r1'),
('fernanda.rios@example.com', 'FerRios.25'),
('diego.hernandez@example.com', 'D!ego_H2024');



-- Asignación de Usuarios: El id_user rota cíclicamente entre 2 y 10.
-- Ajuste de Calificación: Las calificaciones originales (ej. 9.0) se escalaron a 1-5 (ej. 5).

-- 1. Oppenheimer (id_user: 2, Calificacion: 5)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (2, 'Oppenheimer', 'Un drama biográfico monumental y absorbente de Christopher Nolan. La película es un logro técnico y narrativo, con una actuación central hipnótica de Cillian Murphy que explora la complejidad del creador de la bomba atómica.', 5, 'assets/images/R1.jpg');

-- 2. Dune (id_user: 3, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (3, 'Dune', 'Una adaptación épica y visualmente sobrecogedora de la novela de ciencia ficción. Denis Villeneuve construye un mundo inmersivo y grandioso, sentando las bases de una saga con una escala y una ambición impresionantes.', 4, 'assets/images/R2.jpg');

-- 3. Barbie (id_user: 4, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (4, 'Barbie', 'Una película sorprendentemente ingeniosa, divertida y con un mensaje poderoso. Greta Gerwig ofrece una sátira colorida y existencial que deconstruye el ícono de Barbie con humor y corazón, celebrando la feminidad en todas sus formas.', 4, 'assets/images/R3.jpg');

-- 4. Los Vengadores (id_user: 5, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (5, 'Los Vengadores', 'El épico crossover que culminó años de construcción del universo Marvel. Joss Whedon equilibra a la perfección la acción espectacular con el humor y la dinámica entre sus héroes, creando un evento cinematográfico inolvidable.', 4, 'assets/images/R4.jpg');

-- 5. Avatar (id_user: 6, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (6, 'Avatar', 'Una revolución visual que transportó a los espectadores a un mundo alienígena exuberante y detallado. La historia de James Cameron, aunque sencilla, es un espectáculo épico que redefinió el cine en 3D y sigue siendo un hito tecnológico.', 4, 'assets/images/R5.jpg');

-- 6. El Conjuro (id_user: 7, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (7, 'El Conjuro', 'James Wan revitalizó el género de casas embrujadas con esta obra maestra del terror. Basada en un caso real, la película utiliza una tensión magistral y sustos genuinamente aterradores para crear una experiencia escalofriante.', 4, 'assets/images/R6.jpg');

-- 7. It (Eso) (id_user: 8, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (8, 'It (Eso)', 'Una adaptación aterradora y sorprendentemente emotiva de la novela de Stephen King. La película captura el horror de Pennywise a la vez que explora los lazos de amistad del Club de los Perdedores, con un elenco joven excepcional.', 4, 'assets/images/R7.jpg');

-- 8. Star Wars: Una Nueva Esperanza (id_user: 9, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (9, 'Star Wars: Una Nueva Esperanza', 'La película que cambió la ciencia ficción para siempre. Una aventura espacial clásica de bien contra el mal que introdujo a personajes icónicos, un universo fascinante y encendió la imaginación de generaciones enteras.', 4, 'assets/images/R8.jpg');

-- 9. Los Juegos del Hambre (id_user: 10, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (10, 'Los Juegos del Hambre', 'Una emocionante adaptación de la popular novela distópica. Jennifer Lawrence brilla como Katniss Everdeen en una historia que combina acción trepidante con una potente crítica social sobre la desigualdad y el entretenimiento.', 4, 'assets/images/R9.jpg');

-- 10. Shrek (id_user: 2, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (2, 'Shrek', 'Una brillante y divertida parodia de los cuentos de hadas tradicionales. Con un humor ingenioso que apela tanto a niños como a adultos, Shrek se convirtió en un clásico instantáneo de la animación, lleno de personajes memorables.', 4, 'assets/images/R10.jpg');

-- 11. Cómo Entrenar a tu Dragón (id_user: 3, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (3, 'Cómo Entrenar a tu Dragón', 'Una conmovedora y visualmente espectacular película animada sobre la amistad entre un joven vikingo y un dragón. Es una aventura llena de corazón, humor y secuencias de vuelo que te dejarán sin aliento.', 4, 'assets/images/R11.jpg');

-- 12. Orgullo y Prejuicio (id_user: 4, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (4, 'Orgullo y Prejuicio', 'Una adaptación cinematográfica encantadora y visualmente impresionante de la novela clásica de Jane Austen. La química entre Keira Knightley y Matthew Macfadyen captura a la perfección la tensión y el romance de la historia.', 4, 'assets/images/R12.jpg');

-- 13. Yo Antes de Ti (id_user: 5, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (5, 'Yo Antes de Ti', 'Un drama romántico profundamente emotivo que explora temas complejos con sensibilidad. La química entre Emilia Clarke y Sam Claflin es el corazón de esta historia agridulce que te hará reír y llorar.', 4, 'assets/images/R13.jpg');

-- 14. Los Imprevistos del Amor (id_user: 6, Calificacion: 4)
INSERT INTO "Resenas" ("id_user", "titulo", "critica", "calificacion", "imagen_url")
VALUES (6, 'Los Imprevistos del Amor', 'Una encantadora y a menudo divertida comedia romántica sobre dos mejores amigos cuyo destino parece jugarles una mala pasada una y otra vez. Es una historia sobre el tiempo, las oportunidades perdidas y el amor verdadero.', 4, 'assets/images/R14.jpg');

COMMIT;
