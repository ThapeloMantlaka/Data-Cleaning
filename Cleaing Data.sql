SELECT *
FROM NashvilleHousing

--1. Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted 
FROM NashvilleHousing

--2. Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null

 --3. Breaking out Address Into Individual Columns (Adress, City, State)
 --3.1 Property Address

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) aS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))


--3.2 Owner Address

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME( REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME( REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME( REPLACE(OwnerAddress, ',' , '.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME( REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',' , '.'),1)


--4. Change Sold As Vacant = 'Y' and 'N' to 'Yes' and 'No'

SELECT Distinct(SoldASVacant), COUNT(SoldASVacant) 
FROM NashvilleHousing
GROUP BY SoldASVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing 

UPDATE NashvilleHousing  
SET SoldAsVacant =  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--5. Remove Duplicates

WITH RowNumCTE AS (
SELECT  * , 
	ROW_NUMBER() OVER( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference ORDER BY UniqueID) Row_Num
FROM NashvilleHousing)
--ORDER BY PercelID

SELECT * --deleted duplicates using DELETE
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress


--6. Delete Unused Columns 

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress