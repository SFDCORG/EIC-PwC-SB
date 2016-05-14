/**************************************************************************************************
 * Name: LeadEncryptedMobileExtension
 * Object: ***
 * Purpose: Apex class that extends functionality for LeadEncryptedMobilePage
            VF page. It controls the display of encrypted and
            unencrypted phone numbers and logs the history of who asks to see
            the full number.
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-11
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public with sharing class LeadEncryptedMobileExtension {

    public String mobilePhone { get; set; }
    public String phone { get; set; }
    public Boolean showButtonDisabled { get; set; }
    private Id currentRecordID;
    private Lead lead;

    public LeadEncryptedMobileExtension (ApexPages.StandardController controller) {

        showButtonDisabled = false;
        currentRecordID = ApexPages.CurrentPage().getparameters().get('id');
        lead = [SELECT Encrypted_Mobile__c, MobilePhone, Phone, Encrypted_Phone__c
                FROM Lead
                WHERE Id = :currentRecordID];
        phone = lead.Encrypted_Phone__c;
        mobilePhone = lead.Encrypted_Mobile__c;
    }

    public PageReference showContactInfo () {
        mobilePhone = lead.MobilePhone;
        phone = lead.Phone;
        HistoryTrackObjectRelatedController.createLeadHistoryRecords(System.Now(), UserInfo.getUserId(), currentRecordID);
        showButtonDisabled = true;
        return null;
    }
}