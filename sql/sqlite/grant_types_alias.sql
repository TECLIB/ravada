CREATE TABLE `grant_types_alias` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `name` char(32) NOT NULL
,  `alias` char(32) NOT NULL
,  preferred int NOT NULL DEFAULT 0
,    UNIQUE(`name`,`alias`)
);
