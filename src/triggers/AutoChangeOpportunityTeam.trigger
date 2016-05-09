/**************************************************************************************************
 * Name: AutoChangeOpportunityTeam
 * Object: Opportunity
 * Purpose: 1. If opportunity owner has change, just change the opportunity team member
 *          2. Cancel existing appointments, Changed their status to expired
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-07
 * Modify History:
 * 2016-05-07        Create this trigger
 **************************************************************************************************/
trigger AutoChangeOpportunityTeam on Opportunity(after insert,after update,before update, before insert) {
    Set<ID> oppIds = new Set<ID>(); // Get all appointments in current trigger batch
    Set<ID> cancelAppIDs = new Set<ID>(); // Get all opportunities which need close their assignments
    Set<ID> accountIDs = new Set<ID>();

    shouldProcessRun__c shouldrun = shouldProcessRun__c.getInstance();
    if (shouldrun.isDisable__c) {
        return;
    }

    if (trigger.isAfter) {
        Set<Id> selectedIds = new Set<Id>();
        for (Opportunity opp : trigger.new) {
            // The inserted opp shall be generate opp team 
            if (trigger.isInsert) {
                oppIds.add(opp.Id);
                accountIDs.add(opp.AccountId);
            }
            // The updated opp whose ownership been changed shall re-generate the opp team
            else {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id); 
                if (oldOpp.OwnerID != opp.OwnerID) {   
                    oppIds.add(opp.Id);
                    cancelAppIDs.add(opp.Id);
                }

                // Add by joe for TMK appointment status change when opp is win
                if (oldOpp.StageName != Constants.OPPORTUNITY_STAGE_CLOSED_WON 
                        && opp.StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON) {
                    selectedIds.add(opp.Id);
                }
            }

            if (opp.Probability == 0 || opp.Probability == 100 
                    || opp.Probability == 5) {
                cancelAppIDs.add(opp.Id);
            }
        }
        
        // Generate opp team 
        if (oppIds.size() > 0) {
            OpportuinityRelatedController.clearCurrentOPPTeam(oppIds);
            OpportuinityRelatedController.generateOppTeam(oppIds);
        }

        if (selectedIds.size() > 0) {
            List<Appoitment__c> apps = [
                SELECT Id, Status__c, sys_DueTime__c, TMKAppStatus__c 
                FROM Appoitment__c 
                WHERE RecordType.DeveloperName = 'Invitation' 
                AND (Createdby.Profile.Name = '集团市场部呼叫中心专员' 
                    OR createdby.Profile.Name = '集团市场部呼叫中心主管' 
                    OR createdby.Profile.Name = '分公司分校客服专员' 
                    OR createdby.Profile.Name = '分公司分校客服主管'
                ) 
                AND TMKAppStatus__c != '已到访' 
                AND Opportunity__c IN :selectedIds
            ];

            List<Appoitment__c> appsToUpdate = new List<Appoitment__c>();
            for (Appoitment__c a : apps) {
                if ((System.now() < a.sys_DueTime__c) || (System.now()>a.sys_DueTime__c 
                        && (System.now().getTime() - a.sys_DueTime__c.getTime())/1000/60/60/24 < 7)){
                    a.sys_unlock_app__c = true;
                    a.TMKAppStatus__c = '已到访';
                    appsToUpdate.add(a);
                }
            }

            if (appsToUpdate.size() > 0) {
                update appsToUpdate;
            }
        }

        if (accountIDs.size() > 0) {
            OpportuinityRelatedController.updateLossOppReferenceField(oppIds, accountIDs);
        }

        if (cancelAppIDs.size() > 0) {
            ActivityRelated.cancelAssignment(cancelAppIDs);
        }
    }
}