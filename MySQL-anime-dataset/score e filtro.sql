USE banco_anime;

#anime e gênero com os melhores ratings (acima de 8)
SELECT DISTINCT a.anime_id, a.AnimeName, a.Rating, b.Genres
FROM anime_score a
RIGHT JOIN anime_filtro b ON a.anime_id = b.anime_id AND a.AnimeName = b.AnimeName
WHERE a.Rating >= 8
ORDER BY a.Rating DESC;

#animes com mais de 100 eps e seus ratings, rank e popularidade MUDAR!!!!
SELECT a.AnimeName, a.Username, a.Rating, b.Ranked, b.Popularity, b.Episodes
FROM anime_score a
LEFT JOIN anime_filtro b ON a.anime_id = b.anime_id
WHERE b.Episodes >= 100
ORDER BY a.AnimeName;

#quais animes possuem o menor desvio padrão nas avaliações e quantos episódios eles têm
SELECT a.AnimeName, b.Episodes, STDDEV(a.rating) AS desvio_padrao
FROM anime_score a
LEFT JOIN anime_filtro b ON a.AnimeName = b.AnimeName
GROUP BY a.AnimeName, b.Episodes;