@isTest
private class LeadTriggerTest {
    static testMethod void leadTrigger() {
        Campaign campaign = new Campaign(
            Name = 'VT001月年',
            Status = '审批通过',
            City__c = '北京',
            Marketing_Channel_Lv1__c = '老客户推荐',
            Marketing_Channel_Lv2__c = '老客户推荐',
            Marketing_Channel_Lv3__c = '老客户推荐',
            StartDate = System.today() + 1,
            EndDate = System.today() + 10,
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

        Lead_Item__c leadItem = new Lead_Item__c(Lead__c = lead.Id);
        insert leadItem;
    }    
}