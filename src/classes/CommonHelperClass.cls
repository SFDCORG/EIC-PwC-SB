/**************************************************************************************************
 * Name: CommonHelperClass
 * Object: /
 * Purpose:  Define some common using method
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
global  class CommonHelperClass {

    // Get All the Role which higher than the current roles
    public static Set<ID> getAllHigherRoles (set<ID> currentroles) {

        Map<ID, ID> childParentIDMap = generateParentRoleMap(); // ChildID, parentID

        return generateAllRoleIDSet(childParentIDMap, currentroles); // Return all the roles which is higher than the specify role      
    }

    // Get All the Role which lower than the current roles
    public static Set<ID> getAllLowerRoles (set<ID> currentroles) {

        Map<ID, ID> childParentIDMap = generateChildRoleMap(); // ParentID, childID
        return generateAllRoleIDSet(childParentIDMap, currentroles); // Return all the roles which is lower than the specify role    
    }

    // Get All the Role which higher than the current roles, and put the relation ship in a map
    public static Map<ID, Set<ID>> getHigherRoles (set<ID> currentroles) {

        Map<ID, ID> childParentIDMap = generateParentRoleMap(); // ChildID, parentID
        return generateRoleIDSet(childParentIDMap, currentroles); // Return the roles which is higher than the specify role      
    }

    // Get All the Role which lower than the current roles, and put the relation ship in a map
    public static Map<ID, Set<ID>> getLowerRoles (set<ID> currentroles) {

        Map<ID, ID> childParentIDMap = generateChildRoleMap(); // ParentID, childID
        return generateRoleIDSet(childParentIDMap, currentroles); //Return the roles which is lower than the specify role    
    }

    // Get All the role which lower or equals current role
    public static Map<ID, Set<ID>> getLowerEqRoles (set<ID> currentroles) {

        Map<ID, ID> childParentIDMap = generateChildRoleMap(); // ParentID, childID
        return generateRoleIDSetWEQ(childParentIDMap, currentroles); // Return the roles which is lower than the specify role    
    }

    // Get all the user according the specify role
    public static Set<ID> getallUserinSpecifyRole (set<ID> UserRoleId) {

        Set<ID> ids = new Set<ID> ();
        for (User u : [SELECT Id 
                       FROM User 
                       WHERE UserRoleId IN :UserRoleId 
                       AND IsActive = true]) {
          ids.add(u.Id);
        }
        return ids;
    }

    // Get all the user according toe the specify role, and generate the relationship man
    public static Map<ID, Set<ID>> getallUserinSpecifyRolesMap (Map<ID, Set<ID>> UserRoleIdmap) {

        Map<ID, Set<ID>> returnResults = new Map<ID, Set<ID>> ();
        Set<ID> userRoles = new  Set<ID> ();
        
        for (ID key : UserRoleIdmap.keySet()) {

          userRoles.addAll(UserRoleIdmap.get(key));
        }

        for (User u : [SELECT Id, UserRoleId 
                      FROM User 
                      WHERE UserRoleId IN :userRoles 
                      AND IsActive = true
                      AND profileId NOT IN :ProfileRelated.adminProfileSet()]) {

            for (ID key : UserRoleIdmap.keySet()) {

                if (UserRoleIdmap.get(key).contains(u.UserRoleId)) {
                    Set<ID> users = returnResults.get(key) == null ? new Set<ID> () : returnResults.get(key);
                    users.add(u.Id);
                    returnResults.put(key, users);
                }
            }
        }
        return returnResults;
    }

    // Generates Appointment Manually share
    public static Appoitment__share AppointmentmanualShare (Id recordId, Id userOrGroupId, String permissionType) {

        // Create new sharing object for the custom object Job.
        Appoitment__share appShr = new Appoitment__share ();

        // Set the ID of record being shared.
        appShr.ParentId = recordId;

        // Set the ID of user or group being granted access.
        appShr.UserOrGroupId = userOrGroupId;

        // Set the access level.
        appShr.AccessLevel = permissionType;

        // Set rowCause to 'manual' for manual sharing.
        // This line can be omitted as 'manual' is the default value for sharing objects.
        appShr.RowCause = Schema.Appoitment__share.RowCause.Manual;
        return appShr ;
    }

    public static void createManuallyAppShareRule (Map<ID, Map<ID, String>> userPermissions) {

        List<Appoitment__share> jbShares = new List<Appoitment__share> ();
        for (ID appID : userPermissions.keySet()) {

            for (Id userid : userPermissions.get(appID).keySet()) {

                jbShares.add(AppointmentmanualShare(appID, userid, userPermissions.get(appID).get(userID)));
            }
        }

        try {

            if (jbShares.size() > 0) insert jbShares;
        } Catch (Exception e) { return; }
    }

    // Creates appointment share rule
    public static void shareAppstoAccountTeam (Map<ID, Set<ID>> appAccoutMap) {

        List<Appoitment__share> appShares = new List<Appoitment__share> ();
        for (Id appid : appAccoutMap.keySet()) {

             for (Id userid : appAccoutMap.get(appId)) {

                 appShares.add(AppointmentmanualShare(appID, userid, 'Edit'));
             }
        }
        if (appShares.size() > 0) insert appShares;
    }

    // Creates appointment share rule
    public static void shareTmkAppstoAccountgroup (Map<ID, ID> appAccoutMap,Set<ID> accids) {

        List<Appoitment__share> appShares = new List<Appoitment__share> ();
        List<Appoitment__share> delShares = new List<Appoitment__share> ();
        Map<ID, Set<ID>> accUsersMap = new Map<ID, Set<ID>> ();

        for (Opportunity opp : [SELECT id, AccountId,OwnerID 
                                FROM Opportunity
                                WHERE AccountId IN :accids
                                AND Owner.IsActive = true]) {

            Set<id> users = accUsersMap.get(opp.AccountId) == null ? new Set<id> () : accUsersMap.get(opp.AccountId);
            users.add(opp.OwnerID);
            accUsersMap.put(opp.AccountID, users);
        }

        delShares = [SELECT Id
                     FROM Appoitment__share
                     WHERE ParentId IN :appAccoutMap.keySet()
                     AND RowCause = 'Manual'];

        if (delShares.size() > 0) Delete delShares;
        for (Appoitment__c app : [SELECT OwnerID 
                                  FROM Appoitment__c 
                                  WHERE Id IN :appAccoutMap.keySet()]) {

             Set<ID> userids = accUsersMap.get(appAccoutMap.get(app.id)) == null ?
                               new Set<ID> () :
                               accUsersMap.get(appAccoutMap.get(app.id));

             for (Id userid : userids) {

                 if (app.OwnerId != userid) {

                      appShares.add(AppointmentmanualShare(app.id, userid, 'Edit'));
                 }
             }
        }

        if (appShares.size() > 0) insert appShares;
    }

    // Get All higher or lower role in the Role tree
    public static Set<ID> getallRelatedRoles (String roleid) {

        Set<ID> roleids = new Set<ID> ();
        Set<ID> returnRoleids = new Set<ID> ();
        roleids.add(roleid);
        Map<ID, ID> parentIDMap = generateParentRoleMap();
        Map<ID, ID> childIDMap = generateChildRoleMap(); 
        returnRoleids.addAll(generateAllRoleIDSet(parentIDMap,roleids));
        returnRoleids.addAll(generateAllRoleIDSet(childIDMap,roleids));

        Return returnRoleids;
    }

    // Generates Role Map Parent - Child
    private static Map<ID, ID>  generateParentRoleMap () {

        Map<ID, ID> childParentIDMap = new Map<ID, ID> (); // childID, parentID    
        List<UserRole> allRoleMap = [SELECT ParentRoleID 
                                     FROM UserRole];

        for (UserRole ur:allRoleMap) {

            childParentIDMap.put(ur.ID, ur.ParentRoleID);
        }

        return childParentIDMap;
    }

     // Generates Role Map Child - Parent
     private static Map<ID, ID>  generateChildRoleMap() {

        Map<ID, ID> childParentIDMap = new Map<ID, ID> (); // childID, parentID    
        List<UserRole> allRoleMap = [SELECT ParentRoleID FROM UserRole];

        for (UserRole ur:allRoleMap) {

            childParentIDMap.put( ur.ParentRoleID, ur.ID);
        }

        return childParentIDMap;
    }

    // Generates Role ID Set
    private static Map<ID, Set<ID>> generateRoleIDSet(Map<ID, ID> childParentIDMap, Set<ID> currentroles) {

        Map<ID, Set<ID>> userRoleMap = new Map<ID, Set<ID>> ();
        for (ID Idd : currentroles) {

            Set<ID> RoleIDSet = new Set<ID> ();
            ID CurrentID = Idd;
            while(childParentIDMap.get(CurrentID)!= null) {

                RoleIDSet.add(childParentIDMap.get(CurrentID));
                CurrentID = childParentIDMap.get(CurrentID);
            }
            userRoleMap.put(idd, RoleIDSet);
        }

        return userRoleMap;
    }

    private static Map<ID, Set<ID>> generateRoleIDSetWEQ (Map<ID, ID> childParentIDMap, Set<ID> currentroles) {  
        Map<ID, Set<ID>> userRoleMap = new Map<ID, Set<ID>> ();

        for (ID Idd : currentroles) {

           Set<ID> RoleIDSet = new Set<ID> ();
           ID CurrentID = Idd;
           RoleIDSet.add(CurrentID);
           while (childParentIDMap.get(CurrentID) != null) {

              RoleIDSet.add(childParentIDMap.get(CurrentID));
              CurrentID = childParentIDMap.get(CurrentID);
           }

           userRoleMap.put(idd, RoleIDSet);
        }

        return userRoleMap;
    }

    private static Set<ID> generateAllRoleIDSet (Map<ID, ID> childParentIDMap, Set<ID> currentroles) {

        Set<ID> RoleIDSet = new Set<ID> ();
        For (ID Idd : currentroles) {

            ID CurrentID = Idd;
            while(childParentIDMap.get(CurrentID) != null) {

              RoleIDSet.add(childParentIDMap.get(CurrentID));
              CurrentID = childParentIDMap.get(CurrentID);
            }
        }

        return RoleIDSet;
    }

    // Compares the VF Error Message with the expected result, return the compare Result
    public static Boolean compareVfErr(List<Apexpages.Message> msgs, String expectedMsg) {

        Boolean errCheck = false;
        for (Apexpages.Message msg : msgs) {

            if (msg.getDetail().contains(expectedMsg)) errCheck = true;
        }

        return errCheck;
    }
}