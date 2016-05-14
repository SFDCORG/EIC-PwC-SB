/**************************************************************************************************
 * Name: ViewlossOppsAppsControllerTest
 * Object: Account, Contact, Opportunity, Appoitment__c
 * Purpose: Test class for viewlossOppsAppsController.cls
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-11
 * Modify History:
 * 2016-05-11    Vicia Wang    Create this class
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
@isTest
private class ViewlossOppsAppsControllerTest {

    static testMethod void AccountQuickSearch() {
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

        Opportunity reviveopp = new Opportunity();
        reviveopp.CloseDate=System.today();
        reviveopp.name = 'test234';
        reviveopp.AccountId = acc.Id;
        reviveopp.sys_UnlockStage__c = true;  
        reviveopp.StageName = '顾问跟进';
        reviveopp.sys_UnlockStage__c = false;
        insert reviveopp;

        Opportunity o = new Opportunity();
        o.CloseDate = System.today();
        o.name = 'test123';
        o.AccountId = acc.Id;
        o.sys_UnlockStage__c = true;  
        o.StageName = '顾问跟进';
        o.sys_UnlockStage__c = false;
        o.Revive_Opportunity__c = reviveopp.Id;
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
            ProfileId = ProfileRelated.centerManger,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'standarduserrayuat1@testorg.com'
        );
        insert loginUser;

        Appoitment__c app = new Appoitment__c();
        app.Appointment_Type__c = '第5天任务';  
        app.Due_Date__c = System.today();
        app.Opportunity__c = o.Id;
        app.RecordTypeId = RecordTypeRelated.Assignment_App;
        app.Assign_To__c = loginUser.Id;
        app.Status__c = '未完成';
        insert app;

        Appoitment__c app2 = new Appoitment__c();
        app2.Appointment_Type__c = '第0天任务';  
        app2.Due_Date__c = System.today();
        app2.Opportunity__c = reviveopp.Id;
        app2.RecordTypeId = RecordTypeRelated.Assignment_App;
        app2.Assign_To__c = loginUser.Id;
        app2.Status__c = '未完成';
        insert app2; 

        test.StartTest();
        PageReference myVfPage = Page.viewLossOppApps;
        Test.setCurrentPageReference(myVfPage); // Use setCurrentPageReference, 
        ApexPages.currentPage().getParameters().put('ID', reviveopp.Id);
        viewlossOppsAppsController oppAssignC = new viewlossOppsAppsController(
            new ApexPages.StandardController(reviveopp));
        test.stopTest();
    }
}