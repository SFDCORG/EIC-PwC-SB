public without sharing class OpportunityTMKChangeOwnerCtl {
	public String  oppId {get;set;}
	public Opportunity opp {get;set;}
	public String newOwnerID{get;set;}
	public String user{get;set;}
    public OpportunityTMKChangeOwnerCtl(ApexPages.StandardController sd) {
    	oppId = sd.getId();
    	opp = [Select Id,OwnerId From Opportunity Where Id =: oppId];
    	user=userinfo.getName();
    }

    public PageReference AssignOpp(){
    	try{
    		opp.OwnerId = newOwnerID;
    		update opp;
    		PageReference ref = new PageReference('/'+opp.Id);
    		return ref;
    	}catch(Exception e){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
    		return null;
    	}
    }
	public PageReference cancel(){
		PageReference ref = new PageReference('/'+oppId);
		return ref;
	}
}