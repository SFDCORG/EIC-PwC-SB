@isTest
private class BatchCalloutCreateTest {

    @isTest static void method () {

        User u = [SELECT Id FROM User WHERE Id = :Userinfo.getUserId()];
        System.runAs(u) {

           CreateUserUtil.CreateUserForAppointment();
        }

        List<Campaign_Channel__c> ccList = new List<Campaign_Channel__c> ();
        Campaign_Channel__c cc1 = new Campaign_Channel__c ();
        cc1.City__c = '集团';
        cc1.Business_line__c = '全部';
        cc1.Marketing_Channel_Lv1__c = '合作招生';
        cc1.Marketing_Channel_Lv2__c = '线下合作';
        cc1.Marketing_Channel_Lv3__c = '市场合作';
        ccList.add(cc1);
        Campaign_Channel__c cc2 = new Campaign_Channel__c ();
        cc2.City__c = '集团';
        cc2.Business_line__c = '全部';
        cc2.Marketing_Channel_Lv1__c = 'SNS';
        cc2.Marketing_Channel_Lv2__c = '集团';
        cc2.Marketing_Channel_Lv3__c = '官方微信';
        ccList.add(cc2);
        Campaign_Channel__c cc3 = new Campaign_Channel__c ();
        cc3.City__c = '集团';
        cc3.Business_line__c = '全部';
        cc3.Marketing_Channel_Lv1__c = 'SNS';
        cc3.Marketing_Channel_Lv2__c = '集团';
        cc3.Marketing_Channel_Lv3__c = '官方微博';
        ccList.add(cc3);
        insert ccList;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        Campaign cam = TestObjectFactory.createCampaign('百度测试', '全部', 'SNS', '集团', '官方微博');
        Campaign cam1 = TestObjectFactory.createCampaign('谷歌测试', '全部', 'SNS', '集团', '官方微博');
        Lead l = TestObjectFactory.createLead(cam, '上海', true);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        Test.setCurrentPage(Page.BatchCalloutCreate);
        BatchCalloutCreateController ctl = new BatchCalloutCreateController ();

        List<User> usrs = BatchCalloutCreateController.searchUser(UserInfo.getUserName(), '');
        System.assert(usrs.size() == 0);
        usrs = BatchCalloutCreateController.searchUser('sophiezhou@eic.com.testcode', '');
        Id uid = usrs[0].Id;
        System.assert(usrs.size() == 1);
        usrs = BatchCalloutCreateController.searchUser('sophiezhou@eic.com.testcode', uid);
        System.assert(usrs.size() == 0);

        String param = '{"lv1":"SNS", "lv2":"集团", "lv3":"官方微博", "term":"百度测试"}';
        List<Campaign> cams = BatchCalloutCreateController.searchCampaign(param, '');
        System.assert(cams.size() == 1);
        cams = BatchCalloutCreateController.searchCampaign(param, cam.Id);
        System.assert(cams.size() == 0);

        ctl.selectedConsultMode = '集团TMK外呼';
        ctl.selectedIntendCity = '上海';
        ctl.selectedBSLine = Constants.BL_COUSELLING_NAME;
        ctl.selectedProject = '美国';
        ctl.selectedFollowUp = '未跟进';
        ctl.SelectedItemStatus = '全未转化-休眠自动';
        ctl.selectedOpptype = Constants.OPP_RT_COUNSELLING_NAME;
        ctl.selectedIntendDepart = '美国部';
        ctl.selectedOppStage = '待分配';
        ctl.selectedFaculties = '824be818-09a0-4609-bfd8-eea757ba61cb';
        ctl.selectedHtmlFaculties = '商科';
        ctl.selectedHtmlOwnerSource = [SELECT Id, Name FROM User WHERE Id = :Userinfo.getUserId()].Name;
        ctl.selectedOwnerSource = Userinfo.getUserId();
        ctl.selectedCampaignSource = cam.Id;
        ctl.selectedHtmlCampaignSource = cam.Name;
        ctl.getConsultMode();
        ctl.getIntendCity();
        ctl.getBSLine();
        ctl.getProject();
        ctl.getFollowUp();
        ctl.getItemStatus();
        ctl.getOppTypes();
        ctl.getIntendDepart();
        ctl.getOppStage();
        ctl.getselectedFacultySource();
        ctl.getselectedOwnerItems();
        ctl.getselectedCampaignItems();
        ctl.getselectedFaculty();
        ctl.getSelectedConsultModeVal();
        ctl.getSelectedIntendCityVal();
        ctl.getSelectedBSLineVal();
        ctl.getSelectedProjectVal();
        ctl.getSelectedFollowUpVal();
        ctl.getSelectedItemStatusVal();
        ctl.getSelectedOppTypeVal();
        ctl.getSelectedOppStageVal();
        ctl.getSelectedIntendDepartVal();
        ctl.getPageSizePerPage();
        ctl.getDataTypeItems();
 
        ctl.lv1 = 'SNS';
        ctl.getLv2ByLv1();
        ctl.lv2 = '集团';
        ctl.getLv3ByLv1Lv2();
  
        ctl.filterLead.Birthday__c = Date.Today().addDays(1);
        ctl.filterLead.Schedule_Abroad_Year__c = Date.Today().addDays(-1);
        ctl.searchLead();
  
        ctl.filterLead.Birthday__c = Date.Today().addDays(-1);
        ctl.filterLead.Schedule_Abroad_Year__c = Date.Today().addDays(1);
        ctl.searchLead();
 
        Test.stopTest();
    }

