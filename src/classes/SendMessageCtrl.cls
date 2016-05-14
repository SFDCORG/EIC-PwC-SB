/**************************************************************************************************
 * Name: SendMessageCtrl
 * Object: Lead
 * Purpose: It is used to send message by YunPian
 * Requirement: 
 * Author: Tcool Ma
 * Create Date: 2015-10-24
 * Modified History:

***************************************************************************************************/
public without sharing class SendMessageCtrl {
    public SMS_Template__c smsTemplateLookup { get; set; }
    public String smsBodyWithValue { get; set; }
    public Boolean isShowButton { get; set; }
    public String smsStatusCode { get; set; }
    public String sObjectName {get; set;}
    public String recordId {get; set;}
    public String accountName {get; set;}
    public Boolean hasError {get; set;}
    public String selectedPhone {get;set;}

    public String firstLevel { get; set; }
    public List<SelectOption> firstLevelItemList { get; set; }
    public String secondLevel { get; set; }
    public List<SelectOption> secondLevelItemList { get; set; }
    public String thirdLevel { get; set; }
    public List<SelectOption> thirdLevelItemList { get; set; }
    public String fourthLevel { get; set; }
    public List<SelectOption> fourthLevelItemList { get; set; }

    public List<SMSTemplateWrapper> smsTemplateWrapperList { get; set; }
    public List<SMSTemplateWrapper> displayedSMSTemplateWrapperList { get; set; }
    public List<ContactWrapper> contactList {get; set;}

    private String prefix;
    private Set<String> relatedToObjectSet = new Set<String> {'All'};

    public SendMessageCtrl() {
        hasError = false;
        selectedPhone='';
        recordId = ApexPages.currentPage().getParameters().get('id');
        sObjectName = ApexPages.currentPage().getParameters().get('so');
        User u = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
        if (String.isNotBlank(recordId) && String.isNotBlank(sObjectName)) {
            if (sObjectName == 'Account') {
                relatedToObjectSet.add('客户');
                Account account = [
                    SELECT  Name
                    FROM    Account
                    WHERE   Id = :recordId];
                accountName = account.Name;                    
                getAccountPhones(recordId);
            }else if (sObjectName == 'Lead') {
                relatedToObjectSet.add('销售线索');
                Lead lead = [
                    SELECT  MobilePhone,
                            Name
                    FROM    Lead 
                    WHERE   Id = :recordId];
                accountName = lead.Name;                    
                contactList = new List<ContactWrapper>();
                contactList.add(new ContactWrapper(lead.Id, lead.Name, lead.MobilePhone, lead.MobilePhone, true));
            }else if (sObjectName == 'Opportunity') {
                relatedToObjectSet.add('商机');
                Opportunity opp = [
                    SELECT  AccountId,
                            Account.Name
                    FROM    Opportunity 
                    WHERE   Id = :recordId];
                accountName = opp.Account.Name;
                getAccountPhones(opp.AccountId);
            }

            smsTemplateLookup = new SMS_Template__c();

            firstLevelItemList = new List<SelectOption>();
            secondLevelItemList = new List<SelectOption>();
            thirdLevelItemList = new List<SelectOption>();
            fourthLevelItemList = new List<SelectOption>();

            smsTemplateWrapperList = new List<SMSTemplateWrapper>();
            displayedSMSTemplateWrapperList = new List<SMSTemplateWrapper>();
            
            firstLevel = '--无--';
            firstLevelItemList.add(new SelectOption('--无--', '--无--'));

            isShowButton = false;

            Set<String> firstLevelSet = new Set<String>();

            for(SMS_Template__c sms : [
                    SELECT  Name,
                            First_Level__c,
                            Second_Level__c,
                            Third_Level__c,
                            Fourth_Level__c,
                            SMS_Body__c
                    FROM    SMS_Template__c
                    WHERE   Related_To__c IN :relatedToObjectSet
                    AND     Active__c = true
                    ORDER BY First_Level__c, Second_Level__c, Third_Level__c, Fourth_Level__c, Name]) {
                if (String.isNotBlank(sms.First_Level__c)) {
                    firstLevelSet.add(sms.First_Level__c);
                }
                smsTemplateWrapperList.add(new SMSTemplateWrapper(sms));
            }

            displayedSMSTemplateWrapperList.addAll(smsTemplateWrapperList);

            for(String fl : firstLevelSet) {
                firstLevelItemList.add(new SelectOption(fl, fl));
            }

            firstLevelItemList.size();
        }
    }

    // Controls the first level select options
    public void queryByFirstLevel() {
        displayedSMSTemplateWrapperList.clear();
        smsTemplateLookup = new SMS_Template__c();
        secondLevelItemList.clear();
        thirdLevelItemList.clear();
        fourthLevelItemList.clear();
        smsBodyWithValue = '';

        displayedSMSTemplateWrapperList.addAll(smsTemplateWrapperList);

        if (firstLevel == '--无--') return;

        // Removes the SMS template record from the showing list if the first level is not matched.
        Integer j = 0;
        for (Integer i = 0; i < smsTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = smsTemplateWrapperList[i].smsTemplate;
            if (sms.First_Level__c != firstLevel) {
                displayedSMSTemplateWrapperList.remove(i - j);
                j ++;
            }
        }

        secondLevelItemList.add(new SelectOption('--无--', '--无--'));

        // Adds its dependent second level values.
        Set<String> secondLevelSet = new Set<String>();
        for (Integer i = 0; i < displayedSMSTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = displayedSMSTemplateWrapperList[i].smsTemplate;
            if (String.isNotBlank(sms.Second_Level__c)) {
                secondLevelSet.add(sms.Second_Level__c); 
            }
        }

        for(String sl : secondLevelSet) {
            secondLevelItemList.add(new SelectOption(sl, sl));
        }

        secondLevelItemList.sort();
    }

    // Controls the second level select options
    public void queryBySecondLevel() {
        displayedSMSTemplateWrapperList.clear();
        smsTemplateLookup = new SMS_Template__c();
        thirdLevelItemList.clear();
        fourthLevelItemList.clear();
        smsBodyWithValue = '';

        //if (secondLevel == '--无--') return;

        displayedSMSTemplateWrapperList.addAll(smsTemplateWrapperList);

        // Removes the SMS template record from the showing list if the second level is not matched.    
        Integer j = 0;        
        for (Integer i = 0; i < smsTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = smsTemplateWrapperList[i].smsTemplate;
            if (sms.First_Level__c != firstLevel || sms.Second_Level__c != secondLevel) {
                displayedSMSTemplateWrapperList.remove(i - j);
                j ++;
            }
        }

        thirdLevelItemList.add(new SelectOption('--无--', '--无--'));

        // Adds its dependent third level values.
        Set<String> thirdLevelSet = new Set<String>();
        for (Integer i = 0; i < displayedSMSTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = displayedSMSTemplateWrapperList[i].smsTemplate;
            if (String.isNotBlank(sms.Third_Level__c)) {
                thirdLevelSet.add(sms.Third_Level__c); 
            }
        }

        for(String tl : thirdLevelSet) {
            thirdLevelItemList.add(new SelectOption(tl, tl));
        }

        thirdLevelItemList.sort(); 
    }

    // Controls the third level select options
    public void queryByThirdLevel() {
        displayedSMSTemplateWrapperList.clear();
        smsTemplateLookup = new SMS_Template__c();
        fourthLevelItemList.clear();
        smsBodyWithValue = '';

        //if (thirdLevel == '--无--') return;

        displayedSMSTemplateWrapperList.addAll(SMSTemplateWrapperList);

        // Removes the SMS template record from the showing list if the third level is not matched.          
        Integer j = 0;
        for (Integer i = 0; i < SMSTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = smsTemplateWrapperList[i].smsTemplate;
            if (sms.Second_Level__c != secondLevel || sms.Third_Level__c != thirdLevel) {
                displayedSMSTemplateWrapperList.remove(i - j);
                j ++;
            }
        }
        
        fourthLevelItemList.add(new SelectOption('--无--', '--无--'));

        // Adds its dependent fourth level values.
        Set<String> fourthLevelSet = new Set<String>();
        for (Integer i = 0; i < displayedSMSTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = displayedSMSTemplateWrapperList[i].smsTemplate;
            if (String.isNotBlank(sms.Fourth_Level__c)) {
                fourthLevelSet.add(sms.Fourth_Level__c); 
            }
        }

        for(String fl : fourthLevelSet) {
            fourthLevelItemList.add(new SelectOption(fl, fl));
        }

        fourthLevelItemList.sort(); 
    }
    
    // Controls the fourth level select options
    public void queryByFourthLevel() {
        displayedSMSTemplateWrapperList.clear();
        smsTemplateLookup = new SMS_Template__c();
        smsBodyWithValue = '';

        //if (fourthLevel == '--无--') return;

        displayedSMSTemplateWrapperList.addAll(SMSTemplateWrapperList);

        // Removes the SMS template record from the showing list if the fourth level is not matched.
        Integer j = 0;        
        for (Integer i = 0; i < SMSTemplateWrapperList.size(); i ++) {
            SMS_Template__c sms = smsTemplateWrapperList[i].smsTemplate;
            if (sms.Third_Level__c != thirdLevel || sms.Fourth_Level__c != fourthLevel) {
                displayedSMSTemplateWrapperList.remove(i - j);
                j ++;
            }
        }    
    }

    // search SMS template by name
    public void lookupTemplate() {
        firstLevel = '--无--';

        secondLevelItemList.clear();
        thirdLevelItemList.clear();
        fourthLevelItemList.clear();
        displayedSMSTemplateWrapperList.clear();

        try {
            smsTemplateLookup = [
                    SELECT  Name,
                            First_Level__c,
                            Second_Level__c,
                            Third_Level__c,
                            Fourth_Level__c,
                            SMS_Body__c,
                            SMS_Template__c
                    FROM    SMS_Template__c
                    WHERE   Id = :smsTemplateLookup.SMS_Template__c
                    AND     Related_To__c IN :relatedToObjectSet
                    AND     Active__c = true];
            smsTemplateLookup.SMS_Template__c = smsTemplateLookup.Id;
            displayedSMSTemplateWrapperList.add(new SMSTemplateWrapper(smsTemplateLookup, true));
            updateSMSBody();
        } catch(Exception e) {
            isShowButton = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '您只能选择相关项为"学员"的短信模板!'));
        }
    }

    // parse message
    public void updateSMSBody() {
        try {
            isShowButton = true;
            smsBodyWithValue = Utils.replaceMergeField(smsTemplateLookup.SMS_Body__c, sObjectName, recordId);
        } catch (NullPointerException nullex) {
            isShowButton = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '无法解析您输入的相关项对应的字段, 请检查\'{ }\'的内容格式!'));
        } catch (Exception e) {
            isShowButton = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '短信模板解析错误, 请检验短信模板变量格式!'));
        }
    }

    // send message
    public void sendMessage() {
        SMS__c sms = SMS__c.getAll().get('SendMessage');
        if (sms != null) {
            if (String.isBlank(smsBodyWithValue)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '短信发送失败!'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '短信模板内容不能为空！'));
                return;
            }
            String phone = '';

            for(ContactWrapper c : contactList) {
                if (c.isSelected == true && String.isNotBlank(c.mobile)) {
                    phone = c.mobile + ',';
                }
            }
            if (String.isNotBlank(phone)) {
                phone = phone.substring(0, phone.length() - 1);
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '短信发送失败!'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '电话号码不能为空！'));
                return;
            }

            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');
            req.setHeader('Accept', 'application/json;charset=utf-8');
            req.setEndpoint(sms.Endpoint__c);
            req.setBody('apikey=' + sms.APIKEY__c + '&text=' + smsBodyWithValue + '&mobile=' + phone);
            req.setTimeout(120000);
            req.setMethod('POST');

            HttpResponse res = h.send(req);

            if (res.getStatusCode() == 200) {
                System.debug(LoggingLevel.INFO, '*** res.getBody(): ' + res.getBody());
                Object obj = JSON.deserializeUntyped(res.getBody());
                String objStr = JSON.serialize(obj);
                Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(objStr);

                String msg = String.valueOf(objMap.get('msg'));
                if (msg == 'OK') {
                    smsStatusCode = '0';
                    logHistory(phone, smsBodyWithValue);
                }else {
                    smsStatusCode = '-1';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '短信发送失败!'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
                    return;
                }
            }else {
                smsStatusCode = '-1';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '短信发送失败!'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, res.getBody()));
                return;
            }
        }else {
            smsStatusCode = '-1';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '短信发送失败!'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '请联系管理员，维护SMS自定义设置!'));
            return;
        }
    }
  
    // create SMS history
    private void logHistory(String phone, String body) {
        SMS_History__c history = new SMS_History__c();
        history.Send_Time__c = Datetime.now();
        history.Sender__c = UserInfo.getUserId();
        history.Receiving_Mobile_Number__c = phone;
        history.Message_Body__c = body;
        if (sObjectName == 'Lead') {
            history.Lead__c = recordId;
        }else if (sObjectName == 'Opportunity') {
            history.Opportunity__c = recordId;
        }
        insert history;
    }

    // get contacts by account id
    private void getAccountPhones(String accountId) {
        contactList = new List<ContactWrapper>();
        for(Contact_EIC__c c : [
                SELECT  Name,
                        Encryped_Phone__c,
                        Unique_Contact__c,
                        IsPrimary__c,
                        IsInvalid__c,
                        Account__c
                FROM    Contact_EIC__c 
                WHERE   Account__c = :accountId
                AND     Contact_Type__c IN ('手机', 'mig_type')
                AND     IsInvalid__c = false]) {
            contactList.add(new ContactWrapper(c.Account__c, c.Name, c.Encryped_Phone__c, c.Unique_Contact__c, c.IsPrimary__c));
        }
    }

    public class SMSTemplateWrapper {
        public SMS_Template__c smsTemplate { get; set; }
        public Boolean isSelected { get; set; }

        public SMSTemplateWrapper(SMS_Template__c smsTemplate) {
            this.smsTemplate = smsTemplate;
            this.isSelected = false;
        }

        public SMSTemplateWrapper(SMS_Template__c smsTemplate, Boolean isSelected) {
            this.smsTemplate = smsTemplate;
            this.isSelected = isSelected;
        }
    }

    public class ContactWrapper {
        public String contactId {get; set;}
        public String contactName {get; set;}
        public String encrypedPhone {get; set;}
        public String mobile {get; set;}
        public Boolean isPrimary {get; set;}
        public Boolean isSelected { get; set; }

        public ContactWrapper(String contactId, String contactName, String encrypedPhone, String mobile, Boolean isPrimary) {
            this.contactId = contactId;
            this.contactName = contactName;
            this.encrypedPhone = encrypedPhone;
            this.mobile = mobile;
            this.isPrimary = isPrimary;
            this.isSelected = isPrimary;
        }
    }

    public PageReference refreshPhoneSection() {  
        for (ContactWrapper cont : contactList) {    
            cont.isSelected = cont.mobile == selectedPhone;    
        }

        return null;
    }
}