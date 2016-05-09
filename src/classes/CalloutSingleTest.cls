/**************************************************************************************************
 * Name: CalloutSingleTest
 * Object: Lead
 * Purpose: Does the test for call out single class
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class CalloutSingleTest {

    static testMethod void testCalloutSingle() {

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'CallOutSingle';
        calloutmethod.EndPoint__c = 'http://testCallout/SingleCall/Success';
        insert calloutmethod;

        Campaign BankofChina = TestObjectFactory.createCampaign(
                'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

        Lead BOCSHlead = TestObjectFactory.createLead(
                BankofChina, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');       
        insert BOCSHlead;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        String callOutStr = '{"phone":"19099990000",' + '"idstr":"' + BOCSHlead.Id + '"}';
        CalloutUtil.SingleCallout(callOutStr);
        Test.setCurrentPage(Page.CallOutInline);
        ApexPages.StandardController sd = new ApexPages.StandardController (BOCSHlead);
        CalloutUtil callCon = new CalloutUtil (sd);

        CallOutSingle.send(BOCSHlead.MobilePhone, BOCSHlead.Id);
        Test.stopTest();
    }
}