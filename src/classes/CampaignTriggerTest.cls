/**************************************************************************************************
 * Name: CampaignTriggerTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class CampaignTriggerTest {

    @isTest static void method () {

        Campaign cam = TestObjectFactory.createCampaign('百度测试', '全部', 'SNS', '集团', '官方微博');
        cam.Status = '草稿';
        update cam;
        cam.Status = '审批通过';
        update cam;

        Id recordTypeId = Utils.getRecordTypeId('Campaign', 'Subagent');
        Campaign camp = new Campaign(Name = '下级代理测试',
                                     RecordTypeId = recordTypeId,
                                     City__c = '北京',
                                     Business_Line__c = '留学',
                                     Marketing_Channel_Lv1__c = '下级代理',
                                     Marketing_Channel_Lv2__c = '下级代理',
                                     Marketing_Channel_Lv3__c = '下级代理',
                                     Status = '审批通过',
                                     IsActive = TRUE);
        insert camp;
        camp.Status = '草稿';
        update camp;
        camp.Status = '审批通过';
        update camp;
    }
}