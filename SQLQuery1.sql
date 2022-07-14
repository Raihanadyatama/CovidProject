Select * from Covid_Death$ where continent is not null

Select Location, date, total_cases, new_cases, total_deaths, population 
from Covid_Death$ where continent is not null order by 1,2

-- Total Cases VS Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from Covid_Death$ where Location like '%indo%' and continent is not null order by 1,2


-- Total Cases VS Population
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfect 
from Covid_Death$
where continent is not null
order by 1,2

-- Countries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfection, max((total_cases/population))*100 as PercentPopulationInfect 
from Covid_Death$
where continent is not null
group by location, population
order by PercentPopulationInfect desc

-- Countries with highest Death Count per Population
Select Location, max(cast(total_deaths as INT)) as TotalDeathCount
from Covid_Death$
where continent is not null
group by location
order by TotalDeathCount desc

-- Break down by Continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Death$
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing the continent with the highest death count per population
Select continent, max(cast(total_deaths as INT)) as TotalDeathCount
from Covid_Death$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases) as totalcases, sum(cast(new_deaths as INT)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid_Death$
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as totalcases, sum(cast(new_deaths as INT)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid_Death$
where continent is not null
order by 1,2

--Looking at total population vs vaccinations
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over (partition by a.location order by a.location, a.date) as rollingpeoplevaccinated
from Covid_Death$ a join Covid_Vaccinations$ b 
	on a.location=b.location and a.date=b.date
where a.continent is not null
order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as (
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over (partition by a.location order by a.location, a.date) as rollingpeoplevaccinated
from Covid_Death$ a join Covid_Vaccinations$ b 
	on a.location=b.location and a.date=b.date
where a.continent is not null
--order by 2,3
)

select *, (rollingpeoplevaccinated/population)*100 from PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over (partition by a.location order by a.location, a.date) as rollingpeoplevaccinated
from Covid_Death$ a join Covid_Vaccinations$ b 
	on a.location=b.location and a.date=b.date
where a.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over (partition by a.location order by a.location, a.date) as rollingpeoplevaccinated
from Covid_Death$ a join Covid_Vaccinations$ b 
	on a.location=b.location and a.date=b.date
where a.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated



