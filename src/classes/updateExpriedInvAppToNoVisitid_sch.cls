/**************************************************************************************************
 * Name: updateExpriedInvAppToNoVisitid_sch
 * Object: Appoitment__c
 * Purpose: Schedule class for updating expired appointment
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08        Create this class
 **************************************************************************************************/
global class updateExpriedInvAppToNoVisitid_sch implements Schedulable {
    global void execute(SchedulableContext sc) {
        Datetime td = System.now();
        String query = 'SELECT Id, Status__c FROM Appoitment__c ' +
        	'WHERE Status__c = \'跟进中\' ' + 
        	'AND Due_Date__c < ' + td.format('yyyy-MM-dd');
        query += ' and RecordTypeId = \'' + RecordTypeRelated.Invitation_App + '\'';
        Database.executeBatch(new updateExpriedInvAppToNoVisitid_Bth(query), 200);
    }
}