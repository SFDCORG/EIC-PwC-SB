/**************************************************************************************************
 * Name: AppointmentOwnerChangeControllerTest
 * Object: Appointment__c
 * Purpose: a test class for AppointmentOwnerChangeController
 * Author: Ray Cen
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen      Formats the code
 * 2016-05-06    Vicia      Adds comments
 **************************************************************************************************/
@isTest
private class AppointmentOwnerChangeControllerTest {

    static testMethod void appointmentsOwnerChange () {

        User usr = [SELECT Id
                    FROM User
                    WHERE Id = :UserInfo.getUserId()];

        // Prepares the test Data
        System.runAs(usr) {
            User uuser  =  TestObjectFactory.createSalesUser();
            uuser.Username = 'app@test.com.eic.pwc';
            uuser.User_External_Id__c = '201604211738';
            insert uuser;

            User uuser2  =  TestObjectFactory.createSalesUser();
            uuser2.Username = 'appowenr@test.com.eic.pwc';
            uuser2.User_External_Id__c = '201604211739';
            insert uuser2;
        }

        User runUser = [SELECT Id, PreciseSearch__c, Name
                        FROM User
                        WHERE username = 'app@test.com.eic.pwc'];

        User acceptor = [SELECT Id, PreciseSearch__c, Name
                         FROM User
                         WHERE username = 'appowenr@test.com.eic.pwc'];

        // Initializes the data
       	Account acc = TestObjectFactory.createAccount();
        acc.Name = 'AccQuickSearch';
        insert acc;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.id,acceptor);
        insert opp;
        OpportunityTeamMember oppMember = TestObjectFactory.createOppTeam(opp, usr.Id);
        insert oppMember;
        Appoitment__c app5 = TestObjectFactory.createApp(opp, runUser.Id);
        app5.Appointment_Type__c = '第5天任务';
        app5.Assign_To__c = runUser.Id;
        app5.OwnerId = acceptor.Id;
        insert app5;
        Appoitment__c app6 = TestObjectFactory.createApp(opp, runUser.Id);
        app6.Appointment_Type__c = '第5天任务';
        app6.Assign_To__c = acceptor.Id;
        app6.OwnerId = acceptor.Id;
        insert app6;

        Test.StartTest();
        System.runAs(runUser) {

            // Normal Process
            List<appoitment__c> apps = new List<appoitment__c> ();
            apps.add(app5);
            ApexPages.StandardSetController con = new ApexPages.StandardSetController (apps);
            con.setSelected(apps);
            AppointmentOwnerChangeController appOwnerChange = new AppointmentOwnerChangeController (con);

            // Doesn't select new acceptor, a error message will display: no acceptor has been selected
            appOwnerChange.newOwnerID = '';
            appOwnerChange.AssignOwnerChange();
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.NO_SELECTED_ACCEPTOR));

            // Selects one user and assign the appointments to him, the appointments' assign_to_C will be updated as which user selected
            appOwnerChange.newOwnerID = acceptor.Id;
            appOwnerChange.AssignOwnerChange();

            Appoitment__c result = [SELECT Assign_To__c
                                    FROM Appoitment__c
                                    WHERE Id = :apps[0].Id
                                    LIMIT 1];

            System.assertEquals(acceptor.Id, result.Assign_To__c);

            // If the assign_to__c don't be changed. It also can be saved, and saved successfully.
            appOwnerChange.newOwnerID = runUser.Id;
            appOwnerChange.AssignOwnerChange();
            Appoitment__c result2 = [SELECT Assign_To__c, CreatedDate, LastModifiedDate
                                     FROM Appoitment__c
                                     WHERE Id = :apps[0].Id
                                     LIMIT 1];
            System.assertEquals(false, result2.CreatedDate == result2.LastModifiedDate);
            System.assertEquals(runUser.Id, result2.Assign_To__c);

            // Test Cancel method
            appOwnerChange.cancel();

            // Doesn't Select Assignments in the list view, an error message will display, no selected assignments
            apps.clear();
            ApexPages.StandardSetController con2 = new ApexPages.StandardSetController (apps);
            con2.setSelected(apps);
            AppointmentOwnerChangeController appOwnerChange2 = new AppointmentOwnerChangeController (con2);
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.NO_ASSIGNMENT_SELECTED));

            // Contain some appointments which current user don't have permission to edit it assign to user, 
            // an error message will display: Contain No Access Appointments.
            apps.add(app6);
            PageReference myVfPage = Page.AppoitmentOwnerChangeController;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardSetController con3 = new ApexPages.StandardSetController (apps);
            con3.setSelected(apps);

            // Checks whether the user can change others' record
            AppointmentOwnerChangeController appOwnerChange3 = new AppointmentOwnerChangeController (con3);
            appOwnerChange3.newOwnerID = acceptor.Id;
            appOwnerChange3.AssignOwnerChange();            
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.CHANGE_WITH_NO_ACCESS_APP));
        }
        Test.StopTest();
    }
}