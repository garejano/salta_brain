SELECT
    fk.name AS FK_Name,
    tp.name AS Tabela,
    cp.name AS Coluna,
    tr.name AS Tabela_Referenciada,
    cr.name AS Coluna_Referenciada
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc 
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables tp 
    ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns cp 
    ON fkc.parent_object_id = cp.object_id 
   AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables tr 
    ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns cr 
    ON fkc.referenced_object_id = cr.object_id 
   AND fkc.referenced_column_id = cr.column_id
WHERE tp.name = 'ProfessorCarga'
  AND SCHEMA_NAME(tp.schema_id) = 'folha';

select * from folha.ProfessorCarga pc ;






select * from folha.Disciplina d; 



select * from EscolaGerencial eg;
