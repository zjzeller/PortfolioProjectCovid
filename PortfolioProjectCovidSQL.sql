SELECT *
FROM covid_db.death
WHERE continent IS NOT NULL 
ORDER BY 3,4;

-- Selecting data for project
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_db.death
WHERE continent is not null
ORDER BY 1, 2;

-- Calculating Total Cases versus Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
FROM covid_db.death
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Total Cases vs Population
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercPopulationInfected
FROM covid_db.death
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PercPopulationInfected
FROM covid_db.death
GROUP BY Location, Population
ORDER BY PercPopulationInfected desc;

-- Countries with highest death count compared to population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM covid_db.death
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Continents with highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM covid_db.death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPerc
FROM covid_db.death
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Looking at Total Population versus Vaccinations
-- Percentage of population that has recieved at least one dose of vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_db.death dea
JOIN covid_db.vaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_db.death dea
JOIN covid_db.vaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

-- Using temp table to create
DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_db.death dea
JOIN covid_db.vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date;
    
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;

-- Creating view for visualization
DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_db.death dea
JOIN covid_db.vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;percentpopulationvaccinatedpercentpopulationvaccinatedpercentpopulationvaccinated

