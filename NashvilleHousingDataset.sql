SELECT *
FROM SQLPractice.dbo.NashvilleHousingData 

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM SQLPractice.dbo.NashvilleHousingData

ALTER TABLE NashVilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData 
SET SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------------------------------

---Populate Property Address Data

SELECT * 
FROM SQLPractice.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID  


SELECT a.ParcelID ,a.PropertyAddress , b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress  )
FROM SQLPractice.dbo.NashvilleHousingData a
JOIN SQLPractice.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLPractice.dbo.NashvilleHousingData a
JOIN SQLPractice.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL 


/*
NULLs REMOVED and populated in PropertyAddress 
*/

SELECT PropertyAddress
FROM SQLPractice.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL

------------------------------------------
SELECT SoldAsVacant
FROM SQLPractice.dbo.NashvilleHousingData


/*
SoldAsVacant: Case Statement changing 'Y' to 'Yes', 'N' to 'No' and 'Yes' remained 'Yes'
*/
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM SQLPractice.dbo.NashvilleHousingData
GROUP BY SoldAsVacant 
ORDER By 2
/*
Updated 'Y' and 'N' to 'Yes' and 'No' respectively while 'Yes' remained 'Yes'
*/
UPDATE NashvilleHousingData 
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM SQLPractice.dbo.NashvilleHousingData


---------------------------------------------------------------------

--- Address Split(Address, City, State)

/*
PropertyAddresss Split(Address, City)
*/

SELECT *  
FROM SQLPractice.dbo.NashvilleHousingData

SELECT 
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
FROM SQLPractice.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress nvarchar(225);

UPDATE NashvilleHousingData 
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousingData
ADD PropertySplitCity nvarchar(225);

UPDATE NashvilleHousingData 
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)


/*
OwnerAddresss Split(Address, City, State)
*/

SELECT OwnerAddress   
FROM SQLPractice.dbo.NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM SQLPractice.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress nvarchar(225);

UPDATE NashvilleHousingData 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity nvarchar(225);

UPDATE NashvilleHousingData 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousingData
ADD OwnerSplitState nvarchar(225);

UPDATE NashvilleHousingData 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



SELECT  distinct(LandUse) 
, count(LandUse) OVER(PARTITION BY LandUse)
FROM SQLPractice.dbo.NashvilleHousingData
Group by  [UniqueID ] , LandUse ,PropertyAddress
Order by LandUse 


--------------------------------------------------------------------------

-- Remove Duplicates
/*
-- You can remove duplicates values using different methods.
-- But it's BEST to write your querries then put it inside CTE(Common Table Expression)
-- To identify duplicate rows you can use things like RANK, ORDER_RANK, ROW_NUMBER()
But in this our case, we will be using ROW_NUMBER()
*/

WITH DuplicateRows AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID,
	PropertyAddress,
	SaleDate,
	Saleprice,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num
FROM SQLPractice.dbo.NashvilleHousingData 
)
DELETE                          --first SELECT * to see the duplicates you want to delete before deleting
FROM DuplicateRows 
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM SQLPractice.dbo.NashvilleHousingData

