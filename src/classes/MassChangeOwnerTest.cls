@isTest
private class MassChangeOwnerTest {
    @isTest
    private static void testMassChangeOwner(){
        List<User> staffList = new List<User>();
        User staff1 = new User(
            Alias = 'A',
            Email='test@eic1.com',
            EmailEncodingKey='UTF-8',
            LastName='留学上海客服专员A',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '分公司分校客服专员'].Id,
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Counselling_SH_Renguang_CS_Null_Staff'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test@eic1.com');
        staffList.add(staff1);
        User staff2 = new User(
            Alias = 'B',
            Email='test@eic2.com',
            EmailEncodingKey='UTF-8',
            LastName='留学上海客服专员B',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '分公司分校客服专员'].Id,
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Counselling_SH_Renguang_CS_Null_Staff'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test@eic2.com');
        staffList.add(staff2);
        User staff3 = new User(
            Alias = 'C',
            Email='test@eic3.com',
            EmailEncodingKey='UTF-8',
            LastName='留学上海客服专员C',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '分公司分校客服专员'].Id,
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Counselling_SH_Renguang_CS_Null_Staff'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test@eic3.com');
        staffList.add(staff3);
        insert staffList;

        User owner = new User(
            Alias = 'owner',
            Email = 'owner@eic.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Owner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '分公司分校客服主管'].Id,
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Counselling_SH_Renguang_CS_Null_Manager'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'owner@eic.com');
        insert owner;

        User approver = new User(
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

        Group g1 = new Group(Name='集团TMK主管组', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        insert q1;

        Test.startTest();

        System.runAs(owner){
            List<Lead_Distribution_Table__c> ldtList = new List<Lead_Distribution_Table__c>();
            Lead_Distribution_Table__c ldt1 = new Lead_Distribution_Table__c();
            ldt1.Name = '线索分配表A';
            ldtList.add(ldt1);
            Lead_Distribution_Table__c ldt2 = new Lead_Distribution_Table__c();
            ldt2.Name = '线索分配表B';
            ldtList.add(ldt2);
            insert ldtList;

            List<Lead_Distribution_Table_Line__c> ldtlList = new List<Lead_Distribution_Table_Line__c>();
            Lead_Distribution_Table_Line__c ldtl1 = new Lead_Distribution_Table_Line__c();
            ldtl1.Lead_Distribution_Table__c = ldt1.Id;
            ldtl1.Customer_Service_Staff__c = staff1.Id;
            ldtlList.add(ldtl1);
            Lead_Distribution_Table_Line__c ldtl2 = new Lead_Distribution_Table_Line__c();
            ldtl2.Lead_Distribution_Table__c = ldt1.Id;
            ldtl2.Customer_Service_Staff__c = staff2.Id;
            ldtlList.add(ldtl2);
            Lead_Distribution_Table_Line__c ldtl3 = new Lead_Distribution_Table_Line__c();
            ldtl3.Lead_Distribution_Table__c = ldt2.Id;
            ldtl3.Customer_Service_Staff__c = staff3.Id;
            ldtlList.add(ldtl3);
            Lead_Distribution_Table_Line__c ldtl4 = new Lead_Distribution_Table_Line__c();
            ldtl4.Lead_Distribution_Table__c = ldt2.Id;
            ldtl4.Queue__c = '集团TMK主管组';
            ldtlList.add(ldtl4);
            insert ldtlList;

            Campaign campaign1 = new Campaign();
            campaign1.Name = '2015年10月上海百度竞价A';
            campaign1.StartDate = System.today();
            campaign1.EndDate = System.today().addDays(30);
            campaign1.Approver__c = approver.Id;
            campaign1.Marketing_Channel_Lv1__c = '线上';
            campaign1.Marketing_Channel_Lv2__c = 'PC';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;

            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead();
            lead1.Campaign__c = campaign1.Id;
            lead1.Company = 'EIC';
            lead1.Status = '全未转化-新建';
            lead1.LastName = 'A';
            lead1.MobilePhone = '13585779272';
            lead1.Consultation_Mode__c = '面询';
            lead1.Intended_City__c = '上海';
            lead1.Is_NP__c = true;
            leadList.add(lead1);
            Lead lead2 = new Lead();
            lead2.Campaign__c = campaign1.Id;
            lead2.Company = 'EIC';
            lead2.Status = '全未转化-新建';
            lead2.LastName = 'B';
            lead2.MobilePhone = '13585779272';
            lead2.Consultation_Mode__c = '面询';
            lead2.Intended_City__c = '上海';
            lead2.Is_NP__c = true;
            leadList.add(lead2);
            Lead lead3 = new Lead();
            lead3.Campaign__c = campaign1.Id;
            lead3.Company = 'EIC';
            lead3.Status = '全未转化-新建';
            lead3.LastName = 'B';
            lead3.Area_Code__c = '021';
            lead3.Phone = '87490327';
            lead3.Consultation_Mode__c = '面询';
            lead3.Intended_City__c = '上海';
            lead3.Is_NP__c = true;
            leadList.add(lead3);

            insert leadList;

            List<Lead> selectedLeadList = leadList;
            ApexPages.StandardSetController con = new ApexPages.StandardSetController(selectedLeadList);
            con.setSelected(selectedLeadList);
            MassChangeOwnerExt massChangeOwner = new MassChangeOwnerExt(con);
            massChangeOwner.getDistributionTypes();
            massChangeOwner.getLeadDistributionTablePrefix();

            Map<String, List<MassChangeOwnerExt.DistributionTable>> leadDistributionTableIdLinesMap = new Map<String, List<MassChangeOwnerExt.DistributionTable>>();
            MassChangeOwnerExt.DistributionTable dt1 = new MassChangeOwnerExt.DistributionTable();
            dt1.ldtl = ldtl1;
            dt1.numbers = 1;
            MassChangeOwnerExt.DistributionTable dt2 = new MassChangeOwnerExt.DistributionTable();
            dt2.ldtl = ldtl2;
            dt2.numbers = 1;
            MassChangeOwnerExt.DistributionTable dt3 = new MassChangeOwnerExt.DistributionTable();
            dt3.ldtl = ldtl3;
            dt3.numbers = 1;
            MassChangeOwnerExt.DistributionTable dt4 = new MassChangeOwnerExt.DistributionTable();
            dt4.ldtl = ldtl4;
            dt4.numbers = 1;
            leadDistributionTableIdLinesMap.put(ldt2.Id, new List<MassChangeOwnerExt.DistributionTable>{ dt3, dt4 });
            massChangeOwner.leadDistributionTableId = ldt2.Id;
            massChangeOwner.leadDistributionTableIdLinesMap = leadDistributionTableIdLinesMap;
            massChangeOwner.save();

            massChangeOwner.back();
        }

        Test.stopTest();
    }
}