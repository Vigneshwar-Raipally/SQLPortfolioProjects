--To fetch the Data from Covid_Deaths table
select * from SQLPortfolioProject..CovidDeaths
order by 3,4

--select * from SQLPortfolioProject..CovidVaccinations
--order by 3,4

--Query to display required columns from the table and arranging them in required order
Select location, date, total_cases, total_deaths from SQLPortfolioProject..CovidDeaths
order by 1,2

-- Total_cases vs total_deaths
Select location, total_cases, total_deaths, (Total_deaths/Total_cases)*100 Death_Percentage
from SQLPortfolioProject..CovidDeaths

-- Total_cases vs total_deaths of a particular location
Select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 Death_Percentage
from SQLPortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- Fetch the data where total_deaths is not equal to null
Select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 Death_Percentage
from SQLPortfolioProject..CovidDeaths
where location like 'i%a' and total_deaths is not null
order by 1,2

--Total_cases vs population of a particular location
--Also shows of the selected location got affected by covid
Select location, date, total_cases, population, (Total_cases/population)*100 Infected_Population
from SQLPortfolioProject..CovidDeaths
where location like 'india' and total_deaths is not null
order by 1,2

-- Gives the total affected population percentage rate of all the countries
Select location, date, total_cases, population, (Total_cases/population)*100 Infected_Population
from SQLPortfolioProject..CovidDeaths
order by 1,2

--To know which countries with highest infection rate compared to population
Select location, max(total_cases) max_cases, population , max(Total_cases/population)*100 Highest_Infected_Rate
from SQLPortfolioProject..CovidDeaths
group by location, population
order by 4 desc

--Countries with highest percentage of death count per population
Select location, max(total_deaths) Max_Deaths, population, max((total_deaths/population))*100 Death_Percentage
from SQLPortfolioProject..CovidDeaths
--where location like 'i%a' and total_deaths is not null
group by location, population
order by 1,2

--Countries with highest death count per population
--Here total_deaths datatype is converted from varchar to int by using cast function
Select location, max(cast(total_deaths as int)) Max_Deaths
from SQLPortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Rewriting above query w.r.t. continents
Select continent, max(cast(total_deaths as int)) Max_Deaths
from SQLPortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--To know the new cases of all the countries of each day
Select date, sum(new_cases) as Total_Cases_Per_Day
from SQLPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--To know the new cases and new deaths of all the countries of each day
--First we need to change the datatype of new_deaths to in from varchar
Select date, sum(new_cases) as Total_Cases_Per_Day, sum(cast(new_deaths as int)) Total_Deaths_Per_Day
from SQLPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--To know the percentage of new_deaths per new_cases
Select date, sum(new_cases) as Total_Cases_Per_Day, sum(cast(new_deaths as int)) Total_Deaths_Per_Day, sum(cast(new_deaths as int))/sum(new_cases)*100 Total_Death_Rate
from SQLPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--To know the the entire world death rate
Select sum(new_cases) as Total_Cases_Per_Day, sum(cast(new_deaths as int)) Total_Deaths_Per_Day, sum(cast(new_deaths as int))/sum(new_cases)*100 Total_Death_Rate
from SQLPortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--CovidVaccination Table related queries

--To fetch the entire data from CovidVaccinations table
Select * from SQLPortfolioProject..CovidVaccinations
order by 3,4

-- Joining CovidDeaths table with CovidVaccinations
Select * from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date

--Total population Vs Vaccinations
Select cd.continent,cd.location,cd.date,cv.new_vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Splitting data by using partition function
Select cd.continent,cd.location,cd.date,cv.new_vaccinations, sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location) as Total_Vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--To get the compound values of total_vaccinations for above query we need to use order by along with partition function
Select cd.continent,cd.location,cd.date,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Converting from one datatype to another datatype without using cast funtion and by using convert function
Select cd.continent,cd.location,cd.date,cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Creating CTE(Common Table Expression) to perform calculations on a newly named column which is given at the time of writing query
with PopVsVac (continent, location, date, population, new_vaccinations, Total_Vaccinations) as
(
Select cd.continent,cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
)
Select *, (Total_Vaccinations/population)*100 Total_Vaccinated_Percent
from popvsvac

--Creating a temporary table instead of using CTE
Drop table if exists PopulationVsVaccinated --(For using the same temporary table more than once we need to erase it before reusing it from database)
Create table PopulationVsVaccinated
(continent nvarchar(100), location nvarchar(100), date datetime, population bigint, new_vaccinations bigint, Total_Vaccinations float)

--Inserting values into temporary table PopulationVsVaccinated
insert into PopulationVsVaccinated
Select cd.continent,cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

--Fetching data from temporary table PopulationVsVaccinated
Select *, (Total_Vaccinations/population)*100 Total_Vaccinated_Percent
from PopulationVsVaccinated

--Creating a view and views does not support order by clause
create view PopulationVSVaccination as
Select cd.continent,cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from SQLPortfolioProject..CovidDeaths cd
join SQLPortfolioProject..CovidVaccinations cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null

--Checking whether the above created views are executing or not
Select * from PopulationVSVaccination

Select * from Death_Percentage
