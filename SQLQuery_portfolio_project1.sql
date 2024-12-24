
Select *
From [CovidDeaths$]
Where continent is not null
ORDER by 3,4

--Select *
--From [CovidVaccinations$]
--ORDER by 3,4

-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From [CovidDeaths$]
Where continent is not null
order by 1,2

-- looking at total cases vs total deaths (the percentage of dying if you get infected given the location)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [CovidDeaths$]
Where location like '%tunisia%'
order by 1,2

-- looking at total cases vs population (percentage of infection in the population)

Select location, date, total_cases, population, (total_cases/population)*100 as testPercentage
From [CovidDeaths$]
Where location like '%tunisia%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as highestInfectionCount, Max((total_cases/population)*100) as infectionRate
From [CovidDeaths$]
-- Where location like '%tunisia%'
Group by location, population
order by infectionRate desc

-- showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From [CovidDeaths$]
-- Where location like '%tunisia%'
Where continent is not null
Group by location
order by totalDeathCount desc

-- let's break this down by continent

Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From [CovidDeaths$]
-- Where location like '%tunisia%'
Where continent is null
Group by location
order by totalDeathCount desc

-- showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as totalDeathCount
From [CovidDeaths$]
-- Where location like '%tunisia%'
Where continent is not null
Group by continent
order by totalDeathCount desc

-- global numbers

Select date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathPercentage
From [CovidDeaths$]
--Where location like '%tunisia%'
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathPercentage
From [CovidDeaths$]
--Where location like '%tunisia%'
Where continent is not null
--Group by date
order by 1,2

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [CovidDeaths$] dea
Join [CovidVaccinations$] vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP table

Drop Table if exists #VaccinatedPopulationRatio
Create Table #VaccinatedPopulationRatio
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #VaccinatedPopulationRatio
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [CovidDeaths$] dea
Join [CovidVaccinations$] vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #VaccinatedPopulationRatio


--Create view to store data for later visualizations

Create View VaccinatedPopulationRatio as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [CovidDeaths$] dea
Join [CovidVaccinations$] vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From VaccinatedPopulationRatio

Create view HighestInfection as
Select location, population, Max(total_cases) as highestInfectionCount, Max((total_cases/population)*100) as infectionRate
From [CovidDeaths$]
Group by location, population

Create View HighestDeathCount as
Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From [CovidDeaths$]
Where continent is not null
Group by location

Create View DeathCountByContinent as
Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From [CovidDeaths$]
-- Where location like '%tunisia%'
Where continent is null
Group by location
