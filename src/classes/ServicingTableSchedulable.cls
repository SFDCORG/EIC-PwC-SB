/**************************************************************************************************
 * Name: ServicingTableSchedulable
 * Object: Servicing_Table__c
 * Purpose: Update Servicing Table status
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10  
 * Modify History:
 * 2016-05-10   Vicia Wang    Create this class
 **************************************************************************************************/
global class ServicingTableSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	// Change servicing table 
    	List<Servicing_Table__c> srvts = [Select Id, IsActived__c From Servicing_Table__c];
    	for (Servicing_Table__c st : srvts) {
    		if (st.IsActived__c) {
    			st.IsActived__c = false;
    		} else {
    			st.IsActived__c = true;
    		}
    	}
    	if (srvts.size() > 0) {
    		update srvts;
    	}
    }
}