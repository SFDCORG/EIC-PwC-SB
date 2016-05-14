/**************************************************************************************************
 * Name: SchedulingTableOrderRelated
 * Object: Scheduling_Table_Order__c
 * Purpose: 
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-12
 * Modify History:
 * 2016-05-12    Vicia Wang    Create this class
 **************************************************************************************************/
public class SchedulingTableOrderRelated {
    public static void insertNewRecords(List<Scheduling_Table_Order__c> schedulingTableOrders) { 
        try {
            insert schedulingTableOrders;
        }
        catch (DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public static void DeleteExisingRecords(ID schedulingTableID) {
        try {
            delete [Select id from Scheduling_Table_Order__c Where Scheduling_Table__c = :schedulingTableID];
        }
        catch (DmlException e) {
            ApexPages.addMessages(e);
       }
    }
  
    public static void updateScheTablOrderList(List<Scheduling_Table_Order__c> scheTablOrderList) {
        try {
            update scheTablOrderList;
        }
        catch (DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public static void oppcompensate(Boolean isGiveBack, ID userid, ID schedulingTableID) {
        Scheduling_Table_Line__c stl = [select Compensation_Opportunity_Num__c,User__c,ID 
            from Scheduling_Table_Line__c where Scheduling_Table__c = :schedulingTableID and User__c = :userid limit 1];
        if (isGiveBack) {
            stl.Compensation_Opportunity_Num__c = 
                stl.Compensation_Opportunity_Num__c == null ? 
                    1 : (stl.Compensation_Opportunity_Num__c+1);
            update stl;
        }
        else {
            Scheduling_Table_Order__c sto = [select Count__c, ID, sys_Fake_Tick__c from Scheduling_Table_Order__c 
                where Scheduling_Table__c = :schedulingTableID and User__c = :userid Order by Count__c, Order__c limit 1];
            sto.Count__c++;
            sto.sys_Fake_Tick__c = sto.sys_Fake_Tick__c == null ? 1 : ++sto.sys_Fake_Tick__c;
            update sto;
        }
    }

    public static void IndicatorOrder(String schetableID){
        List<Scheduling_Table_Order__c> minIndicatorOrder = [SELECT  Id, Count__c,
                                                                Indicator__C,Order__c
                                                             FROM Scheduling_Table_Order__c
                                                             WHERE Scheduling_Table__c = :schetableID
                                                             ORDER BY Count__c, Order__c];


        for (Integer i = 0; i < minIndicatorOrder.size(); i++) {
            minIndicatorOrder[i].Indicator__c = i == 0;
        }

        update minIndicatorOrder;
    }
}