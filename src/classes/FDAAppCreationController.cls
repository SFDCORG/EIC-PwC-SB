/**************************************************************************************************
 * Name: FDAAppCreationController
 * Object: Appointment
 * Purpose: When FDA Click the customer visited button on the phone search page. An FDA Visited Type Appointment shall be created.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
public class FDAAppCreationController {

    public String oppID { get;set; }

    public void initialization() {

        oppID = ApexPages.CurrentPage().getparameters().get('ID');
        Opportunity opp = [SELECT Intended_City__c, AccountId 
                           FROM Opportunity 
                           WHERE Id = :oppID 
                           LIMIT 1];
        generateInvitiation(opp);
    }

    private void generateInvitiation (Opportunity opp) {

        Appoitment__c app = new Appoitment__c ();
        app.Opportunity__c = opp.Id; 
        app.Intended_City__c = opp.Intended_City__c; 
        app.Account__c = opp.AccountId; 
        app.Status__c = Constants.APP_FOLLOWING; 
        app.Duration__c = '0.5'; 
        app.recordTypeID = Constants.APP_RT_FDA_VISITED_ID;
        app.sys_unlock_app__c = true;
        app.Appointment_Type__c = Constants.APP_FDA_TYPE_CN;

        insert app;
    }
}