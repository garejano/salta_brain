SELECT 
    t.name AS tabela,
    c.name AS coluna,
    ty.name AS tipo,
    c.max_length AS tamanho,
    c.precision AS precisao,
    c.scale AS escala,
    c.is_nullable AS permite_nulo,
    ISNULL(i.is_primary_key, 0) AS chave_primaria
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND i.is_primary_key = 1
WHERE t.is_ms_shipped = 0
ORDER BY t.name, c.column_id;


SELECT  
    fk.name AS nome_fk,
    tp.name AS tabela_origem,
    cp.name AS coluna_origem,
    tr.name AS tabela_referenciada,
    cr.name AS coluna_referenciada
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY tp.name, fk.name;
