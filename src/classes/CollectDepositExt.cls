/**************************************************************************************************
 * Name: CollectDepositExt
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public with sharing class CollectDepositExt {

    private Opportunity opp;
    private List<String> phones = new List<String> ();

    public CollectDepositExt (ApexPages.StandardController con) {

        opp = (Opportunity) con.getRecord();
        opp = [SELECT AccountId,
                      Account.Name,
                      Account.Ext_Customer_Id__c,
                      Ext_Opportunity_Id__c,
                      Account.Merge_Customer_Ids__c,
                      Account.Gender__c
               FROM Opportunity
               WHERE Id = :opp.Id];
        
        for (Contact_EIC__c contact : [SELECT Unique_Contact__c
                                       FROM Contact_EIC__c
                                       WHERE Account__c = :opp.AccountId
                                       AND Contact_Type__c IN ('手机', '座机', 'mig_type', '紧急联系方式')
                                       AND IsInvalid__c = false]) {

            if (String.isNotBlank(contact.Unique_Contact__c) && !contact.Unique_Contact__c.contains('@')) {

                phones.add(contact.Unique_Contact__c);
            }
        }
    }

    public PageReference gotoTestPrepDeposit () {

        Contract_System__c depositCollection = Contract_System__c.getValues('Prepsmith Jiaowu Register');
        if (depositCollection != null) {

            User currentUser = [SELECT Sage_UserName__c, Paike_UserName__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];

            if (String.isBlank(currentUser.Paike_UserName__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                    '您未绑定paike账号，请联系系统管理员！'));
                return null;
            }

            String mobile;
            if (phones.size() > 0) {

                mobile = phones[0]; 
            } else {

                mobile = '';
            }          

            String requestUrl = depositCollection.Endpoint__c;
            String requestStr = '';

            CollectDepositRequest request = new CollectDepositRequest(5,
                                                                      opp.AccountId,
                                                                      opp.Id,
                                                                      0,
                                                                      '',
                                                                      opp.Account.Ext_Customer_Id__c,
                                                                      opp.Ext_Opportunity_Id__c,
                                                                      opp.Account.Name,
                                                                      mobile,
                                                                      getGenderType(),
                                                                      currentUser.Paike_UserName__c,
                                                                      opp.Account.Merge_Customer_Ids__c);

            requestStr = JSON.serialize(request);
            requestStr = 'JSONData=' + requestStr;
            requestStr = requestStr.escapeEcmaScript();
            requestStr = EncodingUtil.urlEncode(requestStr, 'UTF-8');
            requestUrl += requestStr;

            System.debug(LoggingLevel.INFO, '*** requestUrl: ' + requestUrl);

            return new PageReference (requestUrl);
        } else {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,
                                 '"收取订金"自定义设置缺失， 请联系管理员！'));
            return null;
        }
    }

    public Integer getGenderType() {

        if (opp.Account.Gender__c == '女') {
            return 1;
        } else {
            return 0;
        }
    }

    public class CollectDepositRequest {

        Integer Page_Type;
        String CRM_Student_ID;
        String CRM_Opportunity_ID;
        Integer CRM_Opportunity_Type;
        String CRM_Contract_ID;
        String Old_CRM_Student_ID;
        String Old_CRM_Opportunity_ID;
        String CRM_Student_Name;
        String CRM_Student_Phone;
        Integer CRM_Student_Sex;        
        String BS_User_Name;
        String Old_CRM_Student_IDs;

        public CollectDepositRequest (Integer Page_Type, 
                                      String CRM_Student_ID, 
                                      String CRM_Opportunity_ID, 
                                      Integer CRM_Opportunity_Type, 
                                      String CRM_Contract_ID, 
                                      String Old_CRM_Student_ID, 
                                      String Old_CRM_Opportunity_ID,
                                      String CRM_Student_Name, 
                                      String CRM_Student_Phone, 
                                      Integer CRM_Student_Sex, 
                                      String BS_User_Name,
                                      String Old_CRM_Student_IDs) {

            this.Page_Type = Page_Type;
            this.CRM_Student_ID = CRM_Student_ID;
            this.CRM_Opportunity_ID = CRM_Opportunity_ID;
            this.CRM_Opportunity_Type = CRM_Opportunity_Type;
            this.CRM_Contract_ID = CRM_Contract_ID;     
            this.Old_CRM_Student_ID = Old_CRM_Student_ID;
            this.Old_CRM_Opportunity_ID = Old_CRM_Opportunity_ID;
            this.CRM_Student_Name = String.isBlank(CRM_Student_Name) ?
                                    '' :
                                    EncodingUtil.urlEncode(CRM_Student_Name, 'UTF-8');
            this.CRM_Student_Phone = CRM_Student_Phone;
            this.CRM_Student_Sex = CRM_Student_Sex;     
            this.BS_User_Name = String.isBlank(BS_User_Name) ?
                                '' :
                                EncodingUtil.urlEncode(BS_User_Name, 'UTF-8');
            this.Old_CRM_Student_IDs = Old_CRM_Student_IDs;
        }
    }
}