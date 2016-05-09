/**************************************************************************************************
 * Name: ContractInfoControllerTest
 * Object: Contract__c
 * Purpose: a test class for getting contract details from sage system
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-05
 * Modified History: 
 * 2016-05-05    Vicia    Wang Writes comments in this format
 * 2016-05-06    Allen    Format the code
***************************************************************************************************/
@isTest(SeeAllData = TRUE)
private class ContractInfoControllerTest {

    static testMethod void testContractInfoController() {

        User user = TestObjectFactory.createUser();

        System.runAs(user) {

            PageReference contratDetail = Page.ContractDetail;
            Test.setCurrentPage(contratDetail);

            Account acc = TestObjectFactory.createAccount('19100001111');
            List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
            Contract__c contract = TestObjectFactory.createContract(oppList[0]);

            ApexPages.StandardController standardCon = new ApexPages.StandardController (contract);
            Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
            ContractInfoController controller = new ContractInfoController(standardCon);
            controller.getContractDetailList();
        }
    }
}