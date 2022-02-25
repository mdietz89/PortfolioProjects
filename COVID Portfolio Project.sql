select * from CovidDeaths 
where continent is not null
order by 3,4

--select data we will be using
select Location, Date, total_cases, new_cases,total_deaths, population from Coviddeaths order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying after contracting covid in given country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage from CovidDeaths
where location = 'United States' --and continent is not null
order by 1,2

--looking at total cases vs population
--shows percentage of pop that got COVID
select location, date, population,total_cases,(total_cases/population) * 100 as COVIDInfectionPercentage from CovidDeaths
where location = 'United States' --and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,MAX((total_cases/population)) * 100 as PercentPopulationInfected from CovidDeaths
--where location = 'United States'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--looking at countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
--where location = 'United States'
where continent is null
group by location
order by TotalDeathCount desc


--BREAK THINGS DOWN BY CONTINENT, can replace Location with Continent above 


--looking at continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
--where location = 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from CovidDeaths
--where location = 'United States' --and 
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingVaccinationCount
From CovidVaccinations cv
join CovidDeaths cd
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

--USE CTE
With PopvsVac(continent,location,date,population,new_vaccinations,rollingvaccinationcount)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingVaccinationCount
From CovidVaccinations cv
join CovidDeaths cd
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select * , (rollingvaccinationcount/population) * 100
from PopvsVac

--use temp table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(max),
Location nvarchar(max),
Date datetime,
Population bigint,
New_Vaccinations bigint,
RollingVaccinationCount bigint
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingVaccinationCount
From CovidVaccinations cv
join CovidDeaths cd
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

select * , (rollingvaccinationcount/population) * 100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingVaccinationCount
From CovidVaccinations cv
join CovidDeaths cd
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated