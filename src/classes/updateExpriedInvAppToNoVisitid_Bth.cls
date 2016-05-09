/**************************************************************************************************
 * Name: updateExpriedInvAppToNoVisitid_Bth
 * Object: Appointment__c
 * Purpose: Batch update appointments
 * Author:  Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08        Create this class
 **************************************************************************************************/
global class updateExpriedInvAppToNoVisitid_Bth implements Database.Batchable<sObject> {
    public String query;
    
    global updateExpriedInvAppToNoVisitid_Bth(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        List<Appoitment__c> apps = new List<Appoitment__c>();
        for (Appoitment__c app : (List<Appoitment__c>) scope) {
            app.Status__c = '未到访';
            app.sys_unlock_app__c = true;
            apps.add(app);
        }

        if (apps.size() > 0) {
            update apps;
        }
    }

    global void finish(Database.BatchableContext BC) {}
}