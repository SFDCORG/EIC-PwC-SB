/**************************************************************************************************
 * Name: AccountChangeAlertTriggerTest
 * Object: Account
 * Purpose: a test class for AccountChangeAlert, AccountChangeAlertTriggerAfterUpdate
 * Author:  ()
 * Create Date: --
 * Modified History: 
 * 2016-05-11 vicia wang   Writes comments in this format and adds comments
***************************************************************************************************/
@isTest
private class AccountChangeAlertTriggerTest {

    @isTest static void testAlertTriggered () {

        // Implements test code
        User thisUser = [SELECT Id 
                         FROM User 
                         WHERE Id = : UserInfo.getUserId()];

        Test.startTest();
        User accUser;
        User oppUser;
        Account acc;
        Opportunity opp1;

        // Initializes data
        System.runAs(thisUser) {
            accUser = TestObjectFactory.createTmkUser('accUser');
            oppUser = TestObjectFactory.createTmkUser('oppUser');
            insert oppUser;
            insert accUser;
            acc = TestObjectFactory.createAccount();
            acc.OwnerId = accUser.id;
            insert acc;

            // Creates the opportunity with the user
            opp1 = TestObjectFactory.createOpportunity(acc.Id, oppUser);
            insert opp1;
        }


        System.runAs(accUser) {
            acc.Postcode__c = '200053';
            update acc;

            // A notification record has been created for opportunity user
            List<Task> tasks = [SELECT Subject, ActivityDate, 
                                       Description__c, OwnerId
                                FROM Task 
                                WHERE OwnerId = :oppUser.Id];

            System.assert(tasks.size() == 1);
            
            // Asserts the information
            for (Task ac: tasks) {
                System.assert(ac.OwnerId == oppUser.Id);
                System.assert(ac.Subject == '客户信息被改变');
                System.assert(ac.ActivityDate == system.today());
            }
        }

        Test.stopTest();
    }
}