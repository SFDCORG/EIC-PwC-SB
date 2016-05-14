/**************************************************************************************************
 * Name: MiniContactInfoDisplayController
 * Object: Contact
 * Purpose: Display Contact Info on the appointment page
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
public  class MiniContactInfoDisplayController {

    public Id currentReocrdID { get; set; } // Current page Record Id
    public List<ContactWrapper> contactList { get; set; } // Contact 
    private String accountId; // Account Id
    private Boolean showSwitch; // Show complete contact number or not

    public MiniContactInfoDisplayController (ApexPages.StandardController controller) {

        currentReocrdID = ApexPages.CurrentPage().getparameters().get('id');
        contactList = new List<ContactWrapper>();
        accountId = '';
        showSwitch = false;
        List<Appoitment__c> apps = [SELECT Opportunity__r.AccountId, 
                                           Opportunity__r.IsXueYou__c 
                                    FROM Appoitment__c 
                                    WHERE Id = :currentReocrdID 
                                    AND Opportunity__c != null];
        String rolename = [SELECT Name 
                           FROM UserRole 
                           WHERE Id = :userinfo.getUserRoleId()][0].name;

        Boolean xueyouPermission = apps[0].Opportunity__r.IsXueYou__c && rolename.contains('学游');
 
        accountId = apps.size() > 0 ? apps[0].Opportunity__r.AccountId : '';

        if (checkCurrentUserPermission(generateAccessiableUserGroup()) ||
            xueyouPermission) {
            GenerateDisplayList();
        }
    } 
    
    // Shows the contact number
    public PageReference showContactNumber () {
        if (!showSwitch) {
            getCompletedContactNumber();
            trackContactNumberViewrHistory();
            showSwitch=true;
        }

        return null;
    }
    
    // Generates the contacts number
    private void GenerateDisplayList () {
       List<Contact_EIC__c> contats= [SELECT Encryped_Phone__c,
                                             UniqueContact__c,
                                             Contact_Type__c,
                                             isPrimary__c
                                      FROM Contact_EIC__c 
                                      WHERE Account__c = :accountId
                                      AND  Contact_Type__c IN ('座机', '手机', 'mig_type')];

       ContactDisplay__c encryptionSwitch = [SELECT DisplayPhoneNumber__c 
                                             FROM ContactDisplay__c
                                             LIMIT 1 ];
       for (Contact_EIC__c cont : contats) {

            ContactWrapper conw = new ContactWrapper();
            conw.type = cont.Contact_Type__c;
            showSwitch = encryptionSwitch.DisplayPhoneNumber__c;
            conw.displayNumber = encryptionSwitch.DisplayPhoneNumber__c == true ? cont.UniqueContact__c : cont.Encryped_Phone__c;
            conw.completeNumber = cont.UniqueContact__c;
            conw.isprimary = cont.isPrimary__c == true ? true : false;
            contactList.add(conw);
       }
    }

    // Checks current user can view the appointments number or not
    private Boolean checkCurrentUserPermission (Set<ID> oppGroupIDs) {

        return oppGroupIDs.contains(UserInfo.getUserId());
    }
    
    // Generates the accessible appointments' contact's user or groups
    private Set<ID> generateAccessiableUserGroup () {

        Set<ID> oppGroupIDs = OppOwnerGroupGenerate.getOpportuniyOwnerGroup(accountId);
        Set<ID> adminGroupIDs = OppOwnerGroupGenerate.getAdminGroup();
        oppGroupIDs.addall(adminGroupIDs);
        if (OpportuinityRelatedController.checkEditPermissoin(currentReocrdID)) {
            oppGroupIDs.add(UserInfo.getUserID());
        }
        return oppGroupIDs;
    }

    // Wrappers the contact info for display 
    public class ContactWrapper {

        public String type { get; set; }
        public String displayNumber { get; set; }
        private String completeNumber { get; set; }
        public Boolean isprimary { get; set; }
    }

    // Generates the contact number view history
    private void trackContactNumberViewrHistory() {

        HistoryTrackObjectRelatedController.createHisotryRecords(System.Now(), UserInfo.getUserId(), accountId);
    }

    // Gets Complete contact number
    private void getCompletedContactNumber () {

        for(ContactWrapper conw : contactList) {
            conw.displayNumber = conw.completeNumber;
        }
    }
}