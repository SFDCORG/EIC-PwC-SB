@isTest
private class CreateEducationTest {

    @isTest static void method() {

        Account acct = new Account ();
        acct.RecordTypeId = [SELECT Id
                             FROM RecordType
                             WHERE DeveloperName = 'EIC_Account'
                             AND SObjectType = 'Account'].Id;

        acct.Name = 'test001';
        acct.ID_Type__c = null;
        insert acct;
        Contact_EIC__c c2 = new Contact_EIC__c ();
        c2.Account__c = acct.Id;
        c2.Contact_Type__c = '手机';
        c2.UniqueContact__c = '13200000001';
        c2.isInvalid__c = false;
        c2.isPrimary__c = true;
        insert c2;

        Test.setCurrentPage(Page.CreateEducation);
        System.currentPageReference().getParameters().put('acctId', acct.Id);
        ApexPages.StandardController sd = new ApexPages.StandardController (acct);
        CreateEducationController cs = new CreateEducationController (sd);

        String param = '{"degree":"123", "faculty":"456", "major":"789", "school":"1-1-1", "acctId":"' + acct.Id + '"}';
        CreateEducationController.create(param);
        param = '{"degree":"123", "faculty":"456", "major":"789", "school":"1-1-1", "acctId":"' + acct.Id + '"}';
        CreateEducationController.create(param);
        param = '{"degree":"123", "faculty":"456", "major":"789", "school":"1-1-1", "acctId":"0012800000CnPJL"}';
        CreateEducationController.create(param);
    }
}