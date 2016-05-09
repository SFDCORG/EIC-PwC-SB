/**************************************************************************************************
 * Name: AppointmentTriggerBeforeInsert
 * Object: Appointment__c
 * Purpose: The before insert trigger.isBefore
            1. Judge the appointments is a duplicate appointment or not for different scenarios.
            2. update the customer visited Center times
 * Author:  ()
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18        Write comments in this format
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
public class AppointmentTriggerBeforeInsert implements TriggerHandler.HandlerInterface {

    public void handle() {
        tmk7dayCheck();
        AppointmentTriggerHelper.beforeUpdateOrInsert(Trigger.new);
        AppointmentTriggerHelper.appointmentVistiedTimesCheck(Trigger.new); // Update the customer visited Center times
    }

    private void tmk7dayCheck() {
        if (!TriggerShouldRun.AppointmentShouldRun) {
            return;
        }

        // Judge the appointments is a duplicate appointment or not
        if (Trigger.new.size() > 1) {
          // batch import not deal
        } else {

            Appoitment__c app = (Appoitment__c) Trigger.new[0];

            // If the appointment is an Invitation and user is from TMK
            if (app.RecordTypeId == Constants.APP_RT_INVITATION_ID &&
                Constants.TMK_PROFILE_IDS.contains(UserInfo.getProfileId())) {

                Opportunity relatedOpp = [SELECT Id, AccountId, RecordTypeId
                                          FROM Opportunity
                                          WHERE Id = :app.Opportunity__c];

                List<Opportunity> relatedOpps = [SELECT Id 
                                                 FROM Opportunity
                                                 WHERE AccountId = :relatedOpp.AccountId
                                                 AND RecordTypeId = : relatedOpp.RecordTypeId];

                Datetime sevenDaysAgo = System.now() - 7;
                List<Appoitment__c> existingAppsWithin7Days = [SELECT Id, Opportunity__c, CreatedById
                                                               FROM Appoitment__c
                                                               WHERE CreatedDate > :sevenDaysAgo
                                                               AND Opportunity__c IN :relatedOpps
                                                               AND RecordTypeId = :Constants.APP_RT_INVITATION_ID
                                                               AND CreatedBy.Profile.Id IN :Constants.TMK_PROFILE_IDS];
                if (existingAppsWithin7Days.size() > 0) {
                    app.isDuplicated__c = true;

                    // If same TMK, mark other appointments as duplicate
                    for(Appoitment__c existingApp : existingAppsWithin7Days) {
                        if (app.Opportunity__c == existingApp.Opportunity__c &&
                            existingApp.CreatedById == UserInfo.getUserId()) {

                            app.isDuplicated1__c = true;
                            break;
                        }
                    }
                    
                    // creating is not possible if a new TMK tries to insert a new appointment within 7 days of aonther TMK creating
                    // one for this opportunity
                    if (app.isDuplicated1__c == false) {
                        app.addError(System.Label.Tmk7DayInvitationErrorMessage);
                    }
                }
            }
        }
    }
}