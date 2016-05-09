/**************************************************************************************************
 * Name: SchedulingTableCreation
 * Object: Scheduling Table 
 * Purpose: Create or update a scheduling table
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/
public class Beta1_SchedulingTableCreation { 

    public Scheduling_Table__c scheTableHead { get; set; } // Scheduling Table 
    public String OrgID { get; set; } // Organization Id
    public String existSchedTableID { get; set; } // The scheduling table Id for update existing table
    public List<SchedLineWrapper> scheLineList { get; set; } // The Scheduling Table Line List
    public String rowIndex { get; set; } // The Selected row number
    public Boolean ccErrorFlag { get; set; } // Error message shall be shown after added new line
    public Boolean headErrorFlag { get; set; } // Error Message shall be shown after clicked save button.
    public String nextaction { get; set; } // Error Message shall be shown after click next button
    public List<String> headprojectScope { get; set; } // Scheduling Table Project
    public List<String> headSocurceScope { get; set; } // Scheduling Table Source
    public String hidProjects { get; set; } // The selected projects
    public String hidSources { get; set; } // The selected sources
    public String worktimeExample { get; set; } // The fixed work Time display label
    public Boolean weekdayTimeFlag { get; set; } // The fixed work time label shall be shown or not
    public Boolean newflag { get; set; } // New / update a scheduling Table
    public Integer rownum; // Total Scheduling Table line's count
    private Set<Integer> deletedID = new Set<Integer> (); // The Deleted row number
    private List<Scheduling_Table_Line__c> removeLineList; // The Scheduling Table lines which shall be deleted
    private String recordtypeName = ''; // Record type Name
    private WorkTimesV2__c wtimeSets = new WorkTimesV2__c (); // Fixed work time

    public  Beta1_SchedulingTableCreation() {

        scheTableHead = new Scheduling_Table__c ();
        List<SchedLineWrapper> scheLineList = new List<SchedLineWrapper> ();
        removeLineList = new List<Scheduling_Table_Line__c> ();
        headprojectScope = new List<String> ();
        headSocurceScope = new List<String> ();
        rownum = 1;
        rowIndex = '1';
        nextaction = '';
        hidProjects = '';
        hidSources = '';
        ccErrorFlag = false;
        headErrorFlag = false;
        worktimeExample = '';
        weekdayTimeFlag = true;
        newflag = true;
        initializationSchedulingTableBasicInfo();
        getTimeCustomSetting();
    }

    // Adds new scheduling Table Line
    public void addRow() {

        // The scheduling Table's project and source can't be empty
        if (String.isNotBlank(scheTableHead.Project__c)&&
            String.isNotBlank(scheTableHead.Source__c)) {

            Boolean refreshScope = false;
            ccErrorFlag = true;
            headprojectScope = translateStringtoList(scheTableHead.Project__c);
            if (scheLineList != null) refreshScope = RegenerateaSelectScope();
            if (refreshScope || scheLineList == null) {
              addNewRow();
              rownum ++;
              ccErrorFlag = false;
            }
        } else {
            ccErrorFlag = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 Constants.NO_SELECTED_PROJECT_OR_SOURCE));
        }
    }

    // Remove scheduling Table Line
    public PageReference removeLine() {

        List<SchedLineWrapper> existLinelist = new List<SchedLineWrapper> ();
        for (SchedLineWrapper sline : scheLineList) {

            if (String.valueOf(sline.index) <> rowIndex) existLinelist.add(sline);
            else if (sline.isExistLine) removeLineList.add(sline.scheLine);
        }
        scheLineList.clear();
        scheLineList.addAll(existLinelist);
        deletedID.add(Integer.valueOf(rowIndex));
        RegenerateaSelectScope();
        return null;
    }

    // Saves edit or create result
    public pagereference saveResult () {

        RegenerateaSelectScope();
        String checkLineResult = checkLineValue();
        String checkTableResult = checkSchedulingTableFieldEmpty();
        headErrorFlag = false;
        ccErrorFlag = false;

        // Check Scheduling Table fields have been inputed normally.
        if (checkTableResult != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, checkTableResult));
            headErrorFlag = true;
            return null;
        }

        // Check all Scheduling Table Lines fields have been inputed normally.
        if (checkLineResult != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, checkLineResult));
            ccErrorFlag=true;
            return null;
        }
        
        upsert scheTableHead; // Upserts scheduling table info
        upsertline(); // Upserts new scheduling table info
        deleteLine(); // Deletes these scheduling Table lines which have been removed

        SchedulingTableOrderRelated.IndicatorOrder(existSchedTableID);
        
        //If next action equals next, go the Scheduling table order creation page.
        if (nextaction == 'next') {

            if (scheLineList.size() > 0) {

                return new PageReference('/apex/SchedulingTableOrderGenerationPage?ID=' + scheTableHead.Id);
            } else {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.NO_SHCEDULING_TABLE_LINE));
                headErrorFlag = true;

                return null;
            }
        } else return new PageReference('/' + scheTableHead.Id);
    }
    
    // Cancel current Visualforce page
    public pagereference cancel() {

        if (String.isNotBlank(OrgID) && String.isBlank(existSchedTableID)) {
            return new PageReference('/' + OrgID);
        }  else {
            return new PageReference('/' + existSchedTableID);
        }
        return null;
    }

    //Initializes Scheduling Table Basic Info ,such as owner, manger,set default value, if it's existing table, get old vale.
    private void initializationSchedulingTableBasicInfo () {
        scheTableHead.OwnerId = UserInfo.getUserId();
        scheTableHead.Manager__c = UserInfo.getUserId();
        getLoginUserOrgInfo();
        getexistSchedTable();
    }

    // Get the organization info by the org Id.
    private void getLoginUserOrgInfo() {

        OrgID = ApexPages.CurrentPage().getparameters().get('ORGID');
        if (String.isNotBlank(OrgID)) getOrgInfo();
    }
    
    // Get existing Scheduling Table
    private void getexistSchedTable () {
        existSchedTableID = ApexPages.currentPage().getparameters().get('TableID');
        if (String.isNotBlank(existSchedTableID)) {
            scheTableHead = [SELECT Id,
                                    Name,
                                    Department__c,
                                    Project__c,
                                    Intercept__c,
                                    Manager__c,
                                    End_Date__c,
                                    Front_Desk__c,
                                    City__c,
                                    Source__c,
                                    RecordTypeID,
                                    Office__c,
                                    OwnerId,
                                    isActive__c, 
                                    RecordType.DeveloperName
                              FROM Scheduling_Table__c
                              WHERE Id = :existSchedTableID 
                              LIMIT 1];

            headprojectScope = translateStringtoList(scheTableHead.Project__c);
            headSocurceScope = translateStringtoList(scheTableHead.Source__c);
            initializationSchedulingLine();
            newflag = false;
        }
    }
    
    // Does the get orgnization info operation , and judges current record type's scheduling table is fixed work time or not
    private void getOrgInfo() {
        List<Organization__c> org = [SELECT Id,
                                            Name,
                                            City__c,
                                            Front_Desk__c,
                                            Office__c,
                                            Department__c,
                                            RecordType.DeveloperName
                                     FROM Organization__c 
                                     WHERE id = :OrgID];
            
        if (org.size() > 0) {
            scheTableHead.RecordTypeId = ([SELECT id 
                                           FROM RecordType 
                                           WHERE SObjectType = 'Scheduling_Table__c' 
                                           AND DeveloperName = :org[0].RecordType.DeveloperName limit 1][0].id);

            scheTableHead.City__c = org[0].City__c;
            scheTableHead.Office__c = org[0].Office__c;
            scheTableHead.Front_Desk__c = org[0].Front_Desk__c;
            scheTableHead.Department__c = org[0].Department__c;
            scheTableHead.Organization__c = OrgID;

            recordtypeName = [SELECT DeveloperName 
                              FROM RecordType 
                              WHERE Id = :scheTableHead.RecordTypeId limit 1].DeveloperName;

            wtimeSets = [SELECT A__c,B__c,C__c,D__c,Enable_Table_Record_Type__c 
                         FROM WorkTimesV2__c
                         Order By name limit 1];

            weekdayTimeFlag = wtimeSets.Enable_Table_Record_Type__c.contains(recordtypeName);

            if (weekdayTimeFlag) {
              worktimeExample = Constants.JOB_CYCLE;
              worktimeExample += ' ▍' + 'A' + ':' + wtimeSets.A__c + '  ' +
                                 ' ▍' + 'B' + ':' + wtimeSets.B__c + '  ' +
                                 ' ▍' + 'C' + ':' + wtimeSets.C__c + '  ' +
                                 ' ▍' + 'D' + ':' + wtimeSets.D__c + '  ';
            }
        }
    }
    
    // Initialization Scheduling Lines information
    private void initializationSchedulingLine() {
        rownum = 1;
        List<Scheduling_Table_Line__c> existingLines = SchedulingTableRelatedController.queryLine(existSchedTableID);
        scheLineList = new List<SchedLineWrapper> ();
        for (Scheduling_Table_Line__c line:existingLines) {
           
            SchedLineWrapper schlinew = new SchedLineWrapper();
            schlinew.scheLine = line;
            schlinew.index = rownum;
            schlinew.selectedProjectScope = translateStringtoList(line.Project__c);
            schlinew.projectsScope =  getavailableProject(schlinew.selectedProjectScope, headprojectScope);
            schlinew.isExistLine = true;
            schlinew.selectedProject = '';
            schlinew.projects = '';
            
            if (weekdayTimeFlag) {
                schlinew.d1 = line.Monday_Time__c;
                schlinew.d2 = line.Tuesday_Time__c;
                schlinew.d3 = line.Wednesday_Time__c;
                schlinew.d4 = line.Thursday_Time__c;
                schlinew.d5 = line.Friday_Time__c;
                schlinew.d6 = line.Saturday_Time__c;
                schlinew.d7 = line.Sunday_Time__c;
            } else {
                schlinew.dc1 = line.Monday_Time__c == '√' ? true : false;
                schlinew.dc2 = line.Tuesday_Time__c == '√' ? true : false;
                schlinew.dc3 = line.Wednesday_Time__c == '√' ? true : false;
                schlinew.dc4 = line.Thursday_Time__c == '√' ? true : false;
                schlinew.dc5 = line.Friday_Time__c == '√' ? true : false;
                schlinew.dc6 = line.Saturday_Time__c == '√' ? true : false;
                schlinew.dc7 = line.Sunday_Time__c == '√' ? true : false;
            }
 
            hidProjects += rownum + ':' + line.Project__c + ',';
            rownum ++;
            scheLineList.add(schlinew);
        }
    }
    
    // Convert string to string List
    private List<String> translateStringtoList(String initial) {
        List<String> options = new List<String> ();
        if (initial != null) {
            for (String project:initial.split(';')) {
                options.add(project);
            }
        }
        return options;
    }
    
    // Get available project options
    private List<String> getavailableProject(List<String> selectedOptions, List<String> allOptions) {
        Set<String> optionSet = new  Set<String> ();
        List<String> returnResult = new  List<String> ();
        for (String selectedOption : selectedOptions ) {
            optionSet.add(selectedOption);
        }
        for (String option: allOptions) {
            if (!optionSet.contains(option)) returnResult.add(option);
        }

        return returnResult;
    }

    private void addNewRow() {
        SchedLineWrapper schelin = new SchedLineWrapper ();
        schelin.scheLine = new Scheduling_Table_Line__c ();
        schelin.selectedProjectScope = new List<String> ();
        schelin.projectsScope = headprojectScope;
        schelin.index = (rownum == null) ? 1 : rownum;
        schelin.isExistLine = false;
        schelin.scheLine.Start_Working_Time__c = '09:00';
        schelin.scheLine.End_Working_Time__c = '18:00';
        scheLineList = (rownum == 1) ? new List<SchedLineWrapper> () : scheLineList;
        scheLineList.add(schelin); 
        hidProjects += schelin.index + ':';
        newflag = false;
    }

    private void upsertline () {

        List<Scheduling_Table_Line__c> scheTabLineList = new List<Scheduling_Table_Line__c> ();
        for (SchedLineWrapper slw:scheLineList) {

            Scheduling_Table_Line__c scheTabLine = slw.scheLine;
            scheTabLine.Project__c = translateListtoString(slw.selectedProjectScope);
            scheTabLine.Source__c = scheTableHead.Source__c;

            if (weekdayTimeFlag) {
                schetabline.Monday_Time__c = slw.d1;
                schetabline.Tuesday_Time__c = slw.d2;
                schetabline.Wednesday_Time__c = slw.d3;
                schetabline.Thursday_Time__c = slw.d4;
                schetabline.Friday_Time__c = slw.d5;
                schetabline.Saturday_Time__c = slw.d6;
                schetabline.Sunday_Time__c = slw.d7;
                schetabline.Start_Working_Time__c = '00:00';
                schetabline.End_Working_Time__c = '24:00';

            } else {

                schetabline.Monday_Time__c = slw.dc1 ? '√' : 'N/A';
                schetabline.Tuesday_Time__c = slw.dc2 ? '√' : 'N/A';
                schetabline.Wednesday_Time__c = slw.dc3 ? '√' : 'N/A';
                schetabline.Thursday_Time__c = slw.dc4 ? '√' : 'N/A';
                schetabline.Friday_Time__c = slw.dc5 ? '√' : 'N/A';
                schetabline.Saturday_Time__c = slw.dc6 ? '√' : 'N/A';
                schetabline.Sunday_Time__c = slw.dc7 ? '√' : 'N/A';
            }
            if (!slw.isExistLine) {
                scheTabLine.Scheduling_Table__c = scheTableHead.Id;
            }
            scheTabLineList.add(scheTabLine);
        }
        try { upsert scheTabLineList; }
        catch (Exception e) { ApexPages.addMessages(e); }
    }

    private String translateListtoString (List<String> selectedList) {
        String returnReuslt = '';
        for (String so : selectedList) {
            returnReuslt = returnReuslt + so + ';';
        }
        return returnReuslt == '' ? '' : returnReuslt.substring(0,returnReuslt.length() - 1);
    }

    private void deleteLine () {
       try { delete removeLineList; }
       catch (Exception e) { ApexPages.addMessages(e); }
    }

    public class SchedLineWrapper {
        public Integer index { get; set; }
        public Scheduling_Table_Line__c scheLine { get; set; }
        public Boolean isExistLine { get; set; }
        public List<String> sourcesScope { get; set; }
        public List<String> projectsScope { get; set; }
        public List<String> selectedsourcesScope { get; set; }
        public List<String> selectedProjectScope { get; set; }
        public String selectedProject { get; set; }
        public String selectedSources { get; set; }
        public String sources { get; set; }
        public String projects { get; set; }
        public String d1 { get; set; }
        public String d2 { get; set; }
        public String d3 { get; set; }
        public String d4 { get; set; }
        public String d5 { get; set; }
        public String d6 { get; set; }
        public String d7 { get; set; }
        public Boolean dc1 { get; set; }
        public Boolean dc2 { get; set; }
        public Boolean dc3 { get; set; }
        public Boolean dc4 { get; set; }
        public Boolean dc5 { get; set; }
        public Boolean dc6 { get; set; }
        public Boolean dc7 { get; set; }
    }
    
    private String checkSchedulingTableFieldEmpty () {

        if (scheTableHead.Name == null) {
            return Constants.SCHED_TABLE_NAME_EMPTY;
        }
        else if (scheTableHead.Project__c == null ||
                 scheTableHead.Source__c == null) {
            return Constants.SCHED_TABLE_PROJECT_SOURCE_EMPTY;
        }
        else if (scheTableHead.Manager__c == null) {
            return Constants.SCHED_TABLE_MANAGER_EMPTY;
        }
        else if (scheTableHead.Intercept__c == null) {
            return Constants.SCHED_TABLE_INTERCEPT_EMPTY;
        }
        return '';
    }

    private String checkLineValue() {

        Map<ID,Integer> userIDs=checkduplicate();

        for (SchedLineWrapper slw:scheLineList) {

            if (slw.scheLine.User__c == null) {
                return Constants.SCHED_LINE_USER_EMPTY;
            }
            else if (slw.selectedProjectScope.size() == 0) {
                return Constants.SCHED_LINE_PROJECT_EMPTY;
            }
            else if (slw.scheLine.Start_Working_Time__c == null &&
                    slw.scheLine.End_Working_Time__c == null && 
                    !weekdayTimeFlag) {
                return Constants.SCHED_LINE_TIME_EMPTY;
            }
            else if (slw.scheLine.Start_Working_Time__c == null &&
                     !weekdayTimeFlag) {
                return Constants.SCHED_LINE_STARTTIME_EMPTY;
            }
    
            else if (slw.scheLine.End_Working_Time__c == null && 
                    !weekdayTimeFlag) {
                return Constants.SCHED_LINE_ENDTIME_EMPTY;
            }
    
            else if (userIDs.size() > 0 &&
                    userIDs.get(slw.scheLine.User__c) > 1) {
                return Constants.SCHED_LINE_USER_DUPLICATE;
            }
        }
        return '';
    }

    private Map<ID,Integer> checkduplicate() {

        Map<ID,Integer> userIDs = new Map<ID,Integer> ();
        scheLineList=scheLineList == null ? new List<SchedLineWrapper> () : scheLineList;
        for (SchedLineWrapper slw:scheLineList) {
            if (slw.scheLine.User__c != null) {
                userIDs.put(slw.scheLine.User__c,userids.get(slw.scheLine.User__c) == null ? 1 : userids.get(slw.scheLine.User__c) + 1);
            }
        }
        return userIDs;
    }
    
    // Process Visualforce hidden string, generate selected projects info
    private Boolean RegenerateaSelectScope() {

        String phid = '';
        String shid = '';
        try{
            for (SchedLineWrapper slw : scheLineList) {

                String hproj = hidProjects;
                String nextindex = String.valueOf(Integer.valueOf(slw.index) + 1);
                Integer pstartindex = 0;
                Integer pendindex = 0;
                while (deletedID.contains(Integer.valueOf(nextindex)) && !hidProjects.contains(nextindex + ':')) {

                    nextindex = String.valueOf(Integer.valueOf(nextindex) + 1);
                }

                pstartindex = hidProjects.indexOf(slw.index + ':') + 2;
                pendindex = hidProjects.indexOf(',' + nextindex + ':') >= 0 ? 
                            hidProjects.indexOf(',' + nextindex + ':') : 
                            hidProjects.length() - 1;

                hproj = hproj.substring(pstartindex,pendindex);
                slw.selectedProjectScope = translateStringtoList(hproj.trim().replace(':','').replace(';;',';').replace(':;',':').replace(',',''));
                slw.projectsScope = getavailableProject(slw.selectedProjectScope, translateStringtoList(scheTableHead.Project__c));
                phid += slw.index + ':' + hproj + ',';
            }
            hidProjects=phid.replace('::',':');
            return true;
          }
          catch (Exception e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.SCHED_LINE_PROJECT_SOURCE_EMPTY));
              return false;
          }
    }
    
    // After user changed the scheduling Table's projects and sources, the scheduling table lines' info shall be updated
    public PageReference refreshScope() {
        headprojectScope = translateStringtoList(scheTableHead.Project__c);
        scheLineList = (rownum == 1) ? new List<SchedLineWrapper> () : scheLineList;
        RegenerateaSelectScope();
        hidProjects = '';
        for (SchedLineWrapper slw : scheLineList) {

            slw.selectedProjectScope = removeNonAvailabeString(headprojectScope, slw.selectedProjectScope);
            slw.projectsScope =  getavailableProject(slw.selectedProjectScope, headprojectScope);
            hidProjects += slw.index + ':' + translateListtoString(slw.selectedProjectScope) + ',';
        }
        return null;
    }

    public List<String> removeNonAvailabeString(List<String> availableLines, List<String> existingLines) {
        
        Set<String> availableLinesSet = new Set<String> ();
        List<String> returnList = new List<String> ();
        availableLinesSet.addAll(availableLines);
        for (String str : existingLines) {
            if (availableLinesSet.contains(str)) {
                returnList.add(str);
            }
        }
        return returnList;
    }

    public  List<SelectOption> getTimeCustomSetting() {

        List<SelectOption>  options = new List<SelectOption> ();
        if (weekdayTimeFlag) {
            options.add(new SelectOption('N/A', 'N/A'));
            options.add(new SelectOption('A', 'A'));
            options.add(new SelectOption('B', 'B'));
            options.add(new SelectOption('C', 'C'));
            options.add(new SelectOption('D', 'D'));
        }
        return options;
    }
 }