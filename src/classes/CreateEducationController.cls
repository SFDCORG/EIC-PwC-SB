/**************************************************************************************************
 * Name: CreateEducationController
 * Object: Account
 * Purpose: ***
 * Author: Joe Zhou
 * Create Date: 2016-05-06
 * Modified History:
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
global class CreateEducationController {

    public Id acctId { get; set; }
    public CreateEducationController (ApexPages.StandardController con) {

        acctId = ApexPages.currentPage().getParameters().get('acctId');
    }

    @RemoteAction
    global Static String create (String param) {

        Map<String, Object> pmap = (Map<String, Object>) JSON.deserializeUntyped(param);
        System.debug('LoggingLevel.INFO, *** param: ' + param);

        Education__c edu = new Education__c ();
        edu.UUID_Degree__c = String.valueOf(pmap.get('degree'));
        edu.UUID_Faculty__c = String.valueOf(pmap.get('faculty'));
        edu.UUID_Major__c = String.valueOf(pmap.get('major'));
        edu.UUID_School__c = String.valueOf(pmap.get('school'));
        edu.Account__c = String.valueOf(pmap.get('acctId'));
        edu.SchoolNameBak__c = String.valueOf(pmap.get('schoolbak'));
        List<Education__c> ilist = [SELECT Id 
                                    FROM Education__c 
                                    WHERE UUID_School__c = :edu.UUID_School__c 
                                    AND UUID_Degree__c = :edu.UUID_Degree__c 
                                    AND UUID_Faculty__c = :edu.UUID_Faculty__c 
                                    AND UUID_Major__c = :edu.UUID_Major__c 
                                    AND Account__c = :edu.Account__c 
                                    AND SchoolNameBak__c = :edu.SchoolNameBak__c];
        if (ilist.size() > 0) {
            return '已经存在该学校及专业';
        }

        try {

            insert edu;
            return 'success';
        } catch(Exception e) {
            String msg = e.getMessage();
            return msg;
        }
    }
}