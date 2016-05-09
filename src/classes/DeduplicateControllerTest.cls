/**************************************************************************************************
 * Name: DeduplicateControllerTest
 * Object: Lead, Lead_Item__c, Account, Contact_EIC__c, Opportunity
 * Purpose: a test class for phone search visualforce page function
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest
private class DeduplicateControllerTest {
    static testMethod void testPhoneSearch() {
        User user = TestObjectFactory.createUser();

        CallCenterChannelMap__c counsellingChannel = new CallCenterChannelMap__c(
        	Name = '62820990',
        	ChannelNum__c = '62820990',
        	ChannelType__c = 1);
        insert counsellingChannel;

        CallCenterChannelMap__c testprepChannel = new CallCenterChannelMap__c(
        	Name = '62820998',
        	ChannelNum__c = '62820998',
        	ChannelType__c = 2);
        insert testprepChannel;

        // Utils.runLeadTrigger = FALSE;
    	System.runAs(user) {
			List<Lead> leadList = new List<Lead>();

			Campaign BankofChina = TestObjectFactory.createCampaign(
				'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
			Campaign BankofSH = TestObjectFactory.createCampaign(
				'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

			Lead BOCSHlead = TestObjectFactory.createLead(
				BankofChina, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
			leadList.add(BOCSHlead);

			Lead BSHlead = TestObjectFactory.createLead(
				BankofSH, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
			leadList.add(BSHlead);
			insert leadList;

			for (Lead lead :leadList) {
				TestObjectFactory.createLeadItemList(lead);
			}

			Account acc = TestObjectFactory.createAccount('19099990000');

			PageReference convertPage = Page.Deduplicate;
			Test.setCurrentPage(convertPage);
			ApexPages.currentPage().getParameters().put('phone', '19099990000');
			ApexPages.currentPage().getParameters().put('callLogId', 'test0001');
			ApexPages.currentPage().getParameters().put('channel', '62820990');
			ApexPages.currentPage().getParameters().put('Type', '1');
			ApexPages.currentPage().getParameters().put('preNum', '021');
			ApexPages.currentPage().getParameters().put('ActivityId', '');
			ApexPages.currentPage().getParameters().put('batchId', '');

			DeduplicateController controller = new DeduplicateController();
			controller.initAction();

			List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
			
			controller.initAction();			
			controller.searchDuplication();
			controller.notifyOppOwners();
			controller.editLead();

			controller.channel = '62820998';
			controller.searchDuplication();
			controller.initAction();

			controller.customerNo = oppList[0].Id;
			controller.searchDuplication();
			controller.initAction();

			controller.phone = '19099990000';
			controller.searchDuplication();
			controller.initAction();
			controller.createLead();

			controller.phone = '19099990000';
			controller.searchDuplication();
			controller.initAction();
			controller.createLead();
		}
    }
}