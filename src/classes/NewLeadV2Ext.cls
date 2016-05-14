/**************************************************************************************************
 * Name: NewLeadV2Ext
 * Object: Lead
 * Purpose: It is used to create / edit lead
 * Requirement:
 * Author: Tcool Ma
 * Create Date: 2015-10-24
 * Modified History:
 * 2016-05-10    Allen    Format the code
 * 2016-05-13    Ray    Fix a English Version's split account bug
***************************************************************************************************/
public with sharing class NewLeadV2Ext {

    public String mode { get; set; } // '1' => new; '2' => edit
    public Lead lead { get; set; }
    public String campaignName { get; set; }
    public String mPhone { get; set; }
    public String phoneNumber { get; set; }
    public String campaignId { get; set; }
    public String recommendAccountName { get; set; }
    public String recommendAccountId { get; set; }
    public String consultationMode { get; set; }
    public String mobilePhoneEditable { get; set; }
    public String areaCodeEditable { get; set; }
    public String phoneEditable { get; set; }
    public Boolean hasError { get; set; }
    public Boolean editable { get; set; }
    public Boolean canChooseCooperativeEducation { get; set; }
    public Boolean dupliByOldrecommend{ get; set; }
    public String referralType{get;set;}
    private String duplicatedProject = '';
    private String duplicateBL = '';
    private User u;
    private UserRole ur;
    private String leadId;
    private Set<String> uneditableStatusSet = new Set<String> {
        '全部转化',
        '全部转化(到访)'
    };
    public Boolean showTestprep { get; set; }
    public Boolean showCoop { get; set; }
    private ApexPages.StandardController controller;

    public NewLeadV2Ext (ApexPages.StandardController con) {

        hasError = false;
        editable = true;
        canChooseCooperativeEducation = false;
        dupliByOldrecommend = false;
        leadId = ApexPages.currentPage().getParameters().get('id');
        referralType = '';
        mPhone = '';
        phoneNumber ='';
        showCoop = true;
        showTestprep = true;

        // get user and role info
        u = [SELECT ChineseNameofCity__c, Business_Line_Formula__c, Profile.Name
             FROM User
             WHERE Id = :UserInfo.getUserId()
             LIMIT 1];

        for (UserRole role : [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1]) {
            ur = role;
        }

        if (String.isBlank(leadId)) {

            if (ApexPages.currentPage().getParameters().get('isReferral') == null) {
                createLead();

            } else {

                // 集团客服互荐 Customer Referral
                List<Campaign> camps = [SELECT Id, Name
                                        FROM Campaign
                                        WHERE Name = :Constants.CAMP_CUSTOMER_REFERRAL_GROUP_NAME 
                                        AND isActive = true];

                if (camps.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_No_Customer_Referral_Campaign));
                    return;
                }

                mode = '1'; // new
                lead = new Lead();
                Lead.Company = 'EIC';
                lead.Status = '全未转化-新建';
                mPhone = ApexPages.currentPage().getParameters().get('mobile');
                lead.Area_Code__c = ApexPages.currentPage().getParameters().get('areacode');
                phoneNumber = ApexPages.currentPage().getParameters().get('phone');
                lead.Intended_City__c = ApexPages.currentPage().getParameters().get('city');
                lead.LastName = ApexPages.currentPage().getParameters().get('name');
                referralType = ApexPages.currentPage().getParameters().get('referralType');

                if (referralType != '') {
                    campaignId = camps[0].Id;
                    campaignName = camps[0].Name;
                    consultationMode = ApexPages.currentPage().getParameters().get('consultantmode');
                    recommendAccountId = '';
                    recommendAccountName = '';
                }
            }
        } else {
            editLead();
        }

        if (!hasError) {
            mobilePhoneEditable = String.isBlank(lead.MobilePhone) ? '1' : '0';
            areaCodeEditable = String.isBlank(lead.Area_Code__c) ? '1' : '0';
            phoneEditable = String.isBlank(lead.Phone) ? '1' : '0';
        }
    }

    // create lead
    private void createLead () {
        mode = '1'; // new
        lead = new Lead();
        Lead.Company = 'EIC';
        lead.Status = '全未转化-新建';

        // values from Live 800
        mPhone = ApexPages.currentPage().getParameters().get('mobile');
        phoneNumber = ApexPages.currentPage().getParameters().get('phone');
        lead.Area_Code__c = ApexPages.currentPage().getParameters().get('areacode');
        lead.Intended_City__c = ApexPages.currentPage().getParameters().get('city');
        lead.LastName = ApexPages.currentPage().getParameters().get('name');

        // intended city
        if (String.isBlank(lead.Intended_City__c)) {
            if (u.ChineseNameofCity__c == '集团' || u.ChineseNameofCity__c == 'N/A') {
                lead.Intended_City__c = '';

            } else {
                lead.Intended_City__c = u.ChineseNameofCity__c;
            }
        }

        String project = ApexPages.currentPage().getParameters().get('project');
        if (String.isNotBlank(project)) {

            List<String> businessLines = new List<String>();
            if (project.contains('留学')) {
                businessLines.add('留学');
                lead.Is_Counselling__c = true;
            }
            if (project.contains('考培')) {
                businessLines.add('考培');
                lead.Is_TestPrep__c = true;
            }
            if (project.contains('合作办学')) {
                businessLines.add('合作办学');
                lead.Is_Cooperative_Education__c = true;
            }
            lead.Business_Line__c = String.join(businessLines, ';');
        }
        campaignId = '';
        campaignName = '';
        consultationMode = '';
        recommendAccountId = '';
        recommendAccountName = '';
    }

    // edit lead
    private void editLead() {

        mode = '2'; // edit
        for (Lead l : [SELECT  LastName, FirstName, Name, Followup_Result__c, MobilePhone, Intended_City__c, Area_Code__c,
                              Phone, Campaign__c, Campaign__r.Name, Consultation_Mode__c, Is_Counselling__c, Counselling_Project__c,
                              Is_TestPrep__c, TestPrep_Project__c, Is_Xueyou__c, Xueyou_Project__c,Is_Scholar_Tree__c, Is_NP__c,
                              NP_Project__c, Intended_Office__c, Is_Cooperative_Education__c, Cooperative_Education_Project__c,
                              Recommend_Account__c, Recommend_Account__r.Name, Recommend_User__c, Recommend_SA__c, Country__c,
                              Gender__c, ProvinceLookup__c, Birthday__c, City__c, ID_Type__c, District__c, ID_Number__c,
                              Town__c, QQ__c, College__c, Wechat__c, Education_Level__c, Email, GPA__c, Convenient_Time__c,
                              Grade__c, Description, Schedule_Abroad_Year__c, Status, Other_Product__c, Is_Local__c,
                              StudyTourResource__c, OtherRecommend__c
                      FROM Lead
                      WHERE Id = :leadId]) {

            lead = l;
            mPhone = l.MobilePhone;
            phoneNumber = l.Phone;
        }

        if (lead == null) {

            hasError = true;
            editable = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Lead_does_not_exist_or_has_been_deleted));
            return;
        }else if (uneditableStatusSet.contains(lead.Status) && u.Profile.Name != System.Label.System_Administrator) {

            editable = false;
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Cannot_Edit_Converted_Leads));
            return;
        } else {

            campaignId = lead.Campaign__c;
            campaignName = lead.Campaign__r.Name;
            consultationMode = lead.Consultation_Mode__c;
            recommendAccountId = lead.Recommend_Account__c;
            recommendAccountName = lead.Recommend_Account__r.Name;
        }
    }

    // save lead
    private void saveLead () {

        hasError = false;
        try {
            lead.MobilePhone = mPhone;
            lead.Phone = phoneNumber;

            if (String.isNotBlank(recommendAccountId)) {
                lead.Recommend_Account__c = recommendAccountId;
            }

            if (lead.Is_Counselling__c == true && String.isBlank(lead.Counselling_Project__c) && String.isBlank(lead.Other_Product__c)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_No_Projects_For_Counselling));
            }
            if (lead.Is_TestPrep__c == true && String.isBlank(lead.TestPrep_Project__c)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_No_Projects_For_Testprep));
            }
            if (lead.Is_Cooperative_Education__c == true && String.isBlank(lead.Cooperative_Education_Project__c)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_No_Projects_For_Coop));
            }
            if (lead.Is_Cooperative_Education__c == true && !Constants.COOPERATIVE_EDUCATION_CITIES.contains(lead.Intended_City__c)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Not_Coop_City));
            }
            if (lead.Is_TestPrep__c == true && !Constants.TESTPREP_CITIES.contains(lead.Intended_City__c)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Not_Testprep_City));
            }
            if (String.isNotBlank(campaignId)) {
                lead.Campaign__c = campaignId;
            }

            if (hasError) {
                return;
            }

            lead.Consultation_Mode__c = consultationMode;

            if (mode == '1') {
                insert lead;

            } else {
                update lead;
            }

            // create task for Live800
            String calllogId = ApexPages.currentPage().getParameters().get('CallLogId');
            if (String.isNotBlank(calllogId)) {

                CallLog_History__c ch = new CallLog_History__c();
                ch.Type__c = '呼入';
                ch.CallLogId__c = CallLogId;
                ch.Lead__c = lead.Id;
                ch.Result__c = '';
                insert ch;
            }
        } catch (DmlException dmlex) {

            String errorMsg = dmlex.getDmlMessage(0);
            if (errorMsg.contains(System.Label.Error_Duplicate_Lead ) && recommendAccountId != '' && errorMsg.contains('商机')) {

                dupliByOldrecommend = true;
                duplicatedProject = errorMsg.substring(errorMsg.indexOf('[') + 1, errorMsg.indexOf(']'));
                duplicateBL = errorMsg.contains('留学') ? 'Counselling' : 
                              errorMsg.contains('考培') ? 'TestPrep' :
                              errorMsg.contains('合作办学') ? 'CooperativeEducation' : 'other';
                errorMsg = '<a href=\'' + gotoduplicatePhoneAccount() + '\'>' + '拆分客户</a>';
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMsg));
            hasError = true;
            return;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));

            hasError = true;
            return;
        }
    }

    // save
    public PageReference save () {
        saveLead();
        if (hasError) {
            return null;
        }
        return new PageReference('/' + lead.Id);
    }

    public void clearProjectsAndCheckCities () {

        String city = ApexPages.CurrentPage().getParameters().get('city');
        showTestprep = Constants.TESTPREP_CITIES.contains(city);
        showCoop = Constants.COOPERATIVE_EDUCATION_CITIES.contains(city);
        lead.Is_TestPrep__c = false;
        lead.Is_Cooperative_Education__c = false;
        lead.Is_Counselling__c = false;
        clearCounselling();
        clearTestPrepProject();
        clearCooperativeEducation();
    }

    public void clearCounselling() {
        lead.Counselling_Project__c = '';
        lead.Other_Product__c = '';
    }

    public void clearTestPrepProject() {
        lead.TestPrep_Project__c = '';
    }

    public void clearCooperativeEducation() {
        lead.Cooperative_Education_Project__c = '';
    }

    // cancel
    public PageReference cancel() {

        String returnUrl = ApexPages.currentPage().getParameters().get('retURL');
        if (String.isNotBlank(returnUrl)) {
            return new PageReference(returnUrl);

        } else {
            return new PageReference('/00Q');
        }
    }

    // get follow up result setting by user role maintained in custom setting
    public String getFollowupResultSetting() {

        String setting = '';
        for (FollowupResultSetting__c frs : FollowupResultSetting__c.getAll().values()) {
            if (ur != null && ur.Name.contains(frs.Name)) {
                setting = frs.Permission__c;
                break;
            }
        }
        return setting;
    }

    // get consultation modes by user role maintained in custom setting
    public List<SelectOption> getConsultationModes() {

        List<SelectOption> consultationModeList = new List<SelectOption>();
        Boolean found = false;
        for (ConsultationModeMapping__c cmm : ConsultationModeMapping__c.getAll().values()) {

            if ((cmm.Role_Name__c != null && ur != null && ur.Name.contains(cmm.Role_Name__c)) ||
                (cmm.profileName__c != null && u.Profile.Name.contains(cmm.ProfileName__c))) {

                found = true;
                consultationModeList.add(new SelectOption(cmm.Consultation_Mode__c, cmm.Consultation_Mode__c));
            }
        }
        if (!found) {

            Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('Lead').getDescribe();
            Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Consultation_Mode__c').getDescribe();

            for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {

                if (pe.getValue() == '史密斯注册') {
                    continue;
                }
                consultationModeList.add(new SelectOption(pe.getValue(), pe.getValue()));
            }
        }
        return consultationModeList;
    }

    public String gotoduplicatePhoneAccount () {

        String returnlink = '/apex/duplicatePhoneAccountCreation?name=' + lead.LastName + 
                            '&mobilephone=' + lead.MobilePhone + 
                            '&phone=' + lead.Phone + 
                            '&areaCode=' + lead.Area_Code__c + 
                            '&recommendAccountId=' + recommendAccountId + 
                            '&recommendAccountName=' + recommendAccountName + 
                            '&campainName=' + campaignName + 
                            '&campaignId=' + campaignId + 
                            '&Intended_City=' + lead.Intended_City__c + 
                            '&consultMode=' + lead.Consultation_Mode__c + 
                            '&Intended_Office=' + lead.Intended_Office__c + 
                            '&Is_Counselling=' + String.valueof(duplicateBL == 'Counselling') + 
                            '&Counselling_project=' + (duplicateBL == 'Counselling' ? duplicatedProject : '') + 
                            '&Is_TestPrep=' + String.valueof(duplicateBL == 'TestPrep') + 
                            '&TestPrep_Project=' + (duplicateBL == 'TestPrep' ? duplicatedProject : '') + 
                            '&Is_Cooperative_Education=' + String.valueof(duplicateBL == 'Cooperative') + 
                            '&Cooperative_Education_Project=' + (duplicateBL == 'Cooperative' ? duplicatedProject : '') + 
                            '&Is_Scholar_Tree=' + lead.Is_Scholar_Tree__c + 
                            '&Is_Cooperative_Education=' + lead.Is_Cooperative_Education__c;

        System.debug('LoggingLevel.INFO, *** returnlink: ' + returnlink);
        return returnlink;
    }
}