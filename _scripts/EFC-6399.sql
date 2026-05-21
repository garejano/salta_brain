-- EFC-6399: DiaSemAulaMotivo.DataInicio e DataFim criadas como bit em vez de datetime
-- Não é possível ALTER COLUMN de bit para datetime diretamente no SQL Server.
-- Estratégia: adicionar novas colunas datetime, remover as antigas bit, renomear.

-- 1. Adicionar novas colunas como nullable
ALTER TABLE DiaSemAulaMotivo ADD DataInicioNew datetime NULL;
ALTER TABLE DiaSemAulaMotivo ADD DataFimNew datetime NULL;

-- 2. Remover as colunas com tipo errado
ALTER TABLE DiaSemAulaMotivo DROP COLUMN DataInicio;
ALTER TABLE DiaSemAulaMotivo DROP COLUMN DataFim;

-- 3. Renomear para o nome original
EXEC sp_rename 'DiaSemAulaMotivo.DataInicioNew', 'DataInicio', 'COLUMN';
EXEC sp_rename 'DiaSemAulaMotivo.DataFimNew', 'DataFim', 'COLUMN';

-- 4. Tornar NOT NULL (executar apenas após confirmar que não há linhas com NULL)
ALTER TABLE DiaSemAulaMotivo ALTER COLUMN DataInicio datetime NOT NULL;
ALTER TABLE DiaSemAulaMotivo ALTER COLUMN DataFim datetime NOT NULL;
