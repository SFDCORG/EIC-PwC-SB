/**************************************************************************************************
 * Name: miniPhoneoppTest
 * Object: Contact
 * Purpose: Test Contact Info on the opportuntiy page Function
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-5-4
 * Modify History:
 **************************************************************************************************/

@isTest
private class miniPhoneoppTest {
    static testmethod void testminiPhoneView() {
        
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
        insert cont;
        ContactDisplay__c display = new ContactDisplay__c();
        display.name = 'test';
        insert display;

        Test.startTest();

        System.runAs(runUser) {
          
            PageReference myVfPage = Page.MiniPhone_opp;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('id',opp.Id);
            ApexPages.StandardController con = new ApexPages.StandardController(opp);
            miniPhone_opp_cls mini = new miniPhone_opp_cls(con);
            mini.showContactNumber();
        }

        Test.stopTest();
    }
}