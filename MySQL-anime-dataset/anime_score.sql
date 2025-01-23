USE banco_anime;

SELECT * FROM anime_score;

DESCRIBE anime_score;

ALTER TABLE anime_score MODIFY rating INT;
ALtER TABLE anime_score MODIFY anime_id INT;

ALTER TABLE anime_score RENAME COLUMN AnimeTitle TO AnimeName;

#contar quantos usuários tem na base
SELECT COUNT(DISTINCT Username) AS contagem_usuário
FROM anime_score;

#anime mais bem avaliado por usuário
SELECT a.AnimeName, a.Username, a.Rating
FROM anime_score a
INNER JOIN ( 
SELECT MAX(Rating) AS maior_nota, Username
FROM anime_score
GROUP BY Username) b
ON a.Username = b.Username AND a.Rating = b.maior_nota;

#anime pior avaliado por usuário
SELECT a.AnimeName, a.Username, a.Rating
FROM anime_score a
INNER JOIN (
SELECT MIN(Rating) AS menor_nota FROM anime_score) b
ON a.Rating = b.menor_nota;