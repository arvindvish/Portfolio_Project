
select *
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..covid_vaccinations
--order by 3,4

--Select data that we are going to be using 

select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2

--Looking total cases Vs Total Deaths

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathspercentage
from PortfolioProject..covid_deaths
where location like '%india%'
and continent is not null
order by 1,2

--looking at total cases vs populations--
-- show what percentage of population got covid--

select location,date,population, total_cases, (total_cases/population)*100 as percentagecovid
from PortfolioProject..covid_deaths
where continent is not null
--where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population 

select location, population, max(total_cases) as highestinfection,max(total_cases/population)*100 as percentpopulationinfected
from PortfolioProject..covid_deaths
--where location like '%india%'
where continent is not null
group by location, population
order by percentpopulationinfected desc

--Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..covid_deaths
where continent is not null
--where location like '%india%'
group by location
order by totaldeathcount desc

--lets breck things down by continent

--showing continents with the highest death count per population 

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..covid_deaths
where continent is not null
--where location like '%india%'
group by continent
order by totaldeathcount desc

--global numbers

select date, sum (new_cases)as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum (new_cases)*100  as deathspercentage
from PortfolioProject..covid_deaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

--total sum cases & deaths

select sum (new_cases)as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum (new_cases)*100  as deathspercentage
from PortfolioProject..covid_deaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


--Vaccinations
--looking at totak population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
-- ( RollingVaccinated/population)*100
from PortfolioProject..covid_deaths  dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use Cte

with PopvsVac(continent, location,date, population,new_vaccinations,RollingVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
-- ( RollingVaccinated/population)*100
from PortfolioProject..covid_deaths  dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingVaccinated/population)*100
from PopvsVac

--Temp table


drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
-- ( RollingVaccinated/population)*100
from PortfolioProject..covid_deaths  dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visulization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
-- ( RollingVaccinated/population)*100
from PortfolioProject..covid_deaths  dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated