/**************************************************************************************
Apex Class Name:  LeadEncryptedContactInfoTest
Created Date:     13 Apr 2016
Description:      Test class to verify the functionality of
                    - LeadEncryptedMobile.page
                    - LeadEncryptedMobileExtension.cls (100% coverage)
*************************************************************************************/
@isTest
private class LeadEncryptedContactInfoTest {

	@isTest static void viewEncryptedPhoneNumbers() {
    User tmkUser = TestObjectFactory.createTmkUser('tmkUser');
    insert tmkUser;

    System.runAs(tmkUser){
      // insert lead
      Lead lead = TestObjectFactory.createTmkLead();
      insert lead;

      PageReference pageRef = Page.LeadEncryptedMobile;
      pageref.getParameters().put('id', lead.id);
      Test.setCurrentPage(pageRef);

      // view lead
      ApexPages.standardController controller = new ApexPages.standardController(lead);
      LeadEncryptedMobileExtension extension = new LeadEncryptedMobileExtension(controller);

      Test.startTest();

      // assert phone numbers are scrambled and that there is no log history for this lead and user
      System.assertEquals('135****0001', extension.mobilePhone);
      System.assertEquals('****5555', extension.phone);
      System.assertEquals(0, [SELECT count() FROM Lead_Phone_View_Log__c WHERE User__c = :tmkUSer.Id AND Lead__c = :lead.Id]);

      // click show button
      extension.showContactInfo();

      // assert phone numbers are readable
      System.assertEquals('13500000001', extension.mobilePhone);
      System.assertEquals('44445555', extension.phone);

      // assert view log history was created;
      System.assertEquals(1, [SELECT count() FROM Lead_Phone_View_Log__c WHERE User__c = :tmkUSer.Id AND Lead__c = :lead.Id]);

      Test.stopTest();
    }
  }
}