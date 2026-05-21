SELECT COUNT(*) AS SoNaFolha
FROM Folha.Disciplina f
LEFT JOIN dbo.Disciplina d ON d.Id = f.Id
WHERE d.Id IS NULL;