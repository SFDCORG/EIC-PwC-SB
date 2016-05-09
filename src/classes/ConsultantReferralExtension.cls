/**************************************************************************************************
 * Name: ConsultantReferralExtension
 * Object: Account, SMS_Template__c
 * Purpose: Send SMS
 * Requirement:
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-29
 * Modified History:
 * 2015-10-29    Vicia Wang    Writes comments in this format
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public without sharing class ConsultantReferralExtension {

    public Lead leadVar { get; set; }
    public Boolean isTestPrep { get; set; }
    public Set<String> areaCodes = new Set<String> (new List<String> {'010', 
                                                                      '021', 
                                                                      '022', 
                                                                      '023', 
                                                                      '024', 
                                                                      '025', 
                                                                      '027', 
                                                                      '028', 
                                                                      '029', 
                                                                      '020'});

    public List<SelectOption> modes { get; set; }
    public String mode { get; set; }
    public String selected { get; set; }

    Account account = new Account ();
    User currentUser = new User ();
    List<Opportunity> myOpps = new List<Opportunity> ();

    public ConsultantReferralExtension (ApexPages.StandardController controller) {

        String accId;
        isTestPrep = FALSE;
        try {

            if (String.isNotBlank(controller.getId())) {
                accId = controller.getId();

            }

            currentUser = [SELECT ChineseNameofCity__c, Business_Line_Formula__c 
                           FROM User 
                           WHERE Id = :UserInfo.getUserId()];

            if (currentUser.Business_Line_Formula__c == Constants.TESTPREP_CN) {
                isTestPrep = TRUE;
            }

            mode = Constants.F2F_CONSULTING_CN;
            modes = new List<SelectOption> ();
            modes.add(new SelectOption(Constants.F2F_CONSULTING_CN, Constants.F2F_CONSULTING_CN));
            modes.add(new SelectOption(Constants.BRANCH_CONSULTING_CALLOUT_CN, Constants.BRANCH_CONSULTING_CALLOUT_CN));

            LeadVar = [SELECT Intended_City__c, Intended_Office__c, 
                              Is_Counselling__c, Counselling_Project__c, 
                              Is_TestPrep__c, TestPrep_Project__c,
                              Is_Cooperative_Education__c, Cooperative_Education_Project__c, 
                              Is_Scholar_Tree__c, Text_Area__c
                       FROM Lead
                       LIMIT 1];

            if (String.isNotBlank(currentUser.ChineseNameofCity__c)) {
                leadVar.Intended_City__c = currentUser.ChineseNameofCity__c;
            }

            leadVar.Text_Area__c = '';
            leadVar.Intended_Office__c = 'N/A';
            LeadVar.Is_Counselling__c = FALSE;
            LeadVar.Counselling_Project__c = NULL;
            LeadVar.Is_TestPrep__c = FALSE;
            LeadVar.TestPrep_Project__c = NULL;
            LeadVar.Is_Scholar_Tree__c = FALSE;
            leadVar.Is_Cooperative_Education__c = FALSE;
            leadVar.Cooperative_Education_Project__c = NULL;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
        }

        // As we need create a lead, we must get a mobile/phone
        List<String> phoneTypeList = new List<String> { Constants.MOBILE_CN, Constants.FIX_PHONE_CN };
        account = [SELECT Name,
                          (SELECT Unique_Contact__c, Contact_Type__c 
                           FROM Contacts__r
                           WHERE Contact_Type__c IN :phoneTypeList
                           AND isInvalid__c = FALSE)
                   FROM Account 
                   WHERE Id = :accId];

        if (account.Contacts__r.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Phone));
            return;
        }

        // When a user wants to create referral opportunity, he need has already an opportunity belongs to the account
        myOpps = [SELECT Intended_City__c, RecordTypeId, 
                         Intended_Office__c, Project__c, 
                         Department__c ,
                         (Select Id, Lead__c From Lead_Items__r)
                  FROM Opportunity
                  WHERE AccountId = :accId
                  AND OwnerId = :UserInfo.getUserId()];

        if (myOpps.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Opportunities));
            return;
        }
    }

    public PageReference confirmConvert () {

        // Consultant do the second referral
        if (leadVar.Is_TestPrep__c) {
            List<Opportunity> testPrepOpps = new List<Opportunity> ();
            testPrepOpps = [SELECT Is_Second_Referral__c,
                                   AccountId, OwnerId, 
                                   sys_LastAssignTime__c, Second_Referral_Date__c,
                                   Marketing_Channel_Lv1__c, Marketing_Channel_Lv3_Formula__c, 
                                   Level_4_Promotion_Channel__r.Business_line__c,
                                   (SELECT Id 
                                    FROM Appointments__r 
                                    WHERE RecordTypeId = :Constants.APP_RT_CONS_REFERRAL_FOLLOW_UP_ID 
                                    AND Consultant_Referral_Type__c = :Constants.SECOND_REFERRAL_CN)
                            FROM Opportunity
                            WHERE AccountId = :account.Id
                            AND RecordType.Name = 'Testprep'
                            AND Intended_City__c = :leadVar.Intended_City__c
                            AND IsClosed = FALSE];

            // Takes these conditions into Second Referral consideration
            if (testPrepOpps.size() > 0 && testPrepOpps[0].Appointments__r.size() == 0) {
                if (testPrepOpps[0].Marketing_Channel_Lv3_Formula__c != Constants.CONSULTANT_REFERRAL_CN &&
                    testPrepOpps[0].Marketing_Channel_Lv3_Formula__c != Constants.TESTPREP_SA_REFERRAL_CN &&
                    testPrepOpps[0].Marketing_Channel_Lv3_Formula__c != Constants.OLD_CUSTOMER_REFERRAL_CN) {

                    // We can not do the referral for testprep's cooperative campaign
                    if (testPrepOpps[0].Marketing_Channel_Lv3_Formula__c == Constants.ADMISSIONS_REPRESENTATIVE_CN &&
                        testPrepOpps[0].Level_4_Promotion_Channel__r.Business_line__c == Constants.TESTPREP_CN) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                            Constants.CONSULTANT_REFERRAL_WITH_OPEN_OPP_ERROR));
                        return NULL;
                    }

                    Appoitment__c followup = new Appoitment__c (
                        Name = Constants.CONSULTANT_REFERRAL_CREATE_APP_NAME_INFO,
                        RecordTypeId = Constants.APP_RT_CONS_REFERRAL_FOLLOW_UP_ID,
                        Status__c = Constants.APP_COMPLETED,
                        Opportunity__c = testPrepOpps[0].Id,
                        Consultant_Referral_Type__c = Constants.SECOND_REFERRAL_CN,
                        Account__c = testPrepOpps[0].AccountId,
                        Description__c = leadVar.Text_Area__c,
                        Assign_To__c = testPrepOpps[0].OwnerId,
                        Intended_City__c = leadVar.Intended_City__c,
                        Intended_Office__c = leadVar.Intended_Office__c);

                    try {

                        insert followup;

                        testPrepOpps[0].Is_Second_Referral__c = TRUE;
                        testPrepOpps[0].Second_Referral_Date__c = System.Today();
                        update testPrepOpps[0];
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                            System.Label.Consultant_Referral_Success_2nd));
                        return NULL;

                    } catch (Exception e) {
                        System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
                        System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                        return NULL;
                    }

                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        Constants.CONSULTANT_REFERRAL_WITH_OPEN_OPP_ERROR));
                    return NULL;
                }

            } else if (testPrepOpps.size() > 0 && testPrepOpps[0].Appointments__r.size() > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    Constants.CONSULTANT_REFERRAL_SECOND_ERROR));
                return NULL;
            }
        }


        if (myOpps.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Opportunities));
            return NULL;

        } else if (String.isBlank(LeadVar.Counselling_Project__c) && leadVar.Is_Counselling__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Counselling_Countries));
            return NULL;

        } else if (String.isBlank(leadVar.TestPrep_Project__c) && (leadVar.Is_TestPrep__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Testprep_Projects));
            return NULL;

        } else if (String.isBlank(leadVar.Cooperative_Education_Project__c) && 
                   (leadVar.Is_Cooperative_Education__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Coop_Projects));
            return NULL;
        }

        String intendedOfficeMgrId;
        Id oppRTId;
        List<Campaign> crossSalesCampaign = new List<Campaign> ();
        crossSalesCampaign = [SELECT Id 
                              FROM Campaign 
                              WHERE Name = :Label.Cross_Sales_Campaign_Name];

        if (crossSalesCampaign.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Consultant_Referral_No_Cross_Sales_Campaign));
            return NULL;
        }

        Set<Id> oppLeadIdSet = new Set<Id> ();
        for (Opportunity opp : myOpps) {
            if (opp.Lead_Items__r.size() > 0) {
                for(Lead_Item__c li : opp.Lead_Items__r) {
                    oppLeadIdSet.add(li.Lead__c);
                }
            }
        }

        List<Lead> oppLeadList = [SELECT Campaign__r.Name 
                                  FROM Lead 
                                  Where Id IN :oppLeadIdSet 
                                  ORDER BY CreatedDate];

        String firstCampaignName = '';
        if (oppLeadList.size() > 0) {
            firstCampaignName = oppLeadList[0].Campaign__r.Name;
        }

        SavePoint sp = Database.setSavepoint();
        // Creates the lead
        Lead lead = new Lead(
            Lastname = account.Name,
            Campaign__c = crossSalesCampaign[0].Id,
            Consultation_Mode__c = mode,
            Intended_City__c = leadVar.Intended_City__c,
            Intended_Office__c = leadVar.Intended_Office__c,
            Is_Counselling__c = leadVar.Is_Counselling__c,
            Counselling_Project__c = leadVar.Counselling_Project__c,
            Is_TestPrep__c = leadVar.Is_TestPrep__c,
            TestPrep_Project__c  = leadVar.TestPrep_Project__c,
            Is_Scholar_Tree__c = leadVar.Is_Scholar_Tree__c,
            Is_Cooperative_Education__c = leadVar.Is_Cooperative_Education__c,
            Cooperative_Education_Project__c = leadVar.Cooperative_Education_Project__c,
            Company = 'EIC',
            Status = Constants.LEAD_STATUS_WHOLE_CONVERTED_CN,
            Recommend_User__c  = UserInfo.getUserId(),
            AccountFirstCampaignName__c = firstCampaignName,
            OwnerId = UserInfo.getUserId(),
            Description = leadVar.Text_Area__c);

        leadVar.AccountFirstCampaignName__c = firstCampaignName;

        // Sets the mobile/phone
        for (Contact_EIC__c contact :account.Contacts__r) {
            if (contact.Contact_Type__c == Constants.MOBILE_CN) {
                lead.MobilePhone = contact.Unique_Contact__c;

            } else if (contact.Contact_Type__c == Constants.FIX_PHONE_CN) {
                if (contact.Unique_Contact__c.startsWith('0')) {
                    if (areaCodes.contains(contact.Unique_Contact__c.substring(0,3))) {
                        lead.Area_Code__c = contact.Unique_Contact__c.substring(0,3);
                        lead.Phone = contact.Unique_Contact__c.substring(3,contact.Unique_Contact__c.length());

                    // Gets 4-digital area code
                    } else {
                        lead.Area_Code__c = contact.Unique_Contact__c.substring(0,4);
                        lead.Phone = contact.Unique_Contact__c.substring(4,contact.Unique_Contact__c.length());
                    }

                // If the phone does not contains area code
                } else {
                    lead.Phone = contact.Unique_Contact__c;
                }
            }
        }

        // Sets the office manager
        if (leadVar.Is_Counselling__c) {
            oppRTId = Constants.OPP_RT_COUNSELLING_ID;

        } else if (leadVar.Is_TestPrep__c) {
            oppRTId = Constants.OPP_RT_TESTPREP_ID;

        } else if (leadVar.Is_Scholar_Tree__c) {
            oppRTId = Constants.OPP_RT_SCHOLAR_TREE_ID;

        } else if (leadVar.Is_Cooperative_Education__c) {
            oppRTId = Constants.OPP_RT_COOPERATIVE_ID;
        }

        try {

            insert lead;

            for (Lead_Item__c li :[SELECT Intended_Country__c, Project__c 
                                   FROM Lead_Item__c 
                                   WHERE Lead__c = :lead.Id]) {

                convertLinkedItems(li, account, leadVar, oppRTId, mode);
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                System.Label.Consultant_Referral_Success_Opportunities_created));
            return NULL;

        } catch (Utils.utilException e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

            Database.rollback(sp);
            return NULL;

        } catch (DmlException e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());

            if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }

            Database.rollback(sp);
            return NULL;
        }
    }

    // Converts Lead Item including linked lead items conversion
    public static void convertLinkedItems(Lead_Item__c leadItem, Account account, Lead leadVar, Id oppRTId, String mode) {
        Lead_Item__c selectedItem = new Lead_Item__c ();
        Lead selectedLead = new Lead();
        Set<Id> mobileItemIds = new Set<Id> ();
        List<Lead_Item__c> masterleadItems = new List<Lead_Item__c> ();
        List<Lead_Item__c> dupleadItems = new List<Lead_Item__c> ();
        Set<String> linkedKeys = new Set<String> ();
        Set<Id> leadIds = new Set<Id> ();
        List<Lead> leads = new List<Lead> ();
        List<Appoitment__c> followups = new List<Appoitment__c> ();
        Map<String, String> phoneMapType = new Map<String, String> ();

        selectedItem = [SELECT Mobile__c, Mobile_Linked_Key__c, 
                               Intended_Country__c, Fix_Phone__c, 
                               Fix_Phone_Linked_Key__c, Lead__r.Area_Code__c, 
                               Lead__c, Lead__r.Name, 
                               Lead__r.Gender__c, Lead__r.Consultation_Mode__c, 
                               Lead__r.ID_Number__c, Lead__r.Campaign__c,
                               Business_Line__c, Intended_City__c, 
                               Project__c, Marketing_Channel_Lv3__c
                        FROM Lead_Item__c 
                        WHERE Id = :leadItem.Id];

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

        selectedLead = [SELECT Description, 
                               (SELECT Id FROM Lead_Items__r) 
                        FROM Lead 
                        WHERE Id = :selectedItem.Lead__c];

        // Gets all duplicated by mobile
        for (Lead_Item__c li : [SELECT Name, Lead__c,  
                                       Status__c, CreatedDate,
                                       Marketing_Channel_Lv3__c,  Business_Line__c, 
                                       Project__c, Intended_City__c, 
                                       Intended_Country__c, Lead__r.Name, 
                                       Lead__r.OwnerId, Lead__r.Campaign__c, 
                                       Lead__r.Consultation_Mode__c, Lead__r.CreatedDate, 
                                       Lead__r.Intended_Office__c, Mobile_Linked_Key__c
                                FROM Lead_Item__c
                                WHERE Mobile_Linked_Key__c IN :linkedKeys
                                AND Is_Converted__c = FALSE 
                                ORDER BY Lead__r.CreatedDate, Mobile__c]) {

            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            mobileItemIds.add(li.Id);
            leadIds.add(li.Lead__c);

            // Adds to duplicated lead item
            if (masterleadItems.size() > 0) {
                li.Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN;
                dupleadItems.add(li);

            // Sets the first lead item
            } else {
                li.Status__c = Constants.LEAD_ITEM_STATUS_WON_OPP_CN;
                masterleadItems.add(li);
            }
        }

        // Gets all duplicated by fix phone
        for (Lead_Item__c li : [SELECT Name, Lead__c, 
                                       Status__c, CreatedDate,
                                       Marketing_Channel_Lv3__c,  Business_Line__c, Project__c, 
                                       Intended_City__c, Intended_Country__c, 
                                       Lead__r.Name, Lead__r.OwnerId, 
                                       Lead__r.Campaign__c, Lead__r.Consultation_Mode__c, 
                                       Lead__r.CreatedDate, Lead__r.Intended_Office__c,
                                       Fix_Phone_Linked_Key__c
                                FROM Lead_Item__c
                                WHERE Fix_Phone_Linked_Key__c IN :linkedKeys
                                AND Is_Converted__c = FALSE 
                                ORDER BY Lead__r.CreatedDate, Fix_Phone__c]) {

            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            leadIds.add(li.Lead__c);

            // Adds to duplicated lead item
            if (masterleadItems.size() > 0 && !mobileItemIds.contains(li.Id)) {
                li.Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN;
                dupleadItems.add(li);

            // Sets the first lead item
            } else if (masterleadItems.size() == 0) {
                li.Status__c = Constants.LEAD_ITEM_STATUS_WON_OPP_CN;
                masterleadItems.add(li);
            }
        }

        // Gets all follow ups from lead
        followups = [SELECT Id, Account__c FROM Appoitment__c WHERE Lead__c IN :leadIds];
        leads = [SELECT Converted_Account__c FROM Lead WHERE Id IN:leadIds];

        // Converts Lead
        Utils.runLeadTrigger = FALSE;
        List<Contact_EIC__c> contacts = new List<Contact_EIC__c> ();
        SavePoint sp = Database.setSavepoint();

        Opportunity opp = new Opportunity(
            Name = account.Name +
                   leadVar.Intended_City__c +
                   selectedItem.Business_Line__c +
                   leadItem.Intended_Country__c +
                   Constants.OPPORTUNITY_CN,
            AccountId = account.Id,
            RecordTypeId = oppRTId,
            CloseDate = System.Today() + 30,
            Intended_City__c = leadVar.Intended_City__c,
            Intended_Office__c = leadVar.Intended_Office__c,
            Project__c = leadItem.Project__c,
            Consultation_Mode__c = mode,
            StageName = Constants.OPPORTUNITY_STAGE_UNASSIGNED,
            Marketing_Channel_Lv3__c = masterleadItems[0].Marketing_Channel_Lv3__c,
            Level_4_Promotion_Channel__c = masterleadItems[0].Lead__r.Campaign__c,
            Department__c = Utils.countryMapDept.get(selectedItem.Intended_Country__c),
            AccountFirstCampaignName__c = leadVar.AccountFirstCampaignName__c,
            Recommend_User__c  = UserInfo.getUserId());

        if (selectedItem.Business_Line__c == Constants.COOPERATIVE_CN) {

            opp.Department__c = Constants.COOPERATIVE_CN;

        } else if (selectedItem.Business_Line__c == Constants.TESTPREP_CN) {

            opp.Department__c = Constants.DEPARTMENT_TESTPREP_CN;
        }

        if (selectedItem.Business_Line__c != Constants.COUNSELLING_CN) {
            opp.Name = account.Name + leadVar.Intended_City__c + selectedItem.Business_Line__c + Constants.OPPORTUNITY_CN;
            opp.OwnerId = Utils.getOfficeManager(leadVar.Intended_City__c,
                                                 leadVar.Intended_Office__c,
                                                 getENbusinessLine(selectedItem.Business_Line__c),
                                                 '');

        } else {
            opp.OwnerId = Utils.getOfficeManager(leadVar.Intended_City__c,
                                                 leadVar.Intended_Office__c,
                                                 getENbusinessLine(selectedItem.Business_Line__c),
                                                 selectedItem.Intended_Country__c);
        }

        if (opp.OwnerId == NULL) {

            throw new Utils.utilException(Constants.CONSULTANT_REFERRAL_SCHEDULING_TABLE_ERROR);
            return;
        }
        insert opp;

        Appoitment__c followup = new Appoitment__c (
            Name = Constants.CONSULTANT_REFERRAL_CREATE_APP_NAME_INFO,
            RecordTypeId = Utils.getRecordTypeId('Appoitment__c', 'Consultant Referral Follow Up'),
            Status__c = Constants.APP_COMPLETED,
            Opportunity__c = opp.Id,
            Consultant_Referral_Type__c = Constants.FIRST_REFERRAL_CN,
            Account__c = opp.AccountId,
            Description__c = leadVar.Text_Area__c,
            Assign_To__c = opp.OwnerId,
            Intended_City__c = leadVar.Intended_City__c,
            Intended_Office__c = leadVar.Intended_Office__c);

        insert followup;

        for (Lead lead:leads) {
            if (lead.Converted_Account__c == NULL) {
                lead.Converted_Account__c = opp.AccountId;
            }
        }
        Database.update(leads, FALSE);

        masterleadItems[0].Status__c = Constants.LEAD_ITEM_STATUS_WON_OPP_CN;
        masterleadItems[0].Opportunity__c = opp.Id;
        update masterleadItems[0];

        for (Lead_Item__c li :dupleadItems) {
            li.Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN;
            li.Opportunity__c = opp.Id;
        }

        update dupleadItems;
    }

    public void refresh () {
        leadVar.Counselling_Project__c = '';
        leadVar.TestPrep_Project__c = '';
        leadVar.Cooperative_Education_Project__c = '';
    }

    public void clearNonCounsellingProjects () {
        selected = 'Counselling';
        clearOtherProjects();
    }

    public void clearNonTestprepProjects () {
        selected = 'Testprep';
        clearOtherProjects();
    }

    public void clearNonCoopProjects () {
        selected = 'Coop';
        clearOtherProjects();
    }

    public void clearAllProjects () {
        selected = '';
        clearOtherProjects();
    }

    public void clearOtherProjects () {

        if (selected != 'Testprep') {
            leadVar.TestPrep_Project__c = '';
        }
        if (selected != 'Counselling') {
            leadVar.Counselling_Project__c = '';
        }
        if (selected != 'Coop') {
            leadVar.Cooperative_Education_Project__c = '';
        }
    }

    public void clearCounsellingProjects () {
        leadVar.Counselling_Project__c = '';
    }

    public void clearTestPrepProjects () {
        leadVar.TestPrep_Project__c = '';
    }

    public void clearCoopProjects () {
        leadVar.Cooperative_Education_Project__c = '';
    }

    public void resetIsTestprep () {

        if (currentUser.ChineseNameofCity__c == leadVar.Intended_City__c &&
            currentUser.Business_Line_Formula__c == Constants.TESTPREP_CN) {
            isTestPrep = TRUE;

        } else {
            isTestPrep = FALSE;
        }
    }

    public pagereference cancel() {
        return new PageReference('/' + account.Id);
    }

    static String getENbusinessLine(String businessLine) {

        if (businessLine == Constants.COUNSELLING_CN) {
            return 'Counselling';

        } else if (businessLine == Constants.TESTPREP_CN) {
            return 'TestPrep';

        } else if (businessLine == Constants.SCHOLAR_TREE_CN) {
            return 'Scholar Tree';

        } else if (businessLine == Constants.COOPERATIVE_CN) {
            return 'Cooperative';

        } else {
            return 'Other';
        }
    }
}