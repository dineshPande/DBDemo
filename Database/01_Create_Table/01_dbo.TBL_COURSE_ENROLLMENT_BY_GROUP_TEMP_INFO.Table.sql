IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'TBL_COURSE_ENROLLMENT_BY_GROUP_TEMP_INFO')
	DROP TABLE TBL_COURSE_ENROLLMENT_BY_GROUP_TEMP_INFO
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TBL_COURSE_ENROLLMENT_BY_GROUP_TEMP_INFO](
	[strSessionID] [varchar](128) NULL,
	[intRuleGroupID] [int] NULL,
	[strUserDefinedCourseId] [varchar](100) NULL,
	[strCourseEnrollmentType] [varchar](1) NULL,
	[intTimebeforedue] [int] NULL,
	[intTimeZoneId] [int] NULL,
	[dtNewTimeBeforedueSpecific] [datetime] NULL,
	[intCreateOrModifyByID] [int] NULL,
	[strAddRemoveFlag] [varchar](1) NULL,
 CONSTRAINT [UQ_TBL_COURSE_ENROLLMENT_BY_GROUP_TEMP_INFO] UNIQUE NONCLUSTERED 
(
	[strSessionID] ASC,
	[intRuleGroupID] ASC,
	[strUserDefinedCourseId] ASC,
	[intCreateOrModifyByID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO