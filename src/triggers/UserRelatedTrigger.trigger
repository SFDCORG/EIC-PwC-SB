/**************************************************************************************************
 * Name: UserRelatedTrigger
 * Object: User
 * Purpose: Update User basic info according to the user role, If user role changed, refresh related opportunity team 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18        Create this trigger
 **************************************************************************************************/
trigger UserRelatedTrigger on User(after update, after insert) {
    Set<Id> userIDs = new Set<Id>();
    List<User> updatedUsers = new List<User>();
    Set<ID> roleIds = new Set<ID>();
    Set<ID> roleRelatedUserIDs = new Set<ID>();

    for (User u : trigger.new) {
        String currentRoleID = u.UserRoleId;
        if (trigger.isUpdate && u.UserRoleId != null) {
            User olduser = trigger.oldMap.get(u.Id);
          
            if (u.UserRoleId != null && olduser.UserRoleId != u.UserRoleId) {
                userIDs.add(u.Id);
            }

            if ((olduser.UserRoleId == null || olduser.UserRoleId != currentRoleID)
                    ||( !olduser.IsActive && u.IsActive && u.UserRole != null)) {
                roleIds.add(currentRoleID);
                roleRelatedUserIDs.add(u.id);
            }
        }
        else if (u.UserRoleId != null) { 
            userIDs.add(u.Id);
            roleIds.add(currentRoleID);
            roleRelatedUserIDs.add(u.Id);
        }

        if (roleRelatedUserIDs.size() > 0) {
            Database.executeBatch(new refreshOppTeam(roleIds, roleRelatedUserIDs), 20);
        }
    }

    for (User u : [SELECT Id, 
                        UserRole.DeveloperName, 
                        Group_of_Role__c,
                        Title_of_Role__c,
                        Office_of_Role__c,
                        Department_of_Role__c
                    FROM User WHERE Id IN :userIDs]) {    
        String rolename = u.UserRole.DeveloperName;
        List<String> capStrings = rolename.split('_');
        if (capStrings.size() == 6) {
            u.Office_of_Role__c = capStrings[2];
            u.Department_of_Role__c = capStrings[3];
            u.Group_of_Role__c = capStrings[4];
            u.Title_of_Role__c = capStrings[5];
            updatedUsers.add(u);
        }
    }

    if (updatedUsers.size() > 0) {
        update updatedUsers;
    }
}