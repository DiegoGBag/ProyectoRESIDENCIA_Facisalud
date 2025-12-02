/* ---------------------------------------------------------
    PLATAFORMA PSAD - ESTRUCTURA COMPLETA DE BASE DE DATOS
   --------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS psad
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE psad;

/* ---------------------------------------------------------
   TABLA: roles
   --------------------------------------------------------- */
CREATE TABLE roles (
    id TINYINT UNSIGNED PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO roles (id, nombre)
VALUES (1, 'admin'), (2, 'teacher');

/* ---------------------------------------------------------
   TABLA: users (para login)
   --------------------------------------------------------- */
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id TINYINT UNSIGNED NOT NULL DEFAULT 2,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id)
        REFERENCES roles(id)
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: docentes (perfil general)
   --------------------------------------------------------- */
CREATE TABLE docentes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    empleado_numero VARCHAR(50) NOT NULL UNIQUE,
    nombre_completo VARCHAR(255) NOT NULL,
    facultad VARCHAR(255),
    ultimo_grado VARCHAR(100),
    especialidad_area VARCHAR(255),
    tipo_profesor ENUM('asignatura', 'tecnico_academico', 'tiempo_completo'),
    es_profesor_investigador BOOLEAN DEFAULT FALSE,
    perfil_prodep ENUM('no', 'si', 'en_tramite') DEFAULT 'no',
    es_miembro_sni BOOLEAN DEFAULT FALSE,
    sni_nivel VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_docentes_users FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: cuerpos_colegiados
   --------------------------------------------------------- */
CREATE TABLE cuerpos_colegiados (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) UNIQUE NOT NULL
);

/* Relación muchos a muchos */
CREATE TABLE docente_cuerpos (
    docente_id BIGINT UNSIGNED NOT NULL,
    cuerpo_id INT UNSIGNED NOT NULL,
    observaciones TEXT,
    
    PRIMARY KEY (docente_id, cuerpo_id),

    CONSTRAINT fk_dc_docente FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE CASCADE,

    CONSTRAINT fk_dc_cuerpo FOREIGN KEY (cuerpo_id)
        REFERENCES cuerpos_colegiados(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: programas educativos
   --------------------------------------------------------- */
CREATE TABLE programas (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE docente_programas (
    docente_id BIGINT UNSIGNED NOT NULL,
    programa_id INT UNSIGNED NOT NULL,

    PRIMARY KEY (docente_id, programa_id),

    CONSTRAINT fk_dp_doc FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE CASCADE,

    CONSTRAINT fk_dp_prog FOREIGN KEY (programa_id)
        REFERENCES programas(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: attachments (archivos subidos)
   --------------------------------------------------------- */
CREATE TABLE attachments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    docente_id BIGINT UNSIGNED NULL,
    ruta VARCHAR(1024) NOT NULL,
    nombre_original VARCHAR(255),
    categoria VARCHAR(100),
    mime VARCHAR(150),
    tamano_bytes BIGINT UNSIGNED,
    periodo VARCHAR(30),
    uploaded_by BIGINT UNSIGNED,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_att_doc FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE SET NULL,

    CONSTRAINT fk_att_user FOREIGN KEY (uploaded_by)
        REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: certificaciones
   --------------------------------------------------------- */
CREATE TABLE certificaciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    docente_id BIGINT UNSIGNED NOT NULL,
    tipo ENUM('profesional', 'idioma', 'otro'),
    descripcion VARCHAR(500),
    nivel_idioma VARCHAR(100),
    fecha_obtencion DATE,
    archivo_id BIGINT UNSIGNED,

    CONSTRAINT fk_cert_doc FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: publicaciones
   --------------------------------------------------------- */
CREATE TABLE publicaciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    docente_id BIGINT UNSIGNED NOT NULL,

    tipo ENUM(
        'indexado', 'arbitrado', 'divulgacion',
        'libro', 'capitulo', 'memoria', 'otro'
    ) NOT NULL,

    autores TEXT,
    titulo VARCHAR(1024) NOT NULL,
    revista_o_editorial VARCHAR(512),
    issn_isbn VARCHAR(64),
    volumen VARCHAR(64),
    paginas VARCHAR(64),
    year YEAR,
    doi VARCHAR(255),
    url VARCHAR(512),
    archivo_id BIGINT UNSIGNED,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pub_doc FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: tutorías y asesorías
   --------------------------------------------------------- */
CREATE TABLE tutorias (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    docente_id BIGINT UNSIGNED NOT NULL,

    tipo ENUM(
        'acompanamiento',
        'asesor',
        'tutor_investigacion',
        'direccion_tesis',
        'sinodal'
    ) NOT NULL,

    descripcion TEXT,
    estudiante_nombre VARCHAR(255),
    estudiante_matricula VARCHAR(100),
    programa_educativo VARCHAR(255),
    fecha DATE,
    archivo_id BIGINT UNSIGNED,

    CONSTRAINT fk_tut_doc FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   TABLA: eventos académicos
   --------------------------------------------------------- */
CREATE TABLE eventos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    docente_id BIGINT UNSIGNED NOT NULL,

    tipo ENUM('disciplinario','pedagogico','curso','congreso','otro'),
    nombre VARCHAR(512),
    modalidad ENUM('presencial','virtual','mixto'),
    lugar VARCHAR(512),
    fecha DATE,
    descripcion TEXT,
    archivo_id BIGINT UNSIGNED,

    CONSTRAINT fk_event_doc FOREIGN KEY (docente_id)
        REFERENCES docentes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   ÍNDICES ÚTILES
   --------------------------------------------------------- */

CREATE INDEX idx_docente_empleado ON docentes (empleado_numero);
CREATE INDEX idx_docente_prodep ON docentes (perfil_prodep);
CREATE INDEX idx_docente_sni ON docentes (es_miembro_sni);
CREATE INDEX idx_att_doc_per ON attachments (docente_id, periodo);

