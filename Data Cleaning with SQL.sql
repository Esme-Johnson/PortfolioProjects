/*-----------------------------------------------------------------------
DATA CLEANING IN SQL. 
-----------------------------------------------------------------------*/
select * 
from [dbo].[Nashville Housing Data ]

/*-----------------------------------------------------------------------
Stanardise Date Format.
-----------------------------------------------------------------------*/
select SaleDate, convert(date, SaleDate) 
from [dbo].[Nashville Housing Data ]

update [dbo].[Nashville Housing Data ] 
set SaleDate = convert(date, SaleDate)


/*-----------------------------------------------------------------------
Populate Propety Address Data.
-----------------------------------------------------------------------*/
select bt.ParcelID, bt.PropertyAddress, bt2.ParcelID, bt2.PropertyAddress, ISNULL(bt.[propertyaddress],bt2.[PropertyAddress])
from [dbo].[Nashville Housing Data ] bt
join [dbo].[Nashville Housing Data ] bt2 
	on bt.ParcelID = bt2.ParcelID
	and bt.UniqueID != bt2.UniqueID
where bt.PropertyAddress is null

update bt
set PropertyAddress = ISNULL(bt.[propertyaddress],bt2.[PropertyAddress])
from [dbo].[Nashville Housing Data ] bt
join [dbo].[Nashville Housing Data ] bt2 
	on bt.ParcelID = bt2.ParcelID
	and bt.UniqueID != bt2.UniqueID
where bt.PropertyAddress is null


/*-----------------------------------------------------------------------
Breaking out Address into Individual Columns (Address, City, State)
-----------------------------------------------------------------------*/
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) + 1), LEN(PropertyAddress)) as City
from [dbo].[Nashville Housing Data]

alter table [dbo].[Nashville Housing Data ]
add Address varchar(50)
Update [dbo].[Nashville Housing Data ]
set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table [dbo].[Nashville Housing Data ]
add City varchar(50) = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) + 1), LEN(PropertyAddress))
update[dbo].[Nashville Housing Data ]
set City = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) + 1), LEN(PropertyAddress))

 Added Address and City by breaking down the PropertyAddress field using substrings. 
 Now lets seperate out the address using parsename on the owner address field. 

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) city,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) state
from [dbo].[Nashville Housing Data ]

alter table [dbo].[Nashville Housing Data ]
add State varchar(50)
update [dbo].[Nashville Housing Data ]
set State = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


/*-----------------------------------------------------------------------
Change 0 and 1 to 'Yes' and 'No' in SoldAsVacant Feild. 
-----------------------------------------------------------------------*/
select distinct(SoldAsVacant), COUNT(soldasvacant)
from [dbo].[Nashville Housing Data]
group by soldasvacant

alter table [dbo].[Nashville Housing Data ]
alter column [SoldAsVacant] varchar(max)

update [dbo].[Nashville Housing Data ]
set SoldAsVacant = 
	case 
		when SoldAsVacant = 0
		then 'No'
		else 'Yes'
	end 

select distinct(SoldAsVacant)
from [dbo].[Nashville Housing Data ] 


/*-----------------------------------------------------------------------
Remove Duplicates. 
-----------------------------------------------------------------------*/
with cteRowNum as 
( 
	select *, 
	ROW_NUMBER() over (
		partition by ParcelID, 
					 PropertyAddress, 
					 SalePrice, 
					 SaleDate, 
					 LegalReference
					 order by UniqueID
					 ) row_num

	from [dbo].[Nashville Housing Data ]
)
delete
from cteRowNum
where row_num > 1


/*-----------------------------------------------------------------------
Remove Unused Columns. 
-----------------------------------------------------------------------*/
select *
from [dbo].[Nashville Housing Data ]

alter table [dbo].[Nashville Housing Data ]
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate