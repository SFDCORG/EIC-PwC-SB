@isTest
private class NewCampaignTest {
    @isTest
    private static void testNewCampaign(){
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
        cc4.Marketing_Channel_Lv2__c = 'PC端';
        cc4.Marketing_Channel_Lv3__c = '百度';
        ccList.add(cc4);
        insert ccList;

        Test.startTest();

        Campaign campaign = new Campaign();
        NewCampaignV2Ext ext = new NewCampaignV2Ext(new ApexPages.StandardController(campaign));
        campaign.Name = '2015年12月PC百度品专UAT';
        campaign.StartDate = System.today();
        campaign.EndDate = System.today().addDays(30);
        campaign.Approver__c = UserInfo.getUserId();
        campaign.City__c = '集团';
        campaign.Business_line__c = '全部';
        campaign.Marketing_Channel_Lv1__c = '线上';
        campaign.Marketing_Channel_Lv2__c = 'PC端';
        campaign.Marketing_Channel_Lv3__c = '百度';
        ext.save();
        ext.cancel();

        Test.stopTest();

        // dml exception
        List<Campaign> campaignList = [SELECT Name FROM Campaign];
        System.assertEquals(0, campaignList.size());
    }

    @isTest
    private static void testEditCampaign(){
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

        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Level_4_Promotion_Channel' LIMIT 1];

        Test.startTest();

        Campaign campaign = new Campaign();
        campaign.RecordTypeId = rt.Id;
        campaign.Name = '2015年12月PC百度品专UAT';
        campaign.StartDate = System.today();
        campaign.EndDate = System.today().addDays(30);
        campaign.Approver__c = UserInfo.getUserId();
        campaign.City__c = '集团';
        campaign.Business_line__c = '全部';
        campaign.Marketing_Channel_Lv1__c = '线上';
        campaign.Marketing_Channel_Lv2__c = 'PC端';
        campaign.Marketing_Channel_Lv3__c = '百度';
        campaign.IsActive = true;
        insert campaign;

        ApexPages.currentPage().getParameters().put('id', campaign.Id);
        NewCampaignV2Ext ext = new NewCampaignV2Ext(new ApexPages.StandardController(campaign));
        ext.campaign.Name = '2015年12月PC百度品专UAT2';
        ext.save();
        ext.cancel();

        Test.stopTest();

        // success
        List<Campaign> campaignList = [SELECT Name FROM Campaign];
        System.assertEquals(1, campaignList.size());
        System.assertEquals('2015年12月PC百度品专UAT2', campaignList[0].Name);
    }
}