/**************************************************************************************************
 * Name: ViewlossOppsAppsController
 * Object: Account, Contact, Opportunity, Appoitment__c
 * Purpose: View Loss Opportunities
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-11
 * Modify History:
 * 2016-05-11    Vicia Wang    Create this class
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
public with sharing class ViewlossOppsAppsController {

    public ID oppID {get; set;} 
    public List<OppAppWrapper> oaList {get; set;}

    public ViewlossOppsAppsController(ApexPages.StandardController controller) {
        oppID = ApexPages.CurrentPage().getParameters().get('oppID');
        oaList = new List<OppAppWrapper>();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Revive_Opportunity__c = :oppID];
        generateOppAppWrapper(oppList);
    }

    private void generateOppAppWrapper(List<Opportunity> oppList) {
        Map<ID,Set<Appoitment__c>> oppApps = new Map<ID,Set<Appoitment__c>>();
        for (Appoitment__c app : [SELECT Id, Opportunity__c,
                                         Name, Description__c, 
                                         CreatedBy.Name, 
                                         RecordType.Name, 
                                         Appointment_Type__c, 
                                         Assign_To__r.Name, 
                                         sys_DueTime__c, 
                                         Status__c,
                                         CreatedDate, 
                                         Follow_Up_Result__c,
                                         LastModifiedDate,
                                         Opportunity__r.CreatedDate,
                                         Opportunity__r.LastModifiedDate,
                                         Opportunity__r.Owner.Name
                                    FROM Appoitment__c 
                                    WHERE Opportunity__c IN :oppList
                                    ORDER BY sys_DueTime__c DESC]) {

            Set<Appoitment__c> apps = oppApps.get(app.Opportunity__c) == null ? 
                new Set<Appoitment__c>() : oppApps.get(app.Opportunity__c);
            apps.add(app);
            oppApps.put(app.Opportunity__c, apps);
        }

        for (Opportunity opp : [SELECT Id, Name, CreatedDate, LastModifiedDate 
                                FROM Opportunity
                                WHERE Id IN : oppApps.keySet()]) {

            OppAppWrapper oaW = new OppAppWrapper();
            List<Appoitment__c> apps = new List<Appoitment__c>();
            apps.addAll(oppApps.get(opp.Id));

            oaw.opp = opp;
            oaw.apps = apps;
            oaList.add(oaW);
        }
    }

    public class OppAppWrapper {
        public Opportunity opp { get; set; }
        public List<Appoitment__c> apps { get; set; }
    }
}