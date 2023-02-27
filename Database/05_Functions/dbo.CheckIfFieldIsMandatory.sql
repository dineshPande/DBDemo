IF EXISTS( SELECT 1 FROM sys.objects WHERE name = 'CheckIfFieldIsMandatory')
	DROP FUNCTION CheckIfFieldIsMandatory

GO

CREATE FUNCTION CheckIfFieldIsMandatory
    (
      @custID INT ,
      @FieldCode VARCHAR(8)
    )
RETURNS BIT
AS 
    BEGIN
        DECLARE @charPrimaryKeyIdentifier VARCHAR(2),
            @fldIsEmpIdMandatory BIT,
            @charIsEmailIdMandatory VARCHAR(2)
            
        SELECT  @charPrimaryKeyIdentifier = charPrimaryKeyIdentifier ,
                @fldIsEmpIdMandatory = fldIsEmpIdMandatory ,
                @charIsEmailIdMandatory = charIsEmailIdMandatory
        FROM    dbo.TBL_CUSTOMER_LOOKUP
        WHERE   fldCustId = @custID    

        DECLARE @isMandatory BIT
        SELECT  @isMandatory = CASE WHEN ( TBL_SELF_REGISTRATION_FORM_FIELDS.charIsMandatory = 'Y'
                                           OR TBL_USER_PROFILE_FIELDS_MASTER.bitIsSystemField = 1
                                           OR (@charPrimaryKeyIdentifier = 'E'  AND @FieldCode = 'F015')
                                           OR (@charPrimaryKeyIdentifier = 'D'  AND @FieldCode = 'F004')
                                           OR (@charPrimaryKeyIdentifier = 'D'  AND @FieldCode = 'F004')
                                           OR (@charIsEmailIdMandatory = 'Y'  AND @FieldCode = 'F015')
                                           OR (@fldIsEmpIdMandatory = 1  AND @FieldCode = 'F004')
                                         ) THEN 1
                                    ELSE 0
                               END
        FROM    dbo.TBL_SELF_REGISTRATION_FORM_FIELDS
                INNER JOIN dbo.TBL_USER_PROFILE_FIELDS_MASTER ON TBL_SELF_REGISTRATION_FORM_FIELDS.charFieldCode = TBL_USER_PROFILE_FIELDS_MASTER.strFieldCode
        WHERE   TBL_SELF_REGISTRATION_FORM_FIELDS.intCustId = @custID
                AND TBL_SELF_REGISTRATION_FORM_FIELDS.charFieldCode = @FieldCode
	
        RETURN (@isMandatory)
	
	--SELECT dbo.ValidateProfileField(894,'F001')
    END