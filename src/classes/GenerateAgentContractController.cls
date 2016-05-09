public with sharing class GenerateAgentContractController {
    Opportunity opp = new Opportunity();

    Contract_System__c sageSystem = Contract_System__c.getValues('Prepsmith Sage Contract');
    Contract_System__c sageSubcontract = Contract_System__c.getValues('Prepsmith Sage SubContract');

    public GenerateAgentContractController() {
        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        
        opp = [
            SELECT (SELECT External_Contract_Id__c FROM Contracts__r WHERE Sage_Main_Contract_Id__c IN (NULL, '')), 
                Account.Name, Account.Gender__c, Account.ID_Number__c, Account.Subagent_Mobile__c, 
                Account.ext_Customer_id__c, Account.Is_Emergency__c,
                AccountId, ext_Opportunity_id__c, Consultation_Mode__c, Intended_City__c, Department__c, Project__c, Contract_City__c
                FROM Opportunity
                WHERE Id =: oppId];
    }

    public PageReference sendPostRequest() {
        User currentUser = [SELECT Sage_UserName__c FROM User WHERE Id =:UserInfo.getUserId()];
        String requestUrl;
        // Create main contract
        if (opp.Contracts__r.size() == 0) {
            requestUrl = sageSystem.Endpoint__c;
            SASGPicklistMapping__c valmap = SASGPicklistMapping__c.getAll().get('SASGPicklistMapping');
            Map<String,String> citymap = SASGMapConstruct(valmap,'Intended_City__c');
            Map<String,String> projmap = SASGMapConstruct(valmap,'Project__c');
            Map<String,String> depmap = SASGMapConstruct(valmap,'Department__c');
            Map<String,String> methodmap = SASGMapConstruct(valmap,'Consultation_Mode__c');      
            requestUrl += 'custid=' + opp.AccountId;
            requestUrl += '&oldcustid=' + opp.Account.ext_Customer_id__c;
            requestUrl += '&oldaoppid=' + opp.ext_Opportunity_id__c;
            requestUrl += '&aoppid=' + opp.Id;
            requestUrl += '&cnname=' + opp.Account.Name;
            requestUrl += '&issubagent=' + 'Y';
            requestUrl += '&mob=' + opp.Account.Subagent_Mobile__c;
            requestUrl += '&idcard=' + opp.Account.ID_Number__c;
            
            if (opp.Account.Is_Emergency__c) {
                requestUrl += '&isemergency=Y';
            } else {
                requestUrl += '&isemergency=N';
            }
            requestUrl += '&idcard=' + opp.Account.ID_Number__c;
            requestUrl += '&method='+ String.valueOf(methodmap.get(opp.Consultation_Mode__c)==null?'W':methodmap.get(opp.Consultation_Mode__c))+
                          '&country='+ String.valueOf(projmap.get(opp.Project__c)==null?'US':projmap.get(opp.Project__c)) +
                          '&cpy='+ String.valueOf(citymap.get(opp.Contract_City__c)==null?'ABC':citymap.get(opp.Contract_City__c));                
            if (opp.Department__c == '学游项目部') {
                requestUrl += '&dep=AAX';

            } else {
                requestUrl += '&dep='+ String.valueOf(Utils.countryMapDeptCode.get(opp.Project__c) ==null?'AAC':Utils.countryMapDeptCode.get(opp.Project__c));
            }

        // Create the subcontract
        } else {
            requestUrl = sageSubcontract.Endpoint__c;
            requestUrl += 'contid=' + opp.Contracts__r[0].External_Contract_Id__c;
        }      
        PageReference newContractPage = new PageReference(requestUrl);
        System.debug(LoggingLevel.INFO, '*** requestUrl: ' + requestUrl);
        newContractPage.setRedirect(TRUE);
        return newContractPage;
    }

    public Map<String,String> SASGMapConstruct(SASGPicklistMapping__c obj,String s){
        String val1 = '';
        String val2 = '';
        if(s=='Project__c'){
            val1 = obj.CRMCountry1__c+((obj.CRMCountry2__c==null || obj.CRMCountry2__c=='')?'':(','+obj.CRMCountry2__c));
            val2 = obj.SASGCountry1__c+((obj.SASGCountry2__c==null || obj.SASGCountry2__c=='')?'':(','+obj.SASGCountry2__c));
        }else if(s=='Intended_City__c'){
            val1 = obj.CRMCity1__c+((obj.CRMCity2__c==null || obj.CRMCity2__c=='')?'':(','+obj.CRMCity2__c));
            val2 = obj.SASGCity1__c+((obj.SASGCity2__c==null || obj.SASGCity2__c=='')?'':(','+obj.SASGCity2__c));
        }else if(s=='Department__c'){
            val1 = obj.CRMDepartment1__c+((obj.CRMDepartment2__c==null || obj.CRMDepartment2__c=='')?'':(','+obj.CRMDepartment2__c));
            val2 = obj.SASGDepartment1__c+((obj.SASGDepartment2__c==null || obj.SASGDepartment2__c=='')?'':(','+obj.SASGDepartment2__c));
        }else if(s=='Consultation_Mode__c'){
            val1 = obj.CRMMethod1__c+((obj.CRMMethod2__c==null || obj.CRMMethod2__c=='')?'':(','+obj.CRMMethod2__c));
            val2 = obj.SASGMethod1__c+((obj.SASGMethod2__c==null || obj.SASGMethod2__c=='')?'':(','+obj.SASGMethod2__c));
        }
        if(val1.length()==0 || val2.length()==0){
            return new Map<String,String>();
        }
        List<String> array1 = val1.split(',');
        List<String> array2 = val2.split(',');
        if(array1.size() != array2.size()){
            return new Map<String,String>();
        }
        Map<String,String> m = new Map<String,String>();
        for(Integer i = 0; i<array1.size(); i++){
            m.put(array1[i],array2[i]);
        }
        return m;

    }

    public class SageNewContract {
        public String result;
        public String msg;

    }

}