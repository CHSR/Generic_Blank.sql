SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- exec spSearchPC	'jennifer', 'mott', '19760716', null, null, null, null, 11

CREATE procedure [dbo].[spSearchPC]
(
    @PCFirstName      varchar(20)    = null,
    @PCLastName       varchar(30)    = null,
    @PCDOB            datetime       = null,
    @PCPhone          varchar(12)    = null,
    @PCEmergencyPhone varchar(12)    = null,
    @Ethnicity        varchar(30)    = null,
    @Race             varchar(2)     = null,
    @ProgramFK        int            = null
)

as

	set nocount on
	/*
		SELECT pc.pcpk, pc.pcfirstname,pc.pclastname,pc.pcdob,
			pc.pcphone,pc.PCEmergencyPhone,
			CASE WHEN AppCodeText = 'Other' THEN racespecify ELSE AppCodeText END AS race,racespecify--,
			--caseprogram.dischargedate
		FROM pc
		LEFT JOIN codeApp
		ON appcode = pc.race
		AND appcodegroup = 'Race'
		--INNER JOIN hvcase
		--ON pcpk IN(cpfk, pc1fk, pc2fk, obpfk)
		--INNER JOIN caseprogram
		--ON hvcasefk = hvcasepk
		WHERE (pc.pcfirstname LIKE @PCFirstName + '%'
		OR pc.pclastname LIKE @PCLastName + '%'
		OR pc.pcdob = @PCDOB
		OR pc.pcphone = @PCPhone
		OR pc.pcemergencyphone = @PCEmergencyPhone
		OR pc.ethnicity = @Ethnicity
		OR pc.race = @Race)
		--AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
		AND pcpk IN (SELECT pcfk FROM pcprogram WHERE ProgramFK = ISNULL(@ProgramFK, ProgramFK))
		ORDER BY
		CASE WHEN pc.pcfirstname LIKE @PCFirstName + '%' THEN 1 ELSE 0 END +
		CASE WHEN pc.pclastname LIKE @PCLastName + '%' THEN 1 ELSE 0 END +
		CASE WHEN pc.pcdob = @PCDOB THEN 1 ELSE 0 END +
		CASE WHEN pc.pcphone = @PCPhone THEN 1 ELSE 0 END +
		CASE WHEN pc.pcemergencyphone = @PCEmergencyPhone THEN 1 ELSE 0 END +
		CASE WHEN pc.ethnicity = @Ethnicity THEN 1 ELSE 0 END +
		CASE WHEN pc.race = @Race THEN 1 ELSE 0 END DESC
	*/


	--DECLARE @PCFirstName VARCHAR(20) = NULL
	--DECLARE @PCLastName VARCHAR(30) = 'green'
	--DECLARE @PCDOB DATETIME = NULL
	--DECLARE @PCPhone VARCHAR(12) = NULL
	--DECLARE @PCEmergencyPhone VARCHAR(12) = NULL
	--DECLARE @ProgramFK INT = NULL

	;
	with xxx
	as (
	select distinct pc.pcpk
				   ,pc.pcfirstname
				   ,pc.pclastname
				   ,pc.PCOldName
				   ,pc.PCOldName2
				   ,pc.pcdob
				   ,pc.pcphone
				   ,pc.PCEmergencyPhone
				   ,pc.race
				   ,pc.racespecify
				   ,pc.Gender
		from PC as pc
		where
			 (pc.pcfirstname like @PCFirstName+'%'
			 or pc.pcOldName LIKE @PCFirstName+'%'
			 or pc.pcOldName2 LIKE @PCFirstName+'%'

			 or pc.pclastname like @PCLastName+'%'
			 or pc.pcOldName LIKE  '%'+@PCLastName + '%'
			 or pc.pcOldName2 LIKE '%'+@PCLastName

			 or pc.pcdob = @PCDOB
			 or pc.pcphone = @PCPhone
			 or pc.pcemergencyphone = @PCEmergencyPhone)
			 and pc.pcpk in (select pcfk
								 from pcprogram
								 where ProgramFK = isnull(@ProgramFK,ProgramFK))
	)

	,
	yyyNew
	as (
	select b.PCPK
		  ,max(convert(varchar(8),isnull(c.DischargeDate,getdate()),112)+cast(c.CaseProgramPK as varchar(10))) max1
		from HVCase as a
			join xxx as b on b.PCPK = a.PC1FK
			join CaseProgram as c on a.HVCasePK = c.HVCaseFK
		group by b.PCPK
	)

	,
	yyy
	as (
	select a.PCPK
		  ,c.LevelName
		from yyyNew as a
			join CaseProgram b on b.CaseProgramPK = cast(substring(a.max1,9,10) as int)
			join codeLevel as c on c.codeLevelPK = b.CurrentLevelFK
	)

	,
	zzzPC1
	as (
	select b.PCPK
		  ,count(*) [pc1]
		from HVCase as a
			join xxx as b on b.PCPK = a.pc1fk
		group by b.PCPK
	)

	,
	zzzPC2
	as (
	select b.PCPK
		  ,count(*) [pc2]
		from HVCase as a
			join xxx as b on b.PCPK = a.pc2fk
		group by b.PCPK
	)

	,
	zzzOBP
	as (
	select b.PCPK
		  ,count(*) [obp]
		from HVCase as a
			join xxx as b on b.PCPK = a.obpfk
		group by b.PCPK
	)

	,
	qqq
	as (
	select
		  a.pcpk
		 ,a.pcfirstname
		 ,a.pclastname
		 ,a.PCOldName
		 ,a.PCOldName2
		 ,a.pcdob
		 ,a.pcphone
		 ,a.PCEmergencyPhone
		 ,case when AppCodeText = 'Other' then racespecify else AppCodeText end as race
		 ,a.racespecify
		 ,a.Gender
		 ,status =
		  case when b.PCPK is not null then b.LevelName else '' end
		 ,roles =
		  case when e.PCPK is not null then 'PC1 ' else '' end+
		  case when c.PCPK is not null then 'PC2 ' else '' end+
		  case when d.PCPK is not null then 'OBP ' else '' end
		from xxx as a
			left outer join yyy as b on b.pcpk = a.pcpk
			left outer join zzzPC1 as e on e.pcpk = a.pcpk
			left outer join zzzPC2 as c on c.pcpk = a.pcpk
			left outer join zzzOBP as d on d.pcpk = a.pcpk
			left join codeApp on appcode = a.race and appcodegroup = 'Race'
	)

	select top 100 pcpk	
					, pcfirstname
					, pclastname
					, pcOldName
					, pcOldName2 
					, pcdob
					, pcphone
					, PCEmergencyPhone
					, race
					, racespecify
					, gender
					, status
					, roles
					, orderColumn = CASE WHEN pcOldName LIKE  @PCFirstName+'%' then 1 else 0 end+
					                CASE WHEN pcOldName LIKE  '%'+@PCLastName then 1 else 0 end+
									CASE WHEN pcOldName2 LIKE  @PCFirstName+'%' then 1 else 0 end+
					                CASE WHEN pcOldName2 LIKE  '%'+@PCLastName then 1 else 0 end+
					                CASE when pcfirstname like @PCFirstName+'%' then 1 else 0 end+
									case when pclastname like @PCLastName+'%' then 1 else 0 end+
									case when pcdob = @PCDOB then 1 else 0 end+
									case when pcphone = @PCPhone then 1 else 0 end+
									case when pcemergencyphone = @PCEmergencyPhone then 1 else 0 end
		from qqq
		order BY  orderColumn desc
				, pclastname
				, pcfirstname
				--case when ethnicity = @Ethnicity then 1 else 0 end+
				--case when race = @Race then 1 else 0 end desc
--order by pclastname
--		,pcfirstname
GO
