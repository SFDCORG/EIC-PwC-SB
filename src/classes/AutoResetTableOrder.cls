/**************************************************************************************************
 * Name: AutoResetTableOrder
 * Object: Scheduling_Table_Order__c
 * Purpose:Batch job for Resting Scheduling Table Order
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 **************************************************************************************************/
global class AutoResetTableOrder implements Database.Batchable<sObject> {
    
    global final String query;
    
    global AutoResetTableOrder (String q) {
        query = q;
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {

        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, list<Sobject> scope) {

        List<Scheduling_Table_Order__c> schOrders = (List<Scheduling_Table_Order__c>) scope;
        for (Scheduling_Table_Order__c schOrder : schOrders) {

            schOrder.sys_Fake_Tick__c = 0;
            schOrder.Count__c = 0;
        }
        update schOrders;
    }

    global void finish(Database.BatchableContext BC) {}
}