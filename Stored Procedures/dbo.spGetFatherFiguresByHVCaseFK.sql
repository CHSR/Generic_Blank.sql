SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetFatherFiguresByHVCaseFK]

(
    @HVCaseFK int
    , @ProgramFK int
)
as
	set nocount on;

	--spGetFatherFiguresByHVCaseFK 5938,1
	--declare @IsApproved bit
	--exec spGetApprovalStatus @FormType = 'FF' --varchar(2)
	--							,@FormFK = 0 --int
	--							,@HVCaseFK = 0 --int
	--							,@ProgramFK = 0 --int
	--							,@isApproved = 0 --bit

	select isnull(IsApproved,0) as IsApproved
		  ,0 as IsReviewRequired
		  ,FatherFigurePK
		  ,DateAcceptService
		  ,DateInactive
		  ,FatherAdvocateFK
		  ,FatherFigureCreateDate
		  ,FatherFigureCreator
		  ,FatherFigureEditDate
		  ,FatherFigureEditor
		  ,HVCaseFK
		  ,IsOBP
		  ,IsPC2
		  ,LiveInPC1Home
		  ,MarriedToPC1
		  ,PC2InPC1Home
		  ,PCFK
		  ,ProgramFK
		  ,RelationToTargetChild
		  ,RelationToTargetChildOther
		  ,PCFirstName as FirstName
		  ,PCMiddleInitial as MiddleInitial
		  ,PCLastName as LastName
		  ,isnull(PCFirstName,'') + ' ' + isnull(PCMiddleInitial,'') + ' ' + isnull(PCLastName,'') AS FFigureName
		  ,case when FF.IsOBP=1 then 'Yes' else 'No' end as OBPOfCase
		  ,case when FF.IsPC2=1 then 'Yes' else 'No' end as PC2OfCase
		  ,case when FF.LiveInPC1Home=1 then 'Yes' else 'No' end as InPC1Home
		  , h.OBPFK
		  , h.PC2FK
		from FatherFigure FF
		inner join PC P on P.PCPK = FF.PCFK
		INNER JOIN HVCase h ON h.HVCasePK = FF.HVCaseFK
		left outer join dbo.FormReviewedTableList('FF',@ProgramFK) frtl on FormFK = FatherFigurePK
		where HVCaseFK = @HVCaseFK
				and ProgramFK = @ProgramFK
GO
