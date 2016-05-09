/**************************************************************************************************
 * Name: CampaignChannelTrigger
 * Object: Campaign_Channel__c
 * Purpose: De-duplicate for campaign channel
 * Author:  Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-07
 * Modify History:
 * 2016-04-18        Create this trigger
 **************************************************************************************************/
trigger CampaignChannelTrigger on Campaign_Channel__c(before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CampaignChannelTriggerHandler.deduplicate((List<Campaign_Channel__c>)Trigger.new, null);
        } else if (Trigger.isUpdate) {
            CampaignChannelTriggerHandler.deduplicate((List<Campaign_Channel__c>)Trigger.new, Trigger.newMap.keySet());
        }
    }
}