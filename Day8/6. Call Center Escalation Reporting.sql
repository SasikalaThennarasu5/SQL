-- 1. Tables Setup

CREATE TABLE Agents (
    agent_id INT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50), -- 'Agent', 'Supervisor', 'Manager'
    reports_to INT -- Self-referencing foreign key
);

CREATE TABLE Interactions (
    interaction_id INT PRIMARY KEY,
    customer_id INT,
    agent_id INT,
    issue_id INT,
    interaction_time DATETIME,
    resolution_time DATETIME,
    escalation_level INT -- 1 = Agent, 2 = Supervisor, 3 = Manager
);

-- 2. Recursive CTE: Show escalation flow (Agent → Supervisor → Manager)

WITH RECURSIVE EscalationFlow AS (
    SELECT 
        a.agent_id,
        a.name,
        a.role,
        a.reports_to,
        CAST(a.name AS VARCHAR(500)) AS escalation_path,
        1 AS level
    FROM Agents a
    WHERE a.reports_to IS NULL

    UNION ALL

    SELECT 
        sub.agent_id,
        sub.name,
        sub.role,
        sub.reports_to,
        CAST(ef.escalation_path || ' → ' || sub.name AS VARCHAR(500)),
        ef.level + 1
    FROM Agents sub
    JOIN EscalationFlow ef ON sub.reports_to = ef.agent_id
),

-- 3. CTE: Order support interactions by agent and issue

OrderedInteractions AS (
    SELECT 
        i.interaction_id,
        i.customer_id,
        i.issue_id,
        i.agent_id,
        a.name AS agent_name,
        i.interaction_time,
        i.resolution_time,
        i.escalation_level,
        ROW_NUMBER() OVER (PARTITION BY i.issue_id ORDER BY i.interaction_time) AS interaction_order
    FROM Interactions i
    JOIN Agents a ON a.agent_id = i.agent_id
),

-- 4. CTE: Calculate resolution time difference with previous stage using LAG()

ResolutionComparison AS (
    SELECT 
        interaction_id,
        customer_id,
        issue_id,
        agent_id,
        agent_name,
        escalation_level,
        interaction_time,
        resolution_time,
        LAG(resolution_time) OVER (PARTITION BY issue_id ORDER BY interaction_time) AS prev_resolution_time,
        DATEDIFF(MINUTE,
            LAG(resolution_time) OVER (PARTITION BY issue_id ORDER BY interaction_time),
            resolution_time) AS time_diff_minutes
    FROM OrderedInteractions
),

-- 5. CTE: Rank agents by how often their interactions are escalated

AgentEscalationCount AS (
    SELECT 
        a.agent_id,
        a.name AS agent_name,
        COUNT(*) FILTER (WHERE escalation_level > 1) AS escalation_count,
        RANK() OVER (ORDER BY COUNT(*) FILTER (WHERE escalation_level > 1) DESC) AS escalation_rank
    FROM Interactions i
    JOIN Agents a ON a.agent_id = i.agent_id
    GROUP BY a.agent_id, a.name
)

-- Final Outputs

-- A. Full Escalation Path
SELECT * FROM EscalationFlow ORDER BY escalation_path;

-- B. Ordered Support Interactions
SELECT * FROM OrderedInteractions ORDER BY issue_id, interaction_order;

-- C. Resolution Time Comparison Between Levels
SELECT * FROM ResolutionComparison ORDER BY issue_id, interaction_time;

-- D. Most Escalated Agents
SELECT * FROM AgentEscalationCount WHERE escalation_count > 0 ORDER BY escalation_rank;
