/**************************************************************************************************
 * Name: OppOwnerGroupGenerate
 * Object: Opportunity
 * Purpose: 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Ray Cen    Create this class
 **************************************************************************************************/
public class OppOwnerGroupGenerate {
    public static Set<ID> getOpportuniyOwnerGroup(Id accountid) {
        Set<ID> userId = new Set<id>();
        Set<ID> oppID = new Set<id>();
        for(Opportunity opp : [SELECT OwnerId, Id FROM Opportunity WHERE AccountId = :accountid]) {    
            userId.add(opp.OwnerId);
            oppID.add(opp.id);
        }

        for (OpportunityTeamMember member : [SELECT UserId FROM OpportunityTeamMember 
                                           WHERE OpportunityId in :oppID]) {
            userId.add(member.UserId);
        }

        return userId;
   }


    public static Map<ID,Set<ID>> getOpportuniyOwnerGroupBulk(Set<Id> accountid) {
        Map<ID,Set<ID>> accountOppOwners = new Map<ID,Set<ID>> ();
      
        for (Opportunity opp : [SELECT OwnerId,ID,AccountId FROM Opportunity WHERE AccountId IN :accountid]) {   
            Set<ID> oppOwnerIDs = accountOppOwners.get(opp.AccountId) == null ? 
                new Set<ID>() : accountOppOwners.get(opp.AccountId);
            oppOwnerIDs.add(opp.OwnerId);
            accountOppOwners.put(opp.AccountId, oppOwnerIDs);
        }

        return accountOppOwners;
    }

    public static Set<ID> getAdminGroup() {
        Set<ID> userId = new Set<id>();
        for (User uzer : [SELECT Id FROM User 
                          WHERE Profile.Id = :ProfileRelated.adminProfileSet()]) {
            userId.add(uzer.id);
        }
        
        return userId;
    } 
}