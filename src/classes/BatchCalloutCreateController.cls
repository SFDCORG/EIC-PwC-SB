/**************************************************************************************************
 * Name: BatchCalloutCreateController
 * Object: Lead, Calllog_History__c
 * Purpose: Post the batch of callout to the call center system (He Li Jin Qiao)
 * Author: Joe 
 * Create Date: --
 * Modified History: 
 * 2016-05-06    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
public class BatchCalloutCreateController{

    public String dataType { get; set; }
    public Lead filterLead { get; set; }
    public String followupcondition { get; set; }
    public String itemstatuscondition { get; set; }
    public String projectcondition { get; set; }
    public Opportunity filterOpp { get; set; }
    public Boolean isShow { get; set; }
    public DateTime starttime;
    public DateTime endtime;
    public Boolean sevendaynocomplete { get; set; }
    public Boolean lowlevel { get; set; }
    public Boolean otherUncomplete { get; set; }
    public Boolean lost { get; set; }
    public String opptype { get; set; }
    public String delLead { get; set; }
    public String delOpp { get; set; }
    public Set<Id> selLeadIds { get; set; }
    public Set<Id> selOppIds { get; set; }

    // Pagination
    Integer offSet = 0;
    Integer total = 0;
    Integer currentPageNo = 1;
    public String pageRecord { get; set; }
    Integer offSet1 = 0;
    Integer total1 = 0;
    Integer currentPageNo1 = 1;
    public String pageRecord1 { get; set; }

    // Multi-picklist
    public String selectedConsultMode { get; set; }
    public String selectedIntendCity { get; set; }
    public String selectedBSLine { get; set; }
    public String selectedProject { get; set; }
    public String selectedFollowUp { get; set; }
    public String selectedItemStatus { get; set; }
    public String selectedOwnerSource { get; set; }
    public String selectedHtmlOwnerSource { get; set; }
    public List<SelectItem> selectedOwnerItem { get; set; }
    public List<SelectOption> marketingChannelLv1List { get;  set ;}
    public List<SelectOption> marketingChannelLv2List { get;  set ;}
    public List<SelectOption> marketingChannelLv3List { get;  set ;}
    public Map<String, Set<String>> lv1Lv2Map { get; set ;}
    public Map<String, Set<String>> lv1Lv2Lv3Map { get; set ;}
    public String lv1 { get;  set ;}
    public String lv2 { get;  set ;}
    public String lv3 { get;  set ;}
    public String selectedCampaignSource { get; set; }
    public String selectedHtmlCampaignSource { get; set; }
    public String selectedOpptype { get; set; }
    public String selectedIntendDepart { get; set; }
    public String selectedOppStage { get; set; }
    public String selectedFaculties { get; set; }
    public String selectedHtmlFaculties { get; set; }

    public Map<String, String> facultyMap { get; set; }
    public BatchCallOutManagementItem__c batchItem { get; set; }
    public List<callItem> callitemlist  { get; set; }
    public List<LeadOBJ> templeads { get; set; }
    public List<OppOBJ> tempopps { get; set; }
    public List<LeadOBJ> templeadsshow { get; set; }
    public List<OppOBJ> tempoppsshow { get; set; }

    public List<LeadWrap> leads { get; set; }
    public List<OppWrap> opps { get; set; }

    Map<String,ID> rmap { get; set; }

    // For String : value Multipicklist
    public class SelectItem {
        public String name { get; set; }
        public String val { get; set; }
    }

    // Searches for Account
    public String acctType { get; set; }

    public BatchCalloutCreateController () {
        batchItem = new BatchCallOutManagementItem__c ();
        callitemlist = new List<callItem> ();
        List<RecordType> rs = [SELECT Name,DeveloperName
                               FROM RecordType
                               WHERE SobjectType='Opportunity' AND IsActive = true];

        rmap = new Map<String,Id> ();
        for (RecordType r : rs) {
            rmap.put(r.DeveloperName, r.Id);
        }

        opptype = '考培';
        dataType = 'Lead';
        followupcondition = '';
        itemstatuscondition = '';
        leads = new List<LeadWrap> ();
        opps = new List<OppWrap> ();
        templeads = new List<LeadObJ> ();
        tempopps = new List<OppOBJ> ();
        templeadsshow = new List<LeadOBJ> ();
        tempoppsshow = new List<OppOBJ> ();
        isShow = true;
        filterLead = new Lead ();
        filterOpp = new Opportunity ();
        filterOpp.RecordTypeId = Constants.OPP_RT_COUNSELLING_ID;
        sevendaynocomplete = false;
        lowlevel = false;
        otherUncomplete = false;
        lost = false;
        pageRecord = '25';
        pageRecord1 = '25';
        if (!Constants.TMK_AND_SYS_ADMIN_PROFILE_IDS.contains(Userinfo.getProfileId())) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Error_Only_For_Tmk));
            isShow = false;
        }
        selLeadIds = new Set<Id> ();
        selOppIds = new Set<Id> ();

        // Multipicklist
        selectedConsultMode = '';
        selectedIntendCity = '';
        selectedBSLine = '';
        selectedProject = '';
        selectedFollowUp = '';
        selectedItemStatus = '';
        selectedOwnerSource = '';
        selectedHtmlOwnerSource = '';
        lv1 = '';
        lv2 = '';
        lv3 ='';
        selectedCampaignSource='';
        selectedHtmlCampaignSource='';
        selectedOpptype='';
        selectedIntendDepart = '';
        selectedOppStage = '';
        selectedFaculties = '';
        selectedHtmlFaculties = '';

        getCampaignChannels();

        // Searches for Account
        acctType = 'TestPrep';

        facultyMap = fetchAllFaculties();

    }

    // Consultation Multi-Picklist value
    public List<String> getConsultMode () {

        List<String> ss = selectedConsultMode.split(',');
        Schema.DescribeFieldResult F = Lead.Consultation_Mode__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String> ();
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

    // 意向城市多选项
    public List<String> getIntendCity () {
        List<String> ss = selectedIntendCity.split(',');
        Schema.DescribeFieldResult F = Lead.Intended_City__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String> ();
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

    // 业务线多选项
    public List<String> getBSLine () {
        List<String> ss = selectedBSLine.split(',');
        List<String> bss = Constants.ALL_BUSINESS_LINE_NAMES;
        List<String> options = new List<String> ();
        for (String i : bss) {
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

    // 意向项目多选项
    public List<String> getProject() {
        List<String> ss = SelectedProject.split(',');
        Schema.DescribeFieldResult F = Lead.Project__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String> ();
        for (Schema.PicklistEntry i : p) {
            Integer flag = 0;
            for (String s : ss) {
                if (s == i.getValue()) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                options.add(i.getLabel());
            }
        }
        return options;
    }

    // 跟进结果多选项
    public List<String> getFollowUp() {
        List<String> ss = selectedFollowUp.split(',');
        List<String> vals = new List<String> { '未跟进',
                                               '无人接听-1',
                                               '无人接听-2',
                                               '无人接听-3次或以上',
                                               '无人接听-转顾问',
                                               '拒绝回访',
                                               '电话号码错误',
                                               '空号',
                                               '无意向',
                                               '转竞争对手',
                                               '重复咨询',
                                               'DIY'};

        List<String> options = new List<String> ();
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

    // 线索状态多选项
    public List<String> getItemStatus () {
        List<String> ss = SelectedItemStatus.split(',');
        List<String> vals = new List<String>{ '全未转化-休眠自动',
                                              '全未转化-休眠手动',
                                              '全未转化-流失' };

        List<String> options = new List<String> ();
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

    // 商机RecordType多选项
    public List<String> getOppTypes () {
        List<String> ss = selectedOpptype.split(',');
        List<String> vals = Constants.OPP_ALL_EIC_RECORD_TYPES;
        List<String> options = new List<String> ();
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

    //意向业务部门多选项
    public List<String> getIntendDepart () {
        List<String> ss = selectedIntendDepart.split(',');
        Schema.DescribeFieldResult F = Opportunity.Department__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String> ();
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

    // 商机阶段多选项
    public List<String> getOppStage () {
        List<String> ss = selectedOppStage.split(',');
        Schema.DescribeFieldResult F = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> options = new List<String> ();
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

    // 专业大类多选项
    public List<SelectItem> getselectedFacultySource () {
        List<SelectItem> selected = this.getselectedFaculty();
        List<SelectItem> source = new List<SelectItem> ();
        integer i = 0;
        for (String key : facultyMap.keyset()) {
            Integer flag = 0;
            for (SelectItem s : selected) {
                if (s.name == key) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                SelectItem item = new SelectItem();
                item.name = key;
                item.val = facultyMap.get(key);
                source.add(item);
            }
        }
        return source;
    }

    // Owner多选项
    public List<SelectItem> getselectedOwnerItems () {
        if (selectedOwnerSource == '') {

            return new List<SelectItem> ();
        }
        List<String> vals = selectedOwnerSource.split(',');
        List<String> names = selectedHtmlOwnerSource.split(',');
        List<SelectItem> items = new List<SelectItem> ();
        integer i = 0;
        for (String s : vals) {
            SelectItem item = new SelectItem();
            item.name = names[i];
            item.val = vals[i];
            items.add(item);
            i ++;
        }

        return items;
    }

    // 市场活动多选项
    public List<SelectItem> getselectedCampaignItems () {
        if (selectedCampaignSource== '') {
            return new List<SelectItem> ();
        }
        List<String> vals = selectedCampaignSource.split(',');
        List<String> names = selectedHtmlCampaignSource.split(',');
        List<SelectItem> items = new List<SelectItem> ();
        integer i = 0;
        for (String s : vals) {
            SelectItem item = new SelectItem();
            item.name = names[i];
            item.val = vals[i];
            items.add(item);
            i++;
        }
        system.debug('item length:'+items.size());
        return items;
    }

    //已选专业大类列表
    public List<SelectItem>getselectedFaculty() {
        if (selectedFaculties== '') {
            return new List<SelectItem> ();
        }
        List<String> vals = selectedFaculties.split(',');
        List<String> names = selectedHtmlFaculties.split(',');
        List<SelectItem> items = new List<SelectItem> ();
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

    //已选咨询方式列表
    public List<String> getSelectedConsultModeVal () {
        if (selectedConsultMode == '') {
            return new List<String> ();
        }
        return selectedConsultMode.split(',');
    }

    //已选城市列表
    public List<String> getSelectedIntendCityVal () {
        if (selectedIntendCity == '') {
            return new List<String> ();
        }
        return selectedIntendCity.split(',');
    }

    // 已选业务线列表
    public List<String> getSelectedBSLineVal () {
        if (selectedBSLine == '') {
            return new List<String> ();
        }
        return selectedBSLine.split(',');
    }

    // 已选项目列表
    public List<String> getSelectedProjectVal () {
        if (selectedProject == '') {
            return new List<String> ();
        }
        return selectedProject.split(',');
    }

    // 已选跟进结果
    public List<String> getSelectedFollowUpVal () {
        if (selectedFollowUp == '') {
            return new List<String> ();
        }
        return selectedFollowUp.split(',');
    }

    // 已选线索状态
    public List<String> getSelectedItemStatusVal () {
        if (selectedItemStatus == '') {
            return new List<String> ();
        }
        return selectedItemStatus.split(',');
    }

    // 已选商机类型
    public List<String> getSelectedOppTypeVal () {
        if (selectedOpptype == '') {
            return new List<String> ();
        }
        return selectedOpptype.split(',');
    }


    // 已选商机阶段
    public List<String> getSelectedOppStageVal () {
        if (selectedOppStage  == '') {
            return new List<String> ();
        }
        return selectedOppStage.split(',');
    }

    // 已选部门
    public List<String> getSelectedIntendDepartVal () {
        if (selectedIntendDepart== '') {
            return new List<String> ();
        }
        return selectedIntendDepart.split(',');
    }

    // 分页选项
    public List<SelectOption> getPageSizePerPage () {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('25', '25'));
        options.add(new SelectOption('50', '50'));
        options.add(new SelectOption('100','100'));
        options.add(new SelectOption('200','200'));
        options.add(new SelectOption('500','500'));
        options.add(new SelectOption('1000','1000'));
        return options;
    }

    // Radio button option
    public List<SelectOption> getDataTypeItems () {

        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('Lead', Lead.sObjectType.getDescribe().getLabel()));
        if (Userinfo.getProfileId() == Constants.PROFILE_TMK_CUSTOMER_SERVICE_MANAGER_ID ||
            UserInfo.getProfileId() == Constants.PROFILE_SYS_ADMIN_ID) {
            options.add(new SelectOption('Opportunity', Opportunity.sObjectType.getDescribe().getLabel()));
        }
        return options;
    }

    // 从已选则添加到批次的线索中删除。
    public void deleteLead () {

        delLead = ApexPages.CurrentPage().getParameters().get('leadid');
        Integer i = 0;

        for (LeadOBJ w : templeads) {
            if (w.Id == delLead) {
                templeads.remove(i);
                selLeadIds.remove(w.Id);
                break;
            }
            i++;
        }
        changePageNo1();
    }

    public void dummy() {
    }

    // 从已选则添加到批次的商机中删除。
    public void deleteOpp () {

        delOpp =  ApexPages.CurrentPage().getParameters().get('oppid');
        Integer i = 0;
        for (OppOBJ w :tempopps) {
            if (w.Id == delOpp) {
                tempopps.remove(i);
                selOppIds.remove(w.Id);
                break;
            }
            i++;
        }
        changePageNo2();
    }

    // 线索的包装类，用于线索的选择
    public Class LeadWrap{

        public Boolean isSelected { get; set; }
        public Lead leadObj { get; set; }
        String phone { get; set; }
        public LeadWrap() {
            isSelected = false;
        }
    }

    // 商机的包装类，用于商机的选择
    public Class OppWrap{
        public Boolean isSelected { get; set; }
        public Opportunity opp { get; set; }
        String phone { get; set; }
        public OppWrap() {
            isSelected = false;
        }
    }

    // 从商机筛选和从线索筛选之间切换
    public void changeDataType() {
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        pageRecord = '25';
        filterLead = new Lead ();
        followupcondition = null;
        itemstatuscondition = null;
        projectcondition = null;
        filterOpp = new Opportunity ();
        filterOpp.RecordTypeId = Constants.OPP_RT_COUNSELLING_ID;
        sevendaynocomplete = false;
        lowlevel = false;
        otherUncomplete = false;
        lost = false;
        opptype = '考培';
        leads.clear();
        opps.clear();

        selectedConsultMode = '';
        selectedIntendCity = '';
        selectedBSLine = '';
        selectedProject = '';
        selectedFollowUp = '';
        selectedItemStatus = '';
        selectedOwnerSource = '';
        selectedHtmlOwnerSource = '';
        lv1='';
        lv2='';
        lv3='';
        selectedCampaignSource='';
        selectedHtmlCampaignSource='';
        selectedOpptype='';
        selectedIntendDepart = '';
        selectedOppStage = '';
        selectedFaculties = '';
        selectedHtmlFaculties = '';
    }

    // 是否有线索查询到
    public Boolean getLeadStatus () {
        if (leads.size() > 0) {
            return true;
        }
        return false;
    }
    // 是否有商机查询到
    public Boolean getoppStatus() {
        if (opps.size() > 0) {
            return true;
        }
        return false;
    }

    // 查询商机
    public void searchOpp() {
        dataType = 'Opportunity';
        if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c != null) {

            if (filterLead.Birthday__c > filterLead.Schedule_Abroad_Year__c) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.error_creation_date_invalid));
                return;
            }
        }
        if (filterLead.Converted_Date__c != null && filterLead.Transferred_Date__c != null) {

            if (filterLead.Converted_Date__c > filterLead.Transferred_Date__c) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Error_Conversion_Date_Invalid));
                return;
            }
        }
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        pageRecord = '25';
        opps.clear();
        changePageNo();
    }

    // 添加商机到批次
    public void addOppToBatch() {
        Map<Id, RecordType> rts = new Map<Id, RecordType> ([SELECT Id,toLabel(Name)
                                                            FROM RecordType
                                                            WHERE SObjectType = 'Opportunity'
                                                            AND IsActive = TRUE]);
        for (OppWrap lw : opps) {
            if (lw.isSelected) {
                OppOBJ two = new OppOBJ (lw);
                two.RecordTypeId = rts.get(lw.opp.RecordTypeId).Name;
                tempopps.add(two);
                selOppIds.add(two.Id);
            }
        }
        opps.clear();
    }

    // 添加线索导批次
    public void addLeadToBatch () {

        Set<Id> ids = new Set<Id> ();
        for (LeadWrap tempw: leads) {

            ids.add(tempw.leadObj.Campaign__c);
        }

        Map<String,Campaign> cammap = new Map<String,Campaign> ([SELECT Name FROM Campaign WHERE Id IN : ids]);
        for (LeadWrap lw : leads) {
            if (lw.isSelected) {
                Integer flag = 0;
                LeadOBJ twl = new LeadOBJ (lw);
                twl.Campaign = cammap.get(lw.leadObj.Campaign__c).Name;
                templeads.add(twl);
                selLeadIds.add(lw.leadObj.Id);
            }
        }
        leads.clear();
    }

    public void searchAccount() {

    }

    public void addAccountToBatch() {

    }

    public Boolean gettemptabledisplay() {

        if (tempopps.size() > 0) {
            return true;
        }
        return false;
    }

    public Boolean gettemptabledisplay1 () {
        if (templeads.size() > 0) {
            return true;
        }
        return false;
    }

    // 查询线索操作
    public void searchLead () {
        if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c != null) {
            if (filterLead.Birthday__c > filterLead.Schedule_Abroad_Year__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    System.Label.Error_Start_Date_Before_End_Date));
                return;
            }
        }
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        pageRecord = '25';
        leads.clear();
        changePageNo();
    }

    //构建查询语句，查询线索
    public List<Lead> queryForLead() {
        String queryString = 'SELECT Id, Name, Phone, Area_Code__c, MobilePhone, Status, Intended_City__c, ' +
                                    'Business_Line__c, Project__c, Campaign__c, Consultation_Mode__c, Followup_Result__c, ' + 
                                    'CreatedDate, Is_TestPrep__c , Is_Counselling__c, Is_Cooperative_Education__c ';

        Set<String> statusset = new Set<String> ();
        Set<String> followSet = new Set<String> ();
        if (selectedFollowUp  !=  '' && selectedItemStatus != '') {

            followSet = new Set<String> (selectedFollowUp.split(','));
            statusset = new Set<String> (selectedItemStatus.split(','));
            if (followSet.contains('未跟进')) {

                followSet.remove('未跟进');
                statusset.add('全未转化-新建');
                if (followSet.size() > 0) {

                    if (followSet.contains('无人接听-1') ||
                        followSet.contains('无人接听-2')||
                        followSet.contains('无人接听-转顾问')) {

                        statusset.add('全未转化-跟进中');
                        queryString +=' FROM Lead ' +
                                       'WHERE (Phone != null OR MobilePhone != null) ' +
                                       'AND Status IN :statusset ' +
                                       'AND (Followup_Result__c IN :followSet OR Followup_Result__c=null)';
                    } else{
                        queryString +=' FROM Lead ' +
                                       'WHERE (Phone != null OR MobilePhone != null) ' +
                                       'AND Status IN :statusset ' +
                                       'AND (Followup_Result__c IN :followSet OR Followup_Result__c=null)';
                    }
                } else {
                    queryString +=' FROM Lead ' + 
                                   'WHERE (Phone != null OR MobilePhone != null) ' +
                                   'AND Status IN :statusset ' +
                                   'AND Followup_Result__c=null';
                }

            } else{
                if (followSet.contains('无人接听-1') ||
                    followSet.contains('无人接听-2') ||
                    followSet.contains('无人接听-转顾问')) {

                    statusset.add('全未转化-跟进中');
                    queryString += ' FROM Lead ' +
                                    'WHERE (Phone != null OR MobilePhone != null) ' +
                                    'AND Status IN :statusset AND Followup_Result__c IN :followSet';
                } else{
                    queryString+=' FROM Lead ' +
                                  'WHERE (Phone != null OR MobilePhone != null) ' +
                                  'AND Status IN :statusset ' +
                                  'AND Followup_Result__c IN :followSet';
                }
            }

        } else if (selectedFollowUp != '' && selectedItemStatus == '') {

            followSet = new Set<String> (selectedFollowUp.split(','));
            if (followSet.contains('未跟进')) {

                followSet.remove('未跟进');
                if (followSet.size() > 0) {
                    if (followSet.contains('无人接听-1') ||
                        followSet.contains('无人接听-2') ||
                        followSet.contains('无人接听-转顾问')) {
                        queryString += ' FROM Lead ' +
                                       'WHERE (Phone != null OR MobilePhone != null) ' +
                                       'AND Status IN (\'全未转化-新建\',\'全未转化-跟进中\', \'全未转化-休眠自动\', \'全未转化-休眠手动\', \'全未转化-流失\') ' +
                                       'AND (Followup_Result__c IN :followSet OR Followup_Result__c = null)';
                    } else{
                        queryString +=' FROM Lead ' +
                                       'WHERE (Phone != null OR MobilePhone != null) ' +
                                       'AND Status IN (\'全未转化-新建\', \'全未转化-休眠自动\', \'全未转化-休眠手动\', \'全未转化-流失\') ' +
                                       'AND (Followup_Result__c IN :followSet OR Followup_Result__c = null)';
                    }

                } else {
                    queryString +=' FROM Lead ' +
                                   'WHERE (Phone != null OR MobilePhone != null) ' +
                                   'AND Status IN (\'全未转化-新建\', \'全未转化-休眠自动\', \'全未转化-休眠手动\', \'全未转化-流失\') ' +
                                   'AND Followup_Result__c = null';
                }

            } else{
                if (followSet.contains('无人接听-1') ||
                    followSet.contains('无人接听-2') ||
                    followSet.contains('无人接听-转顾问')) {
                    queryString +=' FROM Lead ' +
                                   'WHERE (Phone != null OR MobilePhone != null) ' +
                                   'AND Status IN (\'全未转化-跟进中\', \'全未转化-休眠自动\', \'全未转化-休眠手动\', \'全未转化-流失\') ' +
                                   'AND (Followup_Result__c IN :followSet)';
                } else{
                    queryString +=' FROM Lead ' +
                                   'WHERE (Phone != null OR MobilePhone != null) ' +
                                   'AND Status IN ( \'全未转化-休眠自动\', \'全未转化-休眠手动\', \'全未转化-流失\') ' +
                                   'AND (Followup_Result__c IN :followSet)';
                }
            }
        } else if (selectedItemStatus != '' && selectedFollowUp == '') {

            statusset = new Set<String> (selectedItemStatus.split(','));
            queryString += ' FROM Lead ' +
                            'WHERE (Phone != null OR MobilePhone != null) ' +
                            'AND Status IN :statusset';
        } else{
            queryString += ' FROM Lead ' +
                            'WHERE (Phone != null OR MobilePhone != null) ' +
                            'AND Status IN ( \'全未转化-休眠自动\', \'全未转化-休眠手动\', \'全未转化-流失\')';
        }

        queryString += ' AND (Lead_Item_No__c  !=  null ' +
                        'AND Lead_Item_No__c  !=  0) ';

        if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c==null) {
            starttime = datetime.newInstance(filterLead.Birthday__c.year(),
                                             filterLead.Birthday__c.month(),
                                             filterLead.Birthday__c.day(),0,0,0);
            queryString += ' AND CreatedDate > :starttime';
        }

        if (filterLead.Birthday__c == null && filterLead.Schedule_Abroad_Year__c != null) {
            endtime = datetime.newInstance(filterLead.Schedule_Abroad_Year__c.year(),
                                           filterLead.Schedule_Abroad_Year__c.month(),
                                           filterLead.Schedule_Abroad_Year__c.day(), 24, 0, 0);
            queryString += ' AND CreatedDate < :endtime';
        }

        if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c != null) {
            starttime = datetime.newInstance(filterLead.Birthday__c.year(),
                                             filterLead.Birthday__c.month(),
                                             filterLead.Birthday__c.day(), 0, 0, 0);
            endtime = datetime.newInstance(filterLead.Schedule_Abroad_Year__c.year(),
                                           filterLead.Schedule_Abroad_Year__c.month(),
                                           filterLead.Schedule_Abroad_Year__c.day(), 24, 0, 0);
            queryString += ' AND CreatedDate < :endtime AND CreatedDate > :starttime';
        }

        Set<String> cityset = new Set<String> ();
        if (selectedIntendCity  !=  '') {
            cityset = new Set<String> (selectedIntendCity.split(','));
            queryString += ' AND Intended_City__c IN : cityset';
        }

        if (selectedBSLine  !=  '') {
            queryString += ' AND (';
            Integer flag = 0;
            String[] bLineConditions = new List<String> ();
            for (String v : selectedBSLine.split(',')) {
                if (v == Constants.BL_TESTPREP_NAME) {
                    bLineConditions.add('Is_TestPrep__c = true');
                } else if (v == Constants.BL_COUSELLING_NAME) {
                    bLineConditions.add('Is_Counselling__c = true');
                } else if (v == Constants.BL_NP_NAME) {
                    bLineConditions.add('Is_NP__c = true');
                } else if (v == Constants.BL_SCHOLAR_TREE_NAME) {
                    bLineConditions.add('Is_Scholar_Tree__c = true');
                } else if (v == Constants.BL_COOPERATIVE_NAME) {
                    bLineConditions.add('Is_Cooperative_Education__c = true');
                }
            }
            queryString += String.join(bLineConditions, ' OR ');
            queryString += ')';
        }

        Set<String> proSet = new Set<String> ();
        if (selectedProject  !=  '') {
            proSet = new Set<String> (selectedProject.split(','));
            String setstring = '(';
            for (String includeValue :proSet) {
                setstring += '\''+includeValue + '\',';
            }
            setstring = setstring.removeEnd(',') +')';
            queryString += ' AND (Counselling_Project__c Includes ' +
                           setstring +
                           ' Or TestPrep_Project__c Includes '
                           + setstring +
                           ' Or Cooperative_Education_Project__c Includes ' +
                           setstring + ') ';
        }

        System.debug('LoggingLevel.INFO, *** selectedCampaignSource: ' + selectedCampaignSource);
        Set<string> campaignids = new Set<String> ();
        if (selectedCampaignSource != '') {
            system.debug(selectedCampaignSource);
            for (String s : selectedCampaignSource.split(',')) {
                campaignids.add(s);
            }
            System.debug('LoggingLevel.INFO, *** campaignids: ' + campaignids);
            queryString += ' AND Campaign__c IN :campaignids';
        }

        Set<String> ownerids = new Set<String> ();
        if (selectedOwnerSource != '') {
            for (String s : selectedOwnerSource.split(',')) {
                ownerids.add(s);
            }
            queryString += ' AND OwnerId IN :ownerids';
        }

        Set<String> cmSet = new Set<String> ();
        if (selectedConsultMode  !=  '') {
            cmSet = new Set<String> (selectedConsultMode.split(','));
            queryString += ' AND Consultation_Mode__c IN :cmset';
        }

        if (selLeadIds.size() > 0) {
            queryString += ' AND Id not iN :selLeadIds';
        }

        queryString += ' Order by CreatedDate DESC';

        try{
            System.debug('LoggingLevel.INFO, *** queryString: ' + queryString);
            List<Lead> tempLeadList = Database.query(queryString);
            return tempLeadList;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return new List<Lead> ();
        }
    }

    // 构建查询语句，查询商机
    public List<Opportunity> queryForOpp () {
        Date d = system.today();
        d = d.addDays(-7);
        Set<String> stageSet = new Set<String> ();
        String queryString = 'SELECT Id, Name, RecordTypeId, Intended_City__c, Department__c, Project__c, ' +
                                    'Consultation_Mode__c, StageName, AccountId, CreatedDate, ' +
                                    'Level_4_Promotion_Channel__c, OwnerId ';
        Set<String> uuidSet = new Set<String> ();
        if (selectedFaculties != '') {
            uuidSet = new Set<String> (selectedFaculties.split(','));
            queryString += ', (SELECT Id FROM Intended_School__r WHERE UUID_Faculty__c IN :uuidSet) ';
        }
        if (sevendaynocomplete) {
            queryString += ', (SELECT Id, Due_Date__c,sys_DueTime__c,RecordTypeId, Status__c, ' +
                                     'TMKAppStatus__c, CreatedDate FROM Appointments__r ' +
                               'WHERE RecordType.DeveloperName=\'Invitation\' ' +
                               'AND (Createdby.Profile.Name=\'集团市场部呼叫中心专员\' OR ' +
                                    'Createdby.Profile.Name=\'集团市场部呼叫中心主管\') ' +
                               'ORDER BY CreatedDate DESC ) ';

        }

        Set<Id> chlogIds = new Set<Id> ();
        if (selectedOppStage != '') {

            stageSet = new Set<String> (selectedOppStage.split(','));
            if (filterLead.Converted_Date__c != null || filterLead.Transferred_Date__c != null) {

                String qstr = 'SELECT Id, Opportunity__c FROM Change_Log__c WHERE Type__c=\'低星资源池\'';
                if (filterLead.Converted_Date__c != null && filterLead.Transferred_Date__c == null) {

                    Datetime st = datetime.newInstance(filterLead.Converted_Date__c.year(),
                                                       filterLead.Converted_Date__c.month(),
                                                       filterLead.Converted_Date__c.day(), 0, 0, 0);
                    qstr += ' AND CreatedDate > :st';

                } else if (filterLead.Converted_Date__c == null && filterLead.Transferred_Date__c != null) {

                    Datetime et = datetime.newInstance(filterLead.Transferred_Date__c.year(),
                                                      filterLead.Transferred_Date__c.month(),
                                                      filterLead.Transferred_Date__c.day(), 24, 0, 0);
                    qstr += ' AND CreatedDate <:et';
                } else if (filterLead.Converted_Date__c != null && filterLead.Transferred_Date__c != null) {

                    Datetime st = datetime.newInstance(filterLead.Converted_Date__c.year(),
                                                       filterLead.Converted_Date__c.month(),
                                                       filterLead.Converted_Date__c.day(), 0, 0, 0);
                    Datetime et = datetime.newInstance(filterLead.Transferred_Date__c.year(),
                                                       filterLead.Transferred_Date__c.month(),
                                                       filterLead.Transferred_Date__c.day(), 24, 0, 0);
                    qstr += ' AND CreatedDate <:et AND CreatedDate > :st';
                }

                List<Change_Log__c> clogs = Database.query(qstr);
                for (Change_Log__c ch : clogs) {
                    chlogIds.add(ch.Opportunity__c);
                }
                stageSet.remove('低星资源池');
                queryString +=' FROM Opportunity WHERE (StageName IN : stageSet Or (StageName =\'低星资源池\' AND Id IN : chlogIds))';
            } else{
                queryString += ' FROM Opportunity WHERE StageName IN :stageSet';
            }
        } else{
            queryString += ' FROM Opportunity WHERE StageName IN (\'待分配\', \'顾问跟进\', \'确认有效\', \'申请无效\', \'邀约\', \'到访\', \'合同生成\', \'订金\', \'申请流失\', \'低星资源池\') ';
        }

        Set<String> rds = new Set<String> ();
        if (selectedOpptype  !=  '') {
            for (String s : selectedOpptype.split(',')) {
                if (s == Constants.BL_TESTPREP_NAME) {
                    rds.add(Constants.OPP_RT_TESTPREP_ID);
                } else if (s == Constants.BL_COUSELLING_NAME) {
                    rds.add(Constants.OPP_RT_COUNSELLING_ID);
                } else if (s == Constants.BL_SCHOLAR_TREE_NAME) {
                    rds.add(Constants.OPP_RT_SCHOLAR_TREE_ID);
                } else if (s == Constants.BL_COOPERATIVE_NAME) {
                    rds.add(Constants.OPP_RT_COOPERATIVE_ID);
                }
            }
            queryString+=' AND RecordTypeId IN :rds';
        }
        Set<string> campaignids = new Set<String> ();

        if (selectedCampaignSource != '') {
            for (String s : selectedCampaignSource.split(',')) {

                campaignids.add(s);
            }
            system.debug(campaignids);
            queryString += ' AND Level_4_Promotion_Channel__c IN :campaignids';
        }

        Set<String> ownerids = new Set<String> ();
        if (selectedOwnerSource  !=  '') {

            for (String s : selectedOwnerSource.split(',')) {

                ownerids.add(s);
            }
            queryString += ' AND OwnerId IN :ownerids';
        }

        Set<String> cityset = new Set<String> ();
        if (selectedIntendCity  !=  '') {
            cityset = new Set<String> (selectedIntendCity.split(','));
            queryString += ' AND Intended_City__c IN :cityset';
        }

        Set<String> departSet = new Set<String> ();
        if (selectedIntendDepart  !=  '') {
            departSet = new Set<String> (selectedIntendDepart.split(','));
            queryString += ' AND Department__c IN :departSet';
        }

        Set<String> proSet = new Set<String> ();
        if (selectedProject  !=  '') {
            proSet = new Set<String> (selectedProject.split(','));
            queryString += ' AND Project__c IN : proSet';
        }

        Set<String> cmSet = new Set<String> ();
        if (selectedConsultMode  !=  '') {
            cmSet = new Set<String> (selectedConsultMode.split(','));
            queryString += ' AND Consultation_Mode__c IN :cmset';
        }
        if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c == null) {
            starttime = datetime.newInstance(filterLead.Birthday__c.year(),
                                             filterLead.Birthday__c.month(),
                                             filterLead.Birthday__c.day(), 0, 0, 0);
            queryString += ' AND CreatedDate > :starttime';
        }
        if (filterLead.Birthday__c == null && filterLead.Schedule_Abroad_Year__c != null) {
            endtime = datetime.newInstance(filterLead.Schedule_Abroad_Year__c.year(),
                                           filterLead.Schedule_Abroad_Year__c.month(),
                                           filterLead.Schedule_Abroad_Year__c.day(), 24, 0, 0);
            queryString += ' AND CreatedDate < :endtime';
        }

        if (selOppIds.size() > 0) {
            queryString += ' AND Id not iN :selOppIds';
        }

        if (filterLead.Birthday__c != null && filterLead.Schedule_Abroad_Year__c != null) {
            starttime = datetime.newInstance(filterLead.Birthday__c.year(), 
                                             filterLead.Birthday__c.month(),
                                             filterLead.Birthday__c.day(), 0, 0, 0);
            endtime = datetime.newInstance(filterLead.Schedule_Abroad_Year__c.year(),
                                           filterLead.Schedule_Abroad_Year__c.month(),
                                           filterLead.Schedule_Abroad_Year__c.day(), 24, 0, 0);
            queryString += ' AND CreatedDate < :endtime AND CreatedDate > :starttime';
        }
        queryString += ' Order by CreatedDate DESC';

        try{

            System.debug('LoggingLevel.INFO, *** queryString: ' + queryString);
            List<Opportunity> tempOppList = Database.query(queryString);
            List<Opportunity> oppList = New List<Opportunity> ();
            if (sevendaynocomplete && uuidSet.size() > 0) {

                for (Opportunity o : tempOppList) {

                    if (o.Intended_School__r.size() > 0) {

                        if (o.Appointments__r.size() > 0) {

                            Appoitment__c a = o.Appointments__r[0];
                            if (a.TMKAppStatus__c !=  '已到访') {

                                if (System.Now() > a.sys_DueTime__c) {

                                    if ((System.Now().getTime() - a.sys_DueTime__c.getTime()) / 1000 / 60 / 60 / 24 >= 7) {
                                        oppList.add(o);
                                    }
                                }
                            }
                        }
                    }
                }

                return oppList;

            } else if (sevendaynocomplete && uuidSet.size() == 0) {
                for (Opportunity o : tempOppList) {
                    if (o.Appointments__r.size() > 0) {
                        Appoitment__c a = o.Appointments__r[0];
                        if (a.TMKAppStatus__c !=  '已到访') {
                            if (system.now() > a.sys_DueTime__c) {
                                if ((system.now().getTime()-a.sys_DueTime__c.getTime())/1000/60/60/24>=7) {
                                    oppList.add(o);
                                }
                            }
                        }
                    }
                }
                return oppList;
            } else if (!sevendaynocomplete && uuidSet.size() > 0) {
                for (Opportunity o : tempOppList) {
                    if (o.Intended_School__r.size() > 0) {
                        oppList.add(o);
                    }
                }
                return oppList;
            } else {
                return tempOppList;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return new List<Opportunity> ();
        }
    }

    // 添加到批次结束后，重刷查询页面
    public void submitbatch () {
        isShow = false;
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        pageRecord = '25';
        offSet1 = 0;
        total1 = 0;
        currentPageNo1 = 1;
        pageRecord1 = '25';
        changePageNo1();
        changePageNo2();
    }

    // Query records after the paging
    public void changePageNo () {

        if (dataType == 'lead') {

            List<Lead> leadresult = queryForLead();
            if (leadresult.size() == 0) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                     System.Label.Your_Search_Criteria_Did_Not_Match_Any_Leads));
                return;
            }
            total = leadresult.size();
            leads.clear();
            for (Integer i = offSet; 
                i < (((offSet + Integer.valueOf(pageRecord)) < leadresult.size()) ? 
                      (offSet + Integer.valueOf(pageRecord)) : leadresult.size());
                i ++) {

                LeadWrap w = new LeadWrap ();
                w.leadObj = leadresult[i];
                w.phone = (leadresult[i].MobilePhone != null) ? 
                           leadresult[i].MobilePhone : 
                          (leadresult[i].Area_Code__c + leadresult[i].phone);
                leads.add(w);
            }
        } else if (dataType == 'opportunity') {
            List<Opportunity> oppresult = queryForOpp();

            // 处理没有电话的情况
            Set<Id> accountids = new Set<Id> ();
            for (Opportunity o : oppresult) {
                accountids.add(o.AccountId);
            }
            List<Contact_EIC__c> contactList = [SELECT Id, UniqueContact__c, Account__c, isPrimary__c, Contact_Type__c 
                                                FROM Contact_EIC__c
                                                WHERE Contact_Type__c IN ('手机','座机','办公电话')
                                                AND Account__c IN :accountids];

            Map<String, String> mobip = new Map<String, String> ();
            Map<String, String> ph =  new Map<String, String> ();
            Map<String, String> primary =  new Map<String, String> ();
            for (Contact_EIC__c c : contactList) {

                if (c.isPrimary__c==true) {
                    primary.put(c.Account__c, c.UniqueContact__c);
                }
                if (c.Contact_Type__c== '手机') {

                    mobip.put(c.Account__c,c.UniqueContact__c);
                } else if (c.Contact_Type__c == '座机' || c.Contact_Type__c == '办公电话') {
                    ph.put(c.Account__c, c.UniqueContact__c);
                }
            }

            Integer j = 0;
            while (j < oppresult.size()) {

                if (!primary.containsKey(oppresult[j].AccountId) &&
                    !mobip.containsKey(oppresult[j].AccountId) &&
                    !ph.containsKey(oppresult[j].AccountId)) {

                    oppresult.remove(j);
                } else {
                    j++;
                }
            }
            if (oppresult.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                     System.Label.Your_Search_Criteria_Did_Not_Match_Any_Opportunities));
                return;
            }
            total = oppresult.size();
            opps.clear();

            for (Integer i = offSet; 
                i < (((offSet+Integer.valueOf(pageRecord))<oppresult.size())?(offSet+Integer.valueOf(pageRecord)):oppresult.size());
                i ++) {
                OppWrap w = new OppWrap ();
                w.opp = oppresult[i];
                if (primary.containsKey(oppresult[i].AccountId)) {

                    w.phone = convertPhoneNum(primary.get(oppresult[i].AccountId));
                } else if (mobip.containsKey(oppresult[i].AccountId)) {

                    w.phone = convertPhoneNum(mobip.get(oppresult[i].AccountId));
                } else if (ph.containsKey(oppresult[i].AccountId)) {

                    w.phone = convertPhoneNum(ph.get(oppresult[i].AccountId));
                }
                opps.add(w);
            }
        } else{

        }
    }

    // Special case for special mobile / fix phone number
    public String convertPhoneNum (String input) {
        Pattern p = Pattern.compile('([\\d]*)(\\s?(\\[[\\d,E]*\\])?)?');
        Matcher m = p.matcher(input);
        if (m.find()) {
            return m.replaceFirst('$1');
        }
        return '';
    }

    // Queries after the pagination
    public void changePageNo1() {
        system.debug(templeads.size());
        templeadsshow.clear();
        system.debug(templeads.size());
        system.debug(templeadsshow.size());
        total = templeads.size();
        system.debug(total);
        for (Integer i = offSet; 
             i < (((offSet+Integer.valueOf(pageRecord))<templeads.size())?(offSet+Integer.valueOf(pageRecord)):templeads.size()); 
             i++) {
               templeadsshow.add(templeads[i]);
            }
            system.debug(templeads.size());
        system.debug(templeadsshow.size());
    }

    // Queries after the pagination
    public void changePageNo2 () {
        tempoppsshow.clear();
        total1 = tempopps.size();
         for (Integer i = offSet1;
              i < (((offSet1+Integer.valueOf(pageRecord1))<tempopps.size())?(offSet1+Integer.valueOf(pageRecord1)):tempopps.size());
              i++) {

               tempoppsshow.add(tempopps[i]);
            }
    }


    // Adjusts the record size of the page
    public void changeLeadPerPage1 () {
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        changePageNo1();
    }

    // Goes to next page
    public void next1 () {
        offSet += Integer.valueOf(pageRecord);
        currentPageNo += 1;
        changePageNo1();
    }

    // Goes to the previous page
    public void previous1 () {
        if (offSet > 0) {
            offSet -= Integer.valueOf(pageRecord);
        }

        currentPageNo -= 1;
        changePageNo1();
    }

    // Goes to the first page
    public void homePage1 () {
        offSet = 0;
        currentPageNo = 1;
        changePageNo1();
    }

    // Goes to the last page
    public void endPage1 () {
        offSet = (getTotalPageNo1() - 1) * Integer.valueOf(pageRecord);
        currentPageNo = getTotalPageNo1();
        changePageNo1();
    }

    // Aggregates the total number for the records.
    public String getTotal1() {
        if (total > 2000) {
            return String.valueOf(total);
        
        } else {
            return String.valueOf(total);
        }
    }

    // Gets the current page number
    public Integer getCurrentPageNo1 () {
        if (currentPageNo > getTotalPageNo1()) {
            return getTotalPageNo1();

        } else {
            return currentPageNo;
        }
    }

    public Integer getTotalPageNo1 () {
        if (Math.mod(total, Integer.valueOf(pageRecord))  !=  0) {
            return total / Integer.valueOf(pageRecord) + 1;
        } else {
            return total / Integer.valueOf(pageRecord);
        }
    }


    public Boolean getNextEnable1 () {
        if (getCurrentPageNo1() == getTotalPageNo1()) {
            return false;

        } else {
            return true;
        }
    }

    public Boolean getPreviousEnable1 () {
        if (getCurrentPageNo1() == 1 || getTotalPageNo1() == 0) {

            return false;
        } else {

            return true;
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

            return String.valueOf(total);
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
        if (Math.mod(total, Integer.valueOf(pageRecord))  !=  0) {
            return total / Integer.valueOf(pageRecord) + 1;
        } else {
            return total / Integer.valueOf(pageRecord);
        }
    }


    public Boolean getNextEnable() {
        if (getCurrentPageNo() == getTotalPageNo()) {
            return false;

        } else {
            return true;
        }
    }

    public Boolean getPreviousEnable() {
        if (getCurrentPageNo() == 1 || getTotalPageNo() == 0) {

            return false;
        } else {
            return true;
        }
    }

     public void changeLeadPerPage2() {
        offSet1 = 0;
        total1 = 0;
        currentPageNo1 = 1;
        changePageNo2();
    }

    public void next2() {
        offSet1 += Integer.valueOf(pageRecord1);
        currentPageNo1 += 1;
        changePageNo2();
    }

    public void previous2() {
        if (offSet1 > 0) {
            offSet1 -= Integer.valueOf(pageRecord1);
        }

        currentPageNo1 -= 1;
        changePageNo2();
    }

    public void homePage2() {
        offSet1 = 0;
        currentPageNo1 = 1;
        changePageNo2();
    }

    public void endPage2() {
        offSet1 = (getTotalPageNo2() - 1) * Integer.valueOf(pageRecord1);
        currentPageNo1 = getTotalPageNo2();
        changePageNo2();
    }

    public String getTotal2() {
        if (total1 > 2000) {

            return String.valueOf(total1);
        } else {
            return String.valueOf(total1);
        }
    }

    public Integer getCurrentPageNo2() {
        if (currentPageNo1 > getTotalPageNo2()) {
            return getTotalPageNo2();

        } else {
            return currentPageNo1;
        }
    }

    public Integer getTotalPageNo2() {
        if (Math.mod(total1, Integer.valueOf(pageRecord1)) != 0) {
            return total1 / Integer.valueOf(pageRecord1) + 1;
        } else {
            return total1 / Integer.valueOf(pageRecord1);
        }
    }

    public Boolean getNextEnable2() {
        if (getCurrentPageNo2() == getTotalPageNo2()) {
            return false;

        } else {
            return true;
        }
    }

    public Boolean getPreviousEnable2() {
        if (getCurrentPageNo2() == 1 || getTotalPageNo2() == 0) {
            return false;

        } else {
            return true;
        }
    }


    // Batch call out unit class
    public class callItem {
        public String customerName { get; set; }
        public String customerNo { get; set; }
        public String nation { get; set; }
        public String filiale { get; set; }
        public String phone { get; set; }
    }

    // Batch call out information class
    public class callbatch {
        public String batchName { get; set; }
        public String batchId { get; set; }
        public String team { get; set; }
        public String popSign { get; set; }
        public Boolean batchPhoneMassRemove { get; set; }
        public Boolean batchCNMassRemove { get; set; }
        public Boolean teamPhoneMassRemove { get; set; }
        public Boolean teamCNMassRemove { get; set; }
        public String workNo { get; set; }
        public List<callItem> customersDatas { get; set; }

        public callbatch () {
            customersDatas = new List<callItem> ();
            batchPhoneMassRemove = false;
            batchCNMassRemove = false;
            teamPhoneMassRemove = false;
            teamCNMassRemove = false;
        }
    }

    // Encrypted phone algorithm
    private String encryptPhone(String val) {

        // Gets the secret key
        Map<String,CallCenterBase64EncodeKey__c> cmap = CallCenterBase64EncodeKey__c.getAll();
        CallCenterBase64EncodeKey__c ccbe = cmap.get('CallCenterBatchCallOut');
        String clearText = val;
        Blob key = EncodingUtil.base64Decode(ccbe.key__c);
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(clearText));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        return encodedCipherText;
    }

    // Submits the batch job
    public void save() {
        try{
            upsert batchItem;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                 System.Label.Error_Batch_Operation + e.getMessage()));
            return;
        }
    }

    // Call-out the batch call-out interface to post data to call center system
    public void submit () {
        String logString = '';
        try{
            if (batchItem.Id == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Error_Batch_Operation));
                return;
            }
            batchItem = [SELECT Id, BatchItemName__c, Name, Team__c, batchPhoneMassRemove__c, 
                                batchCNMassRemove__c, teamPhoneMassRemove__c, teamCNMassRemove__c, group__c, popupsign__c
                         FROM BatchCallOutManagementItem__c
                         WHERE Id = :batchItem.Id];
            List<CallLog_History__c> chlist = new List<CallLog_History__c> ();
            callitemlist.clear();
            callbatch cb = new callbatch ();

            for (LeadOBJ w : templeads) {

                callItem ci = new callItem();
                ci.customerName = w.Name;
                ci.customerNo = w.Id;
                ci.filiale = w.Business_Line;
                ci.nation = w.Project;
                ci.phone = this.encryptPhone(w.phone);
                callitemlist.add(ci);
                CallLog_History__c ch = new CallLog_History__c();
                ch.BatchCallOut__c = batchItem.Id;
                ch.Lead__c = w.Id;
                ch.Type__c= '批量外呼';
                chlist.add(ch);
            }

            for (OppOBJ w : tempopps) {
                callItem ci = new callItem();
                ci.customerName = w.Name;
                ci.customerNo = w.Id;
                ci.filiale = w.Department;
                ci.nation = w.Project;
                ci.phone = this.encryptPhone(w.phone);
                callitemlist.add(ci);
                CallLog_History__c ch = new CallLog_History__c();
                ch.BatchCallOut__c = batchItem.Id;
                ch.Opportunity__c = w.Id;
                ch.Type__c= '批量外呼';
                chlist.add(ch);
            }
            User u = [SELECT Id, CCAgentId__c FROM User WHERE Id= :UserInfo.getUserId()];

            cb.batchName = batchItem.BatchItemName__c;
            cb.batchId = batchItem.Name;
            cb.team = TeamMap.get(batchItem.Team__c);
            cb.popSign = 'sf';
            cb.batchPhoneMassRemove = batchItem.batchPhoneMassRemove__c;
            cb.batchCNMassRemove = batchItem.batchCNMassRemove__c;
            cb.teamPhoneMassRemove = batchItem.teamPhoneMassRemove__c;
            cb.teamCNMassRemove = batchItem.teamCNMassRemove__c;
            cb.workNo = u.CCAgentId__c;
            cb.customersDatas = callitemlist;
            String jsonInput = Json.serialize(cb).replace('null', '""');
            Map<String, Object> jsonInputMap = (Map<String, Object>) System.JSON.deserializeUntyped(jsonInput);
            jsonInputMap.put('group',batchItem.group__c);
            jsonInputMap.put('callInType', TypeMap.get(batchItem.popupsign__c));
            jsonInput = Json.serialize(jsonInputMap).replace('null', '""');
            Map<String,CallCenterBase64EncodeKey__c> cmap = CallCenterBase64EncodeKey__c.getAll();
            CallCenterBase64EncodeKey__c ccbe = cmap.get('CallCenterBatchCallOut');
            String body = 'key=' + EncodingUtil.urlEncode(ccbe.key__c, 'UTF-8') + '&json_str=' + EncodingUtil.urlEncode(jsonInput, 'UTF-8');
            system.debug('body:' + body);
            CallOutMethod__c cm = CallOutMethod__c.getValues('CallOutBatch');
            String endpoint =  cm.EndPoint__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest ();
            HttpResponse response = new HttpResponse ();
            request.setEndPoint(endpoint);
            request.setBody(body);
            request.setMethod('POST');
            request.setTimeout(120000);
            response = http.send(request);
            logString =  response.getBody();

            System.debug(LoggingLevel.INFO, '*** response.getBody(): ' + response.getBody());
            List<Attachment> atts = new List<Attachment> ();
            Attachment attobject = new Attachment ();
            attobject.Name = 'body.json';
            attobject.Body = Blob.valueOf(jsonInput);
            attobject.ParentId = batchItem.Id;
            atts.add(attobject);
            Attachment attobject1 = new Attachment ();
            attobject1.Name = 'response.json';
            attobject1.Body = Blob.valueOf(response.getBody());
            attobject1.ParentId = batchItem.Id;
            atts.add(attobject1);
            insert atts;
            respWrap ret = (respWrap) JSON.deserialize(response.getBody(), respWrap.class);
            if (ret.result == 'success') {
                if (chlist.size() > 0) {
                    insert chlist;
                }
                clearpage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                     System.Label.Batch_Operation_Submitted_Successfully));
                return;
            } else{
                String errorMessages = '提交批量外呼出错,出错原因:' + ret.reason + 
                                       ' </br><table border="0" width="100%">' +
                                            '<tr>' +
                                                '<td>名称</td>' +
                                                '<td>对象ID</td>' +
                                                '<td>意向业务</td>' +
                                                '<td>项目</td>' +
                                            '</tr>';
                for (callItem i : ret.errorCustomersDatas) {
                    errorMessages  +=
                                    '<tr>' +
                                         '<td>'+i.customerName+'</td>' +
                                        '<td>' + i.customerNo + '</td>' +
                                        '<td>' + i.filiale + '</td>' +
                                        '<td>' + i.nation + '</td>' +
                                    '</tr>';
                }

                if (batchItem.Id  != null) {
                    delete batchItem;
                }
                batchItem = new BatchCallOutManagementItem__c ();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages));
                return;
            }
        } catch (Exception e) {
            if (batchItem.Id != null) {
                delete batchItem;
            }
            batchItem = new BatchCallOutManagementItem__c();
            InteractionLogUtil.CreateLog('BatchCalloutCreateResponse',logString);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 System.Label.Error_Batch_Operation + e.getMessage()));
            return;
        }
    }

    // Resets the page
    public void clearpage () {
        batchItem = new BatchCallOutManagementItem__c ();
        callitemlist = new List<callItem> ();
        opptype = '考培';
        dataType = 'Lead';
        followupcondition = '';
        itemstatuscondition = '';
        leads = new List<LeadWrap> ();
        opps = new List<OppWrap> ();
        templeads = new List<LeadOBJ> ();
        tempopps = new List<OppOBJ> ();
        templeadsshow = new List<LeadOBJ> ();
        tempoppsshow = new List<OppOBJ> ();
        isShow = true;
        filterLead = new Lead();
        filterOpp = new Opportunity();
        filterOpp.RecordTypeId = rmap.get('Counselling');
        sevendaynocomplete = false;
        lowlevel = false;
        otherUncomplete = false;
        lost = false;
        pageRecord = '25';
        pageRecord1 = '25';
    }

    public class respWrap{
        public String result;
        public String batchId;
        public String batchName;
        public String reason;
        public List<callItem> errorCustomersDatas;
    }

    public void cancel() {
        offSet = 0;
        total = 0;
        currentPageNo = 1;
        pageRecord = '25';
        filterLead = new Lead();
        followupcondition = null;
        itemstatuscondition = null;
        projectcondition = null;
        filterOpp = new Opportunity();
        filterOpp.RecordTypeId = rmap.get('TestPrep');
        sevendaynocomplete = false;
        lowlevel = false;
        otherUncomplete = false;
        lost = false;
        opptype = '考培';
        leads.clear();
        opps.clear();
        isShow = true;
    }

    public Map<String, String> TypeMap = new Map<String, String>{
        '考培'=>'kp',
        '留学'=>'lx'
    };

    public Map<String, String> TeamMap = new Map<String, String>{
        '400'=>'400',
        '留学'=>'lx',
        '考培'=>'kp',
        '兼职团队'=>'parttime'
    };

    // Getting the campaign channels
    private void getCampaignChannels() {
        marketingChannelLv1List = new List<SelectOption> ();
        marketingChannelLv2List = new List<SelectOption> ();
        marketingChannelLv3List = new List<SelectOption> ();

        Set<String> lv1Set = new Set<String> ();

        lv1Lv2Map = new Map<String, Set<String>> ();
        lv1Lv2Lv3Map = new Map<String, Set<String>> ();

        // get LV1, LV2, Business Line, City, LV3 mappings
        for (Campaign_Channel__c cc : [
                SELECT  Marketing_Channel_Lv1__c,
                        Marketing_Channel_Lv2__c,
                        Marketing_Channel_Lv3__c,
                        Business_line__c,
                        City__c
                FROM    Campaign_Channel__c
                WHERE   Active__c = true
                ORDER BY Marketing_Channel_Lv1__c, Marketing_Channel_Lv2__c, Marketing_Channel_Lv3__c]) {
            if (String.isNotBlank(cc.Marketing_Channel_Lv1__c)) {
                lv1Set.add(cc.Marketing_Channel_Lv1__c);

                if (String.isNotBlank(cc.Marketing_Channel_Lv2__c)) {
                    if (!lv1Lv2Map.containsKey(cc.Marketing_Channel_Lv1__c)) {
                        lv1Lv2Map.put(cc.Marketing_Channel_Lv1__c, new Set<String> ());
                    }
                    lv1Lv2Map.get(cc.Marketing_Channel_Lv1__c).add(cc.Marketing_Channel_Lv2__c);

                    String lv1Lv2 = cc.Marketing_Channel_Lv1__c + '-' + cc.Marketing_Channel_Lv2__c;
                    if (!lv1Lv2Lv3Map.containsKey(lv1Lv2)) {
                        lv1Lv2Lv3Map.put(lv1Lv2, new Set<String> ());
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
        system.debug(lv1);
        system.debug(lv1Lv2Map);
        for (String lv2 : lv1Lv2Map.get(lv1)) {
            marketingChannelLv2List.add(new SelectOption(lv2, lv2));
        }
        system.debug(marketingChannelLv2List);
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

    // Searches the owner
    @RemoteAction
    public static List<User>  searchUser(String param,String param1) {
        string queryterm = '%'+param+'%';
        String queryString = 'SELECT Id, Name ' +
                             'FROM User ' +
                             'WHERE (Profile.Name = \'集团市场部呼叫中心专员\' OR ' +
                                    'Profile.Name = \'集团市场部呼叫中心主管\') ' +
                             'AND (Name LIKE :queryterm OR UserName LIKE :queryterm)';

        Set<String> ids = new Set<String> ();
        if (param1 != '') {
            List<String> arr = param1.split(',');
            for (String s : arr) {
                ids.add(s);
            }
        }
        if (ids.size() > 0) {
            queryString += ' AND Id not IN : ids';
        }
        queryString += ' LIMIT 100';
        List<User> userList = Database.query(queryString);
        return userList;
    }

    // Searches campaign
    @RemoteAction
    public static List<Campaign> searchCampaign (String param, String param1) {
        Map<String, object> pm = (Map<String, Object>) JSON.deserializeUntyped(param);
        String l1 = String.valueOf(pm.get('lv1'));
        String l2 = String.valueOf(pm.get('lv2'));
        String l3 = String.valueOf(pm.get('lv3'));
        String term = String.valueOf(pm.get('term'));
        Set<String> ids = new Set<String> ();
        System.debug('LoggingLevel.INFO, *** param1: ' + param1);

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
        sqlString += ' LIMIT 100';
        List<Campaign> clist = Database.query(sqlString);
        return clist;
    }

    // Gets the main class information from Prepsmith
    public static Map<String, String> fetchAllFaculties() {
        try{
            Map<String, String> facultyMap = new Map<String, String> ();
            CallOutMethod__c cm = CallOutMethod__c.getValues('PrepSmithAPIStagingCriteria');
            String endpoint =  cm.EndPoint__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndPoint(endpoint);
            request.setHeader('Authorization', 'OUkxMStDNCs1OlVNP0s/Tl46MzhMREk4TlE1VEQ0KDFXRisyUDhPezxCJDk6Tisz');
            request.setMethod('GET');
            request.setTimeout(120000);
            response = http.send(request);
            Map<String, Object>initdata =(Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object>data = (Map<String, Object>)initdata.get('data');
            List<object> faculties = (List<object>)data.get('faculty');
            for (Object o : faculties) {
                Map<string, object> obj = (Map<String, object>)o;
                facultyMap.put(String.valueOf(obj.get(System.Label.Language_Name)), String.valueOf(obj.get('uuid')));
            }

            return facultyMap;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Error_Fetching_Faculties));
            return new Map<String, String> ();
        }
    }

    public class LeadOBJ {
        public String Name { get; set; }
        public String Id { get; set; }
        public String Business_Line { get; set; }
        public String Project { get; set; }
        public String phone { get; set; }
        public String Campaign { get; set; }
        public String Intended_City { get; set; }
        public String Consultation_Mode { get; set; }
        public String Followup_Result { get; set; }
        public String CreatedDate { get; set; }

        public LeadOBJ(LeadWrap l) {
            Name = l.leadObj.Name;
            Id = l.leadObj.Id;
            Business_Line = l.leadObj.Business_Line__c;
            Project = l.leadObj.Project__c;
            phone = l.phone;
            Intended_City = l.leadObj.Intended_City__c;
            Consultation_Mode = l.leadObj.Consultation_Mode__c;
            Followup_Result = l.leadObj.Followup_Result__c;
            CreatedDate = l.leadObj.CreatedDate.format();
        }
    }

    public class OppOBJ {
        public String Name { get; set; }
        public String Id { get; set; }
        public String Department { get; set; }
        public String Project { get; set; }
        public String phone { get; set; }
        public String RecordTypeId { get; set; }
        public String Intended_City { get; set; }
        public String Consultation_Mode { get; set; }
        public String StageName { get; set; }
        public String CreatedDate { get; set; }

        public OppOBJ(OppWrap oppw) {
            Name = oppw.opp.Name;
            Id = oppw.opp.Id;
            Department = oppw.opp.Department__c;
            Project = oppw.opp.Project__c;
            phone = oppw.phone;
            Intended_City = oppw.opp.Intended_City__c;
            Consultation_Mode = oppw.opp.Consultation_Mode__c;
            StageName = oppw.opp.StageName;
            CreatedDate = oppw.opp.CreatedDate.format();
        }
    }

}