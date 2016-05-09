/**************************************************************************************************
 * Name: lookupUserforOpportunityControllerTest
 * Object: / 
 * Purpose: Test the Lookup component on the Opportunity mass Assign page, 
            Using specify search content to search user in the system
 * Author: /
 * Create Date: 2016-04-26
 **************************************************************************************************/

@isTest
private class lookupUserforOpportunityControllerTest {
    static testMethod void testMethod1() {
        User usr = [SELECT id 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];

        // Prepares the TEST Data
        System.runAs(usr) {
            UserRole role = TestObjectFactory.createUserRole();
            role.DeveloperName = 'Counselling_GZ_XY_AN_A_Consultant';
            insert role;
            UserRole role2 = TestObjectFactory.createUserRole();
            role2.DeveloperName = 'Counselling_SH_XY_AN_A_Consultant';
            insert role2;

            User uuser = TestObjectFactory.createSalesUser();
            uuser.Username = 'oppSearch@test.com.eic';
            uuser.LastName = 'Perfect';
            uuser.User_External_Id__c = '201604231433';
            uuser.UserRoleId = role2.id;
            insert uuser;
            User uuser2 = TestObjectFactory.createSalesUser();
            uuser2.Username ='oppSearch2@test.com.eic';
            uuser2.LastName = 'Nigo';
            uuser2.User_External_Id__c = '201604231434';
            uuser2.UserRoleId = role.Id;
            uuser2.ProfileId = Constants.PROFILE_LOCAL_CS_MANAGER_ID;
            insert uuser2;
            User uuser3 = TestObjectFactory.createSalesUser();
            uuser3.Username = 'oppSearch3@test.com.eic';
            uuser3.LastName = 'Perfect123';
            uuser3.User_External_Id__c = '201604231435';
            uuser3.UserRoleId = role2.id;
            insert uuser3;
            User uuser4 = TestObjectFactory.createSalesUser();
            uuser4.Username = 'oppSearch4@test.com.eic';
            uuser4.LastName = 'Perfect125';
            uuser4.User_External_Id__c = '201604231436';
            uuser4.UserRoleId = Constants.ROLE_TMK_HQ_STAFF_ID;
            insert uuser4;

            List<String> searchResultsIds = new List<String>();
            searchResultsIds.add(uuser.Id);
            searchResultsIds.add(uuser2.Id);
            searchResultsIds.add(uuser3.Id);
            Test.setFixedSearchResults(searchResultsIds);
        }

        //Adding SOSL Queries to Unit Tests,
        User runUser = [SELECT Approval_Department__c, Business_Unit__c, City_of_Role__c, ProfileId,
                               Department_of_Role__c, Name, IsActive
                        FROM User 
                        WHERE Username = 'oppSearch@test.com.eic'];

        User TMKUser = [SELECT Approval_Department__c, Business_Unit__c, City_of_Role__c, ProfileId,
                               Department_of_Role__c, Name, IsActive
                        FROM User 
                        WHERE Username = 'oppSearch4@test.com.eic'];

        User localCSUser = [SELECT Approval_Department__c, Business_Unit__c, City_of_Role__c, ProfileId,
                                   Department_of_Role__c, Name, IsActive
                            FROM User 
                            WHERE Username = 'oppSearch2@test.com.eic'];

        CS_Assign_City_Territory__c terry= TestObjectFactory.createCSAssignCityTerritory();
        insert terry;

        test.StartTest();

        // Logins as a CC Manager, there have 3 Perfect start user in the system, 
        // But only two of them's business line and city is same as each other.
        // Uses Perfect* to search user, and return result shall be only two user.
        System.runAs(runUser) {
            PageReference myVfPage = Page.lookupUserforOpportunity;
            Test.setCurrentPageReference(myVfPage);
            lookupUserforOpportunityController lookup = new lookupUserforOpportunityController();
            lookup.searchText = 'Perfect*';
            lookup.searchUser();
            System.assertEquals(2, lookup.userlist.size());
        }

        // Logins as a tmk user, there have 3 Perfect start user in the system, but only one of them's deparment is CS
        // Uses Perfect* to search user, and return result shall be only one CS deparetment user.
        System.runAs(TMKUser) {
            PageReference myVfPage = Page.lookupUserforOpportunity;
            Test.setCurrentPageReference(myVfPage);
            lookupUserforOpportunityController lookup = new lookupUserforOpportunityController();
            lookup.searchText = 'Perfect*';
            lookup.searchUser();
            System.assertEquals(1, lookup.userlist.size());
        }
        // Login as a Local service center user, and user's city is GZ, which is different with other user in the list
        // Enable one terriroy expand custom setting, means expand GZ CS can also search SH and JN city's user
        // Search named pefect user, User can search 2 shanghai named perfect user
        System.runAs(localCSUser) {
            PageReference myVfPage = Page.lookupUserforOpportunity;
            Test.setCurrentPageReference(myVfPage);
            lookupUserforOpportunityController lookup = new lookupUserforOpportunityController();
            lookup.searchText = 'Perfect*';
            lookup.searchUser();
            System.assertEquals(2, lookup.userlist.size());
        }
        test.StopTest();
    }
}