-- COVID 19 DATA EXPLORATION 2022.

-- Carried out this analysis with the following skills: Joins, CTE's, Windows Functions, Aggregrate Functions, Creating Views, Converting Data Types.

Select * 
From [Portfolio Project]..CovidDeaths
Where continent is NOT NULL
order by 3,4

Select * 
From [Portfolio Project]..CovidVaccinations
Where continent is NOT NULL
order by 3,4

-- Selecting the necessary columns I'm starting with
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is NOT NULL
order by 1,2

-- Total Cases vs Total Deaths (in %)
-- This shows the likelihood of dying if you test positive for Covid in Nigeria.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathperc
From [Portfolio Project]..CovidDeaths
Where location = 'Nigeria'
and continent is NOT NULL
order by 1,2

-- Total Cases vs Population.
-- Shows what percentage of the population was infected
-- Although for Nigeria, this figure is slightly incorrect, because testing was not nationwide. A lot of individuals weren't tested.

Select location, date, total_cases, population, (total_cases/population)*100 as Popperc
From [Portfolio Project]..CovidDeaths
Where location = 'Nigeria'
and continent is NOT NULL
order by 1,2

-- Now, for all countries in the world.

Select location, date, total_cases, population, (total_cases/population)*100 as Popperc
From [Portfolio Project]..CovidDeaths
order by 1,2

--Countries with the highest Infection rate, compared to Population

Select location, population, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population))*100 as PerPopInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
order by PerPopInfected desc

-- Countries with Highest Death Count Per Population

Select location, max(total_deaths) as TotDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is NOT NULL
Group by location
order by TotDeathCount desc

-- ANALYSIS BY DIFFERENT CONTINENTS

-- Continents with the highest death rate per population?

Select continent, MAX(total_deaths) as TotDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is NOT NULL
Group by continent
order by TotDeathCount desc

-- GLOBAL NUMBERS

Select Sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPerc
From [Portfolio Project]..CovidDeaths
Where continent is NOT NULL
order by 1,2


-- Total Populations vs Vaccinations
-- This shows the % of population that has received at least one Covid vaccine.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as  PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is NOT NULL
order by 2,3      


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as  PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is NOT NULL
--order by 2,3
)
Select *, (PeopleVaccinated/population)*100
From PopvsVac


-- Using Temp Table

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date

Select *, (PeopleVaccinated/population)*100
From #PercentagePopulationVaccinated


-- Creating a View to store data for Visualization.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is NOT NULL

Create View PerPopInfected as
Select location, population, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population))*100 as PerPopInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
--order by PerPopInfected desc


Create View Nigeria as
Select location, date, total_cases, population, (total_cases/population)*100 as Popperc
From [Portfolio Project]..CovidDeaths
Where location = 'Nigeria'
and continent is NOT NULL
--order by 1,2
