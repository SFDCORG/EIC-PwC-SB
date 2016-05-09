/**************************************************************************************************
 * Name: EICContactRelatedController
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public class EICContactRelatedController {

    public Static boolean checkPrimaryAvailable (Contact_EIC__c contact) {

        Set<String> contactMethod = new Set<String> ();
        contactMethod.add('手机');
        contactMethod.add('座机');

        return contactMethod.contains(contact.Contact_Type__c);
    }

    public static void uncheckPrimary (ID accountID, ID PMContct) {

        List<Contact_EIC__c> primaryCont = [SELECT Id, isPrimary__c
                                            FROM Contact_EIC__c 
                                            WHERE Account__c = :accountID 
                                            AND isPrimary__c = true 
                                            AND Id != :PMContct];

        for (Contact_EIC__c cont : primaryCont ) {

            cont.isPrimary__c = false;
        }

        update primaryCont;
    }

    public static String reorgnizeContactContent (String type, String content, String homePhoneArea) {

        if (type == '座机') return homePhoneArea + content;
        else if (type == '手机' || type == '邮箱' || type == '办公电话') return content;
        else if (type == '微信') return content + '(Wechat)';
        else if (type == 'SKYPE') return content + '(skype)';
        else if (type == 'QQ') return content + '(QQ)';
        else if (type == '传真') return content + '(FAX)';
        else return 'fail';
    }

    public static  List<Account> checkdupliatedContacts (String uniqueString) {  

      return [SELECT Id, name
              FROM Account
              WHERE Id IN (SELECT Account__c
                           FROM Contact_EIC__c
                           WHERE UniqueContact__c = :uniqueString)];
    }
}