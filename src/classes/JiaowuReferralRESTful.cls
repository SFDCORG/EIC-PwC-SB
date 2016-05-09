/**************************************************************************************************
 * Name: JiaowuReferralRESTful
 * Object: 
 * Purpose: Get the Jiaowu SA's referral
 * Requirement: 
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-13
 * Modified History: 
 * 2015-10-13   vicia.wang Writes comments in this format
 * Endpoint: "http://eic.force.com/services/apexrest/CRM/Jiaowu/JiaowuReferralRESTful/*"
{"referrals": [{
    "Student_Name": "Vicia",
    "Student_Phone": "18012341234",
    "CRM_Student_ID": "00128000008NHvxAAG",
    "Desire_Content_IDs": "GRE;SAT",
    "Desire_City_Name": "上海",
    "Desire_Area_Name": "人广校区",
    "Employee_User_Name":"xieguanjie",
    "Employee_Name":"谢冠杰",
    "Creator_User_Name":"shina",
    "Creator_Name":"时娜",
    "Memo": "Test Sample"
    }]
}
***************************************************************************************************/
@RestResource(urlMapping='/CRM/Jiaowu/JiaowuReferralRESTful/*')
global without sharing class JiaowuReferralRESTful{
    global static List<Account> referrer = new List<Account>();

    @HttpGet
    global static String doGet() {
        return 'Connected Successfully';
    }

    @HttpPost
    global static String doPost(List<Referral> referrals) {
        String result = createReferral(referrals[0]);

        // Create the interaction log
        InteractionLogUtil.CreateLog('JIAOWU - New Referral',JSON.serialize(referrals));

        return result;
    }

    global static String createReferral(Referral ref) {
        Id accId;
        List<Campaign> referralCampaign = new List<Campaign>();
        SavePoint sp = Database.setSavepoint();
        
        // If we can not matched the referrer's in CRM and we return the error
        referrer = [SELECT Id, Name FROM Account WHERE Id = :ref.CRM_Student_ID];
        if (referrer.size() == 0) {
            Result noReferrer = new Result(NULL, NULL, Label.Jiaowu_Referral_Error1);
            return JSON.serialize(noReferrer);
        }

        referralCampaign = [SELECT Id FROM Campaign WHERE Name = :Label.Jiaowu_Referral_Campaign_Name];
        if (referralCampaign.size() == 0) {
            Result noCampaign = new Result(NULL, NULL, Label.Jiaowu_Referral_Error3);
            return JSON.serialize(noCampaign);
        }

        // If the referree's intetion had become the oppotunity and we return the error
        for (Contact_EIC__c con: [
                SELECT Id, Account__c 
                FROM Contact_EIC__c WHERE UniqueContact__c = :ref.Student_Phone AND isInvalid__c = FALSE]) {
            accId = con.Account__c;
            break;
        }

        // Create the lead 
        Lead lead = new Lead(
            Lastname = ref.Student_Name,
            MobilePhone = ref.Student_Phone,
            Campaign__c = referralCampaign[0].Id,
            Consultation_Mode__c = '面询',
            Is_TestPrep__c = TRUE,
            Intended_City__c = ref.Desire_City_Name,
            TestPrep_Project__c = ref.Desire_Content_IDs,
            Jiaowu_Employee_User_Name__c = ref.Employee_User_Name,
            Jiaowu_Employee_Name__c = ref.Employee_Name,
            Jiaowu_Creator_User_Name__c = ref.Creator_User_Name,
            Jiaowu_Creator_Name__c = ref.Creator_Name,
            Description = ref.Memo,
            Company = 'EIC',
            Status = '已转化',
            Recommend_Account__c = referrer[0].Id);

        try {
            insert lead;

            Lead_Item__c leadItem = [SELECT Id FROM Lead_Item__c WHERE Lead__c = :lead.Id LIMIT 1];

            String convertResult = convertLinkedItems(leadItem.Id, accId, ref);
            return convertResult;

        } catch (Utils.utilException e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            Result duplicate = new Result(NULL, NULL, e.getMessage());
            Database.rollback(sp);
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(duplicate)     : ' + JSON.serialize(duplicate));

            return JSON.serialize(duplicate);

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            Result duplicate = new Result(NULL, NULL, Label.Jiaowu_Referral_Error2);
            Database.rollback(sp);
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(duplicate)     : ' + JSON.serialize(duplicate)     );

            return JSON.serialize(duplicate);
        }
    }

    // Convert Lead Item including linked lead items convertion
    global static String convertLinkedItems(Id leadItemId, Id accId, Referral ref) {
        Lead_Item__c selectedItem = new Lead_Item__c();
        Lead selectedLead = new Lead();
        Set<Id> mobileItemIds = new Set<Id>();
        List<Lead_Item__c> masterleadItems = new List<Lead_Item__c>();
        List<Lead_Item__c> dupleadItems = new List<Lead_Item__c>();
        Set<String> linkedKeys = new Set<String>();
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leads = new List<Lead>();
        List<Appoitment__c> followups = new List<Appoitment__c>();
        Map<String, String> phoneMapType = new Map<String, String>();
        
        selectedItem = [
            SELECT 
                Mobile__c, Mobile_Linked_Key__c,
                Lead__r.Area_Code__c, Lead__c, Lead__r.Name, Lead__r.Gender__c, Lead__r.Consultation_Mode__c, Lead__r.ID_Number__c, Lead__r.Campaign__c,
                Business_Line__c, Intended_City__c, Project__c, Marketing_Channel_Lv3__c
            FROM Lead_Item__c WHERE Id = :leadItemId];
        if (String.isNotBlank(selectedItem.Mobile__c)) {
            phoneMapType.put(selectedItem.Mobile__c, '手机');
            linkedKeys.add(selectedItem.Mobile_Linked_Key__c);
        }

        selectedLead = [SELECT Description, (SELECT Id FROM Lead_Items__r) FROM Lead WHERE Id = :selectedItem.Lead__c];

        // Get all duplicated by mobile
        for (Lead_Item__c li : [
                SELECT Name, Lead__c,  Status__c, CreatedDate,
                       Marketing_Channel_Lv3__c,  Business_Line__c, Project__c, Intended_City__c, Intended_Country__c,
                       Lead__r.Name, Lead__r.OwnerId, Lead__r.Campaign__c, Lead__r.Consultation_Mode__c, Lead__r.CreatedDate, Lead__r.Intended_Office__c,
                       Mobile_Linked_Key__c
                FROM Lead_Item__c 
                WHERE Mobile_Linked_Key__c IN :linkedKeys 
                AND Is_Converted__c = FALSE ORDER BY Lead__r.CreatedDate, Mobile__c]) {
            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            mobileItemIds.add(li.Id);
            leadIds.add(li.Lead__c);

            // add to duplicated lead item
            if (masterleadItems.size() > 0) {
                li.Status__c = '关闭--重复线索转化成功';
                dupleadItems.add(li);

            // Set the first lead item
            } else {
                li.Status__c = '关闭--转化商机成功';
                masterleadItems.add(li);     
            }       
        }

        // Get all duplicated by fix phone
        for (Lead_Item__c li : [
                SELECT Name, Lead__c,  Status__c, CreatedDate,
                       Marketing_Channel_Lv3__c,  Business_Line__c, Project__c, Intended_City__c, Intended_Country__c,
                       Lead__r.Name, Lead__r.OwnerId, Lead__r.Campaign__c, Lead__r.Consultation_Mode__c, Lead__r.CreatedDate, Lead__r.Intended_Office__c,
                       Fix_Phone_Linked_Key__c
                FROM Lead_Item__c 
                WHERE Fix_Phone_Linked_Key__c IN :linkedKeys 
                AND Is_Converted__c = FALSE ORDER BY Lead__r.CreatedDate, Fix_Phone__c]) {
            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            leadIds.add(li.Lead__c);

            // add to duplicated lead item
            if (masterleadItems.size() > 0 && !mobileItemIds.contains(li.Id)) {
                li.Status__c = '关闭--重复线索转化成功';
                dupleadItems.add(li);
            
            // Set the first lead item
            } else if (masterleadItems.size() == 0) {
                li.Status__c = '关闭--转化商机成功';
                masterleadItems.add(li);     
            }
        }

        // Get all followups from lead
        followups = [SELECT Id, Account__c FROM Appoitment__c WHERE Lead__c IN :leadIds];
        leads = [SELECT Converted_Account__c FROM Lead WHERE Id IN:leadIds];


        // Convert Lead
        Utils.runLeadTrigger = FALSE;
        List<Contact_EIC__c> contacts = new List<Contact_EIC__c>();
        SavePoint sp = Database.setSavepoint();
        if (String.isBlank(accId)) {
            Account newAcc = new Account(
                Name = selectedItem.Lead__r.Name,
                RecordTypeId = Utils.getRecordTypeId('Account', 'EIC Account'),
                Recommend_Account__c = referrer[0].Name);
            insert newAcc;
            accId = newAcc.Id;

            contacts = Utils.createContacts(newAcc, phoneMapType, NULL, NULL, NULL);
            Database.upsert(contacts, Contact_EIC__c.UniqueContact__c, false);

            followups = Utils.updateFollowups(followups, accId);
            Database.update(followups, FALSE);
 
            Opportunity opp = new Opportunity(
                Name = ref.Student_Name + ref.Desire_City_Name + '考培商机',
                RecordTypeId = Utils.getRecordTypeId('Opportunity', 'TestPrep'),
                AccountId = accId,
                CloseDate = System.today() + 30,
                Intended_City__c = ref.Desire_City_Name,
                Intended_Office__c = ref.Desire_Area_Name,
                Project__c = ref.Desire_Content_IDs,
                Consultation_Mode__c = '面询',
                StageName = '待分配',
                Marketing_Channel_Lv3__c = masterleadItems[0].Marketing_Channel_Lv3__c,
                Level_4_Promotion_Channel__c = masterleadItems[0].Lead__r.Campaign__c,
                Description = ref.Memo,
                Recommend_Account__c = ref.CRM_Student_ID);
            // Get the intended office manager.
            String intendedOfficeMgrId = Utils.getOfficeManager(opp.Intended_City__c, opp.Intended_Office__c, 'TestPrep', '');
            if (String.isNotBlank(intendedOfficeMgrId)) {
                opp.OwnerId = intendedOfficeMgrId;
            } else {
                throw new Utils.utilException('您选择的意向城市和校区, 没有对应的排班表, 请先联系意向城市的校区主管创建排班表');
                return NULL;
            }
            insert opp;

            selectedLead.Is_Master__c = TRUE;
            for (Lead lead:leads) {
                if (lead.Converted_Account__c == NULL) {
                    lead.Converted_Account__c = accId;
                }
            }            
            Database.update(leads, FALSE);

            masterleadItems[0].Status__c = '关闭--转化商机成功';
            masterleadItems[0].Opportunity__c = opp.Id;
            update masterleadItems[0];

            for (Lead_Item__c li :dupleadItems) {
                li.Status__c = '关闭--重复线索转化成功';
                li.Opportunity__c = opp.Id;
            }
            update dupleadItems;

            Result newOpp = new Result(accId, opp.Id, Label.Jiaowu_Referral_Successful);
            return JSON.serialize(newOpp);

        } else {            
            Opportunity opp = new Opportunity(
                Name = ref.Student_Name + ref.Desire_City_Name + '考培商机',
                RecordTypeId = Utils.getRecordTypeId('Opportunity', 'TestPrep'),
                AccountId = accId,
                CloseDate = System.today() + 30,
                Intended_City__c = ref.Desire_City_Name,
                Intended_Office__c = ref.Desire_Area_Name,
                Project__c = ref.Desire_Content_IDs,
                Consultation_Mode__c = '面询',
                StageName = '待分配',
                Marketing_Channel_Lv3__c = masterleadItems[0].Marketing_Channel_Lv3__c,
                Level_4_Promotion_Channel__c = masterleadItems[0].Lead__r.Campaign__c,
                Description = ref.Memo,
                Recommend_Account__c = ref.CRM_Student_ID);
            String intendedOfficeMgrId = Utils.getOfficeManager(opp.Intended_City__c, opp.Intended_Office__c, 'Testprep', '');
            if (String.isNotBlank(intendedOfficeMgrId)) {
                opp.OwnerId = intendedOfficeMgrId;
            }
            insert opp;
            
            followups = Utils.updateFollowups(followups, accId);
            Database.update(followups, FALSE);

            for (Lead lead:leads) {
                if (lead.Converted_Account__c == NULL) {
                    lead.Converted_Account__c = accId;
                }
            }            
            Database.update(leads, FALSE);

            masterleadItems[0].Status__c = '关闭--转化商机成功';
            masterleadItems[0].Opportunity__c = opp.Id;
            update masterleadItems[0];

            for (Lead_Item__c li :dupleadItems) {
                li.Status__c = '关闭--重复线索转化成功';
                li.Opportunity__c = opp.Id;
            }
            update dupleadItems;

            Result newOpp = new Result(accId, opp.Id, Label.Jiaowu_Referral_Successful);
            return JSON.serialize(newOpp);
        }
    }

    global static String getRecordTypeId(String objectType, String recordTypeName) {
        Id recordTypeId;
        try {            
            recordTypeId = [SELECT Id FROM RecordType WHERE Name = :recordTypeName AND SObjectType = :objectType].Id;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
        }
        
        return recordTypeId;
    }

    global class Referral {
        global String Student_Name;                 // 学员名称
        global String Student_Phone;                // 学员电话 
        global String CRM_Student_ID;               // 推荐学员的CRM系统学员ID /CRM 测试客户: 00128000008NHvxAAG
        global String Desire_Content_IDs;           // 意向内容ID集合  /GRE;SAT
        global String Desire_City_Name;             // 意向城市名称     /上海
        global String Desire_Area_Name;             // 意向校区名称     /人广校区
        global String Employee_User_Name;           // 推荐员工用户名
        global String Employee_Name;                // 推荐员工姓名
        global String Creator_User_Name;            // 创建人用户名
        global String Creator_Name;                 // 创建人姓名
        global String Memo;
    }

    global class Result {
        String CRM_Student_ID;              // CRM系统学员ID
        String CRM_Opportunity_ID;          // CRM系统商机ID
        String Result;                      // 用来保存成功或失败信息  /推荐失败返回例如: 推荐失败,客户已存在.

        global Result(String CRM_Student_ID, String CRM_Opportunity_ID, String Result) {
            this.CRM_Student_ID = CRM_Student_ID;
            this.CRM_Opportunity_ID = CRM_Opportunity_ID;
            this.Result = Result;
        }

        global Result() {
        }
    }
}