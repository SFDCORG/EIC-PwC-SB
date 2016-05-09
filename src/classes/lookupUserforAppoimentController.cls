/**************************************************************************************************
 * Name: lookupUserforAppoimentController
 * Object: /
 * Purpose: The Lookup component on the appointment batch Assign page
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/
public class lookupUserforAppoimentController {
    
    public String searchText {get; set;} // Search Key Word
    public List<User> userlist {get; set;} // Define the return User List
    private String city =  ''; // Current User City Info
    private String business =  ''; // Current User Business Line
    private String dep = ''; // Current User deparetment
    private Boolean isWg = false; // Current User is a all contry CC or not
    private Set<Id> managerProfileID=ProfileRelated.getCCManagerSet(); // Get CC Manaager Profile Set
    
    // Initilzes the class, and gets the current login user's basic info
    public lookupUserforAppoimentController() {
        searchText = '';
        userlist =  new List<User> ();
        User u = [SELECT Approval_Department__c,
                         Business_Unit__c,
                         City_of_Role__c,
                         Department_of_Role__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];

        city = u.City_of_Role__c;
        business = u.Business_Unit__c;
        dep = u.Department_of_Role__c;
        city = city.replace('BJHD', '%BJ%');
        isWg = u.Approval_Department__c.contains('WG');
        searchUser();
    }

    // Search User
    public PageReference searchUser() {
        if (String.isNotBlank(searchText)){
            userlist.clear();
            if (searchText.contains('*')) {
                searchText = '%' + searchText.replace('*', '') + '%';
            }
            
            // Admin can search all the manager profiles user
            if (ProfileRelated.adminProfileSet().contains(UserInfo.getProfileId())) {
               
                userlist.addAll( [SELECT userRole.Name, Name ,Department_of_Role__c 
                                  FROM User
                                  WHERE Name LIKE :searchText 
                                  And ProfileID IN :managerProfileID ]);
            } else {
                for(User us1 : [SELECT userRole.Name, 
                                       Name,
                                       Department_of_Role__c,
                                       Approval_Department__c
                                FROM User WHERE Name LIKE :searchText
                                And City_of_Role__c LIKE :city
                                And Business_Unit__c = :business 
                                And isActive = true
                                And ProfileID in :managerProfileID]) {

                    if (us1.Department_of_Role__c.contains(dep) ||
                        dep.contains(us1.Department_of_Role__c) ||
                        us1.Approval_Department__c.contains('WG') || //If WG user can also search other department managers
                        isWg) {
                        userlist.add(us1);
                    }
                }
            }
        } else getUserList();

        return null;
    }
    
    // Gets User List When there no search key words
    private void getUserList() {
        userlist.clear();
        for(User us1 : [SELECT userRole.Name, Name, Id ,Department_of_Role__c
                       FROM User
                       WHERE City_of_Role__c LIKE :city
                       And Business_Unit__c = :business 
                       And isActive = true
                       And ProfileID IN :managerProfileID]) {
            if (us1.Department_of_Role__c.contains(dep) ||
                dep.contains(us1.Department_of_Role__c)) {
                userlist.add(us1);
            }
        }
    }
}