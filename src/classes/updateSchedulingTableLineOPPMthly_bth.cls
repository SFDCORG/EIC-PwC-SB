/**************************************************************************************************
 * Name: updateSchedulingTableLineOPPMthly_bth
 * Object: Scheduling_Table_Line__c
 * Purpose: Update Scheduling table line
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
global class updateSchedulingTableLineOPPMthly_bth implements Database.Batchable<sObject> {
    global final  String query;
    
    global updateSchedulingTableLineOPPMthly_bth(String q) {    
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Scheduling_Table_Line__c> schetableLines = new List<Scheduling_Table_Line__c>();

        for (sobject s : scope) {
            Scheduling_Table_Line__c schTableline = (Scheduling_Table_Line__c)s;
            schTableline.Monthly_Opportunities__c = 0;
            schetableLines.add(schTableline);
        }

        if (schetableLines.size() > 0) {
            update schetableLines;
        }
    }

    global void finish(Database.BatchableContext BC) {}
}