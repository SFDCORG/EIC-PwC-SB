/**************************************************************************************************
 * Name: ResourceExchangeControllerTest
 * Object: Lead, Lead_Item__c, Appointment__c, Account, Opportunity
 * Purpose: a test class for converting lead Visualforce page function
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-27
 * Modified History: 
 * 2016-04-27   Vicia Wang  Writes comments in this format
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class ResourceExchangeControllerTest {

    static testMethod void testResourceExchange() {

        User runUser = TestObjectFactory.createUser();
        User TMKAgent = TestObjectFactory.insertTMKUser();

        Utils.runLeadTrigger = FALSE;
        System.runAs(runUser) {
            shouldProcessRun__c avoidTrigger = new shouldProcessRun__c(Name = runUser.Id,
                                                                       IsDisable__c = TRUE);
            
            insert avoidTrigger;

            Campaign BankofChina = TestObjectFactory.createCampaign(
                'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

            // Sets the resource exchange campaign
            Campaign resourceExchangeCampaign = TestObjectFactory.createCampaign(
                Constants.CAMP_RESOURCE_EXCHANGE_GROUP_NAME, 'All', Constants.REFERRAL_CN, Constants.REFERRAL_CN, Constants.REFERRAL_CN);
            Campaign_Channel__c cc1 = TestObjectFactory.createCampaignChannel();
            insert cc1;
            Campaign_Channel__c cc2 = TestObjectFactory.createGzCoopCampaignChannel();
            insert cc2;

            Account acc1 = TestObjectFactory.createAccount('19011112222', '02162628383');
            List<Opportunity> oppList1 = TestObjectFactory.createOpportunities(acc1);
            List<Opportunity> counsellingOppList = TestObjectFactory.createOpportunities(acc1);
            for (Opportunity opp : oppList1) {
                opp.Level_4_Promotion_Channel__c = BankofChina.Id;
                if (opp.Name.contains('counselling')) {
                    counsellingOppList.add(opp);
                }
            }
            update oppList1;
            delete counsellingOppList;

            PageReference resourceExchangePage = Page.ResourceExchange;
            Test.setCurrentPage(resourceExchangePage);
            ResourceExchangeController controller = new ResourceExchangeController();

            controller.searchOpp();

            // Checks whether user choose at least one business line or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Choose_One_BL_Opp));

            controller.hasCounsellingOpps = TRUE;
            controller.selectedCounsellingOppProject = Constants.US_CN;
            controller.searchOpp();

            // Checks whether user choose at least one business line to create lead or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Choose_One_BL_To_Create_Leads));

            controller.hasTestprepOpps = TRUE;
            controller.selectedTestprepOppProject = 'SAT';
            controller.selectedNewBusinessLine = 
                System.Label.Counselling + ',' + System.Label.Testprep + ',' + System.Label.Cooperative;
            controller.searchOpp();

            // Checks whether user choose testprep opportunity and also wants to create testprep lead or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_No_TP_Leads_for_TP_Acc));

            controller.hasTestprepOpps = FALSE;
            controller.selectedTestprepOppProject = '';
            controller.selectedNewBusinessLine = System.Label.Cooperative;
            controller.hasCooperativeOpps = TRUE;
            controller.selectedCooperativeOppProject = Constants.COOPERATIVE_PROJECT_CN;
            controller.searchOpp();

            // Checks whether user choose cooperative opportunity and also wants to create cooperative lead or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_No_Coop_Leads_for_Coop_Acc));

            controller.hasCounsellingOpps = FALSE;
            controller.selectedNewBusinessLine = System.Label.Counselling;
            controller.selectedIntendCity = Constants.CITY_BJ_CN;
            controller.selectedOppStage  = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN;
            controller.selectedCampaignSource = BankofChina.Id;
            controller.selectedConsultMode = Constants.F2F_CONSULTING_CN;
            controller.filterLead.Birthday__c = System.Today() - 5;
            controller.filterLead.Schedule_Abroad_Year__c = System.Today() - 10;
            controller.searchOpp();

            // Checks whether user inputs the valid start date or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Start_Date_Before_End_Date));

            controller.filterLead.Birthday__c = NULL;
            controller.filterLead.Schedule_Abroad_Year__c = System.Today() - 10;
            controller.searchOpp();

            // Checks whether user inputs the valid start date or not
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), System.Label.Error_Entre_valid_date_range));

            controller.filterLead.Birthday__c = System.Today() - 5;
            controller.filterLead.Schedule_Abroad_Year__c = NULL;
            controller.searchOpp();

            controller.filterLead.Birthday__c = System.Today() - 5;
            controller.filterLead.Schedule_Abroad_Year__c = System.Today() + 5;
            controller.searchOpp();

            for (Integer i = 0; i < controller.acctWraps.size(); i ++) {
                controller.acctWraps[i].isselected = TRUE;
            }
            controller.createLeads();
            controller.getConsultMode();
            controller.getCounsellingOppProjectList();
            controller.getTestprepOppProjectList();
            controller.getCooperativeOppProjectList();
            controller.getBusinessLineList();
            controller.getIncOrExcOptions();
            controller.getselectedCampaignItems();
            controller.getSelectedConsultModeVal();
            controller.getSelectedCounsellingOppProjectVal();
            controller.getSelectedCooperativeOppProjectVal();
            controller.getSelectedTestprepOppProjectVal();
            controller.getSelectedNewBusinessLineVal();
            controller.getIntendCity();
            controller.getSelectedIntendCityVal();
            controller.getProject();
            controller.getSelectedProjectVal();
            controller.getOppStage();
            controller.getSelectedOppStageVal();
            controller.gettestprepSize();
            controller.getcounsellingSize();
            controller.getcooperativeSize();
            controller.getacctSize();
            controller.changeLeadPerPage();
            controller.next();
            controller.previous();
            controller.homePage();
            controller.endPage();
            controller.getTotal();
            controller.getCurrentPageNo();
            controller.getTotalPageNo();
            controller.getNextEnable();
            controller.getPreviousEnable();
            controller.clearCounsellingProjects();
            controller.clearTestprepProjects();
            controller.clearCooperativeProjects();
            controller.getPageSizePerPage();
            controller.lv1 = '线下';
            controller.lv2 = '户外推广';
            controller.getLv2ByLv1();
            controller.getLv3ByLv1Lv2();

            List<User> userList = ResourceExchangeController.searchUser('%@eic.com.test%', UserInfo.getUserId());
            System.assertEquals(1, userList.size());

            String param = '{"lv1":"Offline","lv2":"Business Cooperation","lv3":"BSH","term":"BOC"}';
            List<Campaign> campaignList = ResourceExchangeController.searchCampaign(param, resourceExchangeCampaign.Id);
            System.assertEquals(1, campaignList.size());
        }
    }
}