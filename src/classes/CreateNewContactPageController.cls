/**************************************************************************************************
 * Name: CreateNewContactPageController
 * Object: Lead
 * Purpose: Creates a new contact for an Account
 * Author: Ray Cen
 * Create Date: 2015-11-26
 * Modified History: 
 * 2015-11-26    Ray Cen    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
public class CreateNewContactPageController {

    public String accountName { get; set; }
    public ContactArea cntat { get; set; }
    public String acountID { get; set; }
    public Account duplicatedAccount { get; set; }
    public Boolean isdisplayduliatedAccountLink { get; set; }
    public Boolean  requiredFlag { get; set; }
    private static final Set<String> uniquleType = new Set<String> ();

    static {
        uniquleType.add('手机');
        uniquleType.add('座机');
    }

    private List<Account> duplicatedAccounts;

    public CreateNewContactPageController() {

        acountID = ApexPages.CurrentPage().getparameters().get('AccountID');

        duplicatedAccounts = new List<Account> ();
        duplicatedAccount = new Account ();
        isdisplayduliatedAccountLink = false;
        cntat = new ContactArea ();
        cntat.contact= new Contact_EIC__c ();
        cntat.contact.Contact_Type__c = '手机';
        cntat.homephoneArea = '';
        requiredFlag = false;

        try {

          accountName = [SELECT ID, Name FROM Account WHERE Id = :acountID LIMIT 1].Name;
        } catch(Exception e) {

          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '加载失败，请重新添加'));
        }
    }

    public PageReference SaveContact () {

        isdisplayduliatedAccountLink = false;
        if (checkRquriedFieldEmpty()) {

            cntat.uniquecontact = 
                EICContactRelatedController.reorgnizeContactContent(cntat.contact.Contact_Type__c,
                                                                    cntat.uniquecontact,
                                                                    cntat.homephoneArea);
            
            List<Account> da = EICContactRelatedController.checkdupliatedContacts(cntat.uniquecontact);
            if (da.size() < 1) {

                return createNewContact() ? new PageReference('/' + acountID) : null;
            } else {

              duplicatedAccount = da[0];
              isdisplayduliatedAccountLink = true;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '信息不全，请请检查'));
        }

        return null;
    }

    private Boolean checkRquriedFieldEmpty () {

        return !(cntat.contact.Contact_Type__c == null ||
                 cntat.uniquecontact == null||
                 cntat.uniquecontact == '' ||
                 cntat.contact.Relationship__c == null ||
                 cntat.contact.Name == null ||
                 cntat.contact.Name == '' ||
                 (cntat.contact.Contact_Type__c == '座机' &&
                  cntat.homephoneArea == ''));
    }

    public pagereference contactNameGenerate () {

      if (cntat.contact.Relationship__c == '客户本人') {
          cntat.contact.Name = accountName;
      }

      return null;
    }

    private Boolean createNewContact () {

       Contact_EIC__c contat = new Contact_EIC__c ();
       contat.Account__c = acountID;
       contat.Name = cntat.contact.Name;
       contat.Relationship__c = cntat.contact.Relationship__c;

       if (uniquleType.contains(cntat.contact.Contact_Type__c)) {

          contat.UniqueContact__c = cntat.uniquecontact;
       } else {

          contat.Normal_Contact__c = cntat.uniquecontact;
       }

       contat.Contact_Type__c = cntat.contact.Contact_Type__c;

       contat.isPrimary__c = (EICContactRelatedController.checkPrimaryAvailable(contat)) &&
                              cntat.contact.isPrimary__c == true ? true : false;

       try {
            Insert contat;
            Contact_EIC__c newContact = [SELECT Contact_Type__c, Encryped_Phone__c, Account__c, isPrimary__c 
                                         FROM Contact_EIC__c
                                         WHERE Id = :contat.Id 
                                         LIMIT 1];

            ChangeLogRelated.CreateContactChangeLog('新增联系方式', newContact, newContact);

            if (contat.isPrimary__c == true)
                EICContactRelatedController.uncheckPrimary(contat.Account__c, contat.Id);
            return true;
        } catch(Exception e) {

            ApexPages.addMessages(e);
        }

        return false;
    }

    public pagereference cancel () {
        if (acountID == null) return new PageReference ('/home/home.jsp');
        else return new PageReference ('/'+acountID);
    }

    public class ContactArea {
        public String homePhoneArea { get; set; }
        public String uniquecontact { get; set; }
        public Contact_EIC__c contact { get; set; }
    }
}