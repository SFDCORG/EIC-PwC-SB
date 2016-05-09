/**************************************************************************************************
 * Name: updateApprovalLog
 * Object: Approval_Log__c
 * Purpose: After an approval log had been created, change the Opportunity stage.
            After the approval had been approved, change the Opportuintity Stage, if it was rejectted. Changed the owner to approvaler.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/

trigger updateApprovalLog on Approval_Log__c (After insert, After update) {
   
    List<Opportunity> opps = new List<Opportunity>(); // Define the opp list for update
    Set<Id> logIds = new Set<Id>(); // Collect this transaction's Ids of approval logs
    Set<Id> oppIds = new Set<Id>(); // Collect the opp Ids which shall be updated
    private Boolean batchFlag = false; // Flag for opp Owner changment batch job work or not

    // The BatchSize of Opportunity Owner Change Batch
    private Integer batchSize = Integer.valueOf(Batch_Size_Setting__c.getInstance().Opportunity_Owner_Change_Batch__c);

    for ( Approval_Log__c log : trigger.new) {
          logids.add(log.Id);
    }
    
    // The update trigger
    if (trigger.isUpdate && trigger.isAfter) {
        
        // Query the approval log which shall be updated. The condition is :
        // 1. not Won or Lost
        // 2. RecordType is Opportunity_Status_ALog
        List<Approval_Log__c> logs = [SELECT Approval_Status__c,
                                             Opportunity__r.StageName,
                                             Opportunity__c,
                                             RecordTypeId
                                      FROM Approval_Log__c 
                                      WHERE Id IN :logids
                                      AND (NOT Opportunity__r.StageName IN ('流失','签约'))
                                      AND RecordTypeId IN :RecordTypeRelated.Opportunity_approval_logs_record_types];

        for (Approval_Log__c log : logs) {
            
            // If the Status doesn't be updated, closed the following trigger
            if (log.Approval_Status__c != '审批拒绝' && log.Approval_Status__c != '审批同意') return;

            Opportunity opp = new Opportunity();
            opp = log.Opportunity__r; 
            opp.sys_UnlockStage__c = true;

            // If the approval has been approved, changed the opportunity Stage to Lost
            if (log.Approval_Status__c == '审批同意' &&
                opp.StageName!='流失') {
                opp.StageName='流失';
            }

            // If the approval has been rejected, changed the opportunity Stage to pending Assign
            // If the log size <=10, the owner to current user directly.
            // If the log size > 10, Will call a batch job to finish it.
            else if (log.Approval_Status__c == '审批拒绝' &&
                opp.StageName!='待分配') {

                if (logs.size() <= 10) opp.OwnerId = UserInfo.getUserId();
                else batchFlag = true;

                opp.StageName='待分配';
            }

            // Remove duplicate pending approval log from one opportunity
            if (!oppids.contains(log.Opportunity__c)) {
                oppids.add(log.Opportunity__c);
                opps.add(opp);
            }
        }

        update opps;

        if (batchFlag) {
            Database.executeBatch(new OpportunityOwnerChangeBatch(oppids, UserInfo.getUserId()), batchSize);
        }
    }
    
    // After the approval has been created, changed the Opportuinty Stange, and create a approval request log
    else if (trigger.isInsert) {
        Map<Opportunity,ID> newoppApprover = new  Map<Opportunity,ID> ();
        for (Approval_Log__c log : [SELECT Approval_Status__c,
                                           Opportunity__r.sys_UnlockStage__c,
                                           Opportunity__r.OwnerId, 
                                           Opportunity__r.StageName,
                                           Opportunity__c,
                                           RecordTypeId,
                                           Loss_Reason__c,
                                           Approver__c
                                    FROM Approval_Log__c 
                                    WHERE Id IN :logids 
                                    AND Approval_Status__c = '待审批']) {
            
            Opportunity opp = new Opportunity();
            opp = log.Opportunity__r;
            opp.StageName = opp.StageName == '顾问跟进' ? '申请无效' : '申请流失';
            opp.sys_UnlockStage__c = true;
            opps.add(opp);
            newoppApprover.put(opp, log.Approver__c);
        }
        if (opps.size() > 0) {
            update opps;
            ChangeLogRelated.createOppLossLog(newoppApprover);
        }
    }
}