/*--------------------------------------------------------------------------------------
View the tables.
----------------------------------------------------------------------------------------*/
select * 
from Portfolio_Project..CovidDeaths
order by location, date

select * 
from Portfolio_Project..CovidVaccinations
order by location, date 


/*--------------------------------------------------------------------------------------
Select the data we are looking at, ordered by location and date.
----------------------------------------------------------------------------------------*/
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by location, date 


/*--------------------------------------------------------------------------------------
Looking at total cases vs total deaths. Multiplied total_deaths by 1.0 to force cast into a float. 
Shows the liklihood of dying if you contract Covid at any given date in the UK.
----------------------------------------------------------------------------------------*/
select location, date, total_cases, total_deaths, ((total_deaths * 1.0)/ total_cases) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location = 'United Kingdom'
order by location, date


/*--------------------------------------------------------------------------------------
Look at total cases vs population. 
----------------------------------------------------------------------------------------*/
select location, date, total_cases, population, (total_cases / population) * 100 as CovidPercentage
from Portfolio_Project..CovidDeaths
where location = 'United Kingdom'
order by location, date


/*--------------------------------------------------------------------------------------
Looking at countires with highest infection rate by population.
----------------------------------------------------------------------------------------*/
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases / population)) * 100 as CovidPercentage
from Portfolio_Project..CovidDeaths
group by population, location
order by CovidPercentage desc


/*--------------------------------------------------------------------------------------
Show the countries with the highest death rate by population. Where continent is null, the location
displays the continent. 
----------------------------------------------------------------------------------------*/
select location,  Max(total_deaths) as TotalDeathCount, Max((total_deaths/ population)) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by DeathPercentage desc


/*--------------------------------------------------------------------------------------
Showing continents with the highest death count.
----------------------------------------------------------------------------------------*/
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc 


/*--------------------------------------------------------------------------------------
Global numbers of death percentage by infection rate.
----------------------------------------------------------------------------------------*/
select date, SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths * 1.0)/SUM(new_cases) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null 
group by date
order by date 


/*--------------------------------------------------------------------------------------
Join the CovidVaccinations table.
----------------------------------------------------------------------------------------*/
select * 
from Portfolio_Project..CovidDeaths cd
join Portfolio_Project..CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date 


/*--------------------------------------------------------------------------------------
Looking at total population vs vaccination using CTE. 
----------------------------------------------------------------------------------------*/
with PopVsVac (continent, location, date, population, new_vaccinations, totalvaccinationsrolling)
as
(
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as TotalVaccinationsRolling 
	from Portfolio_Project..CovidDeaths cd
	join Portfolio_Project..CovidVaccinations cv 
		on cd.location = cv.location 
		and cd.date = cv.date 
	where cd.continent is not null
)
select *, (totalvaccinationsrolling / population) * 100 AS RollingPercentage from popvsvac



/*--------------------------------------------------------------------------------------
Looking at total population vs vaccination using temporary table.
----------------------------------------------------------------------------------------*/
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
( 
	continent varchar(255), 
	location varchar(255), 
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	totalvaccinationsrolling numeric
)
insert into #PercentPopulationVaccinated 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as TotalVaccinationsRolling 
	from Portfolio_Project..CovidDeaths cd
	join Portfolio_Project..CovidVaccinations cv 
		on cd.location = cv.location 
		and cd.date = cv.date 
	where cd.continent is not null

select *, (totalvaccinationsrolling / population) * 100 AS RollingPercentage from #PercentPopulationVaccinated 


/*--------------------------------------------------------------------------------------
Create a view. 
----------------------------------------------------------------------------------------*/
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as TotalVaccinationsRolling 
	from Portfolio_Project..CovidDeaths cd
	join Portfolio_Project..CovidVaccinations cv 
		on cd.location = cv.location 
		and cd.date = cv.date 
	where cd.continent is not null
	
select * from PercentPopulationVaccinated
