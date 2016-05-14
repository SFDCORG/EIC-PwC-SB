/**************************************************************************************************
 * Name: JiaowuReferralRESTfulTest
 * Object: Lead, Lead_Item__c, Account, Contact_EIC__c, Opportunity
 * Purpose: a test class for Jiaowu referral interface
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-29
 * Modified History: 
 * 2016-04-29    Vicia Wang    Writes comments in this format
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class JiaowuReferralRESTfulTest {

    static testMethod void testJiaowuReferralRESTful() {
        User user = createUser();
        Utils.runLeadTrigger = FALSE;

        Test.startTest();
        System.runAs(user) {
            shouldProcessRun__c avoidTrigger = new shouldProcessRun__c(Name = user.Id,
                                                                       IsDisable__c = TRUE);
            insert avoidTrigger;

            Account acc = TestObjectFactory.createAccount('19011110002');
            Campaign BankofSH = TestObjectFactory.createCampaign(
                'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
            Lead BSHlead = TestObjectFactory.createLead(
                BankofSH, Constants.CITY_SH_CN, TRUE, '19011110001', '22220000');
            insert BSHlead;
            TestObjectFactory.createLeadItemList(BSHlead);
            Utils.runLeadTrigger = TRUE;

            List<JiaowuReferralRESTful.Referral> referrals = new List<JiaowuReferralRESTful.Referral> ();
            JiaowuReferralRESTful.Referral referral = new JiaowuReferralRESTful.Referral ();
            referral.Student_Name = 'Student A';
            referral.Student_Phone = '19011110001';
            referral.Desire_Content_IDs = 'GRE;SAT';
            referral.Desire_City_Name = Constants.CITY_SH_CN;
            referral.Desire_Area_Name = 'People Square';
            referral.Employee_User_Name = 'SA Andy Username';
            referral.Employee_Name = 'SA Andy name';
            referral.Creator_User_Name = 'Creator Judy Username';
            referral.Creator_Name = 'Creator Judy Name';
            referral.Memo = 'Test';
            referrals.add(referral);

            // Does request
            RestRequest req = new RestRequest (); 
            RestResponse res = new RestResponse ();
            req.requestURI = '/services/apexrest/CRM/Jiaowu/JiaowuReferralRESTful/*';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            String result = '';
            result = JiaowuReferralRESTful.doPost(referrals);

            // Sets the existed account
            referral.CRM_Student_ID = acc.Id;
            result = JiaowuReferralRESTful.doPost(referrals);

            Campaign oldCustomerReferralCampaign = TestObjectFactory.createCampaign(
                    Constants.OLD_CUSTOMER_REFERRAL_CN, Constants.COUNSELLING_CN, Constants.REFERRAL_CN, Constants.OLD_CUSTOMER_REFERRAL_CN, Constants.OLD_CUSTOMER_REFERRAL_CN);

            // Creates the org, scheduling table, scheduling table line
            Organization__c org = TestObjectFactory.createOrg(Constants.CITY_SH_CN, 'Testprep', Constants.TESTPREP_CN);
            insert org;
            Scheduling_Table__c testprepTable = TestObjectFactory.createSchedulingTable(org, 'Testprep');
            insert testprepTable;
            Scheduling_Table_Line__c testprepTableLine = TestObjectFactory.createSchedulingTableLine(testprepTable);
            insert testprepTableLine;
            
            result = JiaowuReferralRESTful.doPost(referrals);
            Utils.runLeadTrigger = TRUE;

            List<JiaowuReferralRESTful.Referral> BJReferrals = new List<JiaowuReferralRESTful.Referral> ();
            JiaowuReferralRESTful.Referral BJReferral = new JiaowuReferralRESTful.Referral ();
            BJReferral.Student_Name = 'Student A';
            BJReferral.CRM_Student_ID = acc.Id;
            BJReferral.Student_Phone = '19011110002';
            BJReferral.Desire_Content_IDs = 'GRE;SAT';
            BJReferral.Desire_City_Name = Constants.CITY_BJ_CN;
            BJReferral.Desire_Area_Name = 'People Square';
            BJReferral.Employee_User_Name = 'SA Andy Username';
            BJReferral.Employee_Name = 'SA Andy name';
            BJReferral.Creator_User_Name = 'Creator Judy Username';
            BJReferral.Creator_Name = 'Creator Judy Name';
            BJReferral.Memo = 'Test';
            BJReferrals.add(BJReferral);

            // Creates the org, scheduling table, scheduling table line
            Organization__c BJorg = TestObjectFactory.createOrg(Constants.CITY_BJ_CN, 'Testprep', Constants.TESTPREP_CN);
            insert BJorg;

            Scheduling_Table__c BJTestprepTable = TestObjectFactory.createSchedulingTable(BJorg, 'Testprep');
            insert BJTestprepTable;

            Scheduling_Table_Line__c BJTestprepTableLine = TestObjectFactory.createSchedulingTableLine(BJTestprepTable);
            insert BJTestprepTableLine;

            result = JiaowuReferralRESTful.doPost(BJReferrals);
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
        User user = new User(Email = 'test@eic.com.test',
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