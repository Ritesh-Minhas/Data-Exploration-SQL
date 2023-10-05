-- Selecting the Database

USE PortfolioProject;

--------------------------------------------------------------------------

-- Browsing the Data

SELECT * FROM CovidDeaths;

SELECT * FROM CovidVaccinations;

--------------------------------------------------------------------------

-- Exploring the Data

SELECT location, date, total_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

---------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Death

-- Shows Likelihood of dying by COVID

-- ALTER TABLE CovidDeaths
-- ALTER COLUMN total_deaths float;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2;


----------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Population

-- Shows what percentage of population got Infected by COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2;

-------------------------------------------------------------------------------------------------------------

-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Death Count per Population

SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

---------------------------------------------------------------------------------------------

-- Looking at Death Count of entire Continent

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

------------------------------------------------------------------------------------------------

-- Looking at Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(NULLIF(new_cases, 0))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Looking at the above numbers collectively

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(NULLIF(new_cases, 0))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Population vs Vaccinations

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER(PARTITION BY a.location ORDER BY a.location, a.date) as TotalVaccinationToDate
FROM CovidDeaths a
JOIN CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE

WITH CTE_PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinationToDate) AS (

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER(PARTITION BY a.location ORDER BY a.location, a.date) as TotalVaccinationToDate
FROM CovidDeaths a
JOIN CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
)

SELECT *, (TotalVaccinationToDate/Population)*100 as TotalPercent_PopulationVaccinated
FROM CTE_PopvsVac;

-- Using TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
TotalVaccinationToDate numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER(PARTITION BY a.location ORDER BY a.location, a.date) as TotalVaccinationToDate
FROM CovidDeaths a
JOIN CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL

SELECT *, (TotalVaccinationToDate/Population)*100 as TotalPercent_PopulationVaccinated
FROM #PercentPopulationVaccinated;

--------------------------------------------------------------------------------------------------------------------------------------

-- Creating Views for later Visualizing it 

CREATE VIEW PercentPopulationVaccinated AS
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER(PARTITION BY a.location ORDER BY a.location, a.date) as TotalVaccinationToDate
FROM CovidDeaths a
JOIN CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL;


CREATE VIEW WorldDeathPercentage AS
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(NULLIF(new_cases, 0))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;

CREATE VIEW PopulationInfectedPercentage AS 
SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population;