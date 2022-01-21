Select *
From [Portfolio Project]..CovidDeaths
Where Continent is not Null
Order by 3,4;

-- select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project].dbo.CovidDeaths
Order By 1,2;

-- Looking at Total Cases vs Total Deaths
-- get date of the highest maximum percentage in the US

Select location, date, total_cases, total_deaths, 
((total_deaths/total_cases)*100) as Death_Percentage
From [Portfolio Project].dbo.CovidDeaths
Where Location Like '%States'
Order By Death_Percentage DESC;

-- Looking at Total Cases vs Population, Shows what percentage of population got covid
-- get date of the highest maximum percentage in the US
Select Location, date, total_cases, Population, ((total_cases/Population)*100) as CovidPercentage_inPopulation
From [Portfolio Project]..CovidDeaths
where location like '%States'
order by CovidPercentage DESC;

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, max(total_cases) as Highest_Infection_Count, Max((total_cases/Population))*100 as HighestCovidPercentage
From [Portfolio Project]..CovidDeaths
-- Where Location like '%States'
Group By Location, Population
order by HighestCovidPercentage Desc;

-- Showing Countries with Highest Death Count Per Population and Highest Death Percentage

Select Location, Population, max(cast(total_deaths as int)) as Highest_DeathCount, Max((total_deaths/total_cases))*100 as Highest_Death_Percentage
From [Portfolio Project]..CovidDeaths
-- Where Location like '%States'
Where Continent is not Null
Group By Location, Population
order by Highest_DeathCount Desc;

-- Total Death Count breaking down by Continent
-- Showing Continents with highest death count

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
-- Where location like '%states'
where continent is not null
Group by continent
Order by TotalDeathCount DESC;

-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Order By 1, 2;


-- Join, Looking at Total Population vs Vaccination, Rolling Count of People Vaccinated per Location 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2,3


-- Using a CTE to find percentage of people vaccinated per location (RollingPPLVac/population) * 100
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPPLVac)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null

)
Select *, (RollingPPLVac/Population)*100 as PercentagePopVaccinated
From PopvsVac
;

-- Temp Table, Alternative to find percentage of people vaccinated per location (RollingPPLVac/population) * 100
DROP table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(225),
location nvarchar(225),
date datetime, 
population numeric, 
New_vaccinations numeric,
RollingPPLVac numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
and dea.location like 'albania'

Select *, (RollingPPLVac/Population)*100 as PercentagePopVaccinated
From #PercentPopVaccinated;


--Creating view to store data for future visualizations
Create View PerPopVac as
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPPLVac)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null

)
Select *, (RollingPPLVac/Population)*100 as PercentagePopVaccinated
From PopvsVac
;

