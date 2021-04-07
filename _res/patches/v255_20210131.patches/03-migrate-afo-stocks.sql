-- drop table ztmp_afi; 
create table ztmp_afi 
select 
	afi.objid, afi.afid, afi.currentseries as startseries, afi.endseries, afi.currentseries, 
	afi.currentstub as startstub, afi.endstub, afi.currentstub, afi.unit, afi.cost, 
	(select qty from afunit where itemid = afi.afid and unit = afi.unit) as unitqty, 
	(select refdate from z20181120_af_inventory_detail where controlid = afi.objid order by lineno limit 1) as dtfiled 
from z20181120_af_inventory afi 
where afi.currentseries <= afi.endseries 
	and afi.respcenter_type = 'AFO' 
order by afi.afid 
; 

CREATE TABLE ztmp_afi_header (
  objid varchar(50) NOT NULL,
  afid varchar(50) NOT NULL,
  txnmode varchar(10) NULL,
  assignee_objid varchar(50) NULL,
  assignee_name varchar(50) NULL,
  startseries int(11) NOT NULL,
  currentseries int(11) NOT NULL,
  endseries int(11) NOT NULL,
  active int(11) NULL,
  org_objid varchar(50) NULL,
  org_name varchar(50) NULL,
  fund_objid varchar(100) NULL,
  fund_title varchar(200) NULL,
  stubno int(11) NULL,
  owner_objid varchar(50) NULL,
  owner_name varchar(255) NULL,
  prefix varchar(10) NOT NULL DEFAULT '',
  suffix varchar(10) NOT NULL DEFAULT '',
  dtfiled date NOT NULL,
  state varchar(50) NOT NULL,
  unit varchar(25) NOT NULL,
  batchno int(11) NULL,
  respcenter_objid varchar(50) NULL,
  respcenter_name varchar(100) NULL,
  cost decimal(16,2) NULL,
  currentindexno int(11) NULL,
  currentdetailid varchar(150) NULL,
  batchref varchar(50) NULL,
  lockid varchar(50) NULL,
  allocid varchar(50) NULL,
  ukey varchar(50) NOT NULL DEFAULT '',
  salecost decimal(16,2) NOT NULL DEFAULT '0.00',
  inventoryid varchar(50) NOT NULL,
  PRIMARY KEY (objid) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


-----------------------------------------------------------------
TEMPLATE-BEGIN: EXECUTE THIS SCRIPTS UNTIL ZERO RECORDS AFFECTED 
-----------------------------------------------------------------

insert into ztmp_afi_header (
	inventoryid, objid, afid, state, txnmode, active, startseries, endseries, currentseries, stubno, prefix, suffix, unit, batchno, dtfiled 
) 
select * 
from ( 
	select 
		z.objid as inventoryid, concat(z.objid,'|',z.currentstub) as objid, afi.afid, 'OPEN' as state, 'ONLINE' as txnmode, 0 as active, 
		z.currentseries as startseries, (z.currentseries + z.unitqty)-1 as endseries, z.currentseries, z.currentstub as stubno, 
		ifnull(afi.prefix,'') as prefix, ifnull(afi.suffix,'') as suffix, afi.unit, 1 as batchno, convert(z.dtfiled, date) as dtfiled
	from ztmp_afi z 
		inner join z20181120_af_inventory afi on afi.objid = z.objid 
		left join ztmp_afi_header zh on zh.objid = concat(z.objid,'|',z.currentstub) 
	where z.currentstub <= z.endstub 
		and zh.objid is null 
)tmp1
;

update 
	ztmp_afi aa, 
	( 
		select z.objid, (z.currentseries + z.unitqty) as nextseries, 
			(select max(stubno)+1 from ztmp_afi_header where inventoryid = z.objid) as nextstub 
		from ztmp_afi z 
		where (select count(*) from ztmp_afi_header where inventoryid = z.objid) > 0 
	)bb 
set aa.currentseries = bb.nextseries, aa.currentstub = bb.nextstub 
where aa.objid = bb.objid 
	and aa.currentseries <= aa.endseries 
;

select * from ztmp_afi where currentseries <= endseries
;

-------------------------------------------------------
TEMPLATE-END 
-------------------------------------------------------


alter table ztmp_afi_header add detailid varchar(50) null
;
create index ix_detailid on ztmp_afi_header (detailid) 
;

update ztmp_afi_header set detailid = ( 
  select objid from z20181120_af_inventory_detail 
  where controlid = ztmp_afi_header.inventoryid 
  order by lineno, refdate, txndate limit 1 
)
; 

create table ztmp_afi_item 
select 
  z.objid, 1 as state, z.objid as controlid, 1 as indexno, d.refid, d.refno, 
  'PURCHASE_RECEIPT' as reftype, d.refdate, d.txndate, 'PURCHASE' as txntype, 
  d.receivedstartseries, d.receivedendseries, d.beginstartseries, d.beginendseries, 
  d.issuedstartseries, d.issuedendseries, d.endingstartseries, d.endingendseries, 
  d.qtyreceived, d.qtybegin, d.qtyissued, d.qtyending, d.qtycancelled, d.remarks, 
  d.refid as aftxnid 
from ztmp_afi_header z 
  inner join z20181120_af_inventory_detail d on d.objid = z.detailid 
; 

insert into af_control ( 
  objid, afid, txnmode, assignee_objid, assignee_name, startseries, currentseries, endseries, 
  active, org_objid, org_name, fund_objid, fund_title, stubno, owner_objid, owner_name, 
  prefix, suffix, dtfiled, state, unit, batchno, respcenter_objid, respcenter_name, cost, 
  currentindexno, currentdetailid, batchref, lockid, allocid, ukey, salecost
) 
select 
  objid, afid, txnmode, assignee_objid, assignee_name, startseries, currentseries, endseries, 
  active, org_objid, org_name, fund_objid, fund_title, stubno, owner_objid, owner_name, 
  prefix, suffix, dtfiled, state, unit, batchno, respcenter_objid, respcenter_name, cost, 
  currentindexno, currentdetailid, batchref, lockid, allocid, objid as ukey, salecost
from ztmp_afi_header z 
where (select count(*) from af_control where objid = z.objid) = 0
;

insert into af_control_detail ( 
  objid, state, controlid, indexno, refid, refno, reftype, refdate, txndate, txntype, 
  receivedstartseries, receivedendseries, beginstartseries, beginendseries, 
  issuedstartseries, issuedendseries, endingstartseries, endingendseries, 
  qtyreceived, qtybegin, qtyissued, qtyending, qtycancelled, remarks  
) 
select 
  objid, state, controlid, indexno, refid, refno, reftype, refdate, txndate, txntype, 
  receivedstartseries, receivedendseries, beginstartseries, beginendseries, 
  issuedstartseries, issuedendseries, endingstartseries, endingendseries, 
  qtyreceived, qtybegin, qtyissued, qtyending, qtycancelled, remarks 
from ztmp_afi_item z 
where (select count(*) from af_control_detail where objid = z.objid) = 0 
;

drop table if exists ztmp_afi_item; 
drop table if exists ztmp_afi_header;
drop table if exists ztmp_afi;



update 
  af_control aa, 
  ( 
    select d.objid as detailid, d.controlid, d.indexno
    from ( 
      select a.objid, 
        (select objid from af_control_detail where controlid = a.objid order by refdate,txndate limit 1) as detailid 
      from af_control a 
      where currentdetailid is null 
        and state = 'OPEN' 
    )tmp1, af_control_detail d 
    where d.objid = tmp1.detailid 
  )bb 
set 
  aa.currentindexno = bb.indexno, 
  aa.currentdetailid = bb.detailid 
where aa.objid = bb.controlid
;

update 
  af_control aa, 
  ( 
    select d.controlid, d.refno 
    from af_control a, af_control_detail d 
    where a.batchref is null 
      and a.state = 'OPEN' 
      and a.currentdetailid = d.objid 
  )bb 
set aa.batchref = bb.refno 
where aa.objid = bb.controlid
;


drop table if exists ztmp_fix_af_control_detail
; 
create table ztmp_fix_af_control_detail 
select d.*, tmp1.maxindexno  
from ( 
  select d.controlid, d.refid, d.refdate, d.txndate, max(d.indexno) as maxindexno, count(*) as icount 
  from af_control_detail d 
  group by d.controlid, d.refid, d.refdate, d.txndate 
  having count(*) > 1 
)tmp1, af_control_detail d 
where d.controlid = tmp1.controlid 
  and d.refid = tmp1.refid 
  and d.refdate = tmp1.refdate 
  and d.txndate = tmp1.txndate 
;

update 
  af_control_detail aa, 
  ( 
    select z.objid, DATE_ADD(z.txndate,INTERVAL 1 SECOND) as newtxndate 
    from ztmp_fix_af_control_detail z 
    where z.indexno = z.maxindexno 
  )bb 
set aa.txndate = bb.newtxndate 
where aa.objid = bb.objid 
; 
drop table if exists ztmp_fix_af_control_detail
; 

