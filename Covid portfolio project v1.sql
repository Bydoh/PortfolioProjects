Select*
From PortfolioProject..coviddeaths$
Order by 3,4

----Select*
----From PortfolioProject..covidvaccinations$
----Order by 3,4
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths$
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths$
where location Like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..coviddeaths$
--where location Like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeaths$
--where location Like '%states%'
Group by Location, population
Order by PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population

Select location, MAX(Cast(total_deaths AS INT)) AS Total_Death_Count
From PortfolioProject..coviddeaths$
--where location Like '%states%'
where continent is null
Group by Location
Order by Total_Death_Count DESC


--Let's break things down by Continent

Select continent, MAX(Cast(total_deaths AS INT)) AS Total_Death_Count
From PortfolioProject..coviddeaths$
--where location Like '%states%'
where continent is not null
Group by continent
Order by Total_Death_Count DESC



-- GLOBAL NUMBERS

Select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
From PortfolioProject..coviddeaths$
-- where location Like '%states%'
where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
From PortfolioProject..coviddeaths$
-- where location Like '%states%'
where continent is not null
--Group by date
Order by 1,2



--Looking at Total Population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USING CTE

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null





