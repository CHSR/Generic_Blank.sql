SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetAllcodeLevels]
as
select *
from dbo.codeLevel
order by levelname



GO
