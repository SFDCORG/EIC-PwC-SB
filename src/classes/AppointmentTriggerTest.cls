/**************************************************************************************************
 * Name: AppointmentTriggerTest
 * Object: Appoitment__c
 * Purpose: a test class for appoint trigger: AppointmentTriggerBeforeUpdate, AppointmentTriggerBeforeInsert
 *          AppointmentTriggerAfterInsert, AppointmentTriggerAfterUpdate
 * Author: Ray Cen ()
 * Create Date: 2016-05-11
 * Modified History: 
 * 2016-05-11 Vicia Wang    Writes comments in this format
***************************************************************************************************/
@isTest
private class AppointmentTriggerTest {

    // If the first appoinment is created date less than 7 days with today
    @isTest static void testTmkAppointment7DaysRule1() {

        User admin = TestObjectFactory.createUser();
        User userTMKA = new User();
        User userTMKB = new User();

        System.runAs(admin) {
            
            // Initializes the users
            userTMKA = TestObjectFactory.createTmkUser('userTMKA');
            insert userTMKA;
            userTMKB = TestObjectFactory.createTmkManager('userTMKB');
            insert userTMKB;
        }

        Test.startTest();
        // Initializes the data
        Account acc = TestObjectFactory.createAccount();
        insert acc;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.Id, userTMKA);
        insert opp;

        Appoitment__c TMKAApp1 = new Appoitment__c();

        // Checks whether insert sucessfully and check
        System.runAs(userTMKA) {
            
            TMKAApp1 = TestObjectFactory.createAppointment(opp, userTMKA, 'Invitation', 2);
            System.AssertNotEquals(NULL, TMKAApp1.Id);
            
            TMKAApp1 = [SELECT IsDuplicated1__c 
                        FROM Appoitment__c 
                        WHERE Id = : TMKAApp1.Id];
            
            System.AssertEquals(FALSE, TMKAApp1.isDuplicated1__c);
        }

        /*
         * TMK A create an invitation for a opportunity, within 7days ,TMK B can't create appointment for this opportunity
         * - Click"New invitation" on opportunity page
         * TMK B can't create new invitation within 7days of TMK A's invitation create date.
         * Error msg: Label.Tmk7DayInvitationErrorMessage
         */
        System.runAs(userTMKB) {
            
            Appoitment__c TMK2App = new Appoitment__c();
            try {
                TMK2App = TestObjectFactory.createAppointment(opp, userTMKB, 'Invitation', 1);
                
                System.AssertEquals(NULL, TMK2App.Id);
            
            } catch (Exception e) {
                Boolean expectedExceptionThrown = 
                    e.getMessage().contains(System.Label.Tmk7DayInvitationErrorMessage) ? TRUE : FALSE;
                
                System.AssertEquals(TRUE, expectedExceptionThrown);
                System.AssertEquals(NULL, TMK2App.Id);
            }
        }

        /*
         * TMK A create an invitation for a opportunity, and if he creates a new apppiontment for the same opportunity,
         * then  the previous appointment will be auto updated to invalid
         * - Click"New invitation" on opportunity page
         * if the previous invitation is in follow up (:跟进中or 未到访），update:
         * 1, status: Constants.APP_NEXT_TIME_VISIT
         * 2，customer service appoinment status：Constants.APP_EXPIRED
         */
        System.runAs(userTMKA) {
            
            TMKAApp1 = [SELECT TMKAppStatus__c, Status__c 
                        FROM Appoitment__c 
                        WHERE Id = : TMKAApp1.Id];
            
            // Checks the status before the second appointment inserted
            System.AssertNotEquals(Constants.APP_NEXT_TIME_VISIT, TMKAApp1.Status__c);
            System.AssertNotEquals(Constants.APP_EXPIRED, TMKAApp1.TMKAppStatus__c);

            // Inserts a second appointment
            Appoitment__c TMKAApp2 = TestObjectFactory.createAppointment(opp, userTMKA, 'Invitation', 1);  

            System.AssertNotEquals(NULL, TMKAApp2.Id);

            TMKAApp2 = [SELECT IsDuplicated1__c 
                        FROM Appoitment__c 
                        WHERE Id = :TMKAApp2.Id];

            TMKAApp1 = [SELECT TMKAppStatus__c, Status__c 
                        FROM Appoitment__c 
                        WHERE Id = :TMKAApp1.Id];

            // Checks the duplication and TMK apointment status
            System.AssertEquals(TRUE, TMKAApp2.IsDuplicated1__c);
            System.AssertEquals(Constants.APP_NEXT_TIME_VISIT, TMKAApp1.Status__c);
            System.AssertEquals(Constants.APP_EXPIRED, TMKAApp1.TMKAppStatus__c);
        }
        Test.stopTest();
    }

    // If the first appointment is created date greater than 7 days with today
    @isTest static void testTmkAppointment7DaysRule2() {

        User admin = TestObjectFactory.createUser();
        User userTMKA = new User();
        User userTMKB = new User();

        System.runAs(admin) {
            // Initializes the users
            userTMKA = TestObjectFactory.createTmkUser('userTMKA');
            insert userTMKA;
            userTMKB = TestObjectFactory.createTmkManager('userTMKB');
            insert userTMKB;
        }

        Test.startTest();
        // Initializes the data
        Account acc = TestObjectFactory.createAccount();
        insert acc;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.Id, userTMKA);
        insert opp;

        Appoitment__c TMKAApp1 = new Appoitment__c();
        Appoitment__c TMKBApp1 = new Appoitment__c();

        /*
         * TMK A create an invitation for a opportunity, after 7days ,TMK B can create appointment for this opportunity
         * - Click"New invitation" on opportunity page
         * If TMK A's invitation is in follow up (Following up or unvisited），update:
         * 1, status: Constants.APP_NEXT_TIME_VISIT
         * 2，customer service appoinment status：Constants.APP_EXPIRED
         */
        System.runAs(userTMKA) {
            
            TMKAApp1 = TestObjectFactory.createAppointment(opp, userTMKA, 'Invitation', 9);
        }

        System.runAs(userTMKB) {
            
            TMKBApp1 = TestObjectFactory.createAppointment(opp, userTMKB, 'Invitation', 1);
        }

        TMKAApp1 = [SELECT TMKAppStatus__c, Status__c
                    FROM Appoitment__c
                    WHERE Id = : TMKAApp1.Id];

        // After created an new appointment, the old one has been expired
        System.AssertEquals(Constants.APP_NEXT_TIME_VISIT, TMKAApp1.Status__c);
        System.AssertEquals(Constants.APP_EXPIRED, TMKAApp1.TMKAppStatus__c);
        Test.stopTest();
    }
}