SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spGetAllMedicalProviders]
as
select *
from dbo.listMedicalProvider
order by mplastname
GO
