-- TABLE STRUCTURE
CREATE TABLE documents (
    document_id INT PRIMARY KEY,
    title VARCHAR(255),
    created_at DATE
);

CREATE TABLE document_versions (
    version_id INT PRIMARY KEY,
    document_id INT,
    version_number INT,
    content TEXT,
    modified_at DATE,
    FOREIGN KEY (document_id) REFERENCES documents(document_id)
);

CREATE TABLE document_dependencies (
    doc_id INT,
    depends_on_doc_id INT,
    FOREIGN KEY (doc_id) REFERENCES documents(document_id),
    FOREIGN KEY (depends_on_doc_id) REFERENCES documents(document_id)
);

-- SAMPLE DATA
INSERT INTO documents VALUES (1, 'Project Plan', '2024-01-01');
INSERT INTO documents VALUES (2, 'Design Doc', '2024-01-05');
INSERT INTO documents VALUES (3, 'API Spec', '2024-01-10');

INSERT INTO document_versions VALUES 
(101, 1, 1, 'Initial Plan', '2024-01-01'),
(102, 1, 2, 'Revised Plan', '2024-01-15'),
(103, 1, 3, 'Final Plan', '2024-02-01'),
(201, 2, 1, 'Initial Design', '2024-01-05'),
(202, 2, 2, 'Updated Design', '2024-01-25'),
(301, 3, 1, 'Initial Spec', '2024-01-10');

INSERT INTO document_dependencies VALUES 
(1, 2),
(1, 3);

------------------------------------------------------
-- 1. ROW_NUMBER() to list versions per document
WITH VersionRanked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY version_number DESC) AS version_rank
    FROM document_versions
)
SELECT * FROM VersionRanked;

------------------------------------------------------
-- 2. LAG() to compare changes between versions
WITH VersionChanges AS (
    SELECT 
        document_id,
        version_number,
        content,
        LAG(content) OVER (PARTITION BY document_id ORDER BY version_number) AS previous_content
    FROM document_versions
)
SELECT * FROM VersionChanges;

------------------------------------------------------
-- 3. WITH RECURSIVE to trace dependencies between documents
WITH RECURSIVE doc_dependency_chain AS (
    SELECT 
        doc_id, 
        depends_on_doc_id, 
        1 AS level
    FROM document_dependencies
    UNION ALL
    SELECT 
        d.doc_id, 
        dd.depends_on_doc_id, 
        level + 1
    FROM document_dependencies dd
    INNER JOIN doc_dependency_chain d ON dd.doc_id = d.depends_on_doc_id
)
SELECT * FROM doc_dependency_chain;

------------------------------------------------------
-- 4. CTE to filter CURRENT versions only
WITH LatestVersions AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY version_number DESC) AS rn
    FROM document_versions
)
SELECT * FROM LatestVersions WHERE rn = 1;

------------------------------------------------------
-- 5. CTE to filter OUTDATED versions
WITH AllVersions AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY version_number DESC) AS rn
    FROM document_versions
)
SELECT * FROM AllVersions WHERE rn > 1;

------------------------------------------------------
-- 6. CTE to find BROKEN dependencies (nonexistent reference)
WITH BrokenDependencies AS (
    SELECT dd.doc_id, dd.depends_on_doc_id
    FROM document_dependencies dd
    LEFT JOIN documents d ON dd.depends_on_doc_id = d.document_id
    WHERE d.document_id IS NULL
)
SELECT * FROM BrokenDependencies;
