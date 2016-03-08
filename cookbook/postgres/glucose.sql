-- --------------------------------------------------------
-- Title: Retrieves a glucose histogram of adult patients 
-- MIMIC version: ?
-- --------------------------------------------------------

WITH agetbl AS
    (SELECT ad.subject_id, ad.hadm_id
     FROM mimiciii.admissions ad
     INNER JOIN mimiciii.patients p
     ON ad.subject_id = p.subject_id 
     WHERE
     -- filter to only adults
    ( 
		(EXTRACT(DAY FROM ad.admittime - p.dob) 
		 + EXTRACT(HOUR FROM ad.admittime - p.dob) /24
		 + EXTRACT(MINUTE FROM ad.admittime - p.dob) / 24 / 60
		 ) / 365.25 
	) > 15
)
    
SELECT bucket, count(*) 
FROM (SELECT width_bucket(valuenum, 0.5, 1000, 1000) AS bucket
      FROM mimiciii.labevents le
      INNER JOIN agetbl 
      ON le.subject_id = agetbl.subject_id
      WHERE itemid IN (50809,50931) 
      AND valuenum IS NOT NULL
      ) AS glucose
GROUP BY bucket 
ORDER BY bucket;
