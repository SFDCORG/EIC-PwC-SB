/**************************************************************************************************
 * Name: OpportunityCalloutController
 * Object: Opportunity
 * Purpose: Webservice to access the call center system so as to dial the mobile/fix phone
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
public class OpportunityCalloutController {

    public Id oppid { get;set; }
    public String phone { get;set; }
    public OpportunityCalloutController (ApexPages.StandardController con) {

        phone = '';
        oppid = con.getId();
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppid];
        List<Contact_EIC__c> contact = [SELECT UniqueContact__c, isPrimary__c, Contact_Type__c 
                                        FROM Contact_EIC__c 
                                        WHERE Contact_Type__c IN ('手机', '座机', '办公电话') 
                                        AND Account__c =: opp.AccountId];
        String mobiphone = '';
        String ph = '';
        String primary = '';
        for (Contact_EIC__c co : contact) {
            if (co.isPrimary__c) {

                primary = co.UniqueContact__c;
            } else if (co.Contact_Type__c == '手机') {

                mobiphone = co.UniqueContact__c;
            } else if (co.Contact_Type__c == '座机' || co.Contact_Type__c == '办公电话') {

                ph = co.UniqueContact__c;
            }
        }
        if (primary != '') {
            phone = convertPhoneNum(primary);

        } else if (mobiphone != '') {
            phone = convertPhoneNum(mobiphone);

        } else if (ph != '') {
            phone = convertPhoneNum(ph);
        }
    }

    public String convertPhoneNum (String input) {
        Pattern p = Pattern.compile('([\\d]*)(\\s?(\\[[\\d,E]*\\])?)?');
        Matcher m = p.matcher(input);
        if (m.find()) {

            return m.replaceFirst('$1'); 
        }

        return '';
    }
}