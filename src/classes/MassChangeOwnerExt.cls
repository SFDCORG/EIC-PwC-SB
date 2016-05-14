/**************************************************************************************************
 * Name: MassChangeOwnerExt
 * Object: Lead
 * Purpose: It is used to mass change lead owners
 * Requirement: 
 * Author: Tcool Ma
 * Create Date: 2015-10-24
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public without sharing class MassChangeOwnerExt {

    public String distributionType { get; set; }
    public String schedulingTable { get; set; }
    public Integer numberOfLeads { get; set; }
    public Boolean hasError { get; set; }
    public String leadDistributionTableId { get; set; }
    public List<Lead_Distribution_Table__c> leadDistributionTableList { get; set; }
    public Map<String, List<DistributionTable>> leadDistributionTableIdLinesMap { get; set; }
    public Map<String, Integer> leadDistributionTableIdLineNumbersMap { get; set; }
    public List<String> leadDistributionTableIdList { get; set; }
    public String selectedStaffIds { get; set; }
    public Integer leadDistributionTableSize { get; set; }
    private Map<String, List<Lead>> mobileLeadsMap = new Map<String, List<Lead>>();
    private Map<String, List<Lead>> areaCodePhoneLeadsMap = new Map<String, List<Lead>>();
    private List<String> mobilePhoneList = new List<String>();

    private List<Lead> updateLeadList = new List<Lead>();
    private Set<Id> selectedLeadIdSet = new Set<Id>();
    private Set<String> leadStatusSet = new Set<String> {
        '全未转化-新建',
        '全未转化-跟进中',
        '全未转化-休眠自动',
        '全未转化-休眠手动',
        '全未转化-流失'
    };

    public MassChangeOwnerExt (ApexPages.StandardSetController con) {

        hasError = false;
        distributionType = '平均分配';

        for (Lead lead : (List<Lead>) con.getSelected()) {
            selectedLeadIdSet.add(lead.Id);
        }

        Map<String, String> processedAreaCodePhoneMobileMap = new Map<String, String>();

        // Gets editable lead ids
        Set<Id> editableLeadIdSet = new Set<Id>();
        for (UserRecordAccess access : [SELECT RecordId, HasEditAccess
                                        FROM UserRecordAccess
                                        WHERE UserId = :UserInfo.getUserId()
                                        AND RecordId IN :selectedLeadIdSet]) {

            if (access.HasEditAccess) {
                editableLeadIdSet.add(access.RecordId);
            }
        }

        // get leads
        for (Lead lead : [SELECT OwnerId, MobilePhone, Area_Code__c, Phone
                          FROM Lead 
                          WHERE Id IN :editableLeadIdSet
                          AND Status IN :leadStatusSet
                          ORDER BY MobilePhone NULLS LAST, 
                                   Phone NULLS LAST]) {

            String areaCodePhone = lead.Area_Code__c + lead.Phone;
            if (String.isNotBlank(lead.MobilePhone)) {

                // Adds lead with same mobile to mobile map
                if (!mobileLeadsMap.containsKey(lead.MobilePhone)) {
                    mobileLeadsMap.put(lead.MobilePhone, new List<Lead>());
                }
                mobileLeadsMap.get(lead.MobilePhone).add(lead);

                // create area code + phone => mobile map for processed mobile
                if (String.isNotBlank(lead.Phone) && !processedAreaCodePhoneMobileMap.containsKey(areaCodePhone)) {
                    processedAreaCodePhoneMobileMap.put(areaCodePhone, lead.MobilePhone);
                }
            } else if (String.isNotBlank(lead.Phone)) {

                // add lead with same area code + phone to the mobile map
                if (processedAreaCodePhoneMobileMap.containsKey(areaCodePhone)) {
                    String mobile = processedAreaCodePhoneMobileMap.get(areaCodePhone);
                    mobileLeadsMap.get(mobile).add(lead);
                } else {

                    // add lead with same area code + phone to the phone map
                    if (!areaCodePhoneLeadsMap.containsKey(areaCodePhone)) {
                        areaCodePhoneLeadsMap.put(areaCodePhone, new List<Lead>());
                    }
                    areaCodePhoneLeadsMap.get(areaCodePhone).add(lead);
                }
            }
        }

        mobilePhoneList.addAll(mobileLeadsMap.keySet());
        mobilePhoneList.addAll(areaCodePhoneLeadsMap.keySet());

        numberOfLeads = mobilePhoneList.size();

        if (editableLeadIdSet.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '请先选择要分配的线索！'));
            hasError = true;
            return;
        } else if (numberOfLeads == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '选中的线索中, 没有未转化的线索！'));
            hasError = true;
            return;
        }

        leadDistributionTableList = new List<Lead_Distribution_Table__c>();
        leadDistributionTableIdLinesMap = new Map<String, List<DistributionTable>>();
        leadDistributionTableIdLineNumbersMap = new Map<String, Integer>();
        leadDistributionTableIdList = new List<String>();

        getLeadDistributionTables();
    }

    // Distributes leads by numbers
    public PageReference save() {

        // get queues
        Map<String, String> queueNameIdMap = new Map<String, String>();
        for (Group g : [SELECT Name
                        FROM Group 
                        WHERE Type = 'Queue']) {

            queueNameIdMap.put(g.Name, g.Id);
        }

        Integer index = 0;
        Integer endNumber = 0;
        for (DistributionTable dt : leadDistributionTableIdLinesMap.get(leadDistributionTableId)) {
            endNumber += dt.numbers;
            for (Integer i = index; i < endNumber; i++) {
                String mobilePhone = mobilePhoneList[i];
                if (mobileLeadsMap.get(mobilePhone) != null) {
                    for (Lead lead : mobileLeadsMap.get(mobilePhone)) {

                        // assign to queue
                        if (String.isBlank(dt.ldtl.Customer_Service_Staff__c)) {
                            String queueId = queueNameIdMap.get(dt.ldtl.Queue__c);
                            if (queueId == null) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '队列"' + 
                                    dt.ldtl.Queue__c + '"不存在, 请联系管理员进行确认！'));
                                return null;
                            } else {
                                lead.OwnerId = queueNameIdMap.get(dt.ldtl.Queue__c);
                                if (dt.ldtl.Queue__c == '集团TMK主管组') {
                                    lead.Consultation_Mode__c = '集团TMK外呼';
                                }
                            }
                        } else { // assign to customer service staff
                            lead.OwnerId = dt.ldtl.Customer_Service_Staff__c;
                        }
                        updateLeadList.add(lead);
                    }
                } else if (areaCodePhoneLeadsMap.get(mobilePhone) != null) {
                    for (Lead lead : areaCodePhoneLeadsMap.get(mobilePhone)) {
                        lead.OwnerId = dt.ldtl.Customer_Service_Staff__c;
                        updateLeadList.add(lead);
                    }
                }
                index++;
            }
        }

        System.debug(LoggingLevel.INFO, '*** updateLeadList: ' + updateLeadList);
        
        try {

            Database.update(updateLeadList, false);
        } catch(DmlException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getDmlMessage(0)));
            return null;
        }
        return new PageReference('/00Q');
    }

    public PageReference back() {
        return new PageReference('/00Q');
    }

    public List<SelectOption> getDistributionTypes () {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('平均分配','平均分配'));
        options.add(new SelectOption('按数量分配','按数量分配'));
        return options;
    }

    // Gets lead distribution tables maintained in Lead_Distribution_Table__c object
    public void getLeadDistributionTables () {

        for (Lead_Distribution_Table__c ldt : [SELECT Name, OwnerId,
                                                      (SELECT Customer_Service_Staff__c,
                                                              Customer_Service_Staff__r.IsActive,
                                                              Queue__c
                                                       FROM Lead_Distribution_Table_Lines__r
                                                       ORDER BY Customer_Service_Staff__c)
                                               FROM Lead_Distribution_Table__c
                                               WHERE OwnerId = :UserInfo.getUserId()
                                               ORDER BY Name]) {

            leadDistributionTableList.add(ldt);
            leadDistributionTableIdList.add(ldt.Id);
            leadDistributionTableIdLinesMap.put(ldt.Id, new List<DistributionTable>());
            leadDistributionTableIdLineNumbersMap.put(ldt.Id, ldt.Lead_Distribution_Table_Lines__r.size());

            for (Lead_Distribution_Table_Line__c ldtl : ldt.Lead_Distribution_Table_Lines__r) {
                leadDistributionTableIdLinesMap.get(ldt.Id).add(new DistributionTable(ldtl, null));
            }
        }
        leadDistributionTableSize = leadDistributionTableList.size();
    }

    public String getLeadDistributionTablePrefix () {
        return Schema.SObjectType.Lead_Distribution_Table__c.getkeyprefix();
    }

    public class DistributionTable {

        public Lead_Distribution_Table_Line__c ldtl { get; set; }
        public Integer numbers { get; set; }

        public DistributionTable() {}

        public DistributionTable(Lead_Distribution_Table_Line__c ldtl, Integer numbers) {
            this.ldtl = ldtl;
            this.numbers = numbers;
        }
    }
}