    @isTest static void method1 () {

        BatchCalloutCreateController ctl = BatchCalloutCreateTest.publicLeadTest();
        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'CallOutBatch';
        calloutmethod.EndPoint__c = 'http://testCallout/CallOutBatch';
        insert calloutmethod;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        ctl.submit();
        BatchCalloutCreateController.fetchAllFaculties();
        Test.stopTest();
        ctl.cancel();
        ctl.changeDataType();
    }

    @isTest static void method2() {

        BatchCalloutCreateController ctl = BatchCalloutCreateTest.publicLeadTest();
        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'CallOutBatch';
        calloutmethod.EndPoint__c = 'http://testCallout/CallOutBatchfail';
        insert calloutmethod;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        ctl.submit();
        Test.stopTest();
        ctl.clearpage();
    }

     @isTest static void method3() {

        BatchCalloutCreateController ctl = BatchCalloutCreateTest.publicLeadTest();
        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'CallOutBatch';
        calloutmethod.EndPoint__c = 'http://testCallout/CallOutBatchException';
        insert calloutmethod;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        ctl.submit();
        Test.stopTest();
    }

    @isTest static void method4() {

        BatchCalloutCreateController ctl = BatchCalloutCreateTest.publicOppTest();
        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'CallOutBatch';
        calloutmethod.EndPoint__c = 'http://testCallout/CallOutBatch';
        insert calloutmethod;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator ());
        ctl.submit();
        List<Id> ids = new List<Id> (ctl.selOppIds);
        System.currentPageReference().getParameters().put('oppid', ids[0]);
        ctl.deleteOpp();
        ctl.submitbatch();
        Test.stopTest();
    }

    public static BatchCalloutCreateController publicOppTest () {

        List<Campaign_Channel__c> ccList = new List<Campaign_Channel__c> ();
        Campaign_Channel__c cc1 = new Campaign_Channel__c ();
        cc1.City__c = '集团';
        cc1.Business_line__c = '全部';
        cc1.Marketing_Channel_Lv1__c = '合作招生';
        cc1.Marketing_Channel_Lv2__c = '线下合作';
        cc1.Marketing_Channel_Lv3__c = '市场合作';
        ccList.add(cc1);
        Campaign_Channel__c cc2 = new Campaign_Channel__c ();
        cc2.City__c = '集团';
        cc2.Business_line__c = '全部';
        cc2.Marketing_Channel_Lv1__c = 'SNS';
        cc2.Marketing_Channel_Lv2__c = '集团';
        cc2.Marketing_Channel_Lv3__c = '官方微信';
        ccList.add(cc2);
        Campaign_Channel__c cc3 = new Campaign_Channel__c ();
        cc3.City__c = '集团';
        cc3.Business_line__c = '全部';
        cc3.Marketing_Channel_Lv1__c = 'SNS';
        cc3.Marketing_Channel_Lv2__c = '集团';
        cc3.Marketing_Channel_Lv3__c = '官方微博';
        ccList.add(cc3);
        insert ccList;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        CallCenterBase64EncodeKey__c ccb = new CallCenterBase64EncodeKey__c ();
        ccb.Name = 'CallCenterBatchCallOut';
        ccb.key__c = 'L/Nm426U37REQxdstSF7PQ==';
        insert ccb;

        Campaign cam = TestObjectFactory.createCampaign('百度测试', '全部', 'SNS', '集团', '官方微博');
        Id recordTypeId = Utils.getRecordTypeId('Account', 'EIC Account');
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeId);
        insert acc;
        System.debug('**XX'+acc.Id);
        Contact_EIC__c contact = new Contact_EIC__c (
            Name = 'Test Account',
            Account__c = acc.Id,
            Contact_Type__c = '手机',
            UniqueContact__c = '13200998787');
        insert contact;

        Id cRTId = Utils.getRecordTypeId('Opportunity', 'Counselling');
        Id tRTId = Utils.getRecordTypeId('Opportunity', 'testprep');
        List<Opportunity> opps = new List<Opportunity> ();
        Opportunity counsellingOpp = new Opportunity(
            Name = 'counsellingOpp',
            RecordTypeId = cRTId,
            AccountId = acc.Id,
            CloseDate = System.Today() + 30,
            Intended_City__c = '北京',
            Intended_Office__c = 'N/A',
            Department__c = '英爱部',
            Project__c = '英国',
            StageName = '顾问跟进',
            Consultation_Mode__c = '400呼入呼叫中心',
            Level_4_Promotion_Channel__c=cam.Id);
        opps.add(counsellingOpp);
        Opportunity counsellingOpp2 = new Opportunity(
            Name = 'counsellingOpp2',
            RecordTypeId = cRTId,
            AccountId = acc.Id,
            CloseDate = System.Today() + 30,
            Intended_City__c = '上海',
            Intended_Office__c = 'N/A',
            Department__c = '英爱部',
            Project__c = '英国',
            StageName = '流失',
            Consultation_Mode__c = '400呼入呼叫中心',
            Level_4_Promotion_Channel__c=cam.Id);
        opps.add(counsellingOpp2);
        Opportunity testprepOpp = new Opportunity(
            Name = 'testprepOpp',
            RecordTypeId = tRTId,
            AccountId = acc.Id,
            CloseDate = System.Today() + 30,
            Intended_City__c = '北京',
            Intended_Office__c = 'N/A',
            Department__c = '考试培训部门',
            Project__c = 'SAT',
            StageName = '低星资源池',
            Consultation_Mode__c = '400呼入呼叫中心',
            Level_4_Promotion_Channel__c=cam.Id);
        opps.add(testprepOpp);
        insert opps;
        Appoitment__c app1 = new Appoitment__c ();
        app1.RecordTypeId = [Select Id From RecordType Where SObjectType='Appoitment__c' And DeveloperName='Invitation'].Id;
        app1.Opportunity__c = counsellingOpp.Id;
        app1.Assign_To__c = UserInfo.getUserId();
        app1.Due_Date__c = System.Today()-10;
        app1.Due_Time__c = '10:00';
        app1.Appointment_Type__c = '首次到访邀约';
        insert app1;
        Change_Log__c ch = new Change_Log__c ();
        ch.Opportunity__c = testprepOpp.Id;
        ch.Type__c= '低星资源池';
        insert ch;
        Intended_School__c sch = new Intended_School__c ();
        sch.UUID_Degree__c = 'xxx';
        sch.UUID_Faculty__c = '824be818-09a0-4609-bfd8-eea757ba61cb';
        sch.UUID_Major__c = 'xxx';
        sch.UUID_School__c = 'xxx';
        sch.Opportunity__c = counsellingOpp.Id;
        insert sch;

        //init controller
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.setCurrentPage(Page.BatchCalloutCreate);
        BatchCalloutCreateController ctl = new BatchCalloutCreateController();

        //with faculities
        ctl.selectedFaculties = '商科';
        //ctl.sevendaynocomplete = true;
        ctl.selectedOppStage = '顾问跟进,流失,低星资源池';
        ctl.selectedOpptype = Constants.OPP_RT_COUNSELLING_NAME;
        ctl.selectedCampaignSource = cam.Id;
        ctl.selectedOwnerSource = Userinfo.getUserId();
        ctl.selectedIntendCity = '北京';
        ctl.selectedIntendDepart = '英爱部,考试培训部门';
        ctl.selectedProject = '英国,SAT';
        ctl.selectedConsultMode ='400呼入呼叫中心';
        ctl.filterLead.Birthday__c =  Date.Today().addDays(-1);
        ctl.filterLead.Schedule_Abroad_Year__c = Date.Today().addDays(1);
        ctl.searchOpp();

        ctl.selectedFaculties = '';
        ctl.selectedOppStage = '低星资源池';
        ctl.selectedOpptype = Constants.OPP_RT_TESTPREP_NAME;
        ctl.selectedCampaignSource = cam.Id;
        ctl.selectedOwnerSource = Userinfo.getUserId();
        ctl.selectedIntendCity = '北京';
        ctl.selectedIntendDepart = '考试培训部门';
        ctl.selectedProject = 'SAT';
        ctl.selectedConsultMode ='400呼入呼叫中心';
        ctl.filterLead.Birthday__c =  Date.Today().addDays(-1);
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.filterLead.Converted_Date__c = Date.Today().addDays(-1);
        ctl.filterLead.Transferred_Date__c = Date.Today().addDays(1);
        ctl.searchOpp();

        ctl.selectedFaculties = '';
        ctl.selectedOppStage = '低星资源池';
        ctl.selectedOpptype = Constants.OPP_RT_TESTPREP_NAME;
        ctl.selectedCampaignSource = cam.Id;
        ctl.selectedOwnerSource = Userinfo.getUserId();
        ctl.selectedIntendCity = '北京';
        ctl.selectedIntendDepart = '考试培训部门';
        ctl.selectedProject = 'SAT';
        ctl.selectedConsultMode ='400呼入呼叫中心';
        ctl.filterLead.Birthday__c =  Date.Today().addDays(-1);
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.filterLead.Converted_Date__c = Date.Today().addDays(-1);
        ctl.filterLead.Transferred_Date__c = null;
        ctl.searchOpp();

        ctl.selectedFaculties = '';
        ctl.sevendaynocomplete = true;
        ctl.selectedOppStage = '';
        ctl.selectedOpptype = Constants.OPP_RT_COUNSELLING_NAME;
        ctl.selectedCampaignSource = cam.Id;
        ctl.selectedOwnerSource = Userinfo.getUserId();
        ctl.selectedIntendCity = '北京';
        ctl.selectedIntendDepart = '英爱部';
        ctl.selectedProject = '英国';
        ctl.selectedConsultMode ='400呼入呼叫中心';
        ctl.filterLead.Birthday__c =  null;
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.filterLead.Converted_Date__c = null;
        ctl.filterLead.Transferred_Date__c = null;
        ctl.searchOpp();


        ctl.selectedFaculties = '';
        ctl.selectedOppStage = '低星资源池';
        ctl.selectedOpptype = Constants.OPP_RT_TESTPREP_NAME;
        ctl.selectedCampaignSource = cam.Id;
        ctl.selectedOwnerSource = Userinfo.getUserId();
        ctl.selectedIntendCity = '北京';
        ctl.selectedIntendDepart = '考试培训部门';
        ctl.selectedProject = 'SAT';
        ctl.selectedConsultMode ='400呼入呼叫中心';
        ctl.filterLead.Birthday__c =  null;
        ctl.filterLead.Schedule_Abroad_Year__c = Date.Today().addDays(1);
        ctl.filterLead.Converted_Date__c = null;
        ctl.filterLead.Transferred_Date__c = Date.Today().addDays(1);
        ctl.searchOpp();
        ctl.getoppStatus();

        ctl.selectedFaculties = '';
        ctl.sevendaynocomplete = false;
        ctl.selectedOppStage = '';
        ctl.selectedOpptype = '';
        ctl.selectedCampaignSource = '';
        ctl.selectedOwnerSource = '';
        ctl.selectedIntendCity = '';
        ctl.selectedIntendDepart = '';
        ctl.selectedProject = '';
        ctl.selectedConsultMode ='';
        ctl.filterLead.Birthday__c =  null;
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.filterLead.Converted_Date__c = null;
        ctl.filterLead.Transferred_Date__c = null;
        ctl.searchOpp();
        ctl.getoppStatus();

        ctl.opps[0].isSelected = true;
        ctl.gettemptabledisplay();
        ctl.addOppToBatch();
        ctl.gettemptabledisplay();

        ctl.next2();
        ctl.previous2();
        ctl.homePage2();
        ctl.endPage2();
        ctl.getTotal2();
        ctl.getCurrentPageNo2();
        ctl.getTotalPageNo2();
        ctl.getNextEnable2();
        ctl.getPreviousEnable2();

        ctl.save();
        return ctl;
    }

    public static BatchCalloutCreateController publicLeadTest() {
        List<Campaign_Channel__c> ccList = new List<Campaign_Channel__c> ();
        Campaign_Channel__c cc1 = new Campaign_Channel__c ();
        cc1.City__c = '集团';
        cc1.Business_line__c = '全部';
        cc1.Marketing_Channel_Lv1__c = '合作招生';
        cc1.Marketing_Channel_Lv2__c = '线下合作';
        cc1.Marketing_Channel_Lv3__c = '市场合作';
        ccList.add(cc1);
        Campaign_Channel__c cc2 = new Campaign_Channel__c ();
        cc2.City__c = '集团';
        cc2.Business_line__c = '全部';
        cc2.Marketing_Channel_Lv1__c = 'SNS';
        cc2.Marketing_Channel_Lv2__c = '集团';
        cc2.Marketing_Channel_Lv3__c = '官方微信';
        ccList.add(cc2);
        Campaign_Channel__c cc3 = new Campaign_Channel__c ();
        cc3.City__c = '集团';
        cc3.Business_line__c = '全部';
        cc3.Marketing_Channel_Lv1__c = 'SNS';
        cc3.Marketing_Channel_Lv2__c = '集团';
        cc3.Marketing_Channel_Lv3__c = '官方微博';
        ccList.add(cc3);
        insert ccList;

        CallOutMethod__c calloutmethod = new CallOutMethod__c ();
        calloutmethod.Name = 'PrepSmithAPIStagingCriteria';
        calloutmethod.EndPoint__c = 'http://testCallout/Criteria';
        insert calloutmethod;

        CallCenterBase64EncodeKey__c ccb = new CallCenterBase64EncodeKey__c ();
        ccb.Name = 'CallCenterBatchCallOut';
        ccb.key__c = 'L/Nm426U37REQxdstSF7PQ==';
        insert ccb;

        Campaign cam = TestObjectFactory.createCampaign('百度测试', '全部', 'SNS', '集团', '官方微博');
        System.assert(cam.Id != null);
        Campaign cam1 = TestObjectFactory.createCampaign('谷歌测试', '全部', 'SNS', '集团', '官方微博');
        Lead l = new Lead(
                Lastname = 'Test',
                Firstname = 'A',
                MobilePhone = '19099990000',
                Area_Code__c = '021',
                Phone = '99999999',
                Campaign__c = cam.Id,
                Consultation_Mode__c = '集团TMK外呼',
                Intended_City__c = '上海',
                Is_Counselling__c = TRUE,
                Is_Testprep__c = TRUE,
                Counselling_Project__c = '美国;英国',
                Testprep_Project__c = 'SAT;GRE',
                GPA__c = 80,
                College__c = 'Test University',
                Company = 'EIC TEST');
        insert l;
        System.assert(l.Id!=null);

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.setCurrentPage(Page.BatchCalloutCreate);
        BatchCalloutCreateController ctl = new BatchCalloutCreateController();

        //test Lead search
        //1、no follow up result and no status  and no createdDate
        ctl.selectedConsultMode = '集团TMK外呼';
        ctl.selectedIntendCity = '上海';
        ctl.selectedBSLine = Constants.BL_COUSELLING_NAME + ',' + Constants.BL_TESTPREP_NAME;
        ctl.selectedProject = '美国,SAT';
        ctl.selectedFollowUp = '';
        ctl.SelectedItemStatus = '';
        ctl.filterLead.Birthday__c =  null;
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.searchLead();
        System.assert(ctl.leads.size() == 0);

        //2、followup result = 未跟进 and no status and CreatedDate has start date
        ctl.selectedConsultMode = '集团TMK外呼';
        ctl.selectedIntendCity = '上海';
        ctl.selectedBSLine = Constants.BL_COUSELLING_NAME + ',' + Constants.BL_TESTPREP_NAME;
        ctl.selectedProject = '美国,SAT';
        ctl.selectedFollowUp = '未跟进';
        ctl.SelectedItemStatus = '';
        ctl.filterLead.Birthday__c =  Date.Today().addDays(-1);
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.searchLead();
        System.assert(ctl.leads.size() == 1);
        ctl.selectedFollowUp = '未跟进,无人接听-1';
        ctl.searchLead();
        ctl.selectedFollowUp = '无人接听-1';
        ctl.searchLead();
        ctl.selectedFollowUp = '无意向';
        ctl.searchLead();

        //3、followup result= 未跟进 and status = 全未转化-休眠自动 and CreatedDate has end date
        ctl.selectedConsultMode = '集团TMK外呼';
        ctl.selectedIntendCity = '上海';
        ctl.selectedBSLine = Constants.BL_COUSELLING_NAME + ',' + Constants.BL_TESTPREP_NAME;
        ctl.selectedProject = '美国,SAT';
        ctl.selectedFollowUp = '未跟进';
        ctl.SelectedItemStatus = '全未转化-休眠自动';
        ctl.filterLead.Birthday__c = null ;
        ctl.filterLead.Schedule_Abroad_Year__c = Date.Today().addDays(1);
        ctl.searchLead();
        System.assert(ctl.leads.size() == 1);
        //have selected Id
        ctl.selectedFollowUp = '未跟进,无人接听-1';
        ctl.searchLead();
        ctl.selectedFollowUp = '无人接听-1';
        ctl.searchLead();
        ctl.selectedFollowUp = '无意向';
        ctl.searchLead();

        //4、no followup result and status = 全未转化-休眠自动 and CreatedDate has both start and end date
        ctl.selectedConsultMode = '集团TMK外呼';
        ctl.selectedIntendCity = '上海';
        ctl.selectedBSLine = Constants.BL_COUSELLING_NAME + ',' + Constants.BL_TESTPREP_NAME;
        ctl.selectedProject = '美国,SAT';
        ctl.selectedFollowUp = '';
        ctl.SelectedItemStatus = '全未转化-休眠自动';
        ctl.filterLead.Birthday__c = Date.Today().addDays(-1) ;
        ctl.filterLead.Schedule_Abroad_Year__c = Date.Today().addDays(1);
        ctl.searchLead();
        ctl.getLeadStatus();
        System.assert(ctl.leads.size() == 0);

        ctl.selectedConsultMode = '集团TMK外呼';
        ctl.selectedIntendCity = '上海';
        ctl.selectedBSLine = Constants.BL_COUSELLING_NAME + ',' + Constants.BL_TESTPREP_NAME;
        ctl.selectedProject = '美国,SAT';
        ctl.selectedFollowUp = '未跟进';
        ctl.SelectedItemStatus = '';
        ctl.filterLead.Birthday__c =  null;
        ctl.filterLead.Schedule_Abroad_Year__c = null;
        ctl.searchLead();
        ctl.getLeadStatus();
        ctl.leads[0].isSelected = true;
        ctl.gettemptabledisplay1();
        ctl.addLeadToBatch();
        ctl.gettemptabledisplay1();
        System.assert(ctl.selLeadIds.size() == 1);
        ctl.searchLead();
        System.assert(ctl.leads.size() == 0);
        ctl.submitbatch();
        ctl.changePageNo1();
        ctl.changeLeadPerPage1();
        ctl.next1();
        ctl.previous1();
        ctl.homePage1();
        ctl.endPage1();
        ctl.getTotal1();
        ctl.getCurrentPageNo1();
        ctl.getTotalPageNo1();
        ctl.getNextEnable1();
        ctl.getPreviousEnable1();
        ctl.changeLeadPerPage();
        ctl.next();
        ctl.previous();
        ctl.homePage();
        ctl.endPage();
        ctl.getTotal();
        ctl.getCurrentPageNo();
        ctl.getTotalPageNo();
        ctl.getNextEnable();
        ctl.getPreviousEnable();
        ctl.save();

       return ctl;
    }
}