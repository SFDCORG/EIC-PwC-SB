@isTest
private class IntendedSchoolListViewTest {

     @isTest static void method() {

        Account acct = new Account ();
        acct.RecordTypeId = [SELECT Id
                             FROM RecordType 
                             WHERE DeveloperName = 'EIC_Account'
                             AND SObjectType = 'Account'].Id;

        acct.Name = 'test001';
        acct.ID_Type__c = null;
        insert acct;
        Contact_EIC__c c2 = new Contact_EIC__c ();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c = '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;

        Opportunity opp = new Opportunity ();
        opp.RecordTypeId = [SELECT Id
                            FROM RecordType
                            WHERE DeveloperName = 'TestPrep'
                            AND SObjectType = 'Opportunity'].Id;

        opp.Name = 'testopp001';
        opp.AccountId = acct.Id;
        opp.StageName = '顾问跟进';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = system.today();
        insert opp;

        //insert education
        Intended_School__c sch1 = new Intended_School__c ();
        sch1.UUID_School__c = '1-1-1';
        sch1.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        sch1.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        sch1.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        sch1.Opportunity__c = opp.Id;
        insert sch1;

        Intended_School__c sch2 = new Intended_School__c ();
        sch2.UUID_School__c = '1-1-2';
        sch2.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        sch2.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        sch2.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        sch2.Opportunity__c = opp.Id;
        insert sch2;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        CallOutMethod__c calloutmethod1 = new CallOutMethod__c ();
        calloutmethod1.Name = 'SchoolMultiUUID';
        calloutmethod1.EndPoint__c = 'http://testCallout/GetSchools/Success';
        insert calloutmethod1;

        Test.startTest ();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        test.setCurrentPage(Page.IntendedSchoolListView);
        system.currentPageReference().getParameters().put ('Id',opp.Id);
        ApexPages.StandardController sd = new ApexPages.StandardController (opp);
        IntendedSchoolListViewController ctl = new IntendedSchoolListViewController (sd);
        ctl.deleteItem();
        System.currentPageReference().getParameters().put ('itemId', sch1.Id);
        ctl.deleteItem();
        Test.stopTest ();
    }

     @isTest static void method1 () {

        Account acct = new Account ();
        acct.RecordTypeId = [SELECT Id
                             FROM RecordType
                             WHERE DeveloperName = 'EIC_Account'
                             AND SObjectType = 'Account'].Id;

        acct.Name = 'test001';
        acct.ID_Type__c = null;
        insert acct;

        Contact_EIC__c c2 = new Contact_EIC__c ();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c= '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;

        Opportunity opp = new Opportunity ();

        opp.RecordTypeId = [SELECT Id
                            FROM RecordType
                            WHERE DeveloperName = 'TestPrep'
                            AND SObjectType = 'Opportunity'].Id;

        opp.Name = 'testopp001';
        opp.AccountId = acct.Id;
        opp.StageName = '顾问跟进';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = system.today();
        insert opp;

        // Inserts education
        Intended_School__c sch1 = new Intended_School__c ();
        sch1.UUID_School__c = '1-1-1';
        sch1.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        sch1.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        sch1.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        sch1.Opportunity__c = opp.Id;
        insert sch1;

        Intended_School__c sch2 = new Intended_School__c ();
        sch2.UUID_School__c = '1-1-2';
        sch2.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        sch2.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        sch2.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        sch2.Opportunity__c = opp.Id;
        insert sch2;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        CallOutMethod__c calloutmethod1 = new CallOutMethod__c ();
        calloutmethod1.Name = 'SchoolMultiUUID';
        calloutmethod1.EndPoint__c = 'http://testCallout/GetSchools/Failed';
        insert calloutmethod1;

        Test.startTest ();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        test.setCurrentPage(Page.IntendedSchoolListView);
        system.currentPageReference().getParameters().put ('Id', opp.Id);
        ApexPages.StandardController sd = new ApexPages.StandardController (opp);
        IntendedSchoolListViewController ctl = new IntendedSchoolListViewController (sd);
        Test.stopTest ();
    }
}