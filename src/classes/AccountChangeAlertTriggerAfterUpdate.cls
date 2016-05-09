/**************************************************************************************************
 * Name: AccountChangeAlertTriggerAfterUpdate
 * Object: Account
 * Purpose: If Account's key Field has been changed, a Task alert will send to all opportunity owner except current login user
 * Author:  ()
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18        Write comments in this format
 **************************************************************************************************/
public class AccountChangeAlertTriggerAfterUpdate implements TriggerHandler.HandlerInterface {
    
    // Does the after update action
    public void handle() {

        doUpdateAlertHandler();
    }
    
    // Translates Date into a String fields
    private String translateDatetoStringIfDate(Map<String, Schema.SObjectField> mFields, Account account,  String key) {

        if (mFields.get(key).getDescribe().getType() == Schema.DisplayType.Date) {
            Date d = Date.valueOf(account.get(key));

            if (d != null) {
                String year = String.valueOf(d.year());
                String month = String.valueOf(d.month());
                String day = String.valueOf(d.day());
                return year + '-' + month + '-' + day;
            } else {
                return '';
            }
        } else {
            return String.valueOf(account.get(key));
        }
    }
    
    // Generates tasks list to opportunities owners
    private List<Task> insertTasks (Map<ID, Set<ID>> oppTeamOwners, Id accountid, String content) {

        if (content != '') {
            Set<ID> userids = oppTeamOwners.get(accountid) == null ? new Set<ID>() : oppTeamOwners.get(accountid);
            List<Task> tazks = new List<Task>();
            for (ID idd:userids) {
                if (idd != UserInfo.getUserId())
                tazks.add(generateTask(content, idd, accountid));
            }
            return tazks;
        }
        return new List<Task>();
    }
    
    // Generates Task
    private Task generateTask(String content, ID userid, ID AccountID) {

        Task tazk = new Task();
        tazk.ActivityDate = System.Today();
        tazk.IsReminderSet = true;
        tazk.OwnerId = userid;
        tazk.Priority = 'Normal';
        tazk.ReminderDateTime = System.Now();
        tazk.Status = 'Open';
        tazk.WhatId = AccountID;
        tazk.Subject = '客户信息被改变';
        tazk.Description__c = content;
        return tazk;
    }
   
    // Set the after update logic
    private void doUpdateAlertHandler() {
        List<Task> tasks = new List<Task>();

        // Gets Hidden Fields, these fields is in a custom setting, these fields won't trigger the alert action.
        Set<String> hiddenFields = new Set<String>();
        for (Account_Alert_Field_Log__c alerts: [SELECT HideFieldName__c FROM Account_Alert_Field_Log__c]) {
            hiddenFields.add(alerts.HideFieldName__c);
        }
        hiddenFields = hiddenFields.size() > 0 ? hiddenFields : new Set<String>();

        Set<ID> accids = new Set<ID>();
        for (Account acc : (List<Account>) Trigger.new) {
            accids.add(acc.Id);
        }
        Map<ID, Set<ID>> oppTeamOwners = OppOwnerGroupGenerate.getOpportuniyOwnerGroupBulk(accids);
        
        // Admin user won't trigger the alert action
        if (!ProfileRelated.adminProfileSet().contains(UserInfo.getProfileId())) {
            for (Account acc: (List<Account>)Trigger.new) {
                Account newAccount = acc;
                Account oldAccount = (Account) trigger.oldMap.get(acc.Id);
                String content = '';

                // Gets all account field
                Map<String, Schema.SObjectField> mFields = new Map<String, Schema.SObjectField>();
                List<Schema.DescribeSObjectResult> results = schema.describeSObjects(new String[] {'Account'});
                for (Schema.DescribeSObjectResult res: results) {
                    mFields = res.fields.getMap();
                }

                // Judges the fields had been changed or not, If changed, send task alerts.
                for (String key: mFields.keySet()) {
                    if (newAccount.get(key) != oldAccount.get(key) &&
                        !hiddenFields.contains(mFields.get(key).getDescribe().getName())) {
                        String originalcontent = content;
                        String newContent = translateDateToStringIfDate(mFields, newAccount, key);
                        String oldContent = translateDateToStringIfDate(mFields, oldAccount, key);
                        content += '[' + mFields.get(key).getDescribe().getLabel() + ']被' +
                                   UserInfo.getName() + '从[' + oldContent+']修改为[' + newContent + ']\n';

                        if (content.length() > 255) {
                            List<Task> tsk = insertTasks(oppTeamOwners, acc.id, originalcontent);
                            if (tsk.size() > 0) tasks.addAll(tsk);
                            content = '[' + mFields.get(key).getDescribe().getLabel() + ']被' + 
                                      UserInfo.getName() + '从[' + oldContent + ']修改为[' + newContent + ']\n';
                        }
                    }
                }

                // Insert all tasks
                List<Task> tsk = insertTasks(oppTeamOwners, acc.id, content);
                if (tsk.size() > 0) tasks.addAll(tsk);
            }

            if (tasks.size() > 0) insert tasks;
            System.debug('Done with trigger. inserted' + tasks.size());
        }
    }
}