/**************************************************************************************************
 * Name: CampaignTrigger
 * Object: Campaign
 * Purpose: Update the campaign record type when status has change
 * Author: Vicia Wang 
 * Create Date: 2016-05-07
 * Modify History:
 * 2016-05-07        Create this trigger
 **************************************************************************************************/
trigger CampaignTrigger on Campaign(before update) {
    if (Trigger.isUpdate && Trigger.isBefore) {
        Map<Id,RecordType> rMap = new Map<Id,RecordType>([
            SELECT Id, SobjectType, Name, DeveloperName 
            FROM RecordType 
            WHERE IsActive = true 
            AND SobjectType = 'Campaign'
        ]);
        Map<String, Id> s2IdMap = new Map<String,Id>();
        for (RecordType r : rMap.values()) {
            s2IdMap.put(r.DeveloperName, r.Id);
        }

        for (Campaign c : Trigger.new) {
            Campaign oc = Trigger.oldMap.get(c.Id);
            if (c.Status == '审批通过' && oc.Status != c.Status) {
                if (rMap.get(c.RecordTypeId).DeveloperName == 'Level_4_Promotion_Channel') {
                    c.RecordTypeId = s2IdMap.get('Level_4_Promotion_Channel_Approved');
                }

                if (rMap.get(c.RecordTypeId).DeveloperName == 'Subagent') {
                    c.RecordTypeId = s2IdMap.get('Subagent_Approved');
                }
            }
            else if (oc.Status == '审批通过' && oc.Status != c.Status) {
                if (rMap.get(c.RecordTypeId).DeveloperName == 'Level_4_Promotion_Channel_Approved') {
                    c.RecordTypeId = s2IdMap.get('Level_4_Promotion_Channel');
                }

                if (rMap.get(c.RecordTypeId).DeveloperName == 'Subagent_Approved') {
                    c.RecordTypeId = s2IdMap.get('Subagent');
                }
            }
        }
    }
}