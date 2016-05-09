/**************************************************************************************************
 * Name: SplitLeadUtils
 * Object: Lead, Lead_Item__c
 * Purpose: It is used to split lead item, and check duplication, and notify opportunity owner
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-24
 * Modified History:
 * 2015-10-24   vicia.wang Writes comments in this format
***************************************************************************************************/
public without sharing class SplitLeadUtils {
    static List<Lead_Item__c> deletedLeadItems = new List<Lead_Item__c>();

    // Processes the lead deduplication 
    public static void processLead(List<Lead> leads,  List<Lead> oldLeads, String triggerType) {
        Savepoint sp = Database.setSavepoint();
        List<Lead_Item__c> items = new List<Lead_Item__c>();
        List<Lead_Item__c> oldItems = new List<Lead_Item__c>();
        Set<String> deletedKeySet = new Set<String>();
        Set<String> newLeadUniqueKey = new Set<String>();

        try {
            // Checks the phone duplication with account and lead
            leads = checkPhoneStatus(leads);
            // Splits the lead to lead items
            items = splitLead(leads);
            // Updates some lead items statuses "LEAD_ITEM_STATUS_DUP_IN_CAMPAIGN_CN","LEAD_ITEM_STATUS_OPEN_OPP_CN", "LEAD_ITEM_STATUS_WON_OPP_CN"; Notify the opportunity owner
            items = checkAccOppNotifyOwner(items, leads);
            // Update some rest lead items statues "LEAD_ITEM_STATUS_HAS_LEAD_CN", "LEAD_ITEM_STATUS_NEW_CN"
            items = checkLead(items);
            for (Lead_Item__c li :items) {
                if (String.isNotBlank(li.Mobile_Unique_Key__c)) {
                    newLeadUniqueKey.add(li.Mobile_Unique_Key__c);
                } else if (String.isNotBlank(li.Fix_Phone_Unique_Key__c)) {
                    newLeadUniqueKey.add(li.Fix_Phone_Unique_Key__c);
                }
            }

            oldItems = splitLead(oldLeads);
            oldItems = checkAccOppNotifyOwner(oldItems, new List<Lead>());
            oldItems = checkLead(oldItems);

            if (triggerType == 'isBefore') {
                for (Lead_Item__c li :items) {
                    String phone = '';
                    String uniqueKey = '';
                    if (String.isNotBlank(li.Mobile__c)) {
                        phone = li.Mobile__c;
                        uniqueKey = li.Mobile_Unique_Key__c;
                    } else if (String.isNotBlank(li.Fix_Phone__c)) {
                        phone = li.Fix_Phone__c;
                        uniqueKey = li.Fix_Phone_Unique_Key__c;
                    }

                    if (li.Status__c == Constants.LEAD_ITEM_STATUS_OPEN_OPP_CN || 
                        li.Status__c == Constants.LEAD_ITEM_STATUS_WON_OPP_CN) {
                        String error = '';
                        if (String.isNotBlank(li.Project__c)) {
                            error = System.Label.Error_Duplicate_Lead + li.Business_Line__c + 
                                    '[' + li.Project__c + ']' + 
                                    Constants.OPPORTUNITY_CN + '.<a href=\'/apex/Deduplicate?phone=' + phone + '\'>' + 
                                    Constants.VIEW_DETAILS_CN + '</a>';
                        
                        } else {
                            error = System.Label.Error_Duplicate_Lead + li.Business_Line__c + 
                                    Constants.OPPORTUNITY_CN + '.<a href=\'/apex/Deduplicate?phone=' + phone + '\'>' +
                                    Constants.VIEW_DETAILS_CN + '</a>';
                        }
                        leads[0].addError(error, FALSE);

                    } else if (li.Status__c == Constants.LEAD_ITEM_STATUS_HAS_LEAD_CN) {
                        String error = System.Label.Error_Duplicate_Contact_For_Lead + uniqueKey + 
                                       ').<a href=\'/apex/Deduplicate?phone=' + phone + '\'>' +
                                       Constants.VIEW_DETAILS_CN + '</a>';
                        leads[0].addError(error, FALSE);
                    }
                }

                if (oldItems != NULL && oldItems.size() > 0) {
                    for (Lead_Item__c oldli :oldItems) {
                        if (!newLeadUniqueKey.contains(oldli.Mobile_Unique_Key__c) && 
                            !newLeadUniqueKey.contains(oldli.Fix_Phone_Unique_Key__c) ) {

                            if (String.isNotBlank(oldli.Mobile_Unique_Key__c)) {
                                deletedKeySet.add(oldli.Mobile_Unique_Key__c);
                            
                            } else if (String.isNotBlank(oldli.Fix_Phone_Unique_Key__c)) {
                                deletedKeySet.add(oldli.Fix_Phone_Unique_Key__c);
                            }
                        }
                    }

                    // Prevents deleting the converted lead items.
                    for (Lead_Item__c dli :[SELECT Mobile_Unique_Key__c, Is_Converted__c, Mobile__c 
                                            FROM Lead_Item__c 
                                            WHERE Mobile_Unique_Key__c IN :deletedKeySet]) {
                        if (dli.Is_Converted__c) {
                            String error = Constants.LEAD_SPLIT_ERROR + dli.Mobile_Unique_Key__c + 
                                           ').<a href=\'/apex/Deduplicate?phone=' + dli.Mobile__c + '\'>' +
                                           Constants.VIEW_DETAILS_CN + '</a>';
                            leads[0].addError(error, FALSE);
                        } else {
                            deletedLeadItems.add(dli);
                        }
                    }

                    // Prevents deleting the converted lead items.
                    for (Lead_Item__c dli :[SELECT Fix_Phone_Unique_Key__c, Is_Converted__c, Fix_Phone__c 
                                            FROM Lead_Item__c 
                                            WHERE Fix_Phone_Unique_Key__c IN :deletedKeySet]) {
                        if (dli.Is_Converted__c) {
                            String error = Constants.LEAD_SPLIT_ERROR + dli.Fix_Phone_Unique_Key__c + 
                                          ').<a href=\'/apex/Deduplicate?phone=' + dli.Fix_Phone__c + '\'>' + 
                                          Constants.VIEW_DETAILS_CN + '</a>';
                            leads[0].addError(error, FALSE);
                        
                        } else {
                            deletedLeadItems.add(dli);
                        }
                    }
                }
            }

            if (triggerType == 'isAfter') {
                // Gets the qualified lead items
                items = createLeadItem(items);
                List<Lead_Item__c> mobileItems = new List<Lead_Item__c>();
                List<Lead_Item__c> fixPhoneItems = new List<Lead_Item__c>();
                for (Lead_Item__c item :items) {
                    if (String.isNotBlank(item.Mobile_Unique_Key__c)) {
                        mobileItems.add(item);

                    } else if (String.isNotBlank(item.Fix_Phone_Unique_Key__c)) {
                        fixPhoneItems.add(item);
                    }
                }
                upsert mobileItems Mobile_Unique_Key__c;
                upsert fixPhoneItems Fix_Phone_Unique_Key__c;
                delete deletedLeadItems;
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** : e.getMessage()' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            Database.rollback(sp);
        }
    }

    // Checks the phone/mobile is same with lead/account
    public static List<Lead> checkPhoneStatus(List<Lead> leads) {
        if (Utils.isExcelUploader || (Trigger.isBefore && Trigger.isInsert)) {
            Set<String> phoneSet = new Set<String>();
            Set<String> fixPhoneSet = new Set<String>();
            Map<String, Lead> mobileMapLead = new Map<String, Lead>();
            Map<String, Lead> fixPhoneMapLead = new Map<String, Lead>();
            Map<String, String> idMapCity = new Map<String, String>();
            Map<String, String> idMapBusinessLine = new Map<String, String>();

            Set<Id> campaignIds = new Set<Id>();
            for (Lead lead :leads) {
                // Phone is key, and lead is the value
                if (String.isNotBlank(lead.MobilePhone)) {
                    mobileMapLead.put(lead.MobilePhone, lead);
                    phoneSet.add(lead.MobilePhone);
                }

                if (String.isNotBlank(lead.Phone)) {
                    String fixPhone = lead.Area_Code__c == NULL ? '' : lead.Area_Code__c + lead.Phone;
                    fixPhoneMapLead.put(fixPhone, lead);
                    phoneSet.add(fixPhone);
                    fixPhoneSet.add(lead.Phone);
                }

                if (String.isNotBlank(lead.Campaign__c)) {
                    campaignIds.add(lead.Campaign__c);
                }
            }

            // Sets 'Campaign Business Line, Campaign City' default value from Campaign
            for (Campaign camp:[SELECT City__c, Business_line__c
                                FROM Campaign
                                WHERE Id IN: campaignIds]) {
                idMapCity.put(camp.Id, camp.City__c);
                idMapBusinessLine.put(camp.Id, camp.Business_line__c);
            }

            for (Lead lead :leads) {
                if (idMapCity.get(lead.Campaign__c) != NULL) {
                    lead.Campaign_City__c = idMapCity.get(lead.Campaign__c);
                    lead.Campaign_Business_line__c = idMapBusinessLine.get(lead.Campaign__c);
                }
            }

            // Updates lead statuses with LEAD_PHONE_STATUS_HASLEAD_CN
            for (Lead_Item__c li :[SELECT Mobile__c, Fix_Phone__c
                                   FROM Lead_Item__c
                                   WHERE Mobile__c IN :mobileMapLead.keySet()
                                   OR Fix_Phone__c IN :fixPhoneSet]) {
                String fixPhone = lead.Area_Code__c == NULL ? '' : lead.Area_Code__c + String.valueOf(lead.Phone);

                if (mobileMapLead.get(li.Mobile__c) != NULL) {
                    mobileMapLead.get(li.Mobile__c).Phone_Status__c = Constants.LEAD_PHONE_STATUS_HASLEAD_CN;
                }

                if (fixPhoneMapLead.get(fixPhone) != NULL) {
                    fixPhoneMapLead.get(fixPhone).Phone_Status__c = Constants.LEAD_PHONE_STATUS_HASLEAD_CN;
                }
            }

            // Sets the map from accountId to prelead item
            for (Contact_EIC__c con :[SELECT Account__c, Unique_Contact__c
                                      FROM Contact_EIC__c
                                      WHERE Unique_Contact__c IN :phoneSet
                                      AND isInvalid__c = FALSE
                                      AND isEmergency__c = FALSE]) {
                if (mobileMapLead.get(con.Unique_Contact__c) != NULL) {
                    mobileMapLead.get(con.Unique_Contact__c).Phone_Status__c = Constants.LEAD_PHONE_STATUS_HASACCOUNT_CN;

                } else if (fixPhoneMapLead.get(con.Unique_Contact__c) != NULL) {
                    fixPhoneMapLead.get(con.Unique_Contact__c).Phone_Status__c = Constants.LEAD_PHONE_STATUS_HASACCOUNT_CN;
                }
            }
            return leads;

        } else {
            return leads;
        }
    }

    // Creates Lead items depends on the Lead's business line/project
    public static List<Lead_Item__c> splitLead(List<Lead> leads) {
        if (leads == NULL) return NULL;
        Project__c testprepProjs = Project__c.getValues(Constants.TESTPREP_CN);
        Project__c counsellingProjs = Project__c.getValues(Constants.COUNSELLING_CN);
        Project__c xueshutangProjs = Project__c.getValues(Constants.SCHOLAR_TREE_CN);
        Project__c shanghaiNPProjs = Project__c.getValues('NP');
        Project__c cooperativeEducationProjs = Project__c.getValues(Constants.COOPERATIVE_CN);
        List<Lead_Item__c> leadItems = new List<Lead_Item__c>();
        String campaignId;

        for (Lead lead :leads) {
            //  It is used for Exceluploader
            if (lead.Campaign__c != NULL) {
                campaignId = lead.Campaign__c;

            } else {
                campaignId = 'No Campaign';
            }

            if (Utils.isExcelUploader) {
                // Gets all business line values from Prelead
                List<String> intendedBL = new List<String>();
                if (String.isNotBlank(lead.Business_Line__c)) {
                    intendedBL = lead.Business_Line__c.split(';');
                }

                // Gets all intended project values from Prelead
                List<String> intendedProjs = new List<String>();
                if (String.isNotBlank(lead.Project__c)) {
                    intendedProjs = lead.Project__c.split(';');
                }

                // In order to skip the no intention validation rule
                lead.Is_Counselling__c = FALSE;
                // Splits the business line and project to prelead items
                for (String bl :intendedBL) {
                    // These business line does not care about their projects.
                    if (bl == Constants.TESTPREP_CN || bl == 'NP' || bl == Constants.SCHOLAR_TREE_CN || bl == Constants.COOPERATIVE_CN) {
                        // Get the projects only for prepsmith
                        String leadProjs = '';
                        for (String intproj :intendedProjs) {
                            if (testprepProjs.Project__c.contains(intproj) && 
                                bl == Constants.TESTPREP_CN) {
                                leadProjs += intproj + ';';

                            } else if (shanghaiNPProjs.Project__c.contains(intproj) && 
                                bl == 'NP') {
                                leadProjs += intproj + ';';

                            } else if (xueshutangProjs.Project__c.contains(intproj) && 
                                bl == Constants.SCHOLAR_TREE_CN) {
                                leadProjs += intproj + ';';

                            } else if (cooperativeEducationProjs.Project__c.contains(intproj) && 
                                bl == Constants.COOPERATIVE_CN) {
                                leadProjs += intproj + ';';
                            }
                        }

                        // Sets the intended projects
                        if (bl == Constants.TESTPREP_CN) {
                            lead.Is_TestPrep__c = TRUE;
                            lead.TestPrep_Project__c = leadProjs;

                        } else if (bl == Constants.SCHOLAR_TREE_CN) {
                            lead.Is_Scholar_Tree__c = TRUE;

                        } else if (bl == 'NP') {
                            lead.Is_NP__c = TRUE;
                            lead.TestPrep_Project__c = leadProjs;

                        } else if (bl == Constants.COOPERATIVE_CN) {
                            lead.Is_Cooperative_Education__c = TRUE;
                            lead.Cooperative_Education_Project__c = leadProjs;
                        }

                        leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, bl, campaignId, leadProjs, ''));

                    // If it contains counselling business line intention
                    } else if (bl == Constants.COUNSELLING_CN) {
                        Boolean hasCounsellingProj = FALSE;
                        String leadProjs = '';
                        lead.Is_Counselling__c = TRUE;
                        // If it has counselling projects
                        for (String country :intendedProjs) {
                            if (counsellingProjs.Project__c.contains(country)) {
                                leadProjs += country + ';';
                                leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, bl, campaignId, country, country));
                                hasCounsellingProj = TRUE;
                            }
                        }

                        // If it does not have counselling projects
                        if (!hasCounsellingProj) {
                            leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, bl, campaignId, NULL, ''));

                        }  else {
                            leadProjs = leadProjs.substring(0, leadProjs.length() - 1);
                            lead.Counselling_Project__c = leadProjs;
                        }
                    }
                }

            } else {
                if (lead.Is_Counselling__c) {
                    List<String> cProjects = new List<String>();
                    if (String.isNotBlank(lead.Counselling_Project__c)) {
                        cProjects = lead.Counselling_Project__c.split(';');
                    }

                    if (cProjects.size() == 0) {
                        leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COUNSELLING_CN, campaignId, NULL, ''));

                    // If it does not have counselling projects
                    } else {
                        // If it has counselling projects
                        for (String country :cProjects) {
                            Lead_Item__c li = createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COUNSELLING_CN, campaignId, country, country);
                            if(Live800Flag.isTestPrepToCounselling){
                                li.isRecommend__c = true;
                            }
                            leadItems.add(li);
                        }
                    }
                }

                if (lead.Is_TestPrep__c) {
                    Lead_Item__c li = createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.TESTPREP_CN, campaignId, lead.TestPrep_Project__c, '');
                    if(Live800Flag.isCounsellingToTestPrep){
                        li.isRecommend__c = true;
                    }

                    if (constants.TESTPREP_CITIES.contains(lead.Intended_City__c)){
                        leadItems.add(li);

                    } else {
                        lead.Intended_City__c.addError(System.Label.Error_Not_Testprep_City);
                    }
                }

                if (lead.Is_NP__c) {
                    if (constants.NP_CITIES.contains(lead.Intended_City__c)){
                        leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, 'NP', campaignId, lead.TestPrep_Project__c, ''));
                    
                    } else {
                        lead.Intended_City__c.addError(System.Label.Error_Not_Np_City);
                    }
                }

                if (lead.Is_Scholar_Tree__c) {
                    leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.SCHOLAR_TREE_CN, campaignId, Constants.SCHOLAR_TREE_PROJECT_CN, ''));
                }

                if (lead.Is_Cooperative_Education__c) {
                    if (constants.COOPERATIVE_EDUCATION_CITIES.contains(lead.Intended_City__c)){
                        leadItems.add(createOneLeadItem (lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COOPERATIVE_CN, campaignId, lead.Cooperative_Education_Project__c, ''));
                    
                    } else {
                        lead.Intended_City__c.addError(System.Label.Error_Not_Coop_City);
                    }
                }
            }
        }

        if (Utils.isExcelUploader) {
            update leads;
        }

        return leadItems;
    }

    // Creates a task for opportunity owner and update some "LEAD_ITEM_STATUS_DUP_IN_CAMPAIGN_CN","LEAD_ITEM_STATUS_OPEN_OPP_CN"  items.
    public static List<Lead_Item__c> checkAccOppNotifyOwner(List<Lead_Item__c> leadItems, List<Lead> leads) {
        if (leadItems == NULL) return NULL;

        Set<String> phoneSet = new Set<String>();
        Set<Id> leadIds = new Set<Id>();
        Map<String, Lead_Item__c> keyMapItem = new Map<String, Lead_Item__c>();
        Map<String, String> keyMapPhone = new Map<String, String>();
        Map<String, Set<Id>> phoneMapAccIds = new Map<String, Set<Id>>();
        Set<Id> cooperationCampaignIds = new Set<Id>();
        Set<Id> referralCampaignIds = new Set<Id>();
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        Label__c cooperation = Label__c.getValues('Cooperation');
        Label__c referral = Label__c.getValues('Referral');
        List<Lead_Item__c> dupItems = new List<Lead_Item__c>();
        Set<String> keySet = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        List<Task> reminders = new List<Task>();
        Map<String, Lead> keyMapLead = new Map<String, Lead>();
        Set<String> channelSet = new Set<String> {Constants.COOPERATIVE_ADMISSIONS_CN, Constants.REFERRAL_CN};

        for (Campaign camp :[SELECT Name, Marketing_Channel_Lv1__c
                             FROM Campaign
                             WHERE Marketing_Channel_Lv1__c IN: channelSet]) {
            if (camp.Marketing_Channel_Lv1__c == Constants.COOPERATIVE_ADMISSIONS_CN) {
                cooperationCampaignIds.add(camp.Id);

            } else {
                referralCampaignIds.add(camp.Id);
            }
            campaignMap.put(camp.Id, camp);
        }

        for (Lead lead :leads) {
            if (lead.Is_Counselling__c) {
                keyMapLead = populateKeyMapLead(keyMapLead, lead, ';' + Constants.COUNSELLING_CN);
            }

            if (lead.Is_TestPrep__c || lead.Is_NP__c) {
                keyMapLead = populateKeyMapLead(keyMapLead, lead, ';' + Constants.TESTPREP_CN);
            }

            if (lead.Is_Cooperative_Education__c) {
                keyMapLead = populateKeyMapLead(keyMapLead, lead, ';' + Constants.COOPERATIVE_CN);
            }

            if (lead.Is_Scholar_Tree__c) {
                keyMapLead = populateKeyMapLead(keyMapLead, lead, ';' + Constants.SCHOLAR_TREE_CN);
            }
        }


        for (Lead_Item__c li :leadItems) {
            if (keySet.contains(li.Mobile_Unique_Key__c) || 
                keySet.contains(li.Fix_Phone_Unique_Key__c)) {
                li.Status__c = Constants.LEAD_ITEM_STATUS_DUP_IN_CAMPAIGN_CN;
                dupItems.add(li);
                continue;
            }

            if (String.isNotBlank(li.Mobile_Unique_Key__c)) {
                keySet.add(li.Mobile_Unique_Key__c);
                keyMapItem.put(li.Mobile_Unique_Key__c, li);
                keyMapPhone.put(li.Mobile_Unique_Key__c, li.Mobile__c);
                phoneSet.add(li.Mobile__c);
            }

            if (String.isNotBlank(li.Fix_Phone_Unique_Key__c)) {
                keySet.add(li.Fix_Phone_Unique_Key__c);
                keyMapItem.put(li.Fix_Phone_Unique_Key__c, li);
                keyMapPhone.put(li.Fix_Phone_Linked_Key__c, li.Fix_Phone__c);
                phoneSet.add(li.Fix_Phone__c);
            }

            if (String.isNotBlank(li.Lead__c)) {
                leadIds.add(li.Lead__c);
            }
        }

        // Gets the account ids
        for (Contact_EIC__c con :[SELECT Account__c, Unique_Contact__c
                                  FROM Contact_EIC__c
                                  WHERE Unique_Contact__c IN :phoneSet
                                  AND isInvalid__c = FALSE
                                  AND isEmergency__c = FALSE]) {
            accIds.add(con.Account__c);
            if (!phoneMapAccIds.containsKey(con.Unique_Contact__c)) {
                phoneMapAccIds.put(con.Unique_Contact__c, new Set<Id>());
            }
            phoneMapAccIds.get(con.Unique_Contact__c).add(con.Account__c);
        }

        for (Opportunity opp :[SELECT Account.Name, RecordType.Name, 
                                      Name, StageName, Project__c, 
                                      OwnerId , Intended_City__c, 
                                      IsClosed, IsWon,
                                      (SELECT Id FROM Lead_Items__r
                               WHERE (Mobile_Unique_Key__c IN :keyMapItem.keySet() OR 
                                      Fix_Phone_Unique_Key__c IN :keyMapItem.keySet())
                               AND Lead__c IN :leadIds)
                               FROM Opportunity
                               WHERE AccountId IN :accIds]) {
            if (!opp.IsClosed) {
                Set<Id> oppOwners = new Set<Id>();
                if (!oppOwners.contains(opp.OwnerId)) {
                    Task task = new Task(
                        Subject = String.valueOf(System.today().format()) + '-' + Constants.ACCOUNT_CN + opp.Account.Name + '-' + Constants.LEAD_CREATION_PROMPT_INFO,
                        OwnerId = opp.OwnerId,
                        WhatId = opp.Id,
                        ActivityDate = System.today(),
                        ReminderDateTime = System.now(),
                        IsReminderSet = TRUE);
                    reminders.add(task);
                }
                oppOwners.add(opp.OwnerId);

                if (opp.Lead_Items__r.size() > 0) continue;

                // There is a same TestPrep opportunity
                if (opp.RecordType.Name == 'TestPrep') {
                    String oppKey = opp.Intended_City__c + ';' + Constants.TESTPREP_CN;
                    String oppKey2 = opp.Intended_City__c + ';NP';
                    for (String itemKey :keyMapItem.keySet()) {
                        if (itemKey.contains(oppKey)
                            && phoneMapAccIds != NULL
                            && keyMapPhone.get(itemKey) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId)) {
                            keyMapItem.get(itemKey).Status__c = Constants.LEAD_ITEM_STATUS_OPEN_OPP_CN;

                        } else if (itemKey.contains(oppKey2)
                            && phoneMapAccIds != NULL
                            && keyMapPhone.get(itemKey) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId)) {
                            keyMapItem.get(itemKey).Status__c = Constants.LEAD_ITEM_STATUS_OPEN_OPP_CN;
                        }
                    }

                // There is a duplicated project for counselling
                } else if (opp.RecordType.Name == 'Counselling') {
                    String oppKey = opp.Intended_City__c + ';' + Constants.COUNSELLING_CN + ';' + opp.Project__c;

                    for (String itemKey :keyMapItem.keySet()) {
                        if (itemKey.contains(oppKey)
                            && phoneMapAccIds != NULL
                            && keyMapPhone.get(itemKey) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId)) {
                            keyMapItem.get(itemKey).Status__c = Constants.LEAD_ITEM_STATUS_OPEN_OPP_CN;
                        }
                    }

                // There is a duplicated project for scholar tree
                } else if (opp.RecordType.Name == 'Scholar Tree' && !opp.IsClosed) {
                    String oppKey = opp.Intended_City__c + ';' + Constants.SCHOLAR_TREE_CN;
                    for (String itemKey :keyMapItem.keySet()) {
                        if (itemKey.contains(oppKey)
                            && phoneMapAccIds != NULL
                            && keyMapPhone.get(itemKey) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId)) {
                            keyMapItem.get(itemKey).Status__c = Constants.LEAD_ITEM_STATUS_OPEN_OPP_CN;
                        }
                    }

                // There is a duplicated project for cooperative education
                } else if (opp.RecordType.Name == 'Cooperative' && !opp.IsClosed) {
                    String oppKey = opp.Intended_City__c + ';' + Constants.COOPERATIVE_CN;
                    for (String itemKey :keyMapItem.keySet()) {
                        if (itemKey.contains(oppKey)
                            && phoneMapAccIds != NULL
                            && keyMapPhone.get(itemKey) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL
                            && phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId)) {
                            keyMapItem.get(itemKey).Status__c = Constants.LEAD_ITEM_STATUS_OPEN_OPP_CN;
                        }
                    }
                }

            // Gets the won opportunities
            } else if (opp.IsWon && opp.RecordType.Name == 'Counselling') {
                String oppKey = opp.Intended_City__c + ';' + Constants.COUNSELLING_CN + ';' + opp.Project__c;
                for (String itemKey :keyMapItem.keySet()) {
                    if (itemKey.contains(oppKey)
                        && phoneMapAccIds != NULL
                        && keyMapPhone.get(itemKey) != NULL
                        && phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL
                        && phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId)) {
                        keyMapItem.get(itemKey).Status__c = Constants.LEAD_ITEM_STATUS_WON_OPP_CN;
                    }
                }


            // Gets the lost opportunties
            } else if (opp.IsClosed && !opp.IsWon && (Trigger.isBefore == TRUE || Utils.isExcelUploader)) {
                if (opp.Lead_Items__r.size() > 0) continue;

                String oppKey = '';
                // There is a same TestPrep opportunity
                if (opp.RecordType.Name == 'Testprep') {
                    oppKey = opp.Intended_City__c + ';' + Constants.TESTPREP_CN;

                // There is a duplicated project for counselling
                } else if (opp.RecordType.Name == 'Counselling') {
                    oppKey = opp.Intended_City__c + ';' + Constants.COUNSELLING_CN;

                // There is a duplicated project for scholar tree
                } else if (opp.RecordType.Name == 'Scholar Tree') {
                    oppKey = opp.Intended_City__c + ';' + Constants.SCHOLAR_TREE_CN;

                // There is a duplicated project for counselling
                } else if (opp.RecordType.Name == 'Cooperative') {
                    oppKey = opp.Intended_City__c + ';' + Constants.COOPERATIVE_CN;
                }

                for (String itemKey :keyMapItem.keySet()) {
                    String leadKey = '';
                    if (itemKey.contains(Constants.COUNSELLING_CN)) {
                        leadKey = itemKey.replace(';' + keyMapItem.get(itemKey).Intended_Country__c, '');

                    } else {
                        leadKey = itemKey;
                    }

                    // Populates the cooperation campaign
                    if (keyMapLead.get(leadKey) != NULL && 
                        phoneMapAccIds != NULL && 
                        keyMapPhone.get(itemKey) != NULL && 
                        phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL && 
                        phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId) && 
                        cooperationCampaignIds.contains(keyMapLead.get(leadKey).Campaign__c) && 
                        itemKey.contains(oppKey)) {

                        if (keyMapItem.get(itemKey).Mobile_Unique_Key__c != NULL) {
                            // Populates the extension agent
                            if (Utils.isExcelUploader || (Trigger.isBefore == TRUE && trigger.isBefore && trigger.isInsert )) {
                                keyMapLead.get(leadKey).OriginCampaign__c = campaignMap.get(keyMapLead.get(leadKey).Campaign__c).Name;
                            }
                            keyMapItem.get(itemKey).Mobile_Unique_Key__c = keyMapItem.get(itemKey).Mobile_Unique_Key__c.replace(keyMapLead.get(leadKey).Campaign__c, cooperation.Value__c);
                            keyMapLead.get(leadKey).Campaign__c = cooperation.Value__c;
                        }

                        if (keyMapItem.get(itemKey).Fix_Phone_Unique_Key__c != NULL) {
                            // Populates the extension agent
                            if (Utils.isExcelUploader || (Trigger.isBefore == TRUE && trigger.isBefore && trigger.isInsert )) {
                                keyMapLead.get(leadKey).OriginCampaign__c = campaignMap.get(keyMapLead.get(leadKey).Campaign__c).Name;
                            }
                            keyMapItem.get(itemKey).Fix_Phone_Unique_Key__c = keyMapItem.get(itemKey).Fix_Phone_Unique_Key__c.replace(keyMapLead.get(leadKey).Campaign__c, cooperation.Value__c);
                            keyMapLead.get(leadKey).Campaign__c = cooperation.Value__c;
                        }

                    // Populates the referral campaign
                    } else if (keyMapLead.get(leadKey) != NULL && 
                               phoneMapAccIds != NULL && 
                               keyMapPhone.get(itemKey) != NULL && 
                               phoneMapAccIds.get(keyMapPhone.get(itemKey)) != NULL && 
                               phoneMapAccIds.get(keyMapPhone.get(itemKey)).contains(opp.AccountId) && 
                               referralCampaignIds.contains(keyMapLead.get(leadKey).Campaign__c) && 
                               itemKey.contains(oppKey)) {
                        if (keyMapItem.get(itemKey).Mobile_Unique_Key__c != NULL) {
                            // Populates the extension agent
                            if (Utils.isExcelUploader || (Trigger.isBefore == TRUE && trigger.isBefore && trigger.isInsert )) {
                                keyMapLead.get(leadKey).OriginCampaign__c = campaignMap.get(keyMapLead.get(leadKey).Campaign__c).Name;
                            }
                            keyMapItem.get(itemKey).Mobile_Unique_Key__c = keyMapItem.get(itemKey).Mobile_Unique_Key__c.replace(keyMapLead.get(leadKey).Campaign__c, referral.Value__c);
                            keyMapLead.get(leadKey).Campaign__c = referral.Value__c;
                        }

                        if (keyMapItem.get(itemKey).Fix_Phone_Unique_Key__c != NULL) {
                            // Populate the extension agent
                            if (Utils.isExcelUploader || (Trigger.isBefore == TRUE && trigger.isBefore && trigger.isInsert )) {
                                keyMapLead.get(leadKey).OriginCampaign__c = campaignMap.get(keyMapLead.get(leadKey).Campaign__c).Name;
                            }
                            keyMapItem.get(itemKey).Mobile_Unique_Key__c = keyMapItem.get(itemKey).Fix_Phone_Unique_Key__c.replace(keyMapLead.get(leadKey).Campaign__c, referral.Value__c);
                            keyMapLead.get(leadKey).Campaign__c = referral.Value__c;
                        }
                    }
                }
            }
        }

        if (Utils.isExcelUploader) {
            insert reminders;
            update leads;
        }

        return leadItems;
    }

    // Updates lead items with the status "LEAD_ITEM_STATUS_HAS_LEAD_CN", "LEAD_ITEM_STATUS_NEW_CN"
    public static List<Lead_Item__c> checkLead(List<Lead_Item__c> leadItems) {
        if (leadItems == NULL) return NULL;
        Map<String, Lead_Item__c> mobileMapItem = new Map<String, Lead_Item__c>();
        Map<String, Lead_Item__c> fixPhoneMapItem = new Map<String, Lead_Item__c>();

        // Gets the unqualified prelead items
        for (Lead_Item__c li :leadItems) {
            if (li.Status__c == Constants.LEAD_ITEM_STATUS_NEW_CN) {
                if (String.isNotBlank(li.Mobile_Unique_Key__c)) {
                    mobileMapItem.put(li.Mobile_Unique_Key__c, li);
                }
                if (String.isNotBlank(li.Fix_Phone_Unique_Key__c)) {
                    fixPhoneMapItem.put(li.Fix_Phone_Unique_Key__c, li);
                }
            }
        }

        // Updates lead items with the status "LEAD_ITEM_STATUS_HAS_LEAD_CN"
        for (Lead_Item__c li :[SELECT Is_Converted__c, Status__c, 
                                      Mobile_Unique_Key__c, Lead__c
                               FROM Lead_Item__c
                               WHERE Mobile_Unique_Key__c IN :mobileMapItem.keySet()]) {
            // We find itself.
            if (mobileMapItem.get(li.Mobile_Unique_Key__c).Lead__c == li.Lead__c) {
                mobileMapItem.get(li.Mobile_Unique_Key__c).Status__c = li.Status__c;

            } else if (li.Is_Converted__c == FALSE) {
                mobileMapItem.get(li.Mobile_Unique_Key__c).Status__c = Constants.LEAD_ITEM_STATUS_HAS_LEAD_CN;
            }
        }

        // Update the some "LEAD_ITEM_STATUS_HAS_LEAD_CN"
        for (Lead_Item__c li :[SELECT Is_Converted__c, Status__c, 
                                      Fix_Phone_Unique_Key__c, Lead__c
                               FROM Lead_Item__c
                               WHERE Fix_Phone_Unique_Key__c IN :fixPhoneMapItem.keySet()]) {
            // We find itself.
            if (fixPhoneMapItem.get(li.Fix_Phone_Unique_Key__c).Lead__c == li.Lead__c) {
                fixPhoneMapItem.get(li.Fix_Phone_Unique_Key__c).Status__c = li.Status__c;

            } else if (li.Is_Converted__c == FALSE) {
                fixPhoneMapItem.get(li.Fix_Phone_Unique_Key__c).Status__c = Constants.LEAD_ITEM_STATUS_HAS_LEAD_CN;
            }
        }

        return leadItems;
    }

    // Creates Lead, Lead Item according to Prelead, Prelead Item
    public static List<Lead_Item__c> createLeadItem(List<Lead_Item__c> leadItems) {
        List<Lead_Item__c> successfulleadItems = new List<Lead_Item__c>();
        for (Lead_Item__c li :leadItems) {
            if (li.Status__c == Constants.LEAD_ITEM_STATUS_NEW_CN || 
                li.Status__c == Constants.LEAD_ITEM_STATUS_FOLLOWUP_CN || 
                li.Status__c == Constants.LEAD_ITEM_STATUS_SLEEP_AUTO_CN || 
                li.Status__c == Constants.LEAD_ITEM_STATUS_SLEEP_MANUALLY_CN || 
                li.Status__c == Constants.LEAD_ITEM_STATUS_LOST_SLEEP_MANUALLY_CN) {
                successfulleadItems.add(li);
            }
        }

        return successfulleadItems;
    }

    // Creates a lead map which the key is mobile/fixphone unique key and the value is lead
    private static Map<String, Lead> populateKeyMapLead (Map<String, Lead> keyMapLead, Lead lead, String project) {
        if (String.isNotBlank(lead.MobilePhone)) {
            keyMapLead.put(lead.MobilePhone + ';' + lead.Campaign__c + ';' + lead.Intended_City__c + project, lead);
        }

        if (String.isNotBlank(lead.Phone)) {
            keyMapLead.put(lead.Phone + ';' + lead.Campaign__c + ';' + lead.Intended_City__c + project, lead);
        }

        return keyMapLead;
    }

    // Creates a lead item
    private static Lead_Item__c createOneLeadItem (Lead lead, String status, String businessLine, String campaignId, String project, String country) {
        Lead_Item__c li = new Lead_Item__c(
            Lead__c = lead.Id,
            Status__c = status,
            Business_Line__c = businessLine,
            Project__c = project);
        if (country != '') {
            li.Intended_Country__c = country;
            businessLine += ';' + country;
        }
        if (String.isNotBlank(lead.MobilePhone)) {
            li.Mobile__c = lead.MobilePhone;
            li.Mobile_Unique_Key__c = lead.MobilePhone + ';' + campaignId + ';' + lead.Intended_City__c + ';' + businessLine;
        }
        if (String.isNotBlank(lead.Phone)) {
            li.Fix_Phone__c = lead.Phone;
            li.Fix_Phone_Unique_Key__c = lead.Area_Code__c == NULL ? '' : lead.Area_Code__c +  lead.Phone + ';';
            li.Fix_Phone_Unique_Key__c += campaignId + ';' + lead.Intended_City__c + ';' + businessLine;
        }
        return li;
    }

}