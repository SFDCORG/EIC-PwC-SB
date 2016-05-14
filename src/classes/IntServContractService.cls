/************************************************
综合考培业务系统Service
@Test url: https://{instance_url}.salesforce.com/services/apexrest/UpdIntServContract

{   
    "intserv" :{  
        "CRM_Student_ID": "00137000003tK5u",
        "CRM_Opportunity_ID" : "00637000005k25G",
        "CRM_Contract_ID":"Contact001",     
        "BS_Event_Type":1,          
        "BS_Register_Infos":[{
            "Code":"AA",                 
            "Date_Stamp":"2015-09-09", 
            "CS_Hour":100,               
            "CS_Hour_Quit":200,          
            "CS_Hour_Effective":100,     
            "Receivables_Money":0,      
            "Pay_Money":0,             
            "Arrears_Money":0,         
            "Price":10,
            "Price_Discount":0, 
            "Fee":110,                
            "Fee_Quit":20, 
            "Fee_Service":50,
            "Fee_Quit_Service":20,
            "Fee_Additional":20,
            "Pay_Records":[{
                           "DateStamp":"2015-09-09",
                           "Money":0
                            }],
            "Curriculas":[{
                   "Code":"0001",  
                   "Name":"托福听力"
                 },
                 {
                   "Code":"0002", 
                   "Name":"托福阅读"
                 }]
        }]
    }
}    

************************************************/
//Create and Update Payment
@RestResource(urlMapping = '/UpdIntServContract')
global without sharing class IntServContractService {

    @HttpPost
    global static String doPost (ServiceWrapper.IntServContract intserv) {

        List<IntServ_Course__c> coursers = new List<IntServ_Course__c> ();
        List<IntServ_Payment__c> payments = new List<IntServ_Payment__c> ();

        try{

            // Upserts contract
            System.debug(LoggingLevel.INFO, '*** intserv: ' + intserv);
            Contract__c sc = ServiceWrapper.MapIntServContract(intserv);
            upsert sc External_Contract_Id__c;

            // Upserts related registers
            List<Register__c> regs = ServiceWrapper.MapIntServReg(sc.Id, intserv.BS_Register_Infos);
            upsert regs Code__c;

            // Upserts related coursers
            // Upserts related payments
            for (Register__c reg : regs) {

                for (ServiceWrapper.RegisterInfo regInfo: intserv.BS_Register_Infos) {

                    if (regInfo.Code == reg.Code__c) {
                        coursers.addAll(ServiceWrapper.MapIntServCourse(reg.Id, regInfo.Curriculas));
                        payments.addAll(ServiceWrapper.MapIntServPayment(reg.Id, regInfo.Pay_Records));
                    }
                }
            }
            upsert coursers;
            upsert payments;
        } catch (Exception e) {

            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize (message);
        }

        return JSON.serialize ('Contract Inserted!');
    }

    @HttpGet
    global static String doGet() {

        return 'SFDC Service与启德综合业务系统对接接口';
    }
}