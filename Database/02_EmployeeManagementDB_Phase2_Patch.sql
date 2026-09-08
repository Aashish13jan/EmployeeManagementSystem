/* ============================================================================
   EMPLOYEE MANAGEMENT SYSTEM - PHASE 2 PATCH
   1. Manager existence/soft-delete validation in Create/Update procedures
   2. Filtered unique index to guarantee only one IsCurrentUser = 1 row
   Run this AFTER the main Phase 2 script.
   ============================================================================ */

USE EmployeeManagementDB;
GO


/* ============================================================================
   IMPROVEMENT 1a: sp_CreateEmployee - validate ManagerId
   ============================================================================ */
ALTER PROCEDURE dbo.sp_CreateEmployee
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
    SET XACT_ABORT ON;

    -- NEW: manager must exist and must not be soft-deleted
    IF @ManagerId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE EmployeeId = @ManagerId AND IsDeleted = 0)
    BEGIN
        RAISERROR('MANAGER_NOT_FOUND', 16, 1);
        RETURN;
    END

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

        SELECT @NewEmployeeId AS NewEmployeeId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO


/* ============================================================================
   IMPROVEMENT 1b: sp_UpdateEmployee - validate ManagerId
   ============================================================================ */
ALTER PROCEDURE dbo.sp_UpdateEmployee
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
        RAISERROR('EMPLOYEE_NOT_FOUND', 16, 1);
        RETURN;
    END

    IF @ManagerId = @EmployeeId
    BEGIN
        RAISERROR('EMPLOYEE_CANNOT_MANAGE_SELF', 16, 1);
        RETURN;
    END

    -- NEW: manager must exist and must not be soft-deleted
    IF @ManagerId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE EmployeeId = @ManagerId AND IsDeleted = 0)
    BEGIN
        RAISERROR('MANAGER_NOT_FOUND', 16, 1);
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
   IMPROVEMENT 2: Filtered unique index - only one IsCurrentUser = 1 row
   A normal UNIQUE constraint on IsCurrentUser would only allow ONE row
   total (since 0 would also have to be unique). A FILTERED index solves
   this by only enforcing uniqueness among rows WHERE IsCurrentUser = 1 -
   any number of rows with IsCurrentUser = 0 are unaffected.
   ============================================================================ */
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_UserRoles_OneCurrentUser' AND object_id = OBJECT_ID('dbo.UserRoles')
)
    DROP INDEX UX_UserRoles_OneCurrentUser ON dbo.UserRoles;
GO

CREATE UNIQUE INDEX UX_UserRoles_OneCurrentUser
    ON dbo.UserRoles (IsCurrentUser)
    WHERE IsCurrentUser = 1;
GO


/* ============================================================================
   VERIFICATION (optional - run manually)
   ============================================================================
   -- Should fail with MANAGER_NOT_FOUND (999 does not exist):
   EXEC dbo.sp_CreateEmployee
        @EmployeeCode = 'EMP-TEST', @FirstName = 'Test', @LastName = 'User',
        @Email = 'test.user@company.com', @DesignationId = 1, @ManagerId = 999,
        @JoiningDate = '2024-01-01', @Salary = 500000;

   -- Should fail with a unique-index violation (Anita is already IsCurrentUser = 0,
   -- Rohan is already 1 - trying to flag a second row as current user):
   UPDATE dbo.UserRoles SET IsCurrentUser = 1 WHERE UserName = 'anita.sharma';
   ============================================================================ */
