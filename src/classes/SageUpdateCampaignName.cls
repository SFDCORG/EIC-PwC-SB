/**************************************************************************************************
 * Name: SageUpdateCampaignName
 * Object: Campaign
 * Purpose: Send the changed campaign name with ids to sage, they do the updates.
 * Requirement: 
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-1-28
 * Modified History: 
 * 2016-1-28   vicia.wang Writes comments in this format
***************************************************************************************************/
public without sharing class SageUpdateCampaignName {
    public SageUpdateCampaignName () {
		Contract_System__c sageCampaign = Contract_System__c.getValues('Prepsmith Sage Update Campaign');
		List<CampaignWrapper> campaignWrappers = new List<CampaignWrapper>();

		// Handle Cooperative Admissions only
	    for (Campaign camp :[SELECT Name 
	    					 FROM Campaign 
	    					 WHERE LastModifiedDate = Yesterday 
	    					 AND Marketing_Channel_Lv1__c = '合作招生']) {
	    	CampaignWrapper wrapper = new CampaignWrapper(camp.Id, camp.Name);
	    	campaignWrappers.add(wrapper);
	    }	    
	    String reqBody = JSON.serialize(campaignWrappers);
		reqBody = '{"campaigns":' + reqBody + '}';

	    HttpRequest request = new HttpRequest();
	    request.setEndpoint(sageCampaign.Endpoint__c);
	    request.setMethod('POST');
	    request.setTimeout(120000);
	    request.setBody(reqBody);
	    System.debug(LoggingLevel.INFO, '*** request.getBody(): ' + reqBody);

	    try {
	    	HttpResponse response = new HttpResponse();
        	Http http = new Http();
        	response = http.send(request);
        	System.debug(LoggingLevel.INFO, '*** response.getBody(): ' + response.getBody());

	    } catch (Exception e) {
	    	System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
	    	System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
	    }
    }

    public class CampaignWrapper {
        String campaignId;
        String campaignName;

        public CampaignWrapper (String campaignId, String campaignName) {
            this.campaignId = campaignId;
        	this.campaignName = campaignName;
        }
    }
}