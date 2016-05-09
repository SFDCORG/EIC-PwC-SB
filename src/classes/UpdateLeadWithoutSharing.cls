/**************************************************************************************************
 * Name: UpdateLeadWithoutSharing
 * Object: Lead
 * Purpose: Update owner
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang   Create this class
 **************************************************************************************************/
public without sharing class UpdateLeadWithoutSharing {
    public static void doUpdateOwner(Id leadId, Id userId) {
        Lead l = [Select Id, OwnerId From Lead Where Id = :leadId];
        try {
            if (l.OwnerId != userId) {
                if (UserInfo.getProfileId() == '00e28000000IwGaAAK'
                        || UserInfo.getProfileId() == '00e28000000IomIAAS') {
                    l.OwnerId = userId;
                    l.BatchCallTransferTime__c = system.now();
                    update l;
                }
            }
        } catch (Exception e) {
            System.debug('update lead failed'+e.getMessage());
        }
    }
}