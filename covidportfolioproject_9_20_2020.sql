select * from dbo.coviddeath$

--select * from dbo.covidvaccination$

select location,date,total_cases,new_cases,total_deaths,population
from dbo.coviddeath$
where continent is not null
order by 1,2


--calculating total cases vs total deaths
select location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as Dealthpercentage
from dbo.coviddeath$
where continent is not null
and location like '%states%'
order by 1,2

--calculating total_cases vs populations

select location,total_cases,population,(total_cases/population)*100 as percentagesofpopulationinfected
from dbo.coviddeath$
where continent is not null
and location like '%states'
order by 1,2

--calculating coutries with the highest infection count compare to population

select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentofpopulationinfected
from dbo.coviddeath$
--where location like '%states%'
where continent is not null
group by location,population
order by percentofpopulationinfected desc

--calculating countries with highest death count per population

select location,population,max(total_deaths) as highestdealthcount,max((total_deaths/population))*100 as percentageofhighestdeathcount
from dbo.coviddeath$
--where location like '%states%'
where continent is not null
group by location,population
order by percentageofhighestdeathcount desc


-- calculating countries with the highest death count

select location,max(cast(total_deaths as int)) as totaldeathcount
from dbo.coviddeath$
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--let break things down by continent

select continent,max(cast(total_deaths as int)) as totaldeathcount
from dbo.coviddeath$
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--Global numbers
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeathscount,sum(cast(new_deaths as int))/sum(new_cases)*100 as precentpopulationvaccinated
from dbo.coviddeath$
where continent is not null
--group by date
order by 1,2


--Total population vs vaccination using CTE

with popvsvacc (continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplevaccinated
from dbo.coviddeath$ dea
join dbo.covidvaccination$ vac
on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 as percentageofrollingpeoplevaccinated 
from popvsvacc


--Total population vs vaccination using TEMP TABLE
create table percentageofrollingpeoplevaccinated (
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccination int,
rollingpeoplevaccinated int
)
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplevaccinated
from dbo.coviddeath$ dea
join dbo.covidvaccination$ vac
on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 from 
percentageofrollingpeoplevaccinated 


--creating view to store data later for visualization
create view precentpopulationvaccinated as
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeathscount,sum(cast(new_deaths as int))/sum(new_cases)*100 as precentpopulationvaccinated
from dbo.coviddeath$
where continent is not null
--group by date
--order by 1,2

create view Dealthpercentage as
select location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as Dealthpercentage
from dbo.coviddeath$
where continent is not null
and location like '%states%'
--order by 1,2

create view percentagesofpopulationinfected as
select location,total_cases,population,(total_cases/population)*100 as percentagesofpopulationinfected
from dbo.coviddeath$
where continent is not null
and location like '%states'
--order by 1,2

create view percentageofhighestdeathcount as 
select location,population,max(total_deaths) as highestdealthcount,max((total_deaths/population))*100 as percentageofhighestdeathcount
from dbo.coviddeath$
--where location like '%states%'
where continent is not null
group by location,population
--order by percentageofhighestdeathcount desc


create view totaldeathcount as 
select continent,max(cast(total_deaths as int)) as totaldeathcount
from dbo.coviddeath$
--where location like '%states%'
where continent is not null
group by continent
--order by totaldeathcount desc
