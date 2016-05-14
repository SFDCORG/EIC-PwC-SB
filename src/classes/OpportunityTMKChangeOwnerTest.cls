/**************************************************************************************************
 * Name: OpportunityTMKChangeOwnerTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class OpportunityTMKChangeOwnerTest {

    @isTest static void method () {

        Test.startTest();
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

        Test.setCurrentPage(Page.OpportunityTMKChangeOwner);
        System.currentPageReference().getParameters().put('Id', opp.Id);
        ApexPages.StandardController sd = new ApexPages.StandardController(opp);
        OpportunityTMKChangeOwnerCtl ctl = new OpportunityTMKChangeOwnerCtl(sd);
        ctl.newOwnerID = UserInfo.getUserId();
        ctl.AssignOpp();
        ctl.cancel();

        ctl.opp.Id = null;
        ctl.AssignOpp();

        Test.stopTest();
    }
}