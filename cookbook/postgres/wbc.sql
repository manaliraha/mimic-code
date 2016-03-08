-- --------------------------------------------------------
-- Title: Retrieves the white blood cell count for adult patients 
-- MIMIC version: ?
-- --------------------------------------------------------

WITH agetbl AS
(
	SELECT ad.subject_id, ad.hadm_id
       FROM mimiciii.admissions ad
       INNER JOIN mimiciii.patients p
       ON ad.subject_id = p.subject_id 
       WHERE
       -- filter to only adults
        ( 
		(extract(DAY FROM ad.admittime - p.dob) 
			+ extract(HOUR FROM ad.admittime - p.dob) /24
			+ extract(MINUTE FROM ad.admittime - p.dob) / 24 / 60
			) / 365.25 
	) > 15
)
SELECT bucket/10, count(*) 
FROM (SELECT width_bucket(valuenum, 0, 100, 1001) AS bucket
      FROM mimiciii.labevents le
      INNER JOIN agetbl
      ON le.subject_id = agetbl.subject_id
      WHERE itemid in (51300, 51301) 
      AND valuenum IS NOT NULL) AS white_blood_cell_count 
GROUP BY bucket 
ORDER BY bucket;
