#JOIN из трех таблиц, выдет подробную таблицу сопоставления сотрудник - должность
SELECT employees.ID AS ID_employee, employees.name AS employee_name, employees_has_jobs.ID_job, jobs.name AS job
FROM employees
JOIN employees_has_jobs ON employees.ID = employees_has_jobs.ID_employee
JOIN jobs on jobs.ID = employees_has_jobs.ID_job;

#WHERE с объединением трех таблиц
SELECT employees.ID AS ID_employee, employees.name AS employee_name, employees_has_jobs.ID_job, jobs.name AS job
FROM employees,
employees_has_jobs,
jobs
WHERE employees.ID = employees_has_jobs.ID_employee AND jobs.ID = employees_has_jobs.ID_job;

#Альтернативный JOIN. Выдает читаемую заявку, вместо циферных обозначений.
SELECT requests.ID as 'request_ID',templates.name as 'templates_name',requests.text as 'request_text', status.name as 'status_name',requests.date as 'request_date'  /* выбираем заявки  с определённым статусом */  
FROM requests 
INNER JOIN status ON (requests.status =status.ID)
INNER JOIN templates ON (requests.templates_ID =templates.ID)
WHERE requests.employees_ID=2;

#WHERE с объединением трех таблиц, выдает полную сводку по заявкам
SELECT requests.ID,
requests.date,
requests.priority,
requests.employees_ID,
employees.name AS employee_name,
requests.templates_ID,
requests.employees_jobs_ID,
requests.accepted_by,
requests.text,
requests.status,
status.name AS status_descr,
templates.name AS tamplate_name,
templates.text AS template_descr
FROM requests, templates, status, employees
WHERE requests.templates_ID = templates.ID AND requests.status = status.ID AND employees.ID = employees_ID;

#Агрегация. Считает количество заявок в работе (Слишком просто)
SELECT COUNT(status) AS 'В работе' FROM requests
WHERE status = 5 and accepted_by = 2;

#Выводит список админов и их количество заявок в порядке убывания
SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by
GROUP BY employees.ID
ORDER BY accepted DESC;

#Выводит ID, имя сотрудника и количество принятых заявок того сотрудника, который имеет наибольшее количество принятых заявок и находящихся не в статусе выполено
SELECT ID, name, accepted FROM  
(
SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by AND status NOT LIKE 4
GROUP BY employees.ID) AS T
WHERE accepted = (SELECT MAX(accepted) FROM (SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by AND status NOT LIKE 4
GROUP BY employees.ID) AS T);

#Выводит ID, имя сотрудника и количество принятых заявок того сотрудника, который имеет наибольшее количество заявок на себе
SELECT ID, name, accepted FROM  
(
SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by
GROUP BY employees.ID) AS T
WHERE accepted = (SELECT MAX(accepted) FROM (SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by
GROUP BY employees.ID) AS T);

ищем все запросы, статус которых назначен, сотрудники назначены.

Нахождение средней продолжительности заявок, находящихся в работе.

сотрудники-админы, статус, задача, автор задачи, должность сотрудника

Самый последний комментарий по заявке, которая была назначена на любого админа и её статус в работе.

#Процедура, которая выводит количество прошедшего времени с момента создания заявки
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `date`()
BEGIN
DECLARE i INT;
DROP TABLE IF EXISTS tmp_table;
CREATE TEMPORARY TABLE tmp_table (
`ID` INT NULL,
`date_in_h_m_s` TIME NULL
);
SET @@session.time_zone = '+10:00';
SET i := (SELECT MIN(ID) FROM requests);
WHILE i<=(SELECT MAX(ID) FROM requests) DO
	IF (NOW() - (SELECT date FROM requests WHERE ID = i)) IS NOT NULL THEN
		INSERT INTO HelpDesk.tmp_table VALUES (I ,TIMEDIFF(NOW(), (SELECT date FROM requests WHERE ID = i)));
	END IF;
SET i := i+1;
END WHILE;
SELECT * FROM tmp_table;
DROP TABLE tmp_table;
END //
DELIMITER ;


#Выводит полную информацию о заявках, включая время существования заявки
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `full_request_info`()
BEGIN
DECLARE i INT;
DROP TABLE IF EXISTS tmp_table;
CREATE TEMPORARY TABLE tmp_table (
`ID` INT NULL,
`date_in_h_m_s` TIME NULL
);
SET @@session.time_zone = '+10:00';
SET i := (SELECT MIN(ID) FROM requests);
WHILE i<=(SELECT MAX(ID) FROM requests) DO
	IF (NOW() - (SELECT date FROM requests WHERE ID = i)) IS NOT NULL THEN
		INSERT INTO HelpDesk.tmp_table VALUES (I ,TIMEDIFF(NOW(), (SELECT date FROM requests WHERE ID = i)));
	END IF;
