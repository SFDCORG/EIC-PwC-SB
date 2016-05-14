/************************************************
 * Name: PaymentStatusService
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
@Test url: https://{instance_url}.salesforce.com/services/apexrest/UpdPaySta
  { "JSONData":{
    "custid":"00128000005yVZf",
    "aoppid":"00628000003xRjd",
    "contid":"600201",
    "typ1":"Y",
    "typ2":"Y"
    }
 }
************************************************/
// 付款信息是否全款
@RestResource(urlMapping = '/UpdPaySta')
global class PaymentStatusService {

    @HttpPost
    global static String doPost(List<ServiceWrapper.PaymentStatus> JSONData) {

        try {

            // Creates the interaction log
            InteractionLogUtil.CreateLog('SAGE Contract - New/Update Payment Status', JSON.serialize(JSONData));
            ServiceWrapper.UpdatePaymentStatus(JSONData);

        } catch(Exception e) {
            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
        }

        return JSON.serialize('全款付款确认信息同步成功!');
    }
}