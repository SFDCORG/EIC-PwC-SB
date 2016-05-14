/**************************************************************************************************
 * Name: ServicingTableSchedulableTest
 * Object: Servicing_Table__c
 * Purpose: Test class for ServicingTableSchedulable
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History: 
 * 2016-05-10   Vicia Wang   Writes comments in this format and format the class
***************************************************************************************************/
@isTest
private class ServicingTableSchedulableTest {
	@isTest static void method() {
		User u = [Select Id From User Where Id = :Userinfo.getUserId()];
    	system.runAs(u){
    		CreateUserUtil.CreateUserForAppointment();
    	}
		Servicing_Table__c st = new Servicing_Table__c();
		st.User__c = [Select Id From User Where Email = 'grouptmk400a@eiceducation.com.cn.testcode'].Id;
    	st.Order_No__c = '1';
    	st.Business_Line__c = '留学,考培';
    	st.Intended_City__c = '全部';
    	st.IsLocal__c = '本地,异地';
    	st.MonS1__c = null;
    	st.MonE1__c = null;
    	st.MonS2__c = null;
    	st.MonE2__c = null;
    	st.TueS1__c = null;
    	st.TueE1__c = null;
    	st.TueS2__c = null;
    	st.TueE2__c = null;
    	st.WedS1__c = null;
    	st.WedE1__c = null;
    	st.WedS2__c = null;
    	st.WedE2__c = null;
    	st.ThuS1__c = null;
    	st.ThuE1__c = null;
    	st.ThuS2__c = null;
    	st.ThuE2__c = null;
    	st.FriS1__c = null;
    	st.FriE1__c = null;
    	st.FriS2__c = null;
    	st.FriE2__c = null;
    	st.SatS1__c = null;
    	st.SatE1__c = null;
    	st.SatS2__c = null;
    	st.SatE2__c = null;
    	st.SunS1__c = null;
    	st.SunE1__c = null;
    	st.SunS2__c = null;
    	st.SunE2__c = null;
    	st.IsActived__c = true;
    	insert st;

    	Servicing_Table__c st1 = new Servicing_Table__c();
		st1.User__c = [Select Id From User Where Email = 'grouptmk400a@eiceducation.com.cn.testcode'].Id;
    	st1.Order_No__c = '1';
    	st1.Business_Line__c = '留学,考培';
    	st1.Intended_City__c = '全部';
    	st1.IsLocal__c = '本地,异地';
    	st1.MonS1__c = null;
    	st1.MonE1__c = null;
    	st1.MonS2__c = null;
    	st1.MonE2__c = null;
    	st1.TueS1__c = null;
    	st1.TueE1__c = null;
    	st1.TueS2__c = null;
    	st1.TueE2__c = null;
    	st1.WedS1__c = null;
    	st1.WedE1__c = null;
    	st1.WedS2__c = null;
    	st1.WedE2__c = null;
    	st1.ThuS1__c = null;
    	st1.ThuE1__c = null;
    	st1.ThuS2__c = null;
    	st1.ThuE2__c = null;
    	st1.FriS1__c = null;
    	st1.FriE1__c = null;
    	st1.FriS2__c = null;
    	st1.FriE2__c = null;
    	st1.SatS1__c = null;
    	st1.SatE1__c = null;
    	st1.SatS2__c = null;
    	st1.SatE2__c = null;
    	st1.SunS1__c = null;
    	st1.SunE1__c = null;
    	st1.SunS2__c = null;
    	st1.SunE2__c = null;
    	st1.IsActived__c = false;
    	insert st1;

    	Test.startTest();

      	// Schedule the test job
      	String jobId = System.schedule(
            'ServicingTableSchedulable',
            '0 0 0 15 3 ? 2022', 
            new ServicingTableSchedulable()
        );

      	Test.stopTest();
	}
}