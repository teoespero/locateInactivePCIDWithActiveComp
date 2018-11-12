-- where are we
select
 upper(@@SERVERNAME) as ServerName,
 DB_NAME() as DBName,
 DistrictID,
 DistrictAbbrev
 DistrictTitle
from tblDistrict
  
-- block 1
-- find comps that are referencing an
-- inactive PCID
select
 cd.EmployeeID,
 te.Fullname,
 pcd.SlotNum,
 cd.CompDetailsID,
 ct.CompType,
 pcd.PositionControlID,
 pcd.InactiveDate,
 (select max(PositionControlID) from tblPositionControlDetails where SlotNum = pcd.SlotNum and InactiveDate is null) as theNewPCID
 into #theNewSlots
from tblCompDetails cd
inner join
 tblPositionControlDetails pcd
 on cd.cdPositionControlID = pcd.PositionControlID
 and pcd.InactiveDate is not null
 and cd.InactiveDate is null
inner join
 tblEmployee te
 on te.EmployeeID = cd.EmployeeID
 and te.TerminateDate is null
inner join
 tblCompType ct
 on cd.CompTypeID = ct.CompTypeID
where
 cd.FiscalYear = 2018
 
-- block 2
select * from #theNewSlots
where (theNewPCID is not null and PositionControlID != theNewPCID)
  
-- block 3
update tblCompDetails
 set
  cdPositionControlID = tns.theNewPCID
from #theNewSlots tns
inner join
 tblCompDetails cd
 on cd.CompDetailsID = tns.CompDetailsID
 where
   theNewPCID is not null
  
-- block 4
drop table #theNewSlots