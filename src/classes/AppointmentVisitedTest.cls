/**************************************************************************************************
 * Name: AppointmentVisitedTest
 * Object: Appointment__c, Opportunity, Account
 * Purpose: a test class for AppointmentTriggerAfterInsert, AppointmentTriggerAfterUpdate
 * Author: Joe Zhou ()
 * Create Date: --
 * Modified History: 
 * 2016-05-11 Vicia Wang   Writes comments in this format
***************************************************************************************************/
@isTest
private class AppointmentVisitedTest {

    // Does the test for the partial convert lead
    @isTest static void testPartialConvertVisit() {

        // Initializes the appointment users
        CreateUserUtil.CreateUserForAppointment();
        User admin = TestObjectFactory.createUser();
        User groupTMKManager = [SELECT UserRole.Name
                                FROM User
                                WHERE UserName = 'sophiezhou@eic.com.testcode'];

        Opportunity opp = new Opportunity();
        Lead lead = new Lead();
        List<Lead_Item__c> leadItemList = new List<Lead_Item__c>();
        Appoitment__c firstInvitation = new Appoitment__c ();

        // To avoid DML MIXED system error
        System.runAs(admin) {
            
            Account acc = TestObjectFactory.createAccount('13200000001');
            opp = TestObjectFactory.createCounsellingOpportunity(acc);
            // Adds read access for the group TMK Manager
            TestObjectFactory.insertAccountShare(groupTMKManager, acc);
            Campaign BankofChina = TestObjectFactory.createCampaign ('BOC', Constants.COUNSELLING_CN, 
                                                                     'Offline', 'Business Cooperation', 
                                                                     'BSH');
            
            // Skips the lead trigger to create lead and lead item
            Utils.runLeadTrigger = FALSE;
            lead = TestObjectFactory.createLead(BankofChina, Constants.CITY_SH_CN, 
                                                TRUE, '19099990000', '22220000');
            lead.Status = Constants.LEAD_STATUS_PARTIAL_CONVERTED_CN;
            lead.OwnerId = groupTMKManager.Id;
            insert lead;
            
            TestObjectFactory.createLeadItemList(lead);
            leadItemList = [SELECT Status__c, Opportunity__c
                            FROM Lead_Item__c
                            WHERE Lead__c = : lead.Id];

            // We should get a converted lead item to test 7-day showup
            leadItemList[0].Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_WON_CN;
            leadItemList[0].Opportunity__c = opp.Id;
            update leadItemList[0];
        }

        Test.startTest();

        System.runAs(groupTMKManager) {
            
            firstInvitation = TestObjectFactory.createAppointment(opp, groupTMKManager, 'Invitation', 1);
        }

        System.runAs(admin) {

            // Inserts a front desk visit appointment to trigger the logic to udpate lead status
            Appoitment__c frontDeskVisit = TestObjectFactory.createAppointment(opp, groupTMKManager, 'Front Desk Visit', 0);
        
            // Checks whether the first invitation created by TMK status has been changed.
            for (Appoitment__c app : [SELECT TMKAppStatus__c 
                                      FROM Appoitment__c
                                      WHERE Id = :firstInvitation.Id]) {

                System.assertEquals(Constants.APP_VISITED, app.TMKAppStatus__c);
            }

            // Checks the related lead and lead item status
            lead = [SELECT Status, 
                           (SELECT Status__c FROM Lead_Items__r)
                    FROM Lead
                    WHERE Id = : lead.Id];

            // The lead and lead item status should be updated
            System.assertEquals(Constants.LEAD_ITEM_STATUS_CONVERTED_WON_VISITED_CN, lead.Lead_Items__r[0].Status__c);
            System.assertEquals(Constants.LEAD_STATUS_PARTIAL_CONVERTED_VISITED_CN, lead.Status);
        }
        Test.stopTest();
    }

