/**************************************************************************************************
 * Name: DuplicatedLeadViewController
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public without sharing class DuplicatedLeadViewController {

    public List<Lead_Item__c> dupLeadItems { get; set; }

    public DuplicatedLeadViewController (ApexPages.StandardController con) {
        dupLeadItems = new List<Lead_Item__c> ();

        Lead curlead = [SELECT Area_Code__c, Phone, MobilePhone
                        FROM Lead
                        WHERE Id = :con.getId()];

        String query = 'SELECT ';
        query += 'Lead__c, Intended_Country__c, Status__c, Business_Line__c, Project__c, ';
        query += 'Lead__r.Name, Lead__r.OwnerId, Lead__r.Campaign__c, Lead__r.CreatedDate, Lead__r.Consultation_Mode__c, Lead__r.Intended_City__c ';
        query += 'FROM Lead_Item__c WHERE Lead__c != \'' + curlead.Id + '\' '; 
        query += 'AND Is_Converted__c = FALSE ';

        if (curlead.Phone != NULL && curlead.MobilePhone != NULL) {

            String fixPhone = curlead.Area_Code__c == NULL?'':curlead.Area_Code__c + curlead.Phone;
            query += 'AND (Mobile__c =\'' + curlead.MobilePhone + '\' OR Fix_Phone__c = \'' + fixPhone + '\')';

        } else if (curlead.Phone != NULL && curlead.MobilePhone == NULL) {

            query += 'AND Fix_Phone__c = \'' + curlead.Phone + '\'';

        } else if (curlead.Phone == NULL && curlead.MobilePhone != NULL) {

            query += 'AND Mobile__c = \'' + curlead.MobilePhone + '\'';
        }

        System.debug(LoggingLevel.INFO, '*** query: ' + query);
        dupLeadItems = Database.query(query);
    }
}