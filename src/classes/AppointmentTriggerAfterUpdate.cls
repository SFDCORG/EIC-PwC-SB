/**************************************************************************************************
 * Name: AppointmentTriggerAfterUpdate
 * Object: Appointment__c
 * Purpose: The after update appointment trigger
            1. update lead follow up results as appointment follow up results
            2. IF cc or FDA confirm customer has visited center, auto update tmk appointments
 * Author: Ray Cen
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
public class AppointmentTriggerAfterUpdate implements TriggerHandler.HandlerInterface {

    public void handle() {
        afterUpdateHandler();
        AppointmentTriggerHelper.afterUpdateOrInsert(Trigger.new, trigger.isInsert);  // old auto generate activity
    }

    private void afterUpdateHandler() {
        if (!TriggerShouldRun.AppointmentShouldRun) {
            return;
        }

        RecordType leadfollowup =  [SELECT Id
                                    FROM RecordType
                                    WHERE DeveloperName = 'Lead_Follow_Up'
                                    AND SObjectType = 'Appoitment__c'];

        Set<Id> oppIds = new Set<Id> ();
        Set<Id> oppIds2 = new Set<Id> ();
        Set<Id> leadids = new Set<Id> ();
        Map<Id, Appoitment__c> lamap = new Map<Id, Appoitment__c> ();
        for (Appoitment__c app : (List<Appoitment__c>) Trigger.new) {

            Appoitment__c oldapp = (Appoitment__c)Trigger.oldMap.get(app.Id);
            if (app.Status__c == '已到访' && oldapp.Status__c != '已到访') {
                oppIds.add(app.Opportunity__c);
            }

            if (app.TMKAppStatus__c == '已到访' && oldapp.TMKAppStatus__c != '已到访') {
                oppIds2.add(app.Opportunity__c);
            }

            if (leadfollowup.Id == app.RecordTypeId &&
                (app.Follow_Up_Result__c != oldapp.Follow_Up_Result__c || app.Description__c != oldapp.Description__c)) {
                
                leadids.add(app.Lead__c);
                lamap.put(app.Lead__c,app);
            }
        }

        // Update lead follow up results as appointment follow up results
        if (leadids.size() > 0) {
          List<Lead> ls = [SELECT Id, Followup_Result__c, Description
                           FROM Lead
                           WHERE Id IN :leadids];

            for (Lead l : ls) {
                Appoitment__c obj = lamap.get(l.Id);
                l.Followup_Result__c = obj.Follow_Up_Result__c;

                if (l.Description == null) {
                    l.Description = obj.Description__c;
                } else {
                    l.Description = l.Description + obj.Description__c;
                }
            }

            update ls;
        }

        // IF cc or FDA confirm customer has visited center, auto update tmk appointments
        if (oppIds.size() > 0) {
            List<Appoitment__c> apps = [SELECT Id, Status__c, sys_DueTime__c, TMKAppStatus__c, Opportunity__c
                                        FROM Appoitment__c
                                        WHERE RecordType.DeveloperName = 'Invitation'
                                        AND (Createdby.Profile.Name = '集团市场部呼叫中心专员' OR
                                             Createdby.Profile.Name = '集团市场部呼叫中心主管' OR
                                             Createdby.Profile.Name = '分公司分校客服专员' OR
                                             Createdby.Profile.Name = '分公司分校客服主管') 
                                        AND TMKAppStatus__c != '已到访'
                                        AND TMKAppStatus__c != '已失效'
                                        AND Opportunity__c IN :oppIds];

            Map<String, List<Appoitment__c>> appMap = new Map<String, List<Appoitment__c>> ();
            for (Appoitment__c obj : apps) {

                if (appMap.containsKey(obj.Opportunity__c)) {

                    appMap.get(obj.Opportunity__c).add(obj);
                } else {

                    appMap.put(obj.Opportunity__c, new List<Appoitment__c>{ obj });
                }
            }

            Map<String, Appoitment__c> appUpMap = new Map<String, Appoitment__c> ();
            for (Appoitment__c app : (List<Appoitment__c>) Trigger.new) {

                Appoitment__c oldapp = (Appoitment__c) Trigger.oldMap.get(app.Id);
                if (app.Status__c == '已到访' && oldapp.Status__c != '已到访') {

                    List<Appoitment__c> applist = appMap.get(app.Opportunity__c);
                    if (applist == null) {
                        continue;
                    }

                    for (Appoitment__c a : applist) {

                        if ((System.Now() <= a.sys_DueTime__c) ||
                            (System.Now() > a.sys_DueTime__c &&
                            (System.Now().getTime() - a.sys_DueTime__c.getTime()) / 1000 / 60 / 60 / 24 < 7)) {

                            a.sys_unlock_app__c = true;
                            a.TMKAppStatus__c = '已到访';
                            appUpMap.put(a.Id, a);
                        }
                    }
                }
            }

            if (appUpMap.values().size() > 0) {
                update appUpMap.values();
            }
        }

        if (oppIds2.size() > 0) {
            List<Lead_Item__c> itemList = [SELECT Id, Lead__c, Status__c
                                           FROM Lead_Item__c
                                           WHERE Opportunity__c IN :oppIds2];

            List<Lead_Item__c> itemsToUpdate = new List<Lead_Item__c> ();
            for (Lead_Item__c li : itemList) {
                if (li.Status__c == '关闭--转化商机成功') {

                    li.Status__c = '关闭--转化商机成功(到访)';
                    itemsToUpdate.add(li);
                }

                if (li.Status__c == '关闭--重复线索转化成功') {

                    li.Status__c = '关闭--重复线索转化成功(到访)';
                    itemsToUpdate.add(li);
                }
            }

            if (itemsToUpdate.size() > 0) {

                update itemsToUpdate;
                Set<Id> lids = new Set<Id> ();
                for (Lead_Item__c o : itemsToUpdate) {
                  lids.add(o.Lead__c);
                }

                List<Lead> ls = [SELECT Id, Status FROM Lead WHERE Id IN :lids];
                List<Lead> ltoupdate = new List<Lead> ();
                for (Lead l : ls) {

                    if (l.Status == '部分转化') {

                        l.Status = '部分转化(到访)';
                        ltoupdate.add(l);
                    }

                    if (l.Status == '全部转化') {
                        l.Status = '全部转化(到访)';
                        ltoupdate.add(l);
                    }
                }

                if (ltoupdate.size() > 0) {
                    update ltoupdate;
                }
            }
        }
    }
}