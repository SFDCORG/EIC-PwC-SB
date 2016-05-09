/**************************************************************************************************
 * Name: UpdateAoppService
 * Object: Opportunity
 * Purpose: Integration service for updating opportunity
 * Author: Vicia Wang (vicia.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 *
 * @url: https://{instance_url}.salesforce.com/services/apexrest/UpdAopp
 **************************************************************************************************/
@RestResource(urlMapping='/UpdAopp')
global class UpdateAoppService {
    @HttpPost
    global static String doPost(List<ServiceWrapper.OppInfo> JSONData) {
        try {
            ServiceWrapper.UpdateOppInfo(JSONData);
        } catch(Exception e) {
            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
        }
        
        return JSON.serialize('商机信息同步成功!');
    }
}