/**************************************************************************************************
 * Name: RefreshOppTeam
 * Object: Opportunity, UserRole
 * Purpose: Batch generate opportunity teams
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-11
 * Modify History:
 * 2016-05-11        Create this class
 **************************************************************************************************/
global class RefreshOppTeam implements Database.Batchable<sObject> {

    global final String query;
    global final Set<ID> roleIds;
    global final Set<ID> userIDs;

    global RefreshOppTeam(Set<ID> roleId, Set<ID> userID) {
        roleIds = CommonHelperClass.getAllLowerRoles(roleId);
        userIDs = userID;
        query = 'SELECT id ' +
                'FROM Opportunity ' + 
                'WHERE OwnerID IN :userIDs OR Owner.UserRoleId IN :roleIds ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        Set<ID> oppids = new Set<ID>();
        for (Opportunity opp : (List<Opportunity>) scope) {
            oppids.add(opp.Id);
        }

        OpportuinityRelatedController.generateOppTeam_Batchjob(oppids);
    }

    global void finish(Database.BatchableContext BC) {}
}