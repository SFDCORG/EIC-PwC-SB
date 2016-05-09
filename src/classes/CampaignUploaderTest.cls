/**************************************************************************************************
 * Name: CampaignUploaderTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class CampaignUploaderTest {

    @isTest
    private static void testUploadCampaign () {
        User approver = new User (
            Alias = 'tma',
            Email = 'tcool.ma@cnsdc01.pwc.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '系统管理员'].Id, 
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test@eic.com');
        insert approver;

        List<Campaign_Channel__c> ccList = new List<Campaign_Channel__c> ();
        Campaign_Channel__c cc1 = new Campaign_Channel__c ();
        cc1.City__c = '集团';
        cc1.Business_line__c = '全部';
        cc1.Marketing_Channel_Lv1__c = '合作招生';
        cc1.Marketing_Channel_Lv2__c = '线下合作';
        cc1.Marketing_Channel_Lv3__c = '市场合作';
        ccList.add(cc1);

        Campaign_Channel__c cc2 = new Campaign_Channel__c ();
        cc2.City__c = '集团';
        cc2.Business_line__c = '全部';
        cc2.Marketing_Channel_Lv1__c = 'SNS';
        cc2.Marketing_Channel_Lv2__c = '集团';
        cc2.Marketing_Channel_Lv3__c = '官方微信';
        ccList.add(cc2);

        Campaign_Channel__c cc3 = new Campaign_Channel__c ();
        cc3.City__c = '集团';
        cc3.Business_line__c = '全部';
        cc3.Marketing_Channel_Lv1__c = 'SNS';
        cc3.Marketing_Channel_Lv2__c = '集团';
        cc3.Marketing_Channel_Lv3__c = '官方微博';
        ccList.add(cc3);
        insert ccList;

        Test.startTest();

        String data = '{"市场推广":"","参考数据":[{"city":"集团","businessLine":"全部","marketingChannelLv1":"线上","marketingChannelLv2":"PC端","marketingChannelLv3":"百度"},{"marketingChannelLv3":"360"},{"marketingChannelLv3":"搜狗"},{"marketingChannelLv3":"谷歌"},{"marketingChannelLv3":"留学专搜"},{"marketingChannelLv3":"网站合作"},{"marketingChannelLv3":"其他展示类广告"},{"marketingChannelLv2":"移动端","marketingChannelLv3":"百度"},{"marketingChannelLv3":"360"},{"marketingChannelLv3":"搜狗"},{"marketingChannelLv3":"神马搜索"},{"marketingChannelLv3":"谷歌"},{"marketingChannelLv3":"其他展示类广告"},{"marketingChannelLv3":"微信公众号"},{"marketingChannelLv3":"其他"},{"marketingChannelLv2":"数据库营销","marketingChannelLv3":"EDM"},{"marketingChannelLv2":"其他类型广告","marketingChannelLv3":"其他"},{"city":"上海","businessLine":"留学","marketingChannelLv1":"SNS","marketingChannelLv2":"集团","marketingChannelLv3":"官方微信"},{"marketingChannelLv3":"官方微博"},{"marketingChannelLv2":"分公司","marketingChannelLv3":"官方微信"},{"marketingChannelLv3":"合作微信"},{"marketingChannelLv3":"官方微博"},{"businessLine":"考培","marketingChannelLv1":"SNS","marketingChannelLv2":"集团","marketingChannelLv3":"官方微信"},{"marketingChannelLv3":"官方微博"},{"marketingChannelLv2":"分公司","marketingChannelLv3":"官方微信"},{"marketingChannelLv3":"合作微信"},{"marketingChannelLv3":"官方微博"},{"businessLine":"留学","marketingChannelLv1":"线下","marketingChannelLv2":"户外推广","marketingChannelLv3":"同济大学"},{"marketingChannelLv3":"海洋大学"},{"marketingChannelLv2":"商家合作","marketingChannelLv3":"夸克金融"},{"marketingChannelLv3":"中芯国际"},{"marketingChannelLv3":"欧风"},{"marketingChannelLv3":"无涯"},{"marketingChannelLv3":"宜信"},{"marketingChannelLv3":"易家佳"},{"marketingChannelLv3":"筑鼎"},{"marketingChannelLv3":"鼎丰"},{"marketingChannelLv3":"人人网"},{"marketingChannelLv3":"中国银行"},{"marketingChannelLv3":"浦发银行"},{"marketingChannelLv3":"花旗银行"},{"marketingChannelLv3":"星展银行"},{"marketingChannelLv2":"校园活动","marketingChannelLv3":"上海大学"},{"marketingChannelLv3":"复旦大学"},{"marketingChannelLv3":"光明中学"},{"marketingChannelLv3":"财经大学"},{"marketingChannelLv3":"同济大学"},{"marketingChannelLv3":"上海外国语大学"},{"marketingChannelLv3":"华东政法大学"},{"marketingChannelLv3":"上海大学"},{"marketingChannelLv3":"上海雅思托福考点"},{"marketingChannelLv3":"欧风"},{"marketingChannelLv2":"传统媒体"},{"businessLine":"考培","marketingChannelLv1":"线下","marketingChannelLv2":"户外推广","marketingChannelLv3":"万普"},{"marketingChannelLv3":"虹桥机场"},{"marketingChannelLv2":"商家合作","marketingChannelLv3":"精锐"},{"marketingChannelLv3":"实惠APP"},{"marketingChannelLv3":"竞对机构"},{"marketingChannelLv2":"校园活动","marketingChannelLv3":"上海理工"},{"marketingChannelLv3":"上海财大"},{"marketingChannelLv3":"上海金融学院"},{"marketingChannelLv3":"上海海事大学"},{"marketingChannelLv3":"雅思考点"},{"marketingChannelLv3":"托福考点"},{"marketingChannelLv2":"传统媒体"},{"businessLine":"留学","marketingChannelLv1":"合作招生","marketingChannelLv2":"线上合作","marketingChannelLv3":"市场合作"},{"marketingChannelLv3":"招生代表"},{"marketingChannelLv2":"线下合作","marketingChannelLv3":"市场合作"},{"marketingChannelLv3":"招生代表"},{"businessLine":"考培","marketingChannelLv2":"线上合作","marketingChannelLv3":"市场合作"},{"marketingChannelLv3":"招生代表"},{"marketingChannelLv2":"线下合作","marketingChannelLv3":"市场合作"},{"marketingChannelLv3":"招生代表"},{"city":"集团","businessLine":"全部","marketingChannelLv1":"推荐","marketingChannelLv2":"推荐","marketingChannelLv3":"顾问互荐"},{"marketingChannelLv3":"销售服务人员推荐"},{"marketingChannelLv3":"老客户推荐"},{"marketingChannelLv3":"员工推荐"},{"marketingChannelLv2":"线上资源互换","marketingChannelLv3":"线上资源互换"},{"marketingChannelLv2":"线下资源互换","marketingChannelLv3":"线下资源互换"}],"Campaign":[{"name":"2015年10月上海留学教育展 - 复旦大学A","recordType":"四级推广方式","startDate":"2015-12-01","endDate":"2015-12-31","approver":"tcool.ma@cnsdc01.pwc.com","city":"集团","businessLine":"全部","marketingChannelLv1":"合作招生","marketingChannelLv2":"线下合作","marketingChannelLv3":"市场合作","budgetedCost":" ","description":" ","errorMessage":" "},{"name":"2015年10月上海新动态A","recordType":"四级推广方式","startDate":"2015-10-01","endDate":"2015-10-31","approver":"tcool.ma@cnsdc01.pwc.com","city":"集团","businessLine":"全部","marketingChannelLv1":"SNS","marketingChannelLv2":"集团","marketingChannelLv3":"官方微信","budgetedCost":" ","description":" ","errorMessage":" "},{"name":"2015年10月上海新动态B","recordType":"四级推广方式","startDate":"2015-10-01","endDate":"2015-10-31","approver":"tcool.ma@cnsdc01.pwc.com","city":"集团","businessLine":"全部","marketingChannelLv1":"SNS","marketingChannelLv2":"集团","marketingChannelLv3":"官方微博","budgetedCost":" ","description":" ","errorMessage":" "}]}';

        CampaignUploaderCtrl campaignUploader = new CampaignUploaderCtrl ();
        campaignUploader.sObjectName = 'Campaign';
        campaignUploader.getExcelUploaderCampaignFieldMapping();
        campaignUploader.getCities();
        campaignUploader.getBusinessLines();
        CampaignUploaderCtrl.uploadData(data);

        Test.stopTest();

        List<Campaign> campaignList = [SELECT Id FROM Campaign];
        System.assertEquals(3, campaignList.size());
    }
}