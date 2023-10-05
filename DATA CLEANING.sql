--/*
--Data cleaning
--*/


SELECT*
FROM [Nashville Housing ]

--STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(Date, SaleDate) AS DATE
FROM [Nashville Housing ]

UPDATE [Nashville Housing ]
SET SaleDate= CONVERT(Date, SaleDate)

--POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM [Nashville Housing ]
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville Housing ] AS A
JOIN [Nashville Housing ] AS B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville Housing ] AS A
JOIN [Nashville Housing ] AS B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is null

--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM [Nashville Housing ]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN (PropertyAddress)) as Address
FROM [Nashville Housing ]


ALTER TABLE [Nashville Housing ]
Add PropertySplitAddress nvarchar(255)

UPDATE [Nashville Housing ]
SET PropertySplitAddress= SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing ]
Add PropertySplitCity nvarchar(255)

UPDATE [Nashville Housing ]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN (PropertyAddress))

SELECT*
FROM [Nashville Housing ]

SELECT OwnerAddress
FROM [Nashville Housing ]


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', ',') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', ',') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', ',') ,1)
FROM [Nashville Housing ]


ALTER TABLE [Nashville Housing ]
Add OwnerSplitAddress nvarchar(255)

UPDATE [Nashville Housing ]
SET OwnerSplitAddress= SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing ]
Add OwnerSplitCity nvarchar(255)

UPDATE [Nashville Housing ]
SET OwnerSplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN (PropertyAddress))

ALTER TABLE [Nashville Housing ]
Add OwnerSplitState nvarchar(255)

UPDATE [Nashville Housing ]
SET OwnerSplitState = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN (PropertyAddress))

SELECT*
FROM [Nashville Housing ]



--REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT* ,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			    ORDER BY UniqueID
				) row_num
FROM [Nashville Housing ]
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


DELETE
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS

SELECT*
FROM [Nashville Housing ]

ALTER TABLE [Nashville Housing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing ]
DROP COLUMN SaleDate