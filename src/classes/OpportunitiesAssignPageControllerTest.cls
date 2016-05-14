/**************************************************************************************************
 * Name: OpportunitiesAssignPageControllerTest
 * Object: opportunity
 * Purpose: Test Opportunity manually assign
 * Author: Ray Cen
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
@isTest
private class OpportunitiesAssignPageControllerTest {

   static testMethod void FunctionTest () {

            User usr = [SELECT Id
                        FROM User
                        WHERE Id = :UserInfo.getUserId()];

        // Prepares the test Data
        System.runAs(usr) {

            User uuser  =  TestObjectFactory.createSalesUser();
            uuser.Username = 'opp@test.com.eic.pwc';
            uuser.User_External_Id__c = '201604211738';
            insert uuser;

            User uuser2  =  TestObjectFactory.createSalesUser();
            uuser2.Username = 'oppowenr@test.com.eic.pwc';
            uuser2.User_External_Id__c = '201604211739';
            insert uuser2;
        }

        User runUser = [SELECT Id, Name
                        FROM User
                        WHERE username = 'opp@test.com.eic.pwc'];

        User lineUser = [SELECT Id, Name
                         FROM User
                         WHERE username = 'oppowenr@test.com.eic.pwc'];

        Account acc = TestObjectFactory.createAccount();
        acc.Name = 'AccQuickSearch';
        insert acc;

        Opportunity opp = TestObjectFactory.createOpportunity(acc.id, runUser);
        opp.Intended_City__c = '上海';
        insert opp;

        OpportunityTeamMember oppMember = TestObjectFactory.createOppTeam(opp, usr.Id);
        insert oppMember;

        Appoitment__c app = TestObjectFactory.createApp(opp, runUser.Id);
        app.Appointment_Type__c = '第5天任务';
        app.Assign_To__c = runUser.Id;
        app.OwnerId = lineUser.Id;
        insert app;

        Organization__c org = TestObjectFactory.createOrgs();
        org.Front_Desk__c = runUser.Id;
        insert org;

        Organization__c CSOrg = TestObjectFactory.createOrgs();
        CSorg.Department__c = '客服部';
        CSorg.Org_Manager__c = runUser.Id;
        CSorg.City__c = '上海';
        CSorg.RecordTypeID = [SELECT Id 
                              FROM RecordType 
                              WHERE SObjectType = 'Organization__c'
                              AND DeveloperName = 'Counselling' LIMIT 1].Id;
        insert CSOrg;

        Scheduling_Table__c sctable = TestObjectFactory.createSchedulingTable(org);
        sctable.Source__c = '集团TMK外呼';
        sctable.Project__c = '美国';
        sctable.Front_Desk__c = runUser.Id;
        sctable.Manager__c = runUser.Id;
        sctable.City__c = '上海';
        insert sctable;

        Scheduling_Table_Line__c sctline = TestObjectFactory.createScheTableLine(sctable);
        sctline.Project__c = '美国';
        sctline.Source__c = '集团TMK外呼';
        sctline.User__c = lineUser.Id;
        sctline.Start_Working_Time__c = '00:00';
        sctline.End_Working_Time__c = '23:59';
        sctline.Monday_Time__c = '√';
        sctline.Tuesday_Time__c = '√';
        sctline.Wednesday_Time__c = '√';
        sctline.Thursday_Time__c = '√';
        sctline.Friday_Time__c = '√';
        sctline.Saturday_Time__c = '√';
        sctline.Sunday_Time__c = '√';
        sctline.Compensation_Opportunity_Num__c = 0;
        sctline.Daily_Opportunities__c = 0;
        insert sctline;

        Scheduling_Table_Line__c sctline2 = TestObjectFactory.createScheTableLine(sctable);
        sctline2.User__c = UserInfo.getUserId();
        sctline2.Project__c = '美国';
        sctline2.Source__c = '集团TMK外呼';
        sctline2.User__c = runUser.Id;
        sctline2.Start_Working_Time__c = '00:00';
        sctline2.End_Working_Time__c = '23:59';
        sctline2.Monday_Time__c = '√';
        sctline2.Tuesday_Time__c = '√';
        sctline2.Wednesday_Time__c = '√';
        sctline2.Thursday_Time__c = '√';
        sctline2.Friday_Time__c = '√';
        sctline2.Saturday_Time__c = '√';
        sctline2.Sunday_Time__c = '√';
        sctline2.Compensation_Opportunity_Num__c = 0;
        sctline2.Daily_Opportunities__c = 0;
        insert sctline2;

        Scheduling_Table_Order__c sctOrder = TestObjectFactory.createScheTableOrder(sctable);
        sctOrder.Count__c = 0;
        sctOrder.Order__c = 1;
        sctOrder.User__c = lineUser.Id;
        insert sctOrder;

        Scheduling_Table_Order__c sctOrder2 = TestObjectFactory.createScheTableOrder(sctable);
        sctOrder2.User__c = runUser.Id;
        sctOrder2.Count__c = 0;
        sctOrder2.Order__c = 2;
        insert sctOrder2;

        Scheduling_Table_Order__c sctOrder3 = TestObjectFactory.createScheTableOrder(sctable);
        sctOrder3.User__c = runUser.Id;
        sctOrder3.Count__c = 0;
        sctOrder3.Order__c = 3;
        insert sctOrder3;

        WorkTimesV2__c wt = TestObjectFactory.createWorkTimesSetting();
        insert wt;

        shouldProcessRun__c avoidTrigger = TestObjectFactory.createShouldRun(usr.Id);
        insert avoidTrigger;

        Opportunity oppResult = new Opportunity();
        Scheduling_Table_Line__c sctlineResult = new Scheduling_Table_Line__c();
        Scheduling_Table_Line__c sctlineResult2 = new Scheduling_Table_Line__c();
        Scheduling_Table_Order__c sctOrderResult = new Scheduling_Table_Order__c();
        Scheduling_Table_Order__c sctOrderResult2 = new Scheduling_Table_Order__c();

        Test.StartTest();
        PageReference myVfPage = Page.OpportunitiesAssignPage;
        Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
        ApexPages.currentPage().getParameters().put('ID', opp.Id);
        ApexPages.currentPage().getParameters().put('appointId', app.Id);
        OpportunitiesAssignPageController oppassign = new OpportunitiesAssignPageController(new ApexPages.StandardController(opp));
        oppassign.getappDateTime();

        // Opportunity Directly Assign
        oppassign.assignMethod = 'OppDirectly';
        oppassign.assignMethodSelect();
        oppassign.selectedUserID = Userinfo.getUserId();
        oppassign.showAllDirectlyUsers();
        oppassign.selectuser();
        oppassign.assignOpp();

        oppResult = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(oppResult.OwnerId, UserInfo.getUserId());

        // Scheduling Table Assign
        oppassign.assignMethod = 'CC';
        oppassign.assignMethodSelect();
        oppassign.selectedscheTableID = sctable.Id;
        oppassign.selectScheTable();
        oppassign.showAllUsers();
        oppassign.selectedscehTableLineID = sctline.Id;
        oppassign.selectScheTableLine();
        oppassign.assignOpp();
        oppResult = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        sctlineResult = [SELECT Daily_Opportunities__c 
                         FROM Scheduling_Table_Line__c 
                         WHERE Id = :sctline.Id LIMIT 1];

        sctOrderResult = [SELECT Count__c 
                          FROM Scheduling_Table_Order__c 
                          WHERE Id = :sctOrder.Id LIMIT 1];

        System.assertEquals(oppResult.OwnerId, lineUser.Id);
        System.assertEquals(1, sctlineResult.Daily_Opportunities__c);
        System.assertEquals(1, sctOrderResult.Count__c);

        /* Compensate test, the line 2's order count is less than the line 1, 
        If assign opportunity to line 1, the compensate logic will be triggered*/
        oppassign = new OpportunitiesAssignPageController(new ApexPages.StandardController(opp));
        oppassign.assignMethod = 'CC';
        oppassign.assignMethodSelect();
        oppassign.selectedscheTableID=sctable.Id;
        oppassign.selectScheTable();
        oppassign.showAllUsers();
        oppassign.selectedscehTableLineID = sctline.Id;
        oppassign.selectScheTableLine();
        oppassign.assignOpp();
        oppassign.isGiveBack = true;
        oppassign.finish();
        sctlineResult2 = [SELECT Daily_Opportunities__c, Compensation_Opportunity_Num__c
                         FROM Scheduling_Table_Line__c 
                         WHERE Id = :sctline2.Id LIMIT 1];
        System.assertEquals(1, sctlineResult2.Compensation_Opportunity_Num__c);

        // low star pool Assign
        oppassign.assignMethod = 'Pool';
        oppassign.assignMethodSelect();
        oppassign.assignOpp();
        oppResult = [SELECT OwnerId, StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals('低星资源池', oppResult.StageName);
        System.assertEquals(runUser.Id, oppResult.OwnerId);
        oppassign.cancel();

        test.StopTest();
   }
}