/**************************************************************************************************
 * Name: MassConvertLeadExtension
 * Object:
 * Purpose: Mass convert lead item to opportunities
 * Requirement:
 * Author: vicia.wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-15
 * Modified History:
 * 2015-10-15   vicia.wang Writes comments in this format
***************************************************************************************************/
public without sharing class MassConvertLeadExtension{
	public List<Lead_Item__c> leadItems { get; set; }
	List<Lead_Item__c> allLeadItems = new List<Lead_Item__c>();
	List<Lead> leads = new List<Lead>();

	public String campaignName { get; set; }
	public String intendedCity { get; set; }
	public String businessLine { get; set; }
	public List<SelectOption> campaignNameItems { get; set; }
	public List<SelectOption> intendedCityItems { get; set; }
	public List<SelectOption> businessLineItems { get; set; }

	public MassConvertLeadExtension(ApexPages.StandardController standardCon) {

	}

	public MassConvertLeadExtension(ApexPages.StandardSetController standardSetCon) {
		leadItems = new List<Lead_Item__c>();
		Set<Id> selectedLeadIds = new Set<Id>();
        Set<Id> editableLeadIds = new Set<Id>();
		campaignNameItems = new List<SelectOption>();
		intendedCityItems = new List<SelectOption>();
		businessLineItems = new List<SelectOption>();

		if (standardSetCon.getSelected().size() == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.MASS_CONVERT_NO_ITEM_ERROR));
			return;
		}

		for (Lead lead : (List<Lead>) standardSetCon.getSelected()) {
			selectedLeadIds.add(lead.Id);
		}

        for (UserRecordAccess access : [SELECT RecordId, HasEditAccess
                					   FROM UserRecordAccess
                					   WHERE UserId = :UserInfo.getUserId()
                					   AND RecordId IN :selectedLeadIds]) {
            if(access.HasEditAccess){
                editableLeadIds.add(access.RecordId);
            }
        }

		allLeadItems = [SELECT Mobile__c, Mobile_Unique_Key__c, 
							   Mobile_Linked_Key__c, Area_Code__c, 
							   Fix_Phone__c, Fix_Phone_Unique_Key__c, 
							   Fix_Phone_Linked_Key__c, Lead_Name__c, 
							   Consultation_Mode__c, Campaign_Id__c, 
							   Lead__r.Name, Lead__r.OwnerId, 
							   Status__c, Lead__r.CreatedDate, 
							   Lead__r.Campaign__r.Name, Lead__r.Consultation_Mode__c,
							   Lead__r.Intended_Office__c, Lead__r.Description,
							   Intended_City__c, Business_Line__c, 
							   Project__c, Intended_Country__c, 
							   Lead__r.OriginCampaign__c
			 			FROM Lead_Item__c
			 			WHERE Lead__c IN :editableLeadIds
			 			AND Is_Converted__c = FALSE
			 			AND Project__c != NULL
			 			AND Project__c != :Constants.UNKNOWN_CN];

		if (allLeadItems.size() == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.MASS_CONVERT_NO_ITEM_ERROR));
			return;
		}

		Set<String> campaignNameSet = new Set<String>();
		Set<String> intendedCitySet = new Set<String>();
		Set<String> businessLineSet = new Set<String>();

		for (Lead_Item__c li :allLeadItems) {
			// Filtered by campaign name
			if (!campaignNameSet.contains(li.lead__r.Campaign__r.Name) && 
				String.isNotBlank(li.lead__r.Campaign__c)) {
				campaignNameItems.add(new SelectOption(li.lead__r.Campaign__r.Name, li.lead__r.Campaign__r.Name));
			}

			// Filtered by intended city
			if (!intendedCitySet.contains(li.Intended_City__c) && 
				String.isNotBlank(li.Intended_City__c)) {
				intendedCityItems.add(new SelectOption(li.Intended_City__c, li.Intended_City__c));
			}

			// Filtered by business line
			if (!businessLineSet.contains(li.Business_Line__c) && 
				String.isNotBlank(li.Business_Line__c)) {
				businessLineItems.add(new SelectOption(li.Business_Line__c, li.Business_Line__c));
			}

			campaignNameSet.add(li.lead__r.Campaign__r.Name);
			intendedCitySet.add(li.Intended_City__c);
			businessLineSet.add(li.Business_Line__c);
		}

		campaignName = allLeadItems[0].Lead__r.Campaign__r.Name;
		intendedCity = allLeadItems[0].Intended_City__c;
		businessLine = allLeadItems[0].Business_Line__c;
		query();
	}

	public void query() {
		leadItems.clear();
		leads.clear();
		Set<Id> leadIds = new Set<Id>();
		Set<Lead_Item__c> allItemSet = new Set<Lead_Item__c>();
		for (Lead_Item__c li :[SELECT Mobile__c, Mobile_Unique_Key__c, 
									  Mobile_Linked_Key__c, Area_Code__c, 
									  Fix_Phone__c, Fix_Phone_Unique_Key__c, 
									  Fix_Phone_Linked_Key__c,
									  Lead_Name__c, Consultation_Mode__c, 
									  Campaign_Id__c, Lead__r.Name, 
									  Lead__r.OwnerId, Status__c, 
									  Lead__r.CreatedDate, Lead__r.Campaign__r.Name, 
									  Lead__r.Consultation_Mode__c, Lead__r.Intended_Office__c, 
									  Lead__r.Description, Intended_City__c, 
									  Business_Line__c, Project__c, 
									  Intended_Country__c, Lead__r.Recommend_Account__c, 
									  Lead__r.Recommend_SA__c, Lead__r.Recommend_User__c, 
									  Lead__r.Customer_Service__c, Lead__r.Extension_Agent__c,
									  Lead__r.OriginCampaign__c
								FROM Lead_Item__c
								WHERE Id IN :allLeadItems]) {

			if (li.Lead__r.Campaign__r.Name == campaignName && 
				li.Intended_City__c == intendedCity && 
				li.Business_Line__c == businessLine) {
				leadItems.add(li);
				leadIds.add(li.Lead__c);
			}

			allItemSet.add(li);
		}

		allLeadItems.clear();
		allLeadItems.addAll(allItemSet);

		leads = [SELECT Name, Gender__c, 
						ID_Type__c, ID_Number__c, 
						Country__c, ProvinceLookup__c, 
						City__c, District__c,
						Birthday__c, Convenient_Time__c, 
						Converted_Account__c, QQ__c, 
						Wechat__c, Email, 
						MobilePhone, Area_Code__c, 
						Phone, Phone_Status__c, 
						Consultation_Mode__c
				 FROM Lead
				 WHERE Id IN :leadIds];
	}

	public PageReference convertLeadItems() {
		Savepoint sp = Database.setSavepoint();

		try {
			Map<String, Id> phoneMapAccountId = Utils.upsertContacts(leads);
			Map<String, Opportunity> keyMapOpportunity = Utils.createKeyMapOpp(phoneMapAccountId, leadItems);
			List<Lead_Item__c> allLinkedItems = Utils.allLinkedItems;
			List<Lead> allLinkedLeads = Utils.allLinkedLeads;
			Utils.updateLeadItems(keyMapOpportunity, allLinkedItems);
			Utils.updateLeads(phoneMapAccountId, allLinkedLeads);
			query();
			return NULL;

		} catch (Exception e) {
			Database.rollback(sp);
			System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
			System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
			return NULL;
		}
	}

	public PageReference gotoAssginOpportunity() {
		return new PageReference('/006');
	}

	public Integer getTotalItemNo() {
		return allLeadItems.size();
	}

	public Integer getConvertedItemNo() {
		Integer i = 0;
		for (Lead_Item__c li :allLeadItems) {
			if (li.Status__c == Constants.LEAD_ITEM_STATUS_CONVERTED_WON_CN || 
				li.Status__c == Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN) {
				i ++;
			}
		}

		return i;
	}

	public Boolean getIsConverted() {
		Boolean isConverted = FALSE;

		if (getTotalItemNo() == 0) {
			isConverted = TRUE;
		}

		for (Lead_Item__c li :leadItems) {
			if (li.Status__c == Constants.LEAD_ITEM_STATUS_CONVERTED_WON_CN || 
				li.Status__c == Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN) {
				IsConverted = TRUE;
				break;
			}
		}

		return isConverted;
	}
}