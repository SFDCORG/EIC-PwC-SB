trigger AccountChangeAlert on Account(after update) {
    shouldProcessRun__c shouldrun = shouldProcessRun__c.getInstance();
    if(shouldrun.isDisable__c){
        return;
    }

    TriggerHandler th = new TriggerHandler();
    th.bind(TriggerHandler.Evt.afterupdate, new AccountChangeAlertTriggerAfterUpdate());
    th.manage();
}