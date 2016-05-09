/**************************************************************************************************
 * Name: ContactInfoRelatedController
 * Object: Account
 * Purpose: Show Contacts for specify Account.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
public class ContactInfoRelatedController {

    public Id currentReocrdID { get; set; } // Current Account Id
    public List<ContactInfoWrapper> ContactInfoWList { get; set; } // Wrapper contact variable
    public boolean isbuttonDisplay { get; set; } // The display complete phone number button flag
    public String primarycontact { get; set; } // Primary contact
    public Map<ID, String> encrypedNumMap; // Encrypted number with completed number map
    public List<Contact_EIC__c> ContactInfo; // Contact info lists
    private Integer rownum;
    private Contact_EIC__c oldcontact;

    public ContactInfoRelatedController (ApexPages.StandardController controller) {

        ContactInfo = new List<Contact_EIC__c> ();
        encrypedNumMap = new Map<ID, String> ();
        currentReocrdID = ApexPages.CurrentPage().getparameters().get('id');
        ContactInfoWList = new List<ContactInfoWrapper> ();
        primarycontact = '';
        rownum = 0;
        isbuttonDisplay = false;
        oldcontact = new Contact_EIC__c ();
       
        if (AccountRelated.checkContactAccessibilityofCurrentUserRole(currentReocrdID)) {

            ContactInfo = getContacts(); 
            initializationContactInfoWList();
            isbuttonDisplay = rownum > 0 &&
                              ProfileRelated.addViewContactsProfileSet().contains(UserInfo.getProfileId()) ? 
                                                                                  true :
                                                                                  false;
        }
    }

    // Gets Contacts info by account Ids
    public List<Contact_EIC__c> getContacts () {

        return [SELECT Id,
                       Name, 
                       isPrimary__c, 
                       Relationship__c,
                       isInvalid__c,
                       UniqueContact__c,
                       Encryped_Phone__c,
                       Contact_Type__c,
                       ContactNumber__c,
                       Account__c
                FROM Contact_EIC__c 
                WHERE Account__c = :currentReocrdID
                AND isInvalid__c = false
                ORDER BY CreatedDate];
    }

    // Initializes the contact List
    public void initializationContactInfoWList () {

        for (Contact_EIC__c contat : ContactInfo) {

           ContactInfoWrapper conw = new ContactInfoWrapper ();
           conw.contat = contat;
           conw.displayPhoneNumber = contat.Encryped_Phone__c;
           conw.index = rownum;
           conw.primaryButtonflag = (contat.isPrimary__c == true || 
                                     !EICContactRelatedController.checkPrimaryAvailable(contat)) ?
                                      false :
                                      true;

           encrypedNumMap.put(contat.Id, contat.ContactNumber__c);
           ContactInfoWList.add(conw);
           rownum++;

           if (contat.isPrimary__c == true) {
               oldcontact = contat;
           }
        }
    }
    
    // The show contacts complete number button action
    public PageReference showContactNumber () {

        getCompletedContactNumber();
        trackContactNumberViewrHistory();
        return null;
    }

    // Get complete contact number
    private void getCompletedContactNumber () {

        for (ContactInfoWrapper conw : ContactInfoWList) {

            conw.displayPhoneNumber = encrypedNumMap.get(conw.contat.id);
        }
    }
  
    public class ContactInfoWrapper {

        public Contact_EIC__c contat { get; set; }
        public String displayPhoneNumber { get; set; }
        public Integer index { get; set; }
        public Boolean primaryButtonflag { get; set; }
    }

    // Generates the contact number view History
    private void trackContactNumberViewrHistory () {

        HistoryTrackObjectRelatedController.createHisotryRecords(System.Now(), UserInfo.getUserId(), currentReocrdID);
    }

    // Set primary Contact Number
    public PageReference setPrimary () {

        List<Contact_EIC__c> conts = new List<Contact_EIC__c> ();
        Contact_EIC__c newContact = new Contact_EIC__c ();
        for (ContactInfoWrapper conw : ContactInfoWList) {

            conw.contat.isPrimary__c = !(conw.index != Integer.valueOf(primarycontact));
            conw.primaryButtonflag = (conw.index != Integer.valueOf(primarycontact)) &&
                                      EICContactRelatedController.checkPrimaryAvailable(conw.contat);

            if (conw.contat.Id == oldcontact.Id || conw.contat.isPrimary__c) {

                conts.add(conw.contat);
            }

            if (conw.contat.isPrimary__c) {
              newContact = conw.contat;
            }
        }

        try {

            update conts;
            ChangeLogRelated.CreateContactChangeLog('更改主要联系方式' , newContact, oldcontact);
        } catch(Exception e) {

            ApexPages.addMessages(e);
        }

        return null;
    }
}