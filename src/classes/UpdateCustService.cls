/**************************************************************************************************
 * Name: UpdateCustService
 * Object: Account
 * Purpose: Update account information from Sage system.
 * Author: Matthew Sun ()
 * Create Date: 2016-05-07
 * Modified History: 
 * 2016-05-07  Vicia Wang  Writes comments in this format
 *{"JSONData":[{
    "custid":"00128000008MXE4",
    "cnname":"leo 222",
    "mob":"13641234567",
    "idcard":"11323ddee2322",
    "birthday":"2015-10-01",
    "sex":"Male",
    "email":"",
    "qq":"",
    "msn":"",
    "homeadd":"addaddaddadds"}]
  }
***************************************************************************************************/
@RestResource(urlMapping='/UpdCust')
global class UpdateCustService{
    @HttpPost
    global static String doPost(List<ServiceWrapper.CustInfo> JSONData) {
        try {
            ServiceWrapper.UpdateCustInfo(JSONData);
        
        } catch (Exception e) {
            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
        }
        
        return JSON.serialize('学员信息同步成功!');
    }
}