Select * 
From PortfolioProject..CovidDeaths
order by 3, 4


--Select * 
--From PortfolioProject..CovidVaccinations

--order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, Population, total_cases, (total_cases/population) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%albania%'
Group by Location, Population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%albania%'
where continent is not null
Group by Location
order by TotalDeathCount DESC

--Let's Break Things Down By Contnent


-- Showing continents with the gighest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%albania%'
where continent is not null
Group by continent
order by TotalDeathCount DESC



-- Global Numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases) as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1, 2


-- Looking at Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
	Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	order by 2,3

	-- USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
	Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	--order by 2,3
	)

	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac


--Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
	Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	--order by 2,3


	
	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

