/************************************************
 * Name: PaymentService
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
 @Test url: https://{instance_url}.salesforce.com/services/apexrest/UpdPayment
 {
    "pay":[
    {"custid":"00128000005yVZf",
    "aoppid":"00628000003xRjd",
    "contid":"162067",
    "payid":"45110",
    "property":"Full",
    "amt":"10500.00",
    "typ":"re",
    "sta":"finished"},
    {"custid":"00128000005yVZf",
    "aoppid":"00628000003xRjd",
    "contid":"162067",
    "payid":"98205",
    "property":"Full",
    "amt":"1700.00",
    "typ":"rt",
    "sta":"finished"}
    ]
 }
************************************************/
// Creates and Update Payment
@RestResource(urlMapping = '/UpdPayment')
global class PaymentService {

    @HttpPost
    global static String doPost (List<ServiceWrapper.SagePayment> pay) {

        try {

            // Creates the interaction log
            InteractionLogUtil.CreateLog('SAGE Contract - New/Update Payment', JSON.serialize(pay));
            List<Sage_Payment__c> sc = ServiceWrapper.MapSagePayment(pay);
            upsert sc Payment_Id__c;

        } catch(Exception e) {
            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
        }

        return JSON.serialize('付款信息同步成功!');
    }
}