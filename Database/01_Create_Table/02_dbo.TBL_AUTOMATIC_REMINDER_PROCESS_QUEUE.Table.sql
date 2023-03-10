/****** Object:  Table [dbo].[TBL_AUTOMATIC_REMINDER_PROCESS_QUEUE]    Script Date: 10-01-2023 11:03:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TBL_AUTOMATIC_REMINDER_PROCESS_QUEUE]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TBL_AUTOMATIC_REMINDER_PROCESS_QUEUE](
	[intAutomaticReminderQueueID] [int] IDENTITY(1,1) NOT NULL,
	[intCustID] [int] NOT NULL,
	[intAutomaticReminderCategoryId] [int] NOT NULL,
	[dtmRequestTime] [datetime] NOT NULL,
	[charProcessType] [char](1) NOT NULL,
	[charProcessStage] [char](1) NOT NULL,
	[intCreatedByUser] [int] NOT NULL,
	[dtCreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TBL_AUTOMATIC_REMINDER_PROCESS_QUEUE] PRIMARY KEY CLUSTERED 
(
	[intAutomaticReminderQueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TBL_AUTOMATIC_REMINDER_PROCESS_QUEUE', N'COLUMN',N'intAutomaticReminderCategoryId'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary key of table TBL_AUTOMATIC_REMINDER_CATEGORY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_AUTOMATIC_REMINDER_PROCESS_QUEUE', @level2type=N'COLUMN',@level2name=N'intAutomaticReminderCategoryId'
GO
