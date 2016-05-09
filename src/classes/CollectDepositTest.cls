@isTest
private class CollectDepositTest {

    @isTest
    private static void testCollectDeposit() {

        Profile p = [SELECT Id FROM Profile WHERE Name='分公司分校前台'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = '留学上海分公司客服部专员'];
        User u = new User(Alias = 'standt', Email='sample1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='sample123@testorg.com',
            Paike_UserName__c = '123456');

        System.runAs(u) {

            Account acc = new Account ();
            acc.Name = '王同学';
            insert acc;

            Contact_EIC__c contact = new Contact_EIC__c ();
            contact.Account__c = acc.Id;
            contact.Contact_Type__c = '手机';
            contact.UniqueContact__c = '13567890987';
            contact.IsInvalid__c = false;
            insert contact;

            Opportunity opp = new Opportunity ();
            opp.Name = '王同学北京留学英国商机';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today().addDays(30);
            opp.StageName = '待分配';
            insert opp;

            Contract_System__c sys = new Contract_System__c ();
            sys.Name = 'Prepsmith Jiaowu Register';
            sys.Endpoint__c = 'https://www.test.com';
            insert sys;

            Test.startTest();

            CollectDepositExt ext = new CollectDepositExt(new ApexPages.StandardController(opp));
            ext.gotoTestPrepDeposit();

            Test.stopTest();
        }
    }

    @isTest
    private static void testCollectDepositService() {

        Account acc = new Account ();
        acc.Name = '王同学';
        insert acc;

        Opportunity opp = new Opportunity ();
        opp.Name = '王同学北京留学英国商机';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today().addDays(30);
        opp.StageName = '待分配';
        insert opp;

        Test.startTest();

        CollectDepositService.Deposit d1 = new CollectDepositService.Deposit ();
        d1.Code = '0001';
        d1.Money = 20000;
        d1.Money_Quit = 0;
        d1.Money_Use = 0;
        d1.Money_Lave = 20000;

        CollectDepositService.DepositWrapper deposit1 = new CollectDepositService.DepositWrapper ();
        deposit1.CRM_Student_ID = acc.Id;
        deposit1.CRM_Opportunity_ID = opp.Id;
        deposit1.BS_Student_Code = '123456';
        deposit1.Earnest_Money_Status = 1;
        deposit1.Earnest_Money_List = new List<CollectDepositService.Deposit>{ d1 };

        CollectDepositRestful.collectDeposic(deposit1);

        CollectDepositService.Deposit d2 = new CollectDepositService.Deposit ();
        d2.Code = '0001';
        d2.Money = 20000;
        d2.Money_Quit = 0;
        d2.Money_Use = 20000;
        d2.Money_Lave = 0;

        CollectDepositService.DepositWrapper deposit2 = new CollectDepositService.DepositWrapper ();
        deposit2.CRM_Student_ID = acc.Id;
        deposit2.CRM_Opportunity_ID = opp.Id;
        deposit2.BS_Student_Code = '123456';
        deposit2.Earnest_Money_Status = 2;
        deposit2.Earnest_Money_List = new List<CollectDepositService.Deposit> { d2 };

        CollectDepositRestful.collectDeposic(deposit2);

        Test.stopTest();

        List<Deposit__c> depositList = [SELECT Money__c, Money_Quit__c, Money_Use__c, Money_Lave__c
                                        FROM Deposit__c];
        System.assertEquals(1, depositList.size());
        System.assertEquals(200, depositList[0].Money__c);
        System.assertEquals(0, depositList[0].Money_Quit__c);
        System.assertEquals(200, depositList[0].Money_Use__c);
        System.assertEquals(0, depositList[0].Money_Lave__c);
    }
}