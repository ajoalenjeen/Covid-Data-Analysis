select date, max(new_cases) as total_case, max(new_deaths) as total_death, max((total_cases/population)*100) as case_percentage, max((total_deaths/total_cases)*100) as death_percentage
from [Covid Analysis]..death_data
where continent is not null
group by date
order by 1;

