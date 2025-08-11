Select count(DISTINCT(location)) as Number_of_Countries
from covid19..coviddeaths
Where continent !='';

-- shows all the column names and its data type with extra information
EXEC sp_help 'Covid19..CovidDeaths';

-- shows just the column name and its data type
SELECT
  COLUMN_NAME,
  DATA_TYPE
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_SCHEMA = 'dbo' -- Or your specific schema if not the default
  AND TABLE_NAME = 'CovidDeaths';

SELECT *
FROM Covid19..CovidDeaths
Order by 3,4;

--Select * 
--From Covid19..CovidVaccinations
--Order by 3,4;

Select location, date, total_cases,new_cases,total_deaths,population
From Covid19..CovidDeaths
order by 1,2;


 
 --converting varchar to float(permenantly)
ALTER TABLE Covid19..CovidDeaths
ALTER COLUMN total_deaths float;

 ALTER TABLE Covid19..CovidDeaths
ALTER COLUMN total_cases float;

-- Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, CONCAT(ROUND(((total_deaths/total_cases)*100),2),'%') AS Death_Percentage
From Covid19..CovidDeaths
where total_cases>0 AND location = 'India'
Order by 1,2;

-- total cases vs population
Select location, date,total_cases, population, CONCAT(ROUND(((total_cases/CAST(population AS float))*100),5),'%') as Infected_Percentage
from covid19..coviddeaths
where CAST(population as float)>0 AND continent !=''
order by 1;

--Highest infection rate among the countries
Select location, MAX(total_cases)as Total_Cases,MAX(cast(population as float)) as Total_Population,Concat(round(((MAX(cast(total_cases as float))/MAX(cast(population as float)))*100),3),'%') as Infected_Percentage
From Covid19..CovidDeaths
Where Cast(population as float)>0  AND continent !=''
group by location
order by Infected_Percentage desc;

-- Shows highest death count 
Select location, MAX(CAST(total_deaths as float)) as Total_Deaths,MAX(CAST(population as float)) As Population, CONCAT(ROUND(((MAX(CAST(total_deaths as float))/ MAX(CAST(population as float)))*100),3),'%') AS Death_per_Population
From Covid19..CovidDeaths
Where CAST(population as float)>0 AND   continent !=''
Group by location
Order by Total_deaths desc;

Select continent, MAX(total_deaths) as Total_Death_Count
From Covid19..CovidDeaths
Where continent !=''
Group by continent
Order by Total_Death_Count desc;

-- Global cases
Select SUM(CAST(new_cases as FLOAT)) as Total_Cases, SUM(CAST(new_deaths as FLOAT)) as Total_Deaths,CONCAT(ROUND((SUM(CAST(new_deaths as FLOAT))/ SUM(CAST(new_cases as FLOAT)))*100,2),'%') as Death_Percentage
From Covid19..CovidDeaths
Where continent !='';

Select  continent, SUM(CAST(new_cases as float)) AS Total_Cases, SUM(CAST(new_deaths as float)) AS Total_Deaths, CONCAT(ROUND((SUM(CAST(new_deaths as FLOAT))/ SUM(CAST(new_cases as FLOAT)))*100,2),'%') as Death_Percentage
From Covid19..CovidDeaths
Where continent !='' AND CAST(new_cases as FLOAT)>0
Group by continent
--Order by CONVERT(DATE,date,103);

Select  date,continent, SUM(CAST(new_cases as float)) AS Total_Cases, SUM(CAST(new_deaths as float)) AS Total_Deaths, CONCAT(ROUND((SUM(CAST(new_deaths as FLOAT))/ SUM(CAST(new_cases as FLOAT)))*100,2),'%') as Death_Percentage
From Covid19..CovidDeaths
Where continent !='' AND CAST(new_cases as FLOAT)>0
Group by date,continent
Order by CONVERT(DATE,date,103),2;

--Total population vs Total vaccination
Select d.location, d.date, d.population,v.new_vaccinations, 
SUM(CONVERT(float, v.new_vaccinations)) OVER (PARTITION by d.location ORDER BY CONVERT(DATE, d.date,103)  ) as Running_Total_Vaccinations
From Covid19..CovidDeaths as d
Join Covid19..CovidVaccinations as v
ON d.location = v.location AND d.date =v.date
Where d.continent !=''
Order by 1, Convert(DATE, d.date,103);


--CTE to check the %
WITH PopVac(location,date,population,new_vaccinations,Rolling_total)
AS
(
Select d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(float, new_vaccinations)) OVER (Partition by d.location Order by Convert(date, d.date,103)) AS Rolling_Total
From Covid19..CovidDeaths as d
JOIN Covid19..CovidVaccinations as v
ON d.location = v.location AND d.date = v.date
Where d.continent !=''
)
Select *,CONCAT(ROUND((Rolling_total/Population)*100,2),'%') AS Vaccination_Percentage
From PopVac;


--TEMP Table to check %

DROP Table IF Exists PopVac;
Create table PopVac(
Continent nvarchar(500),
Location nvarchar(500),
Date date,
Population float,
New_vaccinations float,
Rolling_Total float);

Insert Into PopVac
Select d.continent,d.location, CONVERT(date,d.date,103), d.population, v.new_vaccinations,
SUM(CONVERT(float, new_vaccinations)) OVER (Partition by d.location Order by d.location,Convert(date, d.date,103)) AS Rolling_Total
From Covid19..CovidDeaths as d
JOIN Covid19..CovidVaccinations as v
ON d.location = v.location AND d.date = v.date
Where d.continent !='' ;

Select *,CONCAT(ROUND((Rolling_Total/population) *100,2),'%') as PercentageVaccinated
From PopVac;

--creating view
Use Covid19
Drop view If Exists PercentageVaccinated; 
Go
CREATE VIEW PercentageVaccinated as 
Select d.continent,d.location, CONVERT(date,d.date,103) as Date, d.population, v.new_vaccinations,
SUM(CONVERT(float, new_vaccinations)) OVER (Partition by d.location Order by d.location,Convert(date, d.date,103)) AS Rolling_Total
From Covid19..CovidDeaths as d
JOIN Covid19..CovidVaccinations as v
ON d.location = v.location AND d.date = v.date
Where d.continent !='' ;

Select * from PercentageVaccinated;

--Peak Infection day for each country
WITH Peak AS(
Select location, CONVERT(DATE,date,103) as date, CAST(new_cases as float) as New_cases, 
RANK() OVER (Partition by location Order by new_cases desc) as case_rank
From Covid19..CovidDeaths
where continent !=''
)
select location, date, new_cases as peak_new_cases
From Peak
Where case_rank=1
Order by peak_new_cases desc;

--

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, CONCAT(ROUND(SUM(cast(new_deaths as int))/SUM(cast(New_Cases as float))*100,2),'%') as DeathPercentage
From Covid19..CovidDeaths
--Where location like '%states%'
where continent !=''
--Group By date
order by 1,2;

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid19..CovidDeaths
--Where location like '%states%'
Where continent !='' 
and continent not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc;

Select    Location, Population, SUM(cast(new_cases as float)) as HighestInfectionCount,  SUM((cast(new_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From Covid19..CovidDeaths
where cast(population as float)>0 
Group by Location, Population
order by PercentPopulationInfected desc;


Select Location, Population,date, MAX(cast(total_cases as float)) as HighestInfectionCount,  Max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From Covid19..CovidDeaths
where cast(population as float)>0
Group by Location, Population, date
order by PercentPopulationInfected desc