SET i := i+1;
END WHILE;
SELECT requests.ID,
requests.date,
requests.priority,
requests.employees_ID,
employees.name AS employee_name,
requests.templates_ID,
requests.employees_jobs_ID,
requests.accepted_by,
requests.text,
requests.status,
status.name AS status_descr,
date_in_h_m_s AS 'Время существования',
templates.name AS tamplate_name,
templates.text AS template_descr
FROM requests, templates, status, employees, tmp_table
WHERE requests.templates_ID = templates.ID AND requests.status = status.ID AND employees.ID = employees_ID AND requests.ID = tmp_table.ID;
DROP TABLE tmp_table;
END //
DELIMITER ;

#Выводит полную информацию о заявках, находящихся не в статусе выполнено, включая время существования заявки
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `full_request_info_only_not_done`()
BEGIN
DECLARE i INT;
DROP TABLE IF EXISTS tmp_table;
CREATE TEMPORARY TABLE tmp_table (
`ID` INT NULL,
`date_in_h_m_s` TIME NULL
);
SET @@session.time_zone = '+10:00';
SET i := (SELECT MIN(ID) FROM requests);
WHILE i<=(SELECT MAX(ID) FROM requests) DO
	IF (NOW() - (SELECT date FROM requests WHERE ID = i)) IS NOT NULL THEN
		INSERT INTO HelpDesk.tmp_table VALUES (I ,TIMEDIFF(NOW(), (SELECT date FROM requests WHERE ID = i)));
	END IF;
SET i := i+1;
END WHILE;
SELECT requests.ID,
requests.date,
requests.priority,
requests.employees_ID,
employees.name AS employee_name,
requests.templates_ID,
requests.employees_jobs_ID,
requests.accepted_by,
requests.text,
requests.status,
status.name AS status_descr,
date_in_h_m_s AS 'Время существования',
templates.name AS tamplate_name,
templates.text AS template_descr
FROM requests, templates, status, employees, tmp_table
WHERE requests.templates_ID = templates.ID AND requests.status = status.ID AND employees.ID = employees_ID AND requests.ID = tmp_table.ID AND requests.status NOT LIKE 4;
DROP TABLE tmp_table;
END //
DELIMITER ;

#JOIN из трех таблиц, выдет подробную таблицу сопоставления сотрудник - должность
SELECT employees.ID AS ID_employee, employees.name AS employee_name, employees_has_jobs.ID_job, jobs.name AS job
FROM employees
JOIN employees_has_jobs ON employees.ID = employees_has_jobs.ID_employee
JOIN jobs on jobs.ID = employees_has_jobs.ID_job;

#WHERE с объединением трех таблиц
SELECT employees.ID AS ID_employee, employees.name AS employee_name, employees_has_jobs.ID_job, jobs.name AS job
FROM employees,
employees_has_jobs,
jobs
WHERE employees.ID = employees_has_jobs.ID_employee AND jobs.ID = employees_has_jobs.ID_job;

#Альтернативный JOIN. Выдает читаемую заявку, вместо циферных обозначений.
SELECT requests.ID as 'request_ID',templates.name as 'templates_name',requests.text as 'request_text', status.name as 'status_name',requests.date as 'request_date'  /* выбираем заявки  с определённым статусом */  
FROM requests 
INNER JOIN status ON (requests.status =status.ID)
INNER JOIN templates ON (requests.templates_ID =templates.ID)
WHERE requests.employees_ID=2;

#WHERE с объединением трех таблиц, выдает полную сводку по заявкам
SELECT requests.ID,
requests.date,
requests.priority,
requests.employees_ID,
employees.name AS employee_name,
requests.templates_ID,
requests.employees_jobs_ID,
requests.accepted_by,
requests.text,
requests.status,
status.name AS status_descr,
templates.name AS tamplate_name,
templates.text AS template_descr
FROM requests, templates, status, employees
WHERE requests.templates_ID = templates.ID AND requests.status = status.ID AND employees.ID = employees_ID;

#Агрегация. Считает количество заявок в работе (Слишком просто)
SELECT COUNT(status) AS 'В работе' FROM requests
WHERE status = 5 and accepted_by = 2;

#Не работает, но сохраню
SELECT employees.ID AS ID, employees.name AS employee_name, jobs.name AS job
FROM employees,
jobs,
employees_has_jobs,
requests
WHERE accepted_by = 2 AND employees.ID = accepted_by AND (SELECT COUNT(status) FROM requests WHERE accepted_by = 2 ) = 1 AND jobs.ID = 11
GROUP BY employees.ID
ORDER BY employees.name;

#Выводит список админов и их количество заявок в порядке убывания
SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by
GROUP BY employees.ID
ORDER BY accepted DESC;

