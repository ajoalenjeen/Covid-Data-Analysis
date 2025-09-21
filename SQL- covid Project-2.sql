--COVID DATA ANALYSIS--
select * from [Covid Analysis]..death_data;
select * from [Covid Analysis]..vaccination_data;

--EDA--
--COVID DEATH DATA--

select * from [Covid Analysis]..death_data;


--Total data
select count(*) as total_rows from [Covid Analysis]..death_data;

--Use continent is not null since some continents names are in location where continent column is blank

-- Unique countries and date range

select count(distinct location) AS total_countries,
       min(date) as start_date,
       max(date) as end_date
from [Covid Analysis]..death_data
where continent is not null;


--The data we are gonna use

select location, date, new_cases, total_cases,new_deaths, total_deaths, population
from [Covid Analysis]..death_data
where continent is not null
order by 1,2;


--Global data

select date, sum(new_cases) as day_total_cases, sum(cast(new_deaths as int)) as day_total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Covid Analysis]..death_data
where continent is not null
group by date
order by 1,2;


--Total Cases,Death and Death Percentage

select sum(new_cases) as Total_cases,  sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from [Covid Analysis]..death_data
where continent is not null
order by 1,2 desc;


--Death Percentage Total

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as death_percentage
from [Covid Analysis]..death_data
where continent is not null
order by 1,2;


--Death Percentage in USA

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as death_percentage_usa
from [Covid Analysis]..death_data
where location = 'United States'
order by 2;


--Death Percentage in India

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as death_percentage_india
from [Covid Analysis]..death_data
where location = 'India'
order by 2;


--Death Percentage in China

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as death_percentage_china
from [Covid Analysis]..death_data
where location = 'China'
order by 2;


-- Case Fatality Rate (CFR) = deaths / cases

select location,
       max(total_deaths)/ max(total_cases) as Fatality_rate
FROM [Covid Analysis]..death_data
where continent is not null
group by location
order by fatality_rate desc;


-- Percentage of population infected with COVID over time

select location, date, total_cases, population, ((total_cases/population)*100) as case_percentage_total
from [Covid Analysis]..death_data
where continent is not null
order by 1,2;


-- Percentage of population infected with COVID over time in USA

select location, date, total_cases, population, ((total_cases/population)*100) as case_percentage_usa
from [Covid Analysis]..death_data
where location = 'United States'
order by 1,2;


-- Percentage of population infected with COVID over time India

select location, date, total_cases, population, ((total_cases/population)*100) as case_percentage_india
from [Covid Analysis]..death_data
where location = 'India'
order by 1,2;


-- Percentage of population infected with COVID over time China

select location, date, total_cases, population, ((total_cases/population)*100) as case_percentage_china
from [Covid Analysis]..death_data
where location = 'China'
order by 1,2;


--Top 10 Countries with highest covid count

select top 10 location, population, max(total_cases) as total_cases
from [Covid Analysis]..death_data
where continent is not null
group by location , population
order by total_cases desc;

--Top 10 Countries with highest death count

select top 10 location, population, max(cast(total_deaths as int)) as total_death
from [Covid Analysis]..death_data
where continent is not null
group by location, population
order by total_death desc;


--Top 10 Countries with highest covid rate

select top 10 location, population, max(total_cases) as total_cases_each_country, max((total_cases/population))*100 as total_case_percentage
from [Covid Analysis]..death_data
where continent is not null
group by location , population
order by total_case_percentage desc;


--Top 10 Countries with highest death rate

select top 10 location, population, max(cast(total_deaths as int)) as total_death_each_country, max((total_deaths/population))*100 as total_death_percentage
from [Covid Analysis]..death_data
where continent is not null
group by location, population
order by total_death_percentage desc;


--Continent with highest death count

select location, max(cast(total_deaths as int)) as total_death
from [Covid Analysis]..death_data
where continent is null
and location not in ('World','European Union','International')
group by location
order by total_death desc;




--COVID VACCINATION DATA--

select * from [Covid Analysis]..vaccination_data;


--Join Death and Vaccination table 

select * from [Covid Analysis]..death_data as d
join [Covid Analysis]..vaccination_data as v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null;



--Global Vaccination Coverage

select
    'World' AS location,
    max(v.people_vaccinated) as total_people_vaccinated,
    max(d.population) as world_population,
    (max(v.people_vaccinated) / max(d.population)) * 100 as global_vaccination_percent
from [Covid Analysis]..death_data d
join [Covid Analysis]..vaccination_data v
    on d.location = v.location 
   and d.date = v.date
where d.location = 'World';


--New vaccination data 

select d.continent,d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over(partition by d.location  order by d.location, d.date) total_people_vaccinated
from [Covid Analysis]..death_data d
join [Covid Analysis]..vaccination_data v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2, 3;


--Percentage of people who got vaccination (Using CTE)

with vaccination_percenatage (Continent, Location, Date, Population, New_Vaccination, Total_People_Vaccinated) as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over(partition by d.location  order by d.location, d.date) as rolling_people_vaccinated
from [Covid Analysis]..death_data d
join [Covid Analysis]..vaccination_data v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
)
select *, (Total_people_vaccinated/population)*100 as Vaccination_Percantage 
from vaccination_percenatage
order by 2,3;


--Percenatge of people fully vaccinated vs death rate

select 
    d.location,
    max((v.people_fully_vaccinated / d.population) * 100) as percent_fully_vaccinated,
    max((d.total_deaths / d.population) * 100) as death_rate
from [Covid Analysis]..death_data d
join [Covid Analysis]..vaccination_data v
    on d.location = v.location 
   and d.date = v.date
where d.continent is not null
group BY d.location
order BY 3 desc;


-- Compare total cases before vs after vaccine rollout (per country)

with FirstVaccineDate as (
    select location, min(date) as first_vaccine_date
    from [Covid Analysis]..vaccination_data
    where people_vaccinated is not null
    group by location
)
select 
    d.location,
    sum(case when d.date < f.first_vaccine_date Then d.new_cases else 0 end) as cases_before_vaccine,
    sum(case when d.date >= f.first_vaccine_date then d.new_cases else 0 end) as cases_after_vaccine
from [Covid Analysis]..death_data d
join FirstVaccineDate f
    on d.location = f.location
where d.continent is not null
group by d.location
order by cases_after_vaccine desc;


-- Top 10 most vaccinated countries

select top 10
    d.location,
    max(v.people_vaccinated) as total_vaccinated,
    max(d.population) as population,
    (max(v.people_vaccinated) / max(d.population)) * 100 as vaccination_percent
from [Covid Analysis]..death_data d
join [Covid Analysis]..vaccination_data v
    on d.location = v.location 
   and d.date = v.date
where d.continent is not null
group by d.location
order by vaccination_percent DESC;


