@isTest
private class updateExpriedInvAppToNoVisitidtTest {
    @testSetup static void setup() {  
        Account acc = new Account();
        acc.Name = 'AccQuickSearch';
        insert acc;

        Contact_EIC__c contat  = new Contact_EIC__c();
        contat.isPrimary__c = true;
        contat.Name = 'test';
        contat.Contact_Type__c = '手机';
        contat.Account__c = acc.Id;
        contat.Relationship__c = 'OneSelf';
        contat.UniqueContact__c = '13671999387';
        insert contat;

        Opportunity o = new Opportunity();
        o.CloseDate = System.today();
        o.name = 'test';
        o.AccountId = acc.Id;
        o.sys_UnlockStage__c = true;  
        o.StageName = '顾问跟进';
        o.sys_UnlockStage__c = false;
        insert o;

        OpportunityTeamMember oppMember = new OpportunityTeamMember();
        oppMember.OpportunityId = o.Id;
        oppMember.UserId = userinfo.getUserId();
        oppMember.TeamMemberRole = 'Team Member';
        insert oppMember;

        User loginUser = new User(
            Alias = 'stadndt', 
            Email = 'standarduse1r@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId  = ProfileRelated.centerManger,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'standarduserrayuat1@testorg.com'
        );
        insert loginUser;

        Appoitment__c app2 = new Appoitment__c();
        Date dt = System.today();
        app2.Appointment_Type__c = '首次到访';  
        app2.Due_Date__c = dt.addDays(-1);
        app2.Due_Time__c = '08:00';
        app2.Opportunity__c = o.Id;
        app2.RecordTypeId = RecordTypeRelated.Invitation_App;
        app2.Assign_To__c = loginUser.Id;
        app2.Status__c = '跟进中';
        insert app2;    
    }

    static testMethod void AccountQuickSearch() {
        test.startTest();
        updateExpriedInvAppToNoVisitid_sch sch = new  updateExpriedInvAppToNoVisitid_sch();
        string schTime = '0 10 * * 1-12 ? *';
        system.schedule('Synch Twitter 2', schTime,sch);
        test.stopTest();
    }
}