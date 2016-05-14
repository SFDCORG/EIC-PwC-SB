/**************************************************************************************************
 * Name: AutoResetTableOrderTest
 * Object: Scheduling_Table_Order__c
 * Purpose: a test class for AutoResetTableOrder
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-12
 * Modify History:
 * 2016-05-12    Vicia Wang    Writes comments AND optimizes the code
 **************************************************************************************************/
@isTest
private class AutoResetTableOrderTest {

    static testMethod void AutoResetTableOrder() {
        
        User admin = TestObjectFactory.createUser();

        System.runAs(admin) {

            // Initializes the org hierarchy
            Organization__c org = TestObjectFactory.createOrg(Constants.CITY_SH_CN, 
                                                              'Counselling', 
                                                              Constants.COUNSELLING_CN);
            insert org;

            Scheduling_Table__c scheduleTable = TestObjectFactory.createSchedulingTable(org);
            insert scheduleTable;

            Scheduling_Table_Line__c scheduleLine = TestObjectFactory.createSchedulingTableLine(scheduleTable);
            insert scheduleLine;

            Scheduling_Table_Order__c scheudleOrder = TestObjectFactory.createScheTableOrder(scheduleTable);
            insert scheudleOrder;
            
            String schTime = '0 10 * * 1-12 ? *';

            // Daily Reset
            AutoResetTableOrder_sch schD = new  AutoResetTableOrder_sch ();
            String dayJobId = System.schedule('AutoResetD', schTime, schD);
            // Gets the information from the CronTrigger API object
            CronTrigger dayCT = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                 FROM CronTrigger 
                                 WHERE id = : dayJobId];
            
            // Verifies the expressions are the same
            System.assertEquals(schTime, dayCT.CronExpression);

            //Weekly Reset
            scheduleTable.Auto_Reset_Cycle__c = '周';
            update scheduleTable;
            AutoResetTableOrder_Weekly schW = new  AutoResetTableOrder_Weekly ();
            String weekJobId = System.schedule('AutoResetW', schTime, schW);
            // Gets the information from the CronTrigger API object
            CronTrigger weekCT = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                  FROM CronTrigger 
                                  WHERE id = : weekJobId];
            
            // Verifies the expressions are the same
            System.assertEquals(schTime, weekCT.CronExpression);
            
            // Monthly Reset
            scheduleTable.Auto_Reset_Cycle__c = '月';
            update scheduleTable;            
            AutoResetTableOrder_Monthly schM = new  AutoResetTableOrder_Monthly ();
            String monthJobId = System.schedule('AutoResetM', schTime, schM);
            // Gets the information from the CronTrigger API object
            CronTrigger monthCT = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                   FROM CronTrigger 
                                   WHERE id = : monthJobId];
            
            // Verifies the expressions are the same
            System.assertEquals(schTime, monthCT.CronExpression);
        }
    }
}