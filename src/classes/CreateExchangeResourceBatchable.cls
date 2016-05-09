/**************************************************************************************************
 * Name: CreateExchangeResourceBatchable
 * Object: Lead, Lead_Item__c, Opportunity
 * Purpose: Uses the batch to handle the resource exchange records
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
global class CreateExchangeResourceBatchable implements Database.Batchable<sObject>, Database.Stateful {

    public List<Sobject> inputList;
    public String smail;
    public String errorMsg;
    public Integer i = 0;

    global CreateExchangeResourceBatchable (List<SObject> SObjects,
                                            String val,
                                            String errorMsg,
                                            Integer indexNum) {
        this.inputList = SObjects;
        this.smail = val;
        this.errorMsg = errorMsg;
        this.i = indexNum;
    }

    global Iterable<SObject> start (Database.BatchableContext bc) {

        return this.inputList;
    }

    global void execute (Database.BatchableContext BC, list<Sobject> scope) {

        List<Lead> leads = (List<Lead>) scope;
        Map<String, Lead> validLeadMap = new Map<String, Lead> ();
        Utils.runLeadTrigger = false;
        List<Database.SaveResult> srs = Database.insert(leads, FALSE);
        for (Integer idx = 0; idx < srs.size(); idx++) {

            Database.SaveResult sr = srs[idx];
            if (sr.isSuccess()) {

                validLeadMap.put(leads[idx].Id, leads[idx]);
            } else {

                i++;
                String statusCode = '';
                String msg = '';
                for (Database.Error er : sr.getErrors()) {

                     statusCode += er.getStatusCode();
                     msg += er.getMessage();
                }
                errorMsg += i + ',' + leads[idx].LastName + ',' + 
                   (Leads[idx].MobilePhone == null ?
                    Leads[idx].Area_Code__c + Leads[idx].Phone :
                    Leads[idx].MobilePhone) + 
                   ',' + statusCode +',' + msg + '\r\n';
            }
        }

        if (validLeadMap.values().size() > 0) {

            List<Lead> validLeads = new List<Lead> (validLeadMap.values());
            List<Lead_Item__c> leadItemList = new List<Lead_Item__c> ();
            leadItemList = SplitLeadUtils.splitLead(validLeads);

            // Updates some lead items to "市场活动内重复","与已有商机重复"; Notify the opportunity owner
            leadItemList = SplitLeadUtils.checkAccOppNotifyOwner(leadItemList, validLeads);

            // Update some rest lead items to "与已有线索重复", "新建"
            leadItemList = SplitLeadUtils.checkLead(leadItemList);
            List<Lead_Item__c> item2Insert = new List<Lead_Item__c> ();
            for (Lead_Item__c li : leadItemList) {

                if (li.Status__c != '新建') {
                    Lead l = validLeadMap.get(li.Lead__c);
                    i++;
                    errorMsg += i + ',' + l.LastName + ',' + 
                       (l.MobilePhone == null ?
                        l.Area_Code__c + l.Phone :
                        l.MobilePhone) + ',' + '' + ',' + li.Status__c + '\r\n';
                } else {
                    item2Insert.add(li);
                }
            }

            if (item2Insert.size() > 0) {

                srs = Database.insert(item2Insert, FALSE);
                for (Integer idx = 0; idx < srs.size(); idx++) {
                    Database.SaveResult sr = srs[idx];
                    if (sr.isSuccess()) {
                        Lead l = validLeadMap.get(item2Insert[idx].Lead__c);
                        i++;
                        errorMsg += i + ',' + l.LastName + ',' +
                           (l.MobilePhone == null ?
                            l.Area_Code__c + l.Phone :
                            l.MobilePhone) + ',' + '' + ',' + '创建成功' + '\r\n';
                    } else {
                        i++;
                        Lead l = validLeadMap.get(item2Insert[idx].Lead__c);
                        String statusCode = '';
                        String msg = '';
                        for (Database.Error er : sr.getErrors()) {
                             statusCode += er.getStatusCode();
                             msg += er.getMessage();
                        }
                        errorMsg += i + ',' + l.LastName + ',' +
                           (l.MobilePhone == null ?
                            l.Area_Code__c + l.Phone :
                            l.MobilePhone) + ',' + statusCode + ',' + msg + '\r\n';
                    }
                }
            }

            // Deletes failed leads
            List<Lead> l2D = [SELECT Lead_Item_No__c
                              FROM Lead
                              WHERE Id IN: validLeadMap.keySet()
                              AND (Lead_Item_No__c = NULL OR
                                   Lead_Item_No__c = 0)];
            if (l2D.size() > 0) {
                delete l2D;
            }
        }

        if (Limits.getHeapSize() > 8000000) {
            List<BatchJobRecord__c> hisLogs = [SELECT Id,
                                                  (SELECT Id FROM Attachments)
                                               FROM BatchJobRecord__c
                                               WHERE BatchJobId__c =: BC.getJobId()];
            if (hisLogs.size() == 0) {
                BatchJobRecord__c job = new BatchJobRecord__c();
                job.Name = '资源互换_' + inputList.size() + '_' + System.Now();
                job.BatchJobId__c = BC.getJobId();
                job.BatchType__c = 'CreateExchangeResourceBatchable';
                job.Status__c = '处理中';
                insert job;
                Attachment attobject = new Attachment();
                attobject.Name = '创建日志_'+ System.Now() + '.csv';
                attobject.Body = Blob.valueOf(errorMsg);
                attobject.ParentId = job.Id;
                insert attobject;
            } else {
                Attachment attobject = new Attachment();
                attobject.Name = '创建日志_' + System.Now() + '.csv';
                attobject.Body = Blob.valueOf(errorMsg);
                attobject.ParentId = hisLogs[0].Id;
                insert attobject;
            }

            errorMsg = '';
        }
    }

    global void finish(Database.BatchableContext BC) {

        List<BatchJobRecord__c> hisLogs = [SELECT Id,
                                              (SELECT Id FROM Attachments)
                                           FROM BatchJobRecord__c
                                           WHERE BatchJobId__c =: BC.getJobId()];
        Id JobId = null;
        if (hisLogs.size() == 0) {
            BatchJobRecord__c job = new BatchJobRecord__c ();
            job.Name = '资源互换_' + inputList.size() + '_' + System.Now();
            job.BatchJobId__c = BC.getJobId();
            job.BatchType__c = 'CreateExchangeResourceBatchable';
            job.Status__c = '已完成';
            insert job;
            Attachment attobject = new Attachment();
            attobject.Name = '创建日志_' + System.Now() + '.csv';
            attobject.Body = Blob.valueOf(errorMsg);
            attobject.ParentId = job.Id;
            insert attobject;
            jobId = job.Id;
        } else {
            Attachment attobject = new Attachment();
            attobject.Name = '创建日志_' + System.Now() + '.csv';
            attobject.Body = Blob.valueOf(errorMsg);
            attobject.ParentId = hisLogs[0].Id;
            insert attobject;
            hisLogs[0].Status__c = '已完成';
            update hisLogs[0];
            jobId = hisLogs[0].Id;
        }

        List<Attachment> attachs = [SELECT Id, Name FROM Attachment WHERE ParentId =: jobId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        System.debug('LoggingLevel.INFO, *** mail: ' + mail);

        mail.setToAddresses(new String[] {smail});
        mail.setSubject('您的资源互换任务已经执行完毕');
        String body = '您的资源互换任务已经执行完毕，详细情况请点击下面的链接\r\n';
        String htmlbody = '<div><p>您的资源互换任务已经执行完毕，详细情况请点击下面的链接</p></div><ul>';
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment> ();

        for (Attachment att : attachs) {
            String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL += '/servlet/servlet.FileDownload?file=' + att.id;
            body += att.Name + ':' + fileURL + '\r\n';
            htmlbody += '<li><a href="' + fileURL + '">' + att.Name + '</a></li>';
        }

        htmlbody += '</ul>';
        mail.setPlainTextBody(body);
        mail.setHtmlBody(htmlbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}