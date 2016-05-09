@isTest
private class CreateIntendedSchoolTest {

    @isTest static void method() {

        Account acct = new Account ();
        acct.RecordTypeId = [SELECT Id 
                             FROM RecordType
                             WHERE DeveloperName = 'EIC_Account'
                             AND SObjectType='Account'].Id;
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
        Opportunity opp = new Opportunity ();
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

        Test.setCurrentPage(Page.CreateIntendSchool);
        System.currentPageReference().getParameters().put('oppId', opp.Id);
        ApexPages.StandardController sd = new ApexPages.StandardController (opp);
        CreateIntendedSchool cs = new CreateIntendedSchool (sd);
        String param = '{"degree":"123", "faculty":"456", "major":"789", "school":"1-1-1", "oppId":"' + opp.Id + '"}';
        CreateIntendedSchool.create(param);
        param = '{"degree":"123", "faculty":"456", "major":"789", "school":"1-1-1", "oppId":"' + opp.Id + '"}';
        CreateIntendedSchool.create(param);
        param = '{"degree":"123", "faculty":"456", "major":"789", "school":"1-1-1", "oppId":"006O00000084Nhg"}';
        CreateIntendedSchool.create(param);
    }
}