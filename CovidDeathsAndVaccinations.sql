--SELECT TOP (10) *
--FROM CovidDeath
--ORDER BY 3,4

--SELECT TOP (10) *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data for the Project
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeath	
Order By 1,2

-- Total Cases vs Total Deaths
-- Showing Likelihood of death on contracting Covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeath	
--Where location = 'Canada'
Order By 1,2 desc

-- Total cases vs Total Population
-- Shows percentage of population caught Covid
Select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From CovidDeath	
--Where location = 'Canada'
Order By 1,2 desc

-- Countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as MaxPercentPopulationInfected
From CovidDeath
--Where location = 'Canada'
Group by location, population
Order By 4 desc

 --Showing Countries with Highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount,
		Max(total_deaths/population)*100 As DeathPercent
-- Where location = 'Canada'
From CovidDeath
Where Continent is Not Null
Group by location, population
Order By TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Highest Death Count per continent
Select continent, Max(cast(total_deaths as int)) As TotalDeathCount
From CovidDeath
Where continent is not Null 
Group by continent
Order By TotalDeathCount desc

-- GLOBAL Numbers

Select date, SUM(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 As DeathPercentage
from CovidDeath
where continent is not null
group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location,dea.date)
	as RollingPeopleVaccinated 
From CovidDeath	as Dea
Join CovidVaccinations as Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
order by 2,3 

--USE CTE

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated 
From CovidDeath	as Dea
Join CovidVaccinations as Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
-- order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100 As PercentOfRollingPeopleVaccinate 
From PopVsVac 

-- Similar calculation Using Temp Table
Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert Into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated 
From CovidDeath	as Dea
Join CovidVaccinations as Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
-- order by 2,3 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 
order by RollingPeoplevaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated 
From CovidDeath	as Dea
Join CovidVaccinations as Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
-- order by 2,3 

Select *
from PercentPopulationVaccinated

