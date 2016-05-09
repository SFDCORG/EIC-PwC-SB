/**************************************************************************************************
 * Name: ExcelUploaderV3Ctrl
 * Object: Campaign
 * Purpose: It is used to upload leads
 * Requirement:
 * Author: Tcool Ma
 * Create Date: 2015-10-24
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public without sharing class ExcelUploaderV3Ctrl {

    public String sObjectName { get; set; }

    public ExcelUploaderV3Ctrl() {

    }

    @RemoteAction
    public static String uploadData (String data) {
        Utils.runLeadTrigger = false;
        Utils.isExcelUploader = true;
        Boolean needRollback = false;

        System.debug(LoggingLevel.INFO, '*** data: ' + data);

        Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        System.debug(LoggingLevel.INFO, '*** dataMap: ' + dataMap);

        Set<String> campaignExternalCodeSet = new Set<String> ();

        SavePoint sp = Database.setSavepoint();
        System.debug(LoggingLevel.INFO, '*** dataMap.keySet(): ' + dataMap.keySet());

        BatchJobRecord__c job = new BatchJobRecord__c ();
        try {

            for (String sObjectName : dataMap.keySet()) {
                if (sObjectName == 'Lead') {

                    // get uploaded records
                    List<Lead> leadList = new List<Lead> ();
                    List<Lead_Item__c> leadItemList = new List<Lead_Item__c> ();

                    List<Object> recs = (List<Object>)dataMap.get(sObjectName);
                    Integer index = 1;
                    for (Object o : recs) {
                        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));

                        Lead lead = new Lead();
                        lead.Company = 'EIC (Uploaded)';
                        lead.LastName = String.valueOf(objMap.get('name')).trim();
                        lead.MobilePhone = String.valueOf(objMap.get('mobile')).trim() + '';
                        lead.Area_Code__c = String.valueOf(objMap.get('areaCode')).trim();
                        lead.Phone = String.valueOf(objMap.get('phone')).trim();
                        lead.MobilePhone = Lead.MobilePhone.replaceAll( ' ', '');
                        lead.Area_Code__c = Lead.Area_Code__c.replaceAll( ' ', '');
                        lead.Phone =  Lead.Phone.replaceAll( ' ', '');
                        lead.Campaign_External_Code__c = String.valueOf(objMap.get('campaignExternalCode')).trim();
                        lead.Consultation_Mode__c = String.valueOf(objMap.get('consultationMode')).trim();
                        lead.Business_Line__c = String.valueOf(objMap.get('businessLine')).trim();
                        lead.Intended_City__c = String.valueOf(objMap.get('intendedCity')).trim();
                        lead.Project__c = String.valueOf(objMap.get('project')).trim();
                        lead.Extension_Agent__c = String.valueOf(objMap.get('extensionAgent')).trim();
                        lead.Description = String.valueOf(objMap.get('description')).trim();
                        lead.Customer_Service__c = String.valueOf(objMap.get('live800Custom') == null ?
                                                   '' :
                                                   objMap.get('live800Custom')).trim();

                        lead.Lead_Uploaded_Index__c = index;
                        lead.TransferTime1__c = System.Now();
                        lead.Is_Counselling__c = true; // set Is_Counselling__c to true by default and reset this value in splitting logic below

                        leadList.add(lead);

                        campaignExternalCodeSet.add(String.valueOf(objMap.get('campaignExternalCode')));
                        index++;
                    }

                    System.debug(LoggingLevel.INFO, '*** leadList: ' + leadList);
                    System.debug(LoggingLevel.INFO, '*** campaignExternalCodeSet: ' + campaignExternalCodeSet);

                    // get campaign mappings
                    Map<String, Campaign> externalCodeCampaignMap = new Map<String, Campaign> ();
                    for (Campaign c : [SELECT  Campaign_External_Code__c, City__c, Business_line__c
                                      FROM Campaign
                                      WHERE Campaign_External_Code__c IN :campaignExternalCodeSet
                                      AND IsActive = TRUE]) {

                        externalCodeCampaignMap.put(c.Campaign_External_Code__c, c);
                    }

                    System.debug(LoggingLevel.INFO, '*** externalCodeCampaignMap: ' + externalCodeCampaignMap);

                    Map<Decimal, Map<String, Object>> details = new Map<Decimal, Map<String, Object>> ();

                    List<Lead> validatedLeadList = new List<Lead> ();

                    Set<String> mobileSet = new Set<String> ();
                    Set<String> areaCodePhoneSet = new Set<String> ();
                    Map<String, Lead> mobileLeadMap = new Map<String, Lead> ();
                    Map<String, Lead> areaCodePhoneLeadMap = new Map<String, Lead> ();

                    // Validates campaign external code
                    for (Lead lead : leadList) {

                        String error = '';
                        String c = lead.Campaign_External_Code__c.trim();
                        Campaign campaign = externalCodeCampaignMap.get(c);
                        if (campaign == null) {
                            needRollback = true;
                            error += '市场活动不存在或未启用; ';
                        } else if (lead.Business_Line__c == '合作办学' && !Constants.COOPERATIVE_EDUCATION_CITIES.contains(lead.Intended_City__c)) {
                            needRollback = true;
                            error += '您所选的城市无合作办学项目';
                        } else if (lead.Business_Line__c == 'NP' && !Constants.NP_CITIES.contains(lead.Intended_City__c)) {
                            needRollback = true;
                            error += '您所选的城市无NP项目';
                        } else if (lead.Business_Line__c == '考培' && !Constants.TESTPREP_CITIES.contains(lead.Intended_City__c)) {
                            needRollback = true;
                            error += '您所选的城市无考培项目';
                        } else {

                            lead.Campaign__c = campaign.Id;
                            lead.Campaign_City__c = campaign.City__c;
                            lead.Campaign_Business_Line__c = campaign.Business_line__c;
                            for (ExcelUploaderOwnerMapping__c m : ExcelUploaderOwnerMapping__c.getAll().values()) {

                                if (lead.Consultation_Mode__c == '集团TMK外呼' && 
                                    m.Consultation_Mode__c == lead.Consultation_Mode__c) {

                                    lead.OwnerId = m.Owner_Id__c;
                                } else if (lead.Consultation_Mode__c == '史密斯注册' &&
                                          m.Consultation_Mode__c == lead.Consultation_Mode__c) {

                                    lead.OwnerId = m.Owner_Id__c;
                                } else if (m.Consultation_Mode__c == lead.Consultation_Mode__c &&
                                           m.City__c == lead.Intended_City__c &&
                                           m.Business_Line__c == campaign.Business_line__c) {

                                    lead.OwnerId = m.Owner_Id__c;
                                }
                            }
                        }

                        // merge mobile and phone
                        if (!mobileSet.contains(lead.MobilePhone)) {

                            if (String.isNotBlank(lead.MobilePhone)) {

                                mobileSet.add(lead.MobilePhone);
                                mobileLeadMap.put(lead.MobilePhone, lead);
                            }

                            if (!areaCodePhoneSet.contains(lead.Area_Code__c + lead.Phone)) {

                                if (String.isNotBlank(lead.Phone)) {

                                    areaCodePhoneSet.add(lead.Area_Code__c + lead.Phone);
                                    areaCodePhoneLeadMap.put(lead.Area_Code__c + Lead.Phone, lead);
                                }

                                if (String.isBlank(error)) {
                                    validatedLeadList.add(lead);
                                }
                            } else {
                                Lead previousLead = areaCodePhoneLeadMap.get(lead.Area_Code__c + lead.Phone);
                                if (previousLead.Campaign_External_Code__c == lead.Campaign_External_Code__c) {
                                    if (String.isBlank(previousLead.MobilePhone)) {

                                        // merge mobile
                                        previousLead.MobilePhone = lead.MobilePhone;

                                        // merge business line
                                        previousLead.Business_Line__c = mergeMultiplePickedValues(previousLead.Business_Line__c, lead.Business_Line__c);

                                        // merge project
                                        previousLead.Project__c = mergeMultiplePickedValues(previousLead.Project__c, lead.Project__c);
                                    } else {
                                        if (String.isBlank(lead.MobilePhone) || previousLead.MobilePhone == lead.MobilePhone) {

                                            // merge business line
                                            previousLead.Business_Line__c = mergeMultiplePickedValues(previousLead.Business_Line__c, lead.Business_Line__c);

                                            // merge project
                                            previousLead.Project__c = mergeMultiplePickedValues(previousLead.Project__c, lead.Project__c);
                                        } else {
                                            needRollback = true;
                                            error += '电话号码重复; ';
                                        }
                                    }
                                } else {
                                    validatedLeadList.add(lead);
                                }
                            }
                        } else {
                            Lead previousLead = mobileLeadMap.get(lead.MobilePhone);
                            if (previousLead.Campaign_External_Code__c == lead.Campaign_External_Code__c) {
                                if (String.isBlank(lead.Phone)) {

                                    // merge business line
                                    previousLead.Business_Line__c = mergeMultiplePickedValues(previousLead.Business_Line__c, lead.Business_Line__c);

                                    // merge project
                                    previousLead.Project__c = mergeMultiplePickedValues(previousLead.Project__c, lead.Project__c);
                                } else {
                                    if (String.isBlank(previousLead.Phone)) {

                                        // merge phone
                                        previousLead.Area_Code__c = lead.Area_Code__c;
                                        previousLead.Phone = lead.Phone;

                                        // merge business line
                                        previousLead.Business_Line__c = mergeMultiplePickedValues(previousLead.Business_Line__c, lead.Business_Line__c);

                                        // merge project
                                        previousLead.Project__c = mergeMultiplePickedValues(previousLead.Project__c, lead.Project__c);
                                    } else {
                                        if (previousLead.Phone == lead.phone) {

                                            // merge business line
                                            previousLead.Business_Line__c = mergeMultiplePickedValues(previousLead.Business_Line__c, lead.Business_Line__c);

                                            // merge project
                                            previousLead.Project__c = mergeMultiplePickedValues(previousLead.Project__c, lead.Project__c);
                                        } else {
                                            needRollback = true;
                                            error += '手机号码重复; ';
                                        }
                                    }
                                }
                            } else {
                                validatedLeadList.add(lead);
                            }
                        }
                        if (String.isNotBlank(error)) {
                            details.put(lead.Lead_Uploaded_Index__c, createDetail(lead, error, '主线索', lead.Lead_Uploaded_Index__c));
                        }
                    }

                    // Checks for the running job.
                    List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name, Status
                                               FROM AsyncApexJob
                                               WHERE ApexClass.Name = 'UploadLeadBatchable'
                                               AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
                                               AND JobType = 'BatchApex'];

                    if (jobs.size() > 0) {
                        job.Name = '资源导入_' + validatedLeadList.size() + '_' + System.Now();
                        job.BatchJobId__c = '';
                        job.BatchType__c = 'UploadLeadBatchable';
                        job.Status__c = '排队中';
                        insert job;

                        String leadsJson = JSON.serialize(validatedLeadList);
                        String errorJson = JSON.serialize(details);
                        Attachment attobject = new Attachment ();
                        attobject.Name = 'validateLeads' + '.json';
                        attobject.Body = Blob.valueOf(leadsJson);
                        attobject.ParentId = job.Id;

                        Attachment attobject1 = new Attachment ();
                        attobject1.Name = 'details' + '.json';
                        attobject1.Body = Blob.valueOf(errorJson);
                        attobject1.ParentId = job.Id;
                        List<Attachment> atts = new List<Attachment> { attobject1, attobject };
                        insert atts;

                    } else {
                        Id bid = Database.executeBatch(new UploadLeadBatchable ((List<Sobject>) validatedLeadList, UserInfo.getUserEmail(), details), 50);
                        job.Name = '资源导入_' + validatedLeadList.size() + '_' + System.Now();
                        job.BatchJobId__c = bid;
                        job.BatchType__c = 'UploadLeadBatchable';
                        job.Status__c = '处理中';
                        insert job;
                    }
                }
            }
        } catch (Exception ex) {

            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            Database.rollback(sp);
            throw ex;
            return 'Fail';
        }

        return job.Id;
    }

    private static String mergeMultiplePickedValues (String preStr, String newStr) {

        Set<String> mergedValueSet = new Set<String> ();
        for (String s : prestr.split(';')) {

            if (String.isNotBlank(s)) {

                mergedValueSet.add(s);
            }
        }

        for (String s : newStr.split(';')) {

            if (String.isNotBlank(s)) {

                mergedValueSet.add(s);
            }
        }

        String mergedValue = '';
        for (String s : mergedValueSet) {

            mergedValue += s + ';';
        }
        if (String.isNotBlank(mergedValue)) {

            mergedValue = mergedValue.substring(0, mergedValue.length() - 1);
        }
        return mergedValue;
    }

    private static Map<String, Object> createDetail (Lead lead, String error, String type, Decimal index) {
        Map<String, Object> detail = new Map<String, Object> ();
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

    public Map<String, String> getExcelUploaderPreleadFieldMapping () {

        Map<String, String> mapping = new Map<String, String> {
            'name' => '姓名',
            'mobile' => '手机',
            'areaCode' => '区号',
            'phone' => '电话号码',
            'campaignExternalCode' => '四级推广方式',
            'consultationMode' => '咨询方式',
            'businessLine' => '业务线',
            'intendedCity' => '意向城市',
            'project' => '意向业务',
            'extensionAgent' => '推广员',
            'description' => '描述',
            'errorMessage' => '错误信息',
            'live800Custom'=>'网询顾问'
        };

        return mapping;
    }

    public List<String> getIntendedCities () {

        List<String> intendedCityList = new List<String> ();
        Schema.DescribeSobjectResult dsr= Schema.getGlobalDescribe().get('Lead').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Intended_City__c').getDescribe();
        for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {

            intendedCityList.add(pe.getValue());
        }

        return intendedCityList;
    }

    public List<String> getConsultationModes() {

        List<String> consultationModeList = new List<String> ();
        Schema.DescribeSobjectResult dsr= Schema.getGlobalDescribe().get('Lead').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Consultation_Mode__c').getDescribe();
        for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            consultationModeList.add(pe.getValue());
        }

        return consultationModeList;
    }

    public Map<String, String> getBusinessLines () {

        Map<String, String> mapping = new Map<String, String> ();
        for (Project__c m : Project__c.getAll().Values()) {

            mapping.put(m.Name, m.Project__c);
        }

        return mapping;
    }
}