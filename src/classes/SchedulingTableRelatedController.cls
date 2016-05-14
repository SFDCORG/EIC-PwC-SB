/**************************************************************************************************
 * Name: SchedulingTableRelatedController
 * Object: Scheduling_Table_Line__c
 * Purpose: 
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-12
 * Modify History:
 * 2016-05-12    Vicia Wang    Create this class
 **************************************************************************************************/
global class SchedulingTableRelatedController {
    public static ID  AssginOppOwnertoSchedulingTabline(ID schedulingTablineID, Opportunity opp) {
        Scheduling_Table_Line__c schTabLin= [ SELECT User__r.ID, 
                                              Monthly_Opportunities__c,
                                              Daily_Opportunities__c,
                                              Scheduling_Table__c,
                                              Compensation_Opportunity_Num__c 
                                              FROM Scheduling_Table_Line__c 
                                              WHERE id = :schedulingTablineID limit 1];

        ID userID = schTabLin.User__r.id;
        opp.OwnerId = userID;
        System.debug('opp'+opp);

        OpportuinityRelatedController.updateOpp(opp);
        Boolean results = SchedulingTableLineOppNumIncrease(schTabLin); 
        SchedulingTableOrderCountIncrease(schTabLin);

        return userID;
    }

    private static boolean SchedulingTableLineOppNumIncrease(Scheduling_Table_Line__c schTabLin){
        schTabLin.Monthly_Opportunities__c = schTabLin.Monthly_Opportunities__c == null ? 
            1 : ++schTabLin.Monthly_Opportunities__c;
        schTabLin.Daily_Opportunities__c = schTabLin.Daily_Opportunities__c == null ? 
            1 : ++schTabLin.Daily_Opportunities__c;

        if (schTabLin.Compensation_Opportunity_Num__c != null 
                && schTabLin.Compensation_Opportunity_Num__c > 0) {
            schTabLin.Compensation_Opportunity_Num__c--;

            List<Scheduling_Table_Order__c> scheo = [SELECT User__c, Total_Count__c, Compensate_Number__c
                                                     FROM Scheduling_Table_Order__c
                                                     WHERE Scheduling_Table__c = :schTabLin.Scheduling_Table__c
                                                     AND User__c = :schTabLin.User__c
                                                     And Compensate_Number__c > 0
                                                     ORDER BY Total_Count__c, Order__c ASC LIMIT 1];
            if (scheo.size() == 1) {
                scheo[0].Compensate_Number__c--;
                update scheo[0];
            }
        }

        return updateSchedulingTabline(schTabLin);
    }

    private static void SchedulingTableOrderCountIncrease( Scheduling_Table_Line__c schTabLin) {
        List<Scheduling_Table_Order__c> scheTabOrder = [SELECT Count__c, Id, Scheduling_Table__c 
                                                        FROM Scheduling_Table_Order__c 
                                                        WHERE User__c =:schTabLin.User__c 
                                                        AND Scheduling_Table__c =:schTabLin.Scheduling_Table__c 
                                                        Order By Count__c, Order__c];
       
        if (scheTabOrder.size() > 0) {
            if (scheTabOrder[0].Count__c == null) {
                scheTabOrder[0].Count__c = 1;
            }
            else {
                scheTabOrder[0].Count__c++;
            }

          Boolean results = updateSchedulingTabOrder(scheTabOrder[0]);
       }
    }

    private static boolean updateSchedulingTabOrder(Scheduling_Table_Order__c scheTabOrder) {
        try { 
            update scheTabOrder;
            SchedulingTableOrderRelated.IndicatorOrder(scheTabOrder.Scheduling_Table__c);
        }
        Catch (Exception e) {
            return false;
        }

        return true;
    }
 
    private static boolean updateSchedulingTabline(Scheduling_Table_Line__c schTabLin) {
        try {
            update schTabLin;
        }
        catch (Exception e) {
            return false;
        }
        
        return true;
    }

    public static List<Scheduling_Table_Line__c> queryLine(ID existSchedTableID) {
        return [SELECT Id, Name,
                      Monthly_Opportunities__c, 
                      Daily_Opportunities__c, 
                      Business_Line__c,
                      City__c,
                      Office__c, 
                      Department__c,
                      Source__c,
                      Project__c,
                      Scheduling_Table__c,
                      User__c,
                      User__r.Name, 
                      isAvailableToday__c,
                      Start_Working_Time__c,
                      End_Working_Time__c,
                      Monday_Time__c,
                      Tuesday_Time__c,
                      Wednesday_Time__c,
                      Thursday_Time__c,
                      Friday_Time__c,
                      Saturday_Time__c,
                      Sunday_Time__c
                FROM Scheduling_Table_Line__c 
                WHERE Scheduling_Table__c = : existSchedTableID];
    }

    public static void updateScheduleOrderIndicator(ID existSchedTableID) {
        List<Scheduling_Table_Order__c> indicators = [SELECT Indicator__c,ID 
                                                      FROM Scheduling_Table_Order__c
                                                      WHERE Scheduling_Table__c = :existSchedTableID
                                                      ORDER BY Count__c, Order__c];

        for (Integer i = 0; i < indicators.size(); i++) {
            if (i == 0) {
                indicators[i].Indicator__c = true;
            }
            else {
                indicators[i].Indicator__c = false;         
            }
        }

        update indicators;
    }


    public static void generateTableCheckRecords(String schedluingTableID) {
        List<Scheduling_Table__c> schedulingTableLineList = [SELECT Id, Source__c, Project__c 
                                                             FROM Scheduling_Table__c 
                                                             WHERE ID = :schedluingTableID];

        if (schedulingTableLineList.size() > 0) {
            List<String> sourcelist = String.isBlank(schedulingTableLineList[0].Source__c) ?
                new List<String>() : schedulingTableLineList[0].Source__c.split(';');
            List<String> projectList= String.isBlank(schedulingTableLineList[0].Project__c) ? 
                new List<String>() : schedulingTableLineList[0].Project__c.split(';');
            List<Scheduling_Table_Check__c> scheCheckList = new List<Scheduling_Table_Check__c>();
            if (sourcelist.size() > 0 && projectList.size() > 0) {
                for (String source : sourcelist) {
                    for (String project : projectList) {   
                        Scheduling_Table_Check__c scheTablCheck = new Scheduling_Table_Check__c();
                        scheTablCheck.Source__c = source;
                        scheTablCheck.Scheduling_Table__c = schedluingTableID;
                        scheTablCheck.Project__c = project;
                        scheCheckList.add(scheTablCheck);
                    }
                }

                deleteCheckRecords(schedluingTableID);
                insert scheCheckList;
            }
        }
    }

    public static void deleteCheckRecords(String schedluingTableID) {
        List<Scheduling_Table_Check__c> deletedID = [SELECT id FROM Scheduling_Table_Check__c 
                                                     WHERE Scheduling_Table__c=:schedluingTableID];

        delete deletedID;
    }

    webservice static boolean checkTableEditCability(ID userid, ID tableID) {
        Scheduling_Table__c scheTable = [SELECT Organization__r.OwnerId,
                                             OwnerId, 
                                             Manager__c 
                                         FROM Scheduling_Table__c WHERE id = :tableID limit 1];

        Set<ID> visiablIDs = new Set<ID>();
        visiablIDs.add(scheTable.Organization__r.OwnerId);
        visiablIDs.add(scheTable.OwnerId);
        visiablIDs.add(scheTable.Manager__c);

        return visiablIDs.contains(userid) || 
            ProfileRelated.adminProfileSet().contains(ProfileRelated.getProfileIDofUser(userid));
    }


    webservice static void clearCompensation (ID tableID) {
        List<Scheduling_Table_Line__c> slines = new List<Scheduling_Table_Line__c>();
        List<Scheduling_Table_Order__c> sOrders = new List<Scheduling_Table_Order__c>();

        for (Scheduling_Table_Line__c schdTableline : [SELECT Id  
                                                       FROM Scheduling_Table_Line__c 
                                                       WHERE Scheduling_Table__c = :tableID]) {
            schdTableline.Compensation_Opportunity_Num__c = 0;
            slines.add(schdTableline);
        }

        for (Scheduling_Table_Order__c schdTableOrder : [SELECT Id 
                                                       FROM Scheduling_Table_Order__c 
                                                       WHERE Scheduling_Table__c = :tableID]) {
            schdTableOrder.Compensate_Number__c = 0;
            sOrders.add(schdTableOrder);
        }

        update slines;
        update sOrders;
    }


    webservice static void activeOrInactive(ID tableID, Boolean isactive) {
        Scheduling_Table__c schT = [SELECT id, isActive__c FROM Scheduling_Table__c WHERE id = :tableID limit 1];
        schT.isActive__c = isactive;
        update schT;
    }
}