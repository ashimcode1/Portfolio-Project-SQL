
--looking at total cases vs total deaths
select location,date, total_cases, total_deaths, new_cases, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%Afg%'
order by 1,2

--looking at total cases vs total deaths in the states
select location,date,total_cases,total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100
from [Portfolio Project]..CovidDeaths
where location like '%States%'
order by 1,2

--- what percentage of the total population got covid

select location, population, total_cases,(total_cases/population) as InfectedPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'

--looking at the maximum number of infected population
select location, Population , max(total_cases) as MaximumCases , MAX(total_cases/population) as InfectedPercentage
from [Portfolio Project]..CovidDeaths
Group by location, Population
Order by InfectedPercentage

-- showing highest death counts per population by continent

select continent,Max(CAST([Total_Deaths] as int)) as Maximumdeaths
from [Portfolio Project]..CovidDeaths
where continent is not null
Group by Continent
order by Maximumdeaths desc

-- shows likelihood of dying if you contact covid in your country
select location , total_deaths , total_cases , (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%' and total_deaths is not null
Group by location,total_deaths,total_cases

-- Global Numbers
select sum(cast(new_cases as int)) as total_cases , sum(cast(new_deaths as int)) as total_deaths,(sum(cast(total_deaths as float))/sum
(cast(total_Cases as float)))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null


--joining two tables together

select *
from [Portfolio Project]..CovidDeaths dea
join
[Portfolio Project]..CovidVaccinations vac
on dea.date=vac.date and dea.location=vac.location

--looking at total population vs vacinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over 
(partition by dea.location 
order by dea.location)	as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join
[Portfolio Project]..CovidVaccinations vac
on dea.date=vac.date and dea.location=vac.location

-- using CTE
with PopvsVac(Continent,Location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(Float,vac.new_vaccinations))
over 
(partition by dea.location 
order by dea.location)	as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join
[Portfolio Project]..CovidVaccinations vac
on dea.date=vac.date and dea.location=vac.location)

select * from PopvsVac

--creating a temporotary table
 create table #PercentPeopleVaccinated
(
Continent nvarchar(255),Location nvarchar(255),Date datetime,
Population numeric, New_vaccinations numeric ,RollingPeopleVaccinated numeric)
Insert into #PercentPeopleVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(Float,vac.new_vaccinations))
over 
(partition by dea.location 
order by dea.location)	as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join
[Portfolio Project]..CovidVaccinations vac
on dea.date=vac.date and dea.location=vac.location



select *,(RollingPeopleVaccinated/population)*100
from #PercentPeopleVaccinated

-- creating a view

Create View 
PercentagePopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(Float,vac.new_vaccinations))
over 
(partition by dea.location 
order by dea.location)	as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join
[Portfolio Project]..CovidVaccinations vac	
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null

