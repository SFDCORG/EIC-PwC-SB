trigger LeadItemRollup on Lead_Item__c (after insert, after update, 
                                        after delete, after undelete) {
    shouldProcessRun__c shouldrun = shouldProcessRun__c.getInstance();
    if (shouldrun.isDisable__c) {
        return;
    }

    // modified objects whose parent records should be updated
    Lead_Item__c[] objects = null;
    Utils.runLeadTrigger = FALSE;

     if (Trigger.isDelete) {
         objects = Trigger.old;
     } else {
        /*
            Handle any filtering required, specially on Trigger.isUpdate event. If the rolled up fields
            are not changed, then please make sure you skip the rollup operation.
            We are not adding that for sake of similicity of this illustration.
        */ 
        objects = Trigger.new;
     }

    /*
      First step is to create a context for LREngine, by specifying parent and child objects and
      lookup relationship field name
    */
    LREngine.Context ctx = new LREngine.Context(
    										Lead.SobjectType, // parent object
                                            Lead_Item__c.SobjectType,  // child object
                                            Schema.SObjectType.Lead_Item__c.fields.Lead__c // relationship field name
                                            );     
	/*
	  Next, one can add multiple rollup fields on the above relationship. 
	  Here specify 
	   1. The field to aggregate in child object
	   2. The field to which aggregated value will be saved in master/parent object
	   3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
	*/
    ctx.add(
            new LREngine.RollupSummaryField(
                                            Schema.SObjectType.Lead.fields.Lead_Item_No__c,
                                            Schema.SObjectType.Lead_Item__c.fields.Name,
                                            LREngine.RollupOperation.COUNT 
                                         ));                                     


     LREngine.Context ctx2 = new LREngine.Context(
    										Lead.SobjectType, // parent object
                                            Lead_Item__c.SobjectType,  // child object
                                            Schema.SObjectType.Lead_Item__c.fields.Lead__c, // relationship field name
                                            'Is_Converted__c = TRUE'
                                            );     
	/*
	  Next, one can add multiple rollup fields on the above relationship. 
	  Here specify 
	   1. The field to aggregate in child object
	   2. The field to which aggregated value will be saved in master/parent object
	   3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
	*/
    ctx2.add(
            new LREngine.RollupSummaryField(
                                            Schema.SObjectType.Lead.fields.Converted_Lead_Item_No__c,
                                            Schema.SObjectType.Lead_Item__c.fields.Name,
                                            LREngine.RollupOperation.COUNT 
                                         ));  


     /* 
      Calling rollup method returns in memory master objects with aggregated values in them. 
      Please note these master records are not persisted back, so that client gets a chance 
      to post process them after rollup
      */ 
     Sobject[] masters = LREngine.rollUp(ctx, objects);
     Sobject[] masters2 = LREngine.rollUp(ctx2, objects);    

     try {
        // Persiste the changes in master
        update masters;
        update masters2;   
     } catch (Exception e) {
        System.debug(LoggingLevel.INFO, '***  e.getMessage(): ' +  e.getMessage());
        System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
     }

}