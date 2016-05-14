/**************************************************************************************************
 * Name: AccountEducationListViewTest
 * Object: Account
 * Purpose: a test class for AccountEducationListView
 * Author:  ()
 * Create Date: 2016-05-11
 * Modified History: 
 * 2016-05-11 vicia wang   Writes comments in this format and add comments
***************************************************************************************************/
@isTest
private class AccountEducationListViewTest {

    // Tests the sucessful connect
    @isTest static void testAccountEducationSuccess() {
        Account acc = TestObjectFactory.createAccount('13200000001');

        // Inserts education schools
        Education__c education1 = TestObjectFactory.createEducation('1-1-1', acc);
        Education__c education2 = TestObjectFactory.createEducation('1-1-2', acc);

        // Inserts the endpoint
        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        CallOutMethod__c calloutmethodV1 = new CallOutMethod__c();
        calloutmethodV1.Name = 'PrepSmithAPIStagingCriteriaV1';
        calloutmethodV1.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethodV1;

        CallOutMethod__c calloutmethod1 = new CallOutMethod__c();
        calloutmethod1.Name = 'SchoolMultiUUID';
        calloutmethod1.EndPoint__c = 'http://testCallout/GetSchools/Success';
        insert calloutmethod1;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        Test.setCurrentPage(Page.AccountEducationListView);
        ApexPages.StandardController controller = new ApexPages.StandardController (acc);
        AccountEducationListView accEducation = new AccountEducationListView (controller);

        // Checks the school size
        System.assertEquals(2, accEducation.SchoolWraps.size());

        accEducation.deleteItem();

        // As we don't put the parameter, it will get the error
        System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                            ApexPages.getMessages(), 'Missing id at index: 0'));

        ApexPages.currentPage().getParameters().put('itemId', education1.Id);
        accEducation.deleteItem();

        // After executing the deletion, it will only keep 1
        System.assertEquals(1, accEducation.SchoolWraps.size());

        Test.stopTest();
    }

    // Tests the failed education
    @isTest static void testAccountEducationFailed () {
        User consulantAndy = TestObjectFactory.createUser();
        Account acc = TestObjectFactory.createAccount('13200000001');

        // Inserts education schools
        Education__c education1 = TestObjectFactory.createEducation('1-1-1', acc);
        Education__c education2 = TestObjectFactory.createEducation('1-1-2', acc);

        // Inserts interface endpoint
        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        CallOutMethod__c calloutmethodV1 = new CallOutMethod__c();
        calloutmethodV1.Name = 'PrepSmithAPIStagingCriteriaV1';
        calloutmethodV1.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethodV1;

        CallOutMethod__c calloutmethod1 = new CallOutMethod__c();
        calloutmethod1.Name = 'SchoolMultiUUID';
        calloutmethod1.EndPoint__c = 'http://testCallout/GetSchools/Failed';
        insert calloutmethod1;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        Test.setCurrentPage(Page.AccountEducationListView);
        ApexPages.StandardController controller = new ApexPages.StandardController (acc);
        AccountEducationListView accEducation = new AccountEducationListView (controller);

        // Calls this interface, it will not populate url value
        System.assertEquals(NULL, accEducation.SchoolWraps[0].url);
        System.assertEquals(NULL, accEducation.SchoolWraps[1].url);

        Test.stopTest();
    }
}