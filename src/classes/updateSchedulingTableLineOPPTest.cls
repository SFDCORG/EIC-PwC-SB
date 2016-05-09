/**************************************************************************************************
 * Name: updateSchedulingTableLineOPPTest
 * Object: Organization__c
 * Purpose: Test class for updateSchedulingTableLineOPP
 * Author: Vicia Wang (vicia.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
@isTest
private class updateSchedulingTableLineOPPTest {
    @testSetup static void setup() { 
   	    Organization__c org = new Organization__c();
	    org.name = 'test';
	    org.City__c = '上海';
	    org.Front_Desk__c = UserInfo.getUserId();
	    org.RecordTypeID = '012280000009bCeAAI';
	    org.OwnerId = userInfo.getUserId();
	    org.Department__c = '澳新部';
	    org.Office__c = '人民广场';
	    insert org;

	    Scheduling_Table__c sctable = new Scheduling_Table__c();
	    sctable.Name = 'test';
	    sctable.Organization__c = org.Id;
	    sctable.Front_Desk__c = org.Front_Desk__c;
	    sctable.Intercept__c =  '分配至顾问';
	    sctable.Project__c = '澳大利亚';
	    sctable.Source__c = '普通商机';
	    sctable.Department__c = org.Department__c;
	    sctable.isActive__c = true;
	    sctable.City__c = '上海';
	    sctable.Manager__c = userinfo.getUserId();
	    insert sctable;

	    Scheduling_Table_Line__c sctline = new Scheduling_Table_Line__c();
	    sctline.Project__c = '澳大利亚';
	    sctline.Source__c = '普通商机';
	    sctline.Monday_Time__c = '√';
	    sctline.Start_Working_Time__c = '08:00';
	    sctline.End_Working_Time__c = '13:00';
	    sctline.User__c = userinfo.getUserId();
	    sctline.Daily_Opportunities__c = 1;
	    sctline.Monthly_Opportunities__c = 2;
	    sctline.Scheduling_Table__c = sctable.Id;
	    insert sctline;
   }

    static testMethod void functionTest() {
   		test.startTest();

   		updateSchedulingTableLineOPPDaily schdaily = new updateSchedulingTableLineOPPDaily();
   		updateSchedulingTableLineOPPMonthly schmon = new updateSchedulingTableLineOPPMonthly();

        string schTime = '0 10 * * 1-12 ? *';
        system.schedule('Daily', schTime,schdaily);
        system.schedule('Monthly', schTime,schmon);

   		test.stopTest();
   }
}