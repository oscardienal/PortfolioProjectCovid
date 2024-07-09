
select *
from PortfolioProjectCovid..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProjectCovid..CovidVaccinations
--order by 3,4

-- Select Data that going to be used

Select location,date, total_cases,new_cases, total_deaths, population
from PortfolioProjectCovid..CovidDeaths
where continent is not null
order by 1,2

	
-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of Dying If You Contract Covid in Your Country
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
Where Location like '%Indonesia%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows What Percentage of Population Got Covid

Select location,date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
--Where Location like '%Indonesia%'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population
	
Select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
--Where Location like '%Indonesia%'
Group by location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
	
Select location, MAX(cast(total_deaths as int)) as TotalDeatchCount
from PortfolioProjectCovid..CovidDeaths
--Where Location like '%Indonesia%'
where continent is not null
Group by location
order by TotalDeatchCount desc


-- Break Down the Data By Continent

	
-- Showing Continents with The Highest Death Count per Population
	
Select continent, MAX(cast(total_deaths as int)) as TotalDeatchCount
from PortfolioProjectCovid..CovidDeaths
--Where Location like '%Indonesia%'
where continent is not null
Group by continent
order by TotalDeatchCount desc



-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
--Where Location like '%Indonesia%'
where continent is not null
--Group By date
order by 1,2



--Looking at Total Population vs Vaccination
	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

with Popsvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From Popsvac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
