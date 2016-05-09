/**************************************************************************************************
 * Name: SchedulingTableCheckingTrigger
 * Object: Scheduling_Table__c
 * Purpose: Insert Scheduling Table Checking Record for scheduling Table checking report
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-07
 * Modify History:
 * 2016-04-18        Create this trigger
 **************************************************************************************************/
trigger SchedulingTableCheckingTrigger on Scheduling_Table__c(after insert,after update) {
    if (Trigger.isUpdate) {
        for (Scheduling_Table__c schtable : trigger.new) {   
            Scheduling_Table__c oldschtable = trigger.oldmap.get(schtable.Id);
            if (schtable.isActive__c && (
                    oldschtable.Source__c != schtable.Source__c || 
                    oldschtable.Project__c!=schtable.Project__c)) {
                SchedulingTableRelatedController.generateTableCheckRecords(schtable.Id);
            } 
            else if (!schtable.isActive__c) {
                SchedulingTableRelatedController.deleteCheckRecords(schtable.Id);
            }
            else if (schtable.isActive__c && !oldschtable.isActive__c) {
                SchedulingTableRelatedController.generateTableCheckRecords(schtable.Id);
            }
        }
    }

    if (Trigger.isInsert) {
        for (Scheduling_Table__c schtable : trigger.new) {  
            if (schtable.IsActive__c) {
                SchedulingTableRelatedController.generateTableCheckRecords(schtable.Id);
            }
        }
    }
}