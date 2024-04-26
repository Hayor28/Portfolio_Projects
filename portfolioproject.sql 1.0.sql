select location, date, total_cases, new_cases,total_deaths, population
from CovidDeaths
order by 1,2

--looking for totat_cases vs total_deaths
-- likelihood of dying if you have covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercent
from CovidDeaths
where location = 'nigeria'
order by 1,2

--looking at location vs population
--show the percentage of population thet got covid
select location, date,population, total_cases,  (total_cases/population)*100 as cases_per_pop
from CovidDeaths
where location like '%kingdom'
order by 1,2

--looking at countries highest infection rate per population
select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as cases_per_pop
from CovidDeaths
group by location, population
order by cases_per_pop desc

-- showing countries with the highest death
select location, population, max(total_deaths) as HighestInfectionCount,  max((total_deaths/population))*100 as Death_per_pop
from CovidDeaths
group by location, population
order by Death_per_pop desc

select location, max(cast (total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--lets break things down by continent
select continent, max(cast (total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- global numbers
select date, sum(new_cases) as totalcases, sum(cast (new_deaths as int)) as totaldeath, sum(cast (new_deaths as int))/sum(new_cases)*100 deathpercent
from CovidDeaths
where continent is not null
group by date
order by 1,2 

-- total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
order by 2,3


select location, max(life_expectancy) as gdj
from CovidVaccination
where new_tests is not null
group by location
order by 1,2

--use CTE
with popVvac (continent,location,date,population,new_vaccination,Rolling_People_vaccination)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
)

select *,(Rolling_People_vaccination/population) * 100
from popVvac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent varchar(255),
location varchar (255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_People_vaccination numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null

select *,(Rolling_People_vaccination/population) * 100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


create view Percent_PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date =vac.date

select *
from Percent_PopulationVaccinated