/**************************************************************************************************
 * Name: SageDeleteContractRESTful
 * Object: Contract__c
 * Purpose: if the contract is soft deleted in SAGE, we need delete the contract.
 * Requirement: 
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modified History: 
 * 2015-12-14   vicia.wang Writes comments in this format
* Endpoint: "http://eic.force.com/services/apexrest/CRM/Sage/SageDeleteContractRESTful"
{"sageContractIds": [
	{"sageContractId": "150123"},
    {"sageContractId": "150122"}]
}
***************************************************************************************************/
@RestResource(urlMapping='/CRM/Sage/SageDeleteContractRESTful')
global class SageDeleteContractRESTful {
	@httpGet
	global static String doGet() {
		return 'Connected Successfully';
	}

    @httpPost
    global static string doPost(List<ContractId> sageContractIds) {
    	Set<String> contractIdSet = new Set<String>();
        Set<Id> oppIds = new Set<Id>();
    	List<Contract__c> contracts = new List<Contract__c>();
        List<Opportunity> opportunities = new List<Opportunity>();
        // Create the interaction log
        InteractionLogUtil.CreateLog('SAGE Contract - Delete',JSON.serialize(sageContractIds));
    	for (ContractId contractId :sageContractIds) {
    		contractIdSet.add(contractId.sageContractId);
    	}

    	for (Contract__c contract :[
    			SELECT Id, Opportunity__c
    			FROM Contract__c
    			WHERE External_Contract_Id__c IN :contractIdSet]) {
    		contracts.add(contract);

            if (String.isNotBlank(contract.Opportunity__c)) {
                oppIds.add(contract.Opportunity__c);
            }
    	}

        for (Opportunity opp :[
                SELECT Id, StageName
                FROM Opportunity
                WHERE Id IN :oppIds]) {
            opp.StageName = '确认有效';
            opportunities.add(opp);
        }

    	try {
    		delete contracts;
            Database.update(opportunities, FALSE);
    		return JSON.serialize('Delete Successfully');

    	} catch (Exception e) {
    		String message = 'Cause: ' + e.getCause();
        	message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
    	}
    }

	global class ContractId {
		global String sageContractId;
	}
}