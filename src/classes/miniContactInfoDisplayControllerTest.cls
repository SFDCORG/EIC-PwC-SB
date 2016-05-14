/**************************************************************************************************
 * Name: MiniContactInfoDisplayControllerTest
 * Object: Contact
 * Purpose: Test Contact Info on the appointment page Function
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-5-7
 * Modify History:
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
@isTest
private class MiniContactInfoDisplayControllerTest {

    static testMethod void testminiContactInfoDisplay () {

        //Prepare Testing Data
        User usr = [SELECT id
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            User uuser = TestObjectFactory.createSalesUser();
            uuser.PreciseSearch__c = true;
            uuser.Username = 'miniphon@test.com';
            insert uuser;
        }

        User runUser = [SELECT Id, PreciseSearch__c, Name
                        FROM User 
                        WHERE Username = 'miniphon@test.com'];
        Account acc = TestObjectFactory.createAccount();
        acc.name = 'Peter Cen';
        insert acc;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.id, runUser);
        insert opp;
        OpportunityTeamMember oppTM = TestObjectFactory.createOppTeam(opp, runUser.id);
        insert oppTM;
        Contact_EIC__c cont = TestObjectFactory.createContact(acc);
        cont.UniqueContact__c = '13671999301';
        cont.Contact_Type__c = '手机';
        insert cont;
        ContactDisplay__c display = new ContactDisplay__c();
        display.name = 'test';
        insert display;
        Appoitment__c app = TestObjectFactory.createApp(opp, runUser.Id);
        app.Appointment_Type__c = '第5天任务';
        app.Assign_To__c = runUser.Id;
        app.OwnerId = runUser.Id;
        insert app;

        Test.startTest();

        System.runAs(runUser) {
            PageReference myVfPage = Page.miniContactInfoDisplay_App;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('id', app.Id);
            ApexPages.StandardController con = new ApexPages.StandardController(opp);
            miniContactInfoDisplayController mini = new miniContactInfoDisplayController(con);
            mini.showContactNumber();

            System.assertEquals(1, mini.contactList.size());
        }

        Test.stopTest();
    }
}