drop table if exists #kishi2
drop table if exists #kishi
;WITH kishi_CTE(_id,lineage,fullname) AS  
(  
    SELECT a._id,convert(nvarchar(1000),isnull(a.teacher,'IDK')+' > ' +a.lastname + ' ' + a.firstname),convert(nvarchar(500),a.lastname + ' ' + a.firstname) fullname from kishi a where 
	a._id in ( select child._id from kishi child
			left join kishi parent on child.teacher = parent.lastname+' '+parent.firstname
			where child.teacher is null or parent._id is null )
    UNION ALL  
    SELECT e._id,convert(nvarchar(1000),c.lineage + ' > ' +e.lastname + ' ' + e.firstname),convert(nvarchar(500),e.lastname + ' ' + e.firstname)
    from kishi e   
    JOIN kishi_CTE c ON c.fullname= e.teacher
)  
SELECT 
_id, REPLACE(REPLACE(
		REPLACE(REPLACE(
			REPLACE(REPLACE(lineage COLLATE SQL_Latin1_General_CP1_CS_AS,'Oo',N'Ō'),'oo',N'ō')
			,'Ou',N'Ō'),'ou',N'ō')
	,'uu',N'ū'),'Inōe','Inoue')lineage
into #kishi
FROM kishi_CTE order by _id  

select row_number()over(order by lineage)num,converT(nvarchar(1000),'')delim,* into #kishi2 from #kishi order by lineage
select * from #kishi2
declare @i int = 1,@end int=486
declare @parent nvarchar(1000)=''
while(@i<=@end)
begin
	select @parent = lineage from #kishi2 where num=@i
	update #kishi2 set delim=delim+'|',lineage = replace(lineage,@parent,'') where lineage!=@parent and left(lineage,len(@parent))=@parent
	set @i=@i+1
end
select (replace(delim,N'|',N'	') collate SQL_Latin1_General_CP1_CS_AS)+replace(lineage,N' > ',N'	') from #kishi2
--select * into #kishi2 from kishi
--SELECT
--    --hierarchy.ToString() AS Hierarchy, 
--    --hierarchy.GetLevel() AS [Level],
--    --hierarchy.GetAncestor(1).ToString(),
--    kishi._id,
--		REPLACE(REPLACE(
--		REPLACE(REPLACE(
--			REPLACE(REPLACE(
--			STRING_AGG(
--			CASE WHEN lineage.hierarchy.GetAncestor(1).ToString()='/' THEN lineage.teacher+' > ' ELSE '' END +
--			lineage.lastname+' '+lineage.firstname,' > ')
--			COLLATE SQL_Latin1_General_CP1_CS_AS,'Oo',N'Ō'),'oo',N'ō')
--			,'Ou',N'Ō'),'ou',N'ō')
--		,'uu',N'ū'),'Inōe','Inoue')Y,COUNT(*)X
--INTO #KISHI
--FROM kishi kishi
--JOIN #kishi2 hiers on kishi.hierarchy=hiers.hierarchy -- to fool sql into not using index because that messes up the order in string_agg
--JOIN #kishi2 hiers2 on hiers2.hierarchy=hiers.hierarchy -- to fool sql into not using index because that messes up the order in string_agg
--JOIN kishi lineage on hiers.hierarchy.IsDescendantOf(lineage.hierarchy) = 1
--GROUP BY kishi._id
--ORDER BY X DESC
--update kishi set hierarchy=null
--update aa set aa.hierarchy=child.hier
--from kishi aa join
--(select '/'+convert(nvarchar(5),row_number() over(order by child._id))+'/'hier,child.* from kishi child
--left join kishi parent on child.teacher = parent.lastname+' '+parent.firstname
--where child.teacher is null or parent._id is null
--)child on child._id=aa._id
--where aa.hierarchy is null
--select convert(nvarchar(500),child.hierarchy)hierarchy,child.* from kishi child
--left join kishi parent on child.teacher = parent.lastname+' '+parent.firstname
--where (child.teacher is null or parent._id is null)
--order by child._id
----run following till 0 rows updated
--update aa set aa.hierarchy=child.hier
--from kishi aa join
--(
--select parent.teacher grandparent,convert(nvarchar(500),parent.hierarchy)parent_hier,parent.lastname+' '+parent.firstname parent,
--	convert(nvarchar(500),parent.hierarchy)
--	+  convert(nvarchar(5),row_number() over(partition by parent._id order by parent._id,child._id))
--	+  '/' hier,
--child.*
--from kishi parent
--join kishi child on child.teacher = parent.lastname+' '+parent.firstname
--where child.hierarchy is null and parent.hierarchy is not null 
----order by parent.hierarchy,hier
--)child on child._id=aa._id


--SELECT hierarchy.ToString() AS Text_OrgNode,   
--hierarchy.GetLevel() AS EmpLevel, hierarchy.GetDescendant(NULL,NULL).ToString(),
--hierarchy.GetAncestor(1).ToString(),hierarchy.GetAncestor(2).ToString(),hierarchy.GetAncestor(3).ToString(),hierarchy.GetAncestor(4).ToString(),hierarchy.GetAncestor(5).ToString()
--,*  
--FROM kishi where (firstname='karolina'or firstname='souta'or firstname='yoshiharu')
--SELECT * FROM KISHI WHERE _ID<=36
