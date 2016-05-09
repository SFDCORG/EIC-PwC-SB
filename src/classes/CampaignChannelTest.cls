/**************************************************************************************************
 * Name: CampaignChannelTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class CampaignChannelTest {

    @isTest
    private static void testCampaignChannel () {
        Campaign_Channel__c cc = new Campaign_Channel__c ();
        cc.City__c = '上海';
        cc.Business_line__c = '考培';
        cc.Active__c = TRUE;
        cc.Marketing_Channel_Lv1__c = '合作招生';
        cc.Marketing_Channel_Lv2__c = '线下合作';
        cc.Marketing_Channel_Lv3__c = '招生代表';
        insert cc;

        Campaign_Channel__c cc1 = new Campaign_Channel__c ();
        cc1.City__c = '上海';
        cc1.Business_line__c = '考培';
        cc1.Marketing_Channel_Lv1__c = '合作招生';
        cc1.Marketing_Channel_Lv2__c = '线下合作';
        cc1.Marketing_Channel_Lv3__c = '招生代表';
        
        try {
            insert cc1;
        
        } catch (Exception e) {
            System.assertEquals(TRUE, e.getMessage().contains('已存在')); 
        }
        
        try {
            cc.Active__c = FALSE;
            update cc;
            insert cc1;
        
        } catch (Exception e) {
            System.assertEquals(TRUE, e.getMessage().contains('已存在')); 
        }
    }
}