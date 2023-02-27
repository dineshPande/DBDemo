
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS ( SELECT  1
            FROM    SYS.PROCEDURES
            WHERE   NAME = 'USP_Get_Login_Page_Info' ) 
    DROP PROCEDURE USP_Get_Login_Page_Info
GO
 
 -- EXEC USP_Get_Login_Page_Info 824,1,''
CREATE PROCEDURE [dbo].[USP_Get_Login_Page_Info]
	@strFolderName Varchar(100),
	@intLanguageId INT,
	@ErrorCode VARCHAR(200) OUTPUT
AS 
    SET NOCOUNT ON ;
	SET Transaction Isolation Level Read Uncommitted;
    BEGIN TRY
	DECLARE @strMainColor varchar(50),@strButtonTabColor varchar(50),@strHeadingTitleColor Varchar(50)
	DECLARE @strPortalbody Nvarchar(max)
	DECLARE @displaybodytext BIT
	DECLARE @HeaderTextSettings VARCHAR(10)
	DECLARE @HeaderCustomText  NVARCHAR(MAX)
	DECLARE @BannerfileUrl Varchar(500)
	DECLARE @bitIsSMALSSOEnabled BIT
	DECLARE @bitIsPasswordLessLoginEnable BIT
	DECLARE @count INT
	DECLARE @intCustID INT
	DECLARE @bitIsSystemBanner BIT
	DECLARE @strSAMLEndPointURL VARCHAR(1000)
	DECLARE @strPrimaryOrgEmailID VARCHAR(200)
	DECLARE @intDaysToExpirePasswordLessLoginLink INT;

	Select @intCustID=fldcustid
	from TBL_orgfoldername
	where fldFolderName=@strFolderName

	IF isnull(@intCustID,0)=0
	BEGIN
			SET @ErrorCode='ER0002' 
			RETURN
	END

	IF Exists(Select 1 from TBL_Customer_lookup where fldcustid=@intCustID and fldcustomerflag<>'A')
	BEGIN
			SET @ErrorCode='ER0002' 
			RETURN
	END

	IF isnull(@intLanguageId,0)=0
	BEGIN
		SELECT @intLanguageId=fldlanguageID  from TBL_ORGANIZATION_LANGUAGE  
		 where  fldCustId = @intCustID  
		 and  fldIsDefault = 'Y'  
	END


	Select @count=count(*)
	FROM TBL_ORGANIZATION_LANGUAGE where fldCustId=@intCustID and fldLanguageId=@intLanguageId
	
	IF isnull(@count,0)>0
	BEGIN	
		Select  @strMainColor=TT.strMainColor,@strButtonTabColor= TT.strButtonTabColor,@strHeadingTitleColor= TT.strHeadingTitleColor
		FROM TBL_THEME_MASTER as TT inner join TBL_Customer_Theme as TC on TT.intThemeID = TC.intThemeID
			Where TC.intCustID = @intCustID and TC.bitIsSelected=1 

		 SELECT  @strPortalbody = strLoginPageBodyText   
        FROM    TBL_LOGIN_PAGE_TEXT    
        WHERE   intCustID = @IntCustId    
                AND intLanguageID = @IntLanguageId   

	     Select @displaybodytext=strCustomerSettingValue
		 FROM 
		  TBL_Customer_Setting_Detail where intCustID=@IntCustId and  intCustomerSettingID=404  

		Select @HeaderTextSettings=strCustomerSettingValue
		 FROM 
		  TBL_Customer_Setting_Detail where intCustID=@IntCustId and  intCustomerSettingID=405
		 Select @HeaderCustomText=strCustomerSettingValue
		 FROM 
		  TBL_Customer_Setting_Detail where intCustID=@IntCustId and  intCustomerSettingID=406 
		  
		  Select @BannerfileUrl=strBannerFileName,@bitIsSystemBanner=bitIsSystem from  TBL_Organization_Banner where intCustID=@IntCustId 
		  and strBannerSelectedForSection='LG' 

		  select @bitIsSMALSSOEnabled=bitIsSMALSSOEnabled ,@strSAMLEndPointURL=strEndPointURL 
			from TBL_SSO_MASTER_SETTINGS where intCustID=@intCustID

			 select @strPrimaryOrgEmailID=fldemail  from tbl_user_master tum inner join TBL_CUSTOMER_LOOKUP tcl  on tum.fldUserId=tcl.fldUserId where tcl.fldCustId=@intCustID 
		
		 Select @bitIsPasswordLessLoginEnable=bitIsPasswordLessLoginEnable,
			@intDaysToExpirePasswordLessLoginLink=intDaysToExpirePasswordLessLoginLink
		 from TBL_Customer_PasswordLessLogin_Settings where intCustID=@intCustID

			Select fldcustid,fldcustomername,fldLogoTitle as LogoTitle, fldLogoPath  as logofileurl,Case when len(isnull(fldUrlDetail,''))>0 then  'http://'+fldUrlDetail else fldUrlDetail end  as logolinkurl,
			bitDisplayForgotPasswordLink,fldAllowRegisterUs as displayselfregistrationlink,@strPortalbody as Loginbodytext,
			@displaybodytext as displaybodytext,@HeaderTextSettings as Header,@HeaderCustomText as HeaderText,
			@BannerfileUrl as BannerfileUrl,@bitIsSystemBanner as bitIsSystemBanner,@strMainColor as basecolor ,@strButtonTabColor as buttoncolor ,@strHeadingTitleColor as textcolor,
			@bitIsSMALSSOEnabled as IsSMALSSOEnabled,@bitIsPasswordLessLoginEnable as PasswordLessLogin,
			@intDaysToExpirePasswordLessLoginLink as intDaysToExpirePasswordLessLoginLink,
			fldSupportOption as supportlinktype,
			CASE fldSupportOption  WHEN '1' THEN @strPrimaryOrgEmailID ELSE fldSupportEmailId  ENd as supportlinkvalue,
			bitDisplayLanguageSelector as DisplayLanguageOption
			,@strSAMLEndPointURL as strSAMLEndPointURL
			, charSelfRegEmailVerification as charSelfRegEmailVerification
			, fldDefaultLanguageId as intDefaultLanguageId
			, fldtimezoneid as intDefaultTimezoneId
			FROM
			TBL_Customer_lookup A Left outer join TBL_USER_LOGO B ON A.fldUserid=B.flduserid
			where A.fldcustid=@intCustID
			
			select intPageId, strPageTitle,strPageText,strPageType
			from TBL_ADDITIONAL_PAGES  where intCustId=@intCustId          
			and intLanguageId = @intLanguageId  

			SELECT    TBL_LANGUAGE_MASTER.fldLanguageName ,  
                      TBL_LANGUAGE_MASTER.fldLanguageDisplayName ,
					  TBL_LANGUAGE_MASTER.fldLanguageId 
             FROM    TBL_LANGUAGE_MASTER  
                            INNER JOIN TBL_ORGANIZATION_LANGUAGE  
                                    ON TBL_LANGUAGE_MASTER.fldLanguageId = TBL_ORGANIZATION_LANGUAGE.fldLanguageId  
                            WHERE   TBL_ORGANIZATION_LANGUAGE.fldCustId = @intCustID  and fldIsDelete='N' and fldLanguageActiveStatus = 'A'  
		SET @ErrorCode='0'
		END
		ELSE
		BEGIN
				SET @ErrorCode='ER0001'
		END
			 
			  

			
       
    END TRY
    BEGIN CATCH
		 -- Raise an error with the details of the exception
		 SET @ErrorCode='1'
        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT
        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        RAISERROR(@ErrMsg, @ErrSeverity, 1)
        
    END CATCH
GO


