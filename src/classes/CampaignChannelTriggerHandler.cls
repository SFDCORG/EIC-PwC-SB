/**************************************************************************************************
 * Name: CampaignChannelTriggerHandler
 * Object: Campaign_Channel__c
 * Purpose: De-duplicate for campaign channel handler
 * Author:  Tcool Ma (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-07
 * Modify History:
 * 2016-05-07    Vicia Wang    Create this trigger
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
public with sharing class CampaignChannelTriggerHandler {

    public static void deduplicate (List<Campaign_Channel__c> newCampaignChannelList,
                                    Set<Id> campaignChannelIdSet) {

        List<Campaign_Channel__c> campaignChannelList = new List<Campaign_Channel__c> ();

        // Validates campaign channels in current trigger
        Set<String> newUniqueKeySet = new Set<String> ();
        for (Campaign_Channel__c cc : newCampaignChannelList) {

            String lv3 = String.isBlank(cc.Marketing_Channel_Lv3__c) ? '' : cc.Marketing_Channel_Lv3__c;
            String uniqueKey = cc.Marketing_Channel_Lv1__c + cc.Marketing_Channel_Lv2__c + lv3;

            if (newUniqueKeySet.contains(uniqueKey)) {

                cc.addError('该市场推广渠道在本批数据中重复！', false);
            } else {

                newUniqueKeySet.add(uniqueKey);
                campaignChannelList.add(cc);
            }
        }

        // Gets campaign channels by unique key
        Map<String, Campaign_Channel__c> uniqueKeyCampaignChannelMap = new Map<String, Campaign_Channel__c> ();
        for (Campaign_Channel__c cc : [SELECT Active__c, Unique_Key__c
                                       FROM Campaign_Channel__c
                                       WHERE Unique_Key__c IN :newUniqueKeySet]) {

            if (campaignChannelIdSet == null || (campaignChannelIdSet != null && !campaignChannelIdSet.contains(cc.Id))) {

                uniqueKeyCampaignChannelMap.put(cc.Unique_Key__c, cc);  
            }
        }

        // Validate campaign channels in database
        for (Campaign_Channel__c cc : campaignChannelList) {

            String lv3 = String.isBlank(cc.Marketing_Channel_Lv3__c) ? '' : cc.Marketing_Channel_Lv3__c;
            String uniqueKey = cc.Marketing_Channel_Lv1__c + cc.Marketing_Channel_Lv2__c + lv3;

            if (uniqueKeyCampaignChannelMap.containsKey(uniqueKey)) {
                Campaign_Channel__c duplicatedCampaignChannel = uniqueKeyCampaignChannelMap.get(uniqueKey);

                if (duplicatedCampaignChannel.Active__c == true) {
                    cc.addError('该市场推广渠道已存在, 但是未激活！', false);
                    cc.addError('该市场推广渠道已存在！<a href="/' + 
                                 duplicatedCampaignChannel.Id +
                                 '" target="_blank">查看详情</a>', false);
                } else {
                    cc.addError('该市场推广渠道已存在, 但是未激活！<a href="/' +
                                 duplicatedCampaignChannel.Id +
                                 '" target="_blank">查看详情</a>', false);
                }
            } else {
                cc.Unique_Key__c = uniqueKey;
            }
        }
    }
}