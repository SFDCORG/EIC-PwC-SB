/**************************************************************************************************
 * Name: JiaowuRenewRESTfulTest
 * Object: Lead, Lead_Item__c, Account, Contact_EIC__c, Opportunity
 * Purpose: a test class for Jiaowu renew interface
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-03
 * Modified History: 
 * 2016-05-03   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest
private class JiaowuRenewRESTfulTest {
    static testMethod void testJiaowuRenewRESTfulByMobile() {
        User user = createUser();
        Utils.runLeadTrigger = FALSE;

        Test.startTest();
        System.runAs(user) {
            shouldProcessRun__c avoidTrigger = new shouldProcessRun__c(
                Name = user.Id,
                IsDisable__c = TRUE);        
            insert avoidTrigger;

            Account acc = TestObjectFactory.createAccount('19011110000');
            Opportunity opp = TestObjectFactory.createTestprepOpportunity(acc);

            Campaign BankofSH = TestObjectFactory.createCampaign(
                'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
            Lead BSHlead = TestObjectFactory.createLead(
                BankofSH, Constants.CITY_SH_CN, TRUE, '19011110000', '22220000');
            insert BSHlead;
            TestObjectFactory.createLeadItemList(BSHlead);
            Utils.runLeadTrigger = TRUE;

            List<JiaowuRenewRESTful.Renew> renews = new List<JiaowuRenewRESTful.Renew>();
            JiaowuRenewRESTful.Renew renew = new JiaowuRenewRESTful.Renew();
           	
           	renew.Student_Phone = '19011110000';
           	renew.SA_Phone = '18012345678';
           	renew.SA_Email = 'SA@eic.com.test';
           	renew.Desire_Content_IDs = 'GRE;SAT';
           	renew.Desire_City_Name = Constants.CITY_BJ_CN;
           	renew.Desire_Area_Name = 'People Square';
           	renew.Memo = 'Test Renew Function';
            renews.add(renew);

            // Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/CRM/Jiaowu/JiaowuRenewRESTful/*';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            String result = '';
            
            try {
            	result = JiaowuRenewRESTful.doPost(renews);	
            
            // Checks if the system has the old client
            } catch (Exception e) {
            	System.assertEquals(TRUE, e.getMessage().contains(Label.Jiaowu_Renew_Error0));
            }

            renew.CRM_Student_ID = acc.Id;
            try {            	
            	result = JiaowuRenewRESTful.doPost(renews);
            
            // Checks if the system has the old opportunity
            } catch (Exception e) {
            	System.assertEquals(TRUE, e.getMessage().contains(Label.Jiaowu_Renew_Error1));
            }


            renew.CRM_Opportunity_ID = opp.Id;
            try {
            	result = JiaowuRenewRESTful.doPost(renews);	
            
            // Checks if the system has the closed won opportunity
            } catch (Exception e) {
            	System.assertEquals(TRUE, e.getMessage().contains(Label.Jiaowu_Renew_Error2));
            }
            
            opp.StageName = Constants.OPPORTUNITY_STAGE_CLOSED_WON;
            update opp;
            try {
            	result = JiaowuRenewRESTful.doPost(renews);	
            
            // Checks if the system has Jiaowu SA Consultant Referral campaign
            } catch (Exception e) {
            	System.assertEquals(TRUE, e.getMessage().contains(Label.Jiaowu_Renew_Error3));
            }            

            Campaign oldCustomerReferralCampaign = TestObjectFactory.createCampaign(
            	Constants.TESTPREP_SA_REFERRAL_CN, Constants.TESTPREP_CN, 
            	Constants.REFERRAL_CN, Constants.TESTPREP_SA_REFERRAL_CN,
            	Constants.TESTPREP_SA_REFERRAL_CN);

            try {
            	result = JiaowuRenewRESTful.doPost(renews);
                Utils.runLeadTrigger = TRUE;

            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, '*** e: ' + e);
            	System.assertEquals(TRUE, e.getMessage().contains(Constants.CONSULTANT_REFERRAL_SCHEDULING_TABLE_ERROR));
            }            

            // Creates the org, scheduling table, scheduing table line
            Organization__c org = TestObjectFactory.createOrg(Constants.CITY_BJ_CN, 'Testprep', Constants.TESTPREP_CN);
            insert org;
            Scheduling_Table__c testprepTable = TestObjectFactory.createSchedulingTable(org, 'Testprep');
            insert testprepTable;
            Scheduling_Table_Line__c testprepTableLine = TestObjectFactory.createSchedulingTableLine(testprepTable);
            insert testprepTableLine;
            
            try {
            	result = JiaowuRenewRESTful.doPost(renews);
                System.debug(LoggingLevel.INFO, '*** result: ' + result);
            	System.assertEquals(TRUE, result.contains(Label.Jiaowu_Renew_Successful));            	

            } catch (Exception e) {
            	
            }
        }
        Test.stopTest();
    }

    // In order to avoid "UNABLE_TO_LOCK_ROW"
    public static User createUser() {
        // Gets admin profile
        Profile adminProfile = [SELECT Id 
                                FROM Profile 
                                WHERE Name = 'System Administrator' 
                                LIMIT 1];
        User user = new User(
            Email = 'test@eic.com.test',
            Lastname = 'Test',
            ProfileId = adminProfile.Id,
            Username = String.valueOf(System.Math.random()) + '@eic.com.test',
            Alias = String.valueOf(System.Math.random()).subString(0, 8),
            EmailenCodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_GB',
            TimezonesIdKey = 'America/Los_Angeles',
            CompanyName = 'EIC');

        insert user;

        return user;
    }
}