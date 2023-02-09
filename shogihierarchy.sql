SELECT
    --hierarchy.ToString() AS Hierarchy, 
    --hierarchy.GetLevel() AS [Level],
    --hierarchy.GetAncestor(1).ToString(),
    kishi._id,
		REPLACE(REPLACE(
		REPLACE(REPLACE(
			REPLACE(REPLACE(
			STRING_AGG(
			CASE WHEN lineage.hierarchy.GetAncestor(1).ToString()='/' THEN lineage.teacher+' > ' ELSE '' END +
			lineage.lastname+' '+lineage.firstname,' > ')
			COLLATE SQL_Latin1_General_CP1_CS_AS,'Oo',N'Ō'),'oo',N'ō')
			,'Ou',N'Ō'),'ou',N'ō')
		,'uu',N'ū'),'Inōe','Inoue')Y,COUNT(*)X
INTO #KISHI
FROM kishi kishi
JOIN kishi hiers on kishi.hierarchy=hiers.hierarchy -- to fool sql into not using index because that messes up the order in string_agg
JOIN kishi lineage on hiers.hierarchy.IsDescendantOf(lineage.hierarchy) = 1
GROUP BY kishi._id
ORDER BY X DESC

----update aa set aa.hierarchy=child.hier
----from kishi aa join
----(select '/'+convert(nvarchar(5),row_number() over(order by child._id))+'/'hier,child.* from kishi child
----left join kishi parent on child.teacher = parent.lastname+' '+parent.firstname
----where child.teacher is null or parent._id is null
----)child on child._id=aa._id
--select convert(nvarchar(500),child.hierarchy)hierarchy,child.* from kishi child
--left join kishi parent on child.teacher = parent.lastname+' '+parent.firstname
--where child.teacher is null or parent._id is null 
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


