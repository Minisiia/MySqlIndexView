/*
Создайте базу данных с именем “MyJoinsIndexDB”.
В данной базе данных создайте 3 таблицы, 
В 1-й таблице содержатся имена и номера телефонов сотрудников компании. 
Во 2-й таблице содержатся ведомости о зарплате и должностях сотрудников: главный директор, менеджер, рабочий. 
В 3-й таблице содержится информация о семейном положении, дате рождения, и месте проживания. 

Проанализируйте, какие типы индексов заданы на созданных в предыдущем задании таблицах. 
В каждой созданной таблице есть поля, определенные, как первичные ключи, поэтому именно они и содержат кластеризированные индексы.
	- для таблицы staff PRIMARY KEY(id)
	- для таблицы serviceInfo PRIMARY KEY(staff_id)
	- для таблицы personalInfo PRIMARY KEY(staff_id)

Задайте свои индексы на таблицах, обоснуйте их необходимость. 
Дополнительные индексы задаются в таблице в зависимости от условий задания. 
Они повышают скорость поиска строк по запросу.
Для примера были созданы индексы в таблице staff в поле phone для поиска владельца конкретного номера телефона,
также в таблице serviceInfo в поле salary для поиска имен сотрудников, зп которых равна 20000.

Создайте представления для таких заданий: 
1) Получите контактные данные сотрудников (номера телефонов, место жительства). 
2) Получите информацию о дате рождения всех холостых сотрудников и их номера. 
3) Получите информацию обо всех менеджерах компании: дату рождения и номер телефона. 
*/

CREATE DATABASE MyJoinsIndexDB;
USE MyJoinsIndexDB;

CREATE TABLE staff(
id INT AUTO_INCREMENT NOT NULL,
name VARCHAR(20),
phone VARCHAR(15),
PRIMARY KEY(id)
);

INSERT INTO staff
(name, phone)
VALUES
('Андрей','+380971112233'),
('Евгений','+380952226661'),
('Александр','+380975556644'),
('Василий','+380509994466'),
('Татьяна','+380961326459'),
('Олег','+380995461245');

CREATE TABLE serviceInfo(
staff_id INT,
salary DOUBLE,
position VARCHAR(20),
PRIMARY KEY(staff_id),
FOREIGN KEY (staff_id) REFERENCES staff(id) 
);

INSERT INTO serviceInfo
(staff_id, position, salary)
VALUES
(1, 'Главный директор', 30000),
(2, 'Менеджер', 20000),
(3, 'Менеджер', 22000),
(4, 'Рабочий', 10000),
(5, 'Менеджер', 20000),
(6, 'Рабочий', 12000);

CREATE TABLE personalInfo(
staff_id INT,
maritalStatus VARCHAR(10),
birth_day DATE,
adress VARCHAR(50),
PRIMARY KEY(staff_id),
FOREIGN KEY (staff_id) REFERENCES staff(id) 
);

INSERT INTO personalInfo
(staff_id, maritalStatus, birth_day, adress)
VALUES
(1, 'женат', '1990-02-02','г. Харьков, ул. Радостная, 23'),
(2, 'женат', '2000-12-22','г. Харьков, ул. Счастливая, 25'),
(3, 'не женат', '1995-04-16','г. Харьков, ул. Цветочная, 564'),
(4, 'женат', '1991-06-12','г. Харьков, ул. Умников, 16, кв. 55'),
(5, 'не замужем', '1987-02-14','г. Харьков, ул. Лентяев, 231'),
(6, 'не женат', '1990-02-02','г. Харьков, ул. Обнимашек, 123');

-- Проверка созданных таблиц
SELECT * FROM staff;
SELECT * FROM serviceInfo;
SELECT * FROM personalInfo;

-- Поиск владельца номера телефона без индексов
SELECT * FROM staff
WHERE staff.phone = '+380975556644';

EXPLAIN SELECT * FROM staff
WHERE staff.phone = '+380975556644';

-- Поиск владельца номера телефона, задав поле индексов
CREATE INDEX phone 
ON staff(phone);

SELECT * FROM staff
WHERE staff.phone = '+380975556644';

EXPLAIN SELECT * FROM staff
WHERE staff.phone = '+380975556644';

-- Поиск работников, у которых зп 20000
SELECT staff.name, serviceInfo.salary
FROM staff
INNER JOIN serviceInfo
ON staff.id = serviceInfo.staff_id
WHERE serviceInfo.salary = 20000;

EXPLAIN SELECT staff.name, serviceInfo.salary
FROM staff
INNER JOIN serviceInfo
ON staff.id = serviceInfo.staff_id
WHERE serviceInfo.salary = 20000;

-- Поиск работников, у которых зп 20000, c помощью индексов
CREATE INDEX salary 
ON serviceInfo(salary);

SELECT staff.name, serviceInfo.salary
FROM staff
INNER JOIN serviceInfo
ON staff.id = serviceInfo.staff_id
WHERE serviceInfo.salary = 20000;

EXPLAIN SELECT staff.name, serviceInfo.salary
FROM staff
INNER JOIN serviceInfo
ON staff.id = serviceInfo.staff_id
WHERE serviceInfo.salary = 20000;

/* Получите контактные данные сотрудников (номера телефонов, место жительства) */
CREATE VIEW contact_info
AS SELECT staff.name, staff.phone, personalInfo.adress
FROM staff
JOIN personalInfo
ON staff.id = personalInfo.staff_id;

SELECT * FROM contact_info;

/* Получите информацию о дате рождения всех холостых сотрудников и их номера
В данной бд холостых 3 человека */
CREATE VIEW birth_info
AS SELECT staff.name, personalInfo.birth_day, staff.phone
FROM staff
JOIN personalInfo
ON staff.id = personalInfo.staff_id
WHERE personalInfo.maritalStatus IN ('не женат', 'не замужем');

SELECT * FROM birth_info;

/* Получите информацию обо всех менеджерах компании: дату рождения и номер телефона
В данной бд менеджеров также 3 человека */
CREATE VIEW birth_manager_info
AS SELECT staff.name, personalInfo.birth_day, staff.phone
FROM staff
JOIN personalInfo
ON staff.id = personalInfo.staff_id
JOIN serviceInfo
ON staff.id = serviceInfo.staff_id
WHERE serviceInfo.position = 'Менеджер';

SELECT * FROM birth_manager_info;


