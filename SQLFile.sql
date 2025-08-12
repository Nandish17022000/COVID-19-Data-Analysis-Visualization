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


/*Select Location, Population,date, MAX(cast(total_cases as float)) as HighestInfectionCount,  Max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From Covid19..CovidDeaths
where cast(population as float)>0
Group by Location, Population, date
order by PercentPopulationInfected desc
*/

