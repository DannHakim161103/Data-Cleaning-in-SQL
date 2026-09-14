-- Data Cleaning --

select*
FROM layoffs;

create table layoffs_staging
like layoffs;

select*
from layoffs_staging;

insert layoffs_staging
select*
from layoffs;

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Identify Duplicates --


select*
from layoffs_staging;

select*,
row_number ( ) over
(PARTITION BY company,location,total_laid_off,`date`, percentage_laid_off,industry) as row_num
from layoffs_staging;

with DUPLICATE_CTE as 
(
select*,
row_number ( ) over
(PARTITION BY company,location,total_laid_off,`date`, percentage_laid_off,industry) as row_num
from layoffs_staging
)

select*
from duplicate_cte
where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select*
from layoffs_staging2;

insert into layoffs_staging2
select*,
row_number ( ) over
(PARTITION BY company,location,total_laid_off,`date`, percentage_laid_off,industry) as row_num
from layoffs_staging;

select*
from layoffs_staging2
where row_num >1;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STEP 1: REMOVE DUPLICATES --

delete 
from layoffs_staging2
where row_num > 1;

select*
from layoffs_staging2
where row_num >1;

select*
from layoffs_staging2;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STEP 2 : STANDARDIZED THE DATA --

select distinct company
from layoffs_staging2;

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select*
from layoffs_staging2;

select distinct industry 
from layoffs_staging2
order by 1;

select distinct location
from layoffs_staging2
order by 1;

select*
from layoffs_staging2
where location like 'kuala lumpur%';

update layoffs_staging2
set location = 'Malmo, Non-U.S.'
where location like 'MalmÃ¶, Non-U.S.%';


select distinct country
from layoffs_staging2
order by 1;

select*
from layoffs_staging2;

select distinct `date`
from layoffs_staging2;

select `date`,
Str_to_date (`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set date = Str_to_date (`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STEP 3 : NULLS AND BLANKS

select*
from layoffs_staging2
where total_laid_off is null;

update layoffs_staging2
set industry = null
where industry = ' ';

select*
from layoffs_staging2
where industry is null
or industry = ' ';

select*
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.company is null or t1.company = ' ')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 4 : REMOVING UNNECESSARY COLUMN

select*
from layoffs_staging2;

DELETE 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select*
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;

