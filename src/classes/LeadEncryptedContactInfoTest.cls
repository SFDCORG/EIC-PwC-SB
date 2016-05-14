/**************************************************************************************************
 * Name: LeadEncryptedContactInfoTest
 * Object: ***
 * Purpose: Test class to verify the functionality of
    - LeadEncryptedMobile.page
    - LeadEncryptedMobileExtension.cls (100% coverage) 
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-13
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class LeadEncryptedContactInfoTest {

    @isTest static void viewEncryptedPhoneNumbers() {

        User tmkUser = TestObjectFactory.createTmkUser('tmkUser');
        insert tmkUser;

        System.runAs(tmkUser) {

            // insert lead
            Lead lead = TestObjectFactory.createTmkLead();
            insert lead;

            PageReference pageRef = Page.LeadEncryptedMobile;
            pageref.getParameters().put('id', lead.id);
            Test.setCurrentPage(pageRef);

            // Views lead
            ApexPages.standardController controller = new ApexPages.standardController(lead);
            LeadEncryptedMobileExtension extension = new LeadEncryptedMobileExtension(controller);

            Test.startTest();

            // Asserts phone numbers are scrambled and that there is no log history for this lead and user
            System.assertEquals('135****0001', extension.mobilePhone);
            System.assertEquals('****5555', extension.phone);
            System.assertEquals(0, [SELECT count()
                                    FROM Lead_Phone_View_Log__c
                                    WHERE User__c = :tmkUSer.Id
                                    AND Lead__c = :lead.Id]);

            // Clicks show button
            extension.showContactInfo();

            // Asserts phone numbers are readable
            System.assertEquals('13500000001', extension.mobilePhone);
            System.assertEquals('44445555', extension.phone);

            // assert view log history was created;
            System.assertEquals(1, [SELECT count()
                                    FROM Lead_Phone_View_Log__c
                                    WHERE User__c = :tmkUSer.Id
                                    AND Lead__c = :lead.Id]);

            Test.stopTest();
        }
    }
}