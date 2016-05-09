@isTest
private class CreateNewContactPageControllerTest {

    static testMethod void AccountQuickSearch () {

        Account acc = new Account ();
        acc.Name = 'AccQuickSearch';
        insert acc;
        Test.StartTest();

        PageReference createNewContactPage = Page.CreateNewContactPage;
        Test.setCurrentPageReference(createNewContactPage);
        ApexPages.currentPage().getParameters().put('AccountID', acc.Id);

        CreateNewContactPageController creatCont = new CreateNewContactPageController ();
        creatCont.cntat.homePhoneArea = '021';
        creatCont.cntat.uniquecontact = '54676543';
        creatCont.cntat.contact.Name = 'test';
        creatCont.cntat.contact.Relationship__c = '客户本人';
        creatCont.cntat.contact.Contact_Type__c = '座机';
        creatCont.contactNameGenerate();
        creatCont.SaveContact();
        creatCont.cancel();
        Test.stopTest();
    }
}