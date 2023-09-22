-- Drop everything
-- https://stackoverflow.com/questions/20829105/is-there-a-command-to-delete-drop-everything-in-a-postgres-database
--DROP OWNED BY grp19_2023 CASCADE;

DROP TABLE IF EXISTS vaccinetype CASCADE;
CREATE TABLE vaccinetype (
    id TEXT UNIQUE NOT NULL,
    name VARCHAR(20),
    doses INT CHECK(doses>0),
    tempmin DECIMAL(3,1),
    tempmax DECIMAL(3,1) CHECK(tempMax>tempMin),
    PRIMARY KEY (ID)
);

DROP TABLE IF EXISTS manufacturer CASCADE;
CREATE TABLE manufacturer (
    id TEXT NOT NULL PRIMARY KEY,
    country TEXT,
    phone TEXT CHECK(phone LIKE '+%'),
    vaccine TEXT
);

DROP TABLE IF EXISTS vaccinebatch CASCADE;
CREATE TABLE vaccinebatch (
    batchid TEXT NOT NULL PRIMARY KEY,
    amount INT CHECK(amount>0),
    type TEXT,
    manufacturer TEXT,
    manufDate DATE,
    expiration DATE CHECK(expiration>manufDate),
    location TEXT
);

DROP TABLE IF EXISTS vaccinestation CASCADE;
CREATE TABLE vaccinestation (
    name TEXT NOT NULL PRIMARY KEY,
    address TEXT,
    phone TEXT
);

DROP TABLE IF EXISTS transportationlog CASCADE;
CREATE TABLE transportationlog (
    batchID TEXT NOT NULL,
    arrival TEXT NOT NULL,
    departure TEXT NOT NULL CHECK(departure <> arrival),
    datearr DATE NOT NULL,
    datedep DATE NOT NULL CHECK(datedep >= datearr),
    PRIMARY KEY(batchID,arrival,departure,datearr,datedep)
);

DROP TABLE IF EXISTS staffmember CASCADE;
CREATE TABLE staffmember (
    socialsecuritynumber TEXT NOT NULL PRIMARY KEY,
    name TEXT,
    dateofbirth DATE,
    phone TEXT,
    role TEXT,
    vaccinationstatus INT CHECK(vaccinationstatus=0 OR vaccinationstatus=1),
    hospital TEXT,
    UNIQUE (socialsecuritynumber, hospital)
);

DROP TABLE IF EXISTS shift CASCADE;
CREATE TABLE shift (
    station TEXT NOT NULL,
    weekday TEXT NOT NULL CHECK(weekday IN('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')),
    worker TEXT,
    PRIMARY KEY(station,weekday,worker)
);

DROP TABLE IF EXISTS vaccination CASCADE;
CREATE TABLE vaccination (
    date DATE NOT NULL,
    location TEXT,
    batchid TEXT,
    PRIMARY KEY(date, location)
);

DROP TABLE IF EXISTS patients CASCADE;
CREATE TABLE patients (
    ssno TEXT NOT NULL PRIMARY KEY CHECK(ssno LIKE '%-%'),
    name TEXT,
    dateofbirth DATE,
    gender TEXT CHECK(gender='M' OR gender='F')
);

DROP TABLE IF EXISTS vaccinepatients CASCADE;
CREATE TABLE vaccinepatients (
    date DATE,
    location TEXT,
    patientssno TEXT CHECK(patientssno LIKE '%-%'),
    PRIMARY KEY(patientssno, date) -- Assume one person can't take two vaccines in same day
);

DROP TABLE IF EXISTS symptom CASCADE;
CREATE TABLE symptom (
    name TEXT NOT NULL PRIMARY KEY,
    criticality INT CHECK(criticality IN (0,1))
);

DROP TABLE IF EXISTS diagnosis CASCADE;
CREATE TABLE diagnosis (
    patient TEXT NOT NULL CHECK(patient LIKE '%-%'),
    symptom TEXT,
    date DATE,
    PRIMARY KEY(patient, symptom, date)
);


-- foreign key constraints can be added after data import, so no need
-- to rearrange import steps to solve dependencies.
ALTER TABLE diagnosis ADD FOREIGN KEY (symptom) REFERENCES symptom (name);
ALTER TABLE diagnosis ADD FOREIGN KEY (patient) REFERENCES patients (ssno);
ALTER TABLE vaccinepatients ADD FOREIGN KEY (patientssno) REFERENCES patients (ssno);

ALTER TABLE manufacturer ADD FOREIGN KEY (vaccine) REFERENCES vaccinetype (id);
ALTER TABLE vaccinebatch ADD FOREIGN KEY (type) REFERENCES vaccinetype (id);
ALTER TABLE vaccination ADD FOREIGN KEY (batchid) REFERENCES vaccinebatch (batchid);
ALTER TABLE vaccinepatients ADD FOREIGN KEY (date, location) REFERENCES vaccination (date, location);

ALTER TABLE transportationlog ADD FOREIGN KEY (batchID) REFERENCES vaccinebatch (batchid);
ALTER TABLE transportationlog ADD FOREIGN KEY (departure) REFERENCES vaccinestation(name);
ALTER TABLE transportationlog ADD FOREIGN KEY (arrival) REFERENCES vaccinestation(name);
ALTER TABLE vaccination ADD FOREIGN KEY (location) REFERENCES vaccinestation(name);

ALTER TABLE shift ADD FOREIGN KEY (station) REFERENCES vaccinestation(name);
ALTER TABLE shift ADD FOREIGN KEY (worker, station) REFERENCES staffmember (socialsecuritynumber, hospital);
-- ALTER TABLE staffmember ADD FOREIGN KEY (hospital) REFERENCES vaccinestation(name); -- not needed?
