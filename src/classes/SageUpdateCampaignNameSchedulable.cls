/**************************************************************************************************
 * Name: SageUpdateCampaignNameSchedulable
 * Object: Campaign
 * Purpose: Schedule the updateCampaignName class
 * Requirement: 
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-1-28
 * Modified History: 
 * 2016-1-28    Writes comments in this format
***************************************************************************************************/
global class SageUpdateCampaignNameSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	SageUpdateCampaignName updateCampaignName = new SageUpdateCampaignName();
    }
}