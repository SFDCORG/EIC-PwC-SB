/**************************************************************************************************
 * Name: ConvertLeadItemExtension
 * Object: Lead, Lead_Item__c
 * Purpose: Lead Convertion extension and it is used to convert lead item
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-18
 * Modified History: 
 * 2016-04-18    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
public without sharing class ConvertLeadItemExtension {

    public List<Account> accs { get; set; }
    public Appoitment__c appointTime { get; set; }
    public List<Lead_Item__c> dupleadItems { get; set; }
    public List<Lead_Item__c> masterleadItems { get; set; }
    public Boolean isDisabled { get; set; }
    public String batchId { get;set; }
    public String leadId { get;set; }

    Lead selectedLead = new Lead ();
    List<Lead> leadList = new List<Lead> ();
    Opportunity existedOpp = new Opportunity ();
    Lead_Item__c selectedItem = new Lead_Item__c ();
    List<Appoitment__c> followups = new List<Appoitment__c> ();
    Map<String, String> phoneMapType = new Map<String, String> ();

    public ConvertLeadItemExtension(ApexPages.StandardController con) {
        if (con == NULL || con.getId() == NULL) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_NO_ITEM_ERROR));
            isDisabled = TRUE;
            return;

        } else {
            selectedItem = (Lead_Item__c) con.getRecord();
        }
        initialData();
    }

    public void initialData() {
        Set<Id> accIds = new Set<Id> ();
        Set<Id> mobileItemIds = new Set<Id> ();
        Set<Id> leadIds = new Set<Id> ();
        Set<String> linkedKeys = new Set<String> ();

        accs = new List<Account> ();
        appointTime = new Appoitment__c ();
        dupleadItems = new List<Lead_Item__c> ();
        masterleadItems = new List<Lead_Item__c> ();
        isDisabled = FALSE;

        // Gets the current lead item clicked by the current user
        selectedItem = [SELECT Lead__c, Is_Converted__c , Mobile__c, Mobile_Linked_Key__c, 
                               Fix_Phone__c, Fix_Phone_Linked_Key__c, Business_Line__c, 
                               Intended_City__c, Project__c, Marketing_Channel_Lv3__c, 
                               Intended_Country__c, Lead__r.Lead_Source__c,
                               Lead__r.Intended_Office__c, Lead__r.Area_Code__c, 
                               Lead__r.Name, Lead__r.Consultation_Mode__c, 
                               Lead__r.ID_Number__c, Lead__r.Campaign__c,
                               Lead__r.Country__c, Lead__r.ProvinceLookup__c, 
                               Lead__r.City__c, Lead__r.District__c, 
                               Lead__r.Gender__c, Lead__r.Other_Product__c,
                               Lead__r.Birthday__c, Lead__r.ID_Type__c, 
                               Lead__r.Convenient_Time__c, Lead__r.GPA__c, 
                               Lead__r.Grade__c, Lead__r.Education_Level__c,
                               Lead__r.QQ__c, Lead__r.Wechat__c, Lead__r.Email, 
                               Fix_Phone_Unique_Key__c, Mobile_Unique_Key__c
                        FROM Lead_Item__c
                        WHERE Id = :selectedItem.Id];

        if (selectedItem.Is_Converted__c) {
            isDisabled = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_CONVERTED_ERROR));
            return;
        }

        batchId = ApexPages.currentPage().getParameters().get('batchId');
        leadId = selectedItem.Lead__c;

        if (String.isNotBlank(selectedItem.Mobile__c)) {
            phoneMapType.put(selectedItem.Mobile__c, Constants.MOBILE_CN);
            linkedKeys.add(selectedItem.Mobile_Linked_Key__c);
        }

        if (String.isNotBlank(selectedItem.Fix_Phone__c)) {
            String fixPhone = selectedItem.Lead__r.Area_Code__c == NULL ? 
            '' : 
            selectedItem.Lead__r.Area_Code__c +  selectedItem.Fix_Phone__c;
            phoneMapType.put(fixPhone, Constants.FIX_PHONE_CN);
            linkedKeys.add(selectedItem.Fix_Phone_Linked_Key__c);
        }

        // Gets the current lead clicked by the current user
        selectedLead = [SELECT  (SELECT Id FROM Lead_Items__r),
                                Converted_Lead_Item_No__c, Description,
                                Recommend_Account__c, Recommend_SA__c, Recommend_User__c, 
                                Customer_Service__c, Extension_Agent__c, OriginCampaign__c
                        FROM Lead 
                        WHERE Id = : selectedItem.Lead__c];

        // Gets all duplicated lead items by mobile
        for (Lead_Item__c li : [SELECT Name, Lead__c,  Status__c, CreatedDate,
                                       Marketing_Channel_Lv3__c,  Business_Line__c, 
                                       Project__c, Intended_City__c, Intended_Country__c, 
                                       Lead__r.Other_Product__c, Lead__r.Name, 
                                       Lead__r.OwnerId, Lead__r.Campaign__c, 
                                       Lead__r.Consultation_Mode__c, Lead__r.CreatedDate, 
                                       Lead__r.Intended_Office__c, Mobile_Linked_Key__c
                                FROM Lead_Item__c
                                WHERE Mobile_Linked_Key__c IN: linkedKeys
                                AND Is_Converted__c = FALSE 
                                ORDER BY Lead__r.CreatedDate, Mobile__c]) {

            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            mobileItemIds.add(li.Id);
            leadIds.add(li.Lead__c);

            // Adds to duplicated lead item
            if (masterleadItems.size() > 0) {
                li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                dupleadItems.add(li);

            // Sets the first lead item
            } else {
                li.Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
                masterleadItems.add(li);
            }
        }

        // Gets all duplicated lead item by fix phone
        for (Lead_Item__c li : [SELECT Name, Lead__c,  Status__c, 
                                       CreatedDate,
                                       Marketing_Channel_Lv3__c, 
                                       Business_Line__c, 
                                       Project__c, Intended_City__c, 
                                       Intended_Country__c, 
                                       Lead__r.Other_Product__c,
                                       Lead__r.Name, Lead__r.OwnerId, 
                                       Lead__r.Campaign__c, 
                                       Lead__r.Consultation_Mode__c, 
                                       Lead__r.CreatedDate, 
                                       Lead__r.Intended_Office__c,
                                       Fix_Phone_Linked_Key__c
                                FROM Lead_Item__c
                                WHERE Fix_Phone_Linked_Key__c IN :linkedKeys
                                AND Is_Converted__c = FALSE 
                                ORDER BY Lead__r.CreatedDate, Fix_Phone__c]) {

            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            leadIds.add(li.Lead__c);

            // Resets the successful lead item
            if (masterleadItems.size() == 1) {
                if (masterleadItems[0].Lead__r.CreatedDate > li.Lead__r.CreatedDate) {
                    dupleadItems.add(masterleadItems[0]);
                    masterleadItems.clear();
                    masterleadItems.add(li);
                }

            // They are added to duplicated lead item
            } else if (masterleadItems.size() > 0 && !mobileItemIds.contains(li.Id)) {
                li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                dupleadItems.add(li);

            // Sets the first lead item
            } else if (masterleadItems.size() == 0) {
                li.Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
                masterleadItems.add(li);
            }
        }
        // Gets all followups from lead
        followups = [SELECT Account__c 
                     FROM Appoitment__c 
                     WHERE Lead__c IN :leadIds];

        leadList = [SELECT Is_Master__c, Converted_Account__c 
                    FROM Lead 
                    WHERE Id IN :leadIds];

        // Gets all accounts depending on phone/mobile
        for (Contact_EIC__c contact :[SELECT Account__c
                                      FROM Contact_EIC__c
                                      WHERE UniqueContact__c IN :phoneMapType.keySet()
                                      AND isInvalid__c = FALSE]) {
            accIds.add(contact.Account__c);
            break;
        }

        // Checks the existed opportunity
        for (Account acc :[SELECT Name, OwnerId,
                                  (SELECT Department__c, IsClosed, IsWon,
                                          Description, RecordTypeId, 
                                          RecordType.Name, Name, 
                                          StageName, Project__c, 
                                          OwnerId , Intended_City__c
                                   FROM Opportunities)
                           FROM Account
                           WHERE Id IN :accIds]) {
            accs.add(acc);
            for (Opportunity opp : acc.Opportunities) {

                // There is a same TestPrep opportunity
                if ((opp.RecordType.Name == 'TestPrep' || 
                     opp.RecordType.Name == 'Scholar Tree' || 
                     opp.RecordType.Name == 'Cooperative') && !opp.IsClosed) {
                    String oppKey = '';
                    if (opp.RecordType.Name == 'TestPrep') {
                        oppKey = opp.Intended_City__c + ';' + Constants.TESTPREP_CN;

                    } else if (opp.RecordType.Name == 'Scholar Tree') {
                        oppKey = opp.Intended_City__c + ';' + Constants.SCHOLAR_TREE_CN;

                    } else if (opp.RecordType.Name == 'Cooperative') {
                        oppKey = opp.Intended_City__c + ';' + Constants.COOPERATIVE_CN;
                    }

                    if (selectedItem.Mobile_Linked_Key__c.contains(oppKey)) {
                        existedOpp = opp;
                        dupleadItems.addAll(masterleadItems);
                        masterleadItems.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                            Constants.LEAD_CONVERT_SLEEP_ERROR));
                        return;
                    }

                // There is a duplicated project for counselling
                } else if (opp.RecordType.Name == 'Counselling' && (!opp.IsClosed || opp.IsWon)) {
                    String oppKey = opp.Intended_City__c + ';' + masterleadItems[0].Business_Line__c + ';' + opp.Project__c ;

                    if ((String.isNotBlank(selectedItem.Mobile_Unique_Key__c) && 
                         selectedItem.Mobile_Unique_Key__c.contains(oppKey)) || 
                        (String.isNotBlank(selectedItem.Fix_Phone_Unique_Key__c) && 
                         selectedItem.Fix_Phone_Unique_Key__c.contains(oppKey)) ) {
                        existedOpp = opp;
                        dupleadItems.addAll(masterleadItems);
                        masterleadItems.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                            Constants.LEAD_CONVERT_SLEEP_ERROR));
                        return;
                    }
                }
            }
        }
    }

    public PageReference confirmConvert() {
        Boolean isConvert = FALSE;
        if (selectedItem != NULL) {
            isConvert = [SELECT Is_Converted__c FROM Lead_Item__c WHERE Id = :selectedItem.Id].Is_Converted__c;
        }

        if (isConvert) {
            isDisabled = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_CONVERTED_ERROR));
            return NULL;

        } else if ((String.isBlank(selectedItem.Project__c) || 
                     selectedItem.Project__c == Constants.UNKNOWN_CN ) && 
                    selectedItem.Business_Line__c == Constants.COUNSELLING_CN && 
                    String.isBlank(selectedItem.Lead__r.Other_Product__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_COUNTRY_ERROR));
            return NULL;

        } else if (String.isBlank(selectedItem.Project__c) && 
                   selectedItem.Business_Line__c == Constants.TESTPREP_CN && 
                   String.isBlank(selectedItem.Lead__r.Other_Product__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_PROJECT_ERROR));
            return NULL;

        } else if (String.isBlank(selectedItem.Project__c) && 
                   selectedItem.Business_Line__c == Constants.COOPERATIVE_CN) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_COOPERATIVE_ERROR));
            return NULL;

        } else if ((appointTime.Due_Date__c == NULL && String.isNotBlank(appointTime.Due_Time__c)) ||
                   (appointTime.Due_Date__c != NULL && String.isBlank(appointTime.Due_Time__c)) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                Constants.LEAD_CONVERT_APPOINT_TIME_ERROR));
            return NULL;

        } else if (selectedItem == NULL) {
            isDisabled = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                Constants.LEAD_CONVERT_NO_ITEM_ERROR));
            return NULL;

        }

        Utils.runLeadTrigger = FALSE;
        SavePoint sp = Database.setSavepoint();
        List<Contact_EIC__c> contacts = new List<Contact_EIC__c> ();

        try {
            Id invitationRTId = Utils.getRecordTypeId('Appoitment__c', 'Invitation');
            Id followupRTId = Utils.getRecordTypeId('Appoitment__c', 'Follow Up');
            String department = Utils.countryMapDept.get(selectedItem.Project__c) == NULL ? 
                                '' : 
                                Utils.countryMapDept.get(selectedItem.Project__c);

            // If the opportunity is existed.
            if (existedOpp.Id != NULL) {

                // UpsertS Contact information
                contacts = Utils.createContacts(accs[0],
                                                phoneMapType,
                                                selectedItem.Lead__r.QQ__c,
                                                selectedItem.Lead__r.Wechat__c,
                                                selectedItem.Lead__r.Email);
                Database.upsert(contacts, Contact_EIC__c.UniqueContact__c, false);

                // Matches the follow up to account
                followups = Utils.updateFollowups(followups, accs[0].Id);
                Database.update(followups, FALSE);

                // Updates lead's converted account
                for (Lead lead:leadList) {
                    if (lead.Converted_Account__c == NULL) {
                        lead.Converted_Account__c = accs[0].Id;
                    }
                }

                Database.update(leadList, FALSE);

                // Updates lead items
                for (Lead_Item__c li :dupleadItems) {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                    li.Opportunity__c = existedOpp.Id;
                }
                update dupleadItems;

                if (appointTime.Due_Date__c != NULL) {
                    Appoitment__c appoint = new Appoitment__c ();
                    appoint.Opportunity__c = existedOpp.Id;
                    appoint.RecordTypeId = invitationRTId;
                    appoint.Intended_City__c = existedOpp.Intended_City__c;
                    appoint.Assign_To__c = existedOpp.OwnerId;
                    appoint.Due_Date__c = appointTime.Due_Date__c;
                    appoint.Due_Time__c = appointTime.Due_Time__c;
                    appoint.Appointment_Type__c = Constants.APP_FIRST_SHOWUP_CN;

                    if (batchId !=null && batchId !='') {
                        List<CallLog_History__c> cl = [SELECT Id
                                                       FROM CallLog_History__c
                                                       WHERE BatchCallOut__r.Name = :batchId
                                                       AND Lead__c = :leadId];
                        if (cl.size() > 0) {
                            appoint.CalllogHistory__c = cl[0].Id;
                        }
                    }
                    insert appoint;
                }

                // Creates exam record for GPA
                if (selectedItem.Lead__r.GPA__c != 0 && selectedItem.Lead__r.GPA__c != NULL) {
                    if (!Utils.hasTested(accs[0].Id, 'GPA')) {
                        Score__c GPA = new Score__c (
                            Tester__c = accs[0].Id,
                            Test_Score__c = String.valueOf(selectedItem.Lead__r.GPA__c),
                            Test_Type__c = 'GPA');
                        insert GPA;
                    }
                }

                // Creates the education level
                if (String.isNotBlank(selectedItem.Lead__r.Grade__c) ||
                    String.isNotBlank(selectedItem.Lead__r.Education_Level__c)) {
                    if (!Utils.hasEducation(accs[0].Id, selectedItem.Lead__r.Education_Level__c, selectedItem.Lead__r.Grade__c)) {
                        Education__c edu = new Education__c (
                            Account__c = accs[0].Id,
                            Education_Level__c = selectedItem.Lead__r.Education_Level__c,
                            Grade__c = selectedItem.Lead__r.Grade__c);
                        insert edu;
                    }
                }

                String newPage = '/' + existedOpp.Id;
                return new PageReference (newPage);

            // Creates a new account and opportunity
            } else if (accs.size() == 0) {
                Id accId;

                //  Gets the current lead clicked by the current user
                selectedLead = [
                    SELECT Recommend_Account__c, Recommend_SA__c,
                           Recommend_User__c, Customer_Service__c,
                           Extension_Agent__c, OriginCampaign__c,
                           Converted_Account__c, Converted_Lead_Item_No__c,
                           Is_Master__c, Description,
                           (SELECT Id FROM Lead_Items__r)
                    FROM Lead
                    WHERE Id = :selectedItem.Lead__c];
                if (selectedLead.Converted_Account__c != NULL) {
                    accId = selectedLead.Converted_Account__c;

                } else {
                    Account newAcc = new Account (
                        Name = selectedItem.Lead__r.Name,
                        RecordTypeId = Utils.getRecordTypeId('Account', 'EIC Account'),
                        Gender__c = selectedItem.Lead__r.Gender__c,
                        ID_Type__c = selectedItem.Lead__r.ID_Type__c,
                        ID_Number__c = selectedItem.Lead__r.ID_Number__c,
                        Country__c = selectedItem.Lead__r.Country__c,
                        Province__c = selectedItem.Lead__r.ProvinceLookup__c,
                        City__c = selectedItem.Lead__r.City__c,
                        District__c = selectedItem.Lead__r.District__c,
                        Birthday__c = selectedItem.Lead__r.Birthday__c,
                        Convenient_Time__c = selectedItem.Lead__r.Convenient_Time__c);

                    insert newAcc;

                    for (Lead lead:leadList) {
                        if (lead.Converted_Account__c == NULL) {
                            lead.Converted_Account__c = newAcc.Id;
                        }
                    }

                    Database.update(leadList, FALSE);

                    selectedLead.Is_Master__c = TRUE;
                    update selectedLead;

                    accId = newAcc.Id;
                    // Creates Contact information
                    contacts = Utils.createContacts(newAcc,
                                                    phoneMapType,
                                                    selectedItem.Lead__r.QQ__c,
                                                    selectedItem.Lead__r.Wechat__c,
                                                    selectedItem.Lead__r.Email);

                    try {
                        insert contacts;

                    } catch (Exception e) {

                        System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());

                        Database.rollback(sp);
                        initialData();

                        if (e.getDmlType(0) == StatusCode.DUPLICATE_VALUE) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                                Constants.LEAD_CONVERT_CONTACTS_ERROR));

                        } else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                Constants.LEAD_CONVERT_CONFLICT_ERROR));
                        }
                        return NULL;
                    }
                }

                // Matches the follow up to account
                followups = Utils.updateFollowups(followups, accId);
                Database.update(followups, FALSE);

                Opportunity opp = new Opportunity(
                    Name = selectedItem.Lead__r.Name + selectedItem.Intended_City__c + selectedItem.Business_Line__c + '商机',
                    AccountId = accId,
                    RecordTypeId = getOppRecordTypeId(selectedItem.Business_Line__c),
                    CloseDate = System.today() + 30,
                    Intended_Office__c = selectedItem.Lead__r.Intended_Office__c,
                    Intended_City__c = selectedItem.Intended_City__c,
                    Project__c = selectedItem.Project__c,
                    Consultation_Mode__c = selectedItem.Lead__r.Consultation_Mode__c,
                    Marketing_Channel_Lv3__c = masterleadItems[0].Marketing_Channel_Lv3__c,
                    Level_4_Promotion_Channel__c = masterleadItems[0].Lead__r.Campaign__c,
                    StageName = Constants.UNKNOWN_CN,
                    Other_Product__c = selectedItem.Lead__r.Other_Product__c,
                    Department__c = department,
                    Description = selectedLead.Description,
                    Recommend_Account__c = selectedLead.Recommend_Account__c,
                    Recommend_SA__c = selectedLead.Recommend_SA__c,
                    Recommend_User__c = selectedLead.Recommend_User__c,
                    Customer_Service__c = selectedLead.Customer_Service__c,
                    Extension_Agent__c = selectedLead.Extension_Agent__c,
                    OriginCampaign__c = selectedLead.OriginCampaign__c);
                if (selectedItem.Business_Line__c == Constants.TESTPREP_CN) {
                    opp.Department__c = Constants.DEPARTMENT_TESTPREP_CN;

                } else if (selectedItem.Business_Line__c == Constants.COOPERATIVE_CN) {
                    opp.Department__c = Constants.COOPERATIVE_CN;

                } else if (String.isNotBlank(selectedItem.Lead__r.Other_Product__c) && 
                           String.isBlank(selectedItem.Project__c)) {
                    opp.Project__c = Constants.OTHER_PRODUCT_CN;
                }

                if (selectedItem.Business_Line__c == Constants.COUNSELLING_CN && 
                    String.isNotBlank(selectedItem.Project__c)) {
                    opp.Name = selectedItem.Lead__r.Name +
                               selectedItem.Intended_City__c +
                               selectedItem.Business_Line__c +
                               selectedItem.Project__c + '商机';
                }

                insert opp;

                masterleadItems[0].Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
                masterleadItems[0].Opportunity__c = opp.Id;
                update masterleadItems[0];

                for (Lead_Item__c li : dupleadItems) {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                    li.Opportunity__c = opp.Id;
                }

                update dupleadItems;

                // If the appoint time is not blank, we will create an appoint, and then assign it to the consultant
                Appoitment__c appoint = new Appoitment__c ();
                if (appointTime.Due_Date__c != NULL) {
                    appoint.Opportunity__c = opp.Id;
                    appoint.RecordTypeId = invitationRTId;
                    appoint.Intended_City__c = opp.Intended_City__c;
                    appoint.Due_Date__c = appointTime.Due_Date__c;
                    appoint.Due_Time__c = appointTime.Due_Time__c;
                    appoint.Assign_To__c = UserInfo.getUserId();
                    appoint.Appointment_Type__c = Constants.APP_FIRST_SHOWUP_CN;
                    if (batchId !=null && batchId !='') {
                        List<CallLog_History__c> cl = [SELECT Id
                                                       FROM CallLog_History__c
                                                       WHERE BatchCallOut__r.Name = :batchId 
                                                       AND Lead__c = :leadId];
                        if (cl.size() > 0) {
                            appoint.CalllogHistory__c = cl[0].Id;
                        }
                    }

                    insert appoint;
                }

                // Creates exam record for GPA
                if (selectedItem.Lead__r.GPA__c != 0 && 
                    selectedItem.Lead__r.GPA__c != NULL) {
                    Score__c GPA = new Score__c (
                        Tester__c = accId,
                        Test_Score__c = String.valueOf(selectedItem.Lead__r.GPA__c),
                        Test_Type__c = 'GPA');

                    insert GPA;
                }

                // Creates the education level
                if (String.isNotBlank(selectedItem.Lead__r.Grade__c) || 
                    String.isNotBlank(selectedItem.Lead__r.Education_Level__c)) {
                    if (!Utils.hasEducation(accId, selectedItem.Lead__r.Education_Level__c, selectedItem.Lead__r.Grade__c)) {
                        Education__c edu = new Education__c (
                            Account__c = accId,
                            Education_Level__c = selectedItem.Lead__r.Education_Level__c,
                            Grade__c = selectedItem.Lead__r.Grade__c);

                        insert edu;
                    }
                }

                PageReference assignOppPage = new PageReference (
                    '/apex/OpportunitiesAssignPage?Id=' + opp.Id +
                    '&OppType=' + opp.RecordTypeId +
                    '&appointId=' + appoint.Id);
                assignOppPage.setRedirect(TRUE);

                return assignOppPage;

            } else {
                // Upserts Contact information
                contacts = Utils.createContacts(accs[0],
                                                phoneMapType,
                                                selectedItem.Lead__r.QQ__c,
                                                selectedItem.Lead__r.Wechat__c,
                                                selectedItem.Lead__r.Email);
                Database.upsert(contacts, Contact_EIC__c.UniqueContact__c, false);

                // Matches the follow up to account
                followups = Utils.updateFollowups(followups, accs[0].Id);
                Database.update(followups, FALSE);

                Opportunity opp = new Opportunity(
                    Name = accs[0].Name + selectedItem.Intended_City__c + selectedItem.Business_Line__c + Constants.OPPORTUNITY_CN,
                    AccountId = accs[0].Id,
                    RecordTypeId = getOppRecordTypeId(selectedItem.Business_Line__c),
                    CloseDate = System.today() + 30,
                    Intended_Office__c = selectedItem.Lead__r.Intended_Office__c,
                    Intended_City__c = selectedItem.Intended_City__c,
                    Project__c = selectedItem.Project__c,
                    Consultation_Mode__c = selectedItem.Lead__r.Consultation_Mode__c,
                    Marketing_Channel_Lv3__c = masterleadItems[0].Marketing_Channel_Lv3__c,
                    Level_4_Promotion_Channel__c = masterleadItems[0].Lead__r.Campaign__c,
                    StageName = Constants.OPPORTUNITY_STAGE_UNASSIGNED,
                    Other_Product__c = selectedItem.Lead__r.Other_Product__c,
                    Department__c = department,
                    Description = selectedLead.Description,
                    Recommend_Account__c = selectedLead.Recommend_Account__c,
                    Recommend_SA__c = selectedLead.Recommend_SA__c,
                    Recommend_User__c = selectedLead.Recommend_User__c,
                    Customer_Service__c = selectedLead.Customer_Service__c,
                    Extension_Agent__c = selectedLead.Extension_Agent__c,
                    OriginCampaign__c = selectedLead.OriginCampaign__c);

                if (selectedItem.Business_Line__c == Constants.COOPERATIVE_CN) {

                    opp.Department__c = Constants.COOPERATIVE_CN;
                } else if (selectedItem.Business_Line__c == Constants.TESTPREP_CN) {

                    opp.Department__c = Constants.DEPARTMENT_TESTPREP_CN;
                } else if (String.isNotBlank(selectedItem.Lead__r.Other_Product__c) && 
                           String.isBlank(selectedItem.Project__c)) {

                    opp.Project__c = Constants.OTHER_PRODUCT_CN;
                }

                if (selectedItem.Business_Line__c == Constants.COUNSELLING_CN && 
                    String.isNotBlank(selectedItem.Project__c )) {
                    opp.Name = accs[0].Name +
                               selectedItem.Intended_City__c +
                               selectedItem.Business_Line__c +
                               selectedItem.Project__c + Constants.OPPORTUNITY_CN;
                }

                insert opp;

                for (Lead lead:leadList) {
                    if (lead.Converted_Account__c == NULL) {
                        lead.Converted_Account__c = accs[0].Id;
                    }
                }

                Database.update(leadList, FALSE);

                masterleadItems[0].Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
                masterleadItems[0].Opportunity__c = opp.Id;
                update masterleadItems[0];

                for (Lead_Item__c li :dupleadItems) {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                    li.Opportunity__c = opp.Id;
                }

                update dupleadItems;

                // If the appoint time is not blank, we will create an appoint, and then assign it to the consultant
                Appoitment__c appoint = new Appoitment__c ();
                if (appointTime.Due_Date__c != NULL) {
                    appoint.Opportunity__c = opp.Id;
                    appoint.RecordTypeId = invitationRTId;
                    appoint.Intended_City__c = opp.Intended_City__c;
                    appoint.Due_Date__c = appointTime.Due_Date__c;
                    appoint.Due_Time__c = appointTime.Due_Time__c;
                    appoint.Assign_To__c = UserInfo.getUserId();
                    appoint.Appointment_Type__c = Constants.APP_FIRST_SHOWUP_CN;
                    if (batchId !=null && batchId !='') {
                        List<CallLog_History__c> cl = [SELECT Id 
                                                       FROM CallLog_History__c 
                                                       WHERE BatchCallOut__r.Name = :batchId 
                                                       AND Lead__c = :leadId];
                        if (cl.size() > 0) {
                            appoint.CalllogHistory__c = cl[0].Id;
                        }
                    }

                    insert appoint;
                }

                // Creates exam record for GPA
                if (selectedItem.Lead__r.GPA__c != 0 && 
                    selectedItem.Lead__r.GPA__c != NULL) {
                    if (!Utils.hasTested(accs[0].Id, 'GPA')) {
                        Score__c GPA = new Score__c (
                            Tester__c = accs[0].Id,
                            Test_Score__c = String.valueOf(selectedItem.Lead__r.GPA__c),
                            Test_Type__c = 'GPA');

                        insert GPA;
                    }
                }

                // Creates the education level
                if (String.isNotBlank(selectedItem.Lead__r.Grade__c) || 
                    String.isNotBlank(selectedItem.Lead__r.Education_Level__c)) {
                    if (!Utils.hasEducation(accs[0].Id, selectedItem.Lead__r.Education_Level__c, selectedItem.Lead__r.Grade__c)) {
                        Education__c edu = new Education__c (
                            Account__c = accs[0].Id,
                            Education_Level__c = selectedItem.Lead__r.Education_Level__c,
                            Grade__c = selectedItem.Lead__r.Grade__c);

                        insert edu;
                    }
                }
                PageReference assignOppPage = new PageReference (
                    '/apex/OpportunitiesAssignPage?Id=' + opp.Id +
                    '&OppType=' + opp.RecordTypeId +
                    '&appointId=' + appoint.Id);
                assignOppPage.setRedirect(TRUE);

                return assignOppPage;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            update selectedLead;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

            return NULL;
        }
    }

    // If the user cancel the convertion, the page will redirect to lead detail page
    public PageReference cancel() {
        PageReference leadPage = new PageReference ('/' +  selectedItem.Lead__c);
        leadPage.setRedirect(TRUE);

        return leadPage;
    }

    // Gets the record type by Chinese business line name
    String getOppRecordTypeId (String recordTypeName) {
        Id recordTypeId;

        if (recordTypeName == Constants.COUNSELLING_CN) {
            recordTypeId = Constants.OPP_RT_COUNSELLING_ID;

        } else if (recordTypeName == Constants.TESTPREP_CN || recordTypeName == 'NP') {
            recordTypeId = Constants.OPP_RT_TESTPREP_ID;

        } else if (recordTypeName == Constants.SCHOLAR_TREE_CN) {
            recordTypeId = Constants.OPP_RT_SCHOLAR_TREE_ID;

        } else if (recordTypeName == Constants.COOPERATIVE_CN) {
            recordTypeId = Constants.OPP_RT_COOPERATIVE_ID;

        }
        return recordTypeId;
    }
}