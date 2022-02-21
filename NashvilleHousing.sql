--data cleaning
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date format
SELECT saledate, CONVERT(DATE, saledate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, saledate) --doesnt work

-- try ALTER TABLE
ALTER TABLE NashvilleHousing
ADD SaleDateNew DATE;

UPDATE NashvilleHousing
SET SaleDateNew = CONVERT(DATE, saledate)

-- Some PropertyAddress are NULL, use self join to find the propertyaddress by Unique ParicelID
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
         ON a.ParcelID = b.ParcelID
		 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
         ON a.ParcelID = b.ParcelID
		 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT
 SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
 SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) AS City
 FROM PortfolioProject.dbo.NashvilleHousing

 --Add new columns as Address
ALTER TABLE NashvilleHousing
ADD Address nvarchar(255);

UPDATE NashvilleHousing
SET Address=SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD City nvarchar(255);

UPDATE NashvilleHousing
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--Use Parsename to split Owneraddress
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM  PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM  PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates
WITH row_num AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference,
			 OwnerAddress
ORDER BY UniqueID) row_number
FROM  PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM row_num
WHERE row_number >1
ORDER BY PropertyAddress

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate