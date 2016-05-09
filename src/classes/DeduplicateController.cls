/**************************************************************************************************
 * Name: DeduplicateController
 * Object: Phone
 * Purpose: 
 * Requirement: 
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: --
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public without sharing class DeduplicateController {

    public String phone { get; set; }
    public String callLogId { get; set; }
    public String channel { get; set; }
    public String channelType { get; set; }
    public String preNum { get; set; }
    public String customerNo { get; set; }
    public String batchId { get; set; }
    public Map<String, Integer> channelMap { get; set; }

    public List<Account> accs { get; set;}
    public List<Opportunity> opps { get; set; }

    public List<Lead_Item__c> leadItems { get; set; }
    public String myVar { get; set; }

    List<Task> reminders = new List<Task> ();

    public DeduplicateController () {

        accs = new List<Account> ();
        opps = new List<Opportunity> ();
        String phones = ApexPages.currentPage().getParameters().get('phone');
        callLogId = ApexPages.currentPage().getParameters().get('callLogId');
        channel = ApexPages.currentPage().getParameters().get('channel');
        channelType = ApexPages.currentPage().getParameters().get('Type');
        preNum = ApexPages.currentPage().getParameters().get('preNum');
        customerNo = ApexPages.currentPage().getParameters().get('ActivityId');
        batchId = ApexPages.currentPage().getParameters().get('batchId');

        Map<String, CallCenterChannelMap__c> cmap = CallCenterChannelMap__c.getAll();
        channelMap = new Map<String, Integer> ();

        for (String key : cmap.keySet()) {

            CallCenterChannelMap__c obj = cmap.get(key);
            channelMap.put(key, Integer.valueOf(obj.ChannelType__c));
        }

        System.debug(LoggingLevel.INFO, '*** phones: ' + phones);
        System.debug(LoggingLevel.INFO, '*** callLogId: ' + callLogId);

        if (customerNo == null || customerNo == '') {

            if (String.isNotBlank(phones)) {

                List<String> phoneList = new List<String> ();
                phoneList = phones.split(';');  

                phone = phoneList[0];
                searchDuplication();
            }
        }
    }

    public PageReference initAction () {

        if (customerNo == null || customerNo == '') {

            if (callLogId == null || callLogId == '') {

                return null;
            } else {

                if (opps.size() == 0 && leadItems.size() == 0) {

                    User currentUser = [SELECT ChineseNameofCity__c, Business_Line_Formula__c
                                        FROM User
                                        WHERE Id = :UserInfo.getUserId()];

                    String newURL = '';
                    if (callLogId == '' || callLogId == null) {

                        newURL = '/apex/NewLeadV2?Company=EIC';
                    } else {

                        newURL = '/apex/NewLeadV2?Company=EIC&CallLogId=' + callLogId;
                    }

                    if (String.isNotBlank(preNum)) {

                        newURL += '&phone=' + phone.substring(preNum.length()) + '&areacode=' + preNum;
                    } else {
                        newURL += '&mobile=' + phone;
                    }

                    if (String.isNotBlank(currentUser.ChineseNameofCity__c)) {

                        newURL += '&city=' + currentUser.ChineseNameofCity__c;
                    }

                    if (currentUser.Business_Line_Formula__c == '考培' || currentUser.Business_Line_Formula__c == '留学') {

                        newURL += '&project=' + currentUser.Business_Line_Formula__c;
                    } else {
                        newURL += '';
                    }

                    PageReference ref = new PageReference(newURL);
                    return ref;
                }
                return null;
            }
        } else {

            if (customerNo.substring(0, 3) == '006') {

                // 商机直接跳转到商机详细页面
                UpdateOppWithoutSharing.doUpdateOwner(customerNo, UserInfo.getUserId());
                PageReference ref = null;
                if (batchId == null || batchId == '') {

                    ref = new PageReference('/' + customerNo);
                } else {

                    ref = new PageReference('/' + customerNo + '?batchId=' + batchId);
                }

                return ref;
            } else {

                //如果是TMK线索，把Owner改成当前用户
                UpdateLeadWithoutSharing.doUpdateOwner(customerNo, UserInfo.getUserId());
                PageReference ref = null;
                if (batchId == null || batchId == '') {

                    ref = new PageReference('/apex/LeadDetailV2?id=' + customerNo);
                } else {

                    ref = new PageReference('/apex/LeadDetailV2?id=' + customerNo + '&batchId=' + batchId);
                }
                return ref;
            }
        }
    }

    public void searchDuplication () {

        if (String.isBlank(phone)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                '查询时, 请填写电话号码!'));
            return;
        }

        accs.clear();
        opps.clear();
        leadItems = new List<Lead_Item__c> ();
        Set<Id> accIds = new Set<Id> ();
        Set<Id> oppOwners = new Set<Id> ();
        reminders.clear();

        for (Contact_EIC__c con :[SELECT Account__c, Account__r.Name, Account__r.OwnerId, Account__r.CreatedDate
                                  FROM Contact_EIC__c
                                  WHERE Unique_Contact__c = :phone
                                  AND isInvalid__c = FALSE]) {

            accIds.add(con.Account__c);
        }

        // Gets all same accounts and opportunities.
        for (Account acc :[SELECT Id, Name, OwnerId, CreatedDate,
                                (SELECT Name, RecordType.Name, Project__c, Intended_City__c, IsClosed,
                                        StageName, OwnerId, CreatedById, CreatedDate, FDA_Visted__c, Record_Type_Chinese_Name__c
                                FROM Opportunities)
                           FROM Account
                           WHERE Id IN :accIds]) {

            accs.add(acc);
            for (Opportunity opp :acc.Opportunities) {
                opps.add(opp);
                
                if (!oppOwners.contains(opp.OwnerId) && opp.IsClosed == FALSE) {

                    Task task = new Task(
                        Subject = String.valueOf(System.today().format()) + 
                                  '-您的客户' + 
                                  acc.Name + 
                                  '-可能再次咨询了新的业务, 请您及时跟进您的商机.',
                        OwnerId = opp.OwnerId,
                        WhatId = opp.Id,
                        ActivityDate = System.today(),
                        ReminderDateTime = System.now(),
                        IsReminderSet = TRUE); 

                    reminders.add(task);
                }
                oppOwners.add(opp.OwnerId);
            }
        }

        for (Lead_Item__c li : [SELECT Lead__c, Business_Line__c, Intended_Country__c, Project__c, Status__c, Convert__c, 
                                       Lead__r.Name, Lead__r.OwnerId, Lead__r.Campaign__c, Lead__r.CreatedDate,
                                       Lead__r.Consultation_Mode__c, Lead__r.Intended_City__c
                                FROM Lead_Item__c
                                WHERE Is_Converted__c = FALSE
                                AND (Mobile__c = :phone OR Fix_Phone__c = :phone)
                                ORDER BY Lead__r.CreatedDate DESC]) {

            leadItems.add(li);
        }

        List<Opportunity> tempOppList1 = new List<Opportunity> ();
        List<Opportunity> tempOppList2 = new List<Opportunity> ();
        List<Lead_Item__c> templeadItemList1 = new List<Lead_Item__c> ();
        List<Lead_Item__c> tempLeadItemList2 = new List<Lead_Item__c> ();

        if (String.isNotBlank(channel) || String.isNotBlank(channelType)) {

            if (String.isNotBlank(channel)) {

                // 1、留学 2、考培
                if (channelMap.get(channel)==1) {
                    Set<Id> oppids = new Set<Id> ();
                    for (Opportunity opp : opps) {
                        oppids.add(opp.Id);
                    }

                    for (Opportunity o : [SELECT Name, RecordType.Name, Project__c, Intended_City__c, StageName, OwnerId, 
                                                CreatedById, CreatedDate, FDA_Visted__c, Record_Type_Chinese_Name__c
                                         FROM Opportunity 
                                         WHERE Id IN :oppids
                                         ORDER BY CreatedDate DESC ]) {

                        if (o.RecordType.Name == 'Counselling') {

                            tempOppList1.add(o);
                        } else {

                            tempOppList2.add(o);
                        }
                    }

                    for (Lead_Item__c l : leadItems) {

                        if (l.Business_Line__c == '留学') {

                            templeadItemList1.add(l);
                        } else {

                            tempLeadItemList2.add(l);
                        }
                    }

                    opps.clear();
                    opps.addAll(tempOppList1);
                    opps.addAll(tempOppList2);
                    leadItems.clear();
                    leadItems.addAll(templeadItemList1);
                    leadItems.addAll(tempLeadItemList2);

                } else {

                    Set<Id> oppids = new Set<Id> ();
                    for (Opportunity opp : opps) {

                        oppids.add(opp.Id);
                    }
                    for (Opportunity o : [SELECT Name, RecordType.Name, Project__c, Intended_City__c, StageName, OwnerId,
                                                CreatedById, CreatedDate, FDA_Visted__c, Record_Type_Chinese_Name__c
                                         FROM Opportunity 
                                         WHERE Id IN :oppids
                                         ORDER BY CreatedDate DESC ]) {

                        if (o.RecordType.Name == 'Counselling') {

                            tempOppList2.add(o);
                        } else {

                            tempOppList1.add(o);
                        }
                    }

                    for (Lead_Item__c l : leadItems) {

                        if (l.Business_Line__c=='留学') {

                            tempLeadItemList2.add(l);
                        } else {

                            templeadItemList1.add(l);
                        }
                    }
                    opps.clear();
                    opps.addAll(tempOppList1);
                    opps.addAll(tempOppList2);
                    leadItems.clear();
                    leadItems.addAll(templeadItemList1);
                    leadItems.addAll(tempLeadItemList2);
                }
            }
        }
    }

    public void notifyOppOwners () {

        try {

            insert reminders;
            System.debug('*** reminders: ' + reminders);

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
            System.debug('*** e.getLineNumber(): ' + e.getLineNumber() + '');
        }
    }

    public PageReference editLead () {

        String newURL = '';
        if (callLogId==''||callLogId==null) {

            newURL = '/apex/NewLeadV2?Id=' + myVar;
        } else {

            newURL = '/apex/NewLeadV2?Id=' + myVar + 'EIC&CallLogId=' + callLogId;
        }

        return new PageReference(newURL);
    }

    public PageReference createLead () {

        User currentUser = [SELECT ChineseNameofCity__c, Business_Line_Formula__c
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];
        String newURL = '';
        if (callLogId == '' || callLogId == null) {

            newURL = '/apex/NewLeadV2?Company=EIC';
        } else{

            newURL = '/apex/NewLeadV2?Company=EIC&CallLogId=' + callLogId;
        }

        if (String.isNotBlank(phone) &&  phone.length() == 11 && phone.left(1) != '0') {

            newURL += '&mobile=' + phone;
        } else if (String.isNotBlank(phone)) {

            newURL += '&phone='+phone;
        }

        if (accs.size() > 0) {

            newURL += '&name=' + accs[0].Name;
        }

        return new PageReference(newURL);
    }
}