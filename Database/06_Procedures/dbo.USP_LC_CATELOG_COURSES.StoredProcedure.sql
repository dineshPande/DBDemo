IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[USP_LC_CATELOG_COURSES]')
                    AND type IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[USP_LC_CATELOG_COURSES]
GO


CREATE  PROCEDURE [dbo].[USP_LC_CATELOG_COURSES]  
    @intCategoryId INT ='',  
    @intCustId INT ,  
    @intUserId INT ,  
 @strSearch nVARCHAR(500)='',  
 @intstartIndex INT = -1 ,  
 @intrecordCount INT = 10 , 
 @strSortColumn VARCHAR(200)='strCourseName',    
@strSortOrder VARCHAR(10)='ASC',
 @intTotalRecords INT = 0 OUTPUT,  
 @ErrorCode VARCHAR(200) OUTPUT   
   
   
AS   
                  
   /*EXEC  [USP_LC_CATELOG_COURSES]
    @intCategoryId  =822,
    @intCustId=824 ,@intstartIndex=1,
    @intUserId=822234 ,@errorCode='' 
	*/
   SET NOCOUNT ON ;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  BEGIN TRY  
    
   DECLARE @intLanguageId INT  
   DECLARE @CourseImageType VARCHAR(10)='WI'  
   DECLARE @start INT  
   DECLARE @end INT  
   
  create TABLE #CatelogTree   
            (  
     ID INT Identity(1,1),  
               
              strCategoryName NVARCHAR(200) ,  
              strUserDefinedCourseId VARCHAR(100) ,  
              CourseType CHAR(2) ,  
              charAllowEnrollCourse Varchar(4) ,  
              fldCourseId INT ,  
              fldStatus VARCHAR(2) ,  
              intUnEnroll INT ,  
              fldAssignCourseId INT ,  
              LicenseExpired BIT ,  
              CertificationExpired CHAR(1) ,  
              CourseName NVARCHAR(500),  
     strCourseType varchar(100),  
      DeliveryMethod VARCHAR(100) ,strOwnerEmailID VARCHAR(300) 
            )  
  DECLARE @UserCourse TABLE  
            (  
              fldCourseId INT ,  
              fldUserIdAssignedTo INT ,  
              fldAssignCourseId INT ,  
              fldStatus CHAR(1) ,  
              dtmFinalLicenseExpirationDate DATETIME ,  
              struserdefinedcourseid VARCHAR(150) ,  
              CertificationExpired CHAR(1),  intILTSessionID INT  
            )  
     
   CREATE TABLE #CatelogCourses   
            (  
              id int identity(1,1),
              strUserDefinedCourseId VARCHAR(100) ,  
              CourseType CHAR(2) ,  
              CertificationExpired CHAR(1) ,  
              IsScormEngineCourse INT ,  
              charAllowEnrollCourse Varchar(4) ,  
              fldcourseid INT ,  
              CourseName NVARCHAR(500),  
     flddeliveryMethod varchar(10),  
     strCourseType varchar(100),  
     bitIsEnableLicensePeriod BIT,  
     DeliveryMethod VARCHAR(100)  ,strOwnerEmailID VARCHAR(300)
            ) 
			
	CREATE TABLE #CatalogCourseTree (ID int identity(1,1),strUserDefinedCourseId VARCHAR(200),strAllowEnrollCourse varchar(10),fldCourseId INT,fldStatus varchar(10),intUnEnroll INT,
										fldAssignCourseId INT,bitLicenseExpired BIT,charCertificationExpired char(1),bitIsCertificationEnabled BIT,strCourseName nvarchar(500),
										strCourseType varchar(100),strDeliveryMethod varchar(100),strImageFileName varchar(500),bitIsSystemImage BIT,strOwnerEmailID VARCHAR(300))
  
   DECLARE @strSQL NVARCHAR(Max)                      
   DECLARE @Parameter_Definition NVARCHAR(1000)   
     
  
   CREATE TABLE #Category (intCategoryId int,intCustId int, intParentCategoryId int, strCategoryName nVarchar(500), LevelRow int)  
  
   SET @Parameter_Definition = N'                    
                          
       @strSearch NVARCHAR(500),  
       @intCategoryId INT,  
       @intCustId INT,  
       @intLanguageId INT'  
  
  
     SELECT @ErrorCode=dbo.UDF_LC_URL_VALIDATION (@intCustID ,@intUserID ,'')
	  IF @ErrorCode<>''
	  BEGIN
				return 0
	  END
	  IF (ISNULL(@strSearch,'')=''  AND  @intCategoryId<>-1)
	  BEGIN
	  If NOT EXISTS(Select 1 from TBL_CATALOG_CATEGORY_MASTER where intCustId=@intCustId and intCategoryId=@intCategoryId)
	  BEGIN
			SET @ErrorCode='ERRLCDB404'
			return

	  END
	  END
     
     
   
   
 SET @intLanguageID=dbo.UDF_GET_USER_Language(@intUserId,@intCustID)   
  
  
   
  
 SET @strSQL='INSERT  INTO #CatelogCourses  (strUserDefinedCourseId ,  CourseType ,  CertificationExpired ,  IsScormEngineCourse  ,  
              charAllowEnrollCourse ,  
              fldcourseid ,  
              CourseName,  
			 flddeliveryMethod,  
			strCourseType ,  
			 bitIsEnableLicensePeriod,  
			DeliveryMethod ,strOwnerEmailID) 
                        SELECT      
                           
                                  
                                B.fldUserDefinedCourseId AS strUserDefinedCourseId ,  
                                ( CASE WHEN B.strCourseCurriculumCategory = ''stdcurr''  
                                       THEN ''CR''  
                                       ELSE B.fldDeliveryMethod  
                                  END ) AS CourseType ,  
                                '''' ,  
                                B.IsScormEngineCourse ,  
                                LTRIM(RTRIM(B.charAllowEnrollCourse)) ,  
                                fldcourseid ,  
                                
        CASE WHEN ISNULL(@intCategoryId,0) =0 THEN TLC.fldCourseName ELSE (CASE WHEN B.strCourseCurriculumCategory = ''stdcurr''  
                                       THEN TLC.fldCourseName  
                                            + '' (Curriculum)'' -- @intCategoryId is not passed from API so this variable has been used to skip (Curriculum) word with courseName  
                                       ELSE TLC.fldCourseName  
                                  END ) END AS  CourseName,flddeliveryMethod,  
            Case WHEN C.fldCourseLibraryId IS NULL  
                            AND C.fldIsScorm = 0  
                            AND B.intGroupid=0 and B.fldDeliveryMethod = ''wb'' AND EmbedCount IS NULL THEN ''IC''  
      ELSE  
          CASE WHEN  C.fldIsScorm =1  
                                  AND (B.EmbedCount IS NULL) and Isnull(B.charCourseImportType,'''')<>''X''  
      THEN ''SCO''  
      ELSE  
      CASE WHEN   B.EmbedCount >= 0 THEN ''SCOEMB''  
      ELSE  
      CASE WHEN   B.fldDeliveryMethod = ''il''  
                                                              AND C.fldIsScorm = 0  
                                                              AND EmbedCount IS NULL  
       THEN ''IL''  
      ELSE  
      CASE WHEN   
       B.fldDeliveryMethod = ''et''  
                                                              AND C.fldIsScorm = 0  
                                                              AND EmbedCount IS NULL  
      THEN ''ET''  
      ELSE  
      CASE WHEN B.intGroupID>0 THEN ''CUR''   
      ELSE  
      CASE WHEN  isnull(B.charCourseImportType,'''')=''X''  
                                                              AND EmbedCount IS NULL  
      THEN ''CMI''  
      ELSE ''''  
      END END END END END END END,bitIsEnableLicensePeriod,CASE WHEN fldDeliveryMethod =''il''  
      THEN ''Instructor-led'' ELSE  CASE WHEN flddeliveryMethod=''et'' THEN ''Event'' ELSE ''Web'' END END as DeliveryMethod ,U.fldemail 
                        FROM    TBL_COURSE_CUSTOMER_CATALOG_SETTINGS AS A   
                        INNER JOIN TBL_Course_Name AS B  
                                ON A.strUserDefindedCourseId = B.fldUserDefinedCourseId  
                        INNER JOIN dbo.TBL_LANGUAGE_COURSENAME AS TLC  
                                ON B.fldUserDefinedCourseId = TLC.fldUserDefinedCourseId  
                                   AND TLC.fldLanguageId = @intLanguageId  
                        INNER JOIN tbl_course_master C  
                                ON C.flduserdefinedcourseid = b.flduserdefinedcourseid  
                                   AND fldcourseversion > 0  
                                   AND fldcourseversion = ( SELECT  
                                                              MAX(fldcourseversion)  
                                                            FROM  
                                                              tbl_course_master  
                                                            WHERE  
                                                              flduserdefinedcourseid = c.flduserdefinedcourseid  
                                                          )  
      Inner join TBL_CATALOG_CATEGORY_LANGUAGE_MASTER D ON D.intCategoryID=intCourseCategoryId  
      LEFT OUTER JOIN TBL_Organization_CourseImages TOC ON TOC.strUserDefinedCourseID=B.flduserdefinedcourseID  
      and strCourseImageType=''WI''  
	  Left outer join tbl_User_Master U on U.fldUserID=C.fldCreatedBy
                        WHERE   A.charDispCourseInCatalog = ''Y''  
                                AND b.charCourseStatus = ''A'' AND D.intLanguageID=@intLanguageId  
                                AND EmbedCount IS NULL '  
    IF ISNULL(@strSearch,'')<>''  
      
    BEGIN  
     SET @strSearch = dbo.UDF_GET_SEARCH_CRITERIA(@strSearch)  
	 
                 SET @strSQL = @strSQL  
                    + ' AND  (TLC.fldCourseName LIKE @strSearch        
                                        OR TLC.strSearchKeywords LIKE @strSearch  
                                        OR TLC.strCourseOutline LIKE @strSearch       
                                        OR TLC.fldCourseDescription LIKE @strSearch   
          OR B.fldDisplayCourseid LIKE @strSearch        
                                      ) '   
    END  
	ELSE
	BEGIN
			SET @strSQL = @strSQL  
                    + ' AND intCourseCategoryId = @intCategoryId  '
	END
  
     
                                 
                 SET @strSQL = @strSQL + ' AND A.intcustId = @intCustId   ' 
  -- select @strSQL
    EXECUTE sp_executesql @strSQL, @Parameter_Definition,  
      @strSearch=@strSearch,  
      @intCategoryId=@intCategoryId,  
      @intCustId=@intCustId,  
      @intLanguageId=@intLanguageId     
   
  

   DELETE #CatelogCourses  
   where strCourseType IN ('IL','ET','SCOEMB' )   
   
   
  
 INSERT  INTO @userCourse  
                        SELECT  fldCourseId ,  
                                fldUserIdAssignedTo ,  
                              fldAssignCourseId ,  
                                CASE WHEN intILTSessionID > 0 THEN NULL ELSE  
            CASE WHEN a.fldStatus='A' THEN 'A' ELSE   
            CASE WHEN a.fldstatus='I' THEN 'I' ELSE  
            CASE WHEN a.fldstatus='C' AND a.fldPassFailStatus='P' THEN 'P'  
            ELSE CASE WHEN a.fldstatus='C' AND a.fldPassFailStatus='F'  
            THEN 'F' ELSE   
            CASE WHEN a.fldstatus='W' THEN 'W' ELSE '' END END END END END END AS fldstatus ,  
                                
                                dtmFinalLicenseExpirationDate ,  
                                a.struserdefinedcourseid ,  
                               case when Isnull(bitEnableCertification,0) =0 Then null else  b.charCurrentCertificationStatus end ,  intILTSessionID  
                        FROM    dbo.TBL_ASSIGN_COURSE_STUDENT a  
                        INNER JOIN tbl_assign_course_student_master b  
                                ON a.struserdefinedcourseid = b.struserdefinedcourseid  
                                   AND a.flduseridassignedto = b.intuserid  
					    Inner join TBL_CUSTOMER_COURSE C on C.strUserDefinedCourseId=b.strUserDefinedCourseId and C.intCustId=@intCustId
                        WHERE   fldUserIdAssignedTo = @intUserId   
  
   INSERT  INTO #CatelogTree(  
              
              strUserDefinedCourseId ,  
              CourseType,  
              charAllowEnrollCourse ,  
              fldCourseId ,  
              
              fldStatus ,  
              intUnEnroll ,  
              fldAssignCourseId,  
              LicenseExpired ,  
              CertificationExpired ,  
             CourseName,strCourseType,DeliveryMethod,strOwnerEmailID )  
                        SELECT  DISTINCT  
                                  
                                 
                                 
                                GROUPTBL.strUserDefinedCourseId ,  
                                 GROUPTBL.CourseType ,  
                                 GROUPTBL.charAllowEnrollCourse ,  
                                CASE WHEN TACS.fldCourseID IS NULL  
                                     THEN GROUPTBL.fldCourseId  
                                     ELSE TACS.fldCourseID  
                                END ,  
                                 
                                TACS.fldStatus ,  
                                dbo.UDF_ISDISPLAY_UNENROLL(TACS.intILTSessionID,  
                                                           @intUserId,  
                                                           GROUPTBL.fldCourseId) AS intUnEnroll ,  
                                ISNULL(TACS.fldAssignCourseId, 0) AS fldAssignCourseId ,  
                                 CASE WHEN DATEDIFF(dd,  
                                                              GETUTCDATE(),  
                                                              dtmFinalLicenseExpirationDate) < 0 AND bitIsEnableLicensePeriod=1  
                                                   THEN 1  
                                                   ELSE 0  
                                              END AS LicenseExpired ,  
                                TACS.CertificationExpired ,  
                              CourseName,strCourseType,DeliveryMethod  ,strOwnerEmailID
                        FROM    #CatelogCourses GROUPTBL  
                        LEFT JOIN ( SELECT  fldCourseId ,  
                                            fldUserIdAssignedTo ,  
                                            fldAssignCourseId ,  
                                            fldStatus ,  
                                             intILTSessionID ,  
                                            dtmFinalLicenseExpirationDate ,  
                                            struserdefinedcourseid ,  
                                            CertificationExpired   
                                    FROM    @userCourse a  
                                    WHERE   fldAssignCourseId = ( SELECT  
                                                              MAX(fldAssignCourseId)  
                                                              FROM  
       @userCourse  
                                                              WHERE  
                                                              fldCourseId = a.fldCourseId  
                                                              AND flduseridassignedto = a.flduseridassignedto  
                                                              )  
                                  ) TACS  
                                ON GROUPTBL.strUserDefinedCourseId = TACS.strUserDefinedCourseId  
                        ORDER BY GROUPTBL.CourseName   
  SET @inttotalRecords=@@ROWCOUNT  


   SET @strSQL = ' Insert into #CatalogCourseTree( strUserDefinedCourseId ,strAllowEnrollCourse ,fldCourseId ,fldStatus ,intUnEnroll ,
										fldAssignCourseId ,bitLicenseExpired ,charCertificationExpired ,bitIsCertificationEnabled ,strCourseName ,
										strCourseType,strDeliveryMethod ,strImageFileName,bitIsSystemImage,strOwnerEmailID )
		  SELECT  
			   a1.strUserDefinedCourseId AS strUserDefinedCourseId ,  
               a1.charAllowEnrollCourse as strAllowEnrollCourse ,  
                fldCourseId ,  
                fldStatus ,  
                intUnEnroll ,  
                fldAssignCourseId ,  
                 
                LicenseExpired as bitLicenseExpired,    
                ISNULL(CertificationExpired, '''') AS charCertificationExpired ,  
                
                 
                ISNULL(b1.bitEnableCertification,0) AS bitIsCertificationEnabled,CourseName as strCourseName ,strCourseType, DeliveryMethod  as strDeliveryMethod ,strImageFileName,
				case when TOC.bitIsSystem is null then 1 else TOC.bitIsSystem END as bitIsSystemImage,strOwnerEmailID 
		
        FROM    #CatelogTree a1 LEFT OUTER JOIN  dbo.TBL_CUSTOMER_COURSE b1 ON a1.strUserDefinedCourseId=b1.strUserDefinedCourseId AND b1.intCustID=' +Cast(@intCustId  as varchar(200)) +' 
				LEFT OUTER JOIN TBL_Organization_CourseImages TOC ON TOC.strUserDefinedCourseID=a1.strUserDefinedCourseId  
          AND strCourseImageType=''' +@CourseImageType  + ''' order by ' +@strSortColumn + '   ' +@strSortOrder
  
  EXECUTE sp_executesql @strSQL
  IF @intstartIndex=-1  
  BEGIN  
   
       Select strUserDefinedCourseId ,strAllowEnrollCourse ,fldCourseId ,fldStatus ,intUnEnroll ,
										fldAssignCourseId ,bitLicenseExpired ,charCertificationExpired ,bitIsCertificationEnabled ,strCourseName ,
										strCourseType,strDeliveryMethod ,strImageFileName,bitIsSystemImage ,strOwnerEmailID 
		from   #CatalogCourseTree
		order by ID
  END  
  ELSE  
  BEGIN  
 --  if @intstartIndex>1
	--SET @intstartIndex=@intstartIndex+1
       SELECT     
   @start = CASE WHEN @intstartIndex > 1     
          THEN     
      ((@intstartIndex-1)*@intrecordCount)+1      
       ELSE     
      @intstartIndex     
     END     
  
 SET @end = @intstartIndex*@intrecordCount    
 
				Select strUserDefinedCourseId ,strAllowEnrollCourse ,fldCourseId ,fldStatus ,intUnEnroll ,
										fldAssignCourseId ,bitLicenseExpired ,charCertificationExpired ,bitIsCertificationEnabled ,strCourseName ,
										strCourseType,strDeliveryMethod ,strImageFileName,bitIsSystemImage ,strOwnerEmailID 
		from   #CatalogCourseTree
   --where ID >= @intstartIndex  AND ID < ( @intstartIndex + ( @intrecordCount) )      
        WHERE      
 ID between @start AND @end   
      
  END  
  
  SET @errorCode='0'  
  DROP TABLE #Category  
  DROP TABLE #CatelogCourses  
    
  END TRY  
  BEGIN CATCH  
    
        DECLARE @ErrMsg NVARCHAR(4000) ,  
            @ErrSeverity INT  
        SELECT  @ErrMsg = ERROR_MESSAGE() ,  
                @ErrSeverity = ERROR_SEVERITY()  
        SET @errorCode ='1'  
        RAISERROR(@ErrMsg, @ErrSeverity, 1)  
          
  END CATCH