IF EXISTS( SELECT 1 FROM sys.objects WHERE name = 'CheckIsAllRealmAssigned')
	DROP FUNCTION CheckIsAllRealmAssigned

GO

CREATE FUNCTION CheckIsAllRealmAssigned
    (
      @organizationId INT ,
      @userID INT,
      @realmID INT,
      @realmType VARCHAR(20)
    )
RETURNS INT
AS 
    BEGIN
        
        DECLARE @realmValue INT
        DECLARE @intTotalRealm INT
      
    ---- To check all regions are assigned to user or not
     IF (@realmType = 'Organization') 
        BEGIN
            DECLARE @intAssignedRealmRegion INT
            SELECT  @intTotalRealm = COUNT(*)
            FROM    dbo.TBL_REGION_LOOKUP RL
            WHERE   fldCustId = @organizationId 
								
            SELECT  @intAssignedRealmRegion = COUNT(*)
            FROM    dbo.TBL_MANAGER_REGION_REALM TMDR
                    INNER JOIN dbo.TBL_REGION_LOOKUP RL ON RL.fldRegionId = TMDR.intRegionId
                                                           AND RL.fldCustId = @organizationId
            WHERE   TMDR.intUserId = @userID
			
            IF ( @intAssignedRealmRegion > 0 ) 
                BEGIN
                    IF ( @intAssignedRealmRegion = @intTotalRealm ) 
                        BEGIN 
                            SET @realmValue = 1
                        END
                    ELSE 
                        BEGIN 
                            SET @realmValue = 2
                        END
                END
            ELSE 
                BEGIN 
                    SET @realmValue = 0	
                END
        END
        
     ---- To check all Division and there departments are assigned to user or not for perticular Region   
 IF ( @realmType = 'Region' ) 
    BEGIN
        DECLARE @intAssignedRealmDivision INT
        SELECT  @intTotalRealm = COUNT(*)
        FROM    dbo.TBL_DIVISION_LOOKUP DL
        WHERE   fldCustId = @organizationId
                AND DL.fldRegionId = @realmID
				
        SELECT  @intAssignedRealmDivision = COUNT(*)
        FROM    dbo.TBL_MANAGER_DIVISION_REALM TMDR
                INNER JOIN dbo.TBL_DIVISION_LOOKUP DL ON DL.fldDivisionId = TMDR.intDivisionId
                                                         AND DL.fldRegionId = @realmID
        WHERE   intUserId = @userID 
        
        IF(@intTotalRealm = 0)
			BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.TBL_MANAGER_REGION_REALM WHERE intRegionId =@realmID AND intUserId=@userID) )
					BEGIN
						 SET @realmValue = 1
					END	
				ELSE 
					SET @realmValue = 0		 
			
			END
        ELSE IF ( @intAssignedRealmDivision > 0 ) 
            BEGIN
                IF ( @intAssignedRealmDivision = @intTotalRealm ) 
                    BEGIN
                      DECLARE @intNOTAssignedRealmDepartment INT
                      
                        SELECT  @intNOTAssignedRealmDepartment = COUNT(*)
                        FROM    dbo.TBL_DEPARTMENT_LOOKUP DL
                                LEFT OUTER JOIN TBL_MANAGER_DEPARTMENT_REALM MDL ON DL.fldDeptId = MDL.intDepartmentId
                                                              AND MDL.intUserId = @userID
                        WHERE   DL.fldRegionId = @realmID
                                AND intDepartmentId IS NULL
														
                        IF ( @intNOTAssignedRealmDepartment > 0 ) 
                            SET @realmValue = 2
                        ELSE 
                            SET @realmValue = 1
                    END
                ELSE 
                    SET @realmValue = 2 
            END
        ELSE 
        BEGIN
            SET @realmValue = 0
        END
		
    END
	---- To check all Departments are assigned to user or not for perticular division
 IF ( @realmType = 'Division' ) 
    BEGIN
	  DECLARE @intAssignedRealmDepartment INT
        SELECT  @intTotalRealm = COUNT(*)
        FROM    dbo.TBL_DEPARTMENT_LOOKUP DL
        WHERE   DL.fldCustId = @organizationId
                AND DL.fldDivisionId = @realmID
	
        SELECT  @intAssignedRealmDepartment = COUNT(*)
        FROM    dbo.TBL_DEPARTMENT_LOOKUP DL
                INNER JOIN TBL_MANAGER_DEPARTMENT_REALM MDL ON DL.fldDeptId = MDL.intDepartmentId
                                                              AND MDL.intUserId = @userID
        WHERE   DL.fldDivisionId = @realmID
          
          IF(@intTotalRealm = 0)
			BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.TBL_MANAGER_DIVISION_REALM WHERE intDivisionId =@realmID AND intUserId=@userID) )
					BEGIN
						 SET @realmValue = 1
					END	
				ELSE 
					SET @realmValue = 0		 
			
			END
        ELSE IF ( @intAssignedRealmDepartment > 0 ) 
            BEGIN
                IF ( @intAssignedRealmDepartment = @intTotalRealm ) 
                    SET @realmValue = 1
                ELSE 
                    SET @realmValue = 2
            END
        ELSE 
            SET @realmValue = 0
    END
		
   RETURN (@realmValue)
	
	--SELECT dbo.CheckIsAllRealmAssigned(926,401679,2688,'Region')
	--SELECT dbo.CheckIsAllRealmAssigned(926, 401679, 2688, 'Organization')
    END