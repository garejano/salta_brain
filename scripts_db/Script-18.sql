select top 1 * from ItinerarioFormativo t ;



SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'Semestre'
ORDER BY TABLE_SCHEMA, TABLE_NAME;


SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE c.name = 'Semetre'
ORDER BY s.name, t.name;