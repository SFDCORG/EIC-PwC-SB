/**************************************************************************************************
 * Name: SchedulingTableOrderGenerationController
 * Object: Scheduling_Table_Order__c
 * Purpose: 
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modify History:
 * 2016-05-10   Vicia wANG     Create this class
 **************************************************************************************************/
public class SchedulingTableOrderGenerationController {
    public String schedulingTableOrderText {get; set;}
    public List<Scheduling_Table_Order__c> schedulingTableOrders {get; set;}
    public List<Scheduling_Table_Line__c>  schedulingTableLines {get; set;}
    public List<Scheduling_Table_Order__c> existingTableOrders {get; set;}
    public String textLine  {get; set;}
    public String schedulingTableID {get; set;}
    public String indexline {get; set;}
    
    private Set<ID> userInOrder;

    public SchedulingTableOrderGenerationController() {
        schedulingTableID = ApexPages.CurrentPage().getparameters().get('ID');
        schedulingTableOrderText = '';
        textLine = '';
        schedulingTableOrders = new List<Scheduling_Table_Order__c>();
        existingTableOrders = getexistingTableOrder();
        schedulingTableLines = getschedTablLines();
        initializationTextArea ();
        userInOrder = new Set<ID>();
    }
    
    public void expandRichBoxValue() {   
        schedulingTableOrderText = schedulingTableOrderText == '' ? 
          textLine : (schedulingTableOrderText + '\r\n' + textLine);
    }
   
    public PageReference generationOrder() {
        if (String.isBlank(schedulingTableOrderText)) {
            insertNewTableOrders();
            return new PageReference('/'+schedulingTableID);
        }

        String resultrt = prepareTableOrder(spliteText());
        if (resultrt == 'success') {
            insertNewTableOrders();
            recalculateOrderCount();
            SchedulingTableRelatedController.updateScheduleOrderIndicator(schedulingTableID);

            return new PageReference('/' + schedulingTableID);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, resultrt));
        }

        return null;
    }

    public pagereference cancel() {
        return new PageReference('/' + schedulingTableID);
    }

    private List<Scheduling_Table_Order__c> getexistingTableOrder() {
        return [
            SELECT User__r.Name, 
               User__r.Id,
               Indicator__c,
               Order__c,
               Count__c
            FROM Scheduling_Table_Order__c 
            WHERE Scheduling_Table__c = :schedulingTableID
            ORDER BY Order__c
        ];
    }

    private List<Scheduling_Table_Line__c> getschedTablLines() {
        return [
            SELECT User__r.Name, 
                User__r.Id,
                Project__c,
                Source__c,
                Scheduling_Table__c, 
                Monday_Time__c,Tuesday_Time__c,
                Wednesday_Time__c,Thursday_Time__c,
                Friday_Time__c,Saturday_Time__c,
                Sunday_Time__c 
            FROM Scheduling_Table_Line__c 
            WHERE Scheduling_Table__c = :schedulingTableID
        ];
    }

    private String prepareTableOrder(String[] spliteText) {
        schedulingTableOrders.clear();
        String userID = '';
        for (integer j = 0; j < spliteText.size(); j++) {  
            userID = translateUserNametoID(removeNewlineCharacter(spliteText[j]));
            if (userID != null) {
              Scheduling_Table_Order__c scheTablOrder = new Scheduling_Table_Order__c();
              scheTablOrder.Order__c = j+1;
              scheTablOrder.Scheduling_Table__c = schedulingTableID;
              scheTablOrder.sys_Fake_Tick__c = 0;
              scheTablOrder.User__c = userID;
              scheTablOrder.Count__c = 0;

              schedulingTableOrders.add(scheTablOrder);
              userInOrder.add(userID);
            } else {
                return '请检测第：'+ (j + 1) + '行, 无效用户';
            }   
        }

        return 'success';
    }
    
    private void clearExistingTableOrder() {
        SchedulingTableOrderRelated.DeleteExisingRecords(schedulingTableID);
    }

    private void insertNewTableOrders() {
        clearExistingTableOrder();
        SchedulingTableOrderRelated.insertNewRecords(schedulingTableOrders);
    }

    private String[] spliteText() {
        return schedulingTableOrderText.split('\r\n');
    }

    private String removeNewlineCharacter(String originalText) {
        originalText = originalText.replace('\r\n', '');
        originalText = originalText.replace('\n', '');
        originalText = originalText.replace('\r', '');
        originalText = originalText.trim();

        return originalText;
    }
    
    private String translateUserNametoID(String userName) {
        Map<String,ID> userNameIDMap = generateUserNameIDMap();
        return userNameIDMap.get(userName);
    }

    private Map<String,ID> generateUserNameIDMap() {
        Map<String,ID> userNameIDMap = new Map<String,ID>();
        for (Scheduling_Table_Line__c schline:schedulingTableLines) {
            userNameIDMap.put(schline.User__r.Name, schline.User__r.ID);
        }

        return userNameIDMap;
    }

    private void initializationTextArea() {
        for (Integer i = 0; i < existingTableOrders.size(); i++) {
            schedulingTableOrderText = schedulingTableOrderText + existingTableOrders[i].User__r.Name;
            if (i < existingTableOrders.size() - 1) {
                schedulingTableOrderText = schedulingTableOrderText + '\r\n';
            }
        }
    }

    private void recalculateOrderCount() {
        Map<ID,Decimal> userCompensationOppNum = GETTableLineCompensationNum();
        Map<ID,Decimal> ordercount = new Map<ID,Decimal>();
        Map<ID,Decimal> orderUserNo = new Map<ID,Decimal>();

        List<AggregateResult> scheTabelOrder = [
            SELECT Count(ID) countnum, User__c 
            FROM Scheduling_Table_Order__c 
            WHERE Scheduling_Table__c = :schedulingTableID
            GROUP BY User__c
        ];

        for (AggregateResult asg : scheTabelOrder) {
            ordercount.put((ID)asg.get('User__c'), (Decimal)asg.get('countnum'));
        }

        for (Scheduling_Table_Order__c scheorder:schedulingTableOrders) {
            if (userCompensationOppNum.get(scheorder.User__c) != null) {    
                Integer count = Integer.valueOf(ordercount.get(scheorder.User__c));
                Integer oppNum = Integer.valueOf(userCompensationOppNum.get(scheorder.User__c));

                Integer orderNo = Integer.valueOf(orderUserNo.get(scheorder.User__c) == null ? 
                    1 : orderUserNo.get(scheorder.User__c));

                scheorder.Count__c = scheorder.Count__c - Math.floor(oppNum / count);
                
                scheorder.Count__c = (orderNo <= math.mod(oppNum, count)) ? 
                    --scheorder.Count__c : scheorder.Count__c;

                orderUserNo.put(scheorder.User__c, ++orderNo);
            }
        }

        update schedulingTableOrders;
    }

    private Map<ID,Decimal> GETTableLineCompensationNum() {
        Map<ID,Decimal> userCompensationOppNum = new  Map<ID,Decimal>();   
        List<Scheduling_Table_Line__c> scheTablLines = [
            SELECT Id, Compensation_Opportunity_Num__c, User__c 
            FROM Scheduling_Table_Line__c 
            WHERE Scheduling_Table__c = :schedulingTableID
            AND Compensation_Opportunity_Num__c>0
            AND User__c in :userInOrder
        ];     
        for(Scheduling_Table_Line__c scheTablLine : scheTablLines) {
            userCompensationOppNum.put(scheTablLine.User__c,
                scheTablLine.Compensation_Opportunity_Num__c);
        }

        return userCompensationOppNum;
    }
}