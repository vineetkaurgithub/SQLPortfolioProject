Select * 
from PopulationData

Select *
from LiteracyData

-- Total number of rows

Select count(*) 
From PopulationData

Select count(*)
From LiteracyData

-- Select Dataset from states of Jharkhand and Bihar
Select *
From PopulationData
Where State in ('Jharkhand','Bihar')
Order By State

Select *
From LiteracyData
Where State in ('Jharkhand','Bihar')
Order By State

-- Total Population of India
Select Sum(Population) As TotalPopulationIndia
From PopulationData

-- Average Growth Rate of Population
Select round(100*AVG(Growth),2) As AvgPopulationGrowth
From LiteracyData

-- Statewise Average Growth
Select State, round(100*avg(growth),2) as StatewiseAvgGrowth
From LiteracyData
Group By State
Order By State

-- Average Sex Ratio By State 
-- Sex ratio is the ratio of females to 1000 males in a population
Select State, round(AVG(Sex_Ratio),0) as AvgSexRatio
From LiteracyData
Group by State
ORder by 2 

-- Top Performing States in Literacy
-- The literacy rate is defined by the percentage of the population that can read and write.
Select State, round(AVG(Literacy),2) as AvgLiteracy
From LiteracyData 
Group by State
Having round(AVG(Literacy),2) > 90
Order by AvgLiteracy desc

-- Calculating the number of males and females in a State
Select Litdat.state,sum(popdat.population) as Population,
	--round(avg(litdat.sex_ratio),2) as AvgSexRatio,
	round(sum(popdat.population)*avg(litdat.sex_ratio)/(1000+avg(litdat.Sex_Ratio)),2) as FemPop,
	round(sum(popdat.population)*1000/(1000+avg(litdat.Sex_Ratio)),2) as MalePop
from LiteracyData as litdat
inner join PopulationData as popdat
on litdat.District = popdat.District
group by litdat.State

-- trying to find a correlation between avg sex ratio and literacy rate
Select State, round(Avg(Sex_Ratio),2) as AvgSexRatio, round(Avg(Literacy),2) as AvgLit
From LiteracyData
Group by State 
Order by 3 desc 

-- Calculating population density (people per square km of land area) per state
Select Litdat.State, sum(Popdat.Population) as Population, 
	sum(popdat.area_km2) as Area, round(sum(Popdat.Population)/sum(popdat.area_km2),2) as PopDensity
From LiteracyData as Litdat
Join PopulationData as Popdat
On Litdat.District = Popdat.District
Group By Litdat.State
Order by PopDensity desc

-- Bottom 3 District from each state with highest literacy rate

Select lit.*
	From 
	(Select State, District, Literacy,  Rank() over 
	(partition by State order by Literacy ) as rn
	from LiteracyData) as lit
	where rn in (1,2,3)
	
