/**************************************************************************************************
 * Name: ContactEICTriggerHelper
 * Object: Contact_EIC__c
 * Purpose: Utility class for UpdateAccountContactInfo trigger
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-11-25
 * Modify History:
 * 2016-04-18    Ray Cen    Create this class
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
public with sharing class ContactEICTriggerHelper {

    public static void updateAccoutContactInfo(Set<ID> contactsID) {

        List<Account> accs = new List<Account> ();
        Set<ID> accountIDs = new Set<ID> ();
        for (Contact_EIC__c cont : [SELECT Id, Encryped_Phone__c ,Account__c, Account__r.Phone
                                    FROM Contact_EIC__c
                                    WHERE Id IN :contactsID
                                    AND Encryped_Phone__c != null]) {

            if (!accountIDs.contains(cont.Account__c)) {
                Account acc = new Account ();
                acc = cont.Account__r;
                acc.Phone = cont.Encryped_Phone__c;
                accs.add(acc);
            }

            accountIDs.add(cont.Account__c);
        }

        if (accs.size() > 0) {
            update accs;
        }
    }

    public static void uncheckOtherAllContactPrimaryBox (Set<ID> accoutIds, Set<ID> contactIds) {

        List<Contact_EIC__c> contacts = [SELECT Id, isPrimary__c 
                                         FROM Contact_EIC__c
                                         WHERE (NOT Id IN :contactIds)
                                         AND Account__c IN :accoutids
                                         AND isPrimary__c = true];
        
        for (Contact_EIC__c contacct : contacts) {

            contacct.isPrimary__c = false;
        }

        update contacts;
    }

    public static void autocheckPrimary (Set<ID> accoutids, Set<ID> contactIds) {

        Set<ID> havePrimaryAcc = new Set<ID> ();
        List<Contact_EIC__c> updateContacts = new List<Contact_EIC__c> ();
        for (Contact_EIC__c cct : [SELECT Id, isPrimary__c, Account__c 
                                   FROM Contact_EIC__c 
                                   WHERE (NOT Id IN :contactIds) 
                                   AND Account__c IN :accoutids
                                   AND isPrimary__c = true]) {

            havePrimaryAcc.add(cct.Account__c);
        }

        for (Contact_EIC__c currentConact : [SELECT Id,Account__c, Contact_Type__c
                                             FROM Contact_EIC__c 
                                             WHERE isPrimary__c = false
                                             AND Id IN :contactIds]) {

            Boolean typeCheck = EICContactRelatedController.checkPrimaryAvailable(currentConact);
            currentConact.isPrimary__c = !havePrimaryAcc.contains(currentConact.Account__c);
            if (currentConact.isPrimary__c && typeCheck) {

                updateContacts.add(currentConact);
            }
        }

        if (updateContacts.size() > 0) {
            update updateContacts;
        }
    }
}