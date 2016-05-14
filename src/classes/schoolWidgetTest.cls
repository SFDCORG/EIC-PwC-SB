/**************************************************************************************************
 * Name: schoolWidgetTest
 * Object: CallOutMethod__c
 * Purpose: Test class for SchoolWidget
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04   vicia.wang  Create this class
***************************************************************************************************/
@isTest
private class schoolWidgetTest {
	@isTest static void method() {
		CallOutMethod__c calloutmethod = new CallOutMethod__c();
    	calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
    	calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
    	insert calloutmethod;
    	

    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
    	schoolWidgetController ctl = new schoolWidgetController();
    	schoolWidgetController.getSchool('http://testCallout/SearchSchool');
    	Test.stopTest();
	}
}