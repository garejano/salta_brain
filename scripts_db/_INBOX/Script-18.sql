--ALTER TABLE "DiarioClasseConfiguracao"
--ADD COLUMN "CaracterParaNEE" TEXT NOT NULL DEFAULT '**';

select * from "DiarioClasseConfiguracao" dcc;

ALTER TABLE "DiarioClasseConfiguracao" RENAME COLUMN "CaracterParaNEE" TO "CaracterParaIndicarNEE";
