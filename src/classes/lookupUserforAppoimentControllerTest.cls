/**************************************************************************************************
 * Name: lookupUserforAppoimentControllerTest
 * Object: / 
 * Purpose: Test the Lookup component on the appointment batch Assign page, 
            Using specify search content to search user in the systems
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/
@isTest
private class lookupUserforAppoimentControllerTest {
    static testMethod void testMethod1() {
          
        User usr = [SELECT id 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];

        // Prepares the TEST Data
        System.runAs(usr) {
            UserRole role = TestObjectFactory.createUserRole();
            insert role;
            User uuser = TestObjectFactory.createSalesUser();
            uuser.Username = 'appSearch@test.com.eic';
            uuser.LastName = 'Perfect';
            uuser.User_External_Id__c = '201604231433';
            uuser.isActive=true;
            insert uuser;
            User uuser2 = TestObjectFactory.createSalesUser();
            uuser2.Username='appSearch2@test.com.eic';
            uuser2.LastName = 'Nigo';
            uuser2.User_External_Id__c = '201604231434';
            uuser2.isActive=true;
            insert uuser2;
            User uuser3 = TestObjectFactory.createSalesUser();
            uuser3.Username = 'appSearch3@test.com.eic';
            uuser3.LastName = 'Perfect123';
            uuser3.User_External_Id__c = '201604231435';
            insert uuser3;
            User uuser4 = TestObjectFactory.createSalesUser();
            uuser4.Username = 'appSearch4@test.com.eic';
            uuser4.LastName = 'ShanDa';
            uuser4.User_External_Id__c = '201604231436';
            uuser4.ProfileId = constants.PROFILE_TMK_CUSTOMER_SERVICE_ID;
            insert uuser4;
            User uuser5 = TestObjectFactory.createSalesUser();
            uuser5.Username = 'appSearch5@test.com.eic';
            uuser5.LastName = 'admin';
            uuser5.User_External_Id__c = '201604231437';
            uuser5.ProfileId = constants.PROFILE_SYS_ADMIN_ID;
            uuser5.UserRoleId = role.Id;
            insert uuser5;
        }

        // Uses an CC Manager User login in the system
        User runUser = [SELECT Approval_Department__c, Business_Unit__c, City_of_Role__c, ProfileId,
                         	   Department_of_Role__c, Name, IsActive
                        FROM User 
                        WHERE Username = 'appSearch@test.com.eic'];

        User adminUser = [SELECT Approval_Department__c, Business_Unit__c, City_of_Role__c, ProfileId,
                               Department_of_Role__c, Name, IsActive
                          FROM User 
                          WHERE Username = 'appSearch5@test.com.eic'];
        test.StartTest();
        System.runAs(runUser) {
        	PageReference myVfPage = Page.LookupUserofAppoitnment;
            Test.setCurrentPageReference(myVfPage);
            lookupUserforAppoimentController lookup = new lookupUserforAppoimentController();
            
            // Searchs a manger user in system, and add * after the search key words, Expect it will be searched succesfully.
            lookup.searchText = 'Nigo*';
            lookup.searchUser();
            System.assertEquals(true, lookup.userlist.size() == 1);

            // Searchs a TMK user in the system, becasue it's not a manger user, it can't be searched
            lookup.searchText = 'ShanDa';
            lookup.searchUser();
            System.assertEquals(true, lookup.userlist.size() == 0);
        }
        
        // Runs as an Administrator, admin can serach user without city limitation
        System.runAs(adminUser) {
        	PageReference myVfPage = Page.LookupUserofAppoitnment;
            Test.setCurrentPageReference(myVfPage);
            lookupUserforAppoimentController lookup = new lookupUserforAppoimentController();
            lookup.searchText = 'Perfec*';
            lookup.searchUser();
            System.assertEquals(true, lookup.userlist.size() == 2);
        }
        test.StopTest();
    }
}