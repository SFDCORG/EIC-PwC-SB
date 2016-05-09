/**************************************************************************************************
 * Name: duplicatePhoneAccountClsTest
 * Object: Lead
 * Purpose: Save duplicated phone Accounts into System
            Update the old accounts' contact as emergency Account
            Automatically generates Accounts and contacts
 * Author: Ray Cen
 * Create Date: 2016-05-07
 * Modified History: 
***************************************************************************************************/

@isTest
private class duplicatePhoneAccountClsTest {
    static testMethod void testSpliteAccount() {
        //Prepare Testing Data
        User usr = [SELECT id 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            User uuser = TestObjectFactory.createSalesUser();
            uuser.PreciseSearch__c = true;
            uuser.Username = 'accSearch@test.com';
            insert uuser;
        }

        User runUser = [SELECT Id, PreciseSearch__c, Name
                        FROM User 
                        WHERE Username = 'accSearch@test.com'];
        Lead ld = TestObjectFactory.createTmkLead();
        insert ld;
        Account acc = TestObjectFactory.createAccount();
        acc.name = 'Peter Cen';
        insert acc;
        Contact_EIC__c con = TestObjectFactory.createContact(acc);
        con.UniqueContact__c = '13671999387';
        insert con;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.id, runUser);
        opp.Project__c = 'AU';
        opp.Intended_City__c = 'SH';
        opp.Consultation_Mode__c = '400呼入呼叫中心';
        insert opp;
        Campaign_Channel__c channel = TestObjectFactory.createCampaignChannel();
        channel.Marketing_Channel_Lv3__c = 'test channel3';
        insert channel;
        Campaign campaign = TestObjectFactory.createCoopCampaign(channel);
        campaign.Name = 'test camp';
        insert campaign;
        Test.startTest();
        System.runAs(runUser) {

            PageReference myVfPage = Page.duplicatePhoneAccountCreation;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('name', acc.Name);
            ApexPages.currentPage().getParameters().put('campaignId', campaign.Id);
            ApexPages.currentPage().getParameters().put('campainName', campaign.Name);
            ApexPages.currentPage().getParameters().put('mobilephone', con.UniqueContact__c);
            ApexPages.currentPage().getParameters().put('phone', 'null');
            ApexPages.currentPage().getParameters().put('areaCode', 'null');
            ApexPages.currentPage().getParameters().put('consultMode', 'web');
            ApexPages.currentPage().getParameters().put('recommendAccountId', acc.Id);
            ApexPages.currentPage().getParameters().put('recommendAccountName', acc.Name);
            ApexPages.currentPage().getParameters().put('Is_Counselling', 'true');
            ApexPages.currentPage().getParameters().put('Is_TestPrep', 'false');
            ApexPages.currentPage().getParameters().put('TestPrep_Project', 'Null');
            ApexPages.currentPage().getParameters().put('Is_NP', 'false');
            ApexPages.currentPage().getParameters().put('Is_Scholar_Tree', 'false');
            ApexPages.currentPage().getParameters().put('Is_Cooperative_Education', 'false');
            ApexPages.currentPage().getParameters().put('Intended_City', '上海');
            ApexPages.currentPage().getParameters().put('Intended_Office', 'rg');
            duplicatePhoneAccountCls duplPhoneCrt = new duplicatePhoneAccountCls((new ApexPages.StandardController(ld)));
            duplPhoneCrt.saveResult();

            Contact_EIC__c result = [SELECT isEmergency__c FROM Contact_EIC__c WHERE Id = :con.Id];
            System.assertEquals(true, result.isEmergency__c);
        }
        Test.stopTest();
    }
}