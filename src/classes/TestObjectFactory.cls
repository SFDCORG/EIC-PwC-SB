/**************************************************************************************************
 * Name: TestObjectFactory
 * Object: /
 * Purpose:  Define the fake test object data in here for other test class using
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/

public class TestObjectFactory {

    public static User createTmkUser(string extId) {
        SmartFactory.FillAllFields = true;
        User user = (User)SmartFactory.createSObject('User');
        user.ProfileId = Constants.PROFILE_TMK_CUSTOMER_SERVICE_ID;
        user.User_External_Id__c = extId;
        user.UserRoleId = Constants.ROLE_TMK_HQ_STAFF_ID;
        return user;
    } 

    public static User createTmkManager(string extId) {
        SmartFactory.FillAllFields = true;
        User user = (User)SmartFactory.createSObject('User');
        user.ProfileId = Constants.PROFILE_TMK_CUSTOMER_SERVICE_MANAGER_ID;
        user.UserRoleId = Constants.ROLE_TMK_HQ_STAFF_ID;
        user.User_External_Id__c = extId;
        return user;
    }

    public static User createSalesUser() {
        SmartFactory.FillAllFields = true;
        User user = (User)SmartFactory.createSObject('User');
        user.ProfileId = Constants.PROFILE_SALES_MANAGER_ID;
        user.UserRoleId = Constants.ROLE_SALES_SH_MANAGER_ID;
        user.RoleCityText__c= '';
        return user;
    }

    public static Account createAccount() {
        Account acc = (Account)SmartFactory.createSObject('Account');
        acc.Postcode__c = '200052';
        return acc;
    }

    public static Opportunity createOpportunity(Id accountId, User owner) {
        SmartFactory.FillAllFields = true;
        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId = accountId;
        opp.StageName = '待分配';
        opp.RecordTypeId = Constants.OPP_RT_COUNSELLING_ID;
        opp.OwnerId = owner.Id;
        opp.Intended_City__c = '广州';
        opp.Department__c = '美国部';
        opp.Project__c = '美国';
        opp.Marketing_Channel_Lv3__c = '广州外国语大学';
        opp.Consultation_Mode__c = '集团TMK外呼';
        return opp;
    }

    public static Opportunity createCoopOpportunity(Id accountId, User owner) {
        SmartFactory.FillAllFields = true;
        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId = accountId;
        opp.StageName = '合同生成';
        opp.RecordTypeId = Constants.OPP_RT_COOPERATIVE_ID;
        opp.OwnerId = owner.Id;
        opp.Intended_City__c = '广州';
        opp.Department__c = '合作办学';
        opp.Project__c = '学术英语';
        opp.Marketing_Channel_Lv3__c = '广州外国语大学';
        opp.Consultation_Mode__c = '集团TMK外呼';
        opp.Name = 'OppOpp';
        opp.CloseDate = system.today() +5;
        return opp;
    }

    public static Campaign_Channel__c createCampaignChannel() {
        Campaign_Channel__c channel = (Campaign_Channel__c)SmartFactory.createSObject('Campaign_Channel__c');
        channel.City__c = '广州';
        channel.Business_line__c = '全部';
        channel.Active__c = true;
        channel.Marketing_Channel_Lv1__c = '线下';
        channel.Marketing_Channel_Lv2__c = '户外推广';
        channel.Marketing_Channel_Lv3__c = '全部广州';
        return channel;
    }

    public static Campaign_Channel__c createGzCoopCampaignChannel() {
        Campaign_Channel__c channel = (Campaign_Channel__c)SmartFactory.createSObject('Campaign_Channel__c');
        channel.City__c = '广州';
        channel.Business_line__c = '合作办学';
        channel.Active__c = true;
        channel.Marketing_Channel_Lv1__c = '线下';
        channel.Marketing_Channel_Lv2__c = '户外推广';
        channel.Marketing_Channel_Lv3__c = '合作办学广州';
        return channel;
    }

    public static Campaign createAllCampaign(Campaign_Channel__c channel){
        SmartFactory.FillAllFields = false;
        Campaign campaign = (Campaign)SmartFactory.createSObject('Campaign');
        campaign.Name = 'GzAll';
        campaign.RecordTypeId = Constants.CAMP_RT_LEVEL_4_PROMO_CHANNEL;
        campaign.Marketing_Channel_Lv1__c = channel.Marketing_Channel_Lv1__c;
        campaign.Marketing_Channel_Lv2__c = channel.Marketing_Channel_Lv2__c;
        campaign.Marketing_Channel_Lv3__c = channel.Marketing_Channel_Lv3__c;
        campaign.Status = '审批通过';
        campaign.Business_line__c = '全部';
        campaign.City__c = channel.City__c;
        return campaign;
    }

    public static Campaign createCoopCampaign(Campaign_Channel__c channel){
        SmartFactory.FillAllFields = false;
        Campaign campaign = (Campaign)SmartFactory.createSObject('Campaign');
        campaign.Name = 'GzCoop';
        campaign.RecordTypeId = Constants.CAMP_RT_LEVEL_4_PROMO_CHANNEL;
        campaign.Marketing_Channel_Lv1__c = channel.Marketing_Channel_Lv1__c;
        campaign.Marketing_Channel_Lv2__c = channel.Marketing_Channel_Lv2__c;
        campaign.Marketing_Channel_Lv3__c = channel.Marketing_Channel_Lv3__c;
        campaign.Status = '审批通过';
        campaign.Business_line__c = '合作办学';
        campaign.City__c = channel.City__c;
        return campaign;
    }

    public static Organization__c createCoopOrg() {
        Organization__c org = (Organization__c)SmartFactory.createSObject('Organization__c');
        org.RecordTypeId = Constants.ORG_RT_COOPERATIVE_ID;
        org.Name = 'GZ_COOP_ORG';
        org.DeveloperName__c = 'Cooperative_GZ_Null_Null_Null';
        org.City__c = '广州';
        org.Project__c = '派遣;学术英语;国际预科';
        return org;
    }

    public static Lead createTmkLead() {

        Campaign_Channel__c channel = createCampaignChannel();
        insert channel;

        Campaign campaign = createCoopCampaign(channel);
        insert campaign;

        Lead lead = new Lead();
        lead.LastName = 'tmkLeadTest';
        lead.Company = 'EIC';
        lead.Status = '全未转化-新建';
        lead.Campaign__c = campaign.Id;
        lead.Consultation_Mode__c = '集团TMK外呼';
        lead.Intended_City__c = '广州';
        lead.Is_Cooperative_Education__c = true;
        lead.Cooperative_Education_Project__c = '学术英语;国际预科';
        lead.MobilePhone = '13500000001';
        lead.Area_Code__c = '021';
        lead.Phone = '44445555';

        return lead;
    }

    public static Organization__c createOrgs() {
    
        Organization__c testPrepOrg = new Organization__c();
        testPrepOrg.name = 'testPrepOrg';
        testPrepOrg.City__c = '上海';
        testPrepOrg.Front_Desk__c = UserInfo.getUserId();
        testPrepOrg.RecordTypeID = [Select Id 
                                    FROM RecordType 
                                    WHERE SObjectType = 'Organization__c'
                                    AND DeveloperName = 'TestPrep' limit 1].Id;
        testPrepOrg.OwnerId = userInfo.getUserId();
        testPrepOrg.Department__c = 'LG';
        testPrepOrg.Office__c = '人民广场';

        return testPrepOrg;
    }

    public static Scheduling_Table__c createSchedulingTable(Organization__c org) {
    
        Scheduling_Table__c sctable = new Scheduling_Table__c();
        sctable.Name = 'test';
        sctable.Organization__c = org.Id;
        sctable.Front_Desk__c = org.Front_Desk__c;
        sctable.Intercept__c = '分配至顾问';
        sctable.Project__c = '澳大利亚';
        sctable.Source__c = '普通商机';
        sctable.Department__c = org.Department__c;
        sctable.isActive__c = true;
        sctable.City__c = '上海';
        sctable.Manager__c = userinfo.getUserId();
        sctable.RecordTypeID = [Select Id 
                                FROM RecordType 
                                WHERE SObjectType = 'Scheduling_Table__c'
                                AND DeveloperName = 'TestPrep' limit 1].Id;
        return sctable;
    }

    public static Scheduling_Table_Line__c createScheTableLine(Scheduling_Table__c sctable) {
    
        Scheduling_Table_Line__c sctline = new Scheduling_Table_Line__c();
        sctline.Project__c = '澳大利亚';
        sctline.Source__c = '普通商机';
        sctline.Monday_Time__c = 'D';
        sctline.Start_Working_Time__c = '08:00';
        sctline.End_Working_Time__c = '23:00';
        sctline.User__c = userinfo.getUserId();
        sctline.Daily_Opportunities__c = 1;
        sctline.Monthly_Opportunities__c = 2;
        sctline.Scheduling_Table__c = sctable.Id;

        return sctline;
    }

    public static Scheduling_Table_Order__c createScheTableOrder(Scheduling_Table__c sctable) {
    
        Scheduling_Table_Order__c schOrder = new Scheduling_Table_Order__c();
        schOrder.Indicator__c = true;
        schOrder.Order__c = 1;
        schOrder.Scheduling_Table__c = sctable.Id;
        schOrder.User__c = userinfo.getUserId();

        return schOrder;
    }

    public static WorkTimesV2__c createWorkTimesSetting() {

        WorkTimesV2__c wt = new WorkTimesV2__c();
        wt.A__c = '08:30-17:30';
        wt.B__c = '09:00-18:00';
        wt.C__c = '10:00-19:00';
        wt.D__c = '10:00-19:00';
        wt.Enable_Table_Record_Type__c = 'TestPrep;';
        return wt;
    }

    public static Contact_EIC__c createContact(Account acc) {
        Contact_EIC__c contat  = new Contact_EIC__c();
        contat.isPrimary__c = true;
        contat.Name = 'test';
        contat.Contact_Type__c = '手机';
        contat.Account__c = acc.Id;
        contat.Relationship__c =  'OneSelf';
        contat.UniqueContact__c = '13671999387';
        return contat;
    }

    // Creates sample contact only
    public static void createContact(Account acc, String fixPhone) {
        Contact_EIC__c contact = new Contact_EIC__c(
            Name = 'Test Account',
            Account__c = acc.Id,
            Contact_Type__c = Constants.FIX_PHONE_CN,
            UniqueContact__c = fixPhone);
        insert contact;
    }

    public static OpportunityTeamMember createOppTeam(Opportunity opp, Id userID) {
        OpportunityTeamMember oppMember = new OpportunityTeamMember();
        oppMember.OpportunityId = opp.Id;
        oppMember.UserId = userID;
        oppMember.TeamMemberRole = 'Team Member';
        return oppMember;
    }
  
    public static Appoitment__c createApp(Opportunity opp, Id userID) {
        Appoitment__c app = new Appoitment__c();
        app.Appointment_Type__c = '第5天任务';  
        app.Due_Date__c = System.today();
        app.Opportunity__c = opp.Id;
        app.RecordTypeId = RecordTypeRelated.Assignment_App;
        app.Assign_To__c = userID;
        app.Status__c = '未完成';

        return app;
    }

    public static UserRole createUserRole() {
        UserRole role = new UserRole();
        role.DeveloperName = 'TestPrep_SH_PQ_AU_A_Manager';
        role.Name = 'TestRole';
        
        return role;
    }

    public static CS_Assign_City_Territory__c createCSAssignCityTerritory() {
        CS_Assign_City_Territory__c tery = new CS_Assign_City_Territory__c();
        tery.Current_User_City__c = '广州';
        tery.Expand_User_City__c = '广州;上海;济南';
        tery.Name = 'test Expand Terry';
        return tery;
    }

    public static Batch_Size_Setting__c createBatchSizeSetting() {
        Batch_Size_Setting__c btsize = new Batch_Size_Setting__c();
        btsize.Opportunity_Owner_Change_Batch__c = 15;
        return btsize;
    }

    public static Approval_Log__c createApprovalLog(Id oppId, Id approverId) {
        Approval_Log__c apvl = new Approval_Log__c();
        apvl.name = 'test approval';
        apvl.Opportunity__c = oppId;
        apvl.Approval_Status__c = '待审批';
        apvl.Approver__c = approverId;
        apvl.Description__c = 'test approval log insert';
        return apvl;
    }

    public static shouldProcessRun__c createShouldRun (Id userId) {
        shouldProcessRun__c avoidTrigger = new shouldProcessRun__c(
            Name = userId,
            IsDisable__c = TRUE);
        return avoidTrigger;
    }

    // Creates sample account
    public static Account createAccount(String mobile) {
        Id recordTypeId = Utils.getRecordTypeId('Account', 'EIC Account');
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeId);
        insert acc;

        Contact_EIC__c contact = new Contact_EIC__c(
            Name = 'Test Account',
            Account__c = acc.Id,
            isPrimary__c = TRUE,
            Contact_Type__c = Constants.MOBILE_CN,
            UniqueContact__c = mobile);
        insert contact;

        return acc;
    }

    // Creates sample account
    public static Account createAccount(String mobile, String fixPhone) {
        Id recordTypeId = Utils.getRecordTypeId('Account', 'EIC Account');
        List<Contact_EIC__c> contactList = new List<Contact_EIC__c>();

        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeId);
        insert acc;

        Contact_EIC__c mobilecon = new Contact_EIC__c(
            Name = 'Test Account Mobile',
            Account__c = acc.Id,
            isPrimary__c = TRUE,
            Contact_Type__c = Constants.MOBILE_CN,
            UniqueContact__c = mobile);
        contactList.add(mobilecon);

        Contact_EIC__c fixPhonecon = new Contact_EIC__c(
            Name = 'Test Account Fix Phone',
            Account__c = acc.Id,
            Contact_Type__c = Constants.FIX_PHONE_CN,
            UniqueContact__c = fixPhone);
        contactList.add(fixPhonecon);
        
        insert contactList;

        return acc;
    }

    public static List<Opportunity> createOpportunities(Account acc) {
        Id cRTId = Utils.getRecordTypeId('Opportunity', 'Counselling');
        Id tRTId = Utils.getRecordTypeId('Opportunity', 'Testprep');
        Id scholarTreeRTId = Utils.getRecordTypeId('Opportunity', 'Scholar Tree');
        Id cooperativeRTId = Utils.getRecordTypeId('Opportunity', 'Cooperative');
        List<Opportunity> opps = new List<Opportunity>();

        Opportunity counsellingOpp = new Opportunity(
            Name = 'counsellingOpp',
            RecordTypeId = cRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = Constants.CITY_BJ_CN,
            Intended_Office__c = 'N/A',
            Department__c = 'US',
            Project__c = Constants.US_CN,
            Consultation_Mode__c = Constants.F2F_CONSULTING_CN,
            StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(counsellingOpp);
        Opportunity counsellingOpp2 = new Opportunity(
            Name = 'counsellingOpp2',
            RecordTypeId = cRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = Constants.CITY_SH_CN,
            Intended_Office__c = 'N/A',
            Department__c = 'England&Ireland',
            Project__c = Constants.UK_CN,
            Consultation_Mode__c = Constants.F2F_CONSULTING_CN,
            StageName = Constants.OPPORTUNITY_STAGE_CLOSED_LOST_CN);
        opps.add(counsellingOpp2);

        Opportunity testprepOpp = new Opportunity(
            Name = 'testprepOpp',
            RecordTypeId = tRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = Constants.CITY_BJ_CN,
            Intended_Office__c = 'N/A',
            Department__c = Constants.DEPARTMENT_TESTPREP_CN,
            Project__c = 'SAT',
            Consultation_Mode__c = Constants.F2F_CONSULTING_CN,
            StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(testprepOpp);

        Opportunity scholarTreeOpp = new Opportunity(
            Name = 'scholarTreeOpp',
            RecordTypeId = scholarTreeRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = Constants.CITY_BJ_CN,
            Intended_Office__c = 'N/A',
            Department__c = Constants.SCHOLAR_TREE_CN,
            Consultation_Mode__c = Constants.F2F_CONSULTING_CN,
            StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(scholarTreeOpp);

        Opportunity cooperativeOpp = new Opportunity(
            Name = 'cooperativeOpp',
            RecordTypeId = cooperativeRTId,
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = Constants.CITY_BJ_CN,
            Intended_Office__c = 'N/A',
            Department__c = Constants.COOPERATIVE_CN,
            Project__c = Constants.COOPERATIVE_PROJECT_CN,
            Consultation_Mode__c = Constants.F2F_CONSULTING_CN,
            StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(cooperativeOpp);

        insert opps;
        return opps;
    }

    public static User createUser() {
        // Gets admin profile
        Profile adminProfile = [SELECT Id 
                                FROM Profile 
                                WHERE Name = 'System Administrator'
                                OR Name = : Constants.SYSTEM_ADMIN_PROFILE_CN
                                LIMIT 1];
        User user = new User(
            Email = 'test@eic.com.test',
            Lastname = 'Test',
            ProfileId = adminProfile.Id,
            Username = String.valueOf(System.now().getTime()) + String.valueOf(System.Math.random()) + '@eic.com.test',
            Alias = String.valueOf(System.now().getTime()).subString(0, 8),
            EmailenCodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_GB',
            TimezonesIdKey = 'America/Los_Angeles',
            CompanyName = 'EIC',
            Sage_UserName__c = 'SAGE Username',
            Paike_UserName__c = 'Jiaowu Username');

        insert user;

        return user;
    }

    // Creates branch customer service manager
    public static User createCustomerManager() {
        User user = new User(
            Email = 'test@eic.com.test',
            Lastname = 'Test',
            ProfileId = Constants.PROFILE_LOCAL_CS_MANAGER_ID,
            Username = String.valueOf(System.now().getTime()) + String.valueOf(System.Math.random()) + '@eic.com.test',
            Alias = String.valueOf(System.now().getTime()).subString(0, 8),
            EmailenCodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_GB',
            TimezonesIdKey = 'America/Los_Angeles',
            CompanyName = 'EIC',
            Sage_UserName__c = 'SAGE Username',
            Paike_UserName__c = 'Jiaowu Username');

        insert user;

        return user;        
    }

    public static Campaign createCampaign(String campaignName, String businessLine, String channel1, String channel2, String channel3) {
        Id recordTypeId = Utils.getRecordTypeId('Campaign', 'Level 4 Promotion Channel (Approved)');
        Campaign camp = new Campaign(
            Name = campaignName,
            RecordTypeId = recordTypeId,
            City__c = Constants.CITY_BJ_CN,
            Business_Line__c = businessLine,
            Marketing_Channel_Lv1__c = channel1,
            Marketing_Channel_Lv2__c = channel2,
            Marketing_Channel_Lv3__c = channel3,
            Status = Constants.APPROVED_CN,
            IsActive = TRUE);
        insert camp;
        return camp;
    }

    public static User insertTMKUser() {
        User user = new User(
            Email = 'test@eic.com.test',
            Lastname = 'Test',
            ProfileId = Constants.PROFILE_TMK_CUSTOMER_SERVICE_MANAGER_ID,
            Username = String.valueOf(System.Math.random()) + '@eic.com.test',
            Alias = String.valueOf(System.Math.random()).subString(0, 8),
            EmailenCodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_GB',
            TimezonesIdKey = 'America/Los_Angeles',
            CompanyName = 'EIC');

        insert user;

        return user;
    }

    public static Organization__c createOrg(String city, String businessLineEN, String businessLineCN) {    
        Organization__c org = new Organization__c();
        org.Name = city + businessLineCN + 'org';
        org.City__c = city;
        org.Front_Desk__c = UserInfo.getUserId();
        org.RecordTypeId = Utils.getRecordTypeId('Organization__c', businessLineEN);
        org.OwnerId = userInfo.getUserId();
        org.Department__c = businessLineCN;
        org.Office__c = 'People Square';
    
        return org;
  }

   public static Scheduling_Table__c createSchedulingTable(Organization__c org, String businessLineEN) {    
        Scheduling_Table__c schedulingTable = new Scheduling_Table__c();
        schedulingTable.Name = org.Name + 'Scheduling Table';
        schedulingTable.Organization__c = org.Id;
        schedulingTable.Front_Desk__c = org.Front_Desk__c;
        schedulingTable.Intercept__c = 'Distribute to Consultant';
        schedulingTable.Project__c = 'SAT;GRE';
        schedulingTable.Source__c = 'Normal Opportunity';
        schedulingTable.Department__c = org.Department__c;
        schedulingTable.isActive__c = TRUE;
        schedulingTable.City__c = org.City__c;
        schedulingTable.Office__c = org.Office__c;
        schedulingTable.Manager__c = userinfo.getUserId();
        schedulingTable.RecordTypeId = Utils.getRecordTypeId('Scheduling_Table__c', businessLineEN);
        return schedulingTable;
    }

    public static Scheduling_Table_Line__c createSchedulingTableLine(Scheduling_Table__c schedulingTable) {    
        Scheduling_Table_Line__c schedulingTableLine = new Scheduling_Table_Line__c();
        schedulingTableLine.Project__c = schedulingTable.Project__c;
        schedulingTableLine.Source__c = schedulingTable.Source__c;
        schedulingTableLine.Monday_Time__c = 'D';
        schedulingTableLine.Start_Working_Time__c = '08:00';
        schedulingTableLine.End_Working_Time__c = '23:00';
        schedulingTableLine.User__c = userinfo.getUserId();
        schedulingTableLine.Daily_Opportunities__c = 1;
        schedulingTableLine.Monthly_Opportunities__c = 2;
        schedulingTableLine.Scheduling_Table__c = schedulingTable.Id;

        return schedulingTableLine;
    }

    public static Lead createLead(Campaign campaign, String intendedCity, Boolean hasProject) {
        if (hasProject) {
            Lead lead = new Lead(
                Lastname = 'Test',
                Firstname = 'A',
                MobilePhone = '19099990000',
                Area_Code__c = '021',
                Phone = '99999999',
                Campaign__c = campaign.Id,
                Consultation_Mode__c = 'TMK Callout',
                Intended_City__c = intendedCity,
                Is_Counselling__c = TRUE,
                Is_Testprep__c = TRUE,
                Counselling_Project__c = Constants.US_CN + ';' + Constants.UK_CN,
                Testprep_Project__c = 'SAT;GRE',
                GPA__c = 80,
                College__c = 'Test University',
                Education_Level__c = 'Bachelor',
                Company = 'EIC TEST');
            return lead;

        } else {
            Lead lead = new Lead(
                Lastname = 'Test',
                Firstname = 'B',
                // MobilePhone = '19099990001',
                Area_Code__c = '022',
                Phone = '99999990',
                Campaign__c = campaign.Id,
                Consultation_Mode__c = 'TMK Callout',
                Intended_City__c = intendedCity,
                Is_Counselling__c = TRUE,
                Is_Scholar_Tree__c = TRUE,
                Counselling_Project__c = '',
                GPA__c = 80,
                College__c = 'Test University',
                Education_Level__c = 'Bachelor',
                Company = 'EIC TEST');
            if (intendedCity == Constants.CITY_GZ_CN) {
                lead.Is_Cooperative_Education__c = TRUE;
            }

            if (intendedCity == Constants.CITY_SH_CN) {                
                lead.Is_NP__c = TRUE;
            }

            return lead;
        }
    }

    public static Lead createLead(Campaign campaign, String intendedCity, Boolean hasProject, String mobile, String fixPhone) {
        if (hasProject) {
            Lead lead = new Lead(
                Lastname = 'Test',
                Firstname = 'A',
                MobilePhone = mobile,
                Area_Code__c = '021',
                Phone = fixPhone,
                Campaign__c = campaign.Id,
                Consultation_Mode__c = 'TMK Callout',
                Intended_City__c = intendedCity,
                Is_Counselling__c = TRUE,
                Is_Testprep__c = TRUE,
                Counselling_Project__c = Constants.US_CN + ';' + Constants.UK_CN,
                Testprep_Project__c = 'SAT;GRE',
                GPA__c = 80,
                College__c = 'Test University',
                Education_Level__c = 'Bachelor',
                Company = 'EIC TEST');
            return lead;

        } else {
            Lead lead = new Lead(
                Lastname = 'Test',
                Firstname = 'B',
                // MobilePhone = '19099990001',
                Area_Code__c = '021',
                Phone = fixPhone,
                Campaign__c = campaign.Id,
                Consultation_Mode__c = 'TMK Callout',
                Intended_City__c = intendedCity,
                Is_Counselling__c = TRUE,
                Is_Scholar_Tree__c = TRUE,
                Counselling_Project__c = '',
                GPA__c = 80,
                College__c = 'Test University',
                Education_Level__c = 'Bachelor',
                Company = 'EIC TEST');
            if (intendedCity == Constants.CITY_GZ_CN) {
                lead.Is_Cooperative_Education__c = TRUE;
            }

            if (intendedCity == Constants.CITY_SH_CN) {                
                lead.Is_NP__c = TRUE;
            }

            return lead;
        }
    }

    public static Lead createUploadedLead(Campaign campaign, String intendedCity) {
        Lead lead = new Lead(
            Lastname = 'Test',
            Firstname = 'A',
            MobilePhone = '19099990000',
            Area_Code__c = '021',
            Phone = '99999999',
            Campaign__c = campaign.Id,
            Consultation_Mode__c = 'TMK Callout',
            Intended_City__c = intendedCity,
            Is_Counselling__c = TRUE,
            GPA__c = 80,
            College__c = 'Test University',
            Company = 'EIC TEST');

        lead.Project__c = Constants.UK_CN + ';' + 
                          'SAT' + ';' + 
                          Constants.SCHOLAR_TREE_PROJECT_CN + ';' +
                          Constants.COOPERATIVE_PROJECT_CN;

        lead.Business_Line__c = Constants.COUNSELLING_CN + ';' + 
                                Constants.TESTPREP_CN + ';' +
                                Constants.SCHOLAR_TREE_CN  + ';' + 
                                Constants.COOPERATIVE_CN;
        return lead;
    }

    // Creates lead itemList
    public static void createLeadItemList(Lead lead) {
        List<Lead_Item__c> leadItemList = new List<Lead_Item__c>();
        Id campaignId = [SELECT Campaign__c
                         FROM Lead
                         WHERE Id = :lead.Id].Campaign__c;

        if (lead.Is_Counselling__c) {
            List<String> cProjects = new List<String>();
            if (String.isNotBlank(lead.Counselling_Project__c)) {
                cProjects = lead.Counselling_Project__c.split(';');
            }

            if (cProjects.size() == 0) {
                leadItemList.add(createOneLeadItem (
                    lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COUNSELLING_CN, campaignId, NULL, ''));

            // If it does not have counselling projects
            } else {
                // If it has counselling projects
                for (String country :cProjects) {
                    leadItemList.add(createOneLeadItem (
                        lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COUNSELLING_CN, campaignId, country, country));
                }
            }
        }

        if (lead.Is_TestPrep__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.TESTPREP_CN, campaignId, lead.TestPrep_Project__c, ''));
        }

        if (lead.Is_NP__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, 'NP', campaignId, lead.TestPrep_Project__c, ''));
        }

        if (lead.Is_Scholar_Tree__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.SCHOLAR_TREE_CN, campaignId, Constants.SCHOLAR_TREE_PROJECT_CN, ''));
        }

        if (lead.Is_Cooperative_Education__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COOPERATIVE_CN, campaignId, lead.Cooperative_Education_Project__c, ''));
        }

        insert leadItemList;
    }

    public static Opportunity createTestprepOpportunity(Account acc) {
        Opportunity opp = new Opportunity(
            Name = 'Testprep Opp',
            RecordTypeId = Utils.getRecordTypeId('Opportunity', 'Testprep'),
            AccountId = acc.Id,
            CloseDate = System.today() + 30,
            Intended_City__c = Constants.CITY_BJ_CN,
            Intended_Office__c = 'N/A',
            Department__c = Constants.DEPARTMENT_TESTPREP_CN,
            Project__c = 'SAT',
            Consultation_Mode__c = Constants.F2F_CONSULTING_CN,
            StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        insert opp;
        return opp;
    }

    // Creates one lead item
    private static Lead_Item__c createOneLeadItem (Lead lead, String status, String businessLine, String campaignId, String project, String country) {
        Lead_Item__c li = new Lead_Item__c(
            Lead__c = lead.Id,
            Status__c = status,
            Business_Line__c = businessLine,
            Project__c = project);
        if (country != '') {
            li.Intended_Country__c = country;
            businessLine += ';' + country;
        }
        if (String.isNotBlank(lead.MobilePhone)) {
            li.Mobile__c = lead.MobilePhone;
            li.Mobile_Unique_Key__c = lead.MobilePhone + ';' + campaignId + ';' + lead.Intended_City__c + ';' + businessLine;
        }
        if (String.isNotBlank(lead.Phone)) {
            li.Fix_Phone__c = lead.Phone;
            li.Fix_Phone_Unique_Key__c = lead.Area_Code__c == NULL ? '' : lead.Area_Code__c +  lead.Phone + ';';
            li.Fix_Phone_Unique_Key__c += campaignId + ';' + lead.Intended_City__c + ';' + businessLine;
        }
        return li;
    }

    // Creates the contract
    public static Contract__c  createContract(Opportunity opp) {
        Contract__c contract = new Contract__c(
            Opportunity__c = opp.Id);
        insert contract;
        return contract;
    }

    // Creates batch callout record
    public static CallLog_History__c createLeadCallLogHistory(Id batchCalloutId, Lead lead) {
        CallLog_History__c callLog = new CallLog_History__c(
            BatchCallOut__c = batchCalloutId,
            Lead__c = lead.Id);
        insert callLog;
        return callLog;
    }

    // Creates lead follow up
    public static Appoitment__c createLeadFollowup(Lead lead) {
        Appoitment__c app = new Appoitment__c();
        app.Due_Date__c = System.today();
        app.Lead__c = lead.Id;
        app.RecordTypeId = Utils.getRecordTypeId('Appoitment__c', 'Lead Follow Up');
        app.Assign_To__c = UserInfo.getUserId();
        app.Follow_Up_Result__c = '无人接听-1';
        insert app;
        return app;
    }

    // Creates BatchJobRecord__c record
    public static BatchJobRecord__c createBatchJob() {
        BatchJobRecord__c batchJob = new BatchJobRecord__c(
            Name = 'Test Batch Job',
            Status__c = 'Completed');
        insert batchJob;

        return batchJob;
    }

    // Creates the an attachment record
    public static Attachment createAttachment(Id recordId) {
        Attachment attachment = new Attachment(
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Attachment Body'),
            ParentId = recordId);
        insert attachment;

        return attachment;    
    }

    public static void initializeProjectSetup() {
        List<Project__c> projectList = new List<Project__c>();
        Project__c counsellingProjs = new Project__c(
            Name = Constants.COUNSELLING_CN, 
            Project__c = Constants.UK_CN);
        projectList.add(counsellingProjs);

        Project__c testprepProjs = new Project__c(
            Name = Constants.TESTPREP_CN, 
            Project__c = 'SAT');
        projectList.add(testprepProjs);

        Project__c NPProjs = new Project__c(
            Name = 'NP', 
            Project__c = 'SAT');
        projectList.add(NPProjs);

        Project__c scholarTreeProjs = new Project__c(
            Name = Constants.SCHOLAR_TREE_CN, 
            Project__c = Constants.SCHOLAR_TREE_PROJECT_CN);
        projectList.add(scholarTreeProjs);

        Project__c cooperativeProjs = new Project__c(
            Name = Constants.COOPERATIVE_CN, 
            Project__c = Constants.COOPERATIVE_PROJECT_CN);
        projectList.add(cooperativeProjs);

        insert projectList;
    }
}