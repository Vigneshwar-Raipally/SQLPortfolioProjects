-- Query to fetch the complete data of the table HousingDataCleaning
Select * from SQLPortfolioProject..HousingDataCleaning

--------------------------------------------------------------------------------------------------------------------------

-- Standadizing Date format by converting datatype of column saledate from datetime to date
Alter table SQLPortfolioProject..HousingDataCleaning alter column SaleDate date -- this query statement permanently changes the datatype of the column
Select * from SQLPortfolioProject..HousingDataCleaning

--Another method to change the datatype. 
--Here the datatype of the column remains same but we are creating a new column with datatype date.
--To remove a particular column permanently from the table we the this alter-along-with-drop-query(Alter table HousingDataCleaning drop column saleda).

--Alter table SQLPortfolioProject..housingdatacleaning
--add saleda datetime

--update SQLPortfolioProject..HousingDataCleaning
--set saleda=convert(datetime,saledate)

--------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data/ To remove any null values in propertyaddress and replace them by actual values.

Select PropertyAddress from SQLPortfolioProject..HousingDataCleaning
where PropertyAddress is NULL

-- To fetch entire data from table where the propertyaddress value is null

Select * from SQLPortfolioProject..HousingDataCleaning
where PropertyAddress is NULL

-- To fetch the data where the parcleid is same but uniqueid is different of housingdatacleaning table
-- If we execute the below query we will see the same parcelid has one null value as propertyaddress and some address in other value.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from SQLPortfolioProject..HousingDataCleaning a
join SQLPortfolioProject..HousingDataCleaning b
	on a.ParcelID=b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

-- To replace those null values in propertyaddress column with it's actual value we can use isnull() function, it will replace null value with actual value.
-- By executing the below query we can see an additional column where the null values are replaced.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from SQLPortfolioProject..HousingDataCleaning a
join SQLPortfolioProject..HousingDataCleaning b
	on a.ParcelID=b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

--To update the table we can use below method which removes the null values of propertyaddress from the table
UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from SQLPortfolioProject..HousingDataCleaning a
join SQLPortfolioProject..HousingDataCleaning b
	on a.ParcelID=b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

--Dividing address column into different columns(Address, City, State, etc...)
--In the propertyAddress column a comma is acting as delimiter(Delimiter is something which seperates two columns, it can be \t ; | ,)

Select PropertyAddress from SQLPortfolioProject..HousingDataCleaning

--Query to seperate PropertyAddress column
Select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from SQLPortfolioProject..HousingDataCleaning

--We need to update those new columns into table
Alter table SQLPortfolioProject..HousingDataCleaning
add PropertyAddressOnly nvarchar(150)

Update SQLPortfolioProject..HousingDataCleaning
set PropertyAddressOnly=substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter table SQLPortfolioProject..HousingDataCleaning
add PropertyCity nvarchar(150)

Update SQLPortfolioProject..HousingDataCleaning
set PropertyCity=substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

Select * from SQLPortfolioProject..HousingDataCleaning

--Another method to seperate propertyaddress column or owneraddress column is by using parsename.
--Parsename seperates from backwards, it seperates based on periods(i.e '.')
Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) State
from SQLPortfolioProject..HousingDataCleaning

Alter table SQLPortfolioProject..HousingDataCleaning
add OwnerAddressOnly nvarchar(150)

Update SQLPortfolioProject..HousingDataCleaning
set OwnerAddressOnly=PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table SQLPortfolioProject..HousingDataCleaning
add OwnerCity nvarchar(150)

Update SQLPortfolioProject..HousingDataCleaning
set OwnerCity=PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table SQLPortfolioProject..HousingDataCleaning
add OwnerState nvarchar(150)

Update SQLPortfolioProject..HousingDataCleaning
set OwnerState=PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select * from SQLPortfolioProject..HousingDataCleaning


--------------------------------------------------------------------------------------------------------------------------

-- Changing the values Y to Yes and N to No in the column SoldAsVacant

Select distinct(SoldAsVacant) from SQLPortfolioProject..HousingDataCleaning

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from SQLPortfolioProject..HousingDataCleaning

update SQLPortfolioProject..HousingDataCleaning
set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

Select Distinct(SoldAsVacant) from SQLPortfolioProject..HousingDataCleaning

Select * from SQLPortfolioProject..HousingDataCleaning

--------------------------------------------------------------------------------------------------------------------------

