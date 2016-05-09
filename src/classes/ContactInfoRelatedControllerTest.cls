/**************************************************************************************************
 * Name: ContactInfoRelatedControllerTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class ContactInfoRelatedControllerTest {

    @testSetup static void setup () {

        Account acc = new Account ();
        acc.Name = 'AccQuickSearch';
        insert acc;

        Contact_EIC__c contat = new Contact_EIC__c ();
        contat.isPrimary__c = true;
        contat.Name = 'test';
        contat.Contact_Type__c = '手机';
        contat.Account__c = acc.Id;
        contat.Relationship__c = 'OneSelf';
        contat.UniqueContact__c = '13671999387';
        insert contat;

        Opportunity o = new Opportunity ();
        o.CloseDate = System.Today();
        o.name = 'test';
        o.AccountId = acc.Id;
        o.sys_UnlockStage__c = true;  
        o.StageName = '顾问跟进';
        o.sys_UnlockStage__c = false;
        insert o;

        OpportunityTeamMember oppMember = new OpportunityTeamMember ();
        oppMember.OpportunityId = o.Id;
        oppMember.UserId = userinfo.getUserId();
        oppMember.TeamMemberRole = 'Team Member';
        insert oppMember;
    }

    static testMethod void AccountQuickSearch () {

        Test.startTest();
        Account acc = [SELECT id FROM Account LIMIT 1];

        PageReference myVfPage = Page.ContactInfoDisplay;
        Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
        ApexPages.currentPage().getParameters().put('ID', acc.Id);
        ContactInfoRelatedController contatshow = new ContactInfoRelatedController(new ApexPages.StandardController(acc));
        contatshow.showContactNumber();
        contatshow.primarycontact = '0';
        contatshow.setPrimary();
        test.stopTest();
    }
}