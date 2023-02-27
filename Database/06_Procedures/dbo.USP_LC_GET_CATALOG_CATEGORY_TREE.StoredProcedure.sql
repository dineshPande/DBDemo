IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[USP_LC_GET_CATALOG_CATEGORY_TREE]')
                    AND type IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[USP_LC_GET_CATALOG_CATEGORY_TREE]
GO


CREATE PROCEDURE [dbo].[USP_LC_GET_CATALOG_CATEGORY_TREE]                  
  
@intCustID INT,  
@intUserID INT,  
@errorCode VARCHAR(200)   OUTPUT                
AS  
--EXEC USP_LC_GET_CATALOG_CATEGORY_TREE 824,548141,''  
--Select * from tbl_user_master where intCustomerID=824  
  
SET NOCOUNT ON ;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  BEGIN TRY  
  DECLARE @intLanguageID INT  
  
  SELECT @ErrorCode=dbo.UDF_LC_URL_VALIDATION (@intCustID ,@intUserID ,'')    
    IF @ErrorCode<>''    
    BEGIN    
     return 0    
    END   
   
       
 DECLARE @Catelog_Tree Table (intCategoryId int,intCustId int, intParentCategoryId int, strCategoryName nvarchar(500), LevelRow int)  
      
 SET @intLanguageID=dbo.UDF_GET_USER_Language(@intUserID,@intCustID)    
 ;WITH    Category_CTE ( intCategoryId,intCustId, intParentCategoryId, strCategoryName, LevelRow)  
                                  AS ( SELECT   A.intCategoryId,intCustId, intParentCategoryId, strCategoryName, 0 as LevelRow  
                                       FROM     TBL_CATALOG_CATEGORY_MASTER A Inner JOIN TBL_CATALOG_CATEGORY_LANGUAGE_MASTER B ON A.intCateGoryID=B.intCategoryID  
             and B.intLanguageID=@intLanguageID  
                                       WHERE    intParentCategoryID=-1 and intCustID=@intCustID  
                                       UNION ALL  
                                       SELECT   A.intCategoryId ,  
            A.intCustId,  
                                                A.intParentCategoryId ,  
                                                B.strCategoryName ,  
                                                C.LevelRow + 1  
                                                 
                                       FROM    TBL_CATALOG_CATEGORY_MASTER A Inner JOIN TBL_CATALOG_CATEGORY_LANGUAGE_MASTER B ON A.intCateGoryID=B.intCategoryID  
                                                INNER JOIN Category_CTE C ON C.intCateGoryID = A.intParentCategoryId  
                                                            and B.intLanguageID=@intLanguageID AND A.intCustID=@intCustID  
                                     )  
  
 insert into @Catelog_Tree  
 Select * from Category_CTE order by strCategoryName  
  
 --select * from @Catelog_Tree  
 Select intCategoryId , intParentCategoryId,strCategoryName ,isnull(sum(case when D.fldUserDefinedCourseId is not null then 1 end),0) as intCourseCount  
 FROM  
 @Catelog_Tree A Left outer join TBL_COURSE_CUSTOMER_CATALOG_SETTINGS B ON A.intCategoryId=B.intCourseCategoryId  
     AND B.intcustId = @intCustId and B.charDispCourseInCatalog = 'Y'  
    left outer join tbl_course_name c on c.fldUserDefinedCourseId=B.strUserDefindedCourseId  
	and  c.charCourseStatus = 'A' 
	left outer join tbl_course_master d on d.fldUserDefinedCourseId=c.fldUserDefinedCourseId
	and d.fldCourseVersion=(select max(fldcourseversion) from tbl_course_master where fldUserDefinedCourseId=C.fldUserDefinedCourseId)
         AND c.EmbedCount IS NULL   AND c.fldDeliveryMethod IN ('wb','po')
			
  WHERE    
            A.intCustId=@intCustId   
 Group by intCategoryId , intParentCategoryId,strCategoryName   
  
    SET @errorCode = '0'   
    
END TRY  
    BEGIN CATCH  
    
        DECLARE @ErrMsg NVARCHAR(4000) ,  
            @ErrSeverity INT  
        SELECT  @ErrMsg = ERROR_MESSAGE() ,  
                @ErrSeverity = ERROR_SEVERITY()  
        SET @errorCode ='1'  
        RAISERROR(@ErrMsg, @ErrSeverity, 1)  
          
  END CATCH  