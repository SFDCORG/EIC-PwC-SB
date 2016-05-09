/************************************************
Sage Contract Service
@Test url: https://{instance_url}.salesforce.com/services/apexrest/UpdContSta
{
    "contract": {
        "custid": "",
        "aoppid": "",
        "contid": "10",
        "contno": "X",
        "contsta": "已付款",
        "contprd": "留学",
        "contprds": "英国留学",
        "contamt": "80000",
        "contpaid": "60000",
        "contdis": "90.10",
        "contsysdat": "2015/09/16",
        "contpid": "C01014072900017"
    }
}
************************************************/
//Create and Update Contract
@RestResource(urlMapping = '/UpdContSta')
global class ContractService {

    @HttpPost
    global static String doPost(List<ServiceWrapper.SageContract> contract) {
        try{

            // Creates the interaction log
            InteractionLogUtil.CreateLog('SAGE Contract - New/Update', JSON.serialize(contract));
            List<Contract__c> sc = ServiceWrapper.MapSageContract(contract);

            if (sc.size() == 0) {

                return JSON.serialize('未正确生成合同, 请重新推送!');
            } else {

                upsert sc External_Contract_Id__c;
                return JSON.serialize('Sage合同信息同步成功!');
            }

        } catch(Exception e) {
            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
        }
    }

    @HttpGet
    global static String doGet() {
        return '接口测试页';
    }
}