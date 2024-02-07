

/*
Data Cleaning in SQL Query
*/


SELECT * FROM
PortfolioProject..NationalHousing


--1. Standarize date format

SELECT SaleDate
FROM PortfolioProject..NationalHousing

SELECT SaleDate ,Convert(Date,SaleDate)
FROM PortfolioProject..NationalHousing

UPDATE PortfolioProject..NationalHousing
SET SaleDate=Convert(Date,SaleDate)

ALTER TABLE PortfolioProject..NationalHousing
Add SaleDateConverted Date

UPDATE PortfolioProject..NationalHousing
SET SaleDateConverted=Convert(Date,SaleDate)

SELECT SaleDateConverted,Convert(Date,SaleDate)
FROM PortfolioProject..NationalHousing

--2.Populate Property address data

SELECT *
FROM PortfolioProject..NationalHousing
--WHERE PropertyAddress is not NULL
ORDER BY ParcelID

SELECt a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NationalHousing a
JOIN
PortfolioProject..NationalHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NationalHousing a
JOIN
PortfolioProject..NationalHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL

--2 Breaking out address into individual columns(Address,City,State)

SELECT PropertyAddress
FROM PortfolioProject..NationalHousing
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM PortfolioProject..NationalHousing

ALTER TABLE PortfolioProject..NationalHousing
ADD PropertySplitAddress Nvarchar(255)


alter table PortfolioProject..NationalHousing
drop column PropertySplitAddress


UPDATE PortfolioProject..NationalHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE PortfolioProject..NationalHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject..NationalHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NationalHousing 

--Working on OwnerAddress column

SELECT OwnerAddress
FROM PortfolioProject..NationalHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NationalHousing

ALTER TABLE PortfolioProject..NationalHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject..NationalHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NationalHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject..NationalHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NationalHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject..NationalHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..NationalHousing

--3 Modify 'Y' and 'N' to 'Yes' and 'NO' in 'SoldAsVacant' column.

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y'  THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject..NationalHousing

UPDATE PortfolioProject..NationalHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
                      WHEN SoldAsVacant='N' THEN 'No'
					  ELSE SoldAsVacant
					  END
SELECT *
FROM PortfolioProject..NationalHousing

--4 Remode Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			 UniqueID
			 )row_num
FROM PortfolioProject..NationalHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

SELECT *
FROM PortfolioProject..NationalHousing
ORDER BY ParcelID
 

 --5 Delete Unused Columns

 SELECT *
 FROM PortfolioProject..NationalHousing


 ALTER TABLE PortfolioProject..NationalHousing
 DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

 SELECT *
 FROM PortfolioProject..NationalHousing
 


                                   




