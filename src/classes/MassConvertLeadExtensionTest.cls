/**************************************************************************************************
 * Name: MassConvertLeadExtensionTest
 * Object: Lead, Lead_Item__c, Appointment__c, Account, Opportunity
 * Purpose: a test class for mass convert lead Visualforce page function
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-27
 * Modified History: 
 * 2016-04-27    Vicia Wang    Writes comments in this format
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class MassConvertLeadExtensionTest {

    static testMethod void testMassConvertLead () {

        User user = createUser();
        shouldProcessRun__c avoidTrigger = new shouldProcessRun__c(
            Name = user.Id,
            IsDisable__c = TRUE);

        insert avoidTrigger;

        Utils.runLeadTrigger = FALSE;

        System.runAs(user) {

            List<Lead> leadList = new List<Lead>();
            Campaign BankofSH = TestObjectFactory.createCampaign(
                'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
            Campaign BankofBJ = TestObjectFactory.createCampaign(
                'BBJ', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BBJ');

            Lead SHLead1 = TestObjectFactory.createLead(
                BankofSH, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            SHLead1.QQ__c = 1020304050;
            SHLead1.Wechat__c = '1020304051';
            SHLead1.Email = '1020304052@email.com';
            leadList.add(SHLead1);

            Lead SHLead2 = TestObjectFactory.createLead(
                BankofSH, Constants.CITY_SH_CN, TRUE, '19099990001', '22220001');
            leadList.add(SHLead2);

            Lead SHLead3 = TestObjectFactory.createLead(
                BankofBJ, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            leadList.add(SHLead3);

            Lead BJlead = TestObjectFactory.createLead(
                BankofBJ, Constants.CITY_BJ_CN, TRUE, '19099990001', '11110000');
            leadList.add(BJlead);

            insert leadList;

            for (Lead lead :leadList) {
                TestObjectFactory.createLeadItemList(lead);
            }

            PageReference massConvertLeadPage = Page.ConsultantReferral;
            Test.setCurrentPage(massConvertLeadPage);

            ApexPages.StandardSetController massConvertNonSelect = new ApexPages.StandardSetController(leadList);
            MassConvertLeadExtension massConvertNonSelectSetCon = new MassConvertLeadExtension(massConvertNonSelect);
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), Constants.MASS_CONVERT_NO_ITEM_ERROR));

            ApexPages.StandardSetController massConvertStandardSetCon = new ApexPages.StandardSetController(leadList);
            massConvertStandardSetCon.setSelected(leadList);
            MassConvertLeadExtension massConvertSetCon = new MassConvertLeadExtension(massConvertStandardSetCon);

            massConvertSetCon.convertLeadItems();
            massConvertSetCon.getTotalItemNo();
            massConvertSetCon.getConvertedItemNo();
            massConvertSetCon.getIsConverted();
            massConvertSetCon.gotoAssginOpportunity();
        }
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