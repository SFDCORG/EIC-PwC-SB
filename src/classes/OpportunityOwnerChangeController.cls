/**************************************************************************************************
 * Name: OpportunityOwnerChangeController
 * Object: Account
 * Purpose: Mass change opportunity to another Owner 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-11-12
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 **************************************************************************************************/
public  class OpportunityOwnerChangeController { 
    
    public String  newOwnerID {get; set;} // The new user who been assigned as this batch opportunities' Owner
    public String  user {get; set;} // The user name is used to display the selected name in the search box
    public Boolean saveFlag {get; set;} // Show the save button or not
    public Integer selectedRows {get; set;} // The selected opp number in the list view
    public Integer succcess {get; set;} // The number of opportunities which can be updated successfully in this batch
    private List<Opportunity> app_oppsList = new List<Opportunity>(); // The Opportunity owner change list for inserting first day assignments
    private Set<id> selectedOppIdSet = new Set<id>(); // All the opp id which been selected in the list view
    private Map<Opportunity,id> oldUserOppMap= new Map<Opportunity,id>(); // Get origal [opp]-[opp ownerId] map
    private static final Set<String> blockChangeStage= new Set<String>(); // Define which opp status shall be hold, and not changed to '顾问跟进'   
    static {
        blockChangeStage.add(Constants.OPPORTUNITY_STAGE_LOW_STAR);
        blockChangeStage.add(Constants.OPPORTUNITY_STAGE_CLOSED_LOST_CN);
        blockChangeStage.add(Constants.OPPORTUNITY_STAGE_CLOSED_WON);
    }

    // Initializes the controller
    public OpportunityOwnerChangeController(ApexPages.StandardSetController controller ) {
        newOwnerID = '';
        saveFlag = false;
        succcess = 0;
        user = userinfo.getName();
        newOwnerID = userinfo.getUserId();
    	for (Opportunity opp : (List<Opportunity>)controller.getSelected()) {
            selectedOppIdSet.add(opp.Id);
        } 
        if (selectedOppIdSet.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Constants.NO_SELECTED_OPPS));
            return;
        }
        String transfercheck = transferCheck();
        if (transferCheck() != 'success') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, transfercheck));
            return;
        }
        selectedRows = selectedOppIdSet.size();
        saveFlag = true;
    }

    // The save button action
    public void AssignOpp()
    {
        if (newOwnerID != '') {
            List<Opportunity> updateOppList = NEW List<Opportunity>() ;

            // get [oppid] - [current user assign permission] map
            Map<ID,Boolean> opppermissionSet = OpportuinityRelatedController.BulkoppAssignButtonPermissionget(selectedOppIdSet, userinfo.getUserId());
            
            Map<ID,Boolean> oppEidtpermissionSet = OpportuinityRelatedController.BulkoppAssignButtonEditPermissionget(selectedOppIdSet);

            for (Opportunity opp: [SELECT OwnerID, stagename, sys_UnlockStage__c, Transfer_Status__c 
                                   FROM Opportunity 
                                   WHERE Id IN : selectedOppIdSet]) {
                if (opppermissionSet.get(opp.Id) == true || 
                    oppEidtpermissionSet.get(opp.Id) ||
                    ProfileRelated.adminProfileSet().contains(userinfo.getProfileId()) ||
                    (ProfileRelated.getTMKCallCenterSet().contains(userinfo.getProfileId())&& 
                        opp.StageName == Constants.OPPORTUNITY_STAGE_LOW_STAR)) {

                    succcess ++;
                    if (opp.Transfer_Status__c == Constants.OPPORTUNITY_TRANSFER_STATUS_ING) {
                        selectedOppIdSet.remove(opp.Id);
                    } else { 
                        opp.Transfer_Status__c = Constants.OPPORTUNITY_TRANSFER_STATUS_ING;
                        updateOppList.add(opp);
                    }
                }
	        }

            // Only current user have the permission of all opportunites, the assign action will be done
            If (succcess >0 && selectedRows == succcess) {
                if (updateOppList.size() > 0) update updateOppList;
                Database.executeBatch(new OpportunityOwnerChangeBatch(selectedOppIdSet,newOwnerID ), 10);
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Constants.NO_SELECTED_ACCEPTOR));
        }
    }
    
    public PageReference cancel() {
        return  new PageReference('/' + '006');
    }

    private String transferCheck() {
        List<Opportunity> opps = [SELECT Transfer_Status__c,RecordTypeID 
                                  FROM Opportunity 
                                  WHERE Id IN :selectedOppIdSet];
        
        for (Opportunity opp : opps) {
            
           if (opp.RecordTypeID != RecordTypeRelated.SubAgent_Opp &&
               userinfo.getProfileId() == ProfileRelated.marketSubAgent) { 
              return Constants.CHANGE_WITH_NO_ACCESS_OPPS;
           }

           else if (opp.Transfer_Status__c == Constants.OPPORTUNITY_TRANSFER_STATUS_ING) {
              return Constants.CONTAIN_TRANSFERING_OPPS;
           }
        }
        return 'success';
    }
}