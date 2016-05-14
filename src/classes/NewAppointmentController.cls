/**************************************************************************************************
 * Name: NewAppointmentController
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public with sharing class NewAppointmentController {

    public Appoitment__c app { get;set; }
    public String rType { get;set; }
    public String oppId { get;set; }
    public String leadId { get;set; }
    public String batchId { get;set; }
    public String intendCity { get;set; }
    public String invitationType { get;set; }
    public String userId { get;set; }
    public List<CallLog_History__c> clog { get;set; }
    public Boolean isValid { get;set; }

    public NewAppointmentController() {

        isValid = true;
        app = new Appoitment__c();
        rType = ApexPages.currentPage().getParameters().get('rType');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        batchId = ApexPages.currentPage().getParameters().get('batchId');
        intendCity = ApexPages.currentPage().getParameters().get('intendCity');
        invitationType = ApexPages.currentPage().getParameters().get('invitationType');
        List<RecordType> rts =  [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = :rType
                                 AND isActive = true];

        if (rts.size() == 0 || ((oppId == null || oppId == '') && (leadId == null || oppId == ''))) {
            isValid = false;
        } else {
            app.RecordTypeId = rts[0].Id;
        }

        userId = UserInfo.getUserId();
        clog = [SELECT Id, BatchCallOut__r.Name
                FROM CallLog_History__c
                WHERE Id = :batchId];

        app.Opportunity__c = oppId;
        app.Lead__c = leadId;
        app.Intended_City__c = intendCity;
        app.Assign_To__c = userId;
        app.CalllogHistory__c = batchId;
        if (invitationType !=null && invitationType != '') {
            app.Appointment_Type__c = invitationType;
        }
    }

    public PageReference save () {

        try {
            insert app;
            if (oppId == null || oppId == '') {

                return new PageReference('/apex/LeadDetailV2?id=' + leadId + '&batchId=' + (clog.size() > 0 ? clog[0].BatchCallOut__r.Name : ''));
            } else {

                return new PageReference('/' + oppId + '?batchId=' + (clog.size() > 0 ? clog[0].BatchCallOut__r.Name : ''));
            }

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public PageReference cancel () {
        if (oppId == null || oppId == '') {

            return new PageReference('/apex/LeadDetailV2?id=' + leadId + '&batchId=' + (clog.size() > 0 ? clog[0].BatchCallOut__r.Name : ''));
        } else {

            return new PageReference('/' + oppId + '?batchId=' + (clog.size() > 0 ? clog[0].BatchCallOut__r.Name : ''));
        }
    }
}