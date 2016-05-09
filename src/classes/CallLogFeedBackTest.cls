/**************************************************************************************************
 * Name: CallLogFeedBackTest
 * Object: Lead, Appoitment__c
 * Purpose: a test class for Jiaowu referral interface
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-05
 * Modified History: 
 * 2016-05-05    Vicia Wang    Writes comments in this format
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class CallLogFeedBackTest {

    static testMethod void testCallLogFeedBack () {

        User user = TestObjectFactory.createUser();
        System.runAs(user) {

            Utils.runLeadTrigger = FALSE;
            List<Lead> leadList = new List<Lead> ();
            Campaign BankofSH = TestObjectFactory.createCampaign(
                'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

            Lead SHLead1 = TestObjectFactory.createLead(
                BankofSH, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            leadList.add(SHLead1);

            Lead SHLead2 = TestObjectFactory.createLead(
                BankofSH, Constants.CITY_SH_CN, TRUE, '19099990001', '22220001');
            leadList.add(SHLead2);

            insert leadList;

            for (Lead lead :leadList) {
                TestObjectFactory.createLeadItemList(lead);
            }

            String requestBody = 
                '[{"crmid":"' + leadList[0].Id  + '","calllogid":"cl0001","status":"Successfully","errormsg":"", "batchId":"b001"}]';

            // Does request
            RestRequest req = new RestRequest ();
            RestResponse res = new RestResponse ();
            req.requestURI = '/services/apexrest/CallLogFeedBack';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(requestBody);
            RestContext.request = req;
            RestContext.response = res;
            String result = CallLogFeedBack.doPost();
            System.assertEquals(TRUE, result.contains(Constants.SUCCESS_CN));

            Appoitment__c followup = TestObjectFactory.createLeadFollowup(leadList[0]);
            String bodyContainsError = 
                '[{"crmid":"' + leadList[0].Id  + '","calllogid":"cl0001","status":"Successfully","errormsg":"test error", "batchId":"b001"}]';
            req.requestBody = Blob.valueof(bodyContainsError);
            String result2 = CallLogFeedBack.doPost();
            System.assertEquals(TRUE, result2.contains(Constants.SUCCESS_CN));

            BatchCallOutManagementItem__c batchCallout = new BatchCallOutManagementItem__c ();
            insert batchCallout;
            CallLog_History__c callLog1 = TestObjectFactory.createLeadCallLogHistory(batchCallout.Id, leadList[0]);
            CallLog_History__c callLog2 = TestObjectFactory.createLeadCallLogHistory(batchCallout.Id, leadList[1]);

            String requestBody2 = 
                '[{"crmid":"' + leadList[0].Id  + '","calllogid":"HL001","status":"Successfully","errormsg":"", "batchId":' + batchCallout.Name + '}, ' +
                '{"crmid":"' + leadList[1].Id  + '","calllogid":"HL002","status":"Successfully","errormsg":"", "batchId":' + batchCallout.Name + '}]';
            req.requestBody = Blob.valueof(requestBody2);

            String result3 = CallLogFeedBack.doPost();
            System.debug(LoggingLevel.INFO, '*** result: ' + result3);
        }
    }
}