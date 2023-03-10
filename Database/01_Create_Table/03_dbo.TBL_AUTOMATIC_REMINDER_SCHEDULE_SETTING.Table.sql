/****** Object:  Table [dbo].[TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING]    Script Date: 10-01-2023 11:03:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING](
	[intAutomaticReminderScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[intAutomaticReminderCategoryId] [int] NOT NULL,
	[intCustID] [int] NOT NULL,
	[bitIsEnable] [bit] NOT NULL,
	[bitPastDueMandatory] [bit] NOT NULL,
	[bitPastDueOptional] [bit] NOT NULL,
	[bitIncompleteMandatory] [bit] NOT NULL,
	[bitIncompleteOptional] [bit] NOT NULL,
	[strRecurrenceType] [varchar](5) NOT NULL,
	[intStartTimeHour] [int] NOT NULL,
	[intStartTimeMinute] [int] NOT NULL,
	[strStartTimeAMPM] [varchar](3) NOT NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[intCreatedByUser] [int] NOT NULL,
	[dtCreateDate] [datetime] NOT NULL,
	[intModifiedByUser] [int] NOT NULL,
	[dtModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING] PRIMARY KEY CLUSTERED 
(
	[intAutomaticReminderScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING', N'COLUMN',N'intAutomaticReminderCategoryId'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary key of table TBL_AUTOMATIC_REMINDER_CATEGORY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING', @level2type=N'COLUMN',@level2name=N'intAutomaticReminderCategoryId'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING', N'COLUMN',N'intCreatedByUser'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Record created by user' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING', @level2type=N'COLUMN',@level2name=N'intCreatedByUser'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING', N'COLUMN',N'dtCreateDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'record create date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_AUTOMATIC_REMINDER_SCHEDULE_SETTING', @level2type=N'COLUMN',@level2name=N'dtCreateDate'
GO
