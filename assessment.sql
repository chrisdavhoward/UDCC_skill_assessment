-- 1.
-- How Many Dogs Were Successfully Screened?

SELECT
    COUNT(*) as 'screened_dogs'
FROM screening_form
WHERE form_completion_date IS NOT NULL

-- 2.
-- How Many Dogs Are Eligible?

SELECT
    COUNT(*) as 'eligible_dogs'
FROM screening_form
WHERE 
    elig_question_1 = 1 AND
    elig_question_2 = 1 AND
    elig_question_3 = 1 AND
    NOT (inelig_question_1 IS NULL OR inelig_question_1 = 1) AND -- Nulls are automatically excluded; included for readability
    NOT (inelig_question_2 IS NULL OR inelig_question_2 = 1)

-- 2a.
-- If missing values could be considered for the ineligibility questions how would you rewrite this query?

SELECT
    COUNT(*) as 'eligible_dogs'
FROM screening_form
WHERE 
    elig_question_1 = 1 AND
    elig_question_2 = 1 AND
    elig_question_3 = 1 AND
    (inelig_question_1 IS NULL OR inelig_question_1 != 1) AND
    (inelig_question_2 IS NULL OR inelig_question_2 != 1)

-- 3.
-- How Many Dogs Are Ready To Be Enrolled In The Study?

WITH eligible_dogs as (
    SELECT
        id
    FROM screening_form
    WHERE 
        elig_question_1 = 1 AND
        elig_question_2 = 1 AND
        elig_question_3 = 1 AND
        NOT (inelig_question_1 IS NULL OR inelig_question_1 = 1) AND -- Nulls are automatically excluded; included for readability
        NOT (inelig_question_2 IS NULL OR inelig_question_2 = 1)
) -- using the definition from question 2, not 2a.

SELECT 
    COUNT(*) AS 'ready_to_enroll_dogs'
FROM eligible_dogs e LEFT JOIN request_to_withdraw_form r ON e.id = r.id
WHERE COALESCE(withdrawal_status, 0) NOT IN (1,2)

-- 4.
-- How Many Dogs Were Withdrawn From the Study? 

SELECT
    COUNT(*) AS 'withdrawn_dogs'
FROM request_to_withdraw_form
WHERE withdrawal_status IN (1,2)

-- 5.
-- How many screened dogs are over the age of 5?

WITH dog_years AS (
    SELECT
        id,
        (strftime('%Y', 'now') - strftime('%Y', date_of_birth)) - 
        (strftime('%m-%d', 'now') < strftime('%m-%d', date_of_birth)) AS age_in_years
    FROM participant_info p
)

SELECT
    COUNT(*) AS 'older_screened_dogs'
FROM screening_form s LEFT JOIN dog_years d ON s.id = d.id
WHERE age_in_years >= 5 AND form_completion_date IS NOT NULL

-- 6.
-- Write a query that designates the order in which those ready to enroll should be contacted

WITH eligible_dogs as (
    SELECT
        id,
        form_completion_date
    FROM screening_form
    WHERE 
        elig_question_1 = 1 AND
        elig_question_2 = 1 AND
        elig_question_3 = 1 AND
        NOT (inelig_question_1 IS NULL OR inelig_question_1 = 1) AND
        NOT (inelig_question_2 IS NULL OR inelig_question_2 = 1)
) -- using the definition from question 2, not 2a.

SELECT 
    e.id,
    e.form_completion_date
FROM eligible_dogs e LEFT JOIN request_to_withdraw_form r ON e.id = r.id
WHERE COALESCE(withdrawal_status, 0) NOT IN (1,2)
ORDER BY e.form_completion_date 

