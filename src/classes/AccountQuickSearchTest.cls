/**************************************************************************************************
 * Name: AccountQuickSearchTest
 * Object: /
 * Purpose: Test AccountQuickSearch Function
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen         Format the code
 **************************************************************************************************/
@isTest
private class AccountQuickSearchTest {

    static testMethod void AccountQuickSearch() {

        // Prepares Testing Data
        User usr = [SELECT id
                    FROM User
                    WHERE Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            User uuser = TestObjectFactory.createSalesUser();
            uuser.PreciseSearch__c = true;
            uuser.Username = 'accSearch@test.com';
            insert uuser;
        }

        User runUser = [SELECT Id, PreciseSearch__c, Name
                        FROM User 
                        WHERE Username = 'accSearch@test.com'];

        Account acc = TestObjectFactory.createAccount();
        acc.name = 'Peter Cen';
        insert acc;
        Account acc2 = TestObjectFactory.createAccount();
        acc.name = 'Peter Wang';
        insert acc2;
        Contact_EIC__c con = TestObjectFactory.createContact(acc);
        con.UniqueContact__c = '13671999387';
        insert con;
        Contact_EIC__c con2 = TestObjectFactory.createContact(acc2);
        con2.UniqueContact__c = '13671999301';
        insert con2;
        Contact_EIC__c con3 = TestObjectFactory.createContact(acc2);
        con3.UniqueContact__c = '13891999301';
        insert con3;
        Opportunity opp = TestObjectFactory.createOpportunity(acc.id, runUser);
        insert opp;
        Opportunity opp2 = TestObjectFactory.createOpportunity(acc2.id, runUser);
        insert opp2;
        OpportunityTeamMember oppTM = TestObjectFactory.createOppTeam(opp, runUser.id);
        insert oppTM;
        OpportunityTeamMember oppTM2 = TestObjectFactory.createOppTeam(opp2, runUser.id);
        insert oppTM2;

        // Adds SOSL Queries to Unit Tests,
        List<String> searchResultsIds = new List<String> ();
        searchResultsIds.add(acc.Id);
        searchResultsIds.add(acc2.Id);
        searchResultsIds.add(con.Id);
        searchResultsIds.add(con2.Id);
        searchResultsIds.add(con3.Id);
        Test.setFixedSearchResults(searchResultsIds);

        Test.StartTest();
        System.runAs(runUser) {
            PageReference myVfPage = Page.AccountQuickSearch;
            Test.setCurrentPageReference(myVfPage);
            AccountQuickSearch accSearch = new AccountQuickSearch();

            // Fuzzy Search by Contact number
            accSearch.searchContent = '13671999';
            accSearch.searchType = 'AccountContact';
            accSearch.queryStudents();
            System.assertEquals(false, accSearch.preciseSearch.size() > 0);
            System.assertEquals(true, accSearch.fuzzySearch.size() == 2);

            // Precise Search by Account Name
            accSearch.searchContent = 'Peter Cen';
            accSearch.searchType = 'AccountName'; 
            accSearch.queryStudents();
            System.assertEquals(true, accSearch.preciseSearch.size() == 1);

            // Precise Search by Account Name
            accSearch.searchContent = '13671999387';
            accSearch.searchType = 'AccountContact'; 
            accSearch.queryStudents();
            System.assertEquals(true, accSearch.preciseSearch.size() == 1);

            // Search Content Length Issue Test,a VF Message will be shown
            accSearch.searchContent = '1';
            accSearch.searchType = 'AccountContact';
            accSearch.queryStudents();
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), 
                                                                     Constants.SEARCH_CONTENT_LENGTH_INCORRECT));

            // No result Issue Test, a VF Message will be shown
            accSearch.searchContent = 'Janefer Wang';
            accSearch.searchType = 'AccountName';
            accSearch.queryStudents();
            System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), Constants.NO_RESULT));

            // Cancels Current Page
            accSearch.cancel();
        }

        Test.StopTest();
    }
}