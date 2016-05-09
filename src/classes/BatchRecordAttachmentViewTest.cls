/**************************************************************************************************
 * Name: BatchRecordAttachmentViewTest
 * Object: BatchJobRecord__c
 * Purpose: a test class for BatchRecordAttachmentView
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 
 * Modified History: 
 * 2016-05-07  Vicia Wang  Writes comments in this format
***************************************************************************************************/
@isTest
private class BatchRecordAttachmentViewTest {

    static testMethod void testBatchRecordAttachmentView () {

        User userAndy = TestObjectFactory.createUser();

        System.runAs(userAndy) {
            BatchJobRecord__c testBatchJob = TestObjectFactory.createBatchJob();
            Attachment batchAttachment = TestObjectFactory.createAttachment(testBatchJob.Id);

            PageReference attachmentViewPage = Page.BatchRecordAttachmentListView;
            Test.setCurrentPage(attachmentViewPage);

            ApexPages.StandardController batchRecordCon = new ApexPages.StandardController(testBatchJob);
            BatchRecordAttachmentView controller = new BatchRecordAttachmentView(batchRecordCon);

            System.assertEquals(1, controller.attachs.size());
        }
    }
}