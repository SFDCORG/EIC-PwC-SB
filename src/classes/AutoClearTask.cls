/**************************************************************************************************
 * Name: AutoClearTask
 * Object: task
 * Purpose: schedule clear no use tasks 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
global class AutoClearTask implements Schedulable {

    global void execute (SchedulableContext sc) {

        String query = 'SELECT Id, status, LastModifiedDate FROM Task WHERE IsReminderSet = false';
        ClearTasksBatch ctb = new ClearTasksBatch (query);
        Database.executeBatch(ctb);
    }
}