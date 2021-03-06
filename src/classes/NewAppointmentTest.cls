/**************************************************************************************************
 * Name: NewAppointmentTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class NewAppointmentTest {

    @isTest static void method () {

        TriggerShouldRun.AppointmentShouldRun = false;
        Account acct = new Account();
        acct.RecordTypeId = [SELECT Id
                             FROM RecordType 
                             WHERE DeveloperName = 'EIC_Account' 
                             AND SObjectType = 'Account'].Id;
        acct.Name = 'test001';
        acct.ID_Type__c = null;
        insert acct;
        Contact_EIC__c c2 = new Contact_EIC__c();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c = '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE DeveloperName = 'TestPrep'
                            AND SObjectType = 'Opportunity'].Id;
        opp.Name = 'testopp001';
        opp.AccountId = acct.Id;
        opp.StageName = '顾问跟进';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = System.Today();
        insert opp;

        Campaign campaign = new Campaign(
            Name = 'VT001月年',
            Status = '审批通过',
            City__c = '北京',
            Marketing_Channel_Lv1__c = '老客户推荐',
            Marketing_Channel_Lv2__c = '老客户推荐',
            Marketing_Channel_Lv3__c = '老客户推荐',
            StartDate = System.Today() + 1,
            EndDate = System.Today() + 10,
            IsActive = TRUE);
        insert campaign;

        Lead lead = new Lead(
            LastName = 'TEST',
            Company = 'EIC',
            Intended_City__c = '北京',
            Promotion_Channel_Level_2__c = '老客户推荐',
            MobilePhone = '13345678901',
            Is_Counselling__c = TRUE,
            Campaign__c = campaign.Id);
        insert lead;

        BatchCallOutManagementItem__c BCManagementItem = new BatchCallOutManagementItem__c();
        BCManagementItem.AgentNo__c = '1001';
        BCManagementItem.BatchItemName__c ='批量外呼测试';
        BCManagementItem.Team__c = '留学';
        BCManagementItem.batchPhoneMassRemove__c = true;
        BCManagementItem.group__c = 'A';
        BCManagementItem.popupsign__c = '留学';
        insert BCManagementItem;

        CallLog_History__c ch1 = new CallLog_History__c();
        ch1.Lead__c = lead.Id;
        ch1.Type__c = '批量外呼';
        ch1.BatchCallOut__c = BCManagementItem.Id;
        insert ch1;

        CallLog_History__c ch2 = new CallLog_History__c();
        ch2.Type__c = '批量外呼';
        ch2.Opportunity__c = opp.Id;
        ch2.BatchCallOut__c = BCManagementItem.Id;
        insert ch2;

        Map<String, String> rmap = new Map<String, String>();
        List<RecordType> rts = [SELECT Id, DeveloperName 
                                FROM RecordType
                                WHERE SObjectType = 'Appoitment__c' 
                                AND IsActive = true];
        for(RecordType rt : rts) {
            rmap.put(rt.DeveloperName, rt.Id);
        }

        Test.setCurrentPage(Page.NewAppointment);
        System.currentPageReference().getParameters().put('rType', 'Lead_Follow_Up');
        System.currentPageReference().getParameters().put('leadId', lead.Id);
        System.currentPageReference().getParameters().put('batchId', ch1.Id);
        NewAppointmentController nac1 = new NewAppointmentController();
        nac1.save();
        nac1.cancel();

        System.currentPageReference().getParameters().put('rType', 'Follow_Up');
        System.currentPageReference().getParameters().put('leadId', opp.Id);
        System.currentPageReference().getParameters().put('batchId', ch1.Id);
        NewAppointmentController nac = new NewAppointmentController();
        nac.save();
        nac.cancel();
    }

    @isTest static void method1 () {

        TriggerShouldRun.AppointmentShouldRun = false;
        Account acct = new Account();
        acct.RecordTypeId = [SELECT Id 
                             FROM RecordType 
                             WHERE DeveloperName = 'EIC_Account' 
                             AND SObjectType = 'Account'].Id;
        acct.Name = 'test001';
        acct.ID_Type__c = null;
        insert acct;
        Contact_EIC__c c2 = new Contact_EIC__c();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c = '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;
        Opportunity opp= new Opportunity();
        opp.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE DeveloperName = 'TestPrep'
                            AND SObjectType = 'Opportunity'].Id;
        opp.Name = 'testopp001';
        opp.AccountId = acct.Id;
        opp.StageName = '顾问跟进';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = System.Today();
        insert opp;

        Campaign campaign = new Campaign(
            Name = 'VT001月年',
            Status = '审批通过',
            City__c = '北京',
            Marketing_Channel_Lv1__c = '老客户推荐',
            Marketing_Channel_Lv2__c = '老客户推荐',
            Marketing_Channel_Lv3__c = '老客户推荐',
            StartDate = System.Today() + 1,
            EndDate = System.Today() + 10,
            IsActive = TRUE);
        insert campaign;

        Lead lead = new Lead(
            LastName = 'TEST',
            Company = 'EIC',
            Intended_City__c = '北京',
            Promotion_Channel_Level_2__c = '老客户推荐',
            MobilePhone = '13345678901',
            Is_Counselling__c = TRUE,
            Campaign__c = campaign.Id);
        insert lead;

        BatchCallOutManagementItem__c BCManagementItem = new BatchCallOutManagementItem__c();
        BCManagementItem.AgentNo__c = '1001';
        BCManagementItem.BatchItemName__c ='批量外呼测试';
        BCManagementItem.Team__c = '留学';
        BCManagementItem.batchPhoneMassRemove__c =true;
        BCManagementItem.group__c = 'A';
        BCManagementItem.popupsign__c = '留学';
        insert BCManagementItem;
       
        CallLog_History__c ch1 = new CallLog_History__c();
        ch1.Lead__c = lead.Id;
        ch1.Type__c = '批量外呼';
        ch1.BatchCallOut__c = BCManagementItem.Id;
        insert ch1;

        CallLog_History__c ch2 = new CallLog_History__c();
        ch2.Type__c = '批量外呼';
        ch2.Opportunity__c = opp.Id;
        ch2.BatchCallOut__c = BCManagementItem.Id;
        insert ch2;

        Map<String, String> rmap = new Map<String, String>();
        List<RecordType> rts = [SELECT Id, DeveloperName 
                                FROM RecordType 
                                WHERE SObjectType = 'Appoitment__c' 
                                AND IsActive = true];

        for(RecordType rt : rts) {
            rmap.put(rt.DeveloperName, rt.Id);
        }

        Test.setCurrentPage(Page.NewAppointment);
        System.currentPageReference().getParameters().put('rType', 'Follow_Up');
        System.currentPageReference().getParameters().put('oppId', opp.Id);
        System.currentPageReference().getParameters().put('batchId', ch2.Id);
        System.currentPageReference().getParameters().put('invitationType', '首次到访邀约');
        NewAppointmentController nac = new NewAppointmentController();
        nac.save();
        nac.cancel();
    }
}