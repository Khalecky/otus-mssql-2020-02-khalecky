create database project_otus;

create table cities
(
    id int identity(1,1) primary key,
    city varchar(255)
);

create table addresses
(
    id int identity(1,1) primary key,
    city_id int,
    street varchar(255),
    house int,
    building varchar(15)
);
alter table addresses add constraint FK_addr_city foreign key (city_id) references cities(id);

create table flats
(
    id int identity(1,1) primary key,
    addr_id int references addresses(id),
    num int,
    num_suffix varchar(7) default null
);

create table resources
(
    id int identity(1,1) primary key,
    name varchar(255),
    sensors_cycle int -- years
);
alter table resources add constraint DF_res_cycle default(5) for sensors_cycle;

create table sensors
(
    id int identity(1,1) primary key,
    num varchar(30),
    res_id int references resources(id),
    value int default 0,
    date_prod date,
    date_calibrate date
);
alter table sensors add constraint CK_sensors_dates check (date_calibrate >= date_prod);


-- positions to install sensors
create table sensors_positions
(
    id int identity(1,1) primary key,
    flat_id int references flats(id),
    res_id int references resources(id),
    location varchar(15)
);

create table flat_sensors
(
    id int identity(1,1) primary key,
    sensor_id int references sensors(id),
    sens_pos_id int references sensors_positions(id),
    date_start date,
    date_stop date default null
);

create table companies
(
    id int identity(1,1) primary key,
    name varchar(255),
    inn int
);
alter table companies add constraint UQ_comp_inn UNIQUE (inn);

