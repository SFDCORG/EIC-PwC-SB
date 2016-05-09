trigger AppoitmentTrigger on Appoitment__c(before insert, before update, after update,after insert) {
    shouldProcessRun__c shouldrun = shouldProcessRun__c.getInstance();
    if(shouldrun.isDisable__c){
        return;
    }

    TriggerHandler th = new TriggerHandler();
    th.bind(TriggerHandler.Evt.beforeinsert, new AppointmentTriggerBeforeInsert());
    th.bind(TriggerHandler.Evt.beforeupdate, new AppointmentTriggerBeforeUpdate());
    th.bind(TriggerHandler.Evt.afterupdate, new AppointmentTriggerAfterUpdate());
    th.bind(TriggerHandler.Evt.afterinsert, new AppointmentTriggerAfterInsert());
    th.manage();
}