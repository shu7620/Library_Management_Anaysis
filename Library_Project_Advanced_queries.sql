SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM return_status


/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT
 ist.issued_member_id,
 m.member_name,
 b.book_title,
 ist.issued_date,
 CURRENT_DATE-ist.issued_date AS over_due_days
FROM issued_status AS ist
JOIN
members AS m
 ON m.member_id=ist.issued_member_id
JOIN 
books AS b
 ON b.isbn=ist.issued_book_isbn
LEFT JOIN
 return_status as rst
ON rst.issued_id=ist.issued_id
WHERE
 rst.return_date IS NULL
 AND
 (CURRENT_DATE - ist.issued_date)>30
ORDER BY 1

-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

--we can do it manually
SELECT * FROM issued_status
WHERE issued_id='IS130'

SELECT * FROM books
WHERE isbn='978-0-451-52994-2'

UPDATE books
SET status='no'
WHERE isbn='978-0-330-25864-8'

SELECT * FROM return_status
WHERE issued_id='IS130'

--Book returned
INSERT INTO return_status(return_id, issued_id, return_date)
VALUES
('RS125', 'IS130', CURRENT_DATE);

SELECT * FROM return_status
WHERE issued_id='IS130'

--update status
UPDATE books
SET status='yes'
WHERE isbn='978-0-330-25864-8'

--By stored procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10),p_issued_id VARCHAR(10))
LANGUAGE PLPGSQL
AS $$

DECLARE
  v_isbn VARCHAR(50);
  v_book_name VARCHAR(80);
BEGIN
  INSERT INTO return_status(return_id, issued_id, return_date)
  VALUES
  (p_return_id, p_issued_id, CURRENT_DATE);

  SELECT
    issued_book_isbn,
	issued_book_name
	INTO
	v_isbn
    v_book_name
  FROM issued_status
  WHERE issued_id=p_issued_id;

  UPDATE books
  SET status='yes'
  WHERE isbn=v_isbn;

  RAISE NOTICE 'Thank You for returning the book: %',v_book_name;

END;
$$

--Testing the procedure
SELECT * FROM return_status 
WHERE issued_id='IS135'

--CALLING THE FUNCTION
CALL add_return_records('RS126','IS135')


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM branch
SELECT * FROM issued_status
SELECT * FROM return_status
SELECT * FROM books
SELECT * FROM members
SELECT * FROM employees

--branch->employees->issued_status->return_status->books
CREATE TABLE Branch_Reports
AS
SELECT 
    b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS number_book_issued,
	COUNT(rst.return_id) AS number_book_returned,
	SUM(bk.rental_price) AS total_rental_amounnt
FROM
branch AS b
JOIN
employees AS e
ON e.branch_id=b.branch_id
JOIN
issued_status AS ist
ON e.emp_id=ist.issued_emp_id
LEFT JOIN
return_status AS rst
ON rst.issued_id=ist.issued_id
JOIN
books AS bk
ON ist.issued_book_isbn=bk.isbn
GROUP BY 1,2;

SELECT * FROM Branch_Reports


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE Active_Members
AS
SELECT * FROM members
WHERE member_id
IN
(
     SELECT DISTINCT issued_member_id
     FROM issued_status 
     WHERE issued_date>= CURRENT_DATE-INTERVAL '2 month'
)

SELECT * FROM Active_Members


INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT * FROM branch
SELECT * FROM issued_status
SELECT * FROM employees

--employees->issued_status->branch
SELECT
   emp.emp_name,
   b.*,
   COUNT(ist.issued_id) AS total_book_issued
FROM
issued_status AS ist
JOIN
employees AS emp
ON ist.issued_emp_id=emp.emp_id
JOIN
branch as b
ON emp.branch_id=b.branch_id
GROUP BY 1,2
ORDER BY 6 DESC --6 is the total_book_issued column
LIMIT 3


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

SELECT * FROM books
SELECT * FROM issued_status

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(30),p_issued_b_isbn VARCHAR(30),p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
  v_status VARCHAR(10); 
BEGIN
  SELECT 
    status 
	INTO
	v_status
  FROM books
  WHERE isbn=p_issued_b_isbn;

  IF v_status = 'yes' THEN
    INSERT INTO issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
	VALUES 
	(p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_b_isbn,p_issued_emp_id);

	UPDATE books
	SET status='no'
	WHERE isbn=p_issued_b_isbn;

	RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_b_isbn;

 ELSE
     RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_b_isbn;

 END IF;
END;
$$


SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'