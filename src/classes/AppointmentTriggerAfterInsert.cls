/**************************************************************************************************
 * Name: AppointmentTriggerAfterInsert
 * Object: /
 * Purpose: The after insert trigger logic about Appointment.
            1. According to Appointments update lead follow up results
            2. After Customer Visited appointments have been created, update appointments
            3. Update TMK appointments status
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
public class AppointmentTriggerAfterInsert implements TriggerHandler.HandlerInterface {

    public void handle() {

        afterInsertHandler();
        tmkAppointmentUpdateHandler();
        AppointmentTriggerHelper.afterUpdateOrInsert(Trigger.new, trigger.isInsert); // Auto Generates activity and related sharing rule
    }

    private void afterInsertHandler() {
        if (!TriggerShouldRun.AppointmentShouldRun) {
            return;
        }

        // According to Appointments update lead follow up results
        Set<Id> lids = new Set<Id> ();
        Map<Id, Appoitment__c> lamap = new Map<Id, Appoitment__c> ();
        RecordType leadfollowup = [SELECT Id
                                   FROM RecordType
                                   WHERE DeveloperName = 'Lead_Follow_Up'
                                   AND SObjectType = 'Appoitment__c'];

        for (Appoitment__c aa : (List<Appoitment__c>) Trigger.new) {

            if (aa.RecordTypeId == leadfollowup.Id) {
                lids.add(aa.Lead__c);
                lamap.put(aa.Lead__c,aa);
            }
        }

        List<Lead> ls = [SELECT Followup_Result__c ,Description
                         FROM Lead 
                         WHERE Id IN :lids];

        for (Lead l : ls) {

            Appoitment__c obj = lamap.get(l.Id);
            l.Followup_Result__c = obj.Follow_Up_Result__c;
            if (l.Description == null) {

                l.Description = obj.Description__c;
            } else {
                l.Description = l.Description+obj.Description__c;
            }
        }

        if (ls.size() > 0) {
            update ls;
        }

        // After Customer Visited appointments have been created, update tmk appointments' status
        if (Trigger.new.size() > 1) {
            // Do nothing
        } else {

            RecordType rt = [SELECT Id
                             FROM RecordType
                             WHERE DeveloperName = 'Front_Desk_Visit'
                             AND SObjectType = 'Appoitment__c'];

            Appoitment__c app = (Appoitment__c) Trigger.new[0];
            if (app.RecordTypeId == rt.Id ||
                (app.RecordTypeID == RecordTypeRelated.Invitation_App && app.Status__c == '已到访')) {

                // 前台到访
                try{
                    List<Appoitment__c> applist = [SELECT Status__c, sys_DueTime__c, TMKAppStatus__c 
                                                   FROM Appoitment__c
                                                   WHERE RecordType.DeveloperName = 'Invitation'
                                                   AND (Createdby.Profile.Name = '集团市场部呼叫中心专员' OR
                                                        Createdby.Profile.Name = '集团市场部呼叫中心主管' OR
                                                        Createdby.Profile.Name = '分公司分校客服专员' OR
                                                        Createdby.Profile.Name = '分公司分校客服主管')
                                                   AND TMKAppStatus__c != '已到访'
                                                   AND Opportunity__c = :app.Opportunity__c];

                    List<Appoitment__c> appUpList = new List<Appoitment__c> ();
                    for (Appoitment__c a : applist) {

                        if ((System.Now() <= a.sys_DueTime__c) ||
                            (System.Now() > a.sys_DueTime__c &&
                                (System.Now().getTime() - a.sys_DueTime__c.getTime()) / 1000 / 60 / 60 / 24 < 7)) {

                            a.sys_unlock_app__c = true;
                            a.TMKAppStatus__c = '已到访';
                            appUpList.add(a);
                        }
                    }

                    if (appUpList.size() > 0) {
                        update appUpList;
                    }
                } catch (Exception e) {
                  app.addError(e.getMessage());
                }
            }
        }
    }
    
    // Updates old appointments status, If new appointments have been created
    private void tmkAppointmentUpdateHandler () {
        Set<ID> oppIDs = new Set<ID> ();
        Set<ID> appIDS = new Set<ID> ();
        List<Appoitment__c> updatedapps = new List<Appoitment__c> ();

        for (Appoitment__c app : (List<Appoitment__c>) Trigger.new) {
            if (ProfileRelated.getTMKCallCenterSet().contains(userinfo.getProfileId()) && 
                app.RecordTypeId == RecordTypeRelated.Invitation_App) {

                oppIDs.add(app.Opportunity__c);
                appIDS.add(app.Id);
            }
        }

        for (Appoitment__c app : [SELECT Status__c, TMKAppStatus__c
                                  FROM Appoitment__c
                                  WHERE Opportunity__c IN : oppIDs
                                  AND ID NOT IN : appIDS
                                  AND CreatedBy.ProfileID IN :ProfileRelated.getTMKCallCenterSet()
                                  AND recordTypeID = :RecordTypeRelated.Invitation_App
                                  AND TMKAppStatus__c = '未到访']) {

          app.Status__c = app.Status__c == '跟进中' ? '再约' : app.Status__c;
          app.TMKAppStatus__c = '已失效';
          app.sys_unlock_app__c = true;
          updatedapps.add(app);
        }

        if (updatedapps.size() > 0) {
            update updatedapps;
        }
    }
}