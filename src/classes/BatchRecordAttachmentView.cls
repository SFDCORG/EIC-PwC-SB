/**************************************************************************************************
 * Name: BatchRecordAttachmentView
 * Object: BatchJobRecord__c
 * Purpose: Visualforce page to show the attachments
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06  Vicia Wang  Writes comments in this format
 * 2016-05-06  Allen       Format the code
***************************************************************************************************/
public with sharing class BatchRecordAttachmentView {
    public List<Attachment> attachs { get; set; }
    public String path { get; set; }
    public BatchRecordAttachmentView (ApexPages.StandardController con) {
        Id rid = con.getId();
        attachs = new List<Attachment>();
        attachs = [SELECT Name, CreatedById, CreatedDate
                   FROM Attachment
                   WHERE ParentId =: rid];
        path = URL.getSalesforceBaseUrl().toExternalForm();
        path += '/servlet/servlet.FileDownload?file=';
    }
}