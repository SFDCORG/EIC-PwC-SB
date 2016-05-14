/**************************************************************************************************
 * Name: JiaowuRenewRESTful
 * Object: 
 * Purpose: Get the Jiaowu SA's referral
 * Requirement: 
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-13
 * Modified History: 
 * 2015-10-13   Vicia Wang Writes comments in this format
 * 2016-05-08    Allen    Format the code
 * Endpoint: "http://eic.force.com/services/apexrest/CRM/Jiaowu/JiaowuRenewRESTful/*"
{"renews": [{
    "CRM_Student_ID": "00128000008NHvxAAG",
    "CRM_Opportunity_ID": "00628000004e4qtAAA",
    "Student_Phone": "18212341234",
    "SA_Phone": "18200001111",
    "SA_Email": "sa@eic.com",
    "Desire_Content_IDs": "SAT;GRE",
    "Desire_City_Name" : "上海",
    "Desire_Area_Name": "人广校区",
    "Memo": "Test Sample"
    }]
}
***************************************************************************************************/
@RestResource(urlMapping = '/CRM/Jiaowu/JiaowuRenewRESTful/*')
global without sharing class JiaowuRenewRESTful {

    @HttpGet
    global static String doGet () {
        return 'Connected Successfully';
    }

    @HttpPost
    global static String doPost(List<Renew> renews) {

        String result = createRenew(renews[0]);

        // Create the interaction log
        InteractionLogUtil.CreateLog('JIAOWU - New Renew', JSON.serialize(renews));
        return result;
    }

    global static String createRenew (Renew renew) {

        List<Opportunity> oldOpp = new List<Opportunity>();
        List<Campaign> renewCampaign = new List<Campaign>();
        List<Account> acc = new List<Account>();

        SavePoint sp = Database.setSavepoint();

        // Check whether we have the account in CRM
        acc = [SELECT Id, Name FROM Account WHERE Id = :renew.CRM_Student_ID];
        if (acc.size() == 0) {
            Result noAccount = new Result(NULL, Label.Jiaowu_Renew_Error0);
            return JSON.serialize(noAccount);
        }

        // Check whether we have the old Opp in CRM
        oldOpp = [SELECT Id, IsClosed, AccountId, Account.Name, Intended_Office__c, OwnerId
                  FROM Opportunity
                  WHERE Id = :renew.CRM_Opportunity_ID];

        if (oldOpp.size() == 0) {
            Result noOldOpp = new Result(NULL, Label.Jiaowu_Renew_Error1);
            return JSON.serialize(noOldOpp);

        } else if (oldOpp[0].IsClosed == FALSE) {
            Result oldOppOpen = new Result(NULL, Label.Jiaowu_Renew_Error2);
            return JSON.serialize(oldOppOpen);
        }

        // Check whether we have the campaign in CRM
        renewCampaign = [SELECT Id FROM Campaign WHERE Name = :Label.Jiaowu_Renew_Campaign_Name];
        if (renewCampaign.size() == 0) {

            Result noCampaign = new Result(NULL, Label.Jiaowu_Renew_Error3);
            return JSON.serialize(noCampaign);
        }

        // Create the lead 
        Lead lead = new Lead(Lastname = acc[0].Name,
                             MobilePhone = renew.Student_Phone,
                             Campaign__c = renewCampaign[0].Id,
                             Consultation_Mode__c = '面询',
                             Is_TestPrep__c = TRUE,
                             Intended_City__c = renew.Desire_City_Name,
                             TestPrep_Project__c = renew.Desire_Content_IDs,
                             Description = renew.Memo,
                             Company = 'EIC',
                             Status = '已转化',
                             Recommend_SA__c = renew.SA_Email);

        try {
            insert lead;

            Lead_Item__c leadItem = [SELECT Id FROM Lead_Item__c WHERE Lead__c = :lead.Id LIMIT 1];

            String convertResult = convertLinkedItems(leadItem.Id, oldOpp[0], renew);
            return convertResult;

        } catch (Utils.utilException e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            Result duplicate = new Result(NULL, e.getMessage());
            Database.rollback(sp);
            return JSON.serialize(duplicate);

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            Result duplicate = new Result(NULL, e.getMessage());
            Database.rollback(sp);
            return JSON.serialize(duplicate);
        }
    }

    // Convert Lead Item including linked lead items convention
    global static String convertLinkedItems (Id leadItemId, Opportunity oldOpp, Renew renew) {

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
        
        selectedItem = [SELECT Mobile__c, Mobile_Linked_Key__c, Lead__r.Area_Code__c, Lead__c, Lead__r.Name,
                               Lead__r.Gender__c, Lead__r.Consultation_Mode__c, Lead__r.ID_Number__c,
                               Lead__r.Campaign__c, Business_Line__c, Intended_City__c, Project__c, 
                               Marketing_Channel_Lv3__c
                        FROM Lead_Item__c
                        WHERE Id = :leadItemId];

        if (String.isNotBlank(selectedItem.Mobile__c)) {
            phoneMapType.put(selectedItem.Mobile__c, '手机');
            linkedKeys.add(selectedItem.Mobile_Linked_Key__c);
        }

        selectedLead = [SELECT Description, (SELECT Id
                                             FROM Lead_Items__r)
                        FROM Lead
                        WHERE Id = :selectedItem.Lead__c];

        // Gets all duplicated by mobile
        for (Lead_Item__c li : [SELECT Name, Lead__c,  Status__c, CreatedDate, Marketing_Channel_Lv3__c, 
                                       Business_Line__c, Project__c, Intended_City__c, Intended_Country__c,
                                       Lead__r.Name, Lead__r.OwnerId, Lead__r.Campaign__c, Lead__r.Consultation_Mode__c, 
                                       Lead__r.CreatedDate, Lead__r.Intended_Office__c, Mobile_Linked_Key__c
                                FROM Lead_Item__c
                                WHERE Mobile_Linked_Key__c IN :linkedKeys 
                                AND Is_Converted__c = FALSE
                                ORDER BY Lead__r.CreatedDate,
                                         Mobile__c]) {

            // If the lead item belongs to same selected lead, we need skip it.
            if (selectedItem.Lead__c == li.Lead__c && li.Id != selectedItem.Id) continue;
            mobileItemIds.add(li.Id);
            leadIds.add(li.Lead__c);

            // Adds to duplicated lead item
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
        for (Lead_Item__c li : [SELECT Name, Lead__c,  Status__c, CreatedDate, Marketing_Channel_Lv3__c, Business_Line__c, 
                                       Project__c, Intended_City__c, Intended_Country__c, Lead__r.Name, Lead__r.OwnerId, 
                                       Lead__r.Campaign__c, Lead__r.Consultation_Mode__c, Lead__r.CreatedDate, 
                                       Lead__r.Intended_Office__c, Fix_Phone_Linked_Key__c
                                FROM Lead_Item__c 
                                WHERE Fix_Phone_Linked_Key__c IN :linkedKeys 
                                AND Is_Converted__c = FALSE
                                ORDER BY Lead__r.CreatedDate,
                                         Fix_Phone__c]) {

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

        if (renew.Desire_Area_Name.contains('银网') && renew.Desire_City_Name == '北京') {
            renew.Desire_Area_Name = '银网人大';
        }

        Opportunity opp = new Opportunity(
            Name = oldOpp.Account.Name + renew.Desire_City_Name + '考培商机',
            RecordTypeId = Utils.getRecordTypeId('Opportunity', 'TestPrep'),
            AccountId = oldOpp.AccountId,
            CloseDate = System.today() + 30,
            Intended_City__c = renew.Desire_City_Name,
            Intended_Office__c = renew.Desire_Area_Name,
            Project__c = renew.Desire_Content_IDs,
            Consultation_Mode__c = '面询',
            StageName = '待分配',
            Marketing_Channel_Lv3__c = masterleadItems[0].Marketing_Channel_Lv3__c,
            Level_4_Promotion_Channel__c = masterleadItems[0].Lead__r.Campaign__c,
            Description = renew.Memo,
            Recommend_SA__c = renew.SA_Email);

        // Distribute the new opportunity to the original consultant
        String intendedOfficeMgrId = Utils.getOfficeManager(opp.Intended_City__c, opp.Intended_Office__c, 'TestPrep', '');
        Boolean belongsTo = Utils.belongsToOffice(opp.Intended_City__c, opp.Intended_Office__c, 'TestPrep', oldOpp.OwnerId);

        if (oldOpp.Intended_Office__c == renew.Desire_Area_Name && belongsTo) {
            opp.OwnerId = oldOpp.OwnerId;
            
        } else {
            if (String.isNotBlank(intendedOfficeMgrId)) {
                opp.OwnerId = intendedOfficeMgrId;
            } else {
                throw new Utils.utilException('您选择的意向城市和校区, 没有对应的排班表, 请先联系意向城市的校区主管创建排班表');
                return NULL;
            }
        }
        insert opp;
        
        for (Lead lead:leads) {
            if (lead.Converted_Account__c == NULL) {
                lead.Converted_Account__c = oldOpp.AccountId;
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

        Result newOpp = new Result(opp.Id, Label.Jiaowu_Renew_Successful);
        return JSON.serialize(newOpp);
    }

    global class Renew {
        global String CRM_Student_ID; // CRM系统学员ID /CRM 测试客户: 00128000008NHvxAAG
        global String CRM_Opportunity_ID; // CRM系统商机ID /CRM 测试商机: 00628000004e4qtAAA
        global String Student_Phone; // 学员电话号码
        global String SA_Phone; // 学习顾问的电话
        global String SA_Email; // 学习顾问的邮箱
        global String Desire_Content_IDs; // 意向内容ID集合 /GRE;SAT
        global String Desire_City_Name; // 意向城市名称 / 上海
        global String Desire_Area_Name; // 意向校区名称 / 人广校区
        global String Memo; // 备注 /续费失败时,显示例如,客户续费意愿已存在.

    }

    global class Result {
        String CRM_Opportunity_ID; // CRM系统商机ID
        String Result; // 用来保存成功或失败信息  /推荐失败返回例如: 推荐失败,客户已存在.

        global Result(String CRM_Opportunity_ID, String Result) {
            this.CRM_Opportunity_ID = CRM_Opportunity_ID;
            this.Result = Result;
        }
    }
}