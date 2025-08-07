-- 1. Tables Setup

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE OrderStates (
    state_id INT PRIMARY KEY,
    state_name VARCHAR(100),
    parent_state_id INT -- For hierarchical state transitions (optional)
);

CREATE TABLE OrderEvents (
    event_id INT PRIMARY KEY,
    customer_id INT,
    state_id INT,
    event_time DATETIME,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (state_id) REFERENCES OrderStates(state_id)
);

-- 2. Recursive CTE: Build state transition path if states are hierarchical
WITH RECURSIVE StateHierarchy AS (
    SELECT 
        state_id,
        state_name,
        parent_state_id,
        state_name AS full_path,
        1 AS level
    FROM OrderStates
    WHERE parent_state_id IS NULL

    UNION ALL

    SELECT 
        s.state_id,
        s.state_name,
        s.parent_state_id,
        CONCAT(sh.full_path, ' → ', s.state_name) AS full_path,
        sh.level + 1
    FROM OrderStates s
    JOIN StateHierarchy sh ON s.parent_state_id = sh.state_id
),

-- 3. CTE: Assign row numbers to each customer's order event
OrderedEvents AS (
    SELECT 
        oe.event_id,
        oe.customer_id,
        c.name AS customer_name,
        oe.state_id,
        os.state_name,
        oe.event_time,
        ROW_NUMBER() OVER (PARTITION BY oe.customer_id ORDER BY oe.event_time) AS step_number
    FROM OrderEvents oe
    JOIN Customers c ON oe.customer_id = c.customer_id
    JOIN OrderStates os ON oe.state_id = os.state_id
),

-- 4. CTE: Calculate time between each stage using LAG
OrderTiming AS (
    SELECT 
        customer_id,
        customer_name,
        state_name,
        event_time,
        step_number,
        LAG(event_time) OVER (PARTITION BY customer_id ORDER BY event_time) AS previous_event_time,
        DATEDIFF(MINUTE, 
                 LAG(event_time) OVER (PARTITION BY customer_id ORDER BY event_time),
                 event_time) AS minutes_between_steps
    FROM OrderedEvents
),

-- 5. CTE: Count frequency of customer order events
CustomerFrequency AS (
    SELECT 
        customer_id,
        name AS customer_name,
        COUNT(*) AS total_events,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
    FROM OrderEvents oe
    JOIN Customers c ON c.customer_id = oe.customer_id
    GROUP BY customer_id, name
)

-- Final Outputs

-- A. Full hierarchical state transition path (if used)
SELECT * FROM StateHierarchy ORDER BY full_path;

-- B. Ordered events per customer with step number
SELECT * FROM OrderedEvents ORDER BY customer_id, step_number;

-- C. Time taken between stages
SELECT * FROM OrderTiming ORDER BY customer_id, step_number;

-- D. Most frequent ordering customers
SELECT * FROM CustomerFrequency ORDER BY frequency_rank;
