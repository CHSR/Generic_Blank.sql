SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		jrobohn
-- Create date: Jul 29, 2012
-- Description: Get rows from codeAuditC table 
-- =============================================

CREATE procedure [dbo].[spGetCodeAuditCbyGroup]
(
    @AuditCCodeGroup varchar(20)    = null
)
as

	set nocount on;

	select codeAuditCPK
		  ,codeScore
		  ,codeText
		  ,codeValue
		from codeAuditC ac
		where codeGroup = @AuditCCodeGroup
		order by codeValue
GO