    // Does the test for the partial convert lead
    @isTest static void testWholeConvertVisit () {

        // Initializes the appointment users
        CreateUserUtil.CreateUserForAppointment();
        User admin = TestObjectFactory.createUser();
        User groupTMKManager = [SELECT UserRole.Name
                                FROM User
                                WHERE UserName = 'sophiezhou@eic.com.testcode'];
        
        User branchConsultant = [SELECT Id 
                                 FROM User 
                                 WHERE Username = 'own@eic.com.testcode'];

        Opportunity opp = new Opportunity();
        Appoitment__c firstInvitation = new Appoitment__c ();
        Appoitment__c secondInvitation = new Appoitment__c ();
        Lead lead = new Lead();
        List<Lead_Item__c> leadItemList = new List<Lead_Item__c>();
        
        // Initializes the data
        System.runAs(admin) {

            Account acc = TestObjectFactory.createAccount('13200000001');
            opp = TestObjectFactory.createCounsellingOpportunity(acc);
            // Adds read access for the group TMK Manager
            TestObjectFactory.insertAccountShare(groupTMKManager, acc);
            TestObjectFactory.insertAccountShare(branchConsultant, acc);
            Campaign BankofChina = TestObjectFactory.createCampaign ('BOC', Constants.COUNSELLING_CN, 
                                                                     'Offline', 'Business Cooperation', 
                                                                     'BSH');
            
            // Skips the lead trigger to create lead and lead item
            Utils.runLeadTrigger = FALSE;
            lead = TestObjectFactory.createLead(BankofChina, Constants.CITY_SH_CN, 
                                                     TRUE, '19099990000', '22220000');
            lead.Status = Constants.LEAD_STATUS_WHOLE_CONVERTED_CN;
            lead.OwnerId = groupTMKManager.Id;
            insert lead;

            TestObjectFactory.createLeadItemList(lead);
            leadItemList = [SELECT Status__c, Opportunity__c
                            FROM Lead_Item__c
                            WHERE Lead__c = : lead.Id]; 
            // We should get a converted lead item to test 7-day showup
            leadItemList[0].Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN;
            leadItemList[1].Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN;
            leadItemList[2].Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_CN;
            leadItemList[0].Opportunity__c = opp.Id;
            update leadItemList;
        }

        Test.startTest();

        System.runAs(groupTMKManager) {
            
            TriggerShouldRun.AppointmentShouldRun = FALSE;
            firstInvitation = TestObjectFactory.createAppointment(opp, groupTMKManager, 'Invitation', 2);
            TriggerShouldRun.AppointmentShouldRun = TRUE;
        }

        System.runAs(admin) {

            // Inserts a front desk visit appointment to trigger the logic to udpate lead status
            Appoitment__c frontDeskVisit = TestObjectFactory.createAppointment(opp, groupTMKManager, 'Front Desk Visit', 0);
        }

        // Checks the related lead and lead item status
        lead = [SELECT Status, 
                       (SELECT Status__c FROM Lead_Items__r)
                FROM Lead
                WHERE Id = : lead.Id];

        // The lead and lead item status should be updated
        System.assertEquals(Constants.LEAD_ITEM_STATUS_CONVERTED_DUP_VISITED_CN, lead.Lead_Items__r[0].Status__c);        
        System.assertEquals(Constants.LEAD_STATUS_WHOLE_CONVERTED_VISITED_CN, lead.Status);

        System.runAs(branchConsultant) {            

            TriggerShouldRun.AppointmentShouldRun = FALSE;
            secondInvitation = TestObjectFactory.createAppointment(opp, branchConsultant, 'Invitation', 1);
            TriggerShouldRun.AppointmentShouldRun = TRUE;
            secondInvitation.Follow_Up_Result__c = Constants.APP_VISITED;
            update secondInvitation;
        }        

        // Checks whether the first invitation created by TMK status has been changed.
        for (Appoitment__c app : [SELECT TMKAppStatus__c 
                                  FROM Appoitment__c
                                  WHERE Id = :firstInvitation.Id]) {

            System.assertEquals(Constants.APP_VISITED, app.TMKAppStatus__c);
        }
        Test.stopTest();
    }

    // Does the test for creating lead follow up
    @isTest static void testLeadFollow () {

        // Initializes the appointment users
        CreateUserUtil.CreateUserForAppointment();
        User admin = TestObjectFactory.createUser();
        User groupTMKManager = [SELECT UserRole.Name
                                FROM User
                                WHERE UserName = 'sophiezhou@eic.com.testcode'];

        Opportunity opp = new Opportunity();
        Lead lead = new Lead();
        List<Lead_Item__c> leadItemList = new List<Lead_Item__c>();
        
        // To avoid DML MIXED system error
        System.runAs(admin) {           

            Account acc = TestObjectFactory.createAccount('13200000001');
            opp = TestObjectFactory.createCounsellingOpportunity(acc);
            // Adds read access for the group TMK Manager
            TestObjectFactory.insertAccountShare(groupTMKManager, acc);
            Campaign BankofChina = TestObjectFactory.createCampaign ('BOC', Constants.COUNSELLING_CN, 
                                                                     'Offline', 'Business Cooperation', 
                                                                     'BSH');
            
            // Skips the lead trigger to create lead and lead item
            Utils.runLeadTrigger = FALSE;
            lead = TestObjectFactory.createLead(BankofChina, Constants.CITY_SH_CN, 
                                                     TRUE, '19099990000', '22220000');
            lead.Status = Constants.LEAD_STATUS_WHOLE_CONVERTED_CN;
            lead.OwnerId = groupTMKManager.Id;
            insert lead;
            TestObjectFactory.createLeadItemList(lead);
        }

        Test.startTest();
        Appoitment__c leadFollowup = new Appoitment__c ();
        Appoitment__c secondInvitation = new Appoitment__c ();        

        System.runAs(groupTMKManager) {
            
            leadFollowup = TestObjectFactory.createLeadFollowup(lead);
            leadFollowup.Follow_Up_Result__c = Constants.APP_FOLLOWUP_RESULT_REFUSE_CN;
            leadFollowup.Description__c = 'Test';
            update leadFollowup;
        }

        // Checks the related lead and lead item status
        lead = [SELECT Followup_Result__c, Description
                FROM Lead
                WHERE Id = : lead.Id];

        // Lead follow up result and description should be updated
        System.assertEquals(leadFollowup.Follow_Up_Result__c, lead.Followup_Result__c);
        System.assert(lead.Description.contains(leadFollowup.Description__c));
    }
}