@isTest
private class AppointmentTriggerTest {

    @isTest static void testTmkAppointment7DaysRule1() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        User tmkUser1;
        User tmkUser2;
        Account acc;
        Opportunity opp;

        System.runAs(thisUser) {
            tmkUser1 = TestObjectFactory.createTmkUser('tmkUser1');
            insert tmkUser1;
            tmkUser2 = TestObjectFactory.createTmkManager('tmkUser2');
            insert tmkUser2;
            acc = TestObjectFactory.createAccount();
            insert acc;
            opp = TestObjectFactory.createOpportunity(acc.Id, tmkUser1);
            insert opp;
        }

        Appoitment__c tmkApp1 = new Appoitment__c(Due_Date__c = system.today(),
                                                  CreatedDate = system.today() - 2,
                                                  Due_Time__c = '09:00',
                                                  RecordTypeID = Constants.APP_RT_INVITATION_ID,
                                                  Assign_To__c = tmkUser1.Id,
                                                  Status__c= '跟进中',
                                                  Opportunity__c = opp.Id,
                                                  Description__c = 'hey hey',
                                                  Duration__c = '1',
                                                  CreatedBy = tmkUser1,
                                                  OwnerId = tmkUser1.Id,
                                                  TMKAppStatus__c = '未到访');

        Appoitment__c tmkApp2 = new Appoitment__c(Due_Date__c = system.today(),
                                                  CreatedDate = system.today() - 1,
                                                  Due_Time__c = '10:00',
                                                  RecordTypeID = Constants.APP_RT_INVITATION_ID,
                                                  Assign_To__c = tmkUser2.Id,
                                                  Status__c= '跟进中',
                                                  Opportunity__c = opp.Id,
                                                  Description__c = 'hooo hey',
                                                  Duration__c = '1',
                                                  CreatedBy = tmkUser2,
                                                  OwnerId = tmkUser2.Id,
                                                  TMKAppStatus__c = '未到访');

        Appoitment__c tmkApp3 = new Appoitment__c(Due_Date__c = system.today(),
                                                  CreatedDate = system.today() - 1,
                                                  Due_Time__c = '09:00',
                                                  RecordTypeID = Constants.APP_RT_INVITATION_ID,
                                                  Assign_To__c = tmkUser1.Id,
                                                  Status__c= '跟进中',
                                                  Opportunity__c = opp.Id,
                                                  Description__c = 'hooo hoooo',
                                                  Duration__c = '1',
                                                  CreatedBy = tmkUser1,
                                                  OwnerId = tmkUser1.Id,
                                                  TMKAppStatus__c = '未到访',
                                                  Appointment_Type__c = '首次到访邀约');

        System.runAs(tmkUser1) {
            insert tmkApp1;
            System.AssertNotEquals(tmkApp1.Id, null);
            tmkApp1 = [SELECT IsDuplicated1__c FROM Appoitment__c WHERE Id = :tmkApp1.Id];
            System.AssertEquals(tmkApp1.isDuplicated1__c, false);
        }

        /*
        TMK A create an invitation for a opportunity, within 7days ,TMK B can't create appointment for this opportunity
        - Click"New invitation" on opportunity page
        TMK B can't create new invitation within 7days of TMK A's invitation create date.
        Error msg: 已有其他同事7天内邀约，请勿重复创建。
        */
        System.runAs(tmkUser2) {
            try {
                insert tmkApp2;
                System.AssertEquals(tmkApp2.Id, null);
            } catch(Exception e) {
                Boolean expectedExceptionThrown = 
                    e.getMessage().contains(System.Label.Tmk7DayInvitationErrorMessage) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                System.AssertEquals(tmkApp2.Id, null);
            }
        }

        /*
         TMK A create an invitation for a opportunity, and if he creates a new apppiontment for the same opportunity,
         then  the previous appointment will be auto updated to invalid
         - Click"New invitation" on opportunity page
         if the previous invitation is in follow up (:跟进中or 未到访），update:
         1, status: 再约
         2，客服邀约状态：已失效
        */
        System.runAs(tmkUser1) {
            tmkApp1 = [SELECT TMKAppStatus__c, Status__c FROM Appoitment__c WHERE Id = :tmkApp1.Id];
            System.AssertNotEquals(tmkApp1.TMKAppStatus__c, '已失效');
            System.AssertNotEquals(tmkApp1.Status__c, '再约');
            insert tmkApp3;

            System.AssertNotEquals(tmkApp3.Id, null);
            tmkApp3 = [SELECT IsDuplicated1__c FROM Appoitment__c WHERE Id = :tmkApp3.Id];
            tmkApp1 = [SELECT TMKAppStatus__c, Status__c FROM Appoitment__c WHERE Id = :tmkApp1.Id];
            System.AssertEquals(tmkApp3.IsDuplicated1__c, true);
            System.AssertEquals(tmkApp1.TMKAppStatus__c, '已失效');
            System.AssertEquals(tmkApp1.Status__c, '再约');
        }
        Test.stopTest();
    }

    @isTest static void testTmkAppointment7DaysRule2() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        User tmkUser1;
        User tmkUser2;
        Account acc;
        Opportunity opp;

        System.runAs(thisUser) {
            tmkUser1 = TestObjectFactory.createTmkUser('tmkUser1');
            insert tmkUser1;
            tmkUser2 = TestObjectFactory.createTmkManager('tmkUser2');
            insert tmkUser2;
            acc = TestObjectFactory.createAccount();
            insert acc;
            opp = TestObjectFactory.createOpportunity(acc.Id, tmkUser1);
            insert opp;
        }

        Appoitment__c tmkApp1 = new Appoitment__c(Due_Date__c = system.today(),
                                                  CreatedDate = system.today() - 9,
                                                  Due_Time__c = '09:00',
                                                  RecordTypeID = Constants.APP_RT_INVITATION_ID,
                                                  Assign_To__c = tmkUser1.Id,
                                                  Status__c= '跟进中',
                                                  Opportunity__c = opp.Id,
                                                  Description__c = 'hey hey',
                                                  Duration__c = '1',
                                                  CreatedBy = tmkUser1,
                                                  OwnerId = tmkUser1.Id,
                                                  TMKAppStatus__c = '未到访');

        Appoitment__c tmkApp2 = new Appoitment__c(Due_Date__c = system.today(),
                                                  CreatedDate = system.today() - 1,
                                                  Assign_To__c = tmkUser2.Id,
                                                  Due_Time__c = '10:00',
                                                  RecordTypeID = Constants.APP_RT_INVITATION_ID,
                                                  Status__c= '跟进中',
                                                  Opportunity__c = opp.Id,
                                                  Description__c = 'hooo hey',
                                                  Duration__c = '1',
                                                  OwnerId = tmkUser2.Id,
                                                  TMKAppStatus__c = '未到访');

        /*
         TMK A create an invitation for a opportunity, after 7days ,TMK B can create appointment for this opportunity
         - Click"New invitation" on opportunity page
         If TMK A's invitation is in follow up (:跟进中or 未到访），update:
         1, status: 再约
         2，客服邀约状态：已失效
        */
        System.runAs(tmkUser1) {
            insert tmkApp1;
        }
        System.runAs(tmkUser2) {
            insert tmkApp2;
        }

        tmkApp1 = [SELECT Id, TMKAppStatus__c, Status__c
                   FROM Appoitment__c
                   WHERE Id = :tmkApp1.Id];
        System.AssertEquals(tmkApp1.TMKAppStatus__c, '已失效');
        System.AssertEquals(tmkApp1.Status__c, '再约');
        Test.stopTest();
    }
}