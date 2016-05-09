/**************************************************************************************************
 * Name: AccountQuickSearch
 * Object: Account
 * Purpose: Search Account by contact name or contact number. When users' precise Search check box 
 *          has been checked, the precise Search logic will be done.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen         Format the code
 **************************************************************************************************/
public without sharing class AccountQuickSearch {

    public List<WrapperAccounts> preciseSearch { get; set; } // Save the precise Search result
    public List<WrapperAccounts> fuzzySearch { get; set; } // Save the fuzzy Search result
    public Boolean errorMessageflag { get; set; } // The error message is shown or not
    public String searchType { get; set; } // Search by contact name or contact phone
    public String searchContent { get; set; } // The search key words inputed by users
    public Boolean PreciseSearchFlag { get; set; } // precise permission is opened for current user or not
    private Set<ID> availableAccountIDSet; // The Accounts' ID which is matched the search condition and also can be accessed by current user
    private Set<ID> accIDSet = new Set<ID> (); // The Account ID SET
    private Set<ID> conIDSet = new Set<ID> (); // The Contact ID SET

    public AccountQuickSearch() {

        PreciseSearchFlag = [SELECT PreciseSearch__c
                             FROM User
                             WHERE Id = :UserInfo.getUserId()
                             LIMIT 1].PreciseSearch__c;
        initialization();
        errorMessageflag = false;
        searchContent = '';
        availableAccountIDSet = new Set<ID> ();
    }

    // Initializes search results
    private void initialization () {

        preciseSearch = new List<WrapperAccounts> ();
        fuzzySearch = new List<WrapperAccounts> ();
        conIDSet = new Set<ID> ();
        accIDSet = new Set<ID> ();
        availableAccountIDSet = new Set<ID> ();
    }

    // Gets those accounts which current user is in related opportunity's opportunity team
    private void getAvailableAccount(Set<ID> accIDSet) {

        for (OpportunityTeamMember opp : [SELECT Opportunity.AccountId
                                          FROM OpportunityTeamMember
                                          WHERE UserId = :UserInfo.getUserId()
                                          AND Opportunity.AccountId IN :accIDSet]) {
            availableAccountIDSet.add(opp.Opportunity.AccountId);
        }
    }

    // Queries button action
    public void queryStudents() {

        errorMessageflag = true;
        initialization();
        fuzzySearch.clear();
        if (!checkQueryBoxEmpty()) {

            fuzzySearch = fuzzySearch();

            if (PreciseSearchFlag) {
                preciseSearch = preciseSearch();
            }

            if (fuzzySearch.size() == 0 &&
                searchType != 'AccountContact' &&
                preciseSearch.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.NO_RESULT));
            }
        }
    }

    // Dose precise search and return results
    private List<WrapperAccounts> preciseSearch() {

        List<Account> accounts = accountsQuery('precise');
        List<WrapperAccounts> blwaccount = new List<WrapperAccounts> ();
        blwaccount.addall(buildWrapperAccount(getContactListandMap(accounts), accounts));

        return blwaccount;
    }
    
    // Dose fuzzy search and return results
    private List<WrapperAccounts> fuzzySearch () {

        List<Account> accounts = accountsQuery('fuzzy'); // Gets related AccountList which is searched by user
        List<WrapperAccounts> blwaccount = new List<WrapperAccounts> ();
        blwaccount.addall(buildWrapperAccount(getContactListandMap(accounts), accounts));

        return blwaccount;
    }

    // Checks that user has inputed search key words or not
    private Boolean checkQueryBoxEmpty () {
        return String.isBlank(searchContent);
    }

    // Combines accounts and contacts for Visualforce page display
    private List<WrapperAccounts> buildWrapperAccount (Map<ID, List<Contact_EIC__c>> contactsofAccount,
                                                       List<Account> accs) {

        List<WrapperAccounts> waccount = new List<WrapperAccounts> ();
        for (Account acount : accs) {
            WrapperAccounts wacc = new WrapperAccounts ();
            wacc.contacts = contactsofAccount.get(acount.Id);
            wacc.acount = acount;
            waccount.add(wacc);
        }

        return waccount;
    }

    // Does query action, queryType shall be precise or fuzzy.
    private List<Account> accountsQuery (String queryType) {
        List<Account> accList = new List<account> ();
        Set<ID> accIDSet = new Set<ID> ();
        String searchprepare = searchContent + '*';

        if (queryType == 'fuzzy') {

            if (searchContent.length() > 1) {

                if (searchType == 'AccountContact') {

                    List<List <sObject>> searchList = [FIND :searchprepare
                                                       IN ALL FIELDS
                                                       RETURNING Contact_EIC__c(ContactNumber__c,Account__c)];
                        
                    for (Contact_EIC__c conts : ((List<Contact_EIC__c>) searchList[0])) {
                        String conNumber = String.valueOf(conts.ContactNumber__c);
                        if (conNumber.startsWith(searchContent)) {
                            conIDSet.add(conts.Id);
                            accIDSet.add(conts.Account__c);
                        }
                    }

                    getAvailableAccount(accIDSet);
                    return [SELECT Name, OwnerId,Nickname__c,
                                   (SELECT Id,
                                           Name,
                                           RecordTypeId,
                                           OwnerId,
                                           Project__c,
                                           Intended_City__c,
                                           Intended_Office__c,
                                           StageName
                                    FROM Opportunities
                                    ORDER BY CreatedDate)
                            FROM Account
                            WHERE Id IN (SELECT Account__c
                                         FROM Contact_EIC__c
                                         WHERE Id IN :conIDSet)
                            AND Id IN :availableAccountIDSet
                            LIMIT 200];
                } else {
                    List<List <sObject>> searchList = [FIND :searchprepare
                                                       IN ALL FIELDS
                                                       RETURNING Account(Name)];
                    for (Account acc : ((List<Account>) searchList[0])) {
                        String accName = String.valueOf(acc.Name);
                        if (accName.startsWith(searchContent)) {
                            accIDSet.add(acc.Id);
                        }
                    }
                    getAvailableAccount(accIDSet);
                    return [SELECT Name,
                                   OwnerId,Nickname__c,
                                   (SELECT Name,
                                           RecordTypeId,
                                           OwnerId,Project__c,
                                           Intended_City__c,
                                           Intended_Office__c,
                                           StageName
                                    FROM Opportunities
                                    ORDER BY CreatedDate)
                            FROM Account
                            WHERE Id IN :accIDSet
                            AND Id IN :availableAccountIDSet LIMIT 200];
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                     Constants.SEARCH_CONTENT_LENGTH_INCORRECT));
            }

        } else {
            if (searchType == 'AccountContact') {

                return [SELECT Name, OwnerId,Nickname__c,
                               (SELECT Id,
                                       Name,
                                       RecordTypeId,
                                       OwnerId,Project__c,
                                       Intended_City__c,
                                       Intended_Office__c,StageName
                                FROM Opportunities
                                ORDER BY CreatedDate)
                        FROM Account
                        WHERE Id IN (SELECT Account__c
                                     FROM Contact_EIC__c
                                     WHERE ContactNumber__c = :searchContent
                                     OR Unique_Contact__c = :searchContent)];
            } else {
                return [SELECT Id, Name, OwnerId,Nickname__c,
                               (SELECT Id,
                                       Name,
                                       RecordTypeId,
                                       OwnerId,Project__c,
                                       Intended_City__c,
                                       Intended_Office__c,
                                       StageName
                                FROM Opportunities
                                ORDER BY CreatedDate)
                        FROM Account
                        WHERE Name = :searchContent
                        LIMIT 500];
            }
        }

        return new List<Account> ();
    }
    
    // Puts accounts and contacts in a map
    private Map<ID, List<Contact_EIC__c>> getContactListandMap (List<Account> accs) {
        Map<ID, List<Contact_EIC__c>> contactsofAccount = new Map<ID, List<Contact_EIC__c>> ();

        List<Contact_EIC__c> contacts = [SELECT Id,
                                                isPrimary__c,
                                                Name,
                                                Account__c,
                                                Encryped_Phone__c,
                                                Contact_Type__c
                                         FROM Contact_EIC__c
                                         WHERE Account__c IN :accs
                                         ORDER BY CreatedDate];

        for (Contact_EIC__c contat : contacts) {
            List<Contact_EIC__c> cls = new List<Contact_EIC__c> ();

            if (contactsofAccount.containsKey(contat.Account__c)) {
                cls = contactsofAccount.get(contat.Account__c);
                cls.add(contat);
            } else {
                cls.add(contat);
            }

            contactsofAccount.put(contat.Account__c, cls);
        }

        return contactsofAccount;
    }

    public pagereference cancel() {
        return new PageReference('/001/o');
    }
     
    class WrapperAccounts {
        public Account acount { get; set; }
        public List<Contact_EIC__c> contacts { get; set; }
    }
}