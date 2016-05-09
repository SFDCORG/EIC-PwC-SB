/**************************************************************************************************
 * Name: UpdateCustServiceTest
 * Object: Account
 * Purpose: a test class for UpdateCustService
 * Author: Matthew Sun ()
 * Create Date: 2016-05-07
 * Modified History: 
 * 2016-05-07  Vicia Wang  Writes comments in this format
 *{"JSONData":[{
    "custid":"00128000008MXE4",
    "cnname":"Sage User Andy",
    "mob":"19099990000",
    "idcard":"341126199010102020",
    "birthday":"2015-10-01",
    "sex":"Male",
    "email":"",
    "qq":"",
    "msn":"",
    "homeadd":"SH CHINA"}]
  }
***************************************************************************************************/
@isTest
private class UpdateCustServiceTest {
    static testMethod void testUpdateCustService() {
        User runningUser = TestObjectFactory.createUser();

        System.runAs(runningUser) {
        	Account acc = TestObjectFactory.createAccount('19099990000');

			List<ServiceWrapper.CustInfo> JSONData = new List<ServiceWrapper.CustInfo>();
			ServiceWrapper.CustInfo customer = new ServiceWrapper.CustInfo();
			customer.custid = acc.Id;
    		customer.cnname = 'Sage User Andy';
    		customer.mob = '19099990000';
    		customer.idcard = '341126199010102020';
    		customer.birthday = '2015-10-01';
    		customer.sex = 'Male';
    		customer.email = 'Andy@eic.com.test';
    		customer.qq = '10102020';
    		customer.msn = '10102020';
    		customer.homeadd = 'SH CHINA';
			JSONData.add(customer);

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/UpdCust';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = UpdateCustService.doPost(JSONData);

            System.assertEquals(TRUE, result.contains('学员信息同步成功!'));
        }
    }
}