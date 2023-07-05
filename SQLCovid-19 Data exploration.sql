select * from [Covid_project]..cd;
select * from [Covid_project]..cv;


Select location,date,new_cases,total_cases,total_deaths,population from [Covid_project]..cd order by date;

-- Total death percentages in india

select location,date,total_cases,total_deaths,population,Round((total_deaths/total_cases)*100,3) as Total_death_percentage from[Covid_project] ..cd 
where location='India';


-- Countries with Highest Infection Rate compared to Population

Select location,population,max(total_cases) as Highest_infected,max(total_cases/population)*100 as Infection_rate from [Covid_project]..cd
where continent is not null
group by location,population
order by Infection_rate desc;

-- Countries with Highest Death Count per Population

Select location,population,max(cast(total_deaths as bigint)) as Highest_deaths,max(cast(total_deaths as bigint)/population)*100 as Percent_Death_count from [Covid_project]..cd
where continent is not null 
group by location,population
order by Percent_Death_count desc;

--Show continent with highest death count

Select Continent,max(cast(total_deaths as bigint)) as Total_deaths from [Covid_project]..cd
where continent is not null
group by continent
order by total_deaths desc;


-- Global numbers on total cases and total death percentages date wise

select date,sum(new_cases) as total_case,sum(cast(new_deaths as int)) as total_death,(sum(cast(new_deaths as int))/(sum(new_cases)))*100 as death_percentage
from [Covid_project]..cd
where continent is not null
group by date
order by date;
 

-- Total Cases and Total Death percentages  in the world

 select sum(new_cases) as Total_cases,sum(cast(new_deaths as bigint)) as Total_deaths,(sum(cast(new_deaths as bigint))/(sum(new_cases)))*100 as death_percentage
from [Covid_project]..cd;

-- Joining both the tables

 Select * from [Covid_project]..cd d
 join [Covid_project]..cv v
 on d.location=v.location;

 
-- Looking at total population vs total vaccination

select sum(d.population),sum(cast(v.total_vaccinations as bigint)) from [Covid_project]..cd d
left join [Covid_project]..cv v
on v.location=d.location
where d.continent is not null
group by population;

-- Looking at total population vs total vaccination in percentage
-- Using CTE to perform Calculation on Partition By in previous query

with population_vs_vaccination (continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as (select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [Covid_project]..cd d join [Covid_project]..cv v on d.location=v.location 
and d.date=v.date
where d.continent is not null )
select *,(RollingPeopleVaccinated/population)*100 as vaccinated_people_percentage from percentage_population_vaccinated;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #Percentage_Population_Vaccinated

create table #Percentage_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime , 
population numeric , 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #Percentage_Population_Vaccinated

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From [Covid_project]..cd d
Join [Covid_project]..cv v
On d.location = v.location
and d.date = v.date
where d.continent is not null 
select *, (RollingPeopleVaccinated/population)*100 as vaccinated_people_percentage from #Percentage_Population_Vaccinated


-- Creating View to store data for later visualizations

create view a_Percentage_population_vaccination as

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated,
from [Covid_project]..cd d join [Covid_project]..cv v on d.location=v.location 
where d.continent is not null 


create view covid_world_data as 
select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Covid_project]..cd

