/**************************************************************************************************
 * Name: ClearTasksBatch
 * Object: Task
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
global class ClearTasksBatch implements Database.Batchable<sObject> {

    global final  String query;

    global ClearTasksBatch (String q) {
        query = q;
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext BC, List<Sobject> scope) {

        List<Task> completeTasks = new List<Task> ();
        List<Task> delTasks = new List<Task> ();
        Datetime dt = System.Now();
        dt = dt.addDays(-7);
        System.debug('LoggingLevel.INFO, *** dt: ' + dt);

        for (sobject s : scope) {

            Task tazk = (Task) s;

            if (tazk.LastModifiedDate <= dt && tazk.Status == 'Completed') {

                delTasks.add(tazk);
            } else if (tazk.Status != 'Completed') {

                tazk.Status = 'Completed';
                completeTasks.add(tazk);
            }
        }

        if (delTasks.size() > 0) delete delTasks;
        if (completeTasks.size() > 0) update completeTasks;
    }

    global void finish (Database.BatchableContext BC) { }
}