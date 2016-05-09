/**************************************************************************************************
 * Name: AutoResetTableOrder_Monthly
 * Object: Scheduling_Table_Order__c
 * Purpose: Monthly Scheduling Reset Scheduling Table Order According to the Reset Cycle on the Scheduling Table 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 **************************************************************************************************/
global class AutoResetTableOrder_Monthly implements Schedulable {

    global void execute(SchedulableContext sc) {

        String query = 'SELECT Id FROM Scheduling_Table_Order__c ' +
                       'WHERE Scheduling_Table__c IN (SELECT Id FROM Scheduling_Table__c ' +
                                                     'WHERE Auto_Reset_Cycle__c=\'月\' AND isActive__c=true)';
        AutoResetTableOrder jobs = new AutoResetTableOrder(query);
        Database.executeBatch(jobs);
    }
}