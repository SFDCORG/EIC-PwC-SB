/**************************************************************************************************
 * Name: SageUpdateCampaignNameTest
 * Object: Campaign
 * Purpose: a test class for update Sage campaign
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-04
 * Modified History: 
 * 2016-05-04   vicia.wang Writes comments in this format
***************************************************************************************************/
@isTest(SeeAllData=TRUE)
private class SageUpdateCampaignNameTest {
    static testMethod void testSageUpdateCampaignName() {
        Test.setMock(HttpCalloutMock.class, new SageUpdateCampaignNameMockHttp());
        SageUpdateCampaignName controller = new SageUpdateCampaignName();
    }
}