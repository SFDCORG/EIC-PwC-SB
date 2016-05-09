/**************************************************************************************************
 * Name: UpdateOppLeadWithoutSharingTest
 * Object: Lead
 * Purpose: Test class for UpdateLeadWithoutSharing.cls
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
@isTest
private class UpdateOppLeadWithoutSharingTest {
	@isTest static void method() {
		User u = [Select Id From User Where Id = :Userinfo.getUserId()];
    	system.runAs(u) {
    		CreateUserUtil.CreateUserForAppointment();
    	}

    	Campaign cam = TestObjectFactory.createCampaign('百度测试', '全部', 'SNS', '集团', '官方微博');
    	Campaign cam1 = TestObjectFactory.createCampaign('谷歌测试', '全部', 'SNS', '集团', '官方微博');
    	Lead l = TestObjectFactory.createLead(cam, '上海', true);
    	insert l;
    	Id recordTypeId = Utils.getRecordTypeId('Account', 'EIC Account');
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeId);
        insert acc;
        Contact_EIC__c contact = new Contact_EIC__c(
            Name = 'Test Account',
            Account__c = acc.Id,
            Contact_Type__c = '手机',
            UniqueContact__c = '13200998787');
        insert contact;

        Id cRTId = Utils.getRecordTypeId('Opportunity', 'Counselling');
        Id tRTId = Utils.getRecordTypeId('Opportunity', 'testprep');
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity counsellingOpp = new Opportunity(
            Name = 'counsellingOpp',
            RecordTypeId = cRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = '北京',
            Intended_Office__c = 'N/A',
            Department__c = '英爱部',
            Project__c = '英国',
            StageName = '顾问跟进',
            Consultation_Mode__c = '400呼入呼叫中心',
            Level_4_Promotion_Channel__c=cam.Id);
        opps.add(counsellingOpp);

        Opportunity counsellingOpp2 = new Opportunity(
            Name = 'counsellingOpp2',
            RecordTypeId = cRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = '上海',
            Intended_Office__c = 'N/A',
            Department__c = '英爱部',
            Project__c = '英国',
            StageName = '流失',
            Consultation_Mode__c = '400呼入呼叫中心',
            Level_4_Promotion_Channel__c=cam.Id);
        opps.add(counsellingOpp2);
        insert opps;

        Lead ll = [Select Id,OwnerId From Lead Where Id = :l.Id];
        User u1 = [Select Id From User Where Email = 'grouptmk400a@eiceducation.com.cn.testcode'];
        system.runAs(u1) {
        	UpdateLeadWithoutSharing.doUpdateOwner(l.Id, u1.Id);
        	UpdateLeadWithoutSharing.doUpdateOwner(l.Id, '00Q2800000GnzRf');

        	UpdateOppWithoutSharing.doUpdateOwner(counsellingOpp.Id,u1.Id);
        	UpdateOppWithoutSharing.doUpdateOwner(counsellingOpp2.Id,u1.Id);
        	UpdateOppWithoutSharing.doUpdateOwner(counsellingOpp2.Id,'00628000006vvrv');
        }
	}
}