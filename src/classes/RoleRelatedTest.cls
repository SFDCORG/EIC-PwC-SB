/**************************************************************************************************
 * Name: RoleRelatedTest
 * Object: Role, Profile
 * Purpose: Test class for RoleRelated
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History: 
 * 2016-05-10    Vicia Wang    Create this class
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class RoleRelatedTest {

    static testMethod void testRoleRelated() {

        Set<Id> SHCustomerServiceMgrProfileIdSet = RoleRelated.LocalCSManagerRole();
        Set<Id> groupCustomerServiceMgrProfileIdSet = RoleRelated.HDTMKManagerRole();
        Set<Id> studyAbroadRoleIdSet = RoleRelated.XueYouRole();

        Boolean isXueyou = TRUE;
        for (UserRole role : [SELECT Name FROM UserRole WHERE Id IN : studyAbroadRoleIdSet]) {
            if (!role.Name.contains('学游')) {
                isXueyou = FALSE;
                break;
            }
        }

        Test.startTest();
        System.assert(SHCustomerServiceMgrProfileIdSet.contains('00E28000000NH71EAG'));
        System.assert(groupCustomerServiceMgrProfileIdSet.contains('00E28000000NH7IEAW'));
        System.assert(isXueyou);
        Test.stopTest();
    }
}