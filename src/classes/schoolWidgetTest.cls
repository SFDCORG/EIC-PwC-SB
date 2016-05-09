@isTest
private class schoolWidgetTest {
	@isTest static void method(){
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