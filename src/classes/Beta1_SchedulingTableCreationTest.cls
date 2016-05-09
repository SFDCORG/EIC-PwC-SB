/**************************************************************************************************
 * Name: Test Class for SchedulingTableCreation
 * Object: Scheduling Table 
 * Purpose: Test Create a scheduling table
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/
@isTest
private class Beta1_SchedulingTableCreationTest {

    //Test Creation and update
    static testMethod void FunctionTest() {

        // Prepares test Date
        WorkTimesV2__c wt = TestObjectFactory.createWorkTimesSetting();
        insert wt;
        Organization__c org = TestObjectFactory.createOrgs();
        insert org;

        test.StartTest();
        PageReference myVfPage = Page.Beta1_SchedulingTableCreation;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.currentPage().getParameters().put('ORGID', org.Id);
        Beta1_SchedulingTableCreation createTable= new Beta1_SchedulingTableCreation ();
        createTable.scheTableHead.name = 'test';
        createTable.scheTableHead.Project__c = '澳大利亚';
        createTable.scheTableHead.Source__c = '普通商机';
        createTable.scheTableHead.Intercept__c = '分配至顾问';
        createTable.scheTableHead.Manager__c = UserInfo.getUserId();
        List<String> project = new List<String> ();
        project.add('澳大利亚');
        createTable.addRow();
        createTable.scheLineList[0].selectedProjectScope = project;
        createTable.scheLineList[0].d1 = 'A';
        createTable.scheLineList[0].scheLine.Start_Working_Time__c = '00:00';
        createTable.scheLineList[0].scheLine.End_Working_Time__c = '20:00';
        createTable.scheLineList[0].scheLine.user__c = userinfo.getUserId();
        createTable.refreshScope();
        createTable.saveResult();

        // Queries new insert Scheduling Table Info
        Scheduling_Table_Line__c stl = [SELECT Monday_Time__c, Project__c
                                        FROM Scheduling_Table_Line__c
                                        LIMIT 1][0];

        Scheduling_Table__c st = [SELECT Name,Project__c, Source__c
                                  FROM Scheduling_Table__c
                                  LIMIT 1][0];

        PageReference myVfPageUpdate = Page.Beta1_SchedulingTableCreation;
        Test.setCurrentPageReference(myVfPageUpdate);
        ApexPages.currentPage().getParameters().put('ORGID', org.Id);
        ApexPages.currentPage().getParameters().put('TableID', st.Id);
        Beta1_SchedulingTableCreation updateTable = new Beta1_SchedulingTableCreation ();
        Test.stopTest();
        System.assertEquals('test', st.Name);
        System.assertEquals(true, st.Project__c.contains('澳大利亚'));
        System.assertEquals('A', stl.Monday_Time__c);
        System.assertEquals(true, stl.Project__c.contains('澳大利亚'));
    }
}