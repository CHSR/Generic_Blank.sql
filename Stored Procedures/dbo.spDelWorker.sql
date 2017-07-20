SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelWorker](@WorkerPK int)

AS


DELETE 
FROM Worker
WHERE WorkerPK = @WorkerPK
GO
