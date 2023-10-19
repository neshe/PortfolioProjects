

-- select data that we are going to be using



-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Turkey%'
order by 1,2

-- total cases vs. population


select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from CovidDeaths
--where location like '%Turkey%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionRate
from CovidDeaths
--where location like '%Turkey%'
group by location, population
order by InfectionRate DESC

-- shiwing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC


-- lets break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount DESC

--showing continets with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC


--global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopularionVaccinated
create table #PercentPopularionVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopularionVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopularionVaccinated

--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated