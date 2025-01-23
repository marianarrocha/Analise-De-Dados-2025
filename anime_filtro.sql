USE banco_anime;

CREATE TABLE anime_filtro (
    anime_id INT,
    AnimeName VARCHAR(255),
    Score FLOAT,
    Genres VARCHAR(255),
    EnglishName VARCHAR(255),
    JapaneseName VARCHAR(255),
    synopsis TEXT,
    AnimeType VARCHAR(255),
    Episodes INT,
    Aired VARCHAR(255),
    Premiered VARCHAR(255),
    Producers VARCHAR(255),
    Licensors VARCHAR(255),
    Studios VARCHAR(255),
    AnimeSource VARCHAR(255),
    Duration VARCHAR(255),
    Rating VARCHAR(255),
    Ranked INT,
    Popularity INT,
    Members INT,
    Favorites INT,
    Watching INT,
    Completed INT,
    On_Hold INT,
    Dropped INT
);

#mudar alguns tipos que não conseguiam ser importados
ALTER TABLE anime_filtro MODIFY Episodes VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Ranked VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Popularity VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Members VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Favorites VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Watching VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Completed VARCHAR(255);
ALTER TABLE anime_filtro MODIFY On_Hold VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Dropped VARCHAR(255);
ALTER TABLE anime_filtro MODIFY Producers VARCHAR(800);

#carregar os dados no MySQL
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\anime-filtered.csv'
INTO TABLE anime_filtro
FIELDS TERMINATED BY '|'
IGNORE 1 LINES;

#verificar tabela
SELECT * FROM anime_filtro;

#verificar os tipos dos dados
DESCRIBE anime_filtro;

#removendo safe mode
SET SQL_SAFE_UPDATES = 0;

#modificar os tipos novamente
UPDATE anime_filtro
SET Episodes = NULL
WHERE TRIM(Episodes) = '' OR Episodes IS NULL;
ALTER TABLE anime_filtro MODIFY Episodes INT;

UPDATE anime_filtro
SET Ranked = NULL
WHERE TRIM(Ranked) = '' OR Ranked IS NULL;
ALTER TABLE anime_filtro MODIFY COLUMN Ranked INT;

UPDATE anime_filtro
SET Popularity = NULL
WHERE TRIM(Popularity) = '' OR Popularity IS NULL;
ALTER TABLE anime_filtro MODIFY Popularity  INT;

UPDATE anime_filtro
SET Members = NULL
WHERE TRIM(Members) = '' OR Members IS NULL;
ALTER TABLE anime_filtro MODIFY Members INT;

UPDATE anime_filtro
SET Favorites = NULL
WHERE TRIM(Favorites) = '' OR Favorites IS NULL;
ALTER TABLE anime_filtro MODIFY Favorites INT;

UPDATE anime_filtro
SET Watching = NULL
WHERE TRIM(Watching) = '' OR Watching IS NULL;
ALTER TABLE anime_filtro MODIFY Watching INT;

UPDATE anime_filtro
SET Completed = NULL
WHERE TRIM(Completed) = '' OR Completed IS NULL;
ALTER TABLE anime_filtro MODIFY Completed INT;

UPDATE anime_filtro
SET On_Hold = NULL
WHERE TRIM(On_Hold) = '' OR On_Hold IS NULL;
ALTER TABLE anime_filtro MODIFY On_Hold INT;

UPDATE anime_filtro
SET Dropped = NULL
WHERE TRIM(Dropped) = '' OR Dropped IS NULL;
UPDATE anime_filtro
SET Dropped = NULL
WHERE Dropped = CHAR(13);
ALTER TABLE anime_filtro MODIFY Dropped INT;

SELECT Dropped FROM anime_filtro
LIMIT 3280,1;

SELECT Dropped, LENGTH(Dropped), HEX(Dropped)
FROM anime_filtro
LIMIT 3280,1;

UPDATE anime_filtro
SET Licensors = 'Unknown'
WHERE TRIM(Licensors) = '' OR Licensors IS NULL;

UPDATE anime_filtro
SET AnimeSource = 'Unknown'
WHERE TRIM(AnimeSource) = '' OR AnimeSource IS NULL;

