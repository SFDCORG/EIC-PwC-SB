@isTest
private class AccountEducationListViewTest {

    @isTest static void method() {
    	Account acct = new Account ();
    	acct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='EIC_Account' AND SObjectType='Account'].Id;
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

        // Insert education
        Education__c edu1 = new Education__c ();
        edu1.UUID_School__c = '1-1-1';
        edu1.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        edu1.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        edu1.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        edu1.Account__c = acct.Id;
        insert edu1;

        Education__c edu2 = new Education__c ();
        edu2.UUID_School__c = '1-1-2';
        edu2.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        edu2.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        edu2.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        edu2.Account__c = acct.Id;
        insert edu2;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
    	calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
    	calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
    	insert calloutmethod;

        CallOutMethod__c calloutmethod1 = new CallOutMethod__c ();
    	calloutmethod1.Name = 'SchoolMultiUUID';
    	calloutmethod1.EndPoint__c = 'http://testCallout/GetSchools/Success';
    	insert calloutmethod1;

    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        Test.setCurrentPage(Page.AccountEducationListView);
        ApexPages.StandardController sd = new ApexPages.StandardController (acct);
        AccountEducationListView ctl = new AccountEducationListView (sd);
        ctl.deleteItem();
        System.currentPageReference().getParameters().put('itemId', edu1.Id);
        ctl.deleteItem();
        Test.stopTest();
    }

     @isTest static void method1 () {
    	Account acct = new Account ();
    	acct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='EIC_Account' AND SObjectType='Account'].Id;
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

        // Inserts education
        Education__c edu1 = new Education__c ();
        edu1.UUID_School__c = '1-1-1';
        edu1.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        edu1.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        edu1.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        edu1.Account__c = acct.Id;
        insert edu1;

        Education__c edu2 = new Education__c ();
        edu2.UUID_School__c = '1-1-2';
        edu2.UUID_Major__c = '44418cc7-ef7b-4cf0-b3ec-baadffdf338f';
        edu2.UUID_Degree__c = 'dc5345e0-7020-4c39-995a-21fa76fcf7fc';
        edu2.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        edu2.Account__c = acct.Id;
        insert edu2;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
    	calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
    	calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
    	insert calloutmethod;

        CallOutMethod__c calloutmethod1 = new CallOutMethod__c ();
    	calloutmethod1.Name = 'SchoolMultiUUID';
    	calloutmethod1.EndPoint__c = 'http://testCallout/GetSchools/Failed';
    	insert calloutmethod1;

    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        Test.setCurrentPage(Page.AccountEducationListView);
        ApexPages.StandardController sd = new ApexPages.StandardController (acct);
        AccountEducationListView ctl = new AccountEducationListView (sd);
        Test.stopTest();
    }
}