#Выводит ID, имя сотрудника и количество принятых заявок того сотрудника, который имеет наибольшее количество принятых заявок и находящихся не в статусе выполено
SELECT ID, name, accepted FROM  
(
SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by AND status NOT LIKE 4
GROUP BY employees.ID) AS T
WHERE accepted = (SELECT MAX(accepted) FROM (SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by AND status NOT LIKE 4
GROUP BY employees.ID) AS T);

#Выводит ID, имя сотрудника и количество принятых заявок того сотрудника, который имеет наибольшее количество заявок на себе
SELECT ID, name, accepted FROM  
(
SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by
GROUP BY employees.ID) AS T
WHERE accepted = (SELECT MAX(accepted) FROM (SELECT employees.ID as ID, employees.name AS name, COUNT(*) AS accepted
FROM employees
JOIN requests ON employees.ID = requests.accepted_by
GROUP BY employees.ID) AS T);

ищем все запросы, статус которых назначен, сотрудники назначены.

Нахождение средней продолжительности заявок, находящихся в работе.

сотрудники-админы, статус, задача, автор задачи, должность сотрудника

Самый последний комментарий по заявке, которая была назначена на любого админа и её статус в работе.

#Процедура, которая выводит количество прошедшего времени с момента создания заявки
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `date`()
BEGIN
DECLARE i INT;
DROP TABLE IF EXISTS tmp_table;
CREATE TEMPORARY TABLE tmp_table (
`ID` INT NULL,
`date_in_h_m_s` TIME NULL
);
SET @@session.time_zone = '+10:00';
SET i := (SELECT MIN(ID) FROM requests);
WHILE i<=(SELECT MAX(ID) FROM requests) DO
	IF (NOW() - (SELECT date FROM requests WHERE ID = i)) IS NOT NULL THEN
		INSERT INTO HelpDesk.tmp_table VALUES (I ,TIMEDIFF(NOW(), (SELECT date FROM requests WHERE ID = i)));
	END IF;
SET i := i+1;
END WHILE;
SELECT * FROM tmp_table;
DROP TABLE tmp_table;
END //
DELIMITER ;


#Выводит полную информацию о заявках, включая время существования заявки
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `full_request_info`()
BEGIN
DECLARE i INT;
DROP TABLE IF EXISTS tmp_table;
CREATE TEMPORARY TABLE tmp_table (
`ID` INT NULL,
`date_in_h_m_s` TIME NULL
);
SET @@session.time_zone = '+10:00';
SET i := (SELECT MIN(ID) FROM requests);
WHILE i<=(SELECT MAX(ID) FROM requests) DO
	IF (NOW() - (SELECT date FROM requests WHERE ID = i)) IS NOT NULL THEN
		INSERT INTO HelpDesk.tmp_table VALUES (I ,TIMEDIFF(NOW(), (SELECT date FROM requests WHERE ID = i)));
	END IF;
SET i := i+1;
END WHILE;
SELECT requests.ID,
requests.date,
requests.priority,
requests.employees_ID,
employees.name AS employee_name,
requests.templates_ID,
requests.employees_jobs_ID,
requests.accepted_by,
requests.text,
requests.status,
status.name AS status_descr,
date_in_h_m_s AS 'Время существования',
templates.name AS tamplate_name,
templates.text AS template_descr
FROM requests, templates, status, employees, tmp_table
WHERE requests.templates_ID = templates.ID AND requests.status = status.ID AND employees.ID = employees_ID AND requests.ID = tmp_table.ID;
DROP TABLE tmp_table;
END //
DELIMITER ;

#Выводит полную информацию о заявках, находящихся не в статусе выполнено, включая время существования заявки
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `full_request_info_only_not_done`()
BEGIN
DECLARE i INT;
DROP TABLE IF EXISTS tmp_table;
CREATE TEMPORARY TABLE tmp_table (
`ID` INT NULL,
`date_in_h_m_s` TIME NULL
);
SET @@session.time_zone = '+10:00';
SET i := (SELECT MIN(ID) FROM requests);
WHILE i<=(SELECT MAX(ID) FROM requests) DO
	IF (NOW() - (SELECT date FROM requests WHERE ID = i)) IS NOT NULL THEN
		INSERT INTO HelpDesk.tmp_table VALUES (I ,TIMEDIFF(NOW(), (SELECT date FROM requests WHERE ID = i)));
	END IF;
SET i := i+1;
END WHILE;
SELECT requests.ID,
requests.date,
requests.priority,
requests.employees_ID,
employees.name AS employee_name,
requests.templates_ID,
requests.employees_jobs_ID,
requests.accepted_by,
requests.text,
requests.status,
status.name AS status_descr,
date_in_h_m_s AS 'Время существования',
templates.name AS tamplate_name,
templates.text AS template_descr
FROM requests, templates, status, employees, tmp_table
WHERE requests.templates_ID = templates.ID AND requests.status = status.ID AND employees.ID = employees_ID AND requests.ID = tmp_table.ID AND requests.status NOT LIKE 4;
DROP TABLE tmp_table;
END //
DELIMITER ;