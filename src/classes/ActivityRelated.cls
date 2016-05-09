/**************************************************************************************************
 * Name: ActivityRelated
 * Object: Account
 * Purpose: A universal class for operations of Appointment object
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-11-25
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
global without Sharing  class ActivityRelated {

    // Generates Task alert
    public static Task generateTaskAlert(String content,
                                         String des,
                                         String userid,
                                         Datetime reminderdatetime,
                                         Date dueDate,
                                         String relatedto) {
        Task tazk = new Task ();
        tazk.ActivityDate = dueDate;
        tazk.IsReminderSet = true;
        tazk.OwnerId = userid;
        tazk.Priority = 'Normal';
        tazk.ReminderDateTime = reminderdatetime;
        tazk.Status = 'Open';
        tazk.WhatId = relatedto;
        tazk.Subject = content;
        tazk.Description__c = des;
        return tazk;
    }

    // Generates appointments' name
    public static String generateActivityName (Appoitment__c app) {
        String apptype = app.Appointment_Type__c;
        Datetime dutime = app.sys_DueTime__c == null ? System.Now() : app.sys_DueTime__c;
        String head = app.Opportunity__c != null ? app.Opportunity__r.Account.Name : app.Lead__r.Name; 
        String year = String.valueOf(dutime.year());
        String month = String.valueOf(dutime.month());
        String day = String.valueOf(dutime.day());
        String hour = String.valueOf(dutime.hour());
        String min = String.valueOf(dutime.minute());

        return head + ' | ' +
               apptype + ' | ' +
               year + '.' +
               month + '.' +
               day + ' ' +
               hour + ':' +
               min;
    }

    // Gets record Types' Chinese name according to the RecordTypeID
    public static String generateChinseName (String recordType) {

        if (recordType == RecordTypeRelated.Invitation_App) return Constants.APP_INVITATION;
        else if (recordType == RecordTypeRelated.Assignment_App) return Constants.APP_ASSIGNMENT;
        else if (recordType == RecordTypeRelated.Reminder_App) return Constants.APP_REMINDER;
        else return '';
    }

    // Updates Assignment's status to expired
    public static void  cancelAssignment (Set<ID> oppIDs) {

        List<Appoitment__c> existingAssList = [SELECT Status__c, Id, sys_unlock_app__c
                                               FROM Appoitment__c
                                               WHERE Opportunity__c IN :oppIDs
                                               AND RecordTypeID = :RecordTypeRelated.Assignment_App
                                               AND (not Status__c IN (:Constants.APP_COMPLETED,
                                                                      :Constants.APP_COMPLETED_DELAY,
                                                                      :Constants.APP_EXPIRED))];

        for (Appoitment__c apment : existingAssList) {
            apment.Status__c = Constants.APP_EXPIRED;
            apment.sys_unlock_app__c = true;
        }

        if ( existingAssList.size() > 0) {
            update existingAssList;
        }
    }

    // Generates Assignments by parameters
    webservice static void generetaAssignment (String type, String ownerid, String oppid) {

       HolidaySkippingRelated holidaycheck = new HolidaySkippingRelated ();
       if (duplicateAssigment(type,oppid) == 0) {

          Datetime dtt = System.Now();
          Appoitment__c app = new Appoitment__c ();
          app.Appointment_Type__c = type;
          app.Due_Date__c = holidaycheck.jumpHoliday(getdutedatefoAssignment(type, oppid));
          app.Opportunity__c = oppid;
          app.RecordTypeId = RecordTypeRelated.Assignment_App;
          app.OwnerId = ownerid;
          app.Assign_To__c = app.Appointment_Type__c == Constants.APP_FIFTH_DAY_ASS ?
                                                        getManagerOwnerID(oppid) :
                                                        ownerid;

          insert app;
       }
    }

    // Generates 3,5,7 assignments after user click accept opportunity button
    webservice static void genereta0357 (String ownerid, String oppid) { 
        generetaAssignment(Constants.APP_THIRD_DAY_ASS, ownerid, oppid);
        generetaAssignment(Constants.APP_FIFTH_DAY_ASS, ownerid, oppid);
        generetaAssignment(Constants.APP_SEVENTH_DAY_ASS, ownerid, oppid);
    }

    /* Verifies the new Invitation button permission.
       Returns 1 means: the user can add invitation directly without more condition.
       Returns 2 means: the user have the invitation creation permission,
       but the opportunity status will be checked again in the JS button logic. */
    webservice static Integer appointmentButton (ID oppID) {

        Opportunity opp= [SELECT Id,
                                 sys_isSameBusinessCity__c,
                                 AccountId,
                                 IsXueYou__c
                          FROM Opportunity 
                          WHERE Id = :oppID 
                          LIMIT 1][0];
        Set<ID> oppuserIDs = new Set<ID> ();

        for (OpportunityTeamMember oteam : [SELECT UserId, OpportunityID
                                            FROM OpportunityTeamMember
                                            WHERE OpportunityID IN (SELECT ID
                                                                    FROM Opportunity
                                                                    WHERE AccountId = :opp.AccountId)]) {
            oppuserIDs.add(oteam.UserId);
        }

        // Checks the user have edit permission on the record
        Boolean editPerms = checkEditPermissoin(oppID);

        // TMKs can't add new Invitation on Opportunity, If another TMK already add a Invitation within 7 days.
        Datetime dt = System.Now();
        dt = dt.addDays(-7);
        List<Appoitment__c> apps = [SELECT Id 
                                    FROM Appoitment__c
                                    WHERE Opportunity__c = :opp.Id
                                    AND CreatedBy.ProfileID IN :ProfileRelated.getTMKCallCenterSet()
                                    AND CreatedByID != :userinfo.getUserId()
                                    AND recordTypeID = :RecordTypeRelated.Invitation_App
                                    AND CreatedDate >= :dt];

        // Checks the user profile is a TMK or not
        Boolean istmkcs = ProfileRelated.getTMKCallCenterSet().contains(UserInfo.getProfileId());

        // Checks the user is a local customer server or not
        Boolean isLocalCS = ProfileRelated.getLocalCSSet().contains(UserInfo.getProfileId());

        // Check current user's department is XueYou, and the current Opportunity is XueYou or Not
        Boolean isHQxueyou = RoleRelated.XueYouRole().contains(userinfo.getUserRoleId()) && opp.IsXueYou__c;

        if ((istmkcs && apps.size() == 0) ||
            (isLocalCS && opp.sys_isSameBusinessCity__c) ||
            isHQxueyou) {

            return 1;
        } else if (oppuserIDs.contains(UserInfo.getUserId()) || editPerms) {

            return 2;
        }

        return 3;
    }
    // Verifies the new reminder permissions
    webservice static Integer Reminder_AppButton (ID oppID) {
        Opportunity opp = [SELECT Id, sys_isSameBusinessCity__c, IsXueYou__c 
                           FROM Opportunity 
                           WHERE id =: oppID limit 1][0];

        Set<ID> oppuserIDs = new Set<ID> ();

        for (OpportunityTeamMember oteam : [SELECT UserId, OpportunityID
                                            FROM OpportunityTeamMember
                                            WHERE OpportunityID = :oppID]) {
            oppuserIDs.add(oteam.UserId);
        }

        Boolean editPerms = checkEditPermissoin(oppID);
        Boolean istmkcs = ProfileRelated.getTMKCallCenterSet().contains(UserInfo.getProfileId());
        Boolean isLocalCS = ProfileRelated.getLocalCSSet().contains(UserInfo.getProfileId());
        Boolean isFDA = ProfileRelated.getFDAProfileSet().contains(UserInfo.getProfileId());
        Boolean isHQxueyou = RoleRelated.XueYouRole().contains(userinfo.getUserRoleId()) && opp.IsXueYou__c;

        if (istmkcs ||
            ((isLocalCS || isFDA) && opp.sys_isSameBusinessCity__c) ||
            isHQxueyou) {

            return 1;
        } else if (oppuserIDs.contains(UserInfo.getUserId()) || editPerms) {

            return 2;
        }

        return 3;
    }

    // Calculates the due date for assignment
    private static Date getdutedatefoAssignment (String types, String oppID) {

        Datetime dt = System.Now();
        Date td = System.Today();

        String query = 'SELECT Id, Due_Date__c ' +
                       'FROM Appoitment__c ' +
                       'WHERE Status__c!=\'' + Constants.APP_EXPIRED + '\' ' +
                       'AND Opportunity__c=:oppID ';

        if (types.contains('0') || types.contains('3')) {
          query += ' AND Appointment_Type__c=\'' + Constants.APP_FIRST_DAY_ASS + '\' ';
        } else if (types.contains('5')) {
          query += ' AND Appointment_Type__c=\'' + Constants.APP_THIRD_DAY_ASS + '\' ';
        } else if (types.contains('7')) {
          query += ' AND Appointment_Type__c=\'' + Constants.APP_FIFTH_DAY_ASS + '\' ';
        }

        query += 'Order by CreatedDate DESC';

        List<Appoitment__c> app = Database.query(query);

        if (app.size() >= 1) {

          Date dd = app[0].Due_Date__c;

          if (types.contains('3')) return dd.addDays(3);
          else if (types.contains('5')) return dd.addDays(2);
          else if (types.contains('7')) return dd.addDays(2);
          else return dt.hour() >= 18 ? td.addDays(1) : system.today();
        } else return dt.hour() >= 18 ? td.addDays(1) : system.today();
    }

    private static Integer duplicateAssigment (String type, String oppid) {

        List<Appoitment__c> apps = [SELECT Id
                                    FROM Appoitment__c
                                    WHERE Opportunity__c = :oppid
                                    AND Status__c = :Constants.APP_UNCOMPLETED
                                    AND RecordTypeID = :RecordTypeRelated.Assignment_App
                                    AND Appointment_Type__c = :type];
        return apps.size();
    }

    // Gets the fifth day assignment's manager ID
    private static String getManagerOwnerID (ID oppID) {

        String oppOffice = 'N/A';

        Opportunity opp = [SELECT RecordType.DeveloperName,
                                  OwnerId,
                                  Intended_City__c,
                                  Department__c,
                                  Project__c,
                                  Owner.Role_Office_CN__c,
                                  Owner.DeveloperName_Org__c 
                           FROM Opportunity 
                           WHERE Id = :oppID];

        if (opp.Owner.Role_Office_CN__c != null && 
            opp.Owner.Role_Office_CN__c != '') {

            oppOffice = opp.Owner.Role_Office_CN__c;
        }

        if (opp.RecordType.DeveloperName == 'Counselling') {

            List<Organization__c> org= [SELECT OwnerId,
                                               City__c,
                                               RecordType.DeveloperName,
                                               Project__c,Task5_Manager__c,
                                               haveSubGroup__c
                                        FROM Organization__c
                                        WHERE RecordType.DeveloperName = 'Counselling'
                                        AND City__c = :opp.Intended_City__c
                                        AND City__c != ''
                                        AND Office__c = :oppOffice
                                        AND Project__c INCLUDES (:opp.Project__c)];
            if (org.size() > 0) {

                if (org[0].Task5_Manager__c != null &&
                    org[0].haveSubGroup__c == false) {

                    Return org[0].Task5_Manager__c;
                } else if (org[0].haveSubGroup__c) {
                    if (opp.owner.DeveloperName_Org__c != null) {

                        List<Organization__c> suborg = [SELECT Task5_Manager__c,
                                                               requireHigherApprover__c,
                                                               Parent_Organization__r.Task5_Manager__c
                                                        FROM Organization__c 
                                                        WHERE Parent_Organization__c = :org[0].ID 
                                                        AND DeveloperName__c = :opp.owner.DeveloperName_Org__c];

                        if (suborg.size() > 0) {

                            if (!suborg[0].requireHigherApprover__c || suborg[0].Task5_Manager__c != opp.OwnerId) {

                               Return suborg[0].Task5_Manager__c != null ? suborg[0].Task5_Manager__c : opp.OwnerId;
                            } else {

                               Return suborg[0].Parent_Organization__r.Task5_Manager__c != null ? 
                                   suborg[0].Parent_Organization__r.Task5_Manager__c :
                                   opp.OwnerId;
                            }
                        } else {

                            Return org[0].Task5_Manager__c != null ? org[0].Task5_Manager__c : opp.OwnerId;
                        }
                    }
                }
            }
        }

        return opp.OwnerId;
    }

    // Mass generates 1st day assignments
    public static void generateAssignmentBulk (List<Opportunity> opps) {
        List<Appoitment__c> apps = new List<Appoitment__c> ();
        Map<ID, Boolean> exitingAssignment = getexitingAssignment(opps);
        Datetime dt = System.Now();
        Date td = System.Today();
        HolidaySkippingRelated holidaycheck = new HolidaySkippingRelated ();

        for (Opportunity opp : opps) {

            if (exitingAssignment.get(opp.Id) == null&&
                opp.OwnerId != userinfo.getUserId()) {

                Appoitment__c app = new Appoitment__c ();
                app.Appointment_Type__c = Constants.APP_FIRST_DAY_ASS;
                app.Due_Date__c = holidaycheck.jumpHoliday(dt.hour() >= 18 ? td.addDays(1) : td);
                app.Opportunity__c = opp.Id;
                app.RecordTypeId = RecordTypeRelated.Assignment_App;
                app.OwnerId = opp.OwnerID;
                app.Assign_To__c = opp.OwnerID;
                apps.add(app);
            }
        }

        insert apps;
    }

    // Gets all existing assignments on opportunities
    private static Map<ID, Boolean>  getexitingAssignment (List<Opportunity> opps) {

        Set<ID> oppids = new Set<ID> ();
        Map<ID, Boolean> oppAppTypMap= new Map<ID, Boolean> ();

        for (Opportunity opp : opps) {
            oppids.add(opp.Id);
        }

        for (Appoitment__c app : [SELECT Id, Appointment_Type__c, Opportunity__c 
                                  FROM Appoitment__c
                                  WHERE Opportunity__c IN : oppids
                                  AND Appointment_Type__c = :Constants.APP_FIRST_DAY_ASS
                                  AND Status__c = :Constants.APP_UNCOMPLETED
                                  AND RecordTypeID = :RecordTypeRelated.Assignment_App]) {

            oppAppTypMap.put(app.Opportunity__c, true);
        }

        return oppAppTypMap;
    }

    public static void recalculateappShare (Set<ID> accountIDs) {

        Map<ID, ID> appAccoutMap = new Map<ID, ID> ();

        for (Appoitment__c app : [SELECT Id, Account__c
                                  FROM Appoitment__c
                                  WHERE Opportunity__c = null
                                  AND Account__c IN :accountIDs]) {

            appAccoutMap.put(app.Id, app.Account__c);
        }

        if (appAccoutMap.size() > 0) CommonHelperClass.shareTmkAppstoAccountgroup(appAccoutMap, accountIDs);
    }
    
    // Changes appointments' owner ship after the opportunity owner changed.
    public static void changeappsOwner (Set<ID> oppIDs) {

        List<Appoitment__c> apps = new List<Appoitment__c> ();
        Set<String> validStatus = new Set<String> ();
        validStatus.add(Constants.APP_UNCOMPLETED);
        validStatus.add(Constants.APP_FOLLOWING);

        for (Appoitment__c app : [SELECT OwnerID,
                                         Opportunity__c ,
                                         Opportunity__r.OwnerId, 
                                         Status__c,Assign_To__c,
                                         sys_DueTime__c
                                  FROM Appoitment__c 
                                  WHERE Opportunity__c IN :oppIDs
                                  AND RecordTypeID != :RecordTypeRelated.FrontDeskVisit_App]) {

            if (app.OwnerId != app.Opportunity__r.OwnerId) {

                app.OwnerId = app.Opportunity__r.OwnerId;
                Boolean isfuture =  app.sys_DueTime__c == null ? true : app.sys_DueTime__c >= System.Now();

                if (validStatus.contains(app.Status__c) &&
                    app.RecordTypeId != RecordTypeRelated.Assignment_App &&
                    isfuture) {
                    app.Assign_To__c = app.Opportunity__r.OwnerId;
                }

                app.sys_unlock_app__c = true;
                apps.add(app);
            }
        }

        update apps;
    }

    public static boolean checkEditPermissoin (Id OppID) {
       return [SELECT RecordId, HasEditAccess 
               FROM UserRecordAccess
               WHERE UserId = :UserInfo.getUserId()
               AND RecordId = :OppID][0].HasEditAccess;
    }
}