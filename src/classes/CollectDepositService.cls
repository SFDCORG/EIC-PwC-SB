/**************************************************************************************************
 * Name: CollectDepositService
 * Object: 
 * Purpose: 
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
global class CollectDepositService {

    private static Map<Integer, String> statusMap = new Map<Integer, String> {
        0 => '无定金',
        1 => '有定金',
        2 => '定金已使用',
        3 => '定金已退'
    };

    global static void updateDeposit(DepositWrapper deposit) {

        if (deposit != null) {

            List<Deposit__c> toInsertDepositList = new List<Deposit__c> ();
            List<Deposit__c> toUpdateDepositList = new List<Deposit__c> ();
            
            Map<String, Deposit> codeDepositMap = new Map<String, Deposit> ();
            if (deposit.Earnest_Money_List != null) {

                for (Deposit de : deposit.Earnest_Money_List) {

                    if (String.isNotBlank(de.Code)) {

                        codeDepositMap.put(de.Code, de);
                    }
                }
                System.debug(LoggingLevel.INFO, '*** codeDepositMap: ' + codeDepositMap);
                
                if (codeDepositMap.size() > 0) {

                    Map<String, Deposit__c> sfdcCodeDepositMap = new Map<String, Deposit__c> ();
                    for (Deposit__c d : [
                            SELECT Money__c,
                                   Money_Quit__c,
                                   Money_Use__c,
                                   Money_Lave__c,
                                   Opportunity__c,
                                   Payment_Date__c,
                                   Status__c,
                                   Earnest_Money_Code__c
                            FROM Deposit__c
                            WHERE Earnest_Money_Code__c IN :codeDepositMap.keySet()
                            AND Opportunity__c = :deposit.CRM_Opportunity_ID]) {

                        sfdcCodeDepositMap.put(d.Earnest_Money_Code__c, d);
                    }

                    for (Deposit de : deposit.Earnest_Money_List) {
                        if (String.isNotBlank(de.Code)) {

                            Deposit__c d = sfdcCodeDepositMap.get(de.Code);
                            if (d == null) {

                                Deposit__c newDeposit = new Deposit__c ();
                                newDeposit.Account__c = deposit.CRM_Student_ID;
                                newDeposit.Opportunity__c = deposit.CRM_Opportunity_ID;
                                newDeposit.Earnest_Money_Code__c = de.Code;
                                newDeposit.Money__c = de.Money == null ? 0 : de.Money / 100;
                                newDeposit.Money_Quit__c = de.Money_Quit == null ? 0 : de.Money_Quit / 100;
                                newDeposit.Money_Use__c = de.Money_Use == null ? 0 : de.Money_Use / 100;
                                newDeposit.Money_Lave__c = de.Money_Lave == null ? 0 : de.Money_Lave / 100;
                                newDeposit.Status__c = statusMap.get(deposit.Earnest_Money_Status);
                                newDeposit.Payment_Date__c = System.Today();
                                toInsertDepositList.add(newDeposit);

                            } else {

                                d.Money__c = de.Money == null ? 0 : de.Money / 100;
                                d.Money_Quit__c = de.Money_Quit == null ? 0 : de.Money_Quit / 100;
                                d.Money_Use__c = de.Money_Use == null ? 0 : de.Money_Use / 100;
                                d.Money_Lave__c = de.Money_Lave == null ? 0 : de.Money_Lave / 100;
                                d.Status__c = statusMap.get(deposit.Earnest_Money_Status);
                                toUpdateDepositList.add(d);
                            }
                        }
                    }
                }

                System.debug(LoggingLevel.INFO, '*** toInsertDepositList: ' + toInsertDepositList);
                System.debug(LoggingLevel.INFO, '*** toUpdateDepositList: ' + toUpdateDepositList);

                insert toInsertDepositList;
                update toUpdateDepositList;
            }
        }
    }

    global class DepositWrapper {
        public String CRM_Student_ID { get; set; }
        public String CRM_Opportunity_ID { get; set; }
        public String BS_Student_Code { get; set; }
        public Integer Earnest_Money_Status { get; set; }
        public List<Deposit> Earnest_Money_List { get; set; }
    }

    global class Deposit {
        public String Code { get; set; }
        public Decimal Money { get; set; }
        public Decimal Money_Quit { get; set; }
        public Decimal Money_Use { get; set; }
        public Decimal Money_Lave { get; set; }
    }
}