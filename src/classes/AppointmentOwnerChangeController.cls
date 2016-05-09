/**************************************************************************************************
 * Name: AppointmentOwnerChangeController
 * Object: Account
 * Purpose: Batch change fithday/sixthday assignment's assign to 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
public without sharing class AppointmentOwnerChangeController {

    public String  newOwnerID { get; set; } // the new user who been assigned as this batch opportunities' Owner
    public String  user { get; set; } // the user name is used to display the selected name in the search box
    public Boolean saveFlag { get; set; } // show the save button or not
    public Integer selectedRows { get; set; } // the selected opp number in the list view
    public Integer succcess { get; set; } // the number of opportunities which can be updated successfully in this batch
    private List<Opportunity> app_oppsList = new List<Opportunity> (); // the Opportunity owner change list for inserting first day assignments
    public Set<id> selectedAppIdSet = new Set<id> (); // all the app id which been selected in the list view
    private Map<Opportunity,id> oldUserOppMap = new Map<Opportunity,id> (); // get original [opp]-[opp ownerId] map
    private static final Set<String> appoitmentType = new Set<String> (); // define which opp status shall be hold, and not changed to '顾问跟进'   
    static {
        appoitmentType.add(Constants.APP_FIFTH_DAY_ASS);
        appoitmentType.add(Constants.APP_SIXTH_DAY_ASS);
    }

    // Initializes the controller 
    public AppointmentOwnerChangeController (ApexPages.StandardSetController controller ) {
        newOwnerID = '';
        saveFlag = false;
        succcess = 0;
        user = userinfo.getName();
        newOwnerID = userinfo.getUserId();

        for (Appoitment__c app : (List<Appoitment__c>) controller.getSelected()) {
           selectedAppIdSet.add(app.Id);
        }

        if (selectedAppIdSet.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Constants.NO_ASSIGNMENT_SELECTED));
            return;
        }

        selectedRows = selectedAppIdSet.size();
        saveFlag = true;
    }

    // The save button action, when all selected appointments' assign to user is current user, the job can be success.
    public void AssignOwnerChange() {

        if (newOwnerID != '') {
            List<Appoitment__c> updateAppsList = NEW List<Appoitment__c> () ;
            for (Appoitment__c app: [SELECT Id
                                     FROM Appoitment__c 
                                     WHERE Appointment_Type__c IN :appoitmentType 
                                     AND Status__c = :Constants.APP_UNCOMPLETED
                                     AND Id IN :selectedAppIdSet
                                     AND Assign_To__c = :UserInfo.getUserId()]) {
                succcess ++;
            }

            // Variable success is to check the user have all selected records' permissions, 
            // Otherwise an error message will display
            succcess = profileRelated.adminProfileSet().contains(userinfo.getProfileId()) ? selectedRows : succcess;

            if (selectedRows == succcess) {
                changeAppAssignTo();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Constants.CHANGE_WITH_NO_ACCESS_APP));
            }

        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Constants.NO_SELECTED_ACCEPTOR));
        }
    }

    // Does the appointment update
    private void changeAppAssignTo() {

        List<Appoitment__c> updateApps = [SELECT Id, Assign_To__c
                                          FROM Appoitment__c
                                          WHERE Id IN :selectedAppIdSet];

        Map<Id, Id> oldAppIdAssignId = new Map<Id, Id> ();

        for (Appoitment__c app : updateApps) {
            oldAppIdAssignId.put(app.Id, app.Assign_To__c);
            app.Assign_To__c = newOwnerID;
        }

        if (updateApps.size() > 0) {

            update updateApps;
            generateManullyShare(oldAppIdAssignId);
        }
    }

    // Generates the manual share after owner change, manual share is a Salesforce standard share method,
    // Manual share is base on each records, It is different between sharing rule which is based on a specific rule
    private void generateManullyShare (Map<Id, Id> oldAppIdAssignId) {

        List<Appoitment__share> userPermisisons = new List<Appoitment__share> ();

        for (Appoitment__c app: [SELECT Id, Assign_To__c, OwnerId 
                                 FROM Appoitment__c 
                                 WHERE Id IN :selectedAppIdSet]) {

            if (app.Assign_To__c != app.OwnerId &&
                app.Assign_To__c != null &&
                app.Assign_To__c != oldAppIdAssignId.get(app.Id)) {

                Appoitment__share appShr = new Appoitment__share ();
                appShr.ParentId = app.Id;
                appShr.UserOrGroupId = app.Assign_To__c;
                appShr.AccessLevel = 'edit';
                appShr.RowCause = Schema.Appoitment__share.RowCause.Manual;
                userPermisisons.add(appShr);
            }
        }

        insert userPermisisons;
    }

    public PageReference cancel() {
        return new PageReference('/' + 'a0p');
    }
}