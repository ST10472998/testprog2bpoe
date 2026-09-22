-- Create and select the database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RaceDayDb')
BEGIN
    CREATE DATABASE RaceDayDb;
END
GO
 
USE RaceDayDb;
GO
 
-- Drop tables if they already exist, in FK-safe order, so this script can be re-run cleanly
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

-- Table: Roles
CREATE TABLE dbo.Roles (
    RoleId      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    VARCHAR(20) NOT NULL UNIQUE
);
GO

-- Table: Users
CREATE TABLE dbo.Users (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255) NOT NULL,
    RoleId          INT NOT NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId) ON DELETE NO ACTION
);
GO

-- Table: Events

CREATE TABLE dbo.Events (
    EventId         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT NOT NULL,
    Name            VARCHAR(100) NOT NULL,
    Description     VARCHAR(500) NULL,
    EventDate       DATETIME NOT NULL,
    Location        VARCHAR(150) NOT NULL,
    DistanceKm      DECIMAL(6,2) NOT NULL,
    EventType       VARCHAR(20) NOT NULL CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    BannerImageUrl  VARCHAR(255) NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE
);
GO

-- Table: Categories
CREATE TABLE dbo.Categories (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    EventId         INT NOT NULL,
    Name            VARCHAR(50) NOT NULL,
    MinAge          INT NULL,
    MaxAge          INT NULL,
    DistanceKm      DECIMAL(6,2) NOT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId) ON DELETE CASCADE
);
GO

-- Table: Enrolments

CREATE TABLE dbo.Enrolments (
    EnrolmentId     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId   INT NOT NULL,
    EventId         INT NOT NULL,
    CategoryId      INT NOT NULL,
    EnrolmentDate   DATETIME NOT NULL DEFAULT GETDATE(),
    Status          VARCHAR(20) NOT NULL DEFAULT 'Confirmed' CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId) REFERENCES dbo.Users(UserId) ON DELETE NO ACTION,
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId) ON DELETE NO ACTION,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId) ON DELETE NO ACTION,
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantId, EventId)
);
GO
 
-- Table: Results

CREATE TABLE dbo.Results (
    ResultId        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT NOT NULL UNIQUE, -- one result per enrolment (1-to-1)
    FinishTime      TIME NULL,
    FinishPosition  INT NULL,
    RecordedAt      DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES dbo.Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO

-- Seed Data
 
-- Roles
INSERT INTO dbo.Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO
 
-- Users: 2 Organisers, 2 Participants
-- Passwords below are placeholder BCrypt type hashes for seed purposes only
INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, RoleId)
VALUES
    ('Thandiwe', 'Nkosi', 'thandiwe.nkosi@raceday.co.za', '$2a$11$examplehash0000000000000000000000000000000000000001', 1),
    ('Johan', 'Botha', 'johan.botha@raceday.co.za', '$2a$11$examplehash0000000000000000000000000000000000000002', 1),
    ('Amara', 'Pillay', 'amara.pillay@raceday.co.za', '$2a$11$examplehash0000000000000000000000000000000000000003', 2),
    ('Sipho', 'Dlamini', 'sipho.dlamini@raceday.co.za', '$2a$11$examplehash0000000000000000000000000000000000000004', 2);
GO

-- Events: 3 Events, owned by the two organizers
INSERT INTO dbo.Events (OrganiserId, Name, Description, EventDate, Location, DistanceKm, EventType, BannerImageUrl)
VALUES
    (1, 'Durban Beachfront Fun Run', 'A scenic morning run along the Durban promenade.', '2026-11-15 06:00:00', 'Durban, KwaZulu-Natal', 10.0, 'Run', NULL),
    (1, 'Midlands Cycle Challenge', 'A hilly road cycling event through the KZN Midlands.', '2026-12-06 07:00:00', 'Howick, KwaZulu-Natal', 60.0, 'Cycle', NULL),
    (2, 'Joburg Community Park Walk', 'A family-friendly walk raising funds for local schools.', '2026-10-25 08:00:00', 'Johannesburg, Gauteng', 5.0, 'Walk', NULL);
GO
 
-- Categories: at least one per event
INSERT INTO dbo.Categories (EventId, Name, MinAge, MaxAge, DistanceKm)
VALUES
    (1, '10km Senior', 20, 59, 10.0),
    (1, '10km Under-20', 12, 19, 10.0),
    (2, '60km Open', 18, 99, 60.0),
    (3, '5km Family', 0, 99, 5.0);
GO
 
-- Enrolments: Participants entering events under chosen categories
INSERT INTO dbo.Enrolments (ParticipantId, EventId, CategoryId, Status)
VALUES
    (3, 1, 1, 'Confirmed'),  -- Amara enters the 10km Senior category
    (4, 1, 2, 'Confirmed'),  -- Sipho enters the 10km Under 20 category
    (3, 3, 4, 'Pending');    -- Amara enters the family walk
GO
 
-- Results: captured for a completed enrolment
INSERT INTO dbo.Results (EnrolmentId, FinishTime, FinishPosition)
VALUES
    (1, '00:52:31', 47);
GO
