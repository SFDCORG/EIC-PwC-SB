/**************************************************************************************************
 * Name: UpdateAccountContactInfo
 * Object: Contact_EIC__c
 * Purpose: update contacts' info and related Accounts' info
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-11-25
 * Modify History:
 * 2016-04-18        Create this trigger
 **************************************************************************************************/
trigger UpdateAccountContactInfo on Contact_EIC__c(after insert,after update) {
    Set<ID> primaryContacts = new Set<ID>();
    Set<ID> accountIDSets = new Set<ID>();
    Set<ID> accIds = new Set<ID>(); 
    Set<ID> conIDs = new Set<ID>();

    shouldProcessRun__c shouldrun = shouldProcessRun__c.getInstance();
    if (shouldrun.isDisable__c) {
        return;
    }

    triggerOff__c toff = triggerOff__c.getInstance();
    if (!toff.trigger_off__c) {
        for (Contact_EIC__c contat : trigger.new) {      
            if (trigger.isUpdate && contat.isPrimary__c) {
                Contact_EIC__c oldContact = trigger.oldMap.get(contat.Id);
                if (!oldContact.isPrimary__c) {
                    primaryContacts.add(contat.Id); 
                    accountIDSets.add(contat.Account__c);
                }
            }
            else if (contat.isPrimary__c) {
                primaryContacts.add(contat.Id); 
                accountIDSets.add(contat.Account__c);
            }
            else if (trigger.isInsert) {
                accIds.add(contat.Account__c);
                conIDs.add(contat.Id);
            }
        }

        ContactEICTriggerHelper.autocheckPrimary(accIds,conIDs);
        if (primaryContacts.size() > 0) {
            ContactEICTriggerHelper.updateAccoutContactInfo(primaryContacts);
            ContactEICTriggerHelper.uncheckOtherAllContactPrimaryBox(accountIDSets, primaryContacts);
        }
    }
}