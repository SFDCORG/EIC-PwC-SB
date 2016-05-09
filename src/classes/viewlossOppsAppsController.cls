public with sharing class viewlossOppsAppsController {

	public ID oppID                     {get; set;} 
	public List<OppAppWrapper> oaList   {get; set;}

    public viewlossOppsAppsController(ApexPages.StandardController controller) {

    	oppID = OppID=ApexPages.CurrentPage().getparameters().get('oppID');
      oaList= new List<OppAppWrapper>();
    	List<Opportunity> oppList=[select id from Opportunity where Revive_Opportunity__c =:oppID];
      generateOppAppWrapper(oppList);

    }

    private void generateOppAppWrapper(List<Opportunity> oppList)
    {
          Map<ID,Set<Appoitment__c>> oppApps= new Map<ID,Set<Appoitment__c>>();
          for(Appoitment__c app:[select id, 
                                        Opportunity__c,
                                        name, 
                                        Description__c, 
                                        CreatedBy.Name, 
                                        RecordType.Name, 
                                        Appointment_Type__c, 
                                        Assign_To__r.Name, 
                                        sys_DueTime__c, 
                                        Status__c,
                                        CreatedDate, 
                                        Follow_Up_Result__c,
                                        LastModifiedDate,
                                        Opportunity__r.CreatedDate,
                                        Opportunity__r.LastModifiedDate,
                                        Opportunity__r.Owner.Name
                                        from Appoitment__c 
                                        where Opportunity__c in :oppList
                                        Order by sys_DueTime__c DESC])
          {    
               Set<Appoitment__c> apps= oppApps.get(app.Opportunity__c)==null?new Set<Appoitment__c> ():oppApps.get(app.Opportunity__c);
               apps.add(app);
               oppApps.put(app.Opportunity__c, apps);
          }

          for(Opportunity opp: [select id, Name, CreatedDate, LastModifiedDate  from Opportunity where id in : oppApps.keySet()])
          {

              OppAppWrapper oaW= new OppAppWrapper();
              List<Appoitment__c> apps= new List<Appoitment__c>();
              apps.addAll(oppApps.get(opp.Id));

              oaw.opp=opp;
              oaw.apps=apps;
              oaList.add(oaW);
          }
    }

    public class OppAppWrapper
    {
        public Opportunity opp            {get;set;}
        public List<Appoitment__c> apps   {get;set;}
    }

}