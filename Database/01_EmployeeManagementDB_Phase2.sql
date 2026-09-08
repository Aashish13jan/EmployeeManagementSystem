/* ============================================================================
   EMPLOYEE MANAGEMENT SYSTEM - PHASE 2
   Database creation, tables, constraints, stored procedures, sample data
   Target: SQL Server 2019+ (works on 2016+ too)
   Execute this script top to bottom in SSMS / Azure Data Studio.
   ============================================================================ */


/* ============================================================================
   SECTION 1: CREATE DATABASE
   ============================================================================ */
IF DB_ID('EmployeeManagementDB') IS NULL
BEGIN
    CREATE DATABASE EmployeeManagementDB;
END
GO

USE EmployeeManagementDB;
GO


/* ============================================================================
   SECTION 2: DROP EXISTING OBJECTS (safe re-run during development)
   Order matters because of foreign keys - children before parents,
   procedures before tables.
   ============================================================================ */
IF OBJECT_ID('dbo.sp_GetCurrentUserRole', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetCurrentUserRole;
IF OBJECT_ID('dbo.sp_GetManagers', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetManagers;
IF OBJECT_ID('dbo.sp_GetDesignations', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetDesignations;
IF OBJECT_ID('dbo.sp_SoftDeleteEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_SoftDeleteEmployee;
IF OBJECT_ID('dbo.sp_UpdateEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateEmployee;
IF OBJECT_ID('dbo.sp_CreateEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateEmployee;
IF OBJECT_ID('dbo.sp_GetEmployeeById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetEmployeeById;
IF OBJECT_ID('dbo.sp_GetActiveEmployees', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetActiveEmployees;

IF OBJECT_ID('dbo.UserRoles', 'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID('dbo.EmployeeEducation', 'U') IS NOT NULL DROP TABLE dbo.EmployeeEducation;
IF OBJECT_ID('dbo.EmployeeCompensation', 'U') IS NOT NULL DROP TABLE dbo.EmployeeCompensation;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Designations', 'U') IS NOT NULL DROP TABLE dbo.Designations;
GO


/* ============================================================================
   SECTION 3: TABLE - Designations
   Lookup table for job titles. Kept separate so the same title isn't
   retyped (and mistyped) on every employee row.
   ============================================================================ */
CREATE TABLE dbo.Designations
(
    DesignationId   INT IDENTITY(1,1)      NOT NULL,
    Title           NVARCHAR(100)          NOT NULL,
    CreatedDate     DATETIME2               NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Designations PRIMARY KEY CLUSTERED (DesignationId),
    CONSTRAINT UQ_Designations_Title UNIQUE (Title)
);
GO


/* ============================================================================
   SECTION 4: TABLE - Employees
   Core personal + employment details. Self-referencing ManagerId gives the
   reporting hierarchy without a separate join table.
   ============================================================================ */
CREATE TABLE dbo.Employees
(
    EmployeeId      INT IDENTITY(1,1)      NOT NULL,
    EmployeeCode    NVARCHAR(20)           NOT NULL,
    FirstName       NVARCHAR(50)           NOT NULL,
    LastName        NVARCHAR(50)           NOT NULL,
    Email           NVARCHAR(150)          NOT NULL,
    PhoneNumber     NVARCHAR(20)           NULL,
    DateOfBirth     DATE                   NULL,

    DesignationId   INT                    NOT NULL,
    ManagerId       INT                    NULL,          -- self-referencing FK
    JoiningDate     DATE                   NOT NULL,
    Status          NVARCHAR(20)           NOT NULL DEFAULT 'Active',

    -- Soft delete
    IsDeleted       BIT                    NOT NULL DEFAULT 0,
    DeletedDate     DATETIME2              NULL,

    -- Audit
    CreatedDate     DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate    DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Employees PRIMARY KEY CLUSTERED (EmployeeId),
    CONSTRAINT UQ_Employees_EmployeeCode UNIQUE (EmployeeCode),
    CONSTRAINT UQ_Employees_Email UNIQUE (Email),
    CONSTRAINT FK_Employees_Designations FOREIGN KEY (DesignationId)
        REFERENCES dbo.Designations (DesignationId),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerId)
        REFERENCES dbo.Employees (EmployeeId),
    CONSTRAINT CK_Employees_Status CHECK (Status IN ('Active', 'Inactive')),
    CONSTRAINT CK_Employees_Email CHECK (Email LIKE '%_@__%.__%')
);
GO

-- Supports the list-page search box (name/email lookups) and manager filter
CREATE NONCLUSTERED INDEX IX_Employees_IsDeleted_Status ON dbo.Employees (IsDeleted, Status);
CREATE NONCLUSTERED INDEX IX_Employees_ManagerId ON dbo.Employees (ManagerId);
GO


/* ============================================================================
   SECTION 5: TABLE - EmployeeCompensation
   Split from Employees on purpose: salary data often needs different
   access rules than the rest of the record, and keeping it out of the
   main table keeps the primary grid query lighter.
   1:1 with Employees.
   ============================================================================ */
CREATE TABLE dbo.EmployeeCompensation
(
    CompensationId  INT IDENTITY(1,1)      NOT NULL,
    EmployeeId      INT                    NOT NULL,
    Salary          DECIMAL(12,2)          NOT NULL,
    CreatedDate     DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate    DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_EmployeeCompensation PRIMARY KEY CLUSTERED (CompensationId),
    CONSTRAINT UQ_EmployeeCompensation_EmployeeId UNIQUE (EmployeeId),  -- enforces 1:1
    CONSTRAINT FK_EmployeeCompensation_Employees FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employees (EmployeeId) ON DELETE CASCADE,
    CONSTRAINT CK_EmployeeCompensation_Salary CHECK (Salary >= 0)
);
GO


/* ============================================================================
   SECTION 6: TABLE - EmployeeEducation
   1:1 with Employees.
   ============================================================================ */
CREATE TABLE dbo.EmployeeEducation
(
    EducationId         INT IDENTITY(1,1)      NOT NULL,
    EmployeeId          INT                    NOT NULL,
    Class10SchoolName   NVARCHAR(150)          NULL,
    Class10Percentage   DECIMAL(5,2)           NULL,
    Class12SchoolName   NVARCHAR(150)          NULL,
    Class12Percentage   DECIMAL(5,2)           NULL,
    CreatedDate         DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate        DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_EmployeeEducation PRIMARY KEY CLUSTERED (EducationId),
    CONSTRAINT UQ_EmployeeEducation_EmployeeId UNIQUE (EmployeeId),   -- enforces 1:1
    CONSTRAINT FK_EmployeeEducation_Employees FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employees (EmployeeId) ON DELETE CASCADE,
    CONSTRAINT CK_EmployeeEducation_Class10Pct CHECK (Class10Percentage IS NULL OR (Class10Percentage BETWEEN 0 AND 100)),
    CONSTRAINT CK_EmployeeEducation_Class12Pct CHECK (Class12Percentage IS NULL OR (Class12Percentage BETWEEN 0 AND 100))
);
GO


/* ============================================================================
   SECTION 7: TABLE - UserRoles
   Simple, non-JWT role simulation. The API will read "the current user's
   role" from here (Phase 3 will treat one row as "the logged-in user" via
   config, since there's no real auth yet).
   ============================================================================ */
CREATE TABLE dbo.UserRoles
(
    UserRoleId      INT IDENTITY(1,1)      NOT NULL,
    UserName        NVARCHAR(100)          NOT NULL,
    Role            NVARCHAR(20)           NOT NULL,
    IsCurrentUser   BIT                    NOT NULL DEFAULT 0,   -- flags which row the API treats as "logged in"
    CreatedDate     DATETIME2              NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_UserRoles PRIMARY KEY CLUSTERED (UserRoleId),
    CONSTRAINT UQ_UserRoles_UserName UNIQUE (UserName),
    CONSTRAINT CK_UserRoles_Role CHECK (Role IN ('Admin', 'Manager', 'User'))
);
GO


/* ============================================================================
   SECTION 8: STORED PROCEDURE - sp_GetActiveEmployees
   Powers the Employee List grid. Supports optional server-side search,
   status filter, and designation filter so the API doesn't have to pull
   the whole table for large datasets.
   Returns one row per employee with DesignationTitle and ManagerName
   already resolved (the grid should not need extra lookups).
   ============================================================================ */
CREATE PROCEDURE dbo.sp_GetActiveEmployees
    @Search         NVARCHAR(150) = NULL,
    @Status         NVARCHAR(20)  = NULL,
    @DesignationId  INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.FirstName,
        e.LastName,
        e.Email,
        e.PhoneNumber,
        e.JoiningDate,
        e.Status,
        d.Title                                    AS Designation,
        m.EmployeeId                                AS ManagerId,
        CASE WHEN m.EmployeeId IS NULL THEN NULL
             ELSE m.FirstName + ' ' + m.LastName END AS ManagerName
    FROM dbo.Employees e
        INNER JOIN dbo.Designations d ON d.DesignationId = e.DesignationId
        LEFT JOIN dbo.Employees m ON m.EmployeeId = e.ManagerId
    WHERE e.IsDeleted = 0
        AND (@Status IS NULL OR e.Status = @Status)
        AND (@DesignationId IS NULL OR e.DesignationId = @DesignationId)
        AND (
            @Search IS NULL
            OR e.FirstName LIKE '%' + @Search + '%'
            OR e.LastName LIKE '%' + @Search + '%'
            OR e.Email LIKE '%' + @Search + '%'
            OR e.EmployeeCode LIKE '%' + @Search + '%'
        )
    ORDER BY e.EmployeeId DESC;
END
GO


/* ============================================================================
   SECTION 9: STORED PROCEDURE - sp_GetEmployeeById
   Powers the Add/Edit form's initial load. Single joined row containing
   personal, employment, compensation, and education details.
   ============================================================================ */
CREATE PROCEDURE dbo.sp_GetEmployeeById
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.FirstName,
        e.LastName,
        e.Email,
        e.PhoneNumber,
        e.DateOfBirth,
        e.DesignationId,
        d.Title                                     AS DesignationTitle,
        e.ManagerId,
        CASE WHEN m.EmployeeId IS NULL THEN NULL
             ELSE m.FirstName + ' ' + m.LastName END AS ManagerName,
        e.JoiningDate,
        e.Status,
        c.Salary,
        ed.Class10SchoolName,
        ed.Class10Percentage,
        ed.Class12SchoolName,
        ed.Class12Percentage
    FROM dbo.Employees e
        INNER JOIN dbo.Designations d ON d.DesignationId = e.DesignationId
        LEFT JOIN dbo.Employees m ON m.EmployeeId = e.ManagerId
        LEFT JOIN dbo.EmployeeCompensation c ON c.EmployeeId = e.EmployeeId
        LEFT JOIN dbo.EmployeeEducation ed ON ed.EmployeeId = e.EmployeeId
    WHERE e.EmployeeId = @EmployeeId
        AND e.IsDeleted = 0;
END
GO


/* ============================================================================
   SECTION 10: STORED PROCEDURE - sp_CreateEmployee
   Inserts across three tables in one transaction. Returns the new
   EmployeeId so the API can build a 201 response with a Location header.
   ============================================================================ */
CREATE PROCEDURE dbo.sp_CreateEmployee
    @EmployeeCode        NVARCHAR(20),
    @FirstName           NVARCHAR(50),
    @LastName            NVARCHAR(50),
    @Email                NVARCHAR(150),
    @PhoneNumber          NVARCHAR(20)   = NULL,
    @DateOfBirth          DATE           = NULL,
    @DesignationId        INT,
    @ManagerId            INT            = NULL,
    @JoiningDate          DATE,
    @Status               NVARCHAR(20)   = 'Active',
    @Salary               DECIMAL(12,2),
    @Class10SchoolName    NVARCHAR(150)  = NULL,
    @Class10Percentage    DECIMAL(5,2)   = NULL,
    @Class12SchoolName    NVARCHAR(150)  = NULL,
    @Class12Percentage    DECIMAL(5,2)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;   -- auto-rollback the whole transaction on any error

    BEGIN TRANSACTION;

    BEGIN TRY
        INSERT INTO dbo.Employees
            (EmployeeCode, FirstName, LastName, Email, PhoneNumber, DateOfBirth,
             DesignationId, ManagerId, JoiningDate, Status)
        VALUES
            (@EmployeeCode, @FirstName, @LastName, @Email, @PhoneNumber, @DateOfBirth,
             @DesignationId, @ManagerId, @JoiningDate, @Status);

        DECLARE @NewEmployeeId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.EmployeeCompensation (EmployeeId, Salary)
        VALUES (@NewEmployeeId, @Salary);

        INSERT INTO dbo.EmployeeEducation
            (EmployeeId, Class10SchoolName, Class10Percentage, Class12SchoolName, Class12Percentage)
        VALUES
            (@NewEmployeeId, @Class10SchoolName, @Class10Percentage, @Class12SchoolName, @Class12Percentage);

        COMMIT TRANSACTION;

        -- Return the new id so the API/repository can read it back
        SELECT @NewEmployeeId AS NewEmployeeId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;  -- re-throw so the API's exception middleware can map it to a 400/500
    END CATCH
END
GO


/* ============================================================================
   SECTION 11: STORED PROCEDURE - sp_UpdateEmployee
   Updates all three tables. Uses UPSERT-style logic (UPDATE, and INSERT
   if a compensation/education row somehow doesn't exist yet) so it's
   resilient even if the child rows were created out of band.
   ============================================================================ */
CREATE PROCEDURE dbo.sp_UpdateEmployee
    @EmployeeId           INT,
    @EmployeeCode         NVARCHAR(20),
    @FirstName            NVARCHAR(50),
    @LastName             NVARCHAR(50),
    @Email                NVARCHAR(150),
    @PhoneNumber          NVARCHAR(20)   = NULL,
    @DateOfBirth          DATE           = NULL,
    @DesignationId        INT,
    @ManagerId            INT            = NULL,
    @JoiningDate          DATE,
    @Status               NVARCHAR(20),
    @Salary               DECIMAL(12,2),
    @Class10SchoolName    NVARCHAR(150)  = NULL,
    @Class10Percentage    DECIMAL(5,2)   = NULL,
    @Class12SchoolName    NVARCHAR(150)  = NULL,
    @Class12Percentage    DECIMAL(5,2)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE EmployeeId = @EmployeeId AND IsDeleted = 0)
    BEGIN
        -- Distinct error number the repository/service layer can catch and map to 404
        RAISERROR('EMPLOYEE_NOT_FOUND', 16, 1);
        RETURN;
    END

    -- Guard against assigning an employee as their own manager
    IF @ManagerId = @EmployeeId
    BEGIN
        RAISERROR('EMPLOYEE_CANNOT_MANAGE_SELF', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE dbo.Employees
        SET EmployeeCode  = @EmployeeCode,
            FirstName     = @FirstName,
            LastName      = @LastName,
            Email         = @Email,
            PhoneNumber   = @PhoneNumber,
            DateOfBirth   = @DateOfBirth,
            DesignationId = @DesignationId,
            ManagerId     = @ManagerId,
            JoiningDate   = @JoiningDate,
            Status        = @Status,
            ModifiedDate  = SYSUTCDATETIME()
        WHERE EmployeeId = @EmployeeId;

        IF EXISTS (SELECT 1 FROM dbo.EmployeeCompensation WHERE EmployeeId = @EmployeeId)
        BEGIN
            UPDATE dbo.EmployeeCompensation
            SET Salary = @Salary,
                ModifiedDate = SYSUTCDATETIME()
            WHERE EmployeeId = @EmployeeId;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.EmployeeCompensation (EmployeeId, Salary)
            VALUES (@EmployeeId, @Salary);
        END

        IF EXISTS (SELECT 1 FROM dbo.EmployeeEducation WHERE EmployeeId = @EmployeeId)
        BEGIN
            UPDATE dbo.EmployeeEducation
            SET Class10SchoolName = @Class10SchoolName,
                Class10Percentage = @Class10Percentage,
                Class12SchoolName = @Class12SchoolName,
                Class12Percentage = @Class12Percentage,
                ModifiedDate = SYSUTCDATETIME()
            WHERE EmployeeId = @EmployeeId;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.EmployeeEducation
                (EmployeeId, Class10SchoolName, Class10Percentage, Class12SchoolName, Class12Percentage)
            VALUES
                (@EmployeeId, @Class10SchoolName, @Class10Percentage, @Class12SchoolName, @Class12Percentage);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO


/* ============================================================================
   SECTION 12: STORED PROCEDURE - sp_SoftDeleteEmployee
   Never removes the row. Flags it and stamps the delete date.
   ============================================================================ */
CREATE PROCEDURE dbo.sp_SoftDeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE EmployeeId = @EmployeeId AND IsDeleted = 0)
    BEGIN
        RAISERROR('EMPLOYEE_NOT_FOUND', 16, 1);
        RETURN;
    END

    UPDATE dbo.Employees
    SET IsDeleted = 1,
        DeletedDate = SYSUTCDATETIME(),
        ModifiedDate = SYSUTCDATETIME()
    WHERE EmployeeId = @EmployeeId;
END
GO


/* ============================================================================
   SECTION 13: STORED PROCEDURE - sp_GetDesignations
   Feeds the Designation dropdown in the Add/Edit form.
   ============================================================================ */
CREATE PROCEDURE dbo.sp_GetDesignations
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DesignationId, Title
    FROM dbo.Designations
    ORDER BY Title;
END
GO


/* ============================================================================
   SECTION 14: STORED PROCEDURE - sp_GetManagers
   Feeds the Manager dropdown. Any active, non-deleted employee can be
   picked as a manager (kept simple - no separate "is manager" flag).
   ============================================================================ */
CREATE PROCEDURE dbo.sp_GetManagers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        EmployeeId,
        FirstName + ' ' + LastName AS FullName
    FROM dbo.Employees
    WHERE IsDeleted = 0
        AND Status = 'Active'
    ORDER BY FirstName, LastName;
END
GO


/* ============================================================================
   SECTION 15: STORED PROCEDURE - sp_GetCurrentUserRole
   No JWT/auth yet - this simulates "who is logged in" by returning the
   row flagged IsCurrentUser = 1 when no username is passed, or a specific
   user's role when one is. The API will call this with no parameter for
   the demo.
   ============================================================================ */
CREATE PROCEDURE dbo.sp_GetCurrentUserRole
    @UserName NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @UserName IS NULL
    BEGIN
        SELECT TOP 1 UserRoleId, UserName, Role
        FROM dbo.UserRoles
        WHERE IsCurrentUser = 1;
    END
    ELSE
    BEGIN
        SELECT TOP 1 UserRoleId, UserName, Role
        FROM dbo.UserRoles
        WHERE UserName = @UserName;
    END
END
GO


/* ============================================================================
   SECTION 16: SAMPLE DATA
   ============================================================================ */

-- Designations
INSERT INTO dbo.Designations (Title) VALUES
    ('Software Engineer'),
    ('Senior Software Engineer'),
    ('QA Engineer'),
    ('HR Manager'),
    ('Engineering Manager'),
    ('Business Analyst');
GO

-- Employees
-- Insert managers first (no ManagerId), then their reports.
INSERT INTO dbo.Employees
    (EmployeeCode, FirstName, LastName, Email, PhoneNumber, DateOfBirth, DesignationId, ManagerId, JoiningDate, Status)
VALUES
    ('EMP-1001', 'Rohan', 'Mehta', 'rohan.mehta@company.com', '9876500001', '1985-03-14',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'Engineering Manager'), NULL, '2018-01-10', 'Active'),

    ('EMP-1002', 'Anita', 'Sharma', 'anita.sharma@company.com', '9876500002', '1987-07-22',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'HR Manager'), NULL, '2017-06-01', 'Active');
GO

INSERT INTO dbo.Employees
    (EmployeeCode, FirstName, LastName, Email, PhoneNumber, DateOfBirth, DesignationId, ManagerId, JoiningDate, Status)
VALUES
    ('EMP-1003', 'Karan', 'Verma', 'karan.verma@company.com', '9876500003', '1992-11-05',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'Senior Software Engineer'),
        (SELECT EmployeeId FROM dbo.Employees WHERE EmployeeCode = 'EMP-1001'), '2019-02-18', 'Active'),

    ('EMP-1004', 'Priya', 'Nair', 'priya.nair@company.com', '9876500004', '1994-01-30',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'Software Engineer'),
        (SELECT EmployeeId FROM dbo.Employees WHERE EmployeeCode = 'EMP-1003'), '2021-08-09', 'Active'),

    ('EMP-1005', 'Vikram', 'Singh', 'vikram.singh@company.com', '9876500005', '1996-05-17',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'Software Engineer'),
        (SELECT EmployeeId FROM dbo.Employees WHERE EmployeeCode = 'EMP-1003'), '2022-03-21', 'Active'),

    ('EMP-1006', 'Sneha', 'Patil', 'sneha.patil@company.com', '9876500006', '1993-09-12',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'QA Engineer'),
        (SELECT EmployeeId FROM dbo.Employees WHERE EmployeeCode = 'EMP-1001'), '2020-11-02', 'Active'),

    ('EMP-1007', 'Arjun', 'Rao', 'arjun.rao@company.com', '9876500007', '1990-12-25',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'Business Analyst'),
        (SELECT EmployeeId FROM dbo.Employees WHERE EmployeeCode = 'EMP-1002'), '2019-07-15', 'Inactive'),

    ('EMP-1008', 'Divya', 'Iyer', 'divya.iyer@company.com', '9876500008', '1995-04-08',
        (SELECT DesignationId FROM dbo.Designations WHERE Title = 'Software Engineer'),
        (SELECT EmployeeId FROM dbo.Employees WHERE EmployeeCode = 'EMP-1003'), '2023-01-16', 'Active');
