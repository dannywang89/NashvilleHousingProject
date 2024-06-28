/*

Cleaning Data In SQL Queries

*/

Select * 
From PortfolioProject..NashvilleHousing

-- Standardize Data Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing;

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate);

--Update NashvilleHousing
--Set SaleDate = CONVERT(Date, SaleDate);


-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
-- Using substring and character index for PropertyAddress
-- Using Parsestring for OwnerAddress
Select PropertyAddress
From PortfolioProject..NashvilleHousing;

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing;

Alter TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1); 

Alter TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

Alter TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3); 

Alter TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2); 

Alter TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1); 


-- Change Y and N to Yes and No in SoldAsVacant field
Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE When SoldAsVacant= 'Y' THEN 'Yes'
	WHEN SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing;

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant= 'Y' THEN 'Yes'
	WHEN SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UNIQUEID) row_num
FROM PortfolioProject..NashvilleHousing
)
-- SELECT *
DELETE
FROM RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress;


-- Delete unused columns
SELECT * 
FROM PortfolioProject..NashvilleHousing;

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


----------------------------------------------------------------------------------------------

-- Cleaning up table data to remove unknown
Select Distinct(propertysplitcity), count(propertysplitcity)
From PortfolioProject..NashvilleHousing
group by propertysplitcity
order by count(propertysplitcity) desc;

Select *
From PortfolioProject..NashvilleHousing
Where propertysplitcity = ' UNKNOWN';

DELETE FROM PortfolioProject..NashvilleHousing
WHERE propertysplitcity = ' UNKNOWN';

Select Distinct(OwnerSplitState), count(OwnerSplitState)
From PortfolioProject..NashvilleHousing
group by OwnerSplitState
order by count(OwnerSplitState) desc;

Select *
From PortfolioProject..NashvilleHousing
Where OwnerSplitState = 'NULL';

-- Look at number of houses sold over by years
SELECT Distinct(YEAR(SaleDateConverted)), count(SaleDateConverted)
FROM PortfolioProject..NashvilleHousing
Group by Year(SaleDateConverted)
Order by Year(SaleDateConverted);

-- Look at average price of homes based on ___
Select Round(AVG(SalePrice),2)
FROM PortfolioProject..NashvilleHousing
Where Bedrooms = 3;


