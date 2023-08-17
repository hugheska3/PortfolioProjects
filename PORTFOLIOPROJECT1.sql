--SELECT * FROM CovidVaccinations
--ORDER BY 3,4

SELECT * FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select Data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

-- Update the values and add NULLs to columns

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases dec;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths dec;

ALTER TABLE CovidDeaths
ALTER COLUMN population DEC;

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases DEC;

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths DEC;

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations numeric;

SELECT population FROM CovidDeaths

UPDATE CovidDeaths 
SET total_deaths= NULL WHERE total_deaths= 0;

UPDATE CovidDeaths 
SET total_cases= NULL WHERE total_cases= 0;

UPDATE CovidDeaths 
SET population= NULL WHERE population= 0;

UPDATE CovidDeaths 
SET continent= NULL WHERE continent= '';

UPDATE CovidDeaths 
SET new_deaths= NULL WHERE new_deaths= 0;

UPDATE CovidDeaths 
SET new_cases= NULL WHERE new_cases= 0;

-- These queries only turned them to NULL temporarily

SELECT NULLIF(total_deaths, 0) AS null_column FROM CovidDeaths

SELECT NULLIF(total_cases, 0) AS null_column FROM CovidDeaths

-- Looking at Toal Cases vs Total Deaths
-- shows the death rate on each date in each country/likelihood of dying of COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS TotalDeathPercentage
FROM CovidDeaths
ORDER BY 1,2;

---- Look at the total number of deaths in the United States and how many people contracted COVID
-- The TotalDeathPercentage showed that the chances of dying from COVID had decreased by April 30, 2021

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS TotalDeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID in the US

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Which countries have the highest infection rates compared to their population?

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

-- Finding the Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breaking things down by continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global numbers

--Finding the global death percentages by date

SELECT date, SUM(CAST(new_cases as int)) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

SELECT SUM(CAST(new_cases as int)) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1


-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Crating View to Store Data Later Visulaizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated
