/**************************************************************************************************
 * Name: NewLeadTest
 * Object: Lead, Lead_Item__c
 * Purpose: a test class for NewLeadV2Ext function
 * Author: Tcool Ma ()
 * Create Date: 
 * Modified History: 
 * 2016-05-07   Vicia Wang Writes comments in this format
 * 2016-05-07   Vicia optimize the class
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class NewLeadTest {

    @isTest
    private static void testNewLeadReferralNoReferralCampaign() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();

        Test.setCurrentPage(Page.NewLeadV2);
        Lead lead = new Lead();
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        ApexPages.currentPage().getParameters().put('isReferral', 'true');
        NewLeadV2Ext newLeadPageController = new NewLeadV2Ext(sc);

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for (Apexpages.Message msg:msgs) {
            if (msg.getDetail().contains(System.Label.Error_No_Customer_Referral_Campaign)) b = true;
        }
        System.assert(b);
        Test.stopTest();
    }

    @isTest
    private static void testNewCoopLeadMissingProjectsWrongCity () {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Campaign_Channel__c channel;
        Campaign campaign;
        User tmkUser;

        System.runAs(thisUser) {

            tmkUser = TestObjectFactory.createTmkUser('tmkUser');
            insert tmkUser;

            channel = TestObjectFactory.createCampaignChannel();
            insert channel;

            campaign = TestObjectFactory.createCoopCampaign(channel);
            insert campaign;
        }

        Test.startTest();

        System.runAs(tmkUser) {

            Test.setCurrentPage(Page.NewLeadV2);
            Lead lead = new Lead();
            ApexPages.StandardController sc = new ApexPages.StandardController(lead);
            NewLeadV2Ext newLeadPageController = new NewLeadV2Ext(sc);

            lead.LastName = 'Haha';
            lead.Is_TestPrep__c = true;
            lead.Is_Counselling__c = true;
            lead.Is_Cooperative_Education__c = true;
            lead.Intended_City__c = '上海';

            newLeadPageController.mPhone = '13700010002';
            newLeadPageController.lead = lead;
            PageReference pRef = newLeadPageController.save();

            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean a = false;
            boolean b = false;
            boolean c = false;
            boolean d = false;
            for (Apexpages.Message msg:msgs) {

                if (msg.getDetail().contains(System.Label.Error_No_Projects_For_Counselling)) a = true;
                if (msg.getDetail().contains(System.Label.Error_No_Projects_For_Testprep)) b = true;
                if (msg.getDetail().contains(System.Label.Error_No_Projects_For_Coop)) c = true;
                if (msg.getDetail().contains(System.Label.Error_Not_Coop_City)) d = true;
            }
            System.assert(a && b && c && d);

            lead.Cooperative_Education_Project__c = '学术英语;国际预科';
            lead.Counselling_Project__c = '美国;加拿大';
            lead.TestPrep_Project__c = 'SAT,GRE';

            newLeadPageController.lead = lead;
            pRef = newLeadPageController.save();
        }
        Test.stopTest();
    }


    @isTest
    private static void testNewCoopLeadSuccess () {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Campaign_Channel__c channel;
        Campaign campaign;
        User tmkUser;

        System.runAs(thisUser) {
          tmkUser = TestObjectFactory.createTmkUser('tmkUser');
          insert tmkUser;

          channel = TestObjectFactory.createCampaignChannel();
          insert channel;

          campaign = TestObjectFactory.createCoopCampaign(channel);
          insert campaign;
        }

        Test.startTest();

        System.runAs(tmkUser) {
            Test.setCurrentPage(Page.NewLeadV2);
            Lead lead = new Lead();
            ApexPages.StandardController sc = new ApexPages.StandardController(lead);
            NewLeadV2Ext newLeadPageController = new NewLeadV2Ext(sc);

            lead.LastName = 'Haha';
            lead.Is_TestPrep__c = true;
            lead.Is_Counselling__c = true;
            lead.Is_Cooperative_Education__c = true;
            lead.Intended_City__c = '广州';
            lead.Cooperative_Education_Project__c = '学术英语;国际预科';
            lead.Counselling_Project__c = '美国;加拿大';
            lead.TestPrep_Project__c = 'SAT,GRE';
            lead.Company = 'EIC';
            lead.Status = '全未转化-新建';
            lead.Campaign__c = campaign.Id;
            lead.Consultation_Mode__c = '集团TMK外呼';

            newLeadPageController.mPhone = '13700010002';
            newLeadPageController.lead = lead;
            PageReference pRef = newLeadPageController.save();
            lead.Id = [SELECT Id FROM Lead WHERE LastName = 'Haha'][0].Id;

            // Verify that the URL returned matches the ID of the newly created lead
            System.Assert(pRef.getUrl().contains(lead.Id));

            // Verify that 4 lead items were created
            List<Lead_Item__c> leadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                            FROM Lead_Item__c
                                            WHERE Lead__c = :lead.Id];

            System.AssertEquals(leadItems.size(), 4);
            System.debug(leadItems);

            // Verify that a Canada Counselling lead item was created
            List<Lead_Item__c> canadaLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c, Intended_Country__c
                                                  FROM Lead_Item__c
                                                  WHERE Lead__c = :lead.Id 
                                                  AND Business_Line__c = '留学' 
                                                  AND Intended_Country__c = '加拿大'];

            System.AssertEquals(canadaLeadItems.size(), 1);
            System.AssertEquals(canadaLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(canadaLeadItems[0].Project__c, '加拿大');

            // Verify that a USA Counselling lead item was created
            List<Lead_Item__c> usaLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c, Intended_Country__c 
                                               FROM Lead_Item__c
                                               WHERE Lead__c = :lead.Id 
                                               AND Business_Line__c = '留学' 
                                               AND Intended_Country__c = '美国'];

            System.AssertEquals(usaLeadItems.size(), 1);
            System.AssertEquals(usaLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(usaLeadItems[0].Project__c, '美国');

            // Verify that 1 testprep lead item was created and verify that it is as expected
            List<Lead_Item__c> testprepLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                    FROM Lead_Item__c
                                                    WHERE Lead__c = :lead.Id 
                                                    AND Business_Line__c = '考培'];

            System.AssertEquals(testprepLeadItems.size(), 1);
            System.AssertEquals(testprepLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(testprepLeadItems[0].Project__c, 'SAT,GRE');

            // Verify that 1 cooperative lead item was created and verify that it is as expected
            List<Lead_Item__c> coopLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                FROM Lead_Item__c
                                                WHERE Lead__c = :lead.Id
                                                AND Business_Line__c = '合作办学'];

            System.AssertEquals(coopLeadItems.size(), 1);
            System.AssertEquals(coopLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(coopLeadItems[0].Project__c, '学术英语;国际预科');
        }
        Test.stopTest();
    }

    @isTest
    private static void testNewLead () {

        Campaign campaign1 = new Campaign();
        campaign1.Name = '2015年10月上海百度竞价A';
        campaign1.StartDate = System.today();
        campaign1.EndDate = System.today().addDays(30);
        campaign1.Approver__c = UserInfo.getUserId();
        campaign1.Marketing_Channel_Lv1__c = '线上';
        campaign1.Marketing_Channel_Lv2__c = 'PC';
        campaign1.Marketing_Channel_Lv3__c = '百度';
        insert campaign1;

        FollowupResultSetting__c frs1 = new FollowupResultSetting__c();
        frs1.Name = '400';
        frs1.Permission__c = 'Required';
        insert frs1;

        ConsultationModeMapping__c cmm1 = new ConsultationModeMapping__c();
        cmm1.Name = '01';
        cmm1.Role_Name__c = '前台';
        cmm1.Consultation_Mode__c = '面询';
        insert cmm1;

        Lead lead = new Lead();

        Test.startTest();

        Test.setCurrentPage(Page.NewLeadV2);
        ApexPages.currentPage().getParameters().put('id', '');
        ApexPages.currentPage().getParameters().put('project', '留学');
        ApexPages.currentPage().getParameters().put('CallLogId', '123456');
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        NewLeadV2Ext newLead = new NewLeadV2Ext(sc);
        newLead.campaignId = campaign1.Id;
        newlead.lead.LastName = 'TestLead';
        newLead.lead.Is_Counselling__c = true;
        newlead.lead.Is_TestPrep__c = true;
        newLead.lead.Counselling_Project__c = '美国';
        newlead.lead.TestPrep_Project__c = '雅思';
        newLead.campaignName = campaign1.Name;
        newLead.consultationMode = '面询';
        newLead.save();
        newLead.clearCounselling();
        newLead.clearTestPrepProject();
        newLead.cancel();
        newLead.getFollowupResultSetting();
        newLead.getConsultationModes();

        Test.stopTest();

        // dml exception
        List<Lead> leadList = [SELECT LastName FROM Lead];
        System.assertEquals(0, leadList.size());
    }

    @isTest
    private static void testEditLead () {

        Campaign campaign1 = new Campaign();
        campaign1.Name = '2015年10月上海百度竞价A';
        campaign1.StartDate = System.today();
        campaign1.EndDate = System.today().addDays(30);
        campaign1.Approver__c = UserInfo.getUserId();
        campaign1.Marketing_Channel_Lv1__c = '线上';
        campaign1.Marketing_Channel_Lv2__c = 'PC';
        campaign1.Marketing_Channel_Lv3__c = '百度';
        insert campaign1;

        FollowupResultSetting__c frs1 = new FollowupResultSetting__c();
        frs1.Name = '400';
        frs1.Permission__c = 'Required';
        insert frs1;

        ConsultationModeMapping__c cmm1 = new ConsultationModeMapping__c();
        cmm1.Name = '01';
        cmm1.Role_Name__c = '前台';
        cmm1.Consultation_Mode__c = '面询';
        insert cmm1;

        Lead lead = new Lead();
        lead.Campaign__c = campaign1.Id;
        lead.Company = 'EIC';
        lead.Status = '全未转化-新建';
        lead.LastName = 'A';
        lead.MobilePhone = '13585779272';
        lead.Consultation_Mode__c = '面询';
        lead.Intended_City__c = '广州';
        lead.Is_TestPrep__c = true;
        insert lead;

        Test.startTest();

        Test.setCurrentPage(Page.NewLeadV2);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        NewLeadV2Ext newLead = new NewLeadV2Ext(sc);
        newLead.lead.LastName = 'B';
        newLead.save();

        Test.stopTest();

        // dml exception
        List<Lead> leadList = [SELECT LastName FROM Lead];
        System.assertEquals(1, leadList.size());
        System.assertEquals('A', leadList[0].LastName);
    }

    @isTest
    private static void testLookupCampaign() {

        User customerServiceMgr = TestObjectFactory.createCustomerManager();

        List<Campaign> campaignList = new List<Campaign>();
        Campaign campaign1 = new Campaign();
        campaign1.Name = '上海留学百度竞价';
        campaign1.IsActive = TRUE;
        campaign1.StartDate = System.today();
        campaign1.EndDate = System.today().addDays(30);
        campaign1.Approver__c = UserInfo.getUserId();
        campaign1.Marketing_Channel_Lv1__c = '线上';
        campaign1.Marketing_Channel_Lv2__c = 'PC';
        campaign1.Marketing_Channel_Lv3__c = '百度';
        campaign1.Status = '审批通过';
        campaignList.add(campaign1);
        insert campaignList;

        Campaign BankofChina = TestObjectFactory.createCampaign(
                Constants.CITY_SH_CN + 'BOC', Constants.COUNSELLING_CN, Constants.OFFLINE_CN, 'Business Cooperation', 'BSH');

        List<Campaign_Channel__c> ccList = new List<Campaign_Channel__c>();
        Campaign_Channel__c cc1 = new Campaign_Channel__c();
        cc1.City__c = '集团';
        cc1.Business_line__c = '全部';
        cc1.Marketing_Channel_Lv1__c = '合作招生';
        cc1.Marketing_Channel_Lv2__c = '线下合作';
        cc1.Marketing_Channel_Lv3__c = '市场合作';
        ccList.add(cc1);

        Campaign_Channel__c cc2 = new Campaign_Channel__c();
        cc2.City__c = '集团';
        cc2.Business_line__c = '全部';
        cc2.Marketing_Channel_Lv1__c = 'SNS';
        cc2.Marketing_Channel_Lv2__c = '集团';
        cc2.Marketing_Channel_Lv3__c = '官方微信';
        ccList.add(cc2);

        Campaign_Channel__c cc3 = new Campaign_Channel__c();
        cc3.City__c = '集团';
        cc3.Business_line__c = '全部';
        cc3.Marketing_Channel_Lv1__c = 'SNS';
        cc3.Marketing_Channel_Lv2__c = '集团';
        cc3.Marketing_Channel_Lv3__c = '官方微博';
        ccList.add(cc3);

        Campaign_Channel__c cc4 = new Campaign_Channel__c();
        cc4.City__c = '上海';
        cc4.Business_line__c = '留学';
        cc4.Marketing_Channel_Lv1__c = '线上';
        cc4.Marketing_Channel_Lv2__c = 'PC';
        cc4.Marketing_Channel_Lv3__c = '百度';
        ccList.add(cc4);
        insert ccList;

        Test.startTest();
        System.runAs(customerServiceMgr) {

            LookupCampaignCtrl lookupCampaign = new LookupCampaignCtrl();
            lookupCampaign.searchTextCity = '上海';
            lookupCampaign.searchCampaign();

            lookupCampaign.searchTextBusinessLine = '留学';
            lookupCampaign.searchTextOther = '百度';
            lookupCampaign.searchCampaign();
            lookupCampaign.lv1 = '线上';
            lookupCampaign.lv2 = 'PC';
            lookupCampaign.lv3 = '百度';
            lookupCampaign.searchCampaignByFilters();
            lookupCampaign.getLv2ByLv1();
            lookupCampaign.getLv3ByLv1Lv2();
        }        

        Test.stopTest();
    }

    @isTest
    private static void testLookupRecommendAccount () {

        Account acc = TestObjectFactory.createAccount('13598904758', '02130305656');
        Opportunity testprepOpp = TestObjectFactory.createTestprepOpportunity(acc);
        testprepOpp.StageName = Constants.OPPORTUNITY_STAGE_CLOSED_WON;
        update testprepOpp;

        test.startTest();

        LookupRecommendAccountCtrl ctrl = new LookupRecommendAccountCtrl();
        ctrl.searchText = '*Account';
        ctrl.searchType = 'AccountName';
        ctrl.searchAccount();

        ctrl.searchText = '13598904758';
        ctrl.searchType = 'AccountContact';
        ctrl.searchAccount();

        test.stopTest();
    }

    @isTest
    private static void testGroupServiceReferral() {

        User tmkUser = TestObjectFactory.createUser();
        Campaign BankofChina = TestObjectFactory.createCampaign(
            'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
        Campaign groupServiceCampaign = TestObjectFactory.createCampaign(
            Constants.CAMP_CUSTOMER_REFERRAL_GROUP_NAME, 'All', 
            Constants.REFERRAL_CN, Constants.CAMP_CUSTOMER_REFERRAL_GROUP_NAME, 
            Constants.CAMP_CUSTOMER_REFERRAL_GROUP_NAME);

        Lead BOCSHlead = TestObjectFactory.createLead(
            BankofChina, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');

        Account acc = TestObjectFactory.createAccount('19099990000', '02122220000');
        Opportunity testprepOpp = TestObjectFactory.createTestprepOpportunity(acc);

        PageReference newLead = Page.NewLeadV2;
        Test.setCurrentPage(newLead);        

        ApexPages.currentPage().getParameters().put('mobile', '19099990000');
        ApexPages.currentPage().getParameters().put('areacode', '021');
        ApexPages.currentPage().getParameters().put('phone', '22220000');
        ApexPages.currentPage().getParameters().put('city', Constants.CITY_BJ_CN);
        ApexPages.currentPage().getParameters().put('name', 'BOCSHlead Test');
        ApexPages.currentPage().getParameters().put('referralType', 'YES');
        ApexPages.currentPage().getParameters().put('isReferral', 'TRUE');
        ApexPages.currentPage().getParameters().put('consultantmode', Constants.F2F_CONSULTING_CN);
        ApexPages.currentPage().getParameters().put('project', Constants.TESTPREP_CN);
        ApexPages.currentPage().getParameters().put('CallLogId', 'HLCallLog0001');

        ApexPages.StandardController pageController = new ApexPages.StandardController(BOCSHlead);
        NewLeadV2Ext controller = new NewLeadV2Ext(pageController);
        controller.lead.Is_TestPrep__c = TRUE;
        controller.lead.TestPrep_Project__c = 'SAT';
        controller.recommendAccountId = acc.Id;

        try {

            controller.save();
        
        } catch (Exception e) {
            System.assertEquals(TRUE, e.getMessage().contains(Constants.TESTPREP_CN));
        }

        controller.clearProjectsAndCheckCities();
        controller.gotoduplicatePhoneAccount();
    }
}