CREATE database ProjectOtus;

CREATE TABLE cities
(
    id INT,
    city NVARCHAR(50)
);

CREATE TABLE addresses
(
    id INT PRIMARY KEY IDENTITY,
    cityID INT,
    street NVARCHAR(50),
    house INT,
    building NVARCHAR(15)
);
ALTER TABLE addresses ADD FOREIGN KEY (cityID) REFERENCES cities(id);

CREATE TABLE flats
(
    id INT PRIMARY KEY IDENTITY,
    addrID INT REFERENCES addresses(id),
    num INT,
    num_suffix NVARCHAR(8) DEFAULT NULL
);

CREATE TABLE resources
(
    id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(30),
    sensorsCycle INT -- years
);
ALTER TABLE resources ADD DEFAULT(5) for sensorsCycle;

CREATE TABLE sensors
(
    id INT PRIMARY KEY IDENTITY,
    num varchar(30),
    resourceID INT REFERENCES resources(id),
    value INT DEFAULT 0,
    dateProd DATE,
    dateCalibrate DATE
);
ALTER TABLE sensors ADD CHECK (dateCalibrate >= dateProd);


-- positions to install sensors
CREATE TABLE sensorsPositions
(
    id INT PRIMARY KEY IDENTITY,
    flatID INT REFERENCES flats(id),
    resourceID INT REFERENCES resources(id),
    location NVARCHAR(30)
);

CREATE index idx_sp_flatID on sensorsPositions(flatID);

CREATE TABLE flatSensors
(
    id INT PRIMARY KEY IDENTITY,
    sensorID INT REFERENCES sensors(id),
    sensPosID INT REFERENCES sensorsPositions(id),
    dateStart DATE,
    dateStop DATE DEFAULT NULL
);


CREATE TABLE companies
(
    id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(50),
    inn INT
);
ALTER TABLE companies ADD UNIQUE (inn);

