/**************************************************************************************************
 * Name: DuplicatedAccountsViewController
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public without sharing class DuplicatedAccountsViewController {

    public List<Opportunity> dupOpps { get; set; }

    public DuplicatedAccountsViewController (ApexPages.StandardController con) {

        dupOpps = new List<Opportunity> ();
        Set<String> phoneSet = new Set<String> ();
        Set<Id> accIds = new Set<Id> ();

        for (Lead lead :[SELECT MobilePhone, Area_Code__c, Phone
                         FROM Lead
                         WHERE Id = :con.getId()]) {

            if (String.isNotBlank(lead.MobilePhone)) {

                phoneSet.add(lead.MobilePhone);
            }

            if (String.isNotBlank(lead.Phone)) {

                String fixPhone = lead.Area_Code__c == NULL ? '' : lead.Area_Code__c + lead.Phone;
                phoneSet.add(fixPhone);
            }
        }

        for (Contact_EIC__c contact :[SELECT Account__c
                                      FROM Contact_EIC__c
                                      WHERE UniqueContact__c IN :phoneSet
                                      AND isInvalid__c = FALSE]) {

            accIds.add(contact.Account__c);
        }

        for (Account acc : [SELECT Name, (SELECT Name,
                                                 RecordType.Name,
                                                 Project__c,
                                                 CreatedById,
                                                 StageName,
                                                 OwnerId,
                                                 Intended_City__c,
                                                 CreatedDate,
                                                 Record_Type_Chinese_Name__c
                                          FROM Opportunities
                                          ORDER BY IsClosed, CreatedDate DESC) 
                            FROM Account
                            WHERE Id IN :accIds]) {

            for (Opportunity opp :acc.Opportunities) {

                dupOpps.add(opp);
            }
        }
    }
}