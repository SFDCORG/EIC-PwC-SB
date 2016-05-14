/**************************************************************************************************
 * Name: OpportunityOwnerChangeBatch
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
global class OpportunityOwnerChangeBatch implements Database.Batchable<sObject>, Database.stateful {

    global final String query;
    private List<Opportunity> successList;
    private List<String> errorsList;
    private Set<ID> oppIDs;
    private ID newOwnerID;
    private static final Set<String> blockChangeStage = new Set<String>(); // define which opp status shall be hold, and not changed to '顾问跟进'   
    static {
        blockChangeStage.add('低星资源池');
        blockChangeStage.add('流失');
        blockChangeStage.add('签约');
    }

    global OpportunityOwnerChangeBatch(Set<ID> oppID, ID inputOwnerID) {

        oppIDs = new Set<ID>();
        newOwnerID = inputOwnerID;
        successList = new List<Opportunity>();
        errorsList = new List<String>();
        oppIDs.addAll(oppID);

        query = 'SELECT id FROM Opportunity WHERE id IN :oppIDs';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(query);

    }

    global void execute (Database.BatchableContext BC, list<Sobject> scope) {

        Set<ID> selectedOppIdSet = returnOppIDSet((List<Opportunity>) scope);
        Map<Opportunity, Id> oldUserOppMap = new Map<Opportunity, Id>(); 
        List<Opportunity> updateOppList = new List<Opportunity>() ;
        List<Opportunity> app_oppsList =new List<Opportunity>(); 
        for (Opportunity opp: [SELECT ID, OwnerID, stagename, sys_UnlockStage__c 
                               FROM Opportunity 
                               WHERE id IN :selectedOppIdSet]) {

            Id olduserID = opp.OwnerId;

            if (!blockChangeStage.contains(opp.StageName)) {
                opp.StageName = '顾问跟进';
                opp.sys_UnlockStage__c = true;
                app_oppsList.add(opp);
            }
                
            opp.OwnerId = newOwnerID;
            updateOppList.add(opp);
            oldUserOppMap.put(opp, olduserID);
        }

        // Only current user have the permission of all opportunities, the assign action will be done
        if (updateOppList.size() > 0 ) {

            try {
                update updateOppList;
                ChangeLogRelated.createOppChangeLogBulk(oldUserOppMap);

                if (app_oppsList.size() > 0 && Userinfo.getProfileId() != ProfileRelated.marketSubAgent) {
                    ActivityRelated.generateAssignmentBulk(app_oppsList);
                }

                successList.addAll(updateOppList);
                updateOppTransferStatus(updateOppList, '未转移');

            } catch(Exception e) {
                errorsList.add(e.getMessage() + (List<Opportunity>)scope);
                updateOppTransferStatus(updateOppList, '转移失败');
            }
        }
    }

    global void finish (Database.BatchableContext BC) {

       sendEmail();
    }

    private void sendEmail () {
        String enduserName = [SELECT Id,name FROM User WHERE Id = :newOwnerID][0].name;
        Messaging.SingleEmailMessage mailErrCld = new Messaging.SingleEmailMessage();
        mailErrCld.setSubject('商机所有人批量转化完成') ;
        mailErrCld.setToAddresses(new String[] { userinfo.getUserEmail()} );
        mailErrCld.setPlainTextBody('成功转移至' + enduserName + ':' + successList.size() + '\n' + '失败商机详情:' + listToString(errorsList));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailErrCld });
    }

    private String listToString (List<String> lis) {

        String res = '';
        for (String s : lis) {
            res += s + '|';
        }

        return res;
    }

    private Set<ID> returnOppIDSet (List<Opportunity> opps) {

        Set<ID> returnID = new Set<ID>();

        for (Opportunity opp:opps) {
            returnID.add(opp.Id);
        }

        return returnID;
    }

    private void updateOppTransferStatus (List<Opportunity> opps, String updateResult) {
        
        for (Opportunity opp: opps) {
            opp.Transfer_Status__c = updateResult;
        }

        update opps;
    }
}