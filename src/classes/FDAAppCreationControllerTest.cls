/**************************************************************************************************
 * Name: FDAAppCreationControllerTest
 * Object: Appoitment
 * Purpose: When FDA Click the customer visited button on the phone search page. An FDA Visited Type Appointment shall be created.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
@isTest
private class FDAAppCreationControllerTest {

    static testMethod void testMethod1() {
        User usr = [SELECT Id 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];
        
        // Prepares the test Data
        System.runAs(usr) {
            User uuser  =  TestObjectFactory.createSalesUser();
            uuser.Username = 'app@test.com.eic.pwc';
            uuser.User_External_Id__c = '201605061738';
            insert uuser;
        }

        User runUser = [SELECT Id, PreciseSearch__c, Name
                         FROM User 
                         WHERE username = 'app@test.com.eic.pwc'];

        Account acc = TestObjectFactory.createAccount();
        acc.Name = 'AccQuickSearch';
        insert acc;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.id, runUser);
        insert opp;
        OpportunityTeamMember oppMember = TestObjectFactory.createOppTeam(opp, runUser.Id);
        insert oppMember;

        test.StartTest();
        System.runAs(runUser) {

            // When the FDAAppCreation page was called, A FDA Visited appointment will be generated
            PageReference myVfPage = Page.FDAAppCreation;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('id', opp.Id);
            FDAAppCreationController FDACon = new FDAAppCreationController ();
            FDACon.initialization();
            List<Appoitment__c> app = [SELECT Id
                                       FROM Appoitment__c
                                       WHERE Appointment_Type__c = :Constants.APP_FDA_TYPE_CN
                                       AND recordTypeID = :Constants.APP_RT_FDA_VISITED_ID];
            System.assertEquals(1, app.size());
        }

        test.stopTest();
    }
}