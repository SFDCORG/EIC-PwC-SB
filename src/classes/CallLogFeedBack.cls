/**************************************************************************************************
 * Name: CalllogFeedBack
 * Object: Calllog_History__c
 * Purpose: REST API interface to receive the call log from call center system
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History:
 * 2016-05-06  Vicia Wang    Writes comments in this format
 * 2016-05-06  Allen    Format the code
 * Test url: https://{instance_url}.salesforce.com/services/apexrest/CallLogFeedBack
***************************************************************************************************/
@RestResource(urlMapping = '/CallLogFeedBack/*')
global class CallLogFeedBack {

    @HttpPost
    global static String doPost() {

        try {

            RestRequest request = RestContext.request;
            String body = RestContext.request.requestBody.toString();
            InteractionLogUtil.CreateLog('CallLogFeedBack', body);
            System.debug(LoggingLevel.INFO, '*** body: ' + body);

            body = EncodingUtil.urlDecode(body, 'UTF-8');
            List<feedbackWrap> fws = (List<feedbackWrap>) JSON.deserialize(body, List<feedbackWrap>.class);
            Set<Id> leadids = new Set<Id> ();

            // If the calllog is singular
            if (fws.size() == 1 ) {

                CallLog_History__c ch = new CallLog_History__c ();
                ch.Type__c = '单条外呼';
                feedbackWrap fw = fws[0];

                if (fw.calllogId != '') {

                    ch.Result__c = '呼叫成功';
                    ch.CallLogId__c = fw.calllogid;
                    if (fw.crmid.substring(0, 3) == '00Q') {
                        ch.Lead__c = fw.crmid;
                    } else {
                        ch.Opportunity__c = fw.crmid;
                    }

                } else {

                    if (fw.errormsg != '') {
                        ch.Result__c = fw.errormsg;
                    } else {
                        ch.Result__c = '呼叫失败';
                    }
                    if (fw.crmid.substring(0, 3) == '00Q') {
                        ch.Lead__c = fw.crmid;
                        leadids.add(fw.crmid);
                    } else {
                        ch.Opportunity__c = fw.crmid;
                    }
                }

                insert ch;

                if (fw.crmid.substring(0, 3) == '00Q') {

                    List<Appoitment__c> tempapplist = [SELECT Status__c, Follow_Up_Result__c, Lead__c
                                                       FROM Appoitment__c
                                                       WHERE RecordType.DeveloperName = 'Lead_Follow_Up'
                                                       AND Lead__c = :fw.crmid
                                                       AND Follow_Up_Result__c IN ('无人接听-1',
                                                                                   '无人接听-2',
                                                                                   '无人接听-3次或以上')
                                                       ORDER BY Lead__c, Follow_Up_Result__c];
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

                    Appoitment__c app = new Appoitment__c ();
                    app.Lead__c = fw.crmid;
                    app.Name = 'Generate by batch singleCallout';
                    app.RecordTypeId = [SELECT Id
                                        FROM RecordType
                                        WHERE DeveloperName = 'Lead_Follow_Up'
                                        AND SObjectType = 'Appoitment__c'].Id;
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
                    insert app;
                }

            // If we get a batch size of calllogs, we will handle them by the batch
            } else if (fws.size() > 1) {

                Database.executeBatch(new CreateCalllogHistoryBatchable(fws), 10);
            }

        } catch (Exception e) { 

            return '{"STATUS":"失败", "ERRORMSG":"' + e.getMessage() + '"}';
        }

        return '{"STATUS":"成功", "ERRORMSG":""}';
    }

    global class feedbackWrap{
        global String crmid;
        global String calllogid;
        global String status;
        global String errormsg;
        global String batchId;
        global feedbackWrap() { }
    }

    global class CustomIterable implements Iterator<CallLogFeedBack.feedbackWrap> { 

        List<feedbackWrap> fws { get; set; }
        Integer i { get; set; }

        public CustomIterable(List<feedbackWrap> vals) { 
            fws = vals;
            i = 0;
        }

        global boolean hasNext() {

            if (i >= fws.size()) {
                return false;
            } else {
                return true;
            }
        }

        global feedbackWrap next() {

            if (i == fws.size()) {
                return null;
            }

            i++;
            return fws[i - 1]; 
        }
    }
}