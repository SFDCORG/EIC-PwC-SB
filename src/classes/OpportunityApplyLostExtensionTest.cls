/**************************************************************************************************
 * Name: OpportunityApplyLostExtensionTest
 * Object: Opportunity
 * Purpose: a test class for OpportunityApplyLostExtension
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-11
 * Modified History: 
 * 2016-05-11   vicia wang Writes comments in this format
***************************************************************************************************/
@isTest
private class OpportunityApplyLostExtensionTest {
    static testMethod void testOpportunityApplyLostExtension() {

    	User admin = TestObjectFactory.createUser();
    	// salesman has a wrong profile and can not validate the criteria
    	User salesman = TestObjectFactory.createUser();

    	Test.startTest();
    	Account acc = TestObjectFactory.createAccount('19011112222');
        Opportunity testprepOpp = TestObjectFactory.createTestprepOpportunity(acc);
        Opportunity studyAbroadOpp = TestObjectFactory.createCounsellingOpportunity(acc);
        studyAbroadOpp.Project__c = Constants.STUDY_ABROAD_CN + '-' + Constants.US_CN;
        update studyAbroadOpp;

    	PageReference applyLostPage = Page.OpportunityApplyLost;
    	Test.setCurrentPage(applyLostPage);
        // Validates the admin
        System.runAs(admin) {

	    	salesman.ProfileId = Constants.PROFILE_LOCAL_CS_ID;
    		update salesman;

        	// Validate non study abroad opportunity
        	ApexPages.StandardController testprepOppCon = new ApexPages.StandardController(testprepOpp);
        	OpportunityApplyLostExtension testprepOppApplyLostExt = new OpportunityApplyLostExtension(testprepOppCon);
        	String testprepOppApplyLostUrl = testprepOppApplyLostExt.applyLostPage().getUrl();
        	
        	System.assert(testprepOppApplyLostUrl.contains(Utils.getRecordTypeId('Approval_Log__c', 
        																	     'Opportunity Status')));

        	// Validates study abraod opportunity
        	ApexPages.StandardController studyAbroadOppCon = new ApexPages.StandardController(studyAbroadOpp);
        	OpportunityApplyLostExtension studyAbroadOppApplyLostExt = new OpportunityApplyLostExtension(studyAbroadOppCon);
        	String studyAbroadOppApplyLostUrl = studyAbroadOppApplyLostExt.applyLostPage().getUrl();
        	
        	System.assert(studyAbroadOppApplyLostUrl.contains(Utils.getRecordTypeId('Approval_Log__c', 
        																		    'Xueyou Opportunity Status')));	
        }

        // Validates the user role
        System.runAs(salesman) {

	        Opportunity counsellingOpp = TestObjectFactory.createCounsellingOpportunity(acc);
        	ApexPages.StandardController counsellingOppCon = new ApexPages.StandardController(counsellingOpp);
        	OpportunityApplyLostExtension counsellingOppApplyLostExt = new OpportunityApplyLostExtension(counsellingOppCon);
        	System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
        						ApexPages.getMessages(), OpportunityApplyLostExtension.INVALID_USER_FOR_APPLY_LOST));
        }

        // Updates the salesman to correct profile and correct role
        System.runAs(admin) {
        	salesman.ProfileId = Constants.PROFILE_SALES_MANAGER_ID;
    		salesman.UserRoleId = Constants.ROLE_SALES_SH_MANAGER_ID;
    		update salesman;

    		testprepOpp.OwnerId = salesman.Id;
    		testprepOpp.StageName = Constants.OPPORTUNITY_STAGE_CLOSED_WON;
    		update testprepOpp;
        }

    	// Validates the opportunity stage
    	System.runAs(salesman) {

        	ApexPages.StandardController testprepOppCon = new ApexPages.StandardController(testprepOpp);
        	OpportunityApplyLostExtension testprepOppApplyLostExt = new OpportunityApplyLostExtension(testprepOppCon);
        	
        	System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
        						ApexPages.getMessages(), OpportunityApplyLostExtension.INVALID_OPPORTUNITY_STAGE));
        }
        Test.stopTest();
    }
}