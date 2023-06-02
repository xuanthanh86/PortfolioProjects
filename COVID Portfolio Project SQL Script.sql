
-- Data Cleansing
update CovidDeaths set population = NULL where population = 0
update CovidDeaths set new_cases = NULL where new_cases = 0
update CovidDeaths set new_deaths = NULL where new_deaths = 0
update CovidDeaths set continent = NULL where continent = ''

update CovidVaccinations set new_vaccinations = NULL where new_vaccinations=''

Select * from CovidDeaths 
where continent is not null
order by 3,4

-- select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


-- looking at Total cases vs total deaths
-- Shows likelihood ò dying if you contract covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'Vietnam'
and continent is not null
order by 1,2

-- Looking at total cases vs Population
-- Shows what percentage of population got Covid
select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%vietnam%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%vietnam%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing the Countries with Highest Death Count per Population
select Location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%vietnam%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population 
-- Comment: the query below is not fairly accurate.
select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%vietnam%'
where continent is not null
Group by continent
order by TotalDeathCount desc

		-- --> below one show correct death count per continent
		select location, MAX(total_deaths) as TotalDeathCount
		from CovidDeaths
		--where location like '%vietnam%'
		where continent is null
		Group by location
		order by TotalDeathCount desc



-- GLOBAL NUMBERS 
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location = 'Vietnam'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE

DROP Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3




