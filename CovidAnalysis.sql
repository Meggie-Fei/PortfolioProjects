select * from PortfolioProject..covid_death
order by 3,4;

--select * from PortfolioProject..covid_vaccination
--order by 3,4



--Total Cases vs Total Deaths
SELECT Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_death
WHERE location like 'Australia'
ORDER BY 1,2

SELECT Location, date, total_cases,  population,  (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..covid_death
WHERE location like 'Australia'
ORDER BY 1,2 DESC

--Looking at countries with the highest infection rate compared to population
SELECT Location, MAX(total_cases) as HighestInfectionCount,  population,  MAX(total_cases/population)*100 as CasePercentage
FROM PortfolioProject..covid_death
GROUP BY Location, population
ORDER BY 4 DESC

-- Looking at countries with the highest death rate
SELECT Location, MAX(total_deaths) as TotalDeathCount,  population,  MAX(cast(total_deaths as float)/population)*100 as DeathPercentage
FROM PortfolioProject..covid_death
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 4 DESC

-- Looking at continent with the highest death rate
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..covid_death
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Looking at new cases per day
SELECT date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalDeaths
FROM PortfolioProject..covid_death
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC

--Join tables
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.date) as Runningtotal
FROM PortfolioProject..covid_death dea
JOIN PortfolioProject..covid_vaccination vac
ON dea.date= vac.date AND dea.location=vac.location
WHERE dea.continent is not null
ORDER BY 2,3


--CTE
WITH VacRate (continent, location, date, population,new_vaccinations, runningtotal)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.date) as Runningtotal
FROM PortfolioProject..covid_death dea
JOIN PortfolioProject..covid_vaccination vac
ON dea.date= vac.date AND dea.location=vac.location
WHERE dea.continent is not null
)

select *, (cast(runningtotal as float)/population)*100 from VacRate
-- create View to store data for later visulization

CREATE VIEW VaccinationPercent AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.date) as Runningtotal
FROM PortfolioProject..covid_death dea
JOIN PortfolioProject..covid_vaccination vac
ON dea.date= vac.date AND dea.location=vac.location
WHERE dea.continent is not null

