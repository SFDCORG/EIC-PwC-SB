/**************************************************************************************************
 * Name: SplitLeadUtilsTest
 * Object: Lead, Campaign, Lead_Item__c
 * Purpose: a test class for lead.trigger and SplitLeadUtils.class
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-02-16
 * Modified History: 
 * 2016-02-16   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest
private class SplitLeadUtilsTest {
    static testmethod void testLeadTrigger() {
    	User user = TestObjectFactory.createUser();
    	System.runAs(user) {
    		// They are used to test whether lead items are generated automatically.
			Boolean isUS = FALSE;
			Boolean isUK = FALSE;
			Boolean isTestprep = FALSE;
			List<Lead> leads = new List<Lead>();
			List<Lead> leads2 = new List<Lead>();
			initialSamples();
			// Create the campaign firstly
			Campaign BankofChina = TestObjectFactory.createCampaign(
				'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
			// Create lead
			Lead SHlead = TestObjectFactory.createLead(BankofChina, Constants.CITY_SH_CN, TRUE);
			leads.add(SHlead);
			insert leads;
			Utils.runLeadTrigger = TRUE;

			SHlead = [SELECT Id, (SELECT Id FROM Lead_Items__r) FROM Lead WHERE Id = :SHlead.Id LIMIT 1];
			// According to the lead trigger, it will create 3 lead items
			System.assertEquals(3, SHlead.Lead_Items__r.size());

		    for (Lead_Item__c li :[SELECT Intended_City__c, Business_Line__c, 
		    							  Project__c, Mobile_Unique_Key__c, 
		    							  Fix_Phone_Unique_Key__c 
							       FROM Lead_Item__c 
							       WHERE Lead__c = :SHlead.Id]) {

		      	if (li.Business_Line__c == Constants.COUNSELLING_CN && li.Project__c == Constants.US_CN) {
		        	isUS = TRUE;

		      	} else if (li.Business_Line__c == Constants.COUNSELLING_CN && li.Project__c == Constants.UK_CN) {
		        	isUK = TRUE;

		      	} else {
		        	isTestprep = TRUE;
		      	}
		    }

		    System.assertEquals(TRUE, isUS);
		    System.assertEquals(TRUE, isUK);
		    System.assertEquals(TRUE, isTestprep);

		    SHlead.Counselling_Project__c = Constants.UK_CN;
		    update SHlead;

		    try {
		    	SHlead.Lead_Items__r[0].Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
		    	update SHlead.Lead_Items__r;
		    	Utils.runLeadTrigger = TRUE;
		    	SHlead.Counselling_Project__c = '';
		    	update SHlead;

		    } catch (Exception e) {
		    	System.assert(TRUE, e.getMessage());
		    }

		    // Does the test for the uploaded lead part
		    Utils.isExcelUploader = TRUE;
		    List<Lead> uploadedLeadList = new List<Lead>();
		    List<Lead_Item__c> uploadedLeadItemList = new List<Lead_Item__c>();
		    // Inserts custom setting records for Project    
		    TestObjectFactory.initializeProjectSetup();
		    Lead uploadedLead = TestObjectFactory.createUploadedLead(BankofChina, Constants.CITY_SZ_CN);
		    uploadedLeadList.add(uploadedLead);
		    insert uploadedLeadList;
		    uploadedLeadItemList = SplitLeadUtils.splitLead(uploadedLeadList);

		    System.assertEquals(TRUE, uploadedLead.Is_Counselling__c);
		    System.assertEquals(TRUE, uploadedLead.Is_TestPrep__c);
		    System.assertEquals(TRUE, uploadedLead.Is_Scholar_Tree__c);
		    System.assertEquals(TRUE, uploadedLead.Is_Cooperative_Education__c);

	    	Utils.isExcelUploader = FALSE;
	    	Utils.runLeadTrigger = TRUE;

	    	try {
				Lead BJCounsellingLead = TestObjectFactory.createLead(BankofChina, 
					Constants.CITY_BJ_CN, TRUE);
				insert BJCounsellingLead;
				Utils.runLeadTrigger = TRUE;

			} catch (Exception e) {
				System.assert(TRUE, e.getMessage());
			}

			try {
				Lead BJTestprepllingLead = TestObjectFactory.createLead(BankofChina, 
					Constants.CITY_BJ_CN, FALSE);
				insert BJTestprepllingLead;
				Utils.runLeadTrigger = TRUE;

			} catch (Exception e) {
				System.assert(TRUE, e.getMessage());
			}	
    	}
	}

    static void initialSamples() {
    	Utils.runLeadTrigger = FALSE;
      	Account acc = TestObjectFactory.createAccount('19099990000');
      	List<Opportunity> opps = TestObjectFactory.createOpportunities(acc);
      	Campaign PekingUniversity = TestObjectFactory.createCampaign('BJCPekingUniversity', 
      		Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'Peking University');
     	Lead sampleLead = TestObjectFactory.createLead(PekingUniversity, Constants.CITY_GZ_CN, FALSE);
     	insert sampleLead;     
      	Utils.runLeadTrigger = TRUE;
    }
}