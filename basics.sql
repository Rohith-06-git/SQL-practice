
SELECT * FROM students;


SELECT name FROM students;

SELECT * FROM students
WHERE cgpa > 8;


SELECT * FROM students
WHERE name = 'Rohith';

SELECT * FROM students
ORDER BY cgpa DESC;

SELECT MIN(cgpa) FROM students ;

SELECT MAX(cgpa) FROM students;

SELECT SUM(cgpa) FROM students ;

SELECT AVG(cgpa) FROM students;

SELECT DISTINCT cgpa FROM students;

