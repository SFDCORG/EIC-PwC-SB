/**************************************************************************************************
 * Name: ServiceWrapperTest
 * Object: Contract__c, Opportunity
 * Purpose: a test class for REST API of SAGE contract system, Jiaowu contract system.
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest
private class ServiceWrapperTest {
	// Does the test for Sage ContractService
    static testMethod void testSageContractService() {
        User user = TestObjectFactory.createUser();

        System.runAs(user) {
        	Account acc = TestObjectFactory.createAccount('19099990000');
			List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
			oppList[0].ext_Opportunity_id__c = 'C123456';
			update oppList;

			List<ServiceWrapper.SageContract> contract = new List<ServiceWrapper.SageContract>();
			ServiceWrapper.SageContract sageCon = new ServiceWrapper.SageContract(
				acc.Id,
		        oppList[0].Id,
		        'C000001',
		        'SC-000001',
		        'Paid',
		        Constants.COUNSELLING_CN,
		        Constants.US_CN,
		        '60000',
		        '60000',
		        '100',
		        '2016-04-29',
		        'C01014072900017',
		        'Y',
		        'Consultant Andy',
		        'C123456');
			
	        contract.add(sageCon);

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/UpdContSta';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = ContractService.doPost(contract);
            System.debug(LoggingLevel.INFO, '*** result: ' + result);
            System.assertEquals(TRUE, result.contains('Sage合同信息同步成功!'));
            
            String connection = ContractService.doGet();
            System.assertEquals(TRUE, connection.contains('接口测试页'));
        } 
    }

    // Does the test for Sage contract payment
    static testMethod void testSagePaymentService() {
        User user = TestObjectFactory.createUser();

        System.runAs(user) {
        	Account acc = TestObjectFactory.createAccount('19099990000');
			List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
			Contract__c contract = TestObjectFactory.createContract(oppList[0]);
			contract.External_Contract_Id__c = 'C123456';
			update contract;

			List<ServiceWrapper.SagePayment> pay = new List<ServiceWrapper.SagePayment>();
			ServiceWrapper.SagePayment payment = new ServiceWrapper.SagePayment(
   				acc.Id,
   				oppList[0].Id,
   				'C123456',
   				'P123467',
   				'Full',
   				'10500.00',
   				're',
   				'finished');
	        pay.add(payment);

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/UpdPayment';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = PaymentService.doPost(pay);
            System.debug(LoggingLevel.INFO, '*** result: ' + result);
            System.assertEquals(TRUE, result.contains('付款信息同步成功!'));
        } 
    }

    // Does the test for Sage payment status
    static testMethod void testSagePaymentStatusService() {
        User user = TestObjectFactory.createUser();

        System.runAs(user) {
        	Account acc = TestObjectFactory.createAccount('19099990000');
			List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);
			Contract__c contract = TestObjectFactory.createContract(oppList[0]);
			contract.External_Contract_Id__c = 'C123456';
			update contract;

			List<ServiceWrapper.PaymentStatus> JSONData = new List<ServiceWrapper.PaymentStatus>();
			ServiceWrapper.PaymentStatus paymentStatus = new ServiceWrapper.PaymentStatus();
	  		paymentStatus.custid = acc.Id;
			paymentStatus.aoppid = oppList[0].Id;
			paymentStatus.contid = contract.External_Contract_Id__c;
			paymentStatus.typ1 = 'Y';
			paymentStatus.typ2 = 'Y';
	        JSONData.add(paymentStatus);

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/UpdPaySta';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = PaymentStatusService.doPost(JSONData);
            System.debug(LoggingLevel.INFO, '*** result: ' + result);
            System.assertEquals(TRUE, result.contains('全款付款确认信息同步成功!'));
        } 
    }

    // Does the test for Sage updating opportunity
    static testMethod void testSageUpdateOpportunityService() {
        User user = TestObjectFactory.createUser();

        System.runAs(user) {
        	Account acc = TestObjectFactory.createAccount('19099990000');
			List<Opportunity> oppList = TestObjectFactory.createOpportunities(acc);

			List<ServiceWrapper.OppInfo> JSONData = new List<ServiceWrapper.OppInfo>();
			ServiceWrapper.UpdateCustInfo(new List<ServiceWrapper.CustInfo>());
			ServiceWrapper.CustInfo customerInfo = new ServiceWrapper.CustInfo();
			ServiceWrapper.OppInfo oppInformation = new ServiceWrapper.OppInfo();
	  		oppInformation.aoppid = oppList[0].Id;
			oppInformation.coursetype = '2';
			oppInformation.plantime = '2016-04-29';
	        JSONData.add(oppInformation);

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/UpdAopp';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = UpdateAoppService.doPost(JSONData);
            System.debug(LoggingLevel.INFO, '*** result: ' + result);
            System.assertEquals(TRUE, result.contains('商机信息同步成功!'));
        } 
    }

    // Does the test for IntServContractService
    static testMethod void testJiaowuContractService() {
        User user = TestObjectFactory.createUser();

        System.runAs(user) {
        	Account acc = TestObjectFactory.createAccount('19099990000');
			Opportunity opp = TestObjectFactory.createTestprepOpportunity(acc);

			List<ServiceWrapper.IntServPayment> jiaowuPaymentList = new List<ServiceWrapper.IntServPayment>();
			List<ServiceWrapper.CourseItem> jiaowuCourseList = new List<ServiceWrapper.CourseItem>();
			List<ServiceWrapper.RegisterInfo> registerList = new List<ServiceWrapper.RegisterInfo>();

       		ServiceWrapper.IntServPayment jiaowuPayment = new ServiceWrapper.IntServPayment();
        	jiaowuPayment.DateStamp = '2016-04-29';
			jiaowuPayment.Money = '1000';
			jiaowuPaymentList.add(jiaowuPayment);

			ServiceWrapper.CourseItem jiaowuCourse = new ServiceWrapper.CourseItem();
        	jiaowuCourse.Code = 'SAT';
			jiaowuCourse.Name = 'SAT';
			jiaowuCourseList.add(jiaowuCourse);

			ServiceWrapper.RegisterInfo register = new ServiceWrapper.RegisterInfo();
			register.Code = 'Jiaowu Register 1';
        	register.Date_Stamp = '2016-04-29';
        	register.CS_Hour = '60';
        	register.CS_Hour_Quit = '60';
        	register.CS_hour_Effective = '60';
        	register.Receivables_Money = '1000';
        	register.Pay_Money = '1000';
        	register.Arrears_Money = '0';
        	register.Price = '100';
        	register.Price_Discount = '100';
        	register.Fee = '1000';
        	register.Fee_Quit = '1000';
        	register.Fee_Service = '100';
        	register.Fee_Quit_Service = '100';
        	register.Fee_Additional = '100';
        	register.Pay_Records = jiaowuPaymentList;
        	register.Curriculas = jiaowuCourseList;
        	registerList.add(register);

			ServiceWrapper.IntServContract contract = new ServiceWrapper.IntServContract();
			contract.CRM_Student_ID =  acc.Id;
        	contract.CRM_Opportunity_ID = opp.Id;
        	contract.CRM_Contract_ID = 'T000001';
        	contract.BS_Event_Type = '1';
        	contract.BS_Register_Infos = registerList;

			// Does request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/UpdContSta';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            String result = IntServContractService.doPost(contract);
            System.debug(LoggingLevel.INFO, '*** result: ' + result);
            System.assertEquals(TRUE, result.contains('Contract Inserted!'));
            
            String connection = IntServContractService.doGet();
            System.assertEquals(TRUE, connection.contains('SFDC Service与启德综合业务系统对接接口'));
        } 
    }
}