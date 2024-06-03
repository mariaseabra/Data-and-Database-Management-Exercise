/* 1.Listar os títulos de todos os filmes dirigidos por Steven Spielberg ou James Cameron */

SELECT titulo
from Filme
where realizador = 'Steven Spielberg' or realizador = 'James Cameron'

/* 2. Listar todos os anos em que foi produzido um filme que recebeu uma classificação de 4 ou 5, e
ordene-os por ordem crescente. */ 

SELECT  
    DISTINCT Ano
FROM Filme JOIN Classificacao 
    ON filme.fID = Classificacao.fID
WHERE estrelas = 4 
union
SELECT  
    DISTINCT Ano
FROM Filme JOIN Classificacao 
    ON filme.fID = Classificacao.fID
WHERE estrelas = 5  
ORDER BY ano ASC

/* 3. Listar os títulos de todos os filmes que não têm nenhuma classificação.*/ 

SELECT filme.titulo
from Filme join Classificacao on filme.fID = Classificacao.fID
WHERE ESTRELAS IS NULL

-- O  output devolve uma tabela em branco porque todos os filmes têm pelo menos uma classificação (estrela)

/* 4. Alguns críticos não inseriram a data correspondente à sua classificação. Listar os nomes de todos
os críticos que têm classificações em que a correspondente data é NULL.*/

select c.nome
from classificacao cl join Critico c on cl.cID = c.cID
WHERE cl.dataclassificacao is null 


/* 5. Escrever uma query que apresenta as classificações no seguinte formato: nome do crítico, título
do filme, nº de estrelas e data da classificação. Ordene o resultado por esta ordem: nome do
crítico, título do filme, nº de estrelas.*/

SELECT c.nome, f.titulo, cl.estrelas, cl.dataClassificacao 
from classificacao cl join Critico c on cl.cID = c.cID join filme f on cl.fid = f.fID
order by c.nome, f.titulo, cl.estrelas 

/* 6. Em todos os casos em que o mesmo crítico classificou o mesmo filme mais do que uma vez,
sendo uma classificação posterior superior a uma anterior, listar o nome do crítico e o título do
filme.*/

SELECT 
    c.nome AS Nome_Crítico, 
    f.titulo AS Título_Filme
FROM Classificacao cl1
JOIN Classificacao cl2 
    ON cl1.cID = cl2.cID AND cl1.fID = cl2.fID
JOIN Critico c 
    ON cl1.cID = c.cID
JOIN Filme f 
    ON cl1.fID = f.fID
WHERE cl1.dataClassificacao < cl2.dataClassificacao AND cl1.estrelas < cl2.estrelas

/* 7. Para cada filme com pelo menos uma classificação, pesquisar a classificação máxima que lhe foi
atribuída. Listar o título do filme e a classificação máxima, ordenando por título do filme.*/

SELECT 
    f.titulo AS Título_Filme,
    MAX(CL.estrelas) AS Classificação_Máxima
FROM Filme f 
JOIN Classificacao cl
    ON f.fID=cl.fID
WHERE estrelas IS NOT NULL 
GROUP BY f.titulo
ORDER BY f.titulo

/* 8. Para cada filme com pelo menos uma classificação, listar os seus títulos e as médias das
classificações por ordem decrescente destas últimas. Listar por ordem alfabética os filmes com
as mesmas médias.*/

SELECT
    f.titulo AS Título_Filme,
    AVG(cl.estrelas) AS Média_Classificações
FROM Filme f 
JOIN Classificacao cl
    ON f.fID=cl.fID
WHERE estrelas IS NOT NULL
GROUP BY f.titulo
ORDER BY Média_Classificações DESC, Título_Filme

/* 9. Listar os nomes de todos os críticos que contribuíram com 3 ou mais classificações. */

SELECT 
    c.nome AS Nome_Crítico
FROM Critico c
JOIN Classificacao cl
    ON c.cID=cl.cID
GROUP BY c.nome
HAVING COUNT(estrelas) >= 3

/* 10. Adicione à base de dados os seguintes críticos:
- Diogo Silva, com um cID=209;
- Maria Manuela Simões, com cid=210;
- João Sousa, com cid=211. */

INSERT INTO 
    Critico (cID, nome)
VALUES
    (209, 'Diogo Silva'),
    (210, 'Maria Manuela Simões'),
    (211, 'João Sousa')

SELECT * FROM Critico -- Verificar tabela atualizada

/* 11. Para cada filme, listar o seu título e a diferença entre a classificação mais alta e mais baixa que
lhe foram atribuídas. Ordenar por ordem descendente da diferença de classificações e depois
pelo título do filme */

SELECT
    f.titulo AS Título_Filme,
    MAX(cl.estrelas)-MIN(cl.estrelas) AS Diferença_Classificações
FROM Filme f 
JOIN Classificacao cl
    ON f.fID=cl.fID
GROUP BY f.titulo
HAVING COUNT(cl.estrelas) > 1
ORDER BY Diferença_Classificações DESC, Título_Filme

