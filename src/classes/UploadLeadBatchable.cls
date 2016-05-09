/**************************************************************************************************
 * Name: UploadLeadBatchable
 * Object: Lead
 * Purpose: Batch update lead
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
global class UploadLeadBatchable implements Database.Batchable<sObject>, Database.Stateful {
    public List<Sobject> inputList;
	public String smail;
	public Map<Decimal,Map<String,Object>> errorDetails;
    
    global UploadLeadBatchable(List<SObject> objs, String val, Map<Decimal, Map<String, Object>> details) {
    	this.inputList = objs;
    	this.smail = val;
    	this.errorDetails = details;
    }
    
    global Iterable<SObject> start(Database.BatchableContext bc) {
    	return this.inputList;
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<BatchJobRecord__c> RunningJobs = [
            SELECT Id, CreatedById FROM BatchJobRecord__c 
            WHERE BatchType__c = 'UploadLeadBatchable' 
            AND BatchJobId__c = :BC.getJobId()
        ];

        BatchJobRecord__c RunningJob = RunningJobs[0];
    	Utils.runLeadTrigger = false;
        Utils.isExcelUploader = true;
        List<Lead> leads = (List<Lead>)scope;
        for (Lead ll : leads) {
            ll.CreatedById = RunningJob.CreatedById;
            if (ll.OwnerId == null) {
                ll.OwnerId = RunningJob.CreatedById;
            }
        }

        Map<String,Lead> validLeadMap = new Map<String,Lead>();
        Utils.runLeadTrigger = false;
    	List<Database.SaveResult> srs = Database.insert(leads, FALSE);
    	for(Integer idx = 0; idx < srs.size(); idx++) {
            Database.SaveResult sr = srs[idx];
            if (sr.isSuccess()) {
                validLeadMap.put(leads[idx].Id, leads[idx]);
            } else {
            	String msg = '';
            	for (Database.Error er : sr.getErrors()) {
                    msg += er.getMessage();
                    errorDetails.put(leads[idx].Lead_Uploaded_Index__c,
                        createDetail(leads[idx],msg,'主线索',
                        leads[idx].Lead_Uploaded_Index__c));
                }       	
            }
        }
        List<Lead> validatedLeadList = new List<Lead>(validLeadMap.values());
        List<Lead_Item__c> leadItemList = new List<Lead_Item__c>();

        leadItemList = SplitLeadUtils.splitLead(validatedLeadList);
        // update some lead items to "市场活动内重复","与已有商机重复"; Notify the opportunity owner
        leadItemList = SplitLeadUtils.checkAccOppNotifyOwner(leadItemList, validatedLeadList);
        // Update some rest lead items to "与已有线索重复", "新建"
        leadItemList = SplitLeadUtils.checkLead(leadItemList);
        Set<Id> leadIdSet = new Set<Id>();

      	List<Lead_Item__c> newLeadItemList = new List<Lead_Item__c>();
        Map<Id, Set<String>> leadIdCounsellingProjectsMap = new Map<Id, Set<String>>();

      	for (Lead_Item__c li : leadItemList) {
            // lead
            Lead lead = validLeadMap.get(li.Lead__c);
            if (!leadIdSet.contains(li.Lead__c)) {
                leadIdSet.add(li.Lead__c);
            }
            
            if (li.Status__c != '新建') {
            	if (errorDetails.containsKey(lead.Lead_Uploaded_Index__c)) {
	            	errorDetails.get(lead.Lead_Uploaded_Index__c).put('错误信息',
                        errorDetails.get(lead.Lead_Uploaded_Index__c).get('错误信息') + '  ' +
                        li.Project__c + ':' + li.Status__c);
	            } else {
	            	Map<String, Object> d = new Map<String, Object>();
	            	errorDetails.put(lead.Lead_Uploaded_Index__c,
                        createDetail(lead,li.Project__c + ':' + li.Status__c, 
                        '主线索', lead.Lead_Uploaded_Index__c));
	            }
                
            } else {
                if (li.Business_Line__c == '留学') {
                    if (!leadIdCounsellingProjectsMap.containsKey(li.Lead__c)) {
                        leadIdCounsellingProjectsMap.put(li.Lead__c, new Set<String>());
                    }
                    leadIdCounsellingProjectsMap.get(li.Lead__c).add(li.Project__c);
                }
                newLeadItemList.add(li);
            }
        }
        
        //insert newLeadItemList;
        for (Lead_Item__c ii : newLeadItemList) {
            if (ii.OwnerId == null) {
                ii.OwnerId = RunningJob.CreatedById;
            }
            ii.CreatedById = RunningJob.CreatedById;
        }

        srs = Database.insert(newLeadItemList, FALSE);
    	for (Integer idx = 0; idx < srs.size(); idx++) {
    		Lead_Item__c li = newLeadItemList[idx];
    		Lead lead = validLeadMap.get(li.Lead__c);
            Database.SaveResult sr = srs[idx];
            if (sr.isSuccess()) {
                errorDetails.put(lead.Lead_Uploaded_Index__c,
                    createDetail(lead,li.Project__c+'创建成功',
                    '主线索',lead.Lead_Uploaded_Index__c));
            } else {
            	String msg = '';
            	for (Database.Error er : sr.getErrors()) {
                     msg += er.getMessage();
                     if (errorDetails.containsKey(lead.Lead_Uploaded_Index__c)) {
                     	errorDetails.get(lead.Lead_Uploaded_Index__c).put('错误信息',
                            errorDetails.get(lead.Lead_Uploaded_Index__c).get('错误信息') + '  ' +
                            li.Project__c+':'+msg);
                     } else {
                     	errorDetails.put(lead.Lead_Uploaded_Index__c,createDetail(lead,
                            li.Project__c + ':' + msg,
                            '主线索', lead.Lead_Uploaded_Index__c));
                     }
                     
                }       	
            }
        }

      	List<Lead> deleteLeadList = new List<Lead>();
        Set<Id> deletedLeadIdSet = new Set<Id>();
        for (Lead lead : [
                SELECT  Lead_Item_No__c
                FROM    Lead 
                WHERE   Id IN :validLeadMap.values()]) {
            if (lead.Lead_Item_No__c == null || lead.Lead_Item_No__c == 0) {
                deleteLeadList.add(lead);
                deletedLeadIdSet.add(lead.Id);
            }
        }
        if (deleteLeadList.size() > 0) {
        	delete deleteLeadList;
        }
      

      // update projects
        List<Lead> updateLeadList = new List<Lead>();
        for (Lead lead : [
                SELECT  Counselling_Project__c
                FROM    Lead
                WHERE   Id IN :validLeadMap.values()]) {
            String projects = '';
            if (leadIdCounsellingProjectsMap.get(lead.Id) == null) {
                lead.Is_Counselling__c = false;
            } else {
                for (String project : leadIdCounsellingProjectsMap.get(lead.Id)) {
                    projects += project + ';';
                }
                if (String.isNotBlank(projects)) {
                    projects = projects.substring(0, projects.length() - 1);
                }
            }
            if (String.isNotBlank(projects)) {
                lead.Counselling_Project__c = projects.replaceAll('null', '');
            }
            updateLeadList.add(lead);
        }
        update updateLeadList;


        if (Limits.getHeapSize() > 8000000) {
            String error = '序号,姓名,手机,区号,电话号码,四级推广方式,咨询方式,业务线,意向城市,意向业务,错误信息'+'\r\n';
        	for (Decimal i : errorDetails.keySet()) {
                Map<String,Object> obj = errorDetails.get(i);
                error+=String.valueOf(obj.get('序号'))+','+String.valueOf(obj.get('姓名'))+','+String.valueOf(obj.get('手机'))+','+String.valueOf(obj.get('区号'))+','+String.valueOf(obj.get('电话号码'))+','+String.valueOf(obj.get('四级推广方式'))+','+String.valueOf(obj.get('咨询方式'))+','+String.valueOf(obj.get('业务线'))+','+String.valueOf(obj.get('意向城市'))+','+String.valueOf(obj.get('意向业务'))+','+','+'"'+String.valueOf(obj.get('错误信息'))+'"'+'\r\n';
            }

            List<BatchJobRecord__c> hisLogs = [
                SELECT Id, (SELECT Id FROM Attachments) 
                FROM BatchJobRecord__c WHERE BatchJobId__c = :BC.getJobId()
            ];
            Attachment attobject = new Attachment();
            attobject.Name = '导入信息汇总_'+ System.now() + '.csv';
            attobject.Body = Blob.valueOf(error);
            attobject.ParentId = hisLogs[0].Id;
            attobject.CreatedById = RunningJob.CreatedById;
            insert attobject;
            
            errorDetails.clear();
        }
    }

    global void finish(Database.BatchableContext BC) {
        List<BatchJobRecord__c> RunningJobs = [Select Id,CreatedById From BatchJobRecord__c Where BatchType__c='UploadLeadBatchable' And BatchJobId__c = :BC.getJobId()];
        BatchJobRecord__c RunningJob = RunningJobs[0];

        String error = '序号,姓名,手机,区号,电话号码,四级推广方式,咨询方式,业务线,意向城市,意向业务,错误信息'+'\r\n';
        for (Decimal i : errorDetails.keySet()) {
            Map<String,Object> obj = errorDetails.get(i);
            error += String.valueOf(obj.get('序号')) + ',' + 
                String.valueOf(obj.get('姓名')) + ',' + 
                String.valueOf(obj.get('手机')) + ',' + 
                String.valueOf(obj.get('区号')) + ',' + 
                String.valueOf(obj.get('电话号码')) + ',' + 
                String.valueOf(obj.get('四级推广方式')) + ',' + 
                String.valueOf(obj.get('咨询方式')) + ',' + 
                String.valueOf(obj.get('业务线')) + ',' + 
                String.valueOf(obj.get('意向城市')) + ',' + 
                String.valueOf(obj.get('意向业务')) + ',' + '"' + 
                String.valueOf(obj.get('错误信息')) + '"' + 
                '\r\n';
        }

        List<BatchJobRecord__c> hisLogs = [
            SELECT Id, (SELECT Id FROM Attachments), Name 
            FROM BatchJobRecord__c 
            WHERE BatchJobId__c = :BC.getJobId()
        ];

        Attachment attobject = new Attachment();
        attobject.Name = '导入信息汇总_'+ System.now() + '.csv';
        attobject.Body = Blob.valueOf(error);
        attobject.ParentId = hisLogs[0].Id;
        attobject.CreatedById = RunningJob.CreatedById;
        insert attobject;
        
        hisLogs[0].Status__c = '已完成';
        update hisLogs[0];

        List<Attachment> attachs = [Select Id,Name From Attachment Where ParentId = :hisLogs[0].Id];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug(smail);
            mail.setToAddresses(new String[] {smail});
            mail.setSubject('您的线索导入任务已经执行完毕');
            String body = '您的线索导入任务已经执行完毕，详细情况请点击下面的链接\r\n';
            String htmlbody = '<div><p>您的线索导入任务已经执行完毕，详细情况请点击下面的链接</p></div><ul>';
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL += '/' + hisLogs[0].id;
            body += hisLogs[0].Name + ':' + fileURL+'\r\n';
            htmlbody += '<li><a href="' + fileURL + 
                '" style="text-decoration: underline;">' + 
                hisLogs[0].Name + '</a></li>';
            htmlbody += '</ul>';
            mail.setPlainTextBody(body);
            mail.setHtmlBody(htmlbody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        //check the pendding jobs
        List<BatchJobRecord__c> bjrs = [
            SELECT Id,CreatedById FROM BatchJobRecord__c 
            WHERE BatchType__c = 'UploadLeadBatchable' 
            AND Status__c = '排队中' ORDER BY CreatedDate ASC
        ];
        if (bjrs.size() > 0) {
            BatchJobRecord__c bjob = bjrs[0];
            User u = [Select Id, Email From User Where Id = :bjob.CreatedById];
            List<Attachment> attchs = [Select Id,Name,Body From Attachment Where ParentId = :bjob.Id];
            String vleadstring = '';
            String dstring = '';
            for (Attachment attch : attchs) {
                if (attch.Name=='validateLeads.json') {
                    Blob b = attch.Body;
                    vleadstring = b.toString();
                } else if (attch.Name == 'details.json') {
                    Blob b = attch.Body;
                    dstring = b.toString();
                }
            }
            if (vleadstring != '' && dstring != '') {
                List<Lead> vleads = (List<Lead>)JSON.deserialize(vleadstring, List<Lead>.class);
                Map<String,Object> detailsRaw = (Map<String,Object>)JSON.deserializeUntyped(dstring);
                Map<Decimal,Map<String,Object>>details = new Map<Decimal,Map<String,Object>>();
                for (String key : detailsRaw.keySet()) {
                    details.put(Decimal.valueOf(key),(Map<String,Object>)detailsRaw.get(key));
                }

                Id bid = Database.executeBatch(new UploadLeadBatchable((List<Sobject>)vleads,u.Email,details), 50);
                bjob.BatchJobId__c = bid;
                bjob.Status__c = '处理中';
                update bjob;
            }
        }

    }

    private static Map<String, Object> createDetail(Lead lead, String error, String type, Decimal index) {
        Map<String, Object> detail = new Map<String, Object>();
        detail.put('错误信息', error);
        detail.put('描述', lead.Description);
        detail.put('推广员', lead.Extension_Agent__c);
        detail.put('意向业务', lead.Project__c);
        detail.put('意向城市', lead.Intended_City__c);
        detail.put('业务线', lead.Business_Line__c);
        detail.put('咨询方式', lead.Consultation_Mode__c);
        detail.put('四级推广方式', lead.Campaign_External_Code__c);
        detail.put('电话号码', lead.Phone);
        detail.put('区号', lead.Area_Code__c);
        detail.put('手机', lead.MobilePhone);
        detail.put('姓名', lead.LastName);
        detail.put('序号', index);
        detail.put('线索类型', type);
        return detail;
    }

}