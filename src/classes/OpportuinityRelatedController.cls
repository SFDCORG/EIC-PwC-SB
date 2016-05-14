/**************************************************************************************************
 * Name: OpportuinityRelatedController
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
global class OpportuinityRelatedController {

    private static final Set<String> blockChangeStage = new Set<String>(); // define which opp status shall be hold, AND not changed to '顾问跟进'
    static {
        blockChangeStage.add('签约');
        blockChangeStage.add('流失');
    }

    public static Boolean changeOppOwner(ID userID, ID oppID) {
        Opportunity opp= [SELECT OwnerID 
                          FROM Opportunity
                          WHERE Id = :oppID
                          LIMIT 1];

        opp.OwnerID = userID;
        Return updateOpp(opp);
    }

    public static Boolean updateOpp (Opportunity opp) {

        try { 
            update opp;
        } catch (Exception e) {
            return false;
        }
        return true;
    }

    public static void generateOppTeam (Set<ID> oppIds) {

        List<OpportunityTeamMember> oppteam = new List<OpportunityTeamMember>();
        Set<ID> oppOwnerRoles = new Set<ID>();
        Map<ID, Set<ID>> roleUser = new Map<ID, Set<ID>>();
        Map<ID, Set<ID>> FDARoleUser = new Map<ID, Set<ID>>();

        Set<Id> accountIDs = new Set<Id>();

        for (Opportunity opp: [SELECT Id, AccountId, Owner.UserRoleId, Owner.userrole.DeveloperName
                              FROM Opportunity
                              WHERE Id IN: oppIds
                              AND Owner.UserRoleId != null]) {

           oppOwnerRoles.add(opp.Owner.UserRoleId);
        }

        if (oppOwnerRoles.size() > 0) {
           roleUser = CommonHelperClass.getallUserinSpecifyRolesMap(CommonHelperClass.getHigherRoles(oppOwnerRoles));
        }

        for (Opportunity opp: [SELECT Id, Owner.UserRole.Id, OwnerID, AccountID 
                               FROM Opportunity
                               WHERE Id IN : oppIds]) {

            Set<ID> userList = new Set<ID>();
            Set<ID> oppuserids = new  Set<ID>();

            if (roleUser.isEmpty() == false && opp.Owner.UserRole.Id != null) {

                oppuserids = roleUser.get(opp.Owner.UserRole.Id) == null ? new Set<ID>() : roleUser.get(opp.Owner.UserRole.Id);
                if (oppuserids.size() > 0)
                    userList.addAll(oppuserids);
            }

            if (FDARoleUser.isEmpty() == false && opp.Owner.UserRoleId != null) {
                oppuserids = FDARoleUser.get(opp.Owner.UserRole.Id) == null ? new Set<ID>() : FDARoleUser.get(opp.Owner.UserRole.Id);
                if (oppuserids.size() > 0)
                    userList.addAll(oppuserids);
            }

            userList.add(opp.ownerID);

            for (ID idd : userList) {

                OpportunityTeamMember oppMember = new OpportunityTeamMember();
                oppMember.OpportunityId = opp.Id;
                oppMember.UserId = idd;
                oppMember.TeamMemberRole = 'Team Member';
                oppteam.add(oppMember);
            }

            accountIDs.add(opp.AccountID);
        }
        insert oppteam;

        AccountRelated.generateAccountSharingRule(accountIDs);
        ActivityRelated.changeappsOwner(oppIds);
     }

    public static void clearCurrentOPPTeam (Set<ID> oppIds) {

        List<OpportunityTeamMember> oppteam = [SELECT Id 
                                               FROM OpportunityTeamMember
                                               WHERE OpportunityId IN:oppIds];
        if (oppteam.size() > 0)
            delete oppteam;
    }

    public static void generateOppTeam_Batchjob (Set<ID> oppIds) {

        List<OpportunityTeamMember> deloppteam = [SELECT Id 
                                                  FROM OpportunityTeamMember
                                                  WHERE OpportunityId IN:oppIds];

        if (deloppteam.size() > 0) {

            try {

                delete deloppteam;
            } catch (Exception e) {
                System.debug('LoggingLevel.INFO, *** oppIds: ' + oppIds);
            }
        }

        List<OpportunityTeamMember> oppteam = new List<OpportunityTeamMember>();
        Set<ID> oppOwnerRoles = new Set<ID>();
        Map<ID, Set<ID>> roleUser = new Map<ID, Set<ID>>();
        Map<ID, Set<ID>> FDARoleUser = new Map<ID, Set<ID>>();

        for (Opportunity opp: [SELECT Owner.UserRoleId, Owner.userrole.DeveloperName 
                               FROM Opportunity
                               WHERE Id IN: oppIds
                               AND Owner.UserRoleId != null]) {

            oppOwnerRoles.add(opp.Owner.UserRoleId);
        }

        if (oppOwnerRoles.size() > 0) {
            roleUser = CommonHelperClass.getallUserinSpecifyRolesMap(CommonHelperClass.getHigherRoles(oppOwnerRoles));
        }

        for (Opportunity opp: [SELECT Id, Owner.UserRole.Id, ownerID, AccountID 
                               FROM Opportunity
                               WHERE Id IN : oppIds]) {

            Set<ID> userList = new Set<ID>();
            Set<ID> oppuserids = new  Set<ID>();
            if (roleUser.isEmpty() == false && opp.Owner.UserRole.Id != null) {

                oppuserids = roleUser.get(opp.Owner.UserRole.Id) == null ? new Set<ID>() : roleUser.get(opp.Owner.UserRole.Id);
                if (oppuserids.size() > 0)
                    userList.addAll(oppuserids);
            }

            if (FDARoleUser.isEmpty() == false && opp.Owner.UserRoleId != null) {
                oppuserids=FDARoleUser.get(opp.Owner.UserRole.Id) == null ? new Set<ID>() : FDARoleUser.get(opp.Owner.UserRole.Id);
                if (oppuserids.size() > 0)
                    userList.addAll(oppuserids);
            }
            userList.add(opp.ownerID);

            for (ID idd : userList) {
                OpportunityTeamMember oppMember= new OpportunityTeamMember();
                oppMember.OpportunityId = opp.Id;
                oppMember.UserId = idd;
                oppMember.TeamMemberRole = 'Team Member';
                oppteam.add(oppMember);
            }
        }
        insert oppteam;
     }

    webservice static void masschangeOppOwner (ID oppID, ID toUser) {

        Opportunity opp = [SELECT Id, ownerID
                           FROM Opportunity
                           WHERE Id = :oppID];

        String oldOwner = opp.OwnerId;
        String oldopp = opp.OwnerId;
        opp.OwnerId = toUser;
        opp.sys_UnlockStage__c = true;
        opp.StageName = blockChangeStage.contains(OPP.StageName) ? OPP.StageName : '顾问跟进';
        update opp;
        ChangeLogRelated.CreateOppChangeLog(opp, oldopp, toUser, '', '商机回收');
    }

    webservice static String OppOwnerCollect (ID oppID, ID toUser, ID profileID) {

        Boolean condition1 = oppAssignButtonPermissionget(oppID, toUser, profileID);
        Boolean condition2 = ProfileRelated.getCCManagerSet().contains(profileID);

        if (condition1 && condition2) {
            Opportunity opp=[SELECT Id, ownerID 
                             FROM Opportunity
                             WHERE Id = :oppID];

            String oldOwner = opp.OwnerId;
            String oldopp = opp.OwnerId;
            opp.OwnerId = toUser;
            opp.sys_UnlockStage__c = true;
            opp.StageName = blockChangeStage.contains(OPP.StageName) ? OPP.StageName : '顾问跟进';
            update opp;
            ChangeLogRelated.CreateOppChangeLog(opp, oldopp, toUser, '', '商机回收');
            return '商机回收成功';
        } else {
            return '无商机回收权限';
        }
    }

    webservice static Boolean oppAssignButtonPermissionget (ID oppID, ID userid, ID profileID) {

        Set<String> oppteams = new Set<String>();

        Opportunity opp = [SELECT OwnerID, sys_isSameBusinessCity__c, StageName, Owner.UserRoleID, sys_Department__c,
                                  Owner.Department_of_Role__c, Owner.Office_of_Role__c, Intended_City__c 
                           FROM Opportunity
                           WHERE Id = :oppID];

        Boolean tempPermission = false;
        Boolean FDAPermission = false;
        Boolean TestPrepManager = ProfileRelated.testcenterManger == UserInfo.getProfileId() && opp.sys_isSameBusinessCity__c;

        if (opp.Owner.UserRoleID != null) {
            FDAPermission = ProfileRelated.getFDAProfileSet().contains(profileID) && UserInfo.getUserRoleId() == opp.Owner.UserRoleId;
        }

        if (opp.OwnerId == '00528000001I0RyAAK' && (opp.StageName=='待分配' || opp.StageName=='顾问跟进') &&
            (((ProfileRelated.getCCManagerSet().contains(UserInfo.getProfileId()) ||
               ProfileRelated.getLocalCSSet().contains(UserInfo.getProfileId())) && opp.sys_isSameBusinessCity__c == true)||
               ProfileRelated.getTMKCallCenterSet().contains(UserInfo.getProfileId()))) {
              tempPermission = true;
        }

        for (OpportunityTeamMember opm : [SELECT UserId 
                                          FROM OpportunityTeamMember
                                          WHERE OpportunityId = :oppID]) {
            oppteams.add(opm.UserId);
        }

        Boolean editPerms = checkEditPermissoin(oppID);

        return oppteams.contains(userid) ||
               ProfileRelated.checkAdminprofile(profileID) ||
               tempPermission ||
               FDAPermission ||
               TestPrepManager ||
               editPerms;
     }

    public static Map<ID, Boolean> BulkoppAssignButtonPermissionget (Set<ID> oppID, ID userid) {

        Map<ID, Boolean> returnResult = new Map<ID, Boolean>();
        Map<ID, Set<ID>> oppteams = new Map<ID, Set<ID>>();

        for (OpportunityTeamMember opm : [SELECT UserId, OpportunityId 
                                          FROM OpportunityTeamMember
                                          WHERE OpportunityId IN:oppID]) {
            Set<ID> userSet = oppteams.get(opm.OpportunityId) == null ? new Set<ID>() : oppteams.get(opm.OpportunityId);
            userSet.add(opm.UserId);
            oppteams.put(opm.OpportunityId, userSet);
        }

        for (ID key : oppteams.keySet()) {
            returnResult.put(key, oppteams.get(key).contains(userid));
        }
        return returnResult;
    }

    public static Map<ID, Boolean> BulkoppAssignButtonEditPermissionget (Set<ID> oppID) {

        Map<ID, Boolean> returnResult = new Map<ID, Boolean>();
        for (UserRecordAccess opm:[SELECT RecordId, HasEditAccess 
                                   FROM UserRecordAccess 
                                   WHERE UserId = :UserInfo.getUserId()
                                   AND RecordId IN:oppID]) {

            returnResult.put(opm.RecordId, opm.HasEditAccess);
        }

        return returnResult;
    }

    public static void updateLossOppReferenceField (Set<ID> oppIds, Set<ID> accountIDs) {

        List<Opportunity> lossOpps = [SELECT Id, AccountId, StageName, Intended_City__c, Project__c, RecordTypeId, Revive_Opportunity__c 
                                      FROM Opportunity
                                      WHERE AccountId IN: accountIDs
                                      AND StageName = '流失'];

        Map<Id, Set<Opportunity>> lossOppsMap = generateLossOpportunityMap(lossOpps);
        Set<Opportunity> updateOpps = new Set<Opportunity>();
        if (lossOppsMap != null || !lossOppsMap.isEmpty()) {

            for (Opportunity opp : [SELECT Id, Intended_City__c, Project__c, RecordTypeId, AccountId 
                                    FROM Opportunity
                                    WHERE Id IN :oppIds
                                    AND StageName != '流失']) {

                if (lossOppsMap.get(opp.AccountId) != null) {

                    for (Opportunity lossopp : lossOppsMap.get(opp.AccountId)) {

                        if (lossopp.RecordTypeId == opp.RecordTypeId && lossopp.Intended_City__c == opp.Intended_City__c && 
                           ((lossopp.RecordTypeId == RecordTypeRelated.Counselling_Opp && 
                            lossopp.Project__c == opp.Project__c) || opp.RecordTypeId == RecordTypeRelated.TestPrep_Opp )) {

                            lossopp.Revive_Opportunity__c = opp.Id;
                            updateOpps.add(lossopp);
                        }
                    }
                }
            }

            if (updateOpps.size() > 0) {

                List<Opportunity> updateList = new List<Opportunity> ();
                updateList.addAll(updateOpps);
                update updateList;
            }
        }
    }

    private static Map<Id, Set<Opportunity>> generateLossOpportunityMap (List<Opportunity> lossOpps) {

        Map<Id, Set<Opportunity>> returnResult = new Map<Id, Set<Opportunity>>();

        for (Opportunity opp : lossOpps) {

            Set<Opportunity> opps = returnResult.get(opp.AccountId) == null ? new Set<Opportunity>() : returnResult.get(opp.AccountId);
            opps.add(opp);
            returnResult.put(opp.AccountId, opps);
        }

        return returnResult;
     }

    private static Boolean checkOppExternalPermission (String oppdep, String ownerOffice, String city, String userDep) {

        List<Speical_Opp_Management_City__c> speicals= [SELECT City__c, Office__c
                                                        FROM Speical_Opp_Management_City__c
                                                        WHERE City__c = :city
                                                        AND Office__c = :ownerOffice];

        Boolean cmProfiles = ProfileRelated.getCCManagerSet().contains(UserInfo.getUserId());
        Boolean depcontain = userDep.contains(oppdep);

        return !speicals.isEmpty() && cmProfiles && depcontain;
     }

    public static Boolean checkEditPermissoin (Id OppID) {

       return [SELECT RecordId, HasEditAccess 
               FROM UserRecordAccess
               WHERE UserId = :UserInfo.getUserId()
               AND RecordId = :OppID][0].HasEditAccess;
    }
}