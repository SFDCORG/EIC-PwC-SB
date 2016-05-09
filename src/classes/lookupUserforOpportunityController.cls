/**************************************************************************************************
 * Name: lookupUserforOpportunityController
 * Object: /
 * Purpose: The Lookup component on the Opportunity batch Assign page
 * Author: /
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/

public  class lookupUserforOpportunityController {
    
    public String searchText {get ; set;}
    public List<User> userlist {get ; set;}
    private String city = '';
    private String business = '';
    private String soql = '';
    private String dep ='';
    private String userChineseCity = '';
    private List<String> expandCity = new List<String>();

    public lookupUserforOpportunityController() {
        searchText = '';
        userlist = new List<User> ();
        User u = [SELECT City_of_Role__c,
                         Business_Unit__c,
                         Department_of_Role__c,
                         ChineseNameofCity__c,
                         RoleCityText__c 
                  FROM User 
                  WHERE Id = :UserInfo.getUserId() 
                  AND isActive = true];

        city = u.City_of_Role__c;
        business = u.Business_Unit__c;
        dep = u.Department_of_Role__c;
        userChineseCity = u.ChineseNameofCity__c;
        searchUser();
    }
    
    // Search User according to Current login users' citry and business lines
    public PageReference searchUser() {
        Boolean isSubAgent = UserInfo.getProfileId() == ProfileRelated.marketSubAgent;
        if (String.isNotBlank(searchText)){
            userlist.clear();
            if (searchText.contains('*')) {
               searchText = '%' +searchText.replace('*', '') + '%';
            }
            soql = 'SELECT userRole.Name, Name,ID FROM User WHERE ';
            soql += ' Name LIKE :searchText and isActive=true ';
            soql += 'And City_of_Role__c = :city ';
            soql += 'And Business_Unit__c=:business ';
            if (business == 'Marketing' && !isSubAgent) {
                soql += 'And Department_of_Role__c=\'CS\'';
            }
            soql = replaceCityRangeforCS(soql);
            try {
                userlist.addAll((List<User>)Database.query(soql));
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        } else {
            getUserList();
        }
        return null;
    }
   
    // Get user List is search without any search key wordsd
    private void getUserList() {
        userlist.clear();
        soql = 'SELECT userRole.Name, Name '+
               'FROM User '+
               'WHERE Business_Unit__c=:business '+
               'AND isActive=true '+
               'And City_of_Role__c = :city ';
        if (business == 'Marketing') {
            soql += '  AND Department_of_Role__c = \'CS\'';
        }
        soql = replaceCityRangeforCS(soql);
        userlist.addAll((List<User>)Database.query(soql));
    }
    
    //expand city choosing range for Customer Servicer 
    private String replaceCityRangeforCS(String soql) {
        if (ProfileRelated.getLocalCSSet().contains(userinfo.getProfileId())) {
           
            List<CS_Assign_City_Territory__c> cs=[SELECT Expand_User_City__c,Current_User_City__c 
                                                  FROM CS_Assign_City_Territory__c 
                                                  WHERE Current_User_City__c = :userChineseCity];
            if (cs.size() == 1) {   
                expandCity = String.valueof(cs[0].Expand_User_City__c).split(';');
                String cityRange = 'AND ChineseNameofCity__c IN :expandCity ';
                soql = soql.replace('And City_of_Role__c = :city', cityRange);
            }
        }
        return  soql;
    }
}