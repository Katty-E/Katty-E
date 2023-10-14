--Составьте сводную таблицу. Посчитайте заказы, оформленные за каждый месяц в течение нескольких лет: с 2011 по 2013 год. 
--Итоговая таблица должна включать четыре поля: invoice_month, year_2011, year_2012, year_2013. Поле invoice_month должно хранить месяц в виде числа от 1 до 12. 
--Если в какой-либо месяц заказы не оформляли, номер такого месяца всё равно должен попасть в таблицу.

SELECT
year11.i_month,
year11.year_2011,
year12.year_2012,
year13.year_2013
FROM
(
SELECT
EXTRACT(month from CAST(invoice_date as date)) as i_month,
count(invoice_id) as year_2011
FROM invoice
WHERE 
EXTRACT(Year from CAST(invoice_date as date))=2011
Group by i_month)
as year11

LEFT JOIN
(
SELECT
EXTRACT(month from CAST(invoice_date as date)) as i_month,
count(invoice_id) as year_2012
From invoice
Where 
EXTRACT(Year from CAST(invoice_date as date))=2012
Group by i_month) as year12 
ON year11.i_month=year12.i_month

LEFT JOIN
(
SELECT
EXTRACT(month from CAST(invoice_date as date)) as i_month,
count(invoice_id) as year_2013
FROM invoice
Where 
EXTRACT(Year from CAST(invoice_date as date))=2013
Group by i_month) as year13
ON year11.i_month=year13.i_month

--Сформируйте статистику по категориям фильмов. Отобразите в итоговой таблице два поля: название категории, число фильмов из этой категории.
--Фильмы для второго поля нужно отобрать по условию. Посчитайте фильмы только с теми актёрами и актрисами, которые больше семи раз снимались в фильмах, вышедших после 2013 года. 
--Назовите поля name_category и total_films соответственно. Отсортируйте таблицу по количеству фильмов от большего к меньшему, а затем по полю с названием категории в лексикографическом порядке.

SELECT
c.name as name_category,
COUNT(DISTINCT (m.film_id)) as total_films
FROM movie as m
LEFT JOIN film_category as fc ON fc.film_id  = m.film_id
LEFT JOIN category as c ON fc.category_id = c.category_id
WHERE m.film_id IN
-- находим фильмы с этими актерами
(SELECT
DISTINCT (m.film_id)
FROM movie as m
LEFT JOIN film_actor as a ON a.film_id = m.film_id
WHERE a.actor_id IN
-- находим таких актеров
(SELECT 
a.actor_id
from film_actor as a
LEFT JOIN movie as m ON a.film_id  = m.film_id
WHERE m.release_year > 2013
GROUP BY a.actor_id
HAVING COUNT(a.film_id) > 7)
)
GROUP BY name_category
ORDER BY total_films DESC, name_category ASC

--Посчитайте среднюю стоимость аренды фильма каждого возрастного рейтинга. Среди них найдите рейтинг с самыми дорогими для аренды фильмами.
--Выведите на экран названия категорий фильмов с этим рейтингом. Добавьте второе поле со средним значением продолжительности фильмов категории.
SELECT
c.name,
AVG(m.length)
FROM movie as m
LEFT JOIN film_category as fc ON fc.film_id = m. film_id
LEFT JOIN category as c ON fc.category_id = c.category_id
WHERE rating in
(
SELECT
rating
FROM movie
GROUP BY rating
ORDER BY AVG(rental_rate) DESC
LIMIT 1
)
GROUP BY c.name

--Для каждой страны посчитайте среднюю стоимость заказов в 2009 году по месяцам. 
--Отберите данные за 2, 5, 7 и 10-й месяцы и сложите средние значения стоимости заказов. Выведите названия стран, у которых это число превышает 10 долларов.

SELECT
t1.billing_country
FROM 
(SELECT
billing_country,
SUM(total)/COUNT(invoice_id) as total
from invoice
WHERE 
EXTRACT(YEAR FROM CAST( invoice_date as date)) = 2009 
and 
EXTRACT(MONTH FROM CAST( invoice_date as date)) = 02
GROUP BY billing_country

UNION ALL

SELECT
billing_country,
SUM(total)/COUNT(invoice_id)
from invoice
WHERE 
EXTRACT(YEAR FROM CAST( invoice_date as date)) = 2009 
and 
EXTRACT(MONTH FROM CAST( invoice_date as date)) = 05
GROUP BY billing_country

UNION ALL

SELECT
billing_country,
SUM(total)/COUNT(invoice_id)
from invoice
WHERE 
EXTRACT(YEAR FROM CAST( invoice_date as date)) = 2009 
and 
EXTRACT(MONTH FROM CAST( invoice_date as date)) = 07
GROUP BY billing_country

UNION ALL

SELECT
billing_country,
SUM(total)/COUNT(invoice_id)
from invoice
WHERE 
EXTRACT(YEAR FROM CAST( invoice_date as date)) = 2009 
and 
EXTRACT(MONTH FROM CAST( invoice_date as date)) = 10
GROUP BY billing_country) as t1
GROUP BY t1.billing_country
HAVING SUM(t1.total)>10

--Нужно посчитать суммарную стоимость треков для каждого плейлиста. 
--Отобразите в таблице два поля: playlist_name с названием плейлиста и total_revenue с суммарной стоимостью. Отсортируйте данные по значению в поле total_revenue от большего к меньшему.
SELECT 
DISTINCT p.name as playlist_name,
SUM (t.unit_price) as total_revenue
FROM track AS t
INNER JOIN invoice_line AS i ON t.track_id=i.track_id
INNER JOIN playlist_track AS pl ON t.track_id=pl.track_id
INNER JOIN playlist AS p ON pl.playlist_id = p.playlist_id
GROUP BY p.name
ORDER BY total_revenue DESC

--Посчитайте пропуски в поле с почтовым индексом billing_postal_code для каждой страны (поле billing_country). 
--Получите срез: в таблицу должны войти только те записи, в которых поле billing_address не содержит слов Street, Way, Road или Drive. Отобразите в таблице страну и число пропусков, если их больше 10.
SELECT
billing_country,
COUNT(*)-COUNT(billing_postal_code)
FROM invoice
WHERE 
billing_address like '%Street%' or
billing_address like '%Way%' or
billing_address like '%Road%' or
billing_address like '%Drive%'
GROUP BY billing_country
HAVING (COUNT(*)-COUNT(billing_postal_code))>6