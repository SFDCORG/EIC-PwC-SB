/**************************************************************************************************
 * Name: updateSchedulingTableLineOPPMonthly
 * Object: Scheduling_Table_Line__c
 * Purpose: Batch update scheduling table line
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
global class updateSchedulingTableLineOPPMonthly implements Schedulable {
    global void execute(SchedulableContext sc) {
        String query = 
            'SELECT Id, Monthly_Opportunities__c ' +
            'FROM Scheduling_Table_Line__c ' +
            'WHERE Monthly_Opportunities__c != 0';

        updateSchedulingTableLineOPPMthly_bth ulb = 
            new updateSchedulingTableLineOPPMthly_bth(query);
        Database.executeBatch(ulb);
    }
}