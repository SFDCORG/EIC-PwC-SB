/**************************************************************************************************
 * Name: DuplicatePhoneAccountCls
 * Object: Lead
 * Purpose: Save duplicated phone Accounts into System
            Update the old accounts' contact as emergency Account
            Automatically generates Accounts and contacts
 * Author: Ray Cen
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public without sharing class DuplicatePhoneAccountCls {

    public LeadWrapper leadw { get; set; }
    public Account  duplicatedAccount { get; set; }
    private List<Lead_Item__c> items = new List<Lead_Item__c> ();

    public DuplicatePhoneAccountCls(ApexPages.StandardController controller) {

        leadw = new LeadWrapper ();
        leadw.leadz = new lead ();
        duplicatedAccount = new Account ();
        initilzation();
        String contat = leadw.leadz.MobilePhone == null ?
                        leadw.leadz.Area_Code__c + leadw.leadz.Phone :
                        leadw.leadz.MobilePhone;
        List<Account> accs = [SELECT Name 
                              FROM Account 
                              WHERE Id IN (SELECT Account__c 
                                           FROM Contact_EIC__c 
                                           WHERE UniqueContact__c = :contat)];

        if (accs.size() > 0) {

            duplicatedAccount = accs[0];
        }
    }

    // Saves the split results
    public PageReference saveResult () {

        // Sets a roll back point, when error happened, can be rolled back.
        System.Savepoint sp = Database.setSavepoint();

        // Updates the existing account's contact
        if (updateExistingContactNum() == 'success') {

            Lead ld = GenerateLead();
            if (ld != null ) {

                // Generates the account 
                Account acc = autoGenerateAccount(ld);
                autoGenerateContatct(ld, acc);

                // Generates the opportunities
                Opportunity opp = autoGenereteOpportunity(acc, ld, items[0]);
                updateLeadandLeadItem(items[0], ld, acc, opp);

                // Go to new opportunity assign page
                return new PageReference('/apex/OpportunitiesAssignPage?ID=' + opp.id);

            } else {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                     '线索存在重复意向或者商机，拆分失败！'));
                Database.rollback(sp); 
                return null;
            }
        }

        Database.rollback(sp); 
        return null;
    }

    public PageReference cancel () {

        return new PageReference ('/00Q');
    }

    // Updates existing Contact number as Emergency type number
    private String updateExistingContactNum() {

        String leadphone = leadw.leadz.MobilePhone != null ?
                           leadw.leadz.MobilePhone :
                           leadw.leadz.Area_Code__c + leadw.leadz.phone;

        List<Contact_EIC__c> contat = [SELECT UniqueContact__c,
                                              Account__c,
                                              Account__r.Is_Emergency__c,
                                              Encryped_Phone__c,
                                              Contact_Type__c
                                       FROM Contact_EIC__c
                                       WHERE UniqueContact__c = :leadphone];

        if (contat.size() > 0) {

            contat[0].UniqueContact__c = contat[0].UniqueContact__c + ' [E]';
            contat[0].isEmergency__c = true;
            contat[0].Contact_Type__c = '紧急联系方式';

            try {

                update contat[0];
                ChangeLogRelated.CreateContactChangeLog('更改紧急联系方式', contat[0], contat[0]);
                Account acc = new Account ();
                acc.Id = contat[0].Account__c;
                acc.Is_Emergency__c = true;
                update acc;

                return 'success';
            } Catch(Exception e) {

                ApexPages.addMessages(e);
                return 'fault';
            }
        }
        return 'success';
    }

    // Generates new lead for the new account
    private Lead GenerateLead () {

        Lead lead = new Lead (Lastname = leadw.leadz.LastName,
                              Campaign__c = leadw.leadz.Campaign__c,
                              Consultation_Mode__c = leadw.leadz.Consultation_Mode__c,
                              Intended_City__c = leadw.leadz.Intended_City__c,
                              Intended_Office__c = leadw.leadz.Intended_Office__c,
                              Is_Counselling__c = leadw.leadz.Is_Counselling__c,
                              Counselling_Project__c = leadw.leadz.Counselling_Project__c,
                              Is_TestPrep__c = leadw.leadz.Is_TestPrep__c,            
                              Is_NP__c = leadw.leadz.Is_NP__c,
                              TestPrep_Project__c  = leadw.leadz.TestPrep_Project__c,
                              Is_Scholar_Tree__c = leadw.leadz.Is_Scholar_Tree__c,
                              Is_Cooperative_Education__c = leadw.leadz.Is_Cooperative_Education__c,
                              Company = 'EIC',
                              Status = '已转化',
                              OwnerId = UserInfo.getUserId(),
                              Mobilephone = leadw.leadz.MobilePhone,
                              Area_Code__c = leadw.leadz.Area_Code__c,
                              Phone = leadw.leadz.Phone,
                              Recommend_Account__c = leadw.leadz.Recommend_Account__c);
        Utils.runLeadTrigger = false;
        insert lead;
        List<lead> leads = new List<lead> ();
        leads.add(lead);

        // Split the lead to lead items
        items = SplitLeadUtils.splitLead(leads);

        // update some lead items to "市场活动内重复","不能创建, 已存在未关闭商机！", "不能创建, 已存在已赢单商机！"; 
        // Notify the opportunity owner
        items = SplitLeadUtils.checkAccOppNotifyOwner(items, leads);

        // Update some rest lead items to "不能创建, 已存在未转化线索!", "新建"
        items = SplitLeadUtils.checkLead(items);
        if (items[0].Status__c != '新建') {

            return null;
        } else {

            items[0].Status__c = '关闭--转化商机成功';
            insert items;
        }
        return lead;
    }

    // Auto Generates Contacts
    private void  autoGenerateContatct (lead ld, Account acc) {

        List<Contact_EIC__c> conts = new List<Contact_EIC__c> ();

        if (ld.MobilePhone!=null) {

            Contact_EIC__c contat = new Contact_EIC__c ();
            contat.Account__c = acc.Id;
            contat.Name = acc.Name;
            contat.Relationship__c = '客户本人';
            contat.UniqueContact__c = ld.mobilephone;
            contat.Contact_Type__c = '手机';
            conts.add(contat);
        }

        if (ld.Phone != null && ld.Area_Code__c != null) {

            Contact_EIC__c contat2 = new Contact_EIC__c ();
            contat2.Account__c = acc.Id;
            contat2.Name = acc.Name;
            contat2.Relationship__c = '客户本人';
            contat2.UniqueContact__c =ld.Area_Code__c + ld.Phone;
            contat2.Contact_Type__c = '座机';
            conts.add(contat2);
        }

        try {

            Insert conts;
        } Catch(Exception e) {

             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '已存在相同紧急联系方式客户,拆分失败！'));
        }
    }

    // Auto Generates Opportunity for new account
    private Opportunity autoGenereteOpportunity (Account acc, Lead ld, Lead_Item__c li) {

        Id oppRTId;
        if (ld.Is_Counselling__c) {

            oppRTId = RecordTypeRelated.Counselling_Opp;
        } else if (ld.Is_TestPrep__c) {

            oppRTId = RecordTypeRelated.TestPrep_Opp;
        }

        Opportunity opp = new Opportunity (
            Name = acc.Name + ld.Intended_City__c + li.Business_Line__c  + li.Project__c + '商机',
            AccountId = acc.Id,
            CloseDate = System.Today() + 30,
            Intended_City__c = ld.Intended_City__c,
            Intended_Office__c = ld.Intended_Office__c == 'null' ? '' : ld.Intended_Office__c,
            Project__c = li.Project__c,
            Consultation_Mode__c = ld.Consultation_Mode__c,
            StageName = '待分配',
            Marketing_Channel_Lv3__c = ld.Marketing_Channel_Lv3__c,
            Level_4_Promotion_Channel__c = ld.Campaign__c,
            RecordTypeId = oppRTId);

        insert opp;
        return opp;
    }

    private Account autoGenerateAccount (Lead ld) {

        Account newAcc = new Account(Name = ld.LastName,
                                     RecordTypeId = Utils.getRecordTypeId('Account', 'EIC Account'));
        insert newAcc;
        return newAcc;
    }

    // Generates lead items according to lead projects
    private void updateLeadandLeadItem (Lead_Item__c li, Lead ld, Account acc, Opportunity opp) {

        ld.Converted_Account__c = acc.Id;
        li.Opportunity__c = opp.Id;
        update li;
        update ld;
    }

    public Class LeadWrapper {

        public String oldAccountName { get; set; }
        public String campainName { get; set; }
        public Lead leadz { get; set; }
    }

    // Generate the new lead by parameters
    private void initilzation () {

        leadw.leadz.LastName = ApexPages.currentPage().getParameters().get('name');
        leadw.leadz.Campaign__c = ApexPages.currentPage().getParameters().get('campaignId');
        leadw.campainName = ApexPages.currentPage().getParameters().get('campainName');
        leadw.leadz.MobilePhone = ApexPages.currentPage().getParameters().get('mobilephone');
        leadw.leadz.Phone = ApexPages.currentPage().getParameters().get('phone');
        leadw.leadz.Area_Code__c = ApexPages.currentPage().getParameters().get('areaCode');
        leadw.leadz.Consultation_Mode__c = ApexPages.currentPage().getParameters().get('consultMode');
        leadw.leadz.Recommend_Account__c = ApexPages.currentPage().getParameters().get('recommendAccountId');
        leadw.oldAccountName = ApexPages.currentPage().getParameters().get('recommendAccountName');
        leadw.leadz.Is_Counselling__c = ApexPages.currentPage().getParameters().get('Is_Counselling') == 'true';
        leadw.leadz.Counselling_Project__c = ApexPages.currentPage().getParameters().get('Counselling_project');
        leadw.leadz.Is_TestPrep__c = ApexPages.currentPage().getParameters().get('Is_TestPrep') == 'true';
        leadw.leadz.TestPrep_Project__c = ApexPages.currentPage().getParameters().get('TestPrep_Project');
        leadw.leadz.Is_NP__c = ApexPages.currentPage().getParameters().get('Is_NP') == 'true';
        leadw.leadz.Is_Scholar_Tree__c = ApexPages.currentPage().getParameters().get('Is_Scholar_Tree') == 'true';
        leadw.leadz.Is_Cooperative_Education__c = ApexPages.currentPage().getParameters().get('Is_Cooperative_Education') == 'true';
        leadw.leadz.Intended_City__c = ApexPages.currentPage().getParameters().get('Intended_City');
        leadw.leadz.Intended_Office__c = ApexPages.currentPage().getParameters().get('Intended_Office');
        leadw.leadz.TestPrep_Project__c = leadw.leadz.TestPrep_Project__c == 'null' ? null : leadw.leadz.TestPrep_Project__c;
        leadw.leadz.Counselling_Project__c = leadw.leadz.Counselling_Project__c == 'null' ? null : leadw.leadz.Counselling_Project__c;
        leadw.leadz.Phone = leadw.leadz.Phone == 'null' ? null : leadw.leadz.Phone;
        leadw.leadz.MobilePhone = leadw.leadz.MobilePhone == 'null' ? null : leadw.leadz.MobilePhone;
        leadw.leadz.Area_Code__c = leadw.leadz.Area_Code__c == 'null' ? null : leadw.leadz.Area_Code__c;
    }
}