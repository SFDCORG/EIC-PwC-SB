/**************************************************************************************************
 * Name: ConsultantReferralExtensionTest
 * Object: Lead, Lead_Item__c, Appointment__c, Account, Opportunity
 * Purpose: a test class for consultant referral Visualforce page function
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-26
 * Modified History: 
 * 2016-04-26   Vicia Wang Writes comments in this format
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class ConsultantReferralExtensionTest {

    static testMethod void testConsultantReferral () {

        User user = TestObjectFactory.createUser();
        shouldProcessRun__c avoidTrigger = new shouldProcessRun__c (Name = user.Id, IsDisable__c = TRUE);

        insert avoidTrigger;

        System.runAs(user) {

            Campaign BankofSH = TestObjectFactory.createCampaign(
                'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

            Campaign oldCustomerReferralCampaign = TestObjectFactory.createCampaign(
                Constants.OLD_CUSTOMER_REFERRAL_CN,
                Constants.COUNSELLING_CN,
                Constants.REFERRAL_CN,
                Constants.OLD_CUSTOMER_REFERRAL_CN,
                Constants.OLD_CUSTOMER_REFERRAL_CN);

            Campaign admissionRepresentativeCampaign = TestObjectFactory.createCampaign(
                Constants.ADMISSIONS_REPRESENTATIVE_CN,
                Constants.TESTPREP_CN,
                Constants.COOPERATIVE_ADMISSIONS_CN,
                Constants.ADMISSIONS_REPRESENTATIVE_CN,
                Constants.ADMISSIONS_REPRESENTATIVE_CN);

            Lead BSHlead = TestObjectFactory.createLead(BankofSH, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            insert BSHlead;

            TestObjectFactory.createLeadItemList(BSHlead);

            PageReference consultantReferralPage = Page.ConsultantReferral;
            Test.setCurrentPage(consultantReferralPage);

            // Consultant Referral
            Utils.runLeadTrigger = TRUE;
            Account accWithoutContacts = TestObjectFactory.createAccount('19099990002');
            delete [SELECT Id 
                    FROM Contact_EIC__c 
                    WHERE Account__c = :accWithoutContacts.Id];

            ApexPages.StandardController referralStandardCon = new ApexPages.StandardController(accWithoutContacts);
            ConsultantReferralExtension conNoContacts = new ConsultantReferralExtension(referralStandardCon);

            // Checks whether the account has correct contacts or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Phone));

            Account acc = TestObjectFactory.createAccount('19099990000');
            TestObjectFactory.createContact(acc, '0218888888');
            ApexPages.StandardController referralStandardConNoOpp = new ApexPages.StandardController(acc);
            ConsultantReferralExtension conNoOpp = new ConsultantReferralExtension(referralStandardConNoOpp);

            // Checks whether the current user has opportunity within the account or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Opportunities));

            conNoOpp.confirmConvert();

            // Checks whether the current user has opportunity within the account or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Opportunities));

            // There are no opportunities and then inserts opportunities
            List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);

            ConsultantReferralExtension projectChecExt = new ConsultantReferralExtension(referralStandardConNoOpp);
            projectChecExt.LeadVar.Counselling_Project__c = '';
            projectChecExt.LeadVar.Is_Counselling__c = TRUE;
            projectChecExt.confirmConvert();
            // Checks whether the current user can do the counselling referral with no country
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Counselling_Countries));

            // Resets the values
            projectChecExt.LeadVar.Is_Counselling__c = FALSE;

            projectChecExt.LeadVar.TestPrep_Project__c = '';
            projectChecExt.LeadVar.Is_TestPrep__c = TRUE;
            projectChecExt.confirmConvert();
            // Checks whether the current user can do the testprep referral with no project
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Testprep_Projects));

            // Resets the values
            projectChecExt.LeadVar.Is_TestPrep__c = FALSE;

            projectChecExt.LeadVar.Cooperative_Education_Project__c = '';
            projectChecExt.LeadVar.Is_Cooperative_Education__c = TRUE;
            projectChecExt.confirmConvert();
            // Checks whether the current user can do the cooperative referral with no project
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Coop_Projects));

            for (Integer i = 0; i < oppList.size(); i ++) {

                oppList[i].Level_4_Promotion_Channel__c = oldCustomerReferralCampaign.Id;
            }

            update oppList;

            // Sets lead item the relationship with opportunity so as to get the opportunity first campaign
            List<Lead_Item__c> leadItemList = new List<Lead_Item__c> ();
            for (Lead_Item__c li :[SELECT Opportunity__c
                                   FROM Lead_Item__c
                                   WHERE Lead__c = :BSHlead.Id]) {

                li.Opportunity__c = oppList[1].Id;
                leadItemList.add(li);
            }
            update leadItemList;
            Utils.runLeadTrigger = TRUE;

            ConsultantReferralExtension controller = new ConsultantReferralExtension (referralStandardConNoOpp);

            controller.leadVar.Is_Testprep__c = TRUE;
            controller.leadVar.Testprep_Project__c = 'SAT';
            controller.leadVar.Intended_City__c = Constants.CITY_BJ_CN;
            controller.leadVar.Intended_Office__c = 'People Square';
            controller.confirmConvert();

            // Checks whether the consultant referral meets the second referral condition
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), Constants.CONSULTANT_REFERRAL_WITH_OPEN_OPP_ERROR));

            
            // Sets the opportunity campaign as Admission Reprensentative campaign
            for (Integer i = 0; i < oppList.size(); i ++) {
                oppList[i].Level_4_Promotion_Channel__c = admissionRepresentativeCampaign.Id;
            }

            update oppList;

            controller.confirmConvert();

            // Checks whether the consultant referral meets the second referral condition
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), Constants.CONSULTANT_REFERRAL_WITH_OPEN_OPP_ERROR));
            
            // Sets the opportunity campaign
            for (Integer i = 0; i < oppList.size(); i ++) {
                oppList[i].Level_4_Promotion_Channel__c = BankofSH.Id;
            }

            update oppList;

            controller.confirmConvert();

            // Checks whether the second referral is successful or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Consultant_Referral_Success_2nd));

            controller.confirmConvert();

            // Checks whether the second referral for a second time
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), Constants.CONSULTANT_REFERRAL_SECOND_ERROR));

            // Deletes the testprep opportunity so as to do the first referral
            delete [SELECT Id 
                    FROM Opportunity
                    WHERE AccountId = :acc.Id
                    AND RecordType.Name = 'Testprep'];

            controller.confirmConvert();

            // Checks whether the system has the consultant referral campaign or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Consultant_Referral_No_Cross_Sales_Campaign));

            // Inserts the consultant referral campaign
            Campaign consultantReferralCampaign = TestObjectFactory.createCampaign(
                Constants.CONSULTANT_REFERRAL_CN, 
                Constants.COUNSELLING_CN, 
                Constants.REFERRAL_CN, 
                Constants.CONSULTANT_REFERRAL_CN, 
                Constants.CONSULTANT_REFERRAL_CN);

            // Creates the org, scheduling table, scheduling table line
            Organization__c org = TestObjectFactory.createOrg(Constants.CITY_BJ_CN, 'Testprep', Constants.TESTPREP_CN);
            insert org;

            Scheduling_Table__c testprepTable = TestObjectFactory.createSchedulingTable(org, 'Testprep');
            insert testprepTable;

            Scheduling_Table_Line__c testprepTableLine = TestObjectFactory.createScheTableLine(testprepTable);
            insert testprepTableLine;

            controller.confirmConvert();
            controller.refresh();
            controller.clearNonCounsellingProjects();
            controller.clearNonTestprepProjects();
            controller.clearNonCoopProjects();
            controller.clearCounsellingProjects();
            controller.clearTestPrepProjects();
            controller.clearCoopProjects();
            controller.resetIsTestprep();
            controller.clearAllProjects();
            controller.cancel();

            controller.leadVar.Is_Testprep__c = FALSE;
            controller.leadVar.Is_Counselling__c = TRUE;
            controller.leadVar.Counselling_Project__c = Constants.UK_CN;
            controller.leadVar.Intended_City__c = Constants.CITY_GZ_CN;
            controller.confirmConvert();
        }
    }
}