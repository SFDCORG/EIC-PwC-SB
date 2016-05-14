/**************************************************************************************************
 * Name: OpportunityOwnerChangeControllerTest
 * Object: Account
 * Purpose: Test the opportunity Mass transfer function, 
            login user can transfer the opportunity to other user which him can select,
            the transfer job is batch job, it not a timely job
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-11-12
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
@isTest
private class OpportunityOwnerChangeControllerTest {

    static testMethod void opportunityOwnerChangeController () {
        User usr = [SELECT Id
                    FROM User
                    WHERE Id = :UserInfo.getUserId()];

        // Prepares the test Data
        System.runAs(usr) {

            User uuser = TestObjectFactory.createSalesUser();
            uuser.Username = 'opp1@test.com.eic.pwc';
            uuser.User_External_Id__c = '201604211738';
            insert uuser;

            User uuser2 = TestObjectFactory.createSalesUser();
            uuser2.Username = 'opp2@test.com.eic.pwc';
            uuser2.User_External_Id__c = '201604211739';
            insert uuser2;

            User uuser3 = TestObjectFactory.createSalesUser();
            uuser3.ProfileId = Constants.PROFILE_MARKET_SUBAGENT_ID;
            uuser3.Username = 'opp3@test.com.eic.pwc';
            uuser3.User_External_Id__c = '201604211740';
            insert uuser3;
        }

        User runUser = [SELECT Id
                        FROM User
                        WHERE username = 'opp1@test.com.eic.pwc'];

        User accpeter = [SELECT Id
                         FROM User
                         WHERE username = 'opp2@test.com.eic.pwc'];

        User subagentUser = [SELECT Id
                             FROM User
                             WHERE username = 'opp3@test.com.eic.pwc'];

        Account acc = TestObjectFactory.createAccount();
        acc.Name = 'account eic';
        acc.OwnerId = runUser.Id;
        insert acc;

        Opportunity opp = TestObjectFactory.createOpportunity(acc.Id, runUser);
        opp.Transfer_Status__c = '';
        opp.RecordTypeId = Constants.OPP_RT_COUNSELLING_ID;
        insert opp;

        Opportunity opp2 = TestObjectFactory.createOpportunity(acc.Id, runUser);
        opp2.Transfer_Status__c = '转移中';
        insert opp2;

        Opportunity opp3 = TestObjectFactory.createOpportunity(acc.Id, subagentUser);
        opp3.Transfer_Status__c = '';
        opp3.RecordTypeId = Constants.OPP_RT_COUNSELLING_ID;
        insert opp3;

        OpportunityTeamMember oppMember = TestObjectFactory.createOppTeam(opp, usr.Id);
        insert oppMember;
        
        Test.startTest();
        List<Opportunity> opps = new List<Opportunity>();

        System.runAs(runUser) {

            opps.add(opp);
            PageReference myVfPage = Page.OpportunityOwnerChange;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardSetController con = new ApexPages.StandardSetController(opps);
            con.setSelected(opps);
            OpportunityOwnerChangeController oppOwnerChange = new OpportunityOwnerChangeController(con);
            
            // Doesn't choose an acceptor, assign the opps directly, an Error message will shown on the page
            // No acceptor had been selected, can't go ahead
            oppOwnerChange.newOwnerID = '';
            oppOwnerChange.AssignOpp();
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.NO_SELECTED_ACCEPTOR));

            // Chooses an exiting user, and assign the Opportunity to him, it shall be successfully.Opportunity
            oppOwnerChange.newOwnerID = accpeter.Id;
            oppOwnerChange.AssignOpp();
            Opportunity result = [SELECT OwnerId, Transfer_Status__c
                                  FROM Opportunity
                                  WHERE Id = :opp.Id Limit 1];

            System.assertEquals(Constants.OPPORTUNITY_TRANSFER_STATUS_ING, result.Transfer_Status__c);

            // Doesn't selected any opps in the list view page, an Error message will be shown on the page
            // No Opportunity had been selected, can't go ahead
            opps.clear();
            ApexPages.StandardSetController con2 = new ApexPages.StandardSetController(opps);
            con2.setSelected(opps);
            OpportunityOwnerChangeController oppOwnerChange2 = new OpportunityOwnerChangeController(con2);
            con2.setSelected(opps);
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.NO_SELECTED_OPPS));

            // If the selected Opportunities contain some opportunity which already in the transfer process
            // An error message will be shown, contain some transferring opps, can't go ahead
            opps.add(opp2);
            ApexPages.StandardSetController con3 = new ApexPages.StandardSetController(opps);
            con3.setSelected(opps);
            OpportunityOwnerChangeController oppOwnerChange3 = new OpportunityOwnerChangeController(con3);
            con3.setSelected(opps);
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.CONTAIN_TRANSFERING_OPPS));
            oppOwnerChange3.cancel();
        }

        // If current login user is market SubAgent profile user, 
        // and selected the opportunities contain not SubAgent record type opportunity,
        // an error shall be shown on the page: Can't change no access Opps
        System.runAs(subagentUser) {

            opps.add(opp3);
            PageReference myVfPage = Page.OpportunityOwnerChange;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardSetController con = new ApexPages.StandardSetController(opps);
            con.setSelected(opps);
            OpportunityOwnerChangeController oppOwnerChange = new OpportunityOwnerChangeController(con);
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.CHANGE_WITH_NO_ACCESS_OPPS));
        }

        Test.stopTest();
    }
}