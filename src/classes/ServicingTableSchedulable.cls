global class ServicingTableSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	//change servicing table 
    	List<Servicing_Table__c> srvts = [Select Id,IsActived__c From Servicing_Table__c];
    	for(Servicing_Table__c st : srvts){
    		if(st.IsActived__c){
    			st.IsActived__c = false;
    		}else{
    			st.IsActived__c = true;
    		}
    	}
    	if(srvts.size()>0){
    		update srvts;
    	}
    }
}