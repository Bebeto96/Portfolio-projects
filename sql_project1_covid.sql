Select* 
from portfolio_projects..new_covidDeaths
where continent is not null
order by 3,4;   --to select all from a table

Select location, date, total_cases, new_cases, population
from portfolio_projects..new_covidDeaths 
order by 1,2 --to select some columns 

--To select some tables and calculate DeathPercentage (total_death/total_cases)
Select location, date, total_cases, total_deaths, ((CONVERT(float, total_deaths))/(convert(float, total_cases)))*100 as DeathPercentage
from portfolio_projects..new_covidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- shows likeihood of dying in the USA

Select location, date, total_cases, total_deaths, ((CONVERT(float, total_deaths))/(convert(float, total_cases)))*100 as DeathPercentage
from portfolio_projects..new_covidDeaths
where location like '%STATES%'
order by 1,2

--To show likeihood of being affected 
Select location, date, population,total_cases, (total_cases/ population)*100 as InfectionRATE
from portfolio_projects..new_covidDeaths
order by 1,2

-- Total cases vs population
Select location,  population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentPopulationInfected
from portfolio_projects..new_covidDeaths
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select location, Max(convert(int, total_deaths)) as TotalDeathCount
from portfolio_projects..new_covidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--break down by continent
Select location, Max(convert(int, total_deaths)) as TotalDeathCount
from portfolio_projects..new_covidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- show by continent
Select continent, Max(convert(int, total_deaths)) as TotalDeathCount
from portfolio_projects..new_covidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, sum(convert(int,new_cases)) as SUM_NEWCASES, SUM(convert(int,new_deaths)) as SUM_NEWDEATHS,  SUM(convert(float,new_deaths))/NULLIF(sum(convert(float,new_cases)),0)*100 as DeathPercentage--((CONVERT(float, total_deaths))/(convert(float, total_cases)))*100 as DeathPercentage
from portfolio_projects..new_covidDeaths
--where location like '%STATES%'
where continent is not null
group by date
order by 1,2

--overall
Select sum(convert(int,new_cases)) as SUM_NEWCASES, SUM(convert(int,new_deaths)) as SUM_NEWDEATHS,  SUM(convert(float,new_deaths))/NULLIF(sum(convert(float,new_cases)),0)*100 as DeathPercentage--((CONVERT(float, total_deaths))/(convert(float, total_cases)))*100 as DeathPercentage
from portfolio_projects..new_covidDeaths
--where location like '%STATES%'
where continent is not null
order by 1,2

--vaccinations
select*from portfolio_projects..new_covidvaccinations

--joining two tables together
select*
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date

--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

--ROLLING COUNT
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(ISNULL(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location,dea.date) as cummulative_vaccination
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3


--USE CTE to display the sum for each year(COMMON TABLE EXPRESSION)
with PopvsVac (continent, location, date, population, new_vaccinations, cummulative_vaccination)
as
(
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(ISNULL(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location,dea.date) as cummulative_vaccination
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
)
select*, (cummulative_vaccination/population)*100
from PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cummulative_vaccination numeric
)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(ISNULL(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location,dea.date) as cummulative_vaccination
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
--where dea.continent is not null
order by 2,3
select*, (cummulative_vaccination/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

--To make changes and continue 
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
BEGIN
	DROP TABLE #PercentPopulationVaccinated;
END
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cummulative_vaccination numeric
)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(ISNULL(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location,dea.date) as cummulative_vaccination
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
--where dea.continent is not null
order by 2,3
select*, (cummulative_vaccination/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

--To create a view
Create view PercentPopulationVaccinated as
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(ISNULL(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location,dea.date) as cummulative_vaccination
from portfolio_projects..new_covidDeaths dea
Join portfolio_projects..new_covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null

drop view PercentPopulationVaccinated
select *from INFORMATION_SCHEMA.VIEWS;
select * from PercentPopulationVaccinated;