GO

-- Compensation (one row per employee)
INSERT INTO dbo.EmployeeCompensation (EmployeeId, Salary)
SELECT EmployeeId,
    CASE EmployeeCode
        WHEN 'EMP-1001' THEN 2200000
        WHEN 'EMP-1002' THEN 1900000
        WHEN 'EMP-1003' THEN 1500000
        WHEN 'EMP-1004' THEN 900000
        WHEN 'EMP-1005' THEN 850000
        WHEN 'EMP-1006' THEN 800000
        WHEN 'EMP-1007' THEN 950000
        WHEN 'EMP-1008' THEN 880000
    END
FROM dbo.Employees;
GO

-- Education (one row per employee)
INSERT INTO dbo.EmployeeEducation (EmployeeId, Class10SchoolName, Class10Percentage, Class12SchoolName, Class12Percentage)
SELECT EmployeeId,
    'Delhi Public School', 88.50,
    'Delhi Public School', 84.20
FROM dbo.Employees;
GO

-- User roles (simple role demo - Rohan is treated as the "current" Admin user)
INSERT INTO dbo.UserRoles (UserName, Role, IsCurrentUser) VALUES
    ('rohan.mehta', 'Admin', 1),
    ('anita.sharma', 'Manager', 0),
    ('karan.verma', 'User', 0);
GO


/* ============================================================================
   SECTION 17: QUICK VERIFICATION QUERIES (optional - run manually to check)
   ============================================================================
   EXEC dbo.sp_GetActiveEmployees;
   EXEC dbo.sp_GetActiveEmployees @Search = 'priya';
   EXEC dbo.sp_GetActiveEmployees @Status = 'Inactive';
   EXEC dbo.sp_GetEmployeeById @EmployeeId = 3;
   EXEC dbo.sp_GetDesignations;
   EXEC dbo.sp_GetManagers;
   EXEC dbo.sp_GetCurrentUserRole;
   ============================================================================ */
