/**************************************************************************************************
 * Name: SageDeleteContractRESTfulTest
 * Object: Campaign
 * Purpose: a test class for deleting contract from SAGE.
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest
private class SageDeleteContractRESTfulTest {
    static testMethod void testSageDeleteContractRESTful() {
       	User user = TestObjectFactory.createUser();

        System.runAs(user) {
        	Account acc = TestObjectFactory.createAccount('19099990000');
			List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
            Contract__c contract = TestObjectFactory.createContract(oppList[0]);
			contract.External_Contract_Id__c = 'C123456';
            update contract;

			List<SageDeleteContractRESTful.ContractId> sageContractIds = new List<SageDeleteContractRESTful.ContractId>();
			SageDeleteContractRESTful.ContractId sageContract = new SageDeleteContractRESTful.ContractId();
			sageContract.sageContractId = 'C123456';
			sageContractIds.add(sageContract);

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/CRM/Sage/SageDeleteContractRESTful';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = SageDeleteContractRESTful.doPost(sageContractIds);

            System.assertEquals(TRUE, result.contains('Delete Successfully'));
            
            String connection = SageDeleteContractRESTful.doGet();
            System.assertEquals(TRUE, connection.contains('Connected Successfully'));
        } 
    }
}