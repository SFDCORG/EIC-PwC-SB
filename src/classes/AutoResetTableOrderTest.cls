@isTest
private class AutoResetTableOrderTest {

    static testMethod void AutoResetTableOrder() {
        Organization__c org = new Organization__c ();
        org.name = 'test';
        org.City__c = '上海';
        org.Front_Desk__c = UserInfo.getUserId();
        org.RecordTypeID = '012280000009bCeAAI';
        org.OwnerId = UserInfo.getUserId();
        org.Department__c = '澳新部';
        org.Office__c = '人民广场';
        insert org;

        Scheduling_Table__c sctable = new Scheduling_Table__c ();
        sctable.Name = 'test';
        sctable.Organization__c = org.Id;
        sctable.Front_Desk__c = org.Front_Desk__c;
        sctable.Intercept__c = '分配至顾问';
        sctable.Project__c = '澳大利亚';
        sctable.Source__c = '普通商机';
        sctable.Department__c = org.Department__c;
        sctable.isActive__c = true;
        sctable.City__c = '上海';
        sctable.Manager__c = Userinfo.getUserId();
        sctable.Auto_Reset_Cycle__c = '日';
        insert sctable;

        Scheduling_Table_Line__c sctline = new Scheduling_Table_Line__c ();
        sctline.Project__c = '澳大利亚';
        sctline.Source__c = '普通商机';
        sctline.Monday_Time__c = '√';
        sctline.Start_Working_Time__c = '08:00';
        sctline.End_Working_Time__c = '13:00';
        sctline.User__c = Userinfo.getUserId();
        sctline.Daily_Opportunities__c = 1;
        sctline.Monthly_Opportunities__c = 2;
        sctline.Scheduling_Table__c = sctable.Id;
        insert sctline;

        Scheduling_Table_Order__c schOrder = new Scheduling_Table_Order__c ();
        schOrder.Indicator__c = true;
        schOrder.Order__c = 1;
        schOrder.Scheduling_Table__c = sctable.Id;
        schOrder.User__c = Userinfo.getUserId();
        insert schOrder;

        Test.startTest();

        String schTime = '0 10 * * 1-12 ? *';

         // Daily Reset
         AutoResetTableOrder_sch schD = new  AutoResetTableOrder_sch ();
         System.schedule('AutoResetD', schTime, schD);

         //Weekly Reset
         sctable.Auto_Reset_Cycle__c = '周';
         update sctable;
         AutoResetTableOrder_Weekly schW = new  AutoResetTableOrder_Weekly ();
         System.schedule('AutoResetW', schTime, schW);

         // Monthly Reset
         sctable.Auto_Reset_Cycle__c = '月';
         update sctable;
         AutoResetTableOrder_Monthly schM = new  AutoResetTableOrder_Monthly ();
         System.schedule('AutoResetM', schTime, schM);

         Test.stopTest();
    }
}