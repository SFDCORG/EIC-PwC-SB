@isTest
private class OpportunityTMKChangeOwnerTest {
	
    @isTest static void method(){
    	test.startTest();
    	Account acct = new Account();
    	acct.RecordTypeId = [Select Id From RecordType Where DeveloperName='EIC_Account' And SObjectType='Account'].Id;
    	acct.Name = 'test001';
    	acct.ID_Type__c = null;
    	insert acct;
    	Contact_EIC__c c2 = new Contact_EIC__c();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c= '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;
        Opportunity opp= new Opportunity();
        opp.RecordTypeId = [Select Id From RecordType Where DeveloperName='TestPrep' And SObjectType='Opportunity'].Id;
        opp.Name = 'testopp001';
        opp.AccountId = acct.Id;
        opp.StageName = '顾问跟进';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = system.today();
        insert opp;

        test.setCurrentPage(Page.OpportunityTMKChangeOwner);
        system.currentPageReference().getParameters().put('Id',opp.Id);
        ApexPages.StandardController sd = new ApexPages.StandardController(opp);
        OpportunityTMKChangeOwnerCtl ctl = new OpportunityTMKChangeOwnerCtl(sd);
        ctl.newOwnerID = UserInfo.getUserId();
        ctl.AssignOpp();
        ctl.cancel();

        ctl.opp.Id = null;
        ctl.AssignOpp();

        test.stopTest();

    }
}