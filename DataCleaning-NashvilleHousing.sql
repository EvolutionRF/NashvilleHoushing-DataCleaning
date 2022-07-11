/*Data Cleaning */


-- Show All Data--

select * 
from DataCleaning..NashvilleHoushing

------------------------------------------------------------------
-- Standardize Data Format (Menstandarkan format tanggal)

-- Select SaleDate & Saledate Converted (Menampilkan SaleDate dan SaleDate yang sudah Diconversi)
-- The ordinary SaleDate format is DateTime, we convert that to Date Format (Awalnya SaleDate berformat dateTime(YY-MM-DD HH-MM-SS), kita ubah menjadi Date(YY-MM-DD))
select SaleDate, CONVERT (date,SaleDate)
from DataCleaning..NashvilleHoushing

--ADD Coloum SaleDateConvered with Date Format (YY-MM-DD) Menambahkan kolom SaleDateConvered dengan format Date
ALTER Table NashvilleHoushing
Add SaleDateConverted Date;

--Menambahkan data SaleDateConvered dengan data SaleDate yang dikonversi
Update NashvilleHoushing 
SET SaleDateConverted = CONVERT (date,SaleDate)

--Melihat Hasilnya
select SaleDateConverted, CONVERT (date,SaleDate)
from DataCleaning..NashvilleHoushing

-------------------------------------------------------------------------------------
--Populate Property Addres Data

select *
from DataCleaning..NashvilleHoushing
where PropertyAddress is null


select base.ParcelID, base.PropertyAddress, duplicate.ParcelID, duplicate.PropertyAddress, ISNULL(base.PropertyAddress, duplicate.PropertyAddress)
from DataCleaning..NashvilleHoushing base
JOIN DataCleaning..NashvilleHoushing duplicate
	on base.ParcelID = duplicate.ParcelID
	AND base.[UniqueID ] <> duplicate.[UniqueID ]
Where base.PropertyAddress is null


update base
set PropertyAddress = ISNULL(base.PropertyAddress, duplicate.PropertyAddress)
from DataCleaning..NashvilleHoushing base
JOIN DataCleaning..NashvilleHoushing duplicate
	on base.ParcelID = duplicate.ParcelID
	AND base.[UniqueID ] <> duplicate.[UniqueID ]
Where base.PropertyAddress is null


------------------------------------------------
--Breaking addres into into individual coloums(Address,City,State)
select PropertyAddress
from DataCleaning..NashvilleHoushing



------------------------------PropertyAddress
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1,LEN(PropertyAddress)) as City
--SUBSTRING(PropertyAddress, 1, CHARINDEX(' ' , PropertyAddress) -1) as Numb
from DataCleaning..NashvilleHoushing


--Address
ALTER Table NashvilleHoushing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHoushing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)


--City
ALTER Table NashvilleHoushing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHoushing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1,LEN(PropertyAddress))

Select *
from DataCleaning..NashvilleHoushing

-----------------------------OwnerAddress
Select OwnerAddress
from DataCleaning..NashvilleHoushing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitState
from DataCleaning..NashvilleHoushing


--Address
ALTER Table NashvilleHoushing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHoushing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


--City
ALTER Table NashvilleHoushing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHoushing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


--State
ALTER Table NashvilleHoushing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHoushing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
from DataCleaning..NashvilleHoushing

----------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vecant"

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from DataCleaning..NashvilleHoushing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
from DataCleaning..NashvilleHoushing

Update NashvilleHoushing 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
from DataCleaning..NashvilleHoushing


-----------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER by UniqueID
					) row_num
from DataCleaning..NashvilleHoushing
)
select * 
from RowNumCTE
where row_num >1
order by PropertyAddress

DELETE 
from RowNumCTE
where row_num >1


Select *
from DataCleaning..NashvilleHoushing
order by 1


--------------------------------------------------------------------------------
----Delete Unused Columns
Select *
from DataCleaning..NashvilleHoushing

Alter Table DataCleaning..NashvilleHoushing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table DataCleaning..NashvilleHoushing
Drop Column SaleDate