#análise inicial de dados
#10 animes mais bem avaliados e quais os seus estúdios
SELECT AnimeName, Score, Studios
FROM anime_filtro
ORDER BY Score DESC
LIMIT 10;

#animes com pontuação acima da média
SELECT AnimeName,  Score
FROM anime_filtro
WHERE Score > (SELECT AVG(Score) FROM anime_filtro)
ORDER BY Score DESC;

#quantos animes lançados por producers
SELECT COUNT(AnimeName) AS quantidade_anime, Producers
FROM anime_filtro
WHERE Producers != 'Unknown'
GROUP BY Producers
ORDER BY quantidade_anime DESC;

#anime mais longo de cada estúdio
SELECT a.Studios, a.AnimeName, a.Episodes
FROM anime_filtro a
INNER JOIN(
SELECT MAX(Episodes) as maior_ep, Studios
FROM anime_filtro
GROUP BY Studios) b
ON a.Studios = b.Studios AND a.Episodes = b.maior_ep
ORDER BY a.Studios;

#animes lançados em uma temporada específica
SELECT AnimeName, Genres 
FROM anime_filtro 
WHERE Premiered ='Fall 2001';

#criar uma tabela temporária para fazer consultas com as datas de início e fim dos animes
CREATE TEMPORARY TABLE anime_ano SELECT AnimeName, Aired, Popularity FROM anime_filtro;
ALTER TABLE anime_ano ADD COLUMN Inicio VARCHAR(255);
ALTER TABLE anime_ano ADD COLUMN Fim VARCHAR(255);

UPDATE anime_ano
SET Inicio = TRIM(SUBSTRING_INDEX(Aired,'to',1));

ALTER TABLE anime_ano ADD COLUMN Ini_ano VARCHAR(255);
UPDATE anime_ano
SET Ini_ano = TRIM(SUBSTRING_INDEX(Inicio, ',', -1));

UPDATE anime_ano
SET Fim = TRIM(SUBSTRING_INDEX(Aired,'to', -1))
WHERE LENGTH(Aired) >= 8;

ALTER TABLE anime_ano ADD COLUMN Fim_ano VARCHAR(255);
UPDATE anime_ano
SET Fim_ano = TRIM(SUBSTRING_INDEX(Fim, ',', -1));

UPDATE anime_ano
SET Fim_ano = NULL
WHERE TRIM(Fim_ano) = '' OR Fim_ano = '?';

UPDATE anime_ano
SET Ini_ano = NULL
WHERE TRIM(Ini_ano) = '' OR Ini_ano = 'Unknown';

SELECT*FROM anime_ano;

DROP TABLE anime_ano;

#quantos animes foram lançados por ano
SELECT COUNT(AnimeName) AS quantidade_anime, Ini_ano AS ano_lançamento
FROM anime_ano
WHERE Ini_ano IS NOT NULL
GROUP BY Ini_ano
ORDER BY Ini_ano DESC;

#quantos animes cada licensor possui
SELECT COUNT(AnimeName) AS contagem_anime , Licensors
FROM anime_filtro
GROUP BY Licensors
ORDER BY contagem_anime DESC;

#quais os 10 animes mais antigos do dataset
SELECT AnimeName, Ini_ano 
FROM anime_ano
WHERE Ini_ano IS NOT NULL
ORDER BY Ini_ano ASC
LIMIT 10;

#quais animes tem dropped acima da média, mas que tem uma score acime da média
SELECT AnimeName, Score
FROM anime_filtro 
WHERE Dropped > (SELECT AVG(Dropped) FROM anime_filtro) AND Score > (SELECT AVG(Score) FROM anime_filtro)
ORDER BY Score;

#Liste os 5 animes com mais avaliações para cada ano de lançamento
WITH RankedAnimes AS (
    SELECT 
        a.AnimeName, 
        a.Score, 
        b.Ini_ano,
        ROW_NUMBER() OVER (PARTITION BY b.Ini_ano ORDER BY a.Score DESC) AS Ranking
    FROM anime_filtro a
    LEFT JOIN anime_ano b ON a.AnimeName = b.AnimeName
)
SELECT AnimeName, Score, Ini_ano
FROM RankedAnimes
WHERE Ranking <= 5
ORDER BY Ini_ano DESC, Score DESC;
