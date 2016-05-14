@isTest
public with sharing class SendMessageTest {
    @isTest
    public static void testGenerateSMSTemplate() {
        List<SMS_Template__c> templateList = new List<SMS_Template__c>();
        SMS_Template__c t1 = new SMS_Template__c();
        t1.Active__c = true;
        t1.Name = '活动短信约见的模板';
        t1.Related_To__c = '销售线索';
        t1.First_Level__c = '集团客服中心';
        t1.Second_Level__c = '活动短信约见';
        templateList.add(t1);
        insert templateList;

        test.startTest();

        Test.setCurrentPage(Page.GenerateSMSTemplate);
        ApexPages.StandardController con = new ApexPages.StandardController(t1);
        GenerateSMSTemplateExt ext = new GenerateSMSTemplateExt(con);
        ext.setMergeField('LastName');
        ext.getMergeField();
        t1.SMS_Body__c = '{!Lead.lastname}：感谢您参加启德教育XX展会,时间：XX.XX（周X）XX:XX，地址：XX。凭此短信可走快速通道进入展厅,预约进场请直接填您的手机号!如有朋友一同参展,请提前预约。恭候您的光临，祝留学成功！询XX（人名），XXX（电话）！（系统短信，请勿直接回复）';
        ext.save();
        test.stopTest();

        List<SMS_Template__c> temList = [SELECT SMS_Body__c FROM SMS_Template__c];
        System.assertEquals('{!Lead.lastname}：感谢您参加启德教育XX展会,时间：XX.XX（周X）XX:XX，地址：XX。凭此短信可走快速通道进入展厅,预约进场请直接填您的手机号!如有朋友一同参展,请提前预约。恭候您的光临，祝留学成功！询XX（人名），XXX（电话）！（系统短信，请勿直接回复）', temList[0].SMS_Body__c);
    }

    @isTest
    public static void testLeadSendMessage() {
        Profile p = [SELECT Id FROM Profile WHERE Name='分公司分校前台'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = '留学上海分公司客服部专员'];
        User u = new User(Alias = 'standt', Email='sample1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='sample123@testorg.com');


        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name = '系统管理员'];
        User approver = new User(Alias = 'admin', Email='admin@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='admin123@testorg.com');
        insert approver;

        System.runAs(u) {
            List<SMS_Template__c> templateList = new List<SMS_Template__c>();
            SMS_Template__c t1 = new SMS_Template__c();
            t1.Active__c = true;
            t1.Name = '活动短信约见的模板';
            t1.Related_To__c = '销售线索';
            t1.First_Level__c = '集团客服中心';
            t1.Second_Level__c = '活动短信约见';
            t1.Third_Level__c = '展会';
            t1.Fourth_Level__c = '预约';
            t1.SMS_Body__c = '{!Lead.lastname}：感谢您参加启德教育XX展会,时间：XX.XX（周X）XX:XX，地址：XX。凭此短信可走快速通道进入展厅,预约进场请直接填您的手机号!如有朋友一同参展,请提前预约。恭候您的光临，祝留学成功！询XX（人名），XXX（电话）！（系统短信，请勿直接回复）';
            templateList.add(t1);
            insert templateList;

            Campaign_Channel__c cc1 = new Campaign_Channel__c();
            cc1.City__c = '集团';
            cc1.Business_line__c = '全部';
            cc1.Marketing_Channel_Lv1__c = '线上';
            cc1.Marketing_Channel_Lv2__c = 'PC端';
            cc1.Marketing_Channel_Lv3__c = '百度';
            insert cc1;

            Campaign c1 = new Campaign();
            c1.Name = '2015年12月PC百度品专UAT';
            c1.StartDate = System.today();
            c1.EndDate = System.today().addDays(30);
            c1.Approver__c = approver.Id;
            c1.City__c = '集团';
            c1.Business_line__c = '全部';
            c1.Marketing_Channel_Lv1__c = '线上';
            c1.Marketing_Channel_Lv2__c = 'PC端';
            c1.Marketing_Channel_Lv3__c = '百度';
            c1.IsActive = true;
            insert c1;

            Lead lead = new Lead();
            lead.LastName = '谢丽霞';
            lead.MobilePhone = '13598737849';
            lead.Consultation_Mode__c = '集团TMK外呼';
            lead.Intended_City__c = '上海';
            lead.Is_NP__c = true;
            lead.Campaign__c = c1.Id;
            lead.Company = 'EIC';
            insert lead;

            SMS__c sms = new SMS__c();
            sms.Name = 'SendMessage';
            sms.APIKEY__c = 'ABCDEFG123456';
            sms.Endpoint__c = 'www.yunpian.com';
            insert sms;

            test.startTest();

            Test.setCurrentPage(Page.SendMessage);
            ApexPages.currentPage().getParameters().put('id', lead.Id);
            ApexPages.currentPage().getParameters().put('so', 'Lead');
            SendMessageCtrl con = new SendMessageCtrl();
            con.firstLevel = '集团客服中心';
            con.queryByFirstLevel();
            con.secondLevel = '活动短信约见';
            con.queryBySecondLevel();
            con.thirdLevel = '展会';
            con.queryByThirdLevel();
            con.fourthLevel = '预约';
            con.queryByFourthLevel();

            con.smsTemplateLookup.SMS_Template__c = t1.Id;
            con.lookupTemplate();
            con.updateSMSBody();

            Test.setMock(HttpCalloutMock.class, new SendMessageMockImpl());
            con.sendMessage();
            con.refreshPhoneSection();
            test.stopTest();

            List<SMS_History__c> historyList = [SELECT Id FROM SMS_History__c];
            System.assertEquals(1, historyList.size());
        }
    }

    @isTest
    public static void testAccountSendMessage() {
        Profile p = [SELECT Id FROM Profile WHERE Name='分公司分校前台'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = '留学上海分公司客服部专员'];
        User u = new User(Alias = 'standt', Email='sample@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='sample@testorg.com');

        System.runAs(u) {
            List<SMS_Template__c> templateList = new List<SMS_Template__c>();
            SMS_Template__c t1 = new SMS_Template__c();
            t1.Active__c = true;
            t1.Name = '活动短信约见的模板';
            t1.Related_To__c = '客户';
            t1.First_Level__c = '集团客服中心';
            t1.Second_Level__c = '活动短信约见';
            t1.Third_Level__c = '展会';
            t1.Fourth_Level__c = '预约';
            t1.SMS_Body__c = '{!Account.Name}：感谢您参加启德教育XX展会,时间：XX.XX（周X）XX:XX，地址：XX。凭此短信可走快速通道进入展厅,预约进场请直接填您的手机号!如有朋友一同参展,请提前预约。恭候您的光临，祝留学成功！询XX（人名），XXX（电话）！（系统短信，请勿直接回复）';
            templateList.add(t1);
            insert templateList;

            Account acc = new Account();
            acc.Name = '谢丽霞';
            acc.Phone = '13598737849';
            insert acc;

            Contact_EIC__c contact = new Contact_EIC__c();
            contact.Account__c = acc.Id;
            contact.Contact_Type__c = '手机';
            contact.UniqueContact__c = '13598737849';
            insert contact;

            Opportunity opp = TestObjectFactory.createTestprepOpportunity(acc);
            SMS__c sms = new SMS__c();
            sms.Name = 'SendMessage';
            sms.APIKEY__c = 'ABCDEFG123456';
            sms.Endpoint__c = 'www.yunpian.com';
            insert sms;
            test.startTest();

            Test.setCurrentPage(Page.SendMessage);
            ApexPages.currentPage().getParameters().put('id', opp.Id);
            ApexPages.currentPage().getParameters().put('so', 'Opportunity');
            SendMessageCtrl oppCon = new SendMessageCtrl();

            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.currentPage().getParameters().put('so', 'Account');
            SendMessageCtrl con = new SendMessageCtrl();
            con.firstLevel = '集团客服中心';
            con.queryByFirstLevel();
            con.secondLevel = '活动短信约见';
            con.queryBySecondLevel();
            con.thirdLevel = '展会';
            con.queryByThirdLevel();
            con.fourthLevel = '预约';
            con.queryByFourthLevel();

            con.updateSMSBody();
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), '无法解析您输入的相关项对应的字段, 请检查\'{ }\'的内容格式!'));

            con.sendMessage();
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                ApexPages.getMessages(), '短信模板内容不能为空！'));

            con.smsTemplateLookup.SMS_Template__c = t1.Id;
            con.lookupTemplate();
            con.updateSMSBody();

            Test.setMock(HttpCalloutMock.class, new SendMessageMockImpl());
            con.sendMessage();
            
            test.stopTest();

            List<SMS_History__c> historyList = [SELECT Id FROM SMS_History__c];
            System.assertEquals(1, historyList.size());
        }
        
    }
}