



-- Changing the SaleDate column to not include the time, just the date

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate= CONVERT(Date,SaleDate)

--Populate Property Address Data

SELECT*
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT*
FROM NashvilleHousing
	ORDER BY ParcelID

-- Matching the ParcelID with Addresses that are listed as NULL
-- Join table to itself where the parcel ID is the same but its not in the same row
SELECT *
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON  a.ParcelID= b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON  a.ParcelID= b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Taking the a.propertyaddress(NULL addresses) and putting in the b.PropertyAddress since we found the proper addresses through a self join
-- No more null addresses

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON  a.ParcelID= b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON  a.ParcelID= b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


-- Breaking the address out of individual columns (city, state, street address)

SELECT PropertyAddress FROM NashvilleHousing 
-- Commas (deliminator) only placed before city name in PropertyAddress
-- Using a substring, goes from first value until the comma then using minus 1 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

-- want to separate address, city, and state using PARSENAME
SELECT OwnerAddress 
FROM NashvilleHousing

-- PARSENAME LOOKS FOR PERIODS, SO WE REPLACE COMMAS WITH PERIODS FOR PARSENAME TO WORK, NUMBERING IS RIGHT TO LEFT
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

-- UPDATING TABLE

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvilleHousing

/** Change 1 and 0 to Yes and No in SoldAsVacant field **/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant NVARCHAR(50); 


SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant= 1 THEN 'Yes'
		WHEN SoldAsVacant = 0 THEN 'No'
		ELSE SoldAsVacant /** KEEPS THE SAME IF ELSE **/
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant= 1 THEN 'Yes'
		WHEN SoldAsVacant = 0 THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates
--Row number

SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
		ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
ORDER BY ParcelID;

-- Using CTE
-- Show what the duplicates are
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
		ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)

SELECT * FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

--Deleting the duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
		ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)

DELETE FROM RowNumCTE
WHERE row_num >1


-- Deleting unused columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate