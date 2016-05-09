global class  refreshOppTeam implements Database.Batchable<sObject> {
    
    global final String query;
    global final Set<ID> roleIds;
    global final Set<ID> userIDs;


    global refreshOppTeam(set<ID> roleid, Set<ID> userID) {

        roleIds= CommonHelperClass.getAllLowerRoles(roleid);

        userIDs=userID;
        
        query='select id from Opportunity where OwnerID in : userIDs or Owner.UserRoleId in :roleIds ';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
      
      Set<ID> oppids= new Set<ID>();

      for(Opportunity opp:(List<Opportunity>) scope)
      {
          oppids.add(opp.Id);
      }

      OpportuinityRelatedController.generateOppTeam_Batchjob(oppids);
    }

    global void finish(Database.BatchableContext BC) {
    }
}