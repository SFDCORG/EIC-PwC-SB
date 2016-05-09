/**************************************************************************************************
 * Name: Utils
 * Object:
 * Purpose: Common methods to use
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-15
 * Modified History:
 * 2015-10-15   vicia.wang Writes comments in this format
***************************************************************************************************/
global without sharing class Utils{
    public static Boolean runLeadTrigger = TRUE;
    public static Boolean isExcelUploader = FALSE;
    public static Map<String, Lead_Item__c> earlyKeyMapItem = new Map<String, Lead_Item__c>();
    public static List<Lead_Item__c> allLinkedItems = new List<Lead_Item__c>();
    public static List<Lead> allLinkedLeads = new List<Lead>();

    // Gets the object record type by record type name
    public static String getRecordTypeId(String objectType, String recordTypeName) {
        Id recordTypeId;
        try {
            recordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE Name = :recordTypeName 
                            AND SObjectType = :objectType].Id;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            return e.getMessage();
        }

        return recordTypeId;
    }

    // Gets the scheduling table's manager by city/office/business line/project
    public static String getOfficeManager(String city, String office, String businessLine, String project) {
        String managerId;
        for (Scheduling_Table__c table :[SELECT Manager__r.Id, Office__c, Project__c, Department__c
                                         FROM Scheduling_Table__c
                                         WHERE isActive__c = TRUE 
                                         AND City__c = :city
                                         AND RecordType.Name = :businessLine 
                                         ORDER BY LastModifiedDate DESC]) {
            if (businessLine == 'Counselling') {
                if (project.contains(Constants.STUDY_ABROAD_CN)) {
                    if (String.isNotBlank(table.Office__c) && 
                        office.contains(table.Office__c) && 
                        table.Project__c.contains(project) && 
                        String.isNotBlank(table.Project__c) && 
                        table.Project__c.contains(Constants.STUDY_ABROAD_CN)) {

                        managerId = table.Manager__r.Id;
                        break;
                    }

                } else if (project.contains(Constants.MINORITY_LANGUAGE_CN)) {
                    if (String.isNotBlank(table.Project__c) && 
                        table.Project__c.contains(project) && 
                        table.Project__c.contains(Constants.MINORITY_LANGUAGE_CN)) {

                        managerId = table.Manager__r.Id;
                        break;
                    }

                } else {
                    if (String.isNotBlank(table.Office__c) && 
                        office.contains(table.Office__c) && 
                        table.Project__c.contains(project) && 
                        String.isNotBlank(table.Project__c) && 
                        !table.Project__c.contains(Constants.STUDY_ABROAD_CN)) {

                        managerId = table.Manager__r.Id;
                        break;
                    }
                }


            } else {
                if (jiaowuAreaMapSFArea.get(office) != NULL && 
                    jiaowuAreaMapSFArea.get(office).contains(table.Office__c)) {

                    managerId = table.Manager__r.Id;
                    break;

                } else if (table.Office__c != NULL && office.contains(table.Office__c)) {
                    managerId = table.Manager__r.Id;
                    break;
                }
            }
        }
        // If we can not find the intended office manager, we will choose the department manager.
        if (String.isBlank(managerId)) {
            for (Scheduling_Table__c table :[SELECT Manager__r.Id, Office__c, 
                                                    Project__c, Department__c
                                             FROM Scheduling_Table__c
                                             WHERE isActive__c = TRUE 
                                             AND City__c = :city
                                             AND RecordType.Name = :businessLine 
                                             ORDER BY LastModifiedDate DESC]) {
                if (businessLine == 'Counselling' && 
                    countryMapDept.get(project) == table.Department__c) {
                    managerId = table.Manager__r.Id;
                    break;
                }
            }
        }

        // If we can not find the department manager, we will choose the business line manager of the manager.
        if (String.isBlank(managerId)) {
            for (Scheduling_Table__c table :[SELECT Manager__r.Id, Office__c, 
                                                    Project__c, Department__c
                                             FROM Scheduling_Table__c
                                             WHERE isActive__c = TRUE 
                                             AND City__c = :city
                                             AND RecordType.Name = :businessLine 
                                             ORDER BY LastModifiedDate DESC]) {
                managerId = table.Manager__r.Id;
                break;
            }
        }

        return managerId;
    }

    // Checks the consultant whether to belong to the office.
    public static Boolean belongsToOffice(String city, String office, String businessLine, Id consultant) {
        Boolean belongsTo = FALSE;

        for (Scheduling_Table__c table :[SELECT Manager__r.Id, 
                                                (SELECT User__c FROM Scheduling_Table_Lines__r)
                                         FROM Scheduling_Table__c
                                         WHERE isActive__c = TRUE 
                                         AND City__c = :city
                                         AND Office__c = :office 
                                         AND RecordType.Name = :businessLine]) {
            for (Scheduling_Table_Line__c line :table.Scheduling_Table_Lines__r) {
                if (line.User__c == consultant) {
                    belongsTo = TRUE;
                    break;
                }
            }
        }

        return belongsTo;
    }

    // Checks the account whether to have a exam result or not.
    public static Boolean hasTested(Id accId, String testType) {
        Boolean hasTest = FALSE;
        for (Score__c exam :[
                SELECT Id FROM Score__c
                WHERE Test_Type__c = :testType
                AND Tester__c =:accId]) {
            hasTest = TRUE;
        }
        return hasTest;
    }

    // Checks the account whether to have an education history record or not.
    public static Boolean hasEducation(Id accId, String eduLevel, String grade) {
        Boolean hasEdu = FALSE;
        for (Education__c edu :[SELECT Education_Level__c, Grade__c
                                FROM Education__c
                                WHERE Account__c = :accId
                                AND Education_Level__c = :eduLevel
                                AND Grade__c = :grade]) {
            hasEdu = TRUE;
        }
        return hasEdu;
    }

    // Resets the appointment record type to a normal follup up when converts a lead item
    public static List<Appoitment__c> updateFollowups(List<Appoitment__c> followups, String accId) {
        List<Appoitment__c> newFollowups = new List<Appoitment__c>();
        Id followupRTId = Utils.getRecordTypeId('Appoitment__c', 'Follow Up');
        for (Appoitment__c followup:followups) {
            if (followup.Account__c == NULL) {
                followup.Account__c = accId;
                followup.RecordTypeId = followupRTId;
                newFollowups.add(followup);
            }
        }
        return newFollowups;
    }

    // Create contact records when converts a lead
    public static List<Contact_EIC__c> createContacts (Account acc, Map<String, String> phoneMapType, Decimal qq, String wechat, String email) {
        List<Contact_EIC__c> conts = new List<Contact_EIC__c>();

        for (String phone :phoneMapType.keySet()) {
            Contact_EIC__c contact = New Contact_EIC__c(
                Name = acc.Name,
                Account__c = acc.Id,
                Relationship__c = Constants.CONTACT_RELATIONSHIP_CN,
                Contact_Type__c = phoneMapType.get(phone),
                UniqueContact__c = phone);
            conts.add(contact);
        }

        if (qq != 0  && qq != NULL) {
            Contact_EIC__c contact = New Contact_EIC__c(
                Name = acc.Name,
                Account__c = acc.Id,
                Contact_Type__c = 'QQ',
                Relationship__c = Constants.CONTACT_RELATIONSHIP_CN,
                Normal_Contact__c  = String.valueOf(qq) + '(QQ)');
            conts.add(contact);
        }

        if (String.isNotBlank(wechat)) {
            Contact_EIC__c contact = New Contact_EIC__c(
                Name = acc.Name,
                Account__c = acc.Id,
                Contact_Type__c = Constants.WECHAT_CN,
                Relationship__c = Constants.CONTACT_RELATIONSHIP_CN,
                Normal_Contact__c = wechat + '(Wechat)');
            conts.add(contact);
        }

        if (String.isNotBlank(email)) {
            Contact_EIC__c contact = New Contact_EIC__c(
                Name = acc.Name,
                Account__c = acc.Id,
                Contact_Type__c = Constants.EMAIL_CN,
                Relationship__c = Constants.CONTACT_RELATIONSHIP_CN,
                Normal_Contact__c = email);
            conts.add(contact);
        }
        return conts;
    }

    // Uses regular expression to show merged fields
    public static String replaceMergeField(String SMSTemplate, String objectName, Id recordId){
        Pattern regex = Pattern.compile('\\{!([^}]*)\\}');
        Matcher regexMatcher = regex.matcher(SMSTemplate);
        Set<String> tokens = new Set<String>();

        while (regexMatcher.find()) {
            String dirtyVariable = regexMatcher.group();

            // Extracts curly braces and exclamation marks
            String variable = dirtyVariable.substring(2, dirtyVariable.length()-1);

            // Gets all field API name
            if(variable.startsWith(objectName + '.')){
                tokens.add(variable.replace(objectName + '.', ''));
            }
        }
        System.debug(LoggingLevel.INFO, '*** tokens: ' + tokens);
        if(tokens.size() > 0){
            //Builds dynamic query
            String qry = 'SELECT ';
            for (String s :tokens) {
                Schema.DescribeSObjectResult  d = Schema.getGlobalDescribe().get(objectName).getDescribe();
                Schema.DescribeFieldResult f = d.fields.getMap().get(s).getDescribe();

                if (f.getRelationshipName() != NULL) {
                    qry += f.getRelationshipName() + '.Name,';

                } else if (f.getName() == 'SMS_Learn_Place__c' && objectName == 'Sales_Order_Line__c') {
                    qry += 'Class__r.Learn_Place__c,';

                } else if (f.getName() == 'SMS_Learn_Place__c' && objectName == 'Inquiry_Sheet__c') {
                    qry += 'Intended_Class__r.Learn_Place__c,';

                }else {
                    qry += s + ',';
                }
            }

            // Removes last ","
            qry = qry.substring(0, qry.length()-1);

            // Does the query
            SObject obj;
            obj = Database.query(qry + ' FROM ' + objectName + ' WHERE Id = :recordId');

            // Replaces values
            for (String s :tokens) {
                SMSTemplate = SMSTemplate.replace('{!' + objectName + '.' + s + '}', getValue(obj, s));
            }
        }

        return SMSTemplate;
    }

    // Gets the field value by filed name
    public static String getValue(SObject obj, String fieldName){
        String objName = String.valueOf(obj.getSObjectType());
        Schema.DescribeSObjectResult d = Schema.getGlobalDescribe().get(objName).getDescribe();
        Schema.DescribeFieldResult f = d.fields.getMap().get(fieldName).getDescribe();
        String relationShipName = f.getRelationshipName();

        if (objName == 'User' && obj.get(fieldName) != NULL) {
            return String.valueOf(obj.getSObject(relationShipName).get('LastName')) + ' ' + String.valueOf(obj.getSObject(relationShipName).get('FirstName'));
        
        } else if (f.getRelationshipName() != NULL && obj.get(fieldName) != NULL) {
            return String.valueOf(obj.getSObject(relationShipName).get('Name'));
        
        } else if (f.getType() == DisplayType.DATE && obj.get(fieldName) != NULL) {
            return String.valueOf(obj.get(fieldName)).left(10);
        
        } else {
            return (obj.get(fieldName) != null) ? String.valueOf(obj.get(fieldName)) : '';
        }
    }

    // It is used to call approval process from the custom button
    webservice static String submitForApproval(Id recordId) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(recordId);
        Approval.ProcessResult result = Approval.process(req);

       return 'Success';
    }

    // Customized exception class
    public Class utilException extends Exception {

    }

    // Inserts account and upserts contact
    public static Map<String, Id> upsertContacts(List<Lead> leads) {
        List<Account> newAccs = new List<Account>();
        List<Contact_EIC__c> contacts = new List<Contact_EIC__c>();
        Set<String> phoneSet = new Set<String>();
        Map<String, Id> phoneMapAccountId = new Map<String, Id>();
        Map<String, Account> phoneMapAccount = new Map<String, Account>();
        Id accRTId = Utils.getRecordTypeId('Account', 'EIC Account');
        for (Lead lead : leads) {
            Map<String, String> phoneMapType = new Map<String, String>();
            if (String.isNotBlank(lead.MobilePhone)) {
                phoneMapType.put(lead.MobilePhone, Constants.MOBILE_CN);
                phoneSet.add(lead.MobilePhone);
            }
            if (String.isNotBlank(lead.Phone)) {
                String fixPhone = lead.Area_Code__c == NULL?'':lead.Area_Code__c + lead.Phone;
                phoneMapType.put(fixPhone, Constants.FIX_PHONE_CN);
                phoneSet.add(fixPhone);
            }

            if (lead.Phone_Status__c != Constants.LEAD_PHONE_STATUS_HASACCOUNT_CN && 
                lead.Converted_Account__c == NULL) {
                Account newAcc = new Account(
                    Name = lead.Name,
                    RecordTypeId = accRTId,
                    Gender__c = lead.Gender__c,
                    ID_Type__c = lead.ID_Type__c,
                    ID_Number__c = lead.ID_Number__c,
                    Country__c = lead.Country__c,
                    Province__c = lead.ProvinceLookup__c,
                    City__c = lead.City__c,
                    District__c = lead.District__c,
                    Birthday__c = lead.Birthday__c,
                    Convenient_Time__c = lead.Convenient_Time__c);


                if (String.isNotBlank(lead.MobilePhone)) {
                    phoneMapAccount.put(lead.MobilePhone, newAcc);
                }

                if (String.isNotBlank(lead.Phone)) {
                    String fixPhone = lead.Area_Code__c == NULL?'':lead.Area_Code__c + lead.Phone;
                    phoneMapAccount.put(fixPhone, newAcc);
                }

                contacts.addAll(Utils.createContacts(newAcc, phoneMapType, lead.QQ__c, lead.Wechat__c,lead.Email));
                newAccs.add(newAcc);
            }
        }

        try {
            insert newAccs;

            for (Contact_EIC__c contact :contacts) {
                if (phoneMapAccount.get(contact.UniqueContact__c) != NULL) {
                    contact.Account__c = phoneMapAccount.get(contact.UniqueContact__c).Id;
                }
            }

            Database.UpsertResult [] upRes = Database.upsert(contacts, FALSE);

            // Gets all accounts depending on phone/mobile
            for (Contact_EIC__c contact :[
                    SELECT Account__c, UniqueContact__c
                    FROM Contact_EIC__c
                    WHERE UniqueContact__c IN:phoneSet
                    AND isInvalid__c = FALSE]){
                phoneMapAccountId.put(contact.UniqueContact__c, contact.Account__c);
            }
            return phoneMapAccountId;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            return NULL;
        }
    }

    // Creates opportunity
    public static Map<String, Opportunity> createKeyMapOpp(Map<String, Id> phoneMapAccountId, List<Lead_Item__c> leadItems) {
        Set<String> mobileLinkSet = new Set<String>();
        Set<String> fixPhoneLinkSet = new Set<String>();
        Set<String> earlyLinkSet = new Set<String>();
        Set<Id> allLeadIds = new Set<Id>();
        Set<Lead_Item__c> allLinkedItemSet = new Set<Lead_Item__c>();
        Map<String, Opportunity> keyMapOpportunity = new Map<String, Opportunity>();
        Map<String, Lead_Item__c> earlyPhoneMapItem = new Map<String, Lead_Item__c>();
        Map<String, String> rtCNNameMapRTId = getCNNameMapRTId();
        List<Opportunity> opportunities = new List<Opportunity>();
        // Gets the all unique keys
        for (Lead_Item__c li :leadItems) {
            if (String.isNotBlank(li.Mobile__c)) {
                mobileLinkSet.add(li.Mobile_Linked_Key__c);
            }
            if (String.isNotBlank(li.Fix_Phone__c)) {
                fixPhoneLinkSet.add(li.Fix_Phone_Linked_Key__c);
            }
        }

        // Retrieves all related lead item by mobile unique key ASC
        for (Lead_Item__c li :[SELECT Mobile__c, Mobile_Unique_Key__c, 
                                      Mobile_Linked_Key__c, Fix_Phone__c, 
                                      Fix_Phone_Unique_Key__c, Fix_Phone_Linked_Key__c,
                                      Area_Code__c, Campaign_Id__c, Lead__c, 
                                      Lead__r.Campaign__r.Marketing_Channel_Lv3__c
                               FROM Lead_Item__c
                               WHERE Mobile_Linked_Key__c IN :mobileLinkSet
                               AND Is_Converted__c = FALSE 
                               ORDER BY Lead__r.CreatedDate ASC]) {
            if (!earlyPhoneMapItem.keySet().contains(li.Mobile__c)) {
                earlyPhoneMapItem.put(li.Mobile__c, li);
            }

            if (!earlyLinkSet.contains(li.Mobile_Linked_Key__c)) {
                earlyKeyMapItem.put(li.Mobile_Unique_Key__c, li);
                earlyLinkSet.add(li.Mobile_Linked_Key__c);
            }
            allLinkedItemSet.add(li);
            allLeadIds.add(li.Lead__c);
        }

        // Retrieves all related lead item by fix phone unique key ASC
        for (Lead_Item__c li :[SELECT Mobile__c, Mobile_Unique_Key__c, 
                                      Mobile_Linked_Key__c, Fix_Phone__c, 
                                      Fix_Phone_Unique_Key__c, Fix_Phone_Linked_Key__c,
                                      Area_Code__c, Campaign_Id__c, 
                                      Lead__r.Campaign__r.Marketing_Channel_Lv3__c, 
                                      Lead__c
                               FROM Lead_Item__c
                               WHERE Fix_Phone_Linked_Key__c IN :fixPhoneLinkSet
                               AND Is_Converted__c = FALSE ORDER BY Lead__r.CreatedDate ASC]) {

            String fixPhone = li.Area_Code__c == NULL ? '' : li.Fix_Phone__c;
            if (!earlyPhoneMapItem.keySet().contains(fixPhone)) {
                earlyPhoneMapItem.put(fixPhone, li);
            }

            if (!earlyLinkSet.contains(li.Fix_Phone_Unique_Key__c)) {
                earlyKeyMapItem.put(li.Fix_Phone_Unique_Key__c, li);
                earlyLinkSet.add(li.Fix_Phone_Linked_Key__c);
            }
            allLinkedItemSet.add(li);
            allLeadIds.add(li.Lead__c);
        }

        // Retrieves all related lead
        allLinkedLeads = [
            SELECT MobilePhone, Area_Code__c, 
                   Phone, Converted_Account__c, 
                   Phone_Status__c, Is_Master__c
            FROM Lead
            WHERE Id IN :allLeadIds];

        // Gets all related items
        allLinkedItems.addAll(allLinkedItemSet);

        earlyLinkSet.clear();
        for (Lead_Item__c li :leadItems) {
            // When creates the opportunity, we only create one opportunity
            if ((earlyLinkSet.contains(li.Mobile_Linked_Key__c) && String.isNotBlank(li.Mobile__c)) || 
                (earlyLinkSet.contains(li.Fix_Phone_Linked_Key__c) && String.isNotBlank(li.Fix_Phone__c))) continue;
            Opportunity opp = new Opportunity(
                Name = li.Lead_Name__c + li.Intended_City__c + li.Business_Line__c +  li.Intended_Country__c + Constants.OPPORTUNITY_CN,
                CloseDate = System.today() + 30,
                Intended_City__c = li.Intended_City__c,
                Intended_Office__c = li.Lead__r.Intended_Office__c,
                Project__c = li.Project__c,
                Consultation_Mode__c = li.Consultation_Mode__c,
                StageName = Constants.OPPORTUNITY_STAGE_UNASSIGNED,
                RecordTypeId = rtCNNameMapRTId.get(li.Business_Line__c),
                Department__c = Utils.countryMapDept.get(li.Intended_Country__c),
                Description =  li.Lead__r.Description,
                Recommend_Account__c = li.Lead__r.Recommend_Account__c,
                Recommend_SA__c = li.Lead__r.Recommend_SA__c,
                Recommend_User__c = li.Lead__r.Recommend_User__c,
                Customer_Service__c = li.Lead__r.Customer_Service__c,
                Extension_Agent__c = li.Lead__r.Extension_Agent__c,
                OriginCampaign__c = li.Lead__r.OriginCampaign__c);

            if (li.Business_Line__c == Constants.COOPERATIVE_CN) {
                opp.Department__c = Constants.COOPERATIVE_CN;

            } else if (li.Business_Line__c == Constants.TESTPREP_CN) {
                opp.Department__c = Constants.DEPARTMENT_TESTPREP_CN;
            }

            if (li.Business_Line__c != Constants.COUNSELLING_CN) {
                opp.Name = li.Lead_Name__c + li.Intended_City__c + li.Business_Line__c + Constants.OPPORTUNITY_CN;
            }

            if (String.isNotBlank(li.Mobile__c)) {
                keyMapOpportunity.put(li.Mobile_Linked_Key__c, opp);
                opp.AccountId = phoneMapAccountId.get(li.Mobile__c);
                opp.Marketing_Channel_Lv3__c = earlyPhoneMapItem.get(li.Mobile__c).Lead__r.Campaign__r.Marketing_Channel_Lv3__c;
                opp.Level_4_Promotion_Channel__c = earlyPhoneMapItem.get(li.Mobile__c).Campaign_Id__c;

            } else {
                keyMapOpportunity.put(li.Fix_Phone_Linked_Key__c, opp);
                opp.AccountId = phoneMapAccountId.get(li.Area_Code__c + li.Fix_Phone__c);
                opp.Marketing_Channel_Lv3__c = earlyPhoneMapItem.get(li.Fix_Phone__c).Lead__r.Campaign__r.Marketing_Channel_Lv3__c;
                opp.Level_4_Promotion_Channel__c = earlyPhoneMapItem.get(li.Fix_Phone__c).Campaign_Id__c;
            }
            opportunities.add(opp);

            if (String.isNotBlank(li.Mobile__c)) {
                earlyLinkSet.add(li.Mobile_Linked_Key__c);
            }

            if (String.isNotBlank(li.Fix_Phone__c)) {
                earlyLinkSet.add(li.Fix_Phone_Linked_Key__c);
            }
        }

        try {
            insert opportunities;
            return keyMapOpportunity;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            return NULL;
        }
    }

    // Updates lead item status and connect to opportunity
    public static void updateLeadItems(Map<String, Opportunity> keyMapOpportunity, List<Lead_Item__c> leadItems) {
        for (Lead_Item__c li :leadItems) {
            if (String.isNotBlank(li.Mobile_Unique_Key__c)) {
                if (earlyKeyMapItem.get(li.Mobile_Unique_Key__c) != NULL) {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
                    li.Opportunity__c = keyMapOpportunity.get(li.Mobile_Linked_Key__c).Id;

                } else {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                    li.Opportunity__c = keyMapOpportunity.get(li.Mobile_Linked_Key__c).Id;
                }

            } else {
                if (earlyKeyMapItem.get(li.Fix_Phone_Unique_Key__c) != NULL) {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_WON_CN;
                    li.Opportunity__c = keyMapOpportunity.get(li.Fix_Phone_Linked_Key__c).Id;

                } else {
                    li.Status__c = Constants.LEAD_STATUS_CONVERTED_DUP_CN;
                    li.Opportunity__c = keyMapOpportunity.get(li.Fix_Phone_Linked_Key__c).Id;
                }
            }
        }

        try {
            update leadItems;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
    }

    // Updates lead account and Is_Master__c
    public static void updateLeads(Map<String, Id> phoneMapAccountId, List<Lead> leads) {
        for (Lead lead :leads) {
            if (String.isNotBlank(lead.MobilePhone)) {
                lead.Converted_Account__c = phoneMapAccountId.get(lead.MobilePhone);

            } else {
                String fixPhone = lead.Area_Code__c == NULL?'':lead.Area_Code__c + lead.Phone;
                lead.Converted_Account__c = phoneMapAccountId.get(fixPhone);
            }

            if (lead.Phone_Status__c != Constants.LEAD_PHONE_STATUS_HASACCOUNT_CN) {
                lead.Is_Master__c = TRUE;
            }
        }

        try {
            update leads;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
    }

    // Gets the an opportunity record type map which key is name, value is Id
    public static Map<String, String> getCNNameMapRTId() {
        Map<String, String> CNNameMapRTId = new Map<String, String>();

        for (RecordType rt: [SELECT Name 
                             FROM RecordType 
                             WHERE SObjectType = 'Opportunity']) {
            if (rt.Name == 'Counselling') {
                CNNameMapRTId.put(Constants.COUNSELLING_CN, rt.Id);

            } else if (rt.Name == 'TestPrep') {
                CNNameMapRTId.put('NP', rt.Id);
                CNNameMapRTId.put(Constants.TESTPREP_CN, rt.Id);

            } else if (rt.Name == 'Scholar Tree') {
                CNNameMapRTId.put(Constants.SCHOLAR_TREE_CN, rt.Id);

            } else if (rt.Name == 'Cooperative') {
                CNNameMapRTId.put(Constants.COOPERATIVE_CN, rt.Id);
            }
        }
        return CNNameMapRTId;
    }

    // Minority language's school map for SAGE contract system
    public static Map<String, String> minoritySchoolMap = new Map<String, String>{
        '建和' => '6013'
    };

    // Minority language's branch map for SAGE contract system
    public static Map<String, String> minorityBranchMap = new Map<String, String>{
        '建和' => '6024'
    };

    // Jiaowu's school area map for Jiaowu contract system
    public static Map<String, String> jiaowuAreaMapSFArea = new Map<String, String>{
        '(海)人大校区' => '银网人大',
        '(海)银网校区' => '银网人大'
    };

    // A map which key is country and value is department
    public static Map<String, String> countryMapDept = new Map<String, String> {
        '澳大利亚' => '澳新部',
        '新西兰' => '澳新部',

        '加拿大' => '加拿大部',

        '美国' => '美国部',

        '德国' => '欧洲部',
        '法国' => '欧洲部',
        '意大利' => '欧洲部',
        '荷兰' => '欧洲部',
        '西班牙' => '欧洲部',
        '芬兰' => '欧洲部',
        '瑞士' => '欧洲部',
        '瑞典' => '欧洲部',
        '挪威' => '欧洲部',
        '丹麦' => '欧洲部',
        '奥地利' => '欧洲部',
        '波兰' => '欧洲部',
        '匈牙利' => '欧洲部',
        '比利时' => '欧洲部',
        '波兰' => '欧洲部',

        '韩国' => '亚洲部',
        '日本' => '亚洲部',
        '马来西亚' => '亚洲部',
        '新加坡' => '亚洲部',
        '香港' => '亚洲部',
        '澳门' => '亚洲部',
        '台湾' => '亚洲部',

        '爱尔兰' => '英爱部',
        '英国' => '英爱部',

        '学游-美国' => '学游项目部',
        '学游-加拿大' => '学游项目部',
        '学游-澳新' => '学游项目部',
        '学游-英爱' => '学游项目部',
        '学游-欧洲' => '学游项目部',
        '学游-亚洲' => '学游项目部',

        '小语种-法语' => '小语种部',
        '小语种-德语' => '小语种部',
        '小语种-意大利语' => '小语种部',
        '小语种-西班牙语' => '小语种部',
        '小语种-日语' => '小语种部',
        '小语种-韩语' => '小语种部',
        '小语种-VIP' => '小语种部',
        '小语种-其他' => '小语种部'
    };

    // A map which key is country and value is SAGE contract system country code.
    public static Map<String, String> countryMapDeptCode = new Map<String, String> {
        '澳大利亚' => 'AAB',
        '新西兰' => 'AAB',

        '爱尔兰' => 'AAA',
        '英国' => 'AAA',

        '加拿大' => 'AAD',

        '美国' => 'AAC',

        '法国' => 'AAF',
        '西班牙' => 'AAF',

        '德国' => 'AAG',
        '荷兰' => 'AAG',
        '瑞典' => 'AAG',
        '奥地利' => 'AAG',

        '瑞士' => 'AAH',
        '丹麦' => 'AAH',
        '芬兰' => 'AAH',
        '意大利' => 'AAH',
        '挪威' => 'AAH',
        '波兰' => 'AAH',
        '匈牙利' => 'AAH',
        '比利时' => 'AAH',

        '日本' => 'AAE',

        '马来西亚' => 'AAI',
        '新加坡' => 'AAI',

        '韩国' => 'AAJ',

        '香港' => 'AAK',
        '澳门' => 'AAK',
        '台湾' => 'AAK',

        '学游-美国' => 'AAX',
        '学游-加拿大' => 'AAX',
        '学游-澳新' => 'AAX',
        '学游-英爱' => 'AAX',
        '学游-欧洲' => 'AAX',
        '学游-亚洲' => 'AAX'
    };
}