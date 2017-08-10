SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vPHQ9]
AS
SELECT        p.PHQ9PK, p.FormFK, p.FormType, p.HVCaseFK, p.ProgramFK, p.DateAdministered, 
                         CASE WHEN p.FormType = 'TC' THEN t .FSWFK WHEN p.FormType = 'FU' THEN fu.FSWFK WHEN p.FormType = 'KE' THEN k.FAWFK WHEN p.FormType = 'IN' THEN i.FSWFK END AS workerfk
FROM            dbo.PHQ9 AS p LEFT OUTER JOIN
                         dbo.TCID AS t ON t.HVCaseFK = p.HVCaseFK AND t.TCIDPK = p.FormFK AND p.FormType = 'TC' LEFT OUTER JOIN
                         dbo.FollowUp AS fu ON fu.HVCaseFK = p.HVCaseFK AND fu.FollowUpPK = p.FormFK AND p.FormType = 'FU' LEFT OUTER JOIN
                         dbo.Kempe AS k ON k.HVCaseFK = p.HVCaseFK AND k.KempePK = p.FormFK AND p.FormType = 'KE' LEFT OUTER JOIN
                         dbo.Intake AS i ON i.HVCaseFK = p.HVCaseFK AND i.IntakePK = p.FormFK AND p.FormType = 'IN'
WHERE        (p.DateAdministered IS NOT NULL) AND (p.FormFK IS NOT NULL) AND (p.FormFK > 0) AND (p.Invalid = 0)

GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[17] 4[21] 2[43] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t"
            Begin Extent = 
               Top = 6
               Left = 283
               Bottom = 125
               Right = 520
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fu"
            Begin Extent = 
               Top = 6
               Left = 558
               Bottom = 125
               Right = 781
            End
            DisplayFlags = 280
            TopColumn = 52
         End
         Begin Table = "k"
            Begin Extent = 
               Top = 6
               Left = 819
               Bottom = 125
               Right = 1024
            End
            DisplayFlags = 280
            TopColumn = 68
         End
         Begin Table = "i"
            Begin Extent = 
               Top = 6
               Left = 1062
               Bottom = 125
               Right = 1299
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Outpu', 'SCHEMA', N'dbo', 'VIEW', N'vPHQ9', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N't = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vPHQ9', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vPHQ9', NULL, NULL
GO
