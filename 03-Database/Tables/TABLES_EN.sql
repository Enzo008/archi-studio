-- *****************************************************************************************************
-- Description       : ArchiStudio Database Schema - Clean Version
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Core tables for ArchiStudio platform
-- 
-- Tables:
--   TB_ROLE           - User roles catalog
--   TM_MENU           - Navigation menus
--   TV_ROLE_MENU      - Role-Menu relationship
--   TM_USER           - System users (Clerk integration)
--   TM_CLIENT         - Clients
--   TB_PROJECT_STATUS - Project status catalog
--   TM_PROJECT        - Projects
--   TB_BUDGET_STATUS  - Budget status catalog
--   TM_BUDGET         - Budgets
--   TD_BUDGET_ITEM    - Budget line items
--   TB_DOCUMENT_TYPE  - Document type catalog
--   TM_DOCUMENT       - Documents/Files
-- *****************************************************************************************************

-- =============================================
-- TB_ROLE - User Roles
-- =============================================
CREATE TABLE TB_ROLE(
    ROLCOD CHAR(02) NOT NULL,
    ROLNAM VARCHAR(50),
    ROLDES VARCHAR(200),
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TB_ROLE
ADD CONSTRAINT PK_TB_ROLE PRIMARY KEY (ROLCOD);
GO

-- =============================================
-- TM_MENU - System Menus
-- =============================================
CREATE TABLE TM_MENU(
    MENYEA CHAR(04) NOT NULL,
    MENCOD CHAR(06) NOT NULL,
    MENNAM VARCHAR(50),
    MENREF VARCHAR(50),
    MENICO VARCHAR(50),
    MENORD VARCHAR(3),
    MENYEAPAR CHAR(04),
    MENCODPAR CHAR(06),
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TM_MENU
ADD CONSTRAINT PK_TM_MENU PRIMARY KEY (MENYEA, MENCOD);

ALTER TABLE TM_MENU
ADD CONSTRAINT FK_TM_MENU_PARENT FOREIGN KEY (MENYEAPAR, MENCODPAR) 
    REFERENCES TM_MENU(MENYEA, MENCOD);
GO

-- =============================================
-- TV_ROLE_MENU - Role-Menu Relationship
-- =============================================
CREATE TABLE TV_ROLE_MENU(
    ROLCOD CHAR(02) NOT NULL,
    MENYEA CHAR(04) NOT NULL,
    MENCOD CHAR(06) NOT NULL,
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TV_ROLE_MENU
ADD CONSTRAINT PK_TV_ROLE_MENU PRIMARY KEY (ROLCOD, MENYEA, MENCOD);

ALTER TABLE TV_ROLE_MENU
ADD CONSTRAINT FK_TV_ROLE_MENU_ROLE FOREIGN KEY (ROLCOD) 
    REFERENCES TB_ROLE(ROLCOD);

ALTER TABLE TV_ROLE_MENU
ADD CONSTRAINT FK_TV_ROLE_MENU_MENU FOREIGN KEY (MENYEA, MENCOD) 
    REFERENCES TM_MENU(MENYEA, MENCOD);
GO

-- =============================================
-- TM_USER - System Users (Clerk Integration)
-- =============================================
CREATE TABLE TM_USER(
    USEYEA CHAR(04) NOT NULL,
    USECOD CHAR(06) NOT NULL,
    USEEXTID NVARCHAR(100),           -- External ID from Clerk
    USENAM VARCHAR(50),
    USELAS VARCHAR(50),
    USEEMA VARCHAR(100),
    USEIMG NVARCHAR(500),             -- Profile image URL
    USESTA CHAR(01),                  -- A=Active, I=Inactive
    ROLCOD CHAR(02),
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TM_USER
ADD CONSTRAINT PK_TM_USER PRIMARY KEY (USEYEA, USECOD);

ALTER TABLE TM_USER
ADD CONSTRAINT FK_TM_USER_ROLE FOREIGN KEY (ROLCOD) 
    REFERENCES TB_ROLE(ROLCOD);

CREATE UNIQUE INDEX IX_TM_USER_EXTID ON TM_USER(USEEXTID) WHERE USEEXTID IS NOT NULL;
CREATE INDEX IX_TM_USER_EMAIL ON TM_USER(USEEMA);
GO

-- =============================================
-- TM_CLIENT - Clients (per user - multitenancy)
-- =============================================
CREATE TABLE TM_CLIENT(
    CLIYEA CHAR(04) NOT NULL,
    CLICOD CHAR(06) NOT NULL,
    CLINAM VARCHAR(100),
    CLITYP CHAR(02),                  -- 01=Person, 02=Company
    CLIEMA VARCHAR(100),
    CLIPHO VARCHAR(20),
    CLIADD VARCHAR(200),
    CLISTA CHAR(01),                  -- A=Active, I=Inactive
    CLIDES VARCHAR(500),
    -- Owner User (multitenancy)
    USEYEA CHAR(04),
    USECOD CHAR(06),
    -- Audit
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TM_CLIENT
ADD CONSTRAINT PK_TM_CLIENT PRIMARY KEY (CLIYEA, CLICOD);

ALTER TABLE TM_CLIENT
ADD CONSTRAINT FK_TM_CLIENT_USER FOREIGN KEY (USEYEA, USECOD) 
    REFERENCES TM_USER(USEYEA, USECOD);

CREATE INDEX IX_TM_CLIENT_EMAIL ON TM_CLIENT(CLIEMA);
CREATE INDEX IX_TM_CLIENT_USER ON TM_CLIENT(USEYEA, USECOD);
GO

-- =============================================
-- TB_PROJECT_STATUS - Project Status Catalog
-- =============================================
CREATE TABLE TB_PROJECT_STATUS(
    PROSTA CHAR(02) NOT NULL,
    PROSTANAM VARCHAR(50),
    PROSTAORD INT,
    PROSTAICO VARCHAR(50),
    PROSTACOL VARCHAR(20),
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TB_PROJECT_STATUS
ADD CONSTRAINT PK_TB_PROJECT_STATUS PRIMARY KEY (PROSTA);
GO

-- =============================================
-- TM_PROJECT - Projects
-- =============================================
CREATE TABLE TM_PROJECT(
    PROYEA CHAR(04) NOT NULL,
    PROCOD CHAR(06) NOT NULL,
    PRONAM VARCHAR(200),
    PRODES VARCHAR(500),
    PROSTA CHAR(02),
    PROPRO INT DEFAULT 0,             -- Progress 0-100
    PRODATINI DATE,
    PRODATEND DATE,
    PROBUDGET DECIMAL(18,2),
    PROADD VARCHAR(200),
    -- Foreign Keys
    CLIYEA CHAR(04),
    CLICOD CHAR(06),
    USEYEA CHAR(04),
    USECOD CHAR(06),
    -- Audit
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TM_PROJECT
ADD CONSTRAINT PK_TM_PROJECT PRIMARY KEY (PROYEA, PROCOD);

ALTER TABLE TM_PROJECT
ADD CONSTRAINT FK_TM_PROJECT_STATUS FOREIGN KEY (PROSTA) 
    REFERENCES TB_PROJECT_STATUS(PROSTA);

ALTER TABLE TM_PROJECT
ADD CONSTRAINT FK_TM_PROJECT_CLIENT FOREIGN KEY (CLIYEA, CLICOD) 
    REFERENCES TM_CLIENT(CLIYEA, CLICOD);

ALTER TABLE TM_PROJECT
ADD CONSTRAINT FK_TM_PROJECT_USER FOREIGN KEY (USEYEA, USECOD) 
    REFERENCES TM_USER(USEYEA, USECOD);

CREATE INDEX IX_TM_PROJECT_STATUS ON TM_PROJECT(PROSTA);
GO

-- =============================================
-- TB_BUDGET_STATUS - Budget Status Catalog
-- =============================================
CREATE TABLE TB_BUDGET_STATUS(
    BUDSTA CHAR(02) NOT NULL,
    BUDSTANAM VARCHAR(50),
    BUDSTAORD INT,
    BUDSTAICO VARCHAR(50),
    BUDSTACOL VARCHAR(20),
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TB_BUDGET_STATUS
ADD CONSTRAINT PK_TB_BUDGET_STATUS PRIMARY KEY (BUDSTA);
GO

-- =============================================
-- TM_BUDGET - Budgets
-- =============================================
CREATE TABLE TM_BUDGET(
    BUDYEA CHAR(04) NOT NULL,
    BUDCOD CHAR(06) NOT NULL,
    BUDNAM VARCHAR(200),
    BUDDES VARCHAR(500),
    BUDSTA CHAR(02),
    BUDTOT DECIMAL(18,2) DEFAULT 0,
    BUDDAT DATE,
    BUDEXP DATE,
    BUDNOT VARCHAR(1000),
    -- Foreign Keys
    PROYEA CHAR(04),
    PROCOD CHAR(06),
    -- Audit
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TM_BUDGET
ADD CONSTRAINT PK_TM_BUDGET PRIMARY KEY (BUDYEA, BUDCOD);

ALTER TABLE TM_BUDGET
ADD CONSTRAINT FK_TM_BUDGET_STATUS FOREIGN KEY (BUDSTA) 
    REFERENCES TB_BUDGET_STATUS(BUDSTA);

ALTER TABLE TM_BUDGET
ADD CONSTRAINT FK_TM_BUDGET_PROJECT FOREIGN KEY (PROYEA, PROCOD) 
    REFERENCES TM_PROJECT(PROYEA, PROCOD);
GO

-- TD_BUDGET_ITEM - Budget Line Items
-- =============================================
CREATE TABLE TD_BUDGET_ITEM(
    BUDYEA CHAR(04) NOT NULL,
    BUDCOD CHAR(06) NOT NULL,
    BUDITENUM INT NOT NULL,
    BUDITENAM VARCHAR(200),
    BUDITEQTY DECIMAL(10,2) DEFAULT 1,
    BUDITEUNI VARCHAR(20),
    BUDITEPRI DECIMAL(18,2) DEFAULT 0,
    BUDITETOT DECIMAL(18,2) DEFAULT 0,
    BUDITESTA CHAR(02),
    BUDITENOT VARCHAR(500),
    BUDITEIMGPAT VARCHAR(500),         -- File path (e.g., "budgets/2025/000001/uuid.jpg")
    BUDITEIMGFIL VARCHAR(200),         -- Original filename
    BUDITEIMGSIZ BIGINT,               -- File size in bytes
    BUDITEIMGMIM VARCHAR(100),         -- MIME type (image/jpeg, etc.)
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TD_BUDGET_ITEM
ADD CONSTRAINT PK_TD_BUDGET_ITEM PRIMARY KEY (BUDYEA, BUDCOD, BUDITENUM);

ALTER TABLE TD_BUDGET_ITEM
ADD CONSTRAINT FK_TD_BUDGET_ITEM_BUDGET FOREIGN KEY (BUDYEA, BUDCOD) 
    REFERENCES TM_BUDGET(BUDYEA, BUDCOD);
GO

-- =============================================
-- TB_DOCUMENT_TYPE - Document Type Catalog
-- =============================================
CREATE TABLE TB_DOCUMENT_TYPE(
    DOCTYP CHAR(02) NOT NULL,
    DOCTYPNAM VARCHAR(50),
    DOCTYPICO VARCHAR(50),
    DOCTYPEXT VARCHAR(100),
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TB_DOCUMENT_TYPE
ADD CONSTRAINT PK_TB_DOCUMENT_TYPE PRIMARY KEY (DOCTYP);
GO

-- =============================================
-- TM_DOCUMENT - Documents/Files
-- =============================================
CREATE TABLE TM_DOCUMENT(
    DOCYEA CHAR(04) NOT NULL,
    DOCCOD CHAR(06) NOT NULL,
    DOCNAM VARCHAR(200),
    DOCDES VARCHAR(500),
    DOCTYP CHAR(02),
    DOCPAT VARCHAR(500),
    DOCFIL VARCHAR(200),
    DOCSIZ BIGINT,
    DOCMIM VARCHAR(100),
    DOCSTA CHAR(01),
    -- Foreign Keys (optional)
    PROYEA CHAR(04),
    PROCOD CHAR(06),
    -- Audit
    USECRE VARCHAR(30),
    DATCRE DATETIME,
    ZONCRE VARCHAR(50),
    USEUPD VARCHAR(30),
    DATUPD DATETIME,
    ZONUPD VARCHAR(50),
    STAREC CHAR(1)
);

ALTER TABLE TM_DOCUMENT
ADD CONSTRAINT PK_TM_DOCUMENT PRIMARY KEY (DOCYEA, DOCCOD);

ALTER TABLE TM_DOCUMENT
ADD CONSTRAINT FK_TM_DOCUMENT_TYPE FOREIGN KEY (DOCTYP) 
    REFERENCES TB_DOCUMENT_TYPE(DOCTYP);

ALTER TABLE TM_DOCUMENT
ADD CONSTRAINT FK_TM_DOCUMENT_PROJECT FOREIGN KEY (PROYEA, PROCOD) 
    REFERENCES TM_PROJECT(PROYEA, PROCOD);
GO

-- =============================================
-- SEED DATA - Catalogs
-- =============================================

-- Roles (01=Admin, 02=User, 03=Supervisor)
INSERT INTO TB_ROLE (ROLCOD, ROLNAM, ROLDES, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('01', 'Administrador', 'Acceso completo al sistema', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', 'Usuario', 'Usuario estándar - gestión de proyectos propios', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', 'Supervisor', 'Supervisión y revisión de proyectos', 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Project Status
INSERT INTO TB_PROJECT_STATUS (PROSTA, PROSTANAM, PROSTAORD, PROSTAICO, PROSTACOL, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('01', 'Borrador', 1, 'FileEdit', '#6b7280', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', 'En Progreso', 2, 'Loader', '#3b82f6', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', 'En Revisión', 3, 'Eye', '#f59e0b', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('04', 'Completado', 4, 'CheckCircle', '#22c55e', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('05', 'Cancelado', 5, 'XCircle', '#ef4444', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('06', 'En Pausa', 6, 'PauseCircle', '#8b5cf6', 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Budget Status
INSERT INTO TB_BUDGET_STATUS (BUDSTA, BUDSTANAM, BUDSTAORD, BUDSTAICO, BUDSTACOL, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('01', 'Borrador', 1, 'FileEdit', '#6b7280', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', 'Enviado', 2, 'Send', '#3b82f6', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', 'En Revisión', 3, 'Eye', '#f59e0b', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('04', 'Aprobado', 4, 'CheckCircle', '#22c55e', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('05', 'Rechazado', 5, 'XCircle', '#ef4444', 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Document Types
INSERT INTO TB_DOCUMENT_TYPE (DOCTYP, DOCTYPNAM, DOCTYPICO, DOCTYPEXT, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('01', 'Plano', 'FileText', '.pdf,.dwg,.dxf', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', 'Render', 'Image', '.jpg,.jpeg,.png,.webp', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', 'Contrato', 'FileCheck', '.pdf,.doc,.docx', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('04', 'Presupuesto', 'FileSpreadsheet', '.pdf,.xls,.xlsx', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('05', 'Fotografía', 'Camera', '.jpg,.jpeg,.png,.heic', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('06', 'Otro', 'File', '*', 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Menus
INSERT INTO TM_MENU (MENYEA, MENCOD, MENNAM, MENREF, MENICO, MENORD, MENYEAPAR, MENCODPAR, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000001', 'Dashboard', '/dashboard', 'LayoutDashboard', '001', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 'Proyectos', '/projects', 'FolderKanban', '002', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 'Clientes', '/clients', 'Users', '003', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000004', 'Presupuestos', '/budgets', 'Calculator', '004', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 'Documentos', '/documents', 'FileText', '005', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000006', 'Configuración', '/settings', 'Settings', '006', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000007', 'Calendario', '/calendar', 'Calendar', '007', NULL, NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Role-Menu Assignments
INSERT INTO TV_ROLE_MENU (ROLCOD, MENYEA, MENCOD, USECRE, DATCRE, ZONCRE, STAREC) VALUES
-- Administrador (all menus)
('01', '2025', '000001', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('01', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('01', '2025', '000003', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('01', '2025', '000004', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('01', '2025', '000005', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('01', '2025', '000006', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- Usuario (all except settings)
('02', '2025', '000001', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', '2025', '000003', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', '2025', '000004', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', '2025', '000005', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', '2025', '000006', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('02', '2025', '000007', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- Supervisor (dashboard, projects, documents)
('03', '2025', '000001', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', '2025', '000003', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', '2025', '000004', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', '2025', '000005', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', '2025', '000006', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('03', '2025', '000007', 'SYSTEM', GETDATE(), 'America/Lima', 'C');
GO

-- =============================================
-- SEED DATA - Users
-- =============================================
INSERT INTO TM_USER (USEYEA, USECOD, USEEXTID, USENAM, USELAS, USEEMA, USEIMG, USESTA, ROLCOD, USECRE, DATCRE, ZONCRE, STAREC) VALUES
-- Admin user (2025-000001)
('2025', '000001', NULL, 'Enzo', 'Aguirre', 'enzoaguirre629@gmail.com', NULL, 'A', '01', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- Demo user (2025-000002) - Este será el usuario de prueba
('2025', '000002', NULL, 'Carlos', 'Mendoza', 'carlos.mendoza@archistudio.pe', NULL, 'A', '02', 'SYSTEM', GETDATE(), 'America/Lima', 'C');
GO

-- =============================================
-- SEED DATA - Clients (for demo user 2025-000002)
-- =============================================
INSERT INTO TM_CLIENT (CLIYEA, CLICOD, CLINAM, CLITYP, CLIEMA, CLIPHO, CLIADD, CLISTA, CLIDES, USEYEA, USECOD, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000001', 'María García López', '01', 'maria.garcia@gmail.com', '+51 999 111 222', 'Av. Javier Prado 1234, San Isidro', 'A', 'Cliente frecuente, proyectos residenciales', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 'Constructora Los Andes SAC', '02', 'proyectos@losandes.pe', '+51 1 456 7890', 'Calle Las Begonias 456, San Isidro', 'A', 'Empresa constructora mediana, proyectos comerciales', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 'Roberto Fernández Torres', '01', 'roberto.fernandez@outlook.com', '+51 987 654 321', 'Jr. Tacna 789, Miraflores', 'A', 'Inversionista inmobiliario', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000004', 'Inmobiliaria Costa Verde', '02', 'contacto@costaverde.pe', '+51 1 234 5678', 'Av. La Marina 2345, San Miguel', 'A', 'Desarrolladora de condominios', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 'Ana Lucía Ramírez', '01', 'ana.ramirez@hotmail.com', '+51 912 345 678', 'Calle Los Pinos 567, La Molina', 'A', 'Proyectos de remodelación', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000006', 'Grupo Empresarial Pacífico', '02', 'arquitectura@grupopacifico.pe', '+51 1 567 8901', 'Av. Arequipa 3456, Lince', 'A', 'Oficinas corporativas y locales comerciales', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000007', 'Pedro Sánchez Díaz', '01', 'pedro.sanchez@gmail.com', '+51 923 456 789', 'Av. Primavera 890, Surco', 'A', 'Casa de playa y campo', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000008', 'Hotel Boutique Lima', '02', 'gerencia@hotelboutiquelima.pe', '+51 1 678 9012', 'Calle Bolognesi 123, Barranco', 'A', 'Remodelación y ampliación hotelera', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000009', 'Carmen Vega Ruiz', '01', 'carmen.vega@yahoo.com', '+51 934 567 890', 'Jr. Huallaga 456, Centro de Lima', 'A', 'Restauración de casona antigua', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000010', 'Restaurantes del Norte SAC', '02', 'expansion@restaurantesdelnorte.pe', '+51 1 789 0123', 'Av. Conquistadores 789, San Isidro', 'A', 'Diseño de locales gastronómicos', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000011', 'Luis Alberto Morales', '01', 'luis.morales@gmail.com', '+51 945 678 901', 'Calle Las Flores 234, Chacarilla', 'A', 'Departamento dúplex', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000012', 'Clínica San Gabriel', '02', 'infraestructura@clinicasangabriel.pe', '+51 1 890 1234', 'Av. Brasil 567, Jesús María', 'A', 'Ampliación de instalaciones médicas', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C');
GO

-- =============================================
-- SEED DATA - Projects (for demo user 2025-000002)
-- =============================================
INSERT INTO TM_PROJECT (PROYEA, PROCOD, PRONAM, PRODES, PROSTA, PROPRO, PRODATINI, PRODATEND, PROBUDGET, PROADD, CLIYEA, CLICOD, USEYEA, USECOD, USECRE, DATCRE, ZONCRE, STAREC) VALUES
-- En Progreso
('2025', '000001', 'Residencia García - San Isidro', 'Diseño de casa unifamiliar de 3 niveles con jardín interior, piscina y área social. Estilo contemporáneo con acabados premium.', '02', 65, '2025-01-15', '2025-06-30', 450000.00, 'Av. Javier Prado 1234, San Isidro', '2025', '000001', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 'Edificio Corporativo Los Andes', 'Torre de oficinas de 12 pisos con estacionamiento subterráneo. Certificación LEED en proceso.', '02', 40, '2025-02-01', '2026-03-15', 2800000.00, 'Calle Las Begonias 456, San Isidro', '2025', '000002', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 'Penthouse Fernández - Miraflores', 'Remodelación integral de penthouse de 280m². Terraza con vista al mar, cocina gourmet.', '02', 80, '2025-01-10', '2025-04-20', 180000.00, 'Malecón Cisneros 890, Miraflores', '2025', '000003', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- En Revisión
('2025', '000004', 'Condominio Costa Verde - Fase 1', 'Primera fase del condominio: 4 torres de 8 pisos cada una. Áreas comunes, gimnasio y coworking.', '03', 25, '2025-03-01', '2026-12-31', 5500000.00, 'Av. La Marina 2345, San Miguel', '2025', '000004', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 'Casa de Campo Ramírez', 'Diseño de casa de campo estilo rústico moderno. 4 habitaciones, sala de juegos, quincho.', '03', 15, '2025-04-01', '2025-10-30', 320000.00, 'Km 45 Carretera Cieneguilla', '2025', '000005', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- Borrador
('2025', '000006', 'Oficinas Grupo Pacífico', 'Diseño de interiores para oficinas corporativas en piso 15 de torre empresarial.', '01', 5, '2025-05-15', '2025-08-30', 95000.00, 'Av. Arequipa 3456, Piso 15, Lince', '2025', '000006', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000007', 'Casa Playa Asia - Sánchez', 'Casa de playa minimalista. 3 niveles, piscina infinity, acceso directo a playa privada.', '01', 0, '2025-06-01', '2026-01-15', 680000.00, 'Boulevard Asia Km 97.5', '2025', '000007', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- Completado
('2025', '000008', 'Remodelación Hotel Boutique Lima', 'Renovación de 25 habitaciones, lobby, restaurante y terraza con vista a Barranco.', '04', 100, '2024-08-01', '2025-01-30', 420000.00, 'Calle Bolognesi 123, Barranco', '2025', '000008', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000009', 'Restauración Casona Vega', 'Restauración de casona republicana de 1920. Conservación de fachada original, modernización interior.', '04', 100, '2024-06-15', '2024-12-20', 280000.00, 'Jr. Huallaga 456, Centro de Lima', '2025', '000009', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- En Pausa
('2025', '000010', 'Local Restaurantes del Norte - Surco', 'Diseño de nuevo local gastronómico de 350m². Cocina abierta, barra, terraza techada.', '06', 35, '2025-02-15', '2025-07-30', 145000.00, 'Av. Primavera 1234, Surco', '2025', '000010', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
-- Más proyectos en progreso
('2025', '000011', 'Departamento Dúplex Morales', 'Diseño interior de dúplex de 180m². Estilo industrial con toques cálidos.', '02', 55, '2025-03-10', '2025-06-15', 65000.00, 'Calle Las Flores 234, Chacarilla', '2025', '000011', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000012', 'Ampliación Clínica San Gabriel', 'Nueva ala de especialidades: 8 consultorios, sala de procedimientos, farmacia.', '02', 20, '2025-04-01', '2025-12-15', 890000.00, 'Av. Brasil 567, Jesús María', '2025', '000012', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C');
GO

-- =============================================
-- SEED DATA - Budgets (sample for some projects)
-- =============================================
INSERT INTO TM_BUDGET (BUDYEA, BUDCOD, BUDNAM, BUDDES, BUDSTA, BUDTOT, BUDDAT, BUDEXP, BUDNOT, PROYEA, PROCOD, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000001', 'Presupuesto Inicial - Residencia García', 'Presupuesto base para construcción y acabados', '04', 450000.00, '2025-01-10', '2025-02-10', 'Aprobado por cliente', '2025', '000001', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 'Presupuesto Fase 1 - Edificio Los Andes', 'Cimentación y estructura', '04', 1200000.00, '2025-01-25', '2025-02-25', 'Primera fase aprobada', '2025', '000002', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 'Presupuesto Remodelación Penthouse', 'Incluye demolición, obra civil y acabados', '04', 180000.00, '2025-01-05', '2025-01-20', NULL, '2025', '000003', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000004', 'Propuesta Condominio Costa Verde', 'Presupuesto preliminar sujeto a revisión', '03', 5500000.00, '2025-02-20', '2025-03-20', 'En revisión por directorio', '2025', '000004', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 'Cotización Casa Campo Ramírez', 'Presupuesto referencial', '02', 320000.00, '2025-03-25', '2025-04-25', 'Enviado al cliente', '2025', '000005', 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000006', 'Presupuesto Hotel Boutique Lima', 'Presupuesto final ejecutado', '04', 420000.00, '2024-07-15', '2024-08-15', 'Proyecto completado exitosamente', '2025', '000008', 'SYSTEM', GETDATE(), 'America/Lima', 'C');
GO

-- =============================================
-- SEED DATA - Budget Items (sample items for budgets)
-- =============================================

-- Items for Budget 2025-000001 (Residencia García)
INSERT INTO TD_BUDGET_ITEM (BUDYEA, BUDCOD, BUDITENUM, BUDITENAM, BUDITEQTY, BUDITEUNI, BUDITEPRI, BUDITETOT, BUDITESTA, BUDITENOT, BUDITEIMG, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000001', 1, 'Cimentación y zapatas', 1, 'GLB', 45000.00, 45000.00, '01', 'Incluye excavación, fierro y concreto f''c=210', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 2, 'Estructura de concreto armado', 1, 'GLB', 85000.00, 85000.00, '01', 'Columnas, vigas y losas', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 3, 'Muros de albañilería', 250, 'm2', 120.00, 30000.00, '01', 'Ladrillo King Kong 18 huecos', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 4, 'Instalaciones eléctricas', 1, 'GLB', 35000.00, 35000.00, '01', 'Incluye tableros, cableado y luminarias', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 5, 'Instalaciones sanitarias', 1, 'GLB', 28000.00, 28000.00, '01', 'Red de agua fría, caliente y desagüe', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 6, 'Acabados interiores', 1, 'GLB', 120000.00, 120000.00, '01', 'Pisos, pintura, carpintería', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 7, 'Ventanas y mamparas', 45, 'm2', 850.00, 38250.00, '01', 'Vidrio templado con marco de aluminio', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 8, 'Puertas interiores', 12, 'und', 1200.00, 14400.00, '01', 'Contraplacadas con marco de madera', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 9, 'Puerta principal', 1, 'und', 4500.00, 4500.00, '01', 'Madera cedro con acabado barnizado', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000001', 10, 'Aparatos sanitarios', 1, 'GLB', 18000.00, 18000.00, '01', 'Inodoros, lavatorios, griferías', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Items for Budget 2025-000002 (Edificio Los Andes - Fase 1)
INSERT INTO TD_BUDGET_ITEM (BUDYEA, BUDCOD, BUDITENUM, BUDITENAM, BUDITEQTY, BUDITEUNI, BUDITEPRI, BUDITETOT, BUDITESTA, BUDITENOT, BUDITEIMG, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000002', 1, 'Movimiento de tierras', 1, 'GLB', 85000.00, 85000.00, '01', 'Excavación masiva, eliminación de material', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 2, 'Calzaduras perimetrales', 48, 'ml', 1500.00, 72000.00, '01', 'Protección colindantes', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 3, 'Muro pantalla', 1, 'GLB', 180000.00, 180000.00, '01', 'Muros de contención perimetrales', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 4, 'Cimentación platea', 1, 'GLB', 250000.00, 250000.00, '01', 'Platea de cimentación f''c=280', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 5, 'Estructura sótanos', 2, 'niv', 150000.00, 300000.00, '01', 'Columnas, placas, vigas y losas sótanos', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000002', 6, 'Estructura pisos 1-5', 5, 'niv', 62600.00, 313000.00, '01', 'Columnas, placas, vigas y losas típicas', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Items for Budget 2025-000003 (Remodelación Penthouse)
INSERT INTO TD_BUDGET_ITEM (BUDYEA, BUDCOD, BUDITENUM, BUDITENAM, BUDITEQTY, BUDITEUNI, BUDITEPRI, BUDITETOT, BUDITESTA, BUDITENOT, BUDITEIMG, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000003', 1, 'Demolición selectiva', 1, 'GLB', 8000.00, 8000.00, '01', 'Retiro de muros, pisos y cielos', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 2, 'Distribución nueva tabiquería', 85, 'm2', 180.00, 15300.00, '01', 'Drywall con estructura metálica', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 3, 'Piso porcelanato importado', 180, 'm2', 250.00, 45000.00, '01', 'Porcelanato 1.20x1.20 rectificado', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 4, 'Cocina integral', 1, 'GLB', 45000.00, 45000.00, '01', 'Muebles altos/bajos, isla, electrodomésticos', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 5, 'Baños completos', 3, 'und', 12000.00, 36000.00, '01', 'Remodelación integral baños', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 6, 'Iluminación arquitectónica', 1, 'GLB', 18500.00, 18500.00, '01', 'LED empotrado, spots, cintas indirectas', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000003', 7, 'Pintura y acabados', 1, 'GLB', 12200.00, 12200.00, '01', 'Pintura látex, detalles decorativos', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C');

-- Items for Budget 2025-000005 (Casa Campo Ramírez)
INSERT INTO TD_BUDGET_ITEM (BUDYEA, BUDCOD, BUDITENUM, BUDITENAM, BUDITEQTY, BUDITEUNI, BUDITEPRI, BUDITETOT, BUDITESTA, BUDITENOT, BUDITEIMG, USECRE, DATCRE, ZONCRE, STAREC) VALUES
('2025', '000005', 1, 'Diseño arquitectónico', 1, 'GLB', 25000.00, 25000.00, '01', 'Planos completos, renders 3D', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 2, 'Tramitación municipal', 1, 'GLB', 8000.00, 8000.00, '01', 'Licencia de construcción', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 3, 'Obra civil básica', 1, 'GLB', 145000.00, 145000.00, '01', 'Cimentación, estructura, cerramientos', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 4, 'Instalaciones completas', 1, 'GLB', 42000.00, 42000.00, '01', 'Eléctricas, sanitarias, gas', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 5, 'Acabados estándar', 1, 'GLB', 75000.00, 75000.00, '01', 'Pisos, revestimientos, carpintería', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C'),
('2025', '000005', 6, 'Áreas exteriores', 1, 'GLB', 25000.00, 25000.00, '01', 'Jardín, cerco, estacionamiento', NULL, 'SYSTEM', GETDATE(), 'America/Lima', 'C');
GO

PRINT '✅ ArchiStudio Database Schema created successfully!';
PRINT '📊 Seed data includes:';
PRINT '   - 3 Roles (Admin, User, Supervisor)';
PRINT '   - 2 Users (Admin + Demo User)';
PRINT '   - 12 Clients (for Demo User)';
PRINT '   - 12 Projects (various statuses)';
PRINT '   - 6 Budgets (sample)';
PRINT '   - 29 Budget Items (detailed line items)';
GO

