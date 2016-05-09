/**************************************************************************************************
 * Name: updateSchedulingTableLineOPPDaily_batch
 * Object: Scheduling_Table_Line__c
 * Purpose: Batch update daily opportunities for scheduling table line
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
global class updateSchedulingTableLineOPPDaily_batch implements Database.Batchable<sObject> {
    global final String query;

    global updateSchedulingTableLineOPPDaily_batch(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        List<Scheduling_Table_Line__c> schetableLines = new List<Scheduling_Table_Line__c>();

        for (sobject s : scope) {
            Scheduling_Table_Line__c schTableline = (Scheduling_Table_Line__c)s;
            schTableline.Daily_Opportunities__c = 0;
            schetableLines.add(schTableline);
        }

        if (schetableLines.size() > 0) {
            update schetableLines;
        }
    }

    global void finish(Database.BatchableContext BC) {}
}