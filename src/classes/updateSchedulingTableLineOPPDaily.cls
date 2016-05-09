/**************************************************************************************************
 * Name: updateSchedulingTableLineOPPDaily
 * Object: Scheduling_Table_Line__c
 * Purpose: Update scheduling table line
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 05-08    Vicia Wang    Create this class
 **************************************************************************************************/
global class updateSchedulingTableLineOPPDaily implements Schedulable {
    global void execute(SchedulableContext sc) {
    	String query = 
            'SELECT Id, Daily_Opportunities__c ' + 
            'FROM Scheduling_Table_Line__c ' +
            'WHERE Daily_Opportunities__c != 0';

    	updateSchedulingTableLineOPPDaily_batch ulb = 
            new updateSchedulingTableLineOPPDaily_batch(query);
    	Database.executeBatch(ulb);
    }
}