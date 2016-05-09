/**************************************************************************************************
 * Name: CreateCalllogHistoryBatchable
 * Object: CalllogFeedBack, Calllog_History__c
 * Purpose: If call center sends back the records number greater than the special number, it will use the batch
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
global class CreateCalllogHistoryBatchable implements 
             Database.Batchable<CallLogFeedBack.feedbackWrap>, Database.Stateful {

    public List<CallLogFeedBack.feedbackWrap> fws;

    global CreateCalllogHistoryBatchable (List<CallLogFeedBack.feedbackWrap> fws) {
        this.fws = fws;
    }

    global Iterable<CallLogFeedBack.feedbackWrap> start (Database.BatchableContext bc) {
        return new Foo (fws);
    }

    global void execute (Database.BatchableContext BC, list<CallLogFeedBack.feedbackWrap> scope) {
        List<CallLogFeedBack.feedbackWrap> objs = scope;
        Set<String> batchIds = new Set<String> ();
        Set<Id> lids = new Set<Id> ();
        for (CallLogFeedBack.feedbackWrap w : objs) {
            if (w.calllogId == '' && w.crmid.substring(0,3) == '00Q') {
                lids.add(w.crmid);
            }

            batchIds.add(w.batchId);
        }

        List<CallLog_History__c> chs = [SELECT CallLogId__c, Result__c,
                                               Opportunity__c, BatchCallOut__c,
                                               BatchCallOut__r.Name, Lead__c,
                                               Name
                                        FROM CallLog_History__c
                                        WHERE BatchCallOut__r.Name IN: batchIds];

        Map<String, List<CallLog_History__c>> bntoid = new Map<String, List<CallLog_History__c>> ();
        for (CallLog_History__c clog : chs) {

            if (bntoid.containsKey(clog.BatchCallOut__r.Name)) {

                bntoid.get(clog.BatchCallOut__r.Name).add(clog);
            } else {

                bntoid.put(clog.BatchCallOut__r.Name, new List<CallLog_History__c> {clog});
            }
        }

        List<CallLog_History__c> chToUpdate = new List<CallLog_History__c> ();
        
        for (CallLogFeedBack.feedbackWrap fw : objs) {

            List<CallLog_History__c> templogs = bntoid.get(fw.batchId);
            for (CallLog_History__c obj : templogs) {

                if (obj.BatchCallOut__r.Name == fw.batchId &&
                    (obj.Opportunity__c == fw.crmid || obj.Lead__c == fw.crmid)) {

                    if (fw.calllogid != '') {
                        obj.CallLogId__c = fw.calllogid;
                        obj.Result__c = '呼叫成功';

                    } else {
                        if (fw.errormsg != '') {
                            obj.Result__c = fw.errormsg;
                        } else {
                            obj.Result__c = '呼叫失败';
                        }
                    }
                    chToUpdate.add(obj);
                    break;
                }
            }
        }

        if (chToUpdate.size() > 0) {
            update chToUpdate;
        }

        RecordType rt =  [SELECT Id
                          FROM RecordType
                          WHERE DeveloperName = 'Lead_Follow_Up'
                          AND SObjectType = 'Appoitment__c'];

        List<Appoitment__c> apptoinsert = new List<Appoitment__c> ();
        List<Appoitment__c> applist = [SELECT Status__c, Follow_Up_Result__c, Lead__c
                                       FROM Appoitment__c
                                       WHERE RecordType.DeveloperName = 'Lead_Follow_Up'
                                       AND Lead__c IN:lids
                                       AND Follow_Up_Result__c IN ('无人接听-1',
                                                                   '无人接听-2',
                                                                   '无人接听-3次或以上')
                                       ORDER BY Lead__c, Follow_Up_Result__c];

        Map<Id, List<Appoitment__c>> appMap = new Map<Id, List<Appoitment__c>> ();
        for (Appoitment__c obj : applist) {
            if (appMap.containsKey(obj.Lead__c)) {
                appMap.get(obj.Lead__c).add(obj);
            } else {
                appMap.put(obj.Lead__c, new List<Appoitment__c> {obj});
            }
        }

        for (Id i : lids) {
            Integer index = 0;
            for (CallLogFeedBack.feedbackWrap w : objs) {
                if (w.crmid == i) {
                    break;
                }
                index ++;
            }

            CallLogFeedBack.feedbackWrap wrap = objs[index];
            List<Appoitment__c> tempapplist = appMap.containsKey(wrap.crmid) ?
                                              appMap.get(wrap.crmid) :
                                              new List<Appoitment__c> ();
            Integer flag = 0;
            for (Appoitment__c a : tempapplist) {
                if (a.Follow_Up_Result__c == '无人接听-1') {
                    flag = 1;
                }
                if (a.Follow_Up_Result__c == '无人接听-2') {
                    flag = 2;
                }
                if (a.Follow_Up_Result__c == '无人接听-3次或以上') {
                    flag = 3;
                    break;
                }
            }

            Appoitment__c app = new Appoitment__c();
            app.Lead__c = wrap.crmid;
            app.Name = 'Generate by batch callout';
            app.RecordTypeId = rt.Id;
            app.Appointment_Type__c = '跟进记录';
            app.Contact_Method__c = '电话';
            app.Follow_Up_Date__c = System.Today();

            if (flag == 0) {
                app.Follow_Up_Result__c = '无人接听-1';

            } else if (flag == 1) {
                app.Follow_Up_Result__c = '无人接听-2';

            } else {
                app.Follow_Up_Result__c = '无人接听-3次或以上';
            }

            apptoinsert.add(app);
        }
        if (apptoinsert.size() > 0) {
            insert apptoinsert;
        }
    }

    global void finish(Database.BatchableContext BC) {}

    global class Foo implements iterable<CallLogFeedBack.feedbackWrap> {

        global List<CallLogFeedBack.feedbackWrap> fws;
        public Foo(List<CallLogFeedBack.feedbackWrap> vals) {

            fws = vals;
        }

        global Iterator<CallLogFeedBack.feedbackWrap> Iterator() {

            return new CallLogFeedBack.CustomIterable(fws);
        }
    }
}