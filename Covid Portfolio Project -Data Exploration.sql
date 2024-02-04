--QUERY 1 SELECT ALL COLUMNS FROM CovidDeaths table
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--QUERY 2 SELECT ALL COLUMNS FROM CovidVaccinations
SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

--QUERY 3 SELECT COLUMN location, date, total_cases,new_cases,total_deaths,population FROM CovidDeaths

SELECT location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--QUERY 4 LOOKING TOTAL CASES VS TOTAL DEATHS (SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY)

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--QUERY 5 FOR SPECIFIC LOCATION 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--QUERY 6 TOTAL CASES VS POPULATION (SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID)

SELECT	location,date,total_cases,Population,(total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--QUERY 7 COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount,MAX(total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,Population
ORDER BY PercentPopulationInfected desc

--QUERY 8 COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location ,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--QUERY 9 GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2;

--QUERY 10 PERCENTAGE OF POPULATION THAT HAS RECIEVED AT LEAST ONE COVID VACCINE (TOTAL POPULATION VS VACCINATIONS)

SELECT dea.continent,dea.location,dea.date,dea.Population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY  dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;

--QUERY 11 USING CTE TO PERFORM CALCULATION ON PARTITION BY.

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location=vac.location
		AND dea.date=vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.Population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date)AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location=vac.location
		AND dea.date=vac.date


SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.Population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
       ON dea.location=vac.location
	   AND dea.date=vac.date
WHERE dea.continent is not NULL
