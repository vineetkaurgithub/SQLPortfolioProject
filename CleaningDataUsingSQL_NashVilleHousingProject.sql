-- Cleaning Data Using SQL queries

Select *
From PortfolioProject.dbo.NashVilleHousing

-- Standardize Date Format, by removing the unnecessary time 
Select SaleDate, CONVERT(Date,SaleDate) 
From PortfolioProject.dbo.NashVilleHousing

Alter Table NashVilleHousing
Add Sale_Date Date;
Update NashVilleHousing
Set Sale_Date = Convert(Date,SaleDate)

-- Populate Property Address Data
Select PropertyAddress
From PortfolioProject.dbo.NashVilleHousing
Where PropertyAddress is Null 

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,
	ISNULL(a.propertyaddress, b.PropertyAddress)
from NashVilleHousing as a
join NashVilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashVilleHousing as a
join PortfolioProject.dbo.NashVilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns(Address,City,State)
Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1), 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From PortfolioProject.dbo.NashVilleHousing

alter table PortfolioProject.dbo.NashVilleHousing 
Add PropertySplitAddress Nvarchar(255)
Update PortfolioProject.dbo.NashVilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255) 
Update PortfolioProject.dbo.NashVilleHousing
Set PropertySPlitCity = 
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, Len(PropertyAddress)) 

-- Making changes to Owners Address
Select
parsename(REPLACE(OwnerAddress,',','.'),3),
parsename(REPLACE(OwnerAddress,',','.'),2),
parsename(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing  

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashVilleHousing
Set OwnerSplitAddress = parsename(REPLACE(OwnerAddress,',','.'),3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashVilleHousing
Set OwnerSplitCity = parsename(replace(owneraddress,',','.'),2)

ALter Table PortfolioProject.dbo.NashvilleHousing
Add OwnersSplitState Nvarchar(255)

Update PortfolioProject.dbo.NashVilleHousing
Set OwnersSplitState = parsename(replace(owneraddress,',','.'),1)

--Select *
--from PortfolioProject.dbo.NashVilleHousing
--------------------------------------------------------------------------------------

-- Change  Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashVilleHousing
group by SoldAsVacant

Select SoldAsVacant,
Case When SoldAsVacant = 'N' then 'No'
	WHen SoldAsVacant = 'Y' then 'Yes'
	Else SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

Update NashVilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'N' then 'No'
	WHen SoldAsVacant = 'Y' then 'Yes'
	Else SoldAsVacant
	END

----------------
-- Removing Duplicate Rows - We will use Windows Function

WIth RowNumCTE AS (
Select *,
	Row_Number() over( Partition by 
						ParcelID, 
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
					Order by UniqueID ) as rownum
	From PortfolioProject.dbo.NashVilleHousing )
Delete 
From RowNumCTE
where rownum >1

-- Delete Unused Columns

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--
Select *
From PortfolioProject.dbo.NashVilleHousing



