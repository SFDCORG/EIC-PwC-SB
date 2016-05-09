/**************************************************************************************************
 * Name: AccountRelated
 * Object: Account
 * Purpose: A universal class for  operations of Account object
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-25
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen      Format the code
 **************************************************************************************************/
global class AccountRelated {

    // Declares the permission who can use the add contact
    webservice static Boolean checkContactAccessibilityofCurrentUserRole (ID accID) {

        Set<ID> oppUserRole = new Set<ID> ();
        Set<ID> oppOwners = new Set<ID> ();
        Id profileID = UserInfo.getProfileId();

        for (Opportunity opp : [SELECT Owner.UserRoleId, Id
                                FROM Opportunity
                                WHERE AccountID = :accID]) {
            oppUserRole.add(opp.Owner.UserRoleId);
            oppOwners.add(opp.OwnerId);
        }

        // Current User Role is higher than one of Account's opportunity owner's Roles or not
        Boolean isRoleHigher = CommonHelperClass.getAllHigherRoles(oppUserRole).contains(UserInfo.getUserRoleId());

        // Current User is one of this account's opportunity owner
        Boolean isOppOwner = oppOwners.contains(UserInfo.getUserId());

        // Current User is system admin
        Boolean isAdmin = ProfileRelated.adminProfileSet().contains(profileID);

        // Current User's profile can add contact on Account, but need meet some conditions
        Boolean addConPermisson = ProfileRelated.addViewContactsProfileSet().contains(profileID);

        // Current User's Profile can add contact on all Account, and don't need to meet any conditions.
        Boolean addAllConPermisson = ProfileRelated.addViewAllContactsProfileSet().contains(profileID);

        return ((isRoleHigher || isOppOwner) && addConPermisson) ||
                 addAllConPermisson ||
                 isAdmin;
    }

    // The universal method for generate Account sharing rule, add all opportunity owner in the manual shares
    public static void generateAccountSharingRule (Set<Id> accids) {
        List<AccountShare> accshares = new List<AccountShare> ();
        Set<String> duplicatecheck = new Set<String> ();
        List<AccountShare> delshares = [SELECT Id
                                        FROM AccountShare
                                        WHERE AccountId IN :accids
                                        AND RowCause= 'Manual'];

        if (delshares.size() > 0) Delete delshares; // Deletes existing old account share
 
        for (Opportunity opp : [SELECT Id, OwnerId, AccountID, Account.OwnerId 
                                FROM Opportunity
                                WHERE AccountId IN :accids
                                AND Owner.IsActive = TRUE
                                AND Probability != 0]) {
 
              AccountShare ass = new AccountShare();

              if (opp.OwnerId != opp.account.OwnerId &&
                 !duplicatecheck.contains(opp.AccountId + '&' + opp.OwnerId)) {

                  ass.UserOrGroupId = opp.OwnerId;
                  ass.AccountAccessLevel = 'edit';
                  ass.OpportunityAccessLevel = 'read';
                  ass.RowCause = 'Manual';
                  ass.AccountId = opp.AccountId;
                  accshares.add(ass);
                  duplicatecheck.add(opp.AccountId + '&' + opp.OwnerId);
              }
        }
        if (accshares.size() > 0) insert accshares;
        ActivityRelated.recalculateappShare(accids);
    }
}