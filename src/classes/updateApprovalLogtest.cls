/**************************************************************************************************
 * Name: updateApprovalLogtest
 * Object: Approval_Log__c
 * Purpose: After an approval log had been created, change the Opportunity stage.
            After the approval had been approved, change the Opportuintity Stage, if it was rejectted. Changed the owner to approvaler.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/

@isTest
private class updateApprovalLogtest {
    static testMethod void testupdateApprovalLog() {
        
        User usr = [SELECT Id 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            User uuser = TestObjectFactory.createSalesUser();
            uuser.Username = 'aplog1@test.com.eic.pwc';
            uuser.User_External_Id__c = '201604271738';
            insert uuser;
        } 

        User runUser = [SELECT Id
                         FROM User 
                         WHERE username = 'aplog1@test.com.eic.pwc'];

        Account acc = TestObjectFactory.createAccount();
        acc.Name = 'account eic';
        insert acc;
        
        // Avoid which trigger and flow which is don't need for test data creation
        shouldProcessRun__c avoidTrigger = TestObjectFactory.createShouldRun(usr.Id);
        insert avoidTrigger;

        // Creates a the Batchjob Size
        Batch_Size_Setting__c btsize = TestObjectFactory.createBatchSizeSetting();
        btsize.Opportunity_Owner_Change_Batch__c = 15;
        insert btsize;

        For (Integer i = 0; i <= 12 ;i ++) {
            Opportunity opp = TestObjectFactory.createOpportunity(acc.id,runUser);
            opp.StageName = '顾问跟进';
            opp.RecordTypeId = Constants.OPP_RT_COUNSELLING_ID;
            insert opp;
        }
        
        List<Opportunity> opps = [SELECT Id
                                  FROM Opportunity];
        List<Opportunity> results = new List<Opportunity>();

        test.StartTest();
        System.runAs(runUser) {

            // Tests the insert trigger scenarios, After the approval log has been inserted the system,
            // Opporutnity's Stage will be changed to specific value, and generate a request lost change log in system
            for (Integer i = 0; i < opps.size(); i++){
                Approval_Log__c aprvl = TestObjectFactory.createApprovalLog(opps[i].Id, runUser.Id);
                insert aprvl;
            }
            List<Change_Log__c> changlogs = [SELECT Id 
                                             FROM Change_Log__c 
                                             WHERE Opportunity__c in :opps];
            results = [SELECT Id , StageName
                       FROM Opportunity
                       WHERE Id IN :opps];
            system.assertEquals('申请无效', results[0].StageName);
            system.assertEquals(opps.size(), changlogs.size());
            
            // Tests the update Trigger, If ther reject log numer is less than 10.
            // All Opportunity Stage and onwer will change directly to pending Assign
            List<Approval.ProcessWorkitemRequest> pwrs = new List<Approval.ProcessWorkitemRequest>();
            for (ProcessInstanceWorkitem piw : [SELECT Id 
                                                FROM ProcessInstanceWorkitem LIMIT 1]) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setComments('Approving request.');
                pwr.setAction('Reject');
                pwr.setWorkitemId(piw.Id);
                pwrs.add(pwr);
            }
            Approval.process(pwrs);
            results = [SELECT Id , StageName, OwnerId
                       FROM Opportunity
                       WHERE Id IN :opps and StageName = '待分配'];
            System.assertEquals(runUser.Id, results[0].OwnerId);
            System.assertEquals(1, results.size());

            // Tests the update Trigger, If the reject log number is more than 10, 
            // All Opportunity Stage will change directly to pending Assign
            // But the Opportunity Owner change will be execute as a batch job
            pwrs = new List<Approval.ProcessWorkitemRequest>();
            for (ProcessInstanceWorkitem piw : [SELECT Id 
                                               FROM ProcessInstanceWorkitem LIMIT 11]) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setComments('Approving request.');
                pwr.setAction('Reject');
                pwr.setWorkitemId(piw.Id);
                pwrs.add(pwr);
            }
            Approval.process(pwrs);
            results = [SELECT Id , StageName
                      FROM Opportunity
                      WHERE Id IN :opps and StageName = '待分配'];

            List<AsyncApexJob> asyns = [SELECT Id, MethodName,Status,JobType, ApexClassID
                                        FROM AsyncApexJob 
                                        WHERE ApexClassID IN (SELECT Id 
                                                              FROM ApexClass
                                                              WHERE Name = 'OpportunityOwnerChangeBatch')];
            System.assertEquals(12, results.size()); // becasue rejects 12 approvl log in previous code
            System.assertEquals(1, asyns.size());
             
            // Approve the lost request, the related Opp Stage will be changed to closed
            pwrs = new List<Approval.ProcessWorkitemRequest>();
            for (ProcessInstanceWorkitem piw : [SELECT Id 
                                               FROM ProcessInstanceWorkitem LIMIT 11]) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setComments('Approving request.');
                pwr.setAction('Approve');
                pwr.setWorkitemId(piw.Id);
                pwrs.add(pwr);
            }
            Approval.process(pwrs);
            results = [SELECT Id , StageName
                       FROM Opportunity
                       WHERE Id IN :opps and StageName = :Constants.OPPORTUNITY_STAGE_CLOSED_LOST_CN];
            System.assertEquals(1, results.size()); 
        }
        test.stopTest();
    }
}