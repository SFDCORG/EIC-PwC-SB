/**************************************************************************************************
 * Name: DuplicatedAccountsViewControllerTest
 * Object: Lead, Lead_Item__c
 * Purpose: a test class for searching duplicated account by mobile/fixed phone
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-05
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class DuplicatedAccountsViewControllerTest {

    static testMethod void testDuplicatedAccountsViewController () {

        User user = createUser();
        Utils.runLeadTrigger = FALSE;

        System.runAs(user) {

            List<Lead> leadList = new List<Lead> ();

            Campaign BankofChina = TestObjectFactory.createCampaign(
                'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

            Lead SHlead = TestObjectFactory.createLead(
                BankofChina, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            leadList.add(SHlead);
            insert leadList;

            for (Lead lead :leadList) {

                TestObjectFactory.createLeadItemList(lead);
            }

            Account acc = TestObjectFactory.createAccount('19099990000');
            Opportunity opp = TestObjectFactory.createTestprepOpportunity(acc);

            PageReference duplicatedAccountViewPage = Page.DuplicatedAccountsView;
            Test.setCurrentPage(duplicatedAccountViewPage);
            ApexPages.StandardController SHLeadCon = new ApexPages.StandardController (SHlead);
            DuplicatedAccountsViewController SHInitialController = new DuplicatedAccountsViewController (SHLeadCon);

            System.assertEquals(1, SHInitialController.dupOpps.size()); 
        }
    }

    // In order to avoid "UNABLE_TO_LOCK_ROW"
    public static User createUser () {

        // Gets admin profile
        Profile adminProfile = [SELECT Id
                                FROM Profile
                                WHERE Name = 'System Administrator' OR 
                                      Name = :Constants.SYSTEM_ADMIN_PROFILE_CN
                                LIMIT 1];

        User user = new User(
            Email = 'test@eic.com.test',
            Lastname = 'Test',
            ProfileId = adminProfile.Id,
            Username = String.valueOf(System.now().getTime()) +
                       String.valueOf(System.Math.random()) +
                       '@eic.com.test',
            Alias = String.valueOf(System.now().getTime()).subString(0, 8),
            EmailenCodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_GB',
            TimezonesIdKey = 'America/Los_Angeles',
            CompanyName = 'EIC',
            Sage_UserName__c = 'SAGE Username',
            Paike_UserName__c = 'Jiaowu Username');

        insert user;

        return user;
    }
}