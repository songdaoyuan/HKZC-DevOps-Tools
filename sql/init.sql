-- 设置SQL Mode
SET GLOBAL sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE DATABASE kg_ehr;
CREATE DATABASE shushi_pamirs;
CREATE DATABASE shushi_base;
CREATE USER 'kgdba'@'%' IDENTIFIED BY 'kgdba@2024';
-- ALTER USER 'kgdba'@'%' IDENTIFIED BY 'kgdba@2024';
GRANT ALL PRIVILEGES ON kg_ehr.* TO 'kgdba'@'%';
GRANT ALL PRIVILEGES ON shushi_pamirs.* TO 'kgdba'@'%';
GRANT ALL PRIVILEGES ON shushi_base.* TO 'kgdba'@'%';
FLUSH PRIVILEGES;