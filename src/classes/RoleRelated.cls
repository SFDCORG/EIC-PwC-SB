/**************************************************************************************************
 * Name: RoleRelatedTest
 * Object: Role, Profile
 * Purpose: Set the constant profile Id
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History: 
 * 2016-05-10    Vicia Wang    Writes comments in this format and format the class
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public class RoleRelated {

    // Gets counselling SH Branch customer service in-charge 留学上海分公司客服部主管
    public static Set<Id> LocalCSManagerRole () {
        Set<Id> profileIdSet = new Set<Id>();
        profileIdSet.add('00E28000000NH71EAG');

        return profileIdSet;
    }

    // Gets group call center customer service in-charge #集团呼叫中心TMK主管
    public static Set<Id> HDTMKManagerRole () {
        Set<Id> profileIdSet = new Set<Id>();
        profileIdSet.add('00E28000000NH7IEAW');

        return profileIdSet;
    }

    // Gets all Xueyou role Ids
    public static Set<Id> XueYouRole() {
        Set<Id> roleIdSet = new Set<Id>();

        for (UserRole uRole : [SELECT Id FROM UserRole WHERE Name LIKE '%学游%']) {
            roleIdSet.add(uRole.id);
        }

        return roleIdSet;
    }
}