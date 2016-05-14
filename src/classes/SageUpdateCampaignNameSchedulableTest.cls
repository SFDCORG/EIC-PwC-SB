/**************************************************************************************************
 * Name: SageUpdateCampaignNameSchedulableTest
 * Object: Campaign
 * Purpose: a test class for scheduling the SageUpdateCampaignNameSchedulable class
 * Requirement: 
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Vicia Wang   Create this class
***************************************************************************************************/
@isTest(SeeAllData=true)
private class SageUpdateCampaignNameSchedulableTest {
    static testMethod void testSageUpdateCampaignNameSchedulable() {
        String scheduledDate = '0 0 0 15 3 ? 2022';
        
        // Schedules the test job
        try {
            Test.setMock(HttpCalloutMock.class, new SageUpdateCampaignNameMockHttp());
            String jobId = System.schedule('SageUpdateCampaignNameSchedulable', 
                scheduledDate, new SageUpdateCampaignNameSchedulable());

            // Gets the information from the CronTrigger API object
            CronTrigger ct = [SELECT CronExpression, TimesTriggered, 
                                  NextFireTime
                              FROM CronTrigger 
                              WHERE Id = :jobId];
            // Verifies the expressions are the same
            System.assertEquals(scheduledDate, ct.CronExpression);
        } 
        catch (Exception e) {          
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
        }
    }
}