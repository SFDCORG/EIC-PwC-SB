/**************************************************************************************************
 * Name: GenerateContractControllerTest
 * Object: Account, Opportunity, Contract__c
 * Purpose: a test class for phone search visualforce page function
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04    Vicia Wang    Writes comments in this format
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest(SeeAllData = TRUE)
private class GenerateContractControllerTest {

    static testMethod void testGenerateCounsellingContract () {

        User user = TestObjectFactory.createUser();

        System.runAs(user) {

            Account acc = TestObjectFactory.createAccount('19099990000');
            List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);

            PageReference generateContract = Page.GenerateContract;
            Test.setCurrentPage(generateContract);
            ApexPages.currentPage().getParameters().put('oppId', oppList[0].Id);

            GenerateContractController controller = new GenerateContractController ();
            controller.sendPostRequest();

            Contract__c contract = TestObjectFactory.createContract(oppList[0]);
            GenerateContractController controller2 = new GenerateContractController ();
            controller2.sendPostRequest();
        }
    }

    static testMethod void testGenerateTestprepContract () {

        User user = TestObjectFactory.createUser();

        System.runAs(user) {

            Account acc = TestObjectFactory.createAccount('19099990000');
            Opportunity opp = TestObjectFactory.createTestprepOpportunity(acc);

            PageReference generateContract = Page.GenerateContract;
            Test.setCurrentPage(generateContract);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);

            GenerateContractController controller = new GenerateContractController ();
            controller.sendPostRequest();
        }
    }

    static testMethod void testGenerateMinorityContract () {

        User user = TestObjectFactory.createUser();

        System.runAs(user) {

            Account acc = TestObjectFactory.createAccount('19099990000');
            List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
            oppList[0].Department__c = Constants.DEPARTMENT_MINORITY_LANGUAGE_CN;
            oppList[0].Project__c = Constants.MINORITY_LANGUAGE_FRENCH_CN;
            update oppList;
            System.debug(LoggingLevel.INFO, '*** oppList[0]: ' + oppList[0]);
            PageReference generateContract = Page.GenerateContract;
            Test.setCurrentPage(generateContract);
            ApexPages.currentPage().getParameters().put('oppId', oppList[0].Id);

            GenerateContractController controller = new GenerateContractController ();
            controller.sendPostRequest();

            Contract__c contract = TestObjectFactory.createContract(oppList[0]);
            GenerateContractController controller2 = new GenerateContractController ();
            controller2.sendPostRequest();
        }
    }

    static testMethod void testAgentContract () {

        User user = TestObjectFactory.createUser();

        System.runAs(user) {
            Account acc = TestObjectFactory.createAccount('19099990000');
            List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);

            PageReference generateContract = Page.GenerateContract;
            Test.setCurrentPage(generateContract);
            ApexPages.currentPage().getParameters().put('oppId', oppList[0].Id);

            GenerateAgentContractController controller = new GenerateAgentContractController ();
            controller.sendPostRequest();

            Contract__c contract = TestObjectFactory.createContract(oppList[0]);
            GenerateAgentContractController controller2 = new GenerateAgentContractController ();
            controller2.sendPostRequest();
        }
    }
}