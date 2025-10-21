SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address='Kenduadihi Bankura'
WHERE member_id='C103'


-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id='IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id='E101'


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT
    issued_emp_id
	--COUNT(issued_id) AS total_issues
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id)>1

--IF WE WANT TO FETCH EMPLOYEE NAME ALSO=>
SELECT
   ist.issued_emp_id,
   emp.emp_name
FROM issued_status as ist
INNER JOIN 
employees as emp
ON ist.issued_emp_id=emp.emp_id
GROUP BY 1,2
HAVING COUNT(ist.issued_id)>1



-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS
SELECT 
   b.isbn,
   b.book_title,
   COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN
issued_status as ist
ON b.isbn=ist.issued_book_isbn
GROUP BY 1,2

SELECT * FROM book_cnts

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category='Classic'


-- Task 8: Find Total Rental Income by Category:
SELECT 
    category,
	SUM(rental_price) AS total_rents
FROM books
GROUP BY 1

--TASK 9: List Members Who Registered in the Last 180 Days:
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C120', 'sancho', '145 Main St', '2025-10-01'),
('C121', 'rancho', '133 Main St', '2025-09-01');

SELECT * FROM members
WHERE reg_date>= CURRENT_DATE-INTERVAL '180 DAYS'


-- task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.*,
	b.manager_id,
	e2.emp_name AS manager
FROM employees AS e1
JOIN
branch as b
ON 
e1.branch_id=b.branch_id
JOIN
employees AS e2
ON
e2.emp_id=b.manager_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE books_with_price_above_7
AS
SELECT * FROM books
WHERE rental_price>7

SELECT * FROM books_with_price_above_7

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT
  DISTINCT ist.issued_book_name 
FROM 
issued_status AS ist
LEFT JOIN
return_status as rst
ON ist.issued_id=rst.issued_id
WHERE rst.return_id IS NULL

SELECT * FROM return_status



