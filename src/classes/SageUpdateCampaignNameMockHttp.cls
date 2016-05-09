/**************************************************************************************************
 * Name: SageUpdateCampaignNameTest
 * Object: Campaign
 * Purpose: a test class for update Sage campaign interface mockup
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest
global class SageUpdateCampaignNameMockHttp implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Successful');
        res.setStatusCode(200);
        return res;
    }
}