SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 9, 2009 
-- Modified:    Aug 17, 2009
-- Description: Get records from AppCode with option to filter by
--              appCodeUsedWhere
-- =============================================

CREATE procedure [dbo].[spGetCodebyGroup]
@AppCodeGroup varchar(32) = NULL,
@AppCodeUsedWhere varchar(10) = NULL,
@AppCode varchar(2)=NULL

AS

SET NOCOUNT ON;

IF @AppCodeUsedWhere Is Null and @AppCode is null begin
	SELECT AppCode, 
	AppCodeGroup, 
	AppCodeText, 
	AppCodeUsedWhere, 
	codeAppPK
	FROM codeApp
	WHERE AppCodeGroup = @AppCodeGroup
	Order BY AppCode
end

else if @AppCodeUsedWhere is not null and @AppCode is null begin
	SELECT AppCode, 
	AppCodeGroup, 
	AppCodeText, 
	AppCodeUsedWhere, 
	codeAppPK
	FROM codeApp
	WHERE AppCodeGroup = @AppCodeGroup and
	AppCodeUsedWhere like '%'+ @AppCodeUsedWhere+'%'
	Order BY AppCode
end

else if @AppCode IS NOT NULL and @AppCodeUsedWhere IS NULL begin
	SELECT AppCode, 
	AppCodeGroup, 
	AppCodeText, 
	AppCodeUsedWhere, 
	codeAppPK
	FROM codeApp
	WHERE AppCodeGroup = @AppCodeGroup and
	AppCode = @AppCode
	Order BY AppCode
end

ELSE IF @AppCode IS NOT NULL and @AppCodeUsedWhere IS NOT NULL begin
	SELECT AppCode, 
	AppCodeGroup, 
	AppCodeText, 
	AppCodeUsedWhere, 
	codeAppPK
	FROM codeApp
	WHERE AppCodeGroup = @AppCodeGroup and
	AppCodeUsedWhere like '%'+ @AppCodeUsedWhere+'%' and
	AppCode = @AppCode
	Order BY AppCode
END







GO
