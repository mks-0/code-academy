CREATE TABLE cran_logs (
    download_date TEXT,
    time TEXT,
    size TEXT,
    r_version TEXT,
	r_arch TEXT,
	r_os TEXT,
	package TEXT,
	version TEXT,
	country TEXT,
	ip_id TEXT
);

DELETE FROM cran_logs
WHERE ip_id = 'ip_id';

UPDATE cran_logs
SET download_date = REPLACE(download_date, '"', '')
WHERE download_date LIKE '"%';

UPDATE cran_logs
SET ip_id = REPLACE(ip_id, '"', '')
WHERE ip_id LIKE '%"';

ALTER TABLE cran_logs ALTER COLUMN download_date TYPE DATE;
ALTER TABLE cran_logs ALTER COLUMN time TYPE TIME without time zone
USING download_date + time::interval;
ALTER TABLE cran_logs ALTER COLUMN size TYPE INTEGER
USING size::integer;
ALTER TABLE cran_logs ALTER COLUMN r_version TYPE varchar(10);
ALTER TABLE cran_logs ALTER COLUMN r_arch TYPE varchar(10);
ALTER TABLE cran_logs ALTER COLUMN r_os TYPE varchar(255);
ALTER TABLE cran_logs ALTER COLUMN ip_id TYPE INTEGER
USING size::integer;

-- 9.1 Give the package name and how many times they're downloaded. Order by the 2nd column descending.
SELECT package, COUNT(*) as count
FROM cran_logs
GROUP BY package
ORDER BY count DESC;

-- 9.2 Give the package ranking (based on how many times it was downloaded) during 9AM to 11AM
SELECT package, COUNT(*) as cnt,
RANK () OVER (ORDER BY COUNT(*) DESC)
FROM (SELECT * FROM cran_logs WHERE time BETWEEN '09:00:00' AND '11:00:00')
GROUP BY package;

-- 9.3 How many records (downloads) are from China ("CN") or Japan("JP") or Singapore ("SG")?
SELECT COUNT(*) as cnt
FROM cran_logs
WHERE country = 'CN' or country = 'JP' or country = 'SG';

-- 9.4 Print the countries whose downloads are more than the downloads from China ("CN")
SELECT country, COUNT(country) as cnt
FROM cran_logs
GROUP BY country
HAVING COUNT(country) > (SELECT COUNT(*) AS cnt FROM cran_logs WHERE country = 'CN');

-- 9.5 Print the average length of the package name of all the UNIQUE packages
SELECT AVG(LENGTH(package))
FROM (SELECT DISTINCT package FROM cran_logs);

-- 9.6 Get the package whose download count ranks 2nd (print package name and its download count).
SELECT package, cnt
FROM (
SELECT package, COUNT(*) as cnt,
RANK () OVER (ORDER BY COUNT(*) DESC) AS rank
FROM cran_logs
GROUP BY package)
WHERE rank = 2;

-- 9.7 Print the name of the package whose download count is bigger than 1000.
SELECT package
FROM(
SELECT package, COUNT(*) as count
FROM cran_logs
GROUP BY package
ORDER BY count DESC)
WHERE count > 1000;

-- 9.8 The field "r_os" is the operating system of the users.
    -- 	Here we would like to know what main system we have (ignore version number), the relevant counts, 
	--  and the proportion (in percentage).
SELECT r_os, cnt, (CAST(cnt AS FLOAT)*100/CAST((SELECT COUNT(*) FROM cran_logs) AS FLOAT))::numeric(10, 2) as pct
FROM (
SELECT r_os, COUNT(r_os) as cnt
FROM (SELECT REGEXP_REPLACE(r_os, '[^a-zA-Z]', '', 'g') AS r_os FROM cran_logs)
GROUP BY r_os)
ORDER BY pct DESC;

