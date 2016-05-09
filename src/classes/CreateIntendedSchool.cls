/**************************************************************************************************
 * Name: CreateIntendedSchool
 * Object: Opportunity
 * Purpose: 
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
global without sharing class CreateIntendedSchool {

    public Id oppId { get; set; }
    public String faculty { get; set; }
    public String major { get; set; }
    public String degree { get; set; }
    public String school { get; set; }
    public Intended_School__c intendedSchool { get; set; }
    public String country { get; set; }

    public CreateIntendedSchool (ApexPages.StandardController std) {

        oppId = ApexPages.currentPage().getParameters().get('oppId');
        Opportunity opp = [SELECT Id, Project__c 
                           FROM Opportunity 
                           WHERE Id = :oppId];

        intendedSchool = new Intended_School__c ();
        country = opp.Project__c;
        faculty = '';
        major = ''; 
        degree = '';
        school = '';
    }

    @RemoteAction
    global Static String create (String param) {

        Map<String, Object> pmap = (Map<String, Object>) JSON.deserializeUntyped(param);
        System.debug('LoggingLevel.INFO, *** param: ' + param);

        Intended_School__c intendedSchool = new Intended_School__c ();
        intendedSchool.UUID_Degree__c = String.valueOf(pmap.get('degree'));
        intendedSchool.UUID_Faculty__c = String.valueOf(pmap.get('faculty'));
        intendedSchool.UUID_Major__c = String.valueOf(pmap.get('major'));
        intendedSchool.UUID_School__c = String.valueOf(pmap.get('school'));
        intendedSchool.Opportunity__c = String.valueOf(pmap.get('oppId'));
        intendedSchool.SchoolNameBak__c = String.valueOf(pmap.get('schoolbak'));
        List<Intended_School__c> ilist = [SELECT Id
                                          FROM Intended_School__c
                                          WHERE UUID_School__c = :intendedSchool.UUID_School__c
                                          AND UUID_Degree__c = :intendedSchool.UUID_Degree__c
                                          AND UUID_Faculty__c = :intendedSchool.UUID_Faculty__c
                                          AND UUID_Major__c = :intendedSchool.UUID_Major__c
                                          AND Opportunity__c = :intendedSchool.Opportunity__c
                                          AND SchoolNameBak__c = :intendedSchool.SchoolNameBak__c];
        if (ilist.size() > 0) {
            return '已经存在该学校及专业';
        }

        try {

            System.debug('LoggingLevel.INFO, *** intendedSchool: ' + intendedSchool);
            insert intendedSchool;
            return 'success';
        } catch(Exception e) {

            String msg = e.getMessage();
            return msg;
        }
    }
}