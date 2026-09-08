# Employee Management System

Internal-style Employee Management System.
Backend: ASP.NET Core Web API (.NET 8) + EF Core + SQL Server stored procedures, Repository → Service → Controller architecture.
Frontend: React + Vite + Material UI + Material React Table + Axios + React Router.

## Status: feature-complete for the defined scope

Database, backend, and frontend are all implemented end to end. No authentication/JWT (by design - simple simulated role-based UI only, per project scope).

## Project structure

```
EmployeeManagementSystem/
├── EmployeeManagementSystem.sln
├── EmployeeManagement.API/         (ASP.NET Core Web API)
│   ├── Controllers/EmployeesController.cs
│   ├── Middleware/ExceptionHandlingMiddleware.cs
│   ├── Services/ + Repositories/ + DTOs/ + Models/ + Data/ + Exceptions/
│   └── Program.cs, appsettings.json
├── employee-management-ui/         (React + Vite frontend)
│   └── src/{api,components,pages,context}/...
└── Database/
    ├── 01_EmployeeManagementDB_Phase2.sql
    └── 02_EmployeeManagementDB_Phase2_Patch.sql
```

## Setup: Database

Run both scripts in `Database/`, in order, against your SQL Server instance (SSMS or Azure Data Studio).

## Setup: Backend

1. Open `EmployeeManagementSystem.sln`.
2. Update `EmployeeManagement.API/appsettings.json` → `ConnectionStrings:DefaultConnection` to match your SQL Server instance.
3. `dotnet restore && dotnet build` (or Build in Visual Studio).
4. `dotnet run` (or F5). Note the port it starts on (e.g. `https://localhost:7001`) - Swagger loads at `/swagger` and now shows all 8 endpoints.

## Setup: Frontend

1. `cd employee-management-ui`
2. `npm install`
3. `cp .env.example .env`, then set `VITE_API_BASE_URL` to match the backend port from the step above (e.g. `https://localhost:7001/api`).
4. `npm run dev` → opens at `http://localhost:5173`.

Since the backend uses a local HTTPS dev certificate, your browser may warn about it the first time you load the app - this is normal for local ASP.NET Core dev and can be trusted via `dotnet dev-certs https --trust` if you haven't already.

## What's implemented

- Employee List: search, status filter, sorting (via Material React Table), loading/empty/error states, role-based Add/Edit/Delete visibility
- Add/Edit Employee: sectioned form (Personal/Employment/Compensation/Education), client + server-side validation, self-manager prevention
- Soft delete with confirmation dialog
- Role simulation via `sp_GetCurrentUserRole` (Admin/Manager can edit, User is read-only) - shown as a chip in the app bar
- Consistent JSON error handling end to end (SQL RAISERROR → SqlException → custom exception → middleware → Axios → UI message)

## Known limitation

The simulated "current user" is whichever row has `IsCurrentUser = 1` in the `UserRoles` table (defaults to the Admin, `rohan.mehta`). To test the read-only "User" experience, update that flag in SQL:
```sql
UPDATE dbo.UserRoles SET IsCurrentUser = 0 WHERE UserName = 'rohan.mehta';
UPDATE dbo.UserRoles SET IsCurrentUser = 1 WHERE UserName = 'karan.verma';
```
