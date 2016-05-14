/**************************************************************************************************
 * Name: OpportunityCalloutTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class OpportunityCalloutTest {

    @isTest static void testSend () {
        
        Account acct = new Account();
        acct.RecordTypeId = [SELECT Id 
                             FROM RecordType 
                             WHERE DeveloperName='EIC_Account' 
                             AND SObjectType='Account'].Id;
        acct.Name = 'test001';
        acct.ID_Type__c = null;
        insert acct;

        Opportunity opp = new Opportunity();
        opp.RecordTypeId = [SELECT Id
                            FROM RecordType
                            WHERE DeveloperName='TestPrep' 
                            AND SObjectType='Opportunity'].Id;
        opp.Name = 'testopp001';
        opp.AccountId = acct.Id;
        opp.StageName = '顾问跟进';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = System.Today();
        insert opp;

        List<Contact_EIC__c> cs = new List<Contact_EIC__c>();
        Contact_EIC__c c3 = new Contact_EIC__c();
        c3.Account__c = acct.Id;
        c3.Contact_Type__c = '座机';
        c3.UniqueContact__c = '02181009897';
        c3.isInvalid__c = false;
        c3.isPrimary__c = false;
        insert c3;

        c3.isPrimary__c = false;
        update c3;

        Test.setCurrentPage(Page.OpportunityCallout);
        ApexPages.StandardController sd = new ApexPages.StandardController(opp);
        OpportunityCalloutController oppCallout = new OpportunityCalloutController(sd);

        Contact_EIC__c c1 = new Contact_EIC__c();
        c1.Account__c = acct.Id;
        c1.Contact_Type__c = '手机';
        c1.UniqueContact__c = '13200000001 [1]';
        c1.isInvalid__c = false;
        c1.isPrimary__c = false;
        insert c1;

        c1.isPrimary__c = false;
        update c1;

        Test.setCurrentPage(Page.OpportunityCallout);
        OpportunityCalloutController oppCallout1 = new OpportunityCalloutController(sd);
        

        Contact_EIC__c c2 = new Contact_EIC__c();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c= '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;
        
        Test.setCurrentPage(Page.OpportunityCallout);
        OpportunityCalloutController oppCallout2 = new OpportunityCalloutController(sd);

        Contact_EIC__c c4 = new Contact_EIC__c();
        c4.Account__c = acct.Id;
        c4.Contact_Type__c= '手机';
        c4.UniqueContact__c = '13200000001-123';
        c4.isInvalid__c = false;
        c4.isPrimary__c = true;
        insert c4;

        Test.setCurrentPage(Page.OpportunityCallout);
        OpportunityCalloutController oppCallout3 = new OpportunityCalloutController(sd);
    }
}