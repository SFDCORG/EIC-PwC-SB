/**************************************************************************************************
 * Name: ResourceExchangeController
 * Object: Lead, Lead_Item__c, Opportunity
 * Purpose: Create leads according to lead / opportunity business line
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-07
 * Modified History: 
 * 2016-05-07    Vicia Wang    Writes comments in this format and formats the class
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public without sharing class ResourceExchangeController {

    public String selectedCounsellingOppProject { get; set; }
    public String selectedTestprepOppProject { get; set; }
    public String selectedCooperativeOppProject { get; set; }
    public String selectedNewBusinessLine { get; set; }
    public String selectedIntendCity { get; set; }
    public String selectedProject { get; set; }
    public String selectedOppStage { get; set; }
    public String selectedConsultMode { get; set; }
    public Lead filterLead { get; set; }
    public Map<String, ID> rmap  { get; set; }
    public List<AccountWrap> testprepAcctWraps { get; set; }
    public List<AccountWrap> counsellingAcctWraps { get; set; }
    public List<AccountWrap> cooperativeAcctWraps { get; set; }
    public List<AccountWrap> acctWraps { get; set; }
    public Set<Id> accountIds { get; set; }
    public List<AccountWrap> show { get; set; }
    public List<errorWrap> errors { get; set; }
    public List<SelectOption> marketingChannelLv1List { get; set; }
    public List<SelectOption> marketingChannelLv2List { get; set; }
    public List<SelectOption> marketingChannelLv3List { get; set; }
    public Map<String, Set<String>> lv1Lv2Map  { get; set; }
    public Map<String, Set<String>> lv1Lv2Lv3Map  { get; set; }
    public String lv1 { get; set; }
    public String lv2 { get; set; }
    public String lv3 { get; set; }
    public String selectedCampaignSource { get; set; }
    public String selectedHtmlCampaignSource { get; set; }
    public Boolean hasCounsellingOpps { get; set; }
    public Boolean hasTestprepOpps { get; set; }
    public Boolean hasCooperativeOpps { get; set; }
    public String selectedInOrEx { get; set; }

    Integer offSet = 0;
    Integer total = 0;
    Integer currentPageNo = 1;
    public String pageRecord { get; set; }
    public Boolean issuccess { get; set; }

    // Multiple picklist values
    public class SelectItem{
        public String name { get; set; }
        public String val { get; set; }
    }


    // 3-digital area code
    public Set<String> areas = new Set<String> (new List<String> {'010',
                                                                  '021',
                                                                  '022',
                                                                  '023',
                                                                  '024',
                                                                  '025',
                                                                  '027',
                                                                  '028',
                                                                  '029',
                                                                  '020'});

    public ResourceExchangeController() {
        issuccess = FALSE;
        selectedCounsellingOppProject = '';
        selectedTestprepOppProject = '';
        selectedCooperativeOppProject = '';
        selectedNewBusinessLine = '';
        selectedIntendCity = '';
        selectedProject = '';
        selectedOppStage = '';
        selectedConsultMode = '';
        filterLead = new Lead();
        List<RecordType> rs = [SELECT Name, DeveloperName 
                               FROM RecordType 
                               WHERE SobjectType = 'Opportunity' 
                               AND IsActive = TRUE];

        rmap = new Map<String, Id>();
        for (RecordType r : rs) {
            rmap.put(r.DeveloperName, r.Id);
        }

        testprepAcctWraps = new List<AccountWrap>();
        counsellingAcctWraps = new List<AccountWrap>();
        cooperativeAcctWraps = new List<AccountWrap>();
        acctWraps = new List<AccountWrap>();
        show = new List<AccountWrap>();
        pageRecord = '25';

        lv1 = '';
        lv2 = '';
        lv3 = '';
        selectedCampaignSource = '';
        selectedHtmlCampaignSource = '';

        getCampaignChannels();
        hasCounsellingOpps = FALSE;
        hasTestprepOpps = FALSE;
        hasCooperativeOpps = FALSE;
    }

    // 咨询方式多选项
    public List<String> getConsultMode() {
        List<String> ss = selectedConsultMode.split(',');
        Schema.DescribeFieldResult F = Lead.Consultation_Mode__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry i : p) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i.getValue()) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i.getValue());
            }
        }
        return options;
    }


    public List<String> getCounsellingOppProjectList() {

        List<String> ss = selectedCounsellingOppProject.split(',');

        List<String> vals = new List<String>();
        List<Schema.PicklistEntry> counsellingProjects = Lead.Counselling_Project__c.getDescribe().getPicklistValues();
        for ( Schema.PicklistEntry project : counsellingProjects) {
            vals.add(project.getLabel());
        }
        List<String> options = new List<String>();
        for (String i : vals) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i);
            }
        }
        return options;
    }

    public List<String> getTestprepOppProjectList() {
        List<String> ss = selectedTestprepOppProject.split(',');

        List<String> vals = new List<String>();
        List<Schema.PicklistEntry> testprepProjects = Lead.Testprep_Project__c.getDescribe().getPicklistValues();
        for ( Schema.PicklistEntry project : testprepProjects) {
            vals.add(project.getLabel());
        }
        List<String> options = new List<String>();
        for (String i : vals) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i);
            }
        }
        return options;
    }

    public List<String> getCooperativeOppProjectList() {
        List<String> ss = selectedCooperativeOppProject.split(',');

        List<String> vals = new List<String>();
        List<Schema.PicklistEntry> cooperativeProjects = Lead.Cooperative_Education_Project__c.getDescribe().getPicklistValues();
        for ( Schema.PicklistEntry project : cooperativeProjects) {
            vals.add(project.getLabel());
        }
        List<String> options = new List<String>();
        for (String i : vals) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i);
            }
        }
        return options;
    }

    public List<String> getBusinessLineList() {
        List<String> ss = selectedNewBusinessLine.split(',');
        List<String> vals = new List<String> { System.Label.Counselling, System.Label.Testprep, System.Label.Cooperative };
        List<String> options = new List<String>();
        for (String i : vals) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i);
            }
        }
        return options;
    }

    public List<SelectOption> getIncOrExcOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Include', System.Label.Include));
        options.add(new SelectOption('Exclude', System.Label.Exclude));
        return options;
    }

    // 市场活动多选项
    public List<SelectItem> getselectedCampaignItems() {

        if (selectedCampaignSource == '') {

            return new List<SelectItem>();
        }
        List<String> vals = selectedCampaignSource.split(',');
        List<String> names = selectedHtmlCampaignSource.split(',');
        List<SelectItem> items = new List<SelectItem>();
        integer i = 0;
        for (String s : vals) {
            SelectItem item = new SelectItem();
            item.name = names[i];
            item.val = vals[i];
            items.add(item);
            i++;
        }

        return items;
    }

    // User has selected consultation values
    public List<String> getSelectedConsultModeVal() {

        if (selectedConsultMode == '') {
            return new List<String>();
        }

        return selectedConsultMode.split(',');
    }

    public List<String> getSelectedCooperativeOppProjectVal() {
        if (selectedCooperativeOppProject == '') {
            return new List<String>();
        }

        return selectedCooperativeOppProject.split(',');
    }

    public List<String> getSelectedCounsellingOppProjectVal() {
        if (selectedCounsellingOppProject == '') {
            return new List<String>();
        }

        return selectedCounsellingOppProject.split(',');
    }

    public List<String> getSelectedTestprepOppProjectVal() {
        if (selectedTestprepOppProject == '') {
            return new List<String>();
        }

        return selectedTestprepOppProject.split(',');
    }

    public List<String> getSelectedNewBusinessLineVal() {
        if (selectedNewBusinessLine == '') {
            return new List<String>();
        }

        return selectedNewBusinessLine.split(',');
    }

    public List<String> getIntendCity() {
        List<String> ss = selectedIntendCity.split(',');
        Schema.DescribeFieldResult F = Lead.Intended_City__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry i : p) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i.getValue()) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i.getValue());
            }
        }

        return options;
    }

    public List<String> getSelectedIntendCityVal() {
        if (selectedIntendCity == '') {
            return new List<String>();
        }

        return selectedIntendCity.split(',');
    }

    public List<String> getProject() {
        List<String> ss = SelectedProject.split(',');
        Schema.DescribeFieldResult F = Lead.Project__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry i : p) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i.getValue()) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i.getValue());
            }
        }

        return options;
    }

    public List<String> getSelectedProjectVal() {
        if (selectedProject == '') {
            return new List<String>();
        }
        return selectedProject.split(',');
    }

    public List<String> getOppStage() {
        List<String> ss = selectedOppStage.split(',');
        Schema.DescribeFieldResult F = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry i : p) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i.getValue()) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i.getValue());
            }
        }
        return options;
    }

    public List<String> getSelectedOppStageVal() {
        if (selectedOppStage == '') {
            return new List<String>();
        }
        return selectedOppStage.split(',');
    }

    public void searchOpp() {
        errors = new List<errorWrap>();
        Datetime starttime = null;
        Datetime endtime = null;
        acctWraps.clear();

        // Validations
        if (!(hasCooperativeOpps || hasCounsellingOpps || hasTestprepOpps)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Choose_One_BL_Opp));
            return;
        }

        if (selectedNewBusinessLine == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_Choose_One_BL_To_Create_Leads));
            return;
        }

        if (selectedNewBusinessLine.contains(System.Label.Testprep) && hasTestprepOpps) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_No_TP_Leads_for_TP_Acc));
            return;
        }

        if (selectedNewBusinessLine.contains(System.Label.Cooperative) && hasCooperativeOpps) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Error_No_Coop_Leads_for_Coop_Acc));
            return;
        }

        // Aggregates all opportunities/accounts
        List<OpportunityInfo> opportunityInfoList = new List<OpportunityInfo>();
        OpportunityInfo oppInfo = new OpportunityInfo();
        if (hasTestprepOpps) {
            oppInfo.recordTypeId = Constants.OPP_RT_TESTPREP_ID;
            oppInfo.projects = selectedTestprepOppProject;
            opportunityInfoList.add(oppInfo);
        }

        if (hasCooperativeOpps) {
            oppInfo.recordTypeId = Constants.OPP_RT_COOPERATIVE_ID;
            oppInfo.projects = selectedCooperativeOppProject;
            opportunityInfoList.add(oppInfo);
        }

        if (hasCounsellingOpps) {
            for (String intendedCountry : selectedCounsellingOppProject.split(',')) {
                oppInfo.recordTypeId = Constants.OPP_RT_COUNSELLING_ID;
                oppInfo.projects = intendedCountry;
                opportunityInfoList.add(oppInfo);
            }
        }

        accountIds = new Set<Id>();
        Boolean firstRun = true;
        for (OpportunityInfo searchInfo : opportunityInfoList) {
            String oppRecordTypeId  = searchInfo.recordTypeId;
            String selectedProjects = searchInfo.projects;
            String queryString = 'SELECT Id, AccountId, RecordTypeId, Intended_City__c, Consultation_Mode__c ' + 
                                 'FROM Opportunity ' + 
                                 'WHERE RecordTypeId = :oppRecordTypeId';

            if (selectedProjects != '') {
                String projects = selectedProjects.replaceAll(',', ';');
                projects = projects.replaceAll('; ', ';');
                queryString += ' AND toLabel(Project__c) = :projects';
            }

            Set<String> citys = new Set<String>();
            if (selectedIntendCity != '') {
                citys = new Set<String> (selectedIntendCity.split(','));
                queryString += ' AND Intended_City__c IN :citys';
            }

            Set<String> stages = new Set<String>();
            if (selectedOppStage != '') {
                stages = new Set<String>(selectedOppStage.split(','));
                queryString +=' AND StageName IN :stages';
            }

            Set<string> campaignIds = new Set<String>();
            if (selectedCampaignSource != '') {
                for (String s : selectedCampaignSource.split(',')) {
                    campaignIds.add(s);
                }
                String includeExclude = '';
                if (selectedInOrEx == 'Exclude') {
                    includeExclude = 'NOT ';
                }
                queryString += ' AND Level_4_Promotion_Channel__c ' + includeExclude + 'IN :campaignIds';
            }

            Set<String> consultationModeSet = new Set<String>();
            if (selectedConsultMode != '') {
                consultationModeSet = new Set<String> (selectedConsultMode.split(','));
                queryString += ' AND Consultation_Mode__c IN :consultationModeSet';
            }

            if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c != null) {
                if (filterLead.Birthday__c > filterLead.Schedule_Abroad_Year__c) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Error_Start_Date_Before_End_Date));
                    return;
                }

                starttime = Datetime.newInstance(filterLead.Birthday__c.year(), 
                                                 filterLead.Birthday__c.month(),
                                                 filterLead.Birthday__c.day(), 
                                                 0, 0, 0);

                endtime = Datetime.newInstance(filterLead.Schedule_Abroad_Year__c.year(), 
                                               filterLead.Schedule_Abroad_Year__c.month(),
                                               filterLead.Schedule_Abroad_Year__c.day(), 
                                               24, 0, 0);

                queryString += ' AND CreatedDate < :endtime AND CreatedDate > :starttime';
            } else if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c == null) {
                starttime = Datetime.newInstance(filterLead.Birthday__c.year(),
                                                 filterLead.Birthday__c.month(),
                                                 filterLead.Birthday__c.day());
                queryString +=' AND CreatedDate > :starttime';

            } else if (filterLead.Birthday__c == null || filterLead.Schedule_Abroad_Year__c != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    System.Label.Error_Entre_valid_date_range));
                return;
            }

            System.debug('LoggingLevel.INFO, *** queryString: ' + queryString);

            List<Opportunity> sourceopps = new List<Opportunity>();

            try{

                sourceopps = Database.query(queryString);
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return;
            }

            Set<Id> accountIdSubset = new Set<Id>();

            for (Opportunity o : sourceopps) {
                accountIdSubset.add(o.AccountId);
            }

            if (firstRun) {
                accountIds = accountIdSubset;
                firstRun = FALSE;
            } else {
                accountIds.retainAll(accountIdSubset);
            }
        }

        Set<Id> excludedOppRecordTypeIds = new set<Id>();
        if (selectedNewBusinessLine.contains(System.Label.Cooperative)) { 
            excludedOppRecordTypeIds.add(Constants.OPP_RT_COOPERATIVE_ID);
        }

        if (selectedNewBusinessLine.contains(System.Label.Testprep)) {
            excludedOppRecordTypeIds.add(Constants.OPP_RT_TESTPREP_ID);
        }

        if (selectedNewBusinessLine.contains(System.Label.Counselling)) {
            excludedOppRecordTypeIds.add(Constants.OPP_RT_COUNSELLING_ID);
        }

        for (Account a : [SELECT Name, TestPrepOppCount__c, CounsellingOppCount__c, 
                                Cooperative_Education_Opportunity_Count__c,
                                Newest_Counseling_Opportunity_CreateDate__c, 
                                Newest_Testprep_Opportunity_CreateDate__c,
                                Newest_Coop_Ed_Opportunity_CreatedDate__c, 
                                (SELECT RecordTypeId
                                 FROM Opportunities),
                                (SELECT Contact_Type__c, UniqueContact__c
                                 FROM Contacts__r
                                 WHERE isPrimary__c = true 
                                 AND Contact_Type__c IN ('手机', '座机', '办公电话'))
                          FROM Account
                          WHERE Id IN :accountIds]) {

            if (a.Contacts__r.size() > 0) {
                Boolean includeAccount = true;
                for (Opportunity opp : a.Opportunities) {
                    if (excludedOppRecordTypeIds.contains(opp.RecordTypeId)) {
                        includeAccount = FALSE;
                    }
                }
                AccountWrap w = new AccountWrap();
                w.acct = a;
                if (includeAccount) {
                    acctWraps.add(w);
                }
            }
        }
        if (acctWraps.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                 System.Label.Your_search_criteria_did_not_match_any_accounts));
        }
        changePageNo();
    }

    public Integer gettestprepSize() {
        return testprepAcctWraps.size();
    }

    public Integer getcounsellingSize() {
        return counsellingAcctWraps.size();
    }

    public Integer getcooperativeSize() {
        return cooperativeAcctWraps.size();
    }

    public Integer getacctSize() {
        return acctWraps.size();
    }

    public PageReference createLeads() {
        if (acctWraps.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Error_Select_At_Least_One_Account));
            return null;
        }
        String errorMsg = '编号,姓名,电话,错误码,创建状态'+'\r\n';
        Integer errorIndex = 0;
        List<Lead> leadToInsert = new List<Lead>();
        List<Campaign> camList = [SELECT Id
                                  FROM Campaign 
                                  WHERE Name = :Constants.CAMP_RESOURCE_EXCHANGE_GROUP_NAME 
                                  AND IsActive = true
        ];

        if (camList.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                System.Label.Error_MIssing_Exchange_Resource_Campaign));
            return null;
        }

        Group g = [SELECT Id
                   FROM Group
                   WHERE developerName = 'TMK_Incharge'
                   AND Type = 'Queue'];

        Campaign cam = camList[0];
        List<AccountWrap> wraps = new List<AccountWrap>();
        for (AccountWrap w : acctWraps) {
            if (w.isselected) {
                system.debug(w.acct.Contacts__r);
                Lead l = new Lead();
                l.LastName = w.acct.name;
                l.Intended_City__c = w.intended_city;
                l.Consultation_Mode__c = '集团TMK外呼';
                l.Campaign__c = cam.Id;
                l.Company = 'EIC';
                l.OwnerId = g.Id;

                if (selectedNewBusinessLine.contains(System.Label.Cooperative)) {
                    l.Is_Cooperative_Education__c = true;
                }

                if (selectedNewBusinessLine.contains(System.Label.Testprep)) {
                    l.Is_TestPrep__c = true;
                }

                if (selectedNewBusinessLine.contains(System.Label.Counselling)) {
                    l.Is_Counselling__c = true;
                }

                Contact_EIC__c con = null;
                for (Contact_EIC__c c : w.acct.Contacts__r) {
                    if (c.Contact_Type__c== '手机') {
                        con = c;
                        break;
                    }
                    con = c;
                }
                if (con.Contact_Type__c == '手机') {
                    l.MobilePhone = convertPhoneNum(con.UniqueContact__c);
                } else if (con.Contact_Type__c == '座机' || con.Contact_Type__c == '办公电话') {

                    if (con.UniqueContact__c.startsWith('0')) {
                        if (areas.contains(con.UniqueContact__c.substring(0, 3))) {

                            l.Area_Code__c = con.UniqueContact__c.substring(0, 3);
                            l.Phone = convertPhoneNum(con.UniqueContact__c.substring(3, con.UniqueContact__c.length()));
                        } else {

                            // Gets the 4 digital area code
                            l.Area_Code__c = con.UniqueContact__c.substring(0, 4);
                            l.Phone = convertPhoneNum(con.UniqueContact__c.substring(3, con.UniqueContact__c.length()));
                        }
                    } else {

                        // Skips the validation rule
                        l.Phone = convertPhoneNum(con.UniqueContact__c);
                    }
                }
                if (l.MobilePhone != null) {
                    if (ValidteMobile(l.MobilePhone)) {
                        leadToInsert.add(l);
                        wraps.add(w);
                    } else {
                        errorIndex++;
                        errorMsg += errorIndex + ',' + l.LastName + ',' + (l.MobilePhone == null ? l.Area_Code__c + l.Phone : l.MobilePhone) + ',' + '' + ',' + '请验证客户手机号码的格式' + '\r\n';
                    }
                } else if (l.Phone != null) {
                    if (ValidatePhone(l.Phone)) {
                        leadToInsert.add(l);
                        wraps.add(w);
                    } else {
                        errorIndex++;
                        errorMsg += errorIndex + ',' + l.LastName + ',' + (l.MobilePhone == null ? l.Area_Code__c + l.Phone : l.MobilePhone) + ',' + '' + ',' + '请验证客户电话号码的格式' + '\r\n';
                    }
                } else {
                    errorIndex++;
                    errorMsg += errorIndex + ',' + l.LastName + ',' + (l.MobilePhone == null ? l.Area_Code__c + l.Phone : l.MobilePhone) + ',' + '' + ',' + '客户没有电话号码' + '\r\n';

                }
            }
        }
        if (leadToInsert.size() > 0) {

            try{

                Id bid = Database.executeBatch(new CreateExchangeResourceBatchable(
                    (List<Sobject>)leadToInsert, UserInfo.getUserEmail(), errorMsg,errorIndex), 
                50);
                BatchJobRecord__c job = new BatchJobRecord__c();
                job.Name = '资源互换_' + leadToInsert.size() + '_' + System.Now();
                job.BatchJobId__c = bid;
                job.BatchType__c = 'CreateExchangeResourceBatchable';
                job.Status__c = '处理中';
                insert job;
                issuccess = true;
                return null;

            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
        }
        PageReference ref = new PageReference('/00Q?fcf=00BO0000001I9Pu');
        return ref;
    }

    public String convertPhoneNum(String input) {
        Pattern p = Pattern.compile('([\\d]*)(\\s?(\\[[\\d,E]*\\])?)?');
        Matcher m = p.matcher(input);
        if (m.find()) {
            return m.replaceFirst('$1');
        }
        return '';
    }

    public Boolean ValidteMobile(String mobi) {
        Pattern P = Pattern.compile('^0?(13[0-9]|15[0-9]|14[0-9]|17[0-9]|18[0-9]|19[0-9])[0-9]{8}');
        Matcher m = p.matcher(mobi);
        if (m.find()) {
            return true;
        }
        return FALSE;
    }

    public Boolean ValidatePhone(String phone) {
        Pattern P = Pattern.compile('[0-9]{7,8}');
        Matcher m = p.matcher(phone);
        if (m.find()) {
            return true;
        }
        return FALSE;
    }

    public Class errorWrap{
        public Integer i { get; set; }
        public String AccountName { get; set; }
        public String statusCode { get; set; }
        public String errorMsg { get; set; }
    }

    public Class AccountWrap{
        public Boolean isselected { get; set; }
        public Account acct { get; set; }
        public String intended_city { get; set; }
        public AccountWrap() {
            isselected = FALSE;
        }
    }

    public Class OpportunityInfo{
        public String recordTypeId { get; set; }
        public String projects { get; set; }
    }

    public void changePageNo() {
        show.clear();
        total = acctWraps.size();
        for (Integer i = offSet; i < (((offSet + Integer.valueOf(pageRecord)) < acctWraps.size()) ? (offSet + Integer.valueOf(pageRecord)): acctWraps.size()); i ++) {
            show.add(acctWraps[i]);
        }
    }

    public void changeLeadPerPage() {
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        changePageNo();
    }

    public void next() {
        offSet += Integer.valueOf(pageRecord);
        currentPageNo += 1;
        changePageNo();
    }

    public void previous() {
        if (offSet > 0) {
            offSet -= Integer.valueOf(pageRecord);
        }

        currentPageNo -= 1;
        changePageNo();
    }

    public void homePage() {
        offSet = 0;
        currentPageNo = 1;
        changePageNo();
    }

    public void endPage() {
        offSet = (getTotalPageNo() - 1) * Integer.valueOf(pageRecord);
        currentPageNo = getTotalPageNo();
        changePageNo();
    }

    public String getTotal() {
        if (total > 2000) {
            return '2000+';

        } else {
            return String.valueOf(total);
        }
    }

    public Integer getCurrentPageNo() {
        if (currentPageNo > getTotalPageNo()) {

            return getTotalPageNo();
        } else {
            return currentPageNo;
        }
    }

    public Integer getTotalPageNo() {
        if (Math.mod(total, Integer.valueOf(pageRecord)) != 0) {
            return total / Integer.valueOf(pageRecord) + 1;
        } else {
            return total / Integer.valueOf(pageRecord);
        }
    }

    public Boolean getNextEnable() {

        if (getCurrentPageNo() == getTotalPageNo()) {
            return FALSE;

        } else {
            return true;
        }
    }

    public Boolean getPreviousEnable() {

        if (getCurrentPageNo() == 1 || getTotalPageNo() == 0) {
            return FALSE;

        } else {
            return true;
        }
    }

    public void clearCounsellingProjects() {
        selectedCounsellingOppProject = '';
    }

    public void clearTestprepProjects() {
        selectedTestprepOppProject = '';
    }

    public void clearCooperativeProjects() {
        selectedCooperativeOppProject = '';
    }

    // Gets the campaign channels for picklist options
    private void getCampaignChannels() {
        marketingChannelLv1List = new List<SelectOption>();
        marketingChannelLv2List = new List<SelectOption>();
        marketingChannelLv3List = new List<SelectOption>();

        Set<String> lv1Set = new Set<String>();

        lv1Lv2Map = new Map<String, Set<String>>();
        lv1Lv2Lv3Map = new Map<String, Set<String>>();

        // Gets LV1, LV2, Business Line, City, LV3 mappings
        for (Campaign_Channel__c cc : [SELECT Marketing_Channel_Lv1__c,
                                              Marketing_Channel_Lv2__c,
                                              Marketing_Channel_Lv3__c,
                                              Business_line__c,
                                              City__c
                                       FROM Campaign_Channel__c
                                       WHERE Active__c = true
                                       ORDER BY Marketing_Channel_Lv1__c,
                                                Marketing_Channel_Lv2__c,
                                                Marketing_Channel_Lv3__c]) {

            if (String.isNotBlank(cc.Marketing_Channel_Lv1__c)) {
                lv1Set.add(cc.Marketing_Channel_Lv1__c);

                if (String.isNotBlank(cc.Marketing_Channel_Lv2__c)) {
                    if (!lv1Lv2Map.containsKey(cc.Marketing_Channel_Lv1__c)) {
                        lv1Lv2Map.put(cc.Marketing_Channel_Lv1__c, new Set<String>());
                    }
                    lv1Lv2Map.get(cc.Marketing_Channel_Lv1__c).add(cc.Marketing_Channel_Lv2__c);

                    String lv1Lv2 = cc.Marketing_Channel_Lv1__c + '-' + cc.Marketing_Channel_Lv2__c;
                    if (!lv1Lv2Lv3Map.containsKey(lv1Lv2)) {
                        lv1Lv2Lv3Map.put(lv1Lv2, new Set<String>());
                    }
                    lv1Lv2Lv3Map.get(lv1Lv2).add(cc.Marketing_Channel_Lv3__c);
                }
            }
        }

        marketingChannelLv1List.clear();
        marketingChannelLv1List.add(new SelectOption('--无--', '--无--'));
        for (String lv1 : lv1Set) {
            marketingChannelLv1List.add(new SelectOption(lv1, lv1));
        }
    }

    public void getLv2ByLv1() {
        marketingChannelLv2List.clear();
        marketingChannelLv2List.add(new SelectOption('--无--', '--无--'));

        for (String lv2 : lv1Lv2Map.get(lv1)) {
            marketingChannelLv2List.add(new SelectOption(lv2, lv2));
        }
        System.debug('LoggingLevel.INFO, *** marketingChannelLv2List: ' + marketingChannelLv2List);
    }

    public void getLv3ByLv1Lv2() {
        marketingChannelLv3List.clear();
        marketingChannelLv3List.add(new SelectOption('--无--', '--无--'));
        String lv1Lv2 = lv1 + '-' + lv2;
        for (String lv3 : lv1Lv2Lv3Map.get(lv1Lv2)) {
            if (String.isNotBlank(lv3)) {
                marketingChannelLv3List.add(new SelectOption(lv3, lv3));
            }
        }
    }

    // Query owner
    @RemoteAction
    public static List<User> searchUser(String param, String param1) {

        string queryterm = '%' + param + '%';
        String queryString = 'SELECT Id,Name FROM User ' +
            'WHERE (Profile.Name=\'集团市场部呼叫中心专员\' ' + 
            'OR Profile.Name=\'集团市场部呼叫中心主管\') ' + 
            'AND (Name LIKE :queryterm OR UserName LIKE :queryterm)';
        Set<String> ids = new Set<String>();
        if (param1 != '') {
            List<String> arr = param1.split(',');
            for (String s : arr) {
                ids.add(s);
            }
        }
        if (ids.size() > 0) {
            queryString += ' AND Id not IN : ids';
        }
        queryString += ' limit 100';
        List<User> userList = Database.query(queryString);
        return userList;
    }

    // Searches the campaigns
    @RemoteAction
    public static List<Campaign> searchCampaign(String param, String param1) {

        Map<String, object> pm = (Map<String, Object>) JSON.deserializeUntyped(param);
        String l1 = String.valueOf(pm.get('lv1'));
        String l2 = String.valueOf(pm.get('lv2'));
        String l3 = String.valueOf(pm.get('lv3'));
        String term = String.valueOf(pm.get('term'));
        Set<String> ids = new Set<String>();
        system.debug(param1);
        if (param1 != '') {
            List<String> arr = param1.split(',');
            for (String s : arr) {
                ids.add(s);
            }
        }
        String sqlString = 'SELECT Id, Name FROM Campaign WHERE Status = \'审批通过\' AND IsActive = true';
        if (String.isNotBlank(l1)) {
            sqlString += ' AND Marketing_Channel_Lv1__c=\'' + l1 + '\'';
        }
        if (String.isNotBlank(l2)) {
            sqlString += ' AND Marketing_Channel_Lv2__c=\'' + l2 + '\'';
        }
        if (String.isNotBlank(l3)) {
            sqlString += ' AND Marketing_Channel_Lv3__c=\'' + l3 + '\'';
        }
        if (String.isNotBlank(term)) {
            term = '%' + term + '%';
            sqlString += ' AND Name LIKE :term';
        }
        if (ids.size() > 0) {
            sqlString += ' AND Id not IN : ids';
        }
        sqlString += ' limit 100';
        List<Campaign> clist = Database.query(sqlString);
        return clist;
    }

    public List<SelectOption> getPageSizePerPage() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('25', '25'));
        options.add(new SelectOption('50', '50'));
        options.add(new SelectOption('100', '100'));
        options.add(new SelectOption('200', '200'));
        options.add(new SelectOption('500', '500'));
        return options;
    }
}