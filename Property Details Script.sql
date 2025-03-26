-- Data cleansing project
SELECT *
FROM Home_Hosing..Property_Details

--Different queries to identify missing data, anomalies data
--Covert the SalesDate to Date data type from date/time data type
SELECT SalesDateConverted
	,CONVERT(DATE, SaleDate)
FROM Home_Hosing..Property_Details

--adding new column
ALTER TABLE Home_Hosing..Property_Details ADD SalesDateConverted DATE

UPDATE Home_Hosing..Property_Details
SET SalesDateConverted = convert(DATE, SaleDate)

--Checking Null values in the PropertyAddress column 
SELECT pd.ParcelID
	,pd.PropertyAddress
	,pd2.ParcelID
	,pd2.PropertyAddress
	,ISNULL(pd.PropertyAddress, pd2.PropertyAddress)
FROM Home_Hosing..Property_Details pd
JOIN Home_Hosing..Property_Details pd2 
	ON pd.ParcelID = pd2.ParcelID
	AND pd.[UniqueID] <> pd2.[UniqueID]
WHERE pd.PropertyAddress IS NULL

UPDATE pd
SET PropertyAddress = ISNULL(pd.PropertyAddress, pd2.PropertyAddress)
FROM Home_Hosing..Property_Details pd
JOIN Home_Hosing..Property_Details pd2 
	ON pd.ParcelID = pd2.ParcelID
	AND pd.[UniqueID] <> pd2.[UniqueID]
WHERE pd.PropertyAddress IS NULL


--Seperate PropertyAddress and OwnerAddress 
--PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropAddress
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropCity
FROM Home_Hosing..Property_Details

--adding two columns for split address
ALTER TABLE Home_Hosing..Property_Details ADD Property_Address NVARCHAR(255)

ALTER TABLE Home_Hosing..Property_Details ADD Property_City NVARCHAR(255)

--update two columns with address and city details
UPDATE Home_Hosing..Property_Details
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE Home_Hosing..Property_Details
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT pd.PropertyAddress
	,pd.Property_Address
	,pd.Property_City
FROM Home_Hosing..Property_Details pd

--OwnerAddress
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Home_Hosing..Property_Details

----adding three columns for split address
ALTER TABLE Home_Hosing..Property_Details ADD Owner_Address NVARCHAR(255)
	,Owner_City NVARCHAR(255)
	,Owner_State NVARCHAR(255)

--update three columns with address, city and state details
UPDATE Home_Hosing..Property_Details
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Home_Hosing..Property_Details
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Home_Hosing..Property_Details
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--checking diffferent values for SoldAsVacant coulmn
SELECT DISTINCT (SoldAsVacant)
FROM Home_Hosing..Property_Details

SELECT SoldAsVacant
	,CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM Home_Hosing..Property_Details
WHERE SoldAsVacant IN (
		'Y'
		,'N'
		)

UPDATE Home_Hosing..Property_Details
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
WHERE SoldAsVacant IN (
		'Y'
		,'N'
		)




--remove duplicates
With DupRecordsCTE AS(
SELECT *, 
ROW_NUMBER() over (
	Partition by ParcelID
				,PropertyAddress
				,SalePrice
				,LegalReference
				order by
					UniqueID
					) AS row_num
from Home_Hosing..Property_Details 
--order by ParcelID
)
Select *
--DELETE
from DupRecordsCTE 
where row_num > 1
--order by ParcelID

