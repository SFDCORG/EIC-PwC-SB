@isTest
private class AccountChangeAlertTriggerTest {

    @isTest static void testAlertTriggered () {

        // Implements test code
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        User accUser;
        User oppUser;
        Account acc;
        Opportunity opp1;

        System.runAs(thisUser) {
            accUser = TestObjectFactory.createTmkUser('accUser');
            oppUser = TestObjectFactory.createTmkUser('oppUser');
            insert oppUser;
            insert accUser;
            acc = TestObjectFactory.createAccount();
            acc.OwnerId = accUser.id;
            insert acc;

            opp1 = TestObjectFactory.createOpportunity(acc.Id, oppUser);
            insert opp1;
        }

        System.runAs(accUser) {
            acc.Postcode__c = '200053';
            update acc;

            List<Task> tasks = [SELECT Id, Subject, ActivityDate, Description__c, OwnerId
                                FROM Task WHERE OwnerId = :oppUser.Id];

            System.assert(tasks.size() == 1);
            for (Task ac: tasks) {
                System.assert(ac.OwnerId == oppUser.Id);
                System.assert(ac.Subject == '客户信息被改变');
                System.assert(ac.ActivityDate == system.today());
            }
        }

        Test.stopTest();
    }
}