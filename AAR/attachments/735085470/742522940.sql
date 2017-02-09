select  
zz.F_SNAPSHOT_ID as SNAPSHOT_ID, 
zz.F_APP_ID as APP_ID, 
zz.F_B_CRITERION_ID as BC_ID, 
zz.F_T_CRITERION_ID as TC_ID, 
zz.F_M_WEIGHT as M_WEIGHT, 
zz.F_M_CRIT as M_CRIT, 
zz.F_METRIC_ID as metric_ID, 
zz.F_OBJECT_ID as object_id, 
zz.F_OBJECT_FULL_NAME as object_full_name,  
zz.F_STATUS as object_status 

from ( 
select 
cd1.SNAPSHOT_ID as F_SNAPSHOT_ID, 
cpt.SYST_ID as F_SYST_ID, 
cpt.APP_ID as F_APP_ID, 
cqt.B_CRITERION_ID as F_B_CRITERION_ID, 
cqt.T_CRITERION_ID as F_T_CRITERION_ID, 
cqt.M_WEIGHT as F_M_WEIGHT, 
cqt.M_CRIT as F_M_CRIT, 
cqt.METRIC_ID as F_METRIC_ID, 
cd1.OBJECT_ID as F_OBJECT_ID, 
(select 
dso.OBJECT_FULL_NAME 
from training_80_central.DSS_OBJECTS dso 
where dso.OBJECT_ID = cd1.OBJECT_ID) as F_OBJECT_FULL_NAME, 
coalesce(cpxl.METRIC_NUM_VALUE,0) as F_METRIC_NUM_VALUE, 
( case 
when Ocur.OBJECT_CHECKSUM is null then 'deleted' --2  -- deleted
when Oprev.OBJECT_CHECKSUM is null then 'added' -- 1 -- added
when Ocur.OBJECT_CHECKSUM = Oprev.OBJECT_CHECKSUM then 'unchanged' --0 -- unchanged
else 'updated' end) as F_STATUS -- 3 updated

from ( 
select 
OBJECT_ID , 
SNAPSHOT_ID, 
DIAG_ID , 
CONTEXT_ID from training_80_central.DSS_DIAGDETAILS ) cd1  
join training_80_central.DSS_QUALITY_TREE cqt on ( cqt.METRIC_ID = cd1.DIAG_ID ) 
join training_80_central.DSS_PORTF_TREE cpt on ( cd1.CONTEXT_ID = cpt.MODULE_ID and cpt.SNAPSHOT_ID = cd1.SNAPSHOT_ID and cpt.APP_ID = 3 -- Application ID
 ) 

left join (
           select dmr.METRIC_NUM_VALUE, OBJECT_ID, SNAPSHOT_ID 
           from training_80_central.DSS_METRIC_RESULTS dmr 
           where dmr.METRIC_ID = 65005 ) cpxl 
   on cpxl.OBJECT_ID = cd1.OBJECT_ID and cpxl.SNAPSHOT_ID = cd1.SNAPSHOT_ID 
left join training_80_central.DSS_OBJECT_EXCEPTIONS OE 
     on ( OE.OBJECT_ID = cd1.OBJECT_ID and OE.METRIC_ID = cqt.METRIC_ID and cd1.SNAPSHOT_ID < OE.LAST_SNAPSHOT_ID ) 

join training_80_central.ADG_DELTA_SNAPSHOTS d on ( d.APPLICATION_ID = cpt.APP_ID and d.SNAPSHOT_ID = cd1.SNAPSHOT_ID ) 
left outer join training_80_central.DSS_OBJECT_INFO Ocur on ( Ocur.SNAPSHOT_ID = d.SNAPSHOT_ID and Ocur.OBJECT_ID = cd1.OBJECT_ID ) 
left outer join training_80_central.DSS_OBJECT_INFO Oprev on ( Oprev.SNAPSHOT_ID = d.PREV_SNAPSHOT_ID and Oprev.OBJECT_ID = cd1.OBJECT_ID ) ) zz 
where 1=1 order by 6 desc,1 desc, 4 desc, 9 desc