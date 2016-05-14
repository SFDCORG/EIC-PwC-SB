/**************************************************************************************************
 * Name: AutoClearTaskTest
 * Object: task
 * Purpose: a test class for AutoClearTask
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 **************************************************************************************************/
@isTest
private class AutoClearTaskTest {
    
    static testMethod void testAutoClearTask() {
        
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
        // Schedule Clear task job
        String jobId = System.schedule('AutoClearTask',CRON_EXP, new AutoClearTask());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger 
                          WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}