/**************************************************************************************************
 * Name: AppointmentTriggerBeforeInsert
 * Object: Appointment__c
 * Purpose: 
 * Author:  ()
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
global class AppointmentTriggerHelper {

    // Auto generate activity before trigger
    public static void beforeUpdateOrInsert (List<Appoitment__c> triggerAppointments) {

        for (Appoitment__c appointment : triggerAppointments) {
            if (appointment.Operation_User__c == null && appointment.Follow_Up_Date__c != null) {
                appointment.Operation_User__c = userinfo.getUserId();
            }
        }
    }

    // Auto generate activity after trigger
    public static void afterUpdateOrInsert (List<Appoitment__c> triggerAppointments, Boolean isInsert) {

        Set<ID> appids = new Set<ID> ();
        List<Appoitment__c> applist = new List<Appoitment__c> ();
        List<Task> tasks = new List<Task> ();
        List<Event> evnts = new List<Event> ();
        Map<ID, Map<ID, String>> appUserPermissions = new Map<ID, Map<ID, String>> ();
        Map<ID, ID> tmkAppPermissions = new Map<ID, ID> ();
        Set<ID> tmkAccIDs = new Set<ID> ();
        List<Appoitment__c> nextapps =new List<Appoitment__c> ();
        Set<ID> cancelAssOppIDs = new Set<ID> ();
        List<Appoitment__c> appresore = new List<Appoitment__c> ();
        Set<ID> apprestoreIDS = new Set<ID> ();
        List<Opportunity> oppNextShowlist = new List<Opportunity> ();
        List<Opportunity> oppNextApplist = new List<Opportunity> ();
        Set<ID> appOppIDs = new Set<ID> ();
        Set<ID> inviAppoppIDs = new Set<ID> ();

        for (Appoitment__c app: triggerAppointments) {

            appids.add(app.Id);
            appOppIDs.add(app.Opportunity__c);
            Map<ID, String> userPermisisons = new Map<ID, String> ();

            if (app.CreatedById != app.OwnerId && app.CreatedById != app.Assign_To__c)
                userPermisisons.put(app.CreatedById, 'read');

            if (app.Assign_To__c != app.OwnerId && app.Assign_To__c != null)
                userPermisisons.put(app.Assign_To__c, 'edit');
                appUserPermissions.put(app.Id, userPermisisons);

            if (app.Account__c != null && app.Opportunity__c == null) {
                tmkAppPermissions.put(app.Id, app.Account__c);
                tmkAccIDs.add(app.Account__c);
            }

            if (app.next_follow_up_date__c != null) {
                Appoitment__c newapp = new Appoitment__c ();
                newapp.RecordTypeId = RecordTypeRelated.Reminder_App;
                newapp.Due_Date__c = app.next_follow_up_date__c;
                newapp.Assign_To__c = Userinfo.getUserId();
                newapp.OwnerId = Userinfo.getUserId();
                newapp.Opportunity__c = app.Opportunity__c;
                newapp.Contact_Method__c = app.Contact_Method__c;
                nextapps.add(newapp);
            }

            if (app.next_show_up_date__c != null) {
                Appoitment__c newapp2 = new Appoitment__c ();
                newapp2.RecordTypeId = RecordTypeRelated.Invitation_App;
                newapp2.Opportunity__c = app.Opportunity__c;
                newapp2.Contact_Method__c = app.Contact_Method__c;
                newapp2.Assign_To__c = userinfo.getUserId();
                newapp2.Due_Date__c = app.next_show_up_date__c;
                newapp2.Due_Time__c = app.next_show_up_time__c;
                newapp2.Intended_City__c = app.Intended_City__c;
                newapp2.Duration__c = app.Duration__c == null ? '30' : app.Duration__c;
                newapp2.OwnerId = Userinfo.getUserId();
                nextapps.add(newapp2);
            }

            if (app.Cancel_Assignments__c == true) {
                cancelAssOppIDs.add(app.Opportunity__c);
            }

            if (app.next_follow_up_date__c != null || app.next_show_up_date__c != null) {
                apprestoreIDS.add(app.Id);
            }
        }

        for (Appoitment__c app : [SELECT next_follow_up_date__c, next_show_up_date__c, next_show_up_time__c
                                  FROM Appoitment__c 
                                  WHERE Id IN :apprestoreIDS]) {

            app.next_follow_up_date__c = null;
            app.next_show_up_date__c = null;
            app.next_show_up_time__c = '';
            appresore.add(app);
        }

        if (appresore.size() > 0) {
            update appresore;
        }

        if (cancelAssOppIDs.size() > 0) {

            List<Appoitment__c> cancelAssignments = new List<Appoitment__c> ();
            for (Appoitment__c app : [SELECT Id, status__c
                                      FROM Appoitment__c
                                      WHERE Opportunity__c IN : cancelAssOppIDs
                                      AND status__c = '未完成'
                                      AND Due_Date__c > :System.Today()
                                      AND RecordTypeID = :RecordTypeRelated.Assignment_App]) {

                app.Status__c = '已失效';
                cancelAssignments.add(app);
            }

            if (cancelAssignments.size() > 0) {
                update cancelAssignments;
            }
        }

        if (nextapps.size() > 0) {
            insert nextapps;
        }

        if (isInsert) {
            for (Appoitment__c app : [SELECT Id,
                                             Appointment_Type__c,
                                             CreatedDate,
                                             RecordType.Name,
                                             CreatedBy.Name,
                                             Name,
                                             Assign_To__c,
                                             Assign_To__r.Name,
                                             Account__r.Name,
                                             Due_Date__c,
                                             Due_Time__c,
                                             CreatedBy.Profile.Name,
                                             CreatedBy.City_of_Role__c,
                                             Opportunity__r.Account.Name,
                                             RecordTypeId,
                                             CreatedById,
                                             Duration__c,
                                             sys_Due_Date_Time__c,
                                             sys_DueTime__c,
                                             Description__c,
                                             OwnerId,
                                             sys_unlock_app__c,
                                             Opportunity__r.OwnerId,
                                             Opportunity__r.AccountId,
                                             Opportunity__c,
                                             Opportunity__r.sys_isvisted__c,
                                             Account__c,
                                             next_follow_up_date__c,
                                             next_show_up_date__c,
                                             next_show_up_time__c,
                                             Lead__c,
                                             Lead__r.Name
                                      FROM Appoitment__c
                                      WHERE ID IN: appids]) {

                if (app.Opportunity__c != null) {

                    app.OwnerId = app.RecordTypeId != RecordTypeRelated.FrontDeskVisit_App ?
                                                    app.Opportunity__r.OwnerId :
                                                    app.OwnerId;
                    app.Account__c = app.Opportunity__r.AccountId;
                    if (app.RecordTypeId == RecordTypeRelated.Invitation_App) {
                        app.Appointment_Type__c = app.Opportunity__r.sys_isvisted__c == false ?
                                                                                      '首次到访邀约' :
                                                                                      '再次到访邀约';
                        inviAppoppIDs.add(app.Opportunity__c);
                    }
                }

                app.name = ActivityRelated.generateActivityName(app);
                app.sys_isCreatedByCS__c = app.CreatedBy.Profile.Name.contains('客服') ||
                                           app.CreatedBy.Profile.Name.contains('呼叫');
                app.sys_CreateByCity__c = app.CreatedBy.City_of_Role__c == null ? '' : app.CreatedBy.City_of_Role__c;
                app.sys_unlock_app__c = true;
                applist.add(app);

                if (app.RecordTypeID == RecordTypeRelated.Invitation_App) {

                    Event evnt = new Event ();
                    evnt.Description = app.Description__c;
                    evnt.WhatId = app.Id;
                    evnt.StartDateTime = app.sys_DueTime__c == null ? System.Now() : app.sys_DueTime__c;
                    evnt.OwnerId = app.Assign_To__c;
                    evnt.IsReminderSet = true;
                    evnt.DurationInMinutes = Integer.valueOf(Decimal.valueOf(app.Duration__c) * 60);
                    evnt.ReminderDateTime = evnt.StartDateTime.addMinutes(-30);
                    evnt.Subject = '邀约';
                    evnts.add(evnt);
                } else if (app.RecordTypeID == RecordTypeRelated.Reminder_App ||
                           app.RecordTypeID == RecordTypeRelated.Assignment_App) {

                    Task tazk = new Task ();
                    String tazkType = app.RecordTypeId == RecordTypeRelated.Reminder_App ? '提醒' : '任务';
                    String Subject = app.CreatedBy.Name + '创建了一条' + tazkType;
                    tazk = ActivityRelated.generateTaskAlert(Subject, '', app.Assign_To__c, app.sys_DueTime__c, app.Due_Date__c, app.Id);
                    tasks.add(tazk);
                }
            }

            if (evnts.size() > 0) insert evnts;
            if (tasks.size() > 0) insert tasks;
            update applist;
        }

        if (appUserPermissions.size() > 0)

            // Shares the appointments to assign to user and the created by user
            CommonHelperClass.createManuallyAppShareRule(appUserPermissions);
        if (tmkAppPermissions.size() > 0)
            CommonHelperClass.shareTmkAppstoAccountgroup(tmkAppPermissions, tmkAccIDs);

        if (isInsert) {
            for (AggregateResult art : [SELECT MIN(sys_DueTime__c) myMin, Opportunity__c
                                        FROM Appoitment__c
                                        WHERE Due_Date__c > :System.Today()
                                        AND (RecordTypeID = :RecordTypeRelated.Reminder_App OR
                                             RecordTypeID = :RecordTypeRelated.Assignment_App)
                                        AND Status__c IN ('未完成', '跟进中')
                                        AND Opportunity__c IN :appOppIDs
                                        AND Opportunity__c != NULL
                                        Group BY Opportunity__c]) {

                Opportunity opp = new Opportunity ();
                opp.Id = String.valueOf(art.get('Opportunity__c'));
                opp.mig_CCNextAppTime__c = Datetime.valueOf(art.get('myMin'));
                oppNextApplist.add(opp);
            }

            if (oppNextApplist.size() > 0) {
                update oppNextApplist;
            }
        }
    }

    public static void appointmentVistiedTimesCheck (List<Appoitment__c> triggerAppointments) {

        if (!TriggerShouldRun.AppointmentShouldRun) {
          return;
        }

        Set<ID> inviationoppIDs = new Set<ID> (); // appointments id Set for collect all invitation or FDA type records
        Map<ID, Decimal> oppVistiedAppNum = new Map<ID, Decimal> (); // the existing invitation apps' visited times of each Opp
        Map<ID, Decimal> FDAAppNum = new Map<ID, Decimal> (); // the existing FDA apps' visited times of each Opp
        Set<ID> firstShowOppID = new Set<ID> (); // collect Id of these opps whose visited times is null
        List<Opportunity> opplist = new List<Opportunity> (); // opp list which shall be updated after DML

        // Gets all invitation and FDA Visited appointments
        for (Appoitment__c app : triggerAppointments) {
            if (app.Status__c == '已到访' || app.RecordTypeId == RecordTypeRelated.FrontDeskVisit_App) {
                inviationoppIDs.add(app.Opportunity__c);
            }
        }

        // 1.get the invitation appointments existing visited times
        // 2.get the FDA existing appointments visited times
        for (Appoitment__c app : [SELECT Id, Visited_Times__c, Opportunity__c, RecordTypeID
                                  FROM Appoitment__c
                                  WHERE Opportunity__c IN : inviationoppIDs]) {

            if (app.RecordTypeID == RecordTypeRelated.Invitation_App) {

                Decimal viistedTimes = oppVistiedAppNum.get(app.Opportunity__c) == NULL ? 0 : oppVistiedAppNum.get(app.Opportunity__c);
                viistedTimes ++;
                oppVistiedAppNum.put(app.Opportunity__c, viistedTimes);
            } else if (app.RecordTypeID == RecordTypeRelated.FrontDeskVisit_App) {

                Decimal viistedTimes = FDAAppNum.get(app.Opportunity__c) == NULL ? 0 : FDAAppNum.get(app.Opportunity__c);
                viistedTimes ++;
                FDAAppNum.put(app.Opportunity__c, viistedTimes);
            }
        }

         // 1. update the invitation appointments visited times and the FDA appointments visited times
         // 2. calculate the opportunity first show times
         for (Appoitment__c app : triggerAppointments) {

            if (app.RecordTypeId == RecordTypeRelated.Invitation_App && app.Status__c == '已到访' ) {
                app.Visited_Times__c = oppVistiedAppNum.get(app.Opportunity__c) == NULL ? 1 : oppVistiedAppNum.get(app.Opportunity__c);
            }

            if (app.RecordTypeId == RecordTypeRelated.FrontDeskVisit_App) {
                app.Visited_Times__c = FDAAppNum.get(app.Opportunity__c) == NULL ? 1 : FDAAppNum.get(app.Opportunity__c);
                if (app.Visited_Times__c == 1) firstShowOppID.add(app.Opportunity__c);
            }
         }

         // Updates all opps
         for (Opportunity opp :[SELECT Id, First_Show_DateTime__c
                                FROM Opportunity
                                WHERE Id IN : firstShowOppID
                                AND First_Show_DateTime__c = null]) {
            opp.First_Show_DateTime__c= System.Now();
            opplist.add(opp);
         }

         update opplist;
    }
}