/* 12. Listar a diferença entre as médias das classificações dos filmes produzidos antes de 1980 e no
ano de 1980 e seguintes. Deve ser calculada a média da classificação para cada filme e depois
calculada a média das médias para os filmes anteriores a 1980 e os produzidos nos anos de 1980
e seguintes. */

WITH ClassificacoesAntes AS (
    SELECT 
        f.titulo, 
        AVG(cl.estrelas) AS Média_Classificação
    FROM Filme f 
    JOIN Classificacao cl ON f.fID = cl.fID
    WHERE f.ano < 1980
    GROUP BY f.titulo
    HAVING COUNT(cl.estrelas) > 1
),
ClassificacoesDepois AS (
    SELECT 
        f.titulo, 
        AVG(cl.estrelas) AS Média_Classificação
    FROM Filme f 
    JOIN Classificacao cl ON f.fID = cl.fID
    WHERE f.ano >= 1980
    GROUP BY f.titulo
    HAVING COUNT(cl.estrelas) > 1
)
SELECT
    AVG(COALESCE(antes.Média_Classificação, 0)) - AVG(COALESCE(depois.Média_Classificação, 0)) AS Diferença_Médias
FROM 
    ClassificacoesAntes antes
FULL JOIN
    ClassificacoesDepois depois ON antes.titulo = depois.titulo;

/* 13. Para todos os realizadores de mais de um filme, listar o seu nome e os títulos dos filmes que
realizaram, ordenados por nome do realizador, título do filme. */

SELECT  
    realizador AS Nome_Realizador,
    titulo AS Título_Filme
FROM Filme
WHERE realizador IN (
    SELECT realizador
    FROM Filme
    GROUP BY realizador
    HAVING COUNT(DISTINCT fID) > 1
)
ORDER BY Nome_Realizador, Título_Filme;

/* 14. Listar o(s) título(s) do(s)filme(s) com a maior média de classificações, bem como essa média. */

WITH RankedFilms AS (
    SELECT  
        f.titulo,
        AVG(estrelas) AS Media,
        RANK() OVER (ORDER BY AVG(estrelas) DESC) AS Rank
    FROM
        Classificacao cl 
    JOIN Filme f 
        ON cl.fid=f.fID
    GROUP BY f.titulo 
)
SELECT
    titulo,
    Media AS Maior_Média
FROM RankedFilms
WHERE RANK = 1

/* 15. Para cada par filme, crítico (título do filme e nome do crítico) liste o nº de classificações (um
filme pode ser avaliado mais do que uma vez por um crítico, em datas diferentes). Listar também
o nº de classificações por filme e por crítico, bem como o nº total de classificações. */

SELECT 
    f.titulo AS Título_Filme,
    cr.nome AS Nome_Crítico,
    COUNT(cl.cID) AS numero_classificacoes
FROM 
    Filme f
JOIN Classificacao cl
    ON f.fID=cl.fID
JOIN Critico cr
    ON cl.cID=cr.cID
GROUP BY CUBE (f.titulo, cr.nome)
ORDER BY f.titulo

/* 16. Apresente o ranking dos filmes por ordem descendente de média de classificação. */

SELECT  
        f.titulo AS Título,
        AVG(estrelas) AS Media_Classificacao,
        RANK() OVER (ORDER BY AVG(estrelas) DESC) AS Ranking_Filme
    FROM
        Classificacao cl 
    JOIN Filme f 
        ON cl.fid=f.fID
    GROUP BY f.titulo 

/* 17. Para cada realizador, apresente o ranking dos seus filmes por ordem descendente de média de
classificação. */

SELECT  
        COALESCE(f.realizador, 'Unknown') AS Realizador,
        AVG(estrelas) AS Media_Classificacao,
        RANK() OVER (ORDER BY AVG(estrelas) DESC) AS Ranking
    FROM
        Classificacao cl 
    JOIN Filme f 
        ON cl.fid=f.fID
    GROUP BY f.realizador
    ORDER BY Media_Classificacao DESC

/* 18. Qual o título do(s) filme(s) e respetivo(s) realizador(es) que obteve(obtiveram) a máxima média
de classificações? */

WITH RankedFilmes AS (
    SELECT 
    f.titulo AS Titulo_Filme,
    COALESCE(f.realizador, 'Unknown') AS Realizador,
    AVG(cl.estrelas) AS Media_Classificacao,
    RANK() OVER (ORDER BY AVG(cl.estrelas) DESC) AS Rank
    FROM Filme f
    JOIN Classificacao cl
        ON f.fID=cl.fID
    GROUP BY f.titulo, f.realizador
)
SELECT
    Titulo_Filme,
    Realizador
FROM RankedFilmes
WHERE Rank = 1

/* 19. Liste o código e o nome dos críticos que não atribuíram nenhuma classificação utilizando o
operador EXISTS. */

SELECT
    cr.cID AS Código_Crítico,
    Nome AS Nome_Crítico
FROM Critico cr
WHERE NOT EXISTS (
    SELECT *
    FROM Classificacao cl
    WHERE cl.cID=cr.cID
)