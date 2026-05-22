-- Executar com o owner da tabela ou superuser
-- Amplia Nome de varchar(200) para varchar(300) sem perda de dados

ALTER TABLE "EscolaExterna"
    ALTER COLUMN "Nome" TYPE character varying(300);
