/**************************************************************************************************
 * Name: OpportunitiesAssignPageController
 * Object: opportunity
 * Purpose: Opportunity manually assign
 * Author: Ray Cen
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
public without sharing class OpportunitiesAssignPageController {

    public ID OppID { get ; set; } // get parameter from url: Opportunity ID
    public String initialAPPID { get ; set; } // get the appointment which already been created on the lead
    public String assignMethod { get ; set; } // Opp assign method selection
    public List<Scheduling_Table__c> scheTables { get ; set; } // Get Available Scheduling Tables
    public List<SchedulingTableLineWrapper> scheTablines { get ; set; } // Get Available Scheduling Tables Lines
    public Boolean CCFlag { get ; set; } // scheduling table Section display
    public Boolean PoolFlag { get ; set; } // Assign Opportunity to Pool
    public Boolean LocalCSFlag { get ; set; } // Assign opportunity to LocalCS
    public Boolean HDTMKFlag { get ; set; } // Assign opportunity to TMK
    public Boolean SchedLineFlag { get ; set; } // Scheduling Table Lines Section Flag
    public Boolean SaveButtonFlag { get ; set; } // Save Button Display
    public Boolean OppAdjustJudgeFlag { get ; set; } // if the opp don't assign to recommend CC, after assign a choice dialog will display
    public Boolean OppDirectly { get ; set; } // opp directly assign to specific user list
    public String selectedscheTableID { get ; set; } // the scheduling Table ID which choose by user
    public String selectedscehTableLineID { get ; set; } // the scheduling Table Line ID which choose by user
    public String selectedUserID { get ; set; } // the selected directly assign UserID
    public String appviewuserId { get ; set; } // the user which shall be query current appointments status
    public String intercept { get ; set; } // the scheduling Table intercept which choose by user
    public Boolean isGiveBack { get ; set; } // give back opp to the priority opp or not
    public Boolean schedulingTableOptionvisiableflag { get ; set; } // specify profile user can select scheduling Table Assign method
    public Boolean poolOptionvisiableflag { get ; set; } // specify profile user can select pool Assign method
    public Boolean direcltyAssignflag { get ; set; } // specify profile user can directly Assign method
    public List<User> userList { get ; set; } // Directly Assign user Range List
    public List<Appoitment__c> applists { get ; set; } // the existing appointment of scheduling Table line user
    public String compensateCC { get ; set; } // the compensate CC Name
    public Appoitment__c initialAPP { get ; set; }
    public String initialAppDate { get ; set; }
    public String initialAppTime { get ; set; }
    public Integer tableNum { get ; set; }
    public Set<String> offices { get ; set; }
    private Opportunity OPP; // the Opportunity which shall be assigned.
    private List<String> OppProjects; // All Projects of the Assigning OPP
    private String OppTypeID; // the Opp Type of the assigning Opp
    private String OppCity; // the Opp City of the assigning Opp
    private Map<ID, List<SchedulingTableLineWrapper>> scheTableRoute; // Got Schelling Table line Routing Map
    private Map<ID,ID> userandTablepriorityMap; // Got the priority user of Scheduling Table<TableID, PriorityUserID>
    private Map<ID, List<Appoitment__c>> userAppointmentsMap;
    private Set<String> linesUserSet;
    private Map<ID, Boolean> lineavailable = new  Map<ID, Boolean> ();
    private Boolean hideDirectlyUser = true;
    private Map<Id, Boolean> tableCompensateMap = new Map<ID, Boolean>(); // the recommend user can be compensate or not
    private Map<Id, Scheduling_Table_Order__c> tableCompensateOrderMap = new Map<ID, Scheduling_Table_Order__c>(); // the compensate order with table id
    public Boolean weekdayTimeFlag { get ; set; }
    public String worktimeExample { get ; set; }
    public Boolean showallUsers { get ; set; }
    private static final Set<String> blockChangeStage = new Set<String>(); // define which opp status shall be hold, and not changed to '顾问跟进'
    static {
        blockChangeStage.add('签约');
        blockChangeStage.add('流失');
    }

    public OpportunitiesAssignPageController (ApexPages.StandardController controller) {

        OppID = ApexPages.CurrentPage().getparameters().get('ID');
        initialAPPID = ApexPages.CurrentPage().getparameters().get('appointId');
        User currentLogin = [SELECT Directly_Assign__c
                             FROM User
                             WHERE Id = :userinfo.getUserId() LIMIT 1];

        initilizaitonOppInfo();
        scheTableRoute = new Map<ID, List<SchedulingTableLineWrapper>>();
        scheTablines = new List<SchedulingTableLineWrapper>();
        scheTables = new List<Scheduling_Table__c>();
        userandTablepriorityMap = new Map<ID,ID>();
        userList = new List<User>();
        linesUserSet = new Set<String>();
        userAppointmentsMap = new Map<ID, List<Appoitment__c>>();
        applists = new List<Appoitment__c>();
        offices = new Set<String>();
        tableNum = -1;
        assignMethod = '';
        selectedscheTableID = '';
        intercept = '';
        appviewuserId = '';
        compensateCC = '';
        CCFlag = false;
        PoolFlag = false;
        SchedLineFlag = false;
        SaveButtonFlag = false;
        OppAdjustJudgeFlag = false;
        isGiveBack = false;
        HDTMKFlag = false;
        LocalCSFlag = false;
        OppDirectly = false;
        weekdayTimeFlag = true;
        showallUsers = false;
        worktimeExample = '';

        if (opp != null) {

            direcltyAssignflag = ProfileRelated.oppDirecltyAssignProfileSet().contains(UserInfo.getProfileId()) ||
                                 currentLogin.Directly_Assign__c;
            schedulingTableOptionvisiableflag = ProfileRelated.oppSchedulingTableOptionvisiableProfileSet().contains(UserInfo.getProfileId());
            poolOptionvisiableflag = ProfileRelated.oppPoolOptionvisiableProfileSet().contains(UserInfo.getProfileId()) &&
                                     !blockChangeStage.contains(opp.StageName);
            generateScheTablsMap();
            generateScheTablineUserAppMap();
            initilizationAppInfo();

            if (schedulingTableOptionvisiableflag) {
               initilizationSchedulingTableSection();
            }
        }
    }
    
    // Initializes the existing appointment info
    private void initilizationAppInfo () {

        List<Appoitment__c> apps=[SELECT Due_Date__c,
                                         Due_Time__c,
                                         sys_DueTime__c,
                                         Name,
                                         Appointment_Type__c,
                                         Opportunity__c,
                                         Lead__r.Name,
                                         Opportunity__r.Account.Name
                                  FROM Appoitment__c
                                  WHERE Id = :initialAPPID];

        if (apps.size() > 0) {
          initialAPP = apps[0];
          Date dt = apps[0].Due_Date__c;
          initialAppDate = dt.year() + '-' + dt.month() + '-' + dt.day();
          initialAppTime = apps[0].Due_Time__c;
        }
    }

    private void initilizaitonOppInfo () {
        List<Opportunity> OppList=[SELECT Intended_City__c, 
                                          Project__c,
                                          RecordTypeID,
                                          StageName,Source__c,
                                          sys_Department__c,
                                          sys_UnlockStage__c,
                                          OwnerID ,
                                          RecordType.DeveloperName,
                                          sys_LastAssignTime__c,
                                          sys_LastContactTime__c
                                  FROM Opportunity 
                                  WHERE Id = :OppID];

        if (OppList.size() == 1) {

            OPP =  OppList[0];
            OppCity = String.isBlank(OPP.Intended_City__c) ? '' : OPP.Intended_City__c;
            OppTypeID = String.isBlank(OPP.RecordTypeID) ? '' : OPP.RecordTypeID;
            OppProjects = String.isBlank(OPP.Project__c) ? new List<String>() : OPP.Project__c.split(';');
        } else {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '读取失败，请返回商机界面重新分配'));
        }
    }
    
    // Initializes the scheduling table sections
    private void initilizationSchedulingTableSection () {

        assignMethod = 'CC';
        CCFlag = true;
        tableNum = scheTables.size();
        if (scheTables.size() == 1) {

            selectedscheTableID = scheTables[0].id;
            scheTablines = scheTableRoute.get(selectedscheTableID);
            if (scheTablines.size() > 0) {

                intercept = scheTablines[0].intercept;
                if (intercept != '分配至顾问') {
                    SaveButtonFlag = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '该排班表无顾问可分配，请联系主管'));
            }
        }
        else if (scheTables.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '无排班表可选，请联系主管'));
        }
    }
    
    // Selects Assign Method
    public PageReference assignMethodSelect () {

        CCFlag = FALSE;
        PoolFlag = FALSE;
        SaveButtonFlag = false;
        OppDirectly = false;
        showallUsers = false;
        intercept = '';

        if (assignMethod == 'CC') {
            CCFlag = true;
            initilizationSchedulingTableSection();
        } else if (assignMethod == 'Pool' || assignMethod == 'CS' || assignMethod == 'TMK') {
            PoolFlag = assignMethod == 'Pool' ? true : false;
            HDTMKFlag = assignMethod == 'TMK' ? true : false;
            LocalCSFlag = assignMethod == 'CS' ? true : false;
            SaveButtonFlag = true;
        } else if (assignMethod == 'OppDirectly') {
           OppDirectly = true;
           userList = generateUserList();
           if (userList.size() == 0) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '无分配人可选，请联系主管'));
           }
        }
        return null;
    }

    public PageReference selectScheTable () {

        scheTablines = scheTableRoute.get(selectedscheTableID);
        SaveButtonFlag = false;
        showallUsers = false;

        if (scheTablines.size() > 0) {

            intercept = scheTablines[0].intercept;
            SaveButtonFlag = intercept == '分配至前台' || intercept == '分配至主管';
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '该排班表无顾问可分配，请联系主管'));
        }
        return null;
    }

    public PageReference selectScheTableLine () {
        SaveButtonFlag = true;
        return null;
    }

    public PageReference confirmdate () {
        return null;
    }

    public pagereference assignOpp () {

        Opportunity orignalOpp = OPP;
        String fromUserID = OPP.OwnerId;
        String toUser = '';
        OPP.sys_UnlockStage__c = true;
        OPP.sys_LastAssignTime__c = System.Now();
        OPP.sys_LastContactTime__c = System.Now();
        String clgID = '';

        if (!updateApp()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '邀约日期及时间不能为空'));
        }
        OppAdjustJudgeFlag = false;

        if (String.isNotBlank(selectedscehTableLineID) && (intercept == '分配至顾问')) {

            opp.Department__c = [SELECT Department__c 
                                 FROM Scheduling_Table_Line__c 
                                 WHERE Id = :selectedscehTableLineID LIMIT 1].Department__c;
            toUser = SchedulingTableRelatedController.AssginOppOwnertoSchedulingTabline(selectedscehTableLineID, OPP);
            SchedulingTableRelatedController.updateScheduleOrderIndicator(selectedscehTableLineID);

            if (!blockChangeStage.contains(OPP.StageName)) {
                OPP.StageName = '顾问跟进';
            }

            if (String.isNotBlank(toUser)) {
                clgID = ChangeLogRelated.CreateOppChangeLog(orignalOpp, fromUserID, toUser, selectedscheTableID, intercept);
            }

            if (userandTablepriorityMap.get(selectedscheTableID) != toUser &&
                ProfileRelated.oppcompensateProfileSet().contains(UserInfo.getProfileId())) {
                OppAdjustJudgeFlag = true;
                List<User> compensateusers = [SELECT name
                                              FROM user 
                                              WHERE Id = :userandTablepriorityMap.get(selectedscheTableID)
                                              LIMIT 1];

                if (compensateusers.size() > 0) {
                    compensateCC = compensateusers[0].name;
                    ChangeLogRelated.updateChangelogInfo(clgID, compensateusers[0].id);
                    System.debug('LoggingLevel.INFO, *** : ' + tableCompensateMap);
                    if (tableCompensateMap.get(selectedscheTableID)) {
                        return null;
                    }
                }
            }
            ChangeLogRelated.updateChangelogInfo(clgID,toUser);

            if (!blockChangeStage.contains(OPP.StageName)) {
                ActivityRelated.generetaAssignment('第0天任务', toUser, OppID);
            }
            appAssign(toUser);
        } else if (String.isNotBlank(intercept)) {

            OPP.OwnerID = scheTablines[0].interceptByID;
            toUser = scheTablines[0].interceptByID;
            OpportuinityRelatedController.updateOpp(OPP);

            appAssign(scheTablines[0].manager);
            if (String.isNotBlank(toUser))
            ChangeLogRelated.CreateOppChangeLog(orignalOpp, fromUserID, toUser, selectedscheTableID, intercept);
        } else if (OppDirectly) {

            OPP.OwnerId = selectedUserID;
            toUser = selectedUserID;
            OPP.sys_UnlockStage__c = true;
            if (!blockChangeStage.contains(OPP.StageName)) {
                OPP.StageName = '顾问跟进';
            }
            update OPP;
            if (!blockChangeStage.contains(OPP.StageName)) {
                ActivityRelated.generetaAssignment('第0天任务', toUser, OppID);
            }
            ChangeLogRelated.CreateOppChangeLog(orignalOpp, fromUserID, selectedUserID, '', '指定接收人');
        } else if (PoolFlag) {
            List<User> u = new  List<User>();

            if (OppTypeID == RecordTypeRelated.Counselling_Opp) {
                if (opp.Intended_City__c != null) {

                    try {
                        User userr = new User();
                        userr.Id = [SELECT OwnerId,Org_Manager__c
                                    FROM Organization__c
                                    WHERE Department__c = '客服部'
                                    AND City__c = :opp.Intended_City__c
                                    AND RecordType.DeveloperName = 'Counselling'
                                    AND Org_Manager__c != null
                                    LIMIT 1][0].Org_Manager__c;
                          u.add(userr);
                    } catch (Exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '请联系管理员检查组织架构配置！'));
                        return null;
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '商机意向城市为空，分配失败！'));
                    return null;
                }
            } else if (Constants.OPP_RT_TESTPREP_COOP_IDS.contains(OppTypeID)) {
                u = [SELECT ID
                     FROM User
                     WHERE UserRoleID = :RoleRelated.HDTMKManagerRole() 
                     AND isActive = true
                     LIMIT 1];
            }

            if (u.size() > 0) {
                OPP.OwnerId = u[0].id;
                opp.sys_UnlockStage__c = true;
                opp.StageName = '低星资源池';
                update OPP;
                ChangeLogRelated.CreateOppChangeLog(orignalOpp, fromUserID, u[0].Id, '', '低星资源池');
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '无法分配至资源池请联系admin'));
                return null;
            }
        }

        if (checkPermissoin()) {
            return new PageReference('/'+OppID);
        } else {
            return new PageReference('/006/o');
        }
    }

    public pagereference finish () {

        SchedulingTableOrderRelated.oppcompensate(isGiveBack, userandTablepriorityMap.get(selectedscheTableID), selectedscheTableID);
        if (isGiveBack) {
            Scheduling_Table_Order__c sorder = tableCompensateOrderMap.get(selectedscheTableID);
            sorder.Compensate_Number__c = (sorder.Compensate_Number__c == null ? 0 : sorder.Compensate_Number__c ) + 1;
            update sorder;
        }
        if (checkPermissoin()) {
            return new PageReference('/' + OppID);
        } else {
            return new PageReference('/006/o');
        }
    }

    public pagereference selectuser () {
        SaveButtonFlag = true;
        return null;
    }

    private Boolean checkPermissoin () {
       return [SELECT RecordId, HasReadAccess
               FROM UserRecordAccess
               WHERE UserId = :UserInfo.getUserId()
               AND RecordId = :OppID][0].HasReadAccess;
    }

    public List<SelectOption> getappDateTime () {

        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult appDuetimes = Appoitment__c.Due_Time__c.getDescribe();
        List<Schema.PicklistEntry> appDuetimesValues = appDuetimes.getPicklistValues();
        for (Schema.PicklistEntry  spick : appDuetimesValues) {
           options.add(new SelectOption(spick.getValue(), spick.getValue()));
        }

        return options;
    }


    private List<User> generateUserList() {

        userList = new List<User> ();

        if (OPP.Intended_City__c != null) {
            for (User userr: [SELECT Name,
                                     ID,
                                     UserRole.Name,
                                     Profile.Name,
                                     ChineseNameofCity__c,
                                     Role_Office_CN__c,
                                     Business_Unit__c,
                                     Title_of_Role__c,
                                     Department_of_Role__c,
                                     Email
                              FROM User
                              WHERE ChineseNameofCity__c = :OPP.Intended_City__c
                              And UserRoleID != null
                              And IsActive = true
                              And Business_Unit__c = :OPP.RecordType.DeveloperName
                              And (Not Profile.Name LIKE '%市场%')]) {

                String validTitle = 'Consultant, Incharge, Manager, Staff';
                Boolean showUser = userr.Department_of_Role__c.contains(opp.sys_Department__c) ||
                                  (validTitle.contains(userr.Title_of_Role__c) &&
                                      (userr.Department_of_Role__c == 'Null'));
                if (showUser || !hideDirectlyUser) {
                    userList.add(userr);
                    offices.add(userr.Role_Office_CN__c);
                }
            }
        }
        return userList;
    }

    public pagereference showAllDirectlyUsers () {
        hideDirectlyUser = hideDirectlyUser == true ? false : true;
        userList = generateUserList();
        return null;
    }

    private void generateScheTablsMap () {

        if (opp.Source__c != null && opp.Project__c != null && OppCity != null) {

            scheTables= [SELECT Id,
                                Name,
                                Department__c,
                                Project__c,
                                Intercept__c,
                                Manager__c,
                                Manager__r.Full_Name__c,
                                Front_Desk__c,
                                Front_Desk__r.Full_Name__c,
                                City__c,
                                Source__c,
                                RecordTypeID,
                                RecordType.DeveloperName,
                                Office__c,
                                Daily_Opportunities__c,
                                Monthly_Opportunities__c
                          FROM  Scheduling_Table__c
                          Where isActive__c = true
                          AND Source__c != null
                          AND Project__c != null
                          AND Project__c includes(:opp.Project__c)
                          AND Source__c includes(:opp.Source__c)
                          AND City__c = :OppCity];
  
            generateScheTablines();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' 请先选择商机 来源、项目、城市'));
        }
    }

    private void generateScheTablines() {

        for (Scheduling_Table__c scheTable : scheTables) {

            ID scheTableID = scheTable.Id;
            List<SchedulingTableLineWrapper> scheTableLineWList = new List<SchedulingTableLineWrapper>();

            if (displayschedulingTableLineSection(scheTable)) {

                List<Scheduling_Table_Line__c> schedlinesList = removeUnsuitableTableLines([SELECT Id,
                                                                                                   Name,
                                                                                                   Monthly_Opportunities__c,
                                                                                                   Daily_Opportunities__c,
                                                                                                   Business_Line__c,
                                                                                                   City__c,
                                                                                                   Office__c,
                                                                                                   Department__c,
                                                                                                   Source__c,
                                                                                                   Project__c,
                                                                                                   Monday_Time__c,
                                                                                                   Tuesday_Time__c,
                                                                                                   Wednesday_Time__c,
                                                                                                   Thursday_Time__c,
                                                                                                   Friday_Time__c,
                                                                                                   Saturday_Time__c,
                                                                                                   Scheduling_Table__c,
                                                                                                   Sunday_Time__c,
                                                                                                   User__c,
                                                                                                   User__r.Full_Name__c,
                                                                                                   isAvailableToday__c,
                                                                                                   is_Available_Now__c,
                                                                                                   End_Working_Time__c,
                                                                                                   Start_Working_Time__c,
                                                                                                   Scheduling_Table__r.Manager__c,
                                                                                                   sys_isavailable_Friday__c,
                                                                                                   sys_isavailable_Monday__c,
                                                                                                   sys_isavailable_Saturday__c,
                                                                                                   sys_isavailable_Sunday__c,
                                                                                                   sys_isavailable_Thursday__c,
                                                                                                   sys_isavailable_Tuesday__c,
                                                                                                   sys_isavailable_Wednesday__c
                                                                                              FROM Scheduling_Table_Line__c
                                                                                              WHERE Scheduling_Table__c = :scheTableID
                                                                                              AND Project__c != null
                                                                                              AND Source__c != null
                                                                                              AND User__r.IsActive = true
                                                                                              Order BY is_Available_Now__c DESC ]);

                String priorityUser = getcurrentTablePriorityCCName(scheTableID, getTodayScheLineUserNameSet(schedlinesList));

                Set<String> scheUsersinTableOrder =  getCurrentTableOrderUserSet(scheTableID);
                WorkTimesV2__c wtimeSets = [SELECT A__c,B__c,C__c,D__c,Enable_Table_Record_Type__c 
                                            FROM WorkTimesV2__c 
                                            ORDER BY name LIMIT 1];
                weekdayTimeFlag = wtimeSets.Enable_Table_Record_Type__c.contains(OPP.RecordType.DeveloperName);

                if (weekdayTimeFlag) {
                    worktimeExample='班次时间' + ' ▍' + 
                    'A' + ':'  + wtimeSets.A__c + '  ' + ' ▍' + 
                    'B' + ':'  + wtimeSets.B__c + '  ' + ' ▍' + 
                    'C' + ':'  + wtimeSets.C__c + '  '+ ' ▍' +
                    'D'+':' + wtimeSets.D__c + '  ';
                }

                for (Scheduling_Table_Line__c stl : schedlinesList) {

                    SchedulingTableLineWrapper scheTableLineW = new SchedulingTableLineWrapper();
                    if (scheUsersinTableOrder.contains(stl.User__c)) {
                        scheTableLineW.schedulingTableLine=stl;
                        scheTableLineW.isScheduling = stl.User__r.Full_Name__c == priorityUser;
                        scheTableLineW.intercept = '分配至顾问';
                        scheTableLineW.isAvailableNow = lineavailable.get(stl.Id);
                        scheTableLineW.starttime = weekdayTimeFlag == true ? '/' : stl.Start_Working_Time__c;
                        scheTableLineW.endtime = weekdayTimeFlag == true ? '/' : stl.End_Working_Time__c;
                        scheTableLineWList.add(scheTableLineW);
                        linesUserSet.add(stl.User__c);
                    }
                }
            }
            else if (scheTable.Intercept__c == '分配至前台' || scheTable.Intercept__c == '分配至主管') {
                SchedulingTableLineWrapper scheTableLineW = new SchedulingTableLineWrapper();
                scheTableLineW.intercept = scheTable.Intercept__c;
                scheTableLineW.interceptByName = scheTable.Intercept__c == '分配至前台' ? 
                    scheTable.Front_Desk__r.Full_Name__c :
                    scheTable.Manager__r.Full_Name__c;
                scheTableLineW.interceptByID = scheTable.Intercept__c == '分配至前台' ?
                    scheTable.Front_Desk__c :
                    scheTable.Manager__c;
                scheTableLineW.manageR = scheTable.Manager__c;
                scheTableLineWList.add(scheTableLineW);
            }

            scheTableRoute.put(scheTableID, scheTableLineWList);
        }
    }

    private List<Scheduling_Table_Line__c> removeUnsuitableTableLines (List<Scheduling_Table_Line__c> schedlines) {

        List<Scheduling_Table_Line__c> unremoveSchedlines = new List<Scheduling_Table_Line__c> ();
        for (Scheduling_Table_Line__c schedline : schedlines) {

            Boolean remove = True;
            if (schedline.Source__c.contains(OPP.Source__c)) {
                remove = multiplePickListChecking(OppProjects, schedline.Project__c);
            }
            if (!remove) unremoveSchedlines.add(schedline);
        }

        return unremoveSchedlines;
    }

    private Boolean multiplePickListChecking (List<String> oppScopes, String scheTableScopes) {

        String scheTableScope = String.isNotBlank(scheTableScopes) ? scheTableScopes : '';
        for (String oppscope : oppScopes) {
            if (scheTableScope.contains(oppscope))
                return false;
        }
        return true;
    }

    public pagereference cancel () {
        if (OppID == null) {
          return new PageReference('/home/home.jsp');
        }  else {
          return new PageReference('/' + OppID);
        }
    }

    private String getcurrentTablePriorityCCName (ID scheTableID, Set<String> availableUsers) {

        List<Scheduling_Table_Order__c> currentOrders= [SELECT User__r.Full_Name__c, 
                                                               User__c, 
                                                               Total_Count__c,
                                                               Compensate_Number__c
                                                        FROM Scheduling_Table_Order__c
                                                        WHERE Scheduling_Table__c = :scheTableID
                                                        AND User__c IN :availableUsers
                                                        ORDER BY Count__c, Order__c ASC];
                                                       
        List<Scheduling_Table_Order__c> compenOrders= [SELECT User__c, 
                                                              Total_Count__c,
                                                              Compensate_Number__c
                                                        FROM Scheduling_Table_Order__c
                                                        WHERE Scheduling_Table__c = :scheTableID
                                                        AND User__c IN :availableUsers
                                                        ORDER BY Total_Count__c, Order__c ASC];

        if (currentOrders.size() > 0) {

            Scheduling_Table_Order__c currentOrder = currentOrders[0];
            userandTablepriorityMap.put(scheTableID, currentOrder.User__c);
            if (compenOrders[0].User__c == currentOrders[0].User__c) {
                tableCompensateMap.put(scheTableID, true);
                tableCompensateOrderMap.put(scheTableID, compenOrders[0]);
                return currentOrder.User__r.Full_Name__c;
            }
            else if (currentOrders[0].Total_Count__c < compenOrders[compenOrders.size() - 1].Total_Count__c) {
                tableCompensateMap.put(scheTableID, true);
                tableCompensateOrderMap.put(scheTableID, currentOrders[0]);
                return currentOrder.User__r.Full_Name__c;
            }
            tableCompensateMap.put(scheTableID, false);
        }
        return null;
    }

    private Set<String> getTodayScheLineUserNameSet (List<Scheduling_Table_Line__c > schelines) {

        Set<String> availableUsers = new Set<String>();

        for (Scheduling_Table_Line__c stl : schelines) {
          Boolean isavaliable = false;
          if (stl.is_Available_Now__c && checkisAvailableNow(stl)) {
            availableUsers.add(stl.User__c);
            isavaliable = true;
          }

          lineavailable.put(stl.Id, isavaliable);
        }
        return availableUsers;
    }

    private Boolean checkisAvailableNow (Scheduling_Table_Line__c stl) {

      Datetime dt = System.Now();
      if (dt.format('EEEE').equalsIgnoreCase('Sunday'))
         return  stl.sys_isavailable_Sunday__c;
      else if (dt.format('EEEE').equalsIgnoreCase('Monday'))
         return  stl.sys_isavailable_Monday__c;
      else if (dt.format('EEEE').equalsIgnoreCase('Tuesday'))
         return  stl.sys_isavailable_Tuesday__c;
      else if (dt.format('EEEE').equalsIgnoreCase('Wednesday'))
         return  stl.sys_isavailable_Wednesday__c;
      else if (dt.format('EEEE').equalsIgnoreCase('Thursday'))
         return  stl.sys_isavailable_Thursday__c;
      else if (dt.format('EEEE').equalsIgnoreCase('Friday'))
         return  stl.sys_isavailable_Friday__c;
      else if (dt.format('EEEE').equalsIgnoreCase('Saturday'))
         return  stl.sys_isavailable_Saturday__c;
      else
         return false;
    }

    private Set<String> getCurrentTableOrderUserSet (ID selectedscheTabl) {

        Set<String> orderUserSet = new  Set<String>();
        for (Scheduling_Table_Order__c scheOrder : [SELECT User__c 
                                                    FROM Scheduling_Table_Order__c 
                                                    WHERE Scheduling_Table__c = :selectedscheTabl]) {

            orderUserSet.add(scheOrder.User__c);
        }
        return orderUserSet;
    }

    public Boolean displayschedulingTableLineSection (Scheduling_Table__c scheTable) {

        return (ProfileRelated.getFDAProfileSet().contains(Userinfo.getProfileId())) || 
                  (scheTable.Intercept__c == '分配至顾问' || 
                   UserInfo.getUserId() == scheTable.Manager__c ||
                   UserInfo.getUserId() == scheTable.Front_Desk__c);
    }


    public pagereference getAppointmentsofUser () {

        try {

            applists = userAppointmentsMap.get(appviewuserId);
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
            return null;
    }

    private void generateScheTablineUserAppMap() {

        Date currentDay = System.Today();
        List<Appoitment__c> apps = [SELECT Name,
                                           Opportunity__r.Name,
                                           Opportunity__c,
                                           Intended_City__c,
                                           Intended_Office__c,
                                           Status__c,
                                           Duration__c,
                                           Assign_To__c,Description__c,
                                           Assign_To__r.Name,
                                           sys_Due_Date_Time__c,
                                           createdBy.Name
                                    FROM Appoitment__c
                                    WHERE Assign_To__c IN :linesUserSet
                                    AND Status__c IN ('跟进中')
                                    AND RecordTypeID = :RecordTypeRelated.Invitation_App
                                    AND sys_Due_Date_Time__c >= :currentDay
                                    AND sys_Due_Date_Time__c <= :currentDay.addDays(7)
                                    ORDER BY sys_Due_Date_Time__c];

        for (Appoitment__c app : apps) {
            List<Appoitment__c> newlist = new List<Appoitment__c>();

            if (userAppointmentsMap.get(app.Assign_To__c) == null) {
                newlist.add(app);
            } else {
                newlist = userAppointmentsMap.get(app.Assign_To__c);
                newlist.add(app);
            }
            userAppointmentsMap.put(app.Assign_To__c, newlist);
        }
    }

    private void appAssign (String assUserID) {

        if (initialAPPID != null) {

            List<Appoitment__c> app= [SELECT Assign_To__c FROM Appoitment__c WHERE Id = :initialAPPID LIMIT 1];

            if (app.size() > 0) {
                app[0].Assign_To__c=assUserID;
                app[0].Due_Time__c=initialAppTime;
                app[0].Due_Date__c=Date.valueOf(initialAppDate);
                update app;
            }
        }
    }

    private Boolean updateApp() {

        if (initialAPP != null) {
            if (initialAPP.Due_Date__c != null && initialAPP.Due_Time__c != null) {
                String appname = initialAPP.Opportunity__r.Account.Name + '| ' + initialAPP.Appointment_Type__c;
                Datetime dutime = Datetime.valueOf(string.valueOf(initialAPP.Due_Date__c) + ' ' + String.valueOf(initialAPP.Due_Time__c) + ':00');
                String year = String.valueOf(dutime.year());
                String month = String.valueOf(dutime.month());
                String day = String.valueOf(dutime.day());
                String hour = String.valueOf(dutime.hour());
                String min = String.valueOf(dutime.minute());
                appname = appname + ' | ' + year + '.' + month + '.' + day + ' ' + hour + ':' + min;
                initialAPP.Name = appname;
                update initialAPP;
                return true;
            }
            return false;
        }
        return true;
    }

    public PageReference showAllUsers () {

        showallUsers =! (showallUsers == true);
        SaveButtonFlag = false;
        return null;
    }

    public class SchedulingTableLineWrapper {

        public Scheduling_Table_Line__c schedulingTableLine { get;set; }
        public String intercept { get;set; }
        public String interceptByID { get;set; }
        public String interceptByName { get;set; }
        public String manager { get;set; }
        public Boolean isScheduling { get;set; }
        public Boolean isAvailableNow { get;set; }
        public String starttime { get;set; }
        public String endtime { get;set; }
    }
}