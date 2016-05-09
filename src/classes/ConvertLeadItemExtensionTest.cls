/**************************************************************************************************
 * Name: ConvertLeadItemExtensionTest
 * Object: Lead, Lead_Item__c, Appointment__c, Account, Opportunity
 * Purpose: a test class for converting lead Visualforce page function
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-25
 * Modified History: 
 * 2016-04-25    Vicia    Wang Writes comments in this format
 * 2016-05-06    Allen    Format the code
***************************************************************************************************/
@isTest
private class ConvertLeadItemExtensionTest {

    static testMethod void testConvertLeadItem () {
        User user = TestObjectFactory.createUser();
        shouldProcessRun__c avoidTrigger = new shouldProcessRun__c (
            Name = user.Id,
            IsDisable__c = TRUE);

        insert avoidTrigger; 

        Utils.runLeadTrigger = FALSE;

        System.runAs(user) {
            initialSamples();

            List<Lead> leadList = new List<Lead> ();
            List<Lead_Item__c> leadItemList = new List<Lead_Item__c> ();
            Lead_Item__c SHUSCounsellingItem = new Lead_Item__c ();
            Lead_Item__c SHUKCounsellingItem = new Lead_Item__c ();
            Lead_Item__c BJCounsellingItem = new Lead_Item__c ();
            Lead_Item__c BJTestprepItem = new Lead_Item__c ();
            Lead_Item__c GZTestprepItem = new Lead_Item__c ();
            Lead_Item__c fixPhoneLeadItem = new Lead_Item__c ();
            Lead_Item__c testExceptionItem = new Lead_Item__c ();

            Campaign BankofChina = TestObjectFactory.createCampaign (
                'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');
            Campaign BankofSH = TestObjectFactory.createCampaign (
                'BSH', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

            Lead BOCSHlead = TestObjectFactory.createLead (
                BankofChina, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            leadList.add(BOCSHlead);

            Lead BSHlead = TestObjectFactory.createLead (
                BankofSH, Constants.CITY_SH_CN, TRUE, '', '22220000');
            leadList.add(BSHlead);

            Lead BJlead = TestObjectFactory.createLead (
                BankofSH, Constants.CITY_BJ_CN, TRUE, '19099990001', '11110000');
            leadList.add(BJlead);

            Lead GZlead = TestObjectFactory.createLead (
                BankofSH, Constants.CITY_GZ_CN, TRUE, '19099990002', '11110002');
            leadList.add(GZlead);
            insert leadList;

            BatchCallOutManagementItem__c batchCallout = new BatchCallOutManagementItem__c();
            insert batchCallout;
            batchCallout = [SELECT Name FROM BatchCallOutManagementItem__c WHERE Id = : batchCallout.Id];
            CallLog_History__c BJLeadCalllog = TestObjectFactory.createLeadCallLogHistory(batchCallout.Id, BJlead);
            Appoitment__c leadFollowup = TestObjectFactory.createLeadFollowup(BJlead);

            for (Lead lead : leadList) {
                TestObjectFactory.createLeadItemList(lead);
            }

            for (Lead_Item__c li : [SELECT Intended_City__c, Business_Line__c, 
                                           Project__c, Mobile__c, 
                                           Lead__c
                                    FROM Lead_Item__c
                                    WHERE Lead__c IN :leadList]) {
                leadItemList.add(li);

                if (li.Intended_City__c == Constants.CITY_SH_CN &&
                    li.Project__c == Constants.US_CN &&
                    li.Lead__c == BOCSHlead.Id) {
                    SHUSCounsellingItem = li;
                
                } else if (li.Intended_City__c == Constants.CITY_SH_CN &&
                    	   li.Project__c == Constants.UK_CN &&
                    	   li.Lead__c == BOCSHlead.Id) {
                    SHUKCounsellingItem = li;
                
                } else if (li.Intended_City__c == Constants.CITY_BJ_CN &&
                           li.Project__c == Constants.US_CN) {
                    BJCounsellingItem = li;

                } else if (li.Intended_City__c == Constants.CITY_BJ_CN &&
                           li.Business_Line__c == Constants.TESTPREP_CN) {
                    BJTestprepItem = li;

                } else if (li.Intended_City__c == Constants.CITY_GZ_CN && 
                           li.Business_Line__c == Constants.TESTPREP_CN) {
                    GZTestprepItem = li;

                } else if (li.Intended_City__c == Constants.CITY_SH_CN &&
                           String.isBlank(li.Mobile__c)) {
                    fixPhoneLeadItem = li;

                } else {
                    testExceptionItem = li;
                }
            }

            PageReference convertPage = Page.ConvertLeadItem;
            Test.setCurrentPage(convertPage);
            ApexPages.currentPage().getParameters().put('batchId', batchCallout.Name);
            
            // Checks the null point lead item
            Lead_Item__c nullLeadItem = new Lead_Item__c ();
            ApexPages.StandardController nullLeadItemCon = new ApexPages.StandardController(nullLeadItem);
            ConvertLeadItemExtension nullcontroller = new ConvertLeadItemExtension(nullLeadItemCon);
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                              ApexPages.getMessages(), Constants.LEAD_CONVERT_NO_ITEM_ERROR));

            // Checks the closed lead item
            SHUKCounsellingItem.Status__c = Constants.LEAD_ITEM_STATUS_CONVERTED_WON_CN;
            update SHUKCounsellingItem;
            ApexPages.StandardController closedLeadItemCon = new ApexPages.StandardController(SHUKCounsellingItem);
            ConvertLeadItemExtension closedController = new ConvertLeadItemExtension(closedLeadItemCon);
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                              ApexPages.getMessages(), Constants.LEAD_CONVERT_CONVERTED_ERROR));

            // Checks unknown and null counselling project item to convert
            SHUKCounsellingItem.Status__c = Constants.LEAD_ITEM_STATUS_NEW_CN;
            SHUKCounsellingItem.Project__c = Constants.UNKNOWN_CN;
            update SHUKCounsellingItem;
            ApexPages.StandardController unknownLeadItemCon = new ApexPages.StandardController(SHUKCounsellingItem);
            ConvertLeadItemExtension unknownController = new ConvertLeadItemExtension(unknownLeadItemCon);
            unknownController.confirmConvert();
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                              ApexPages.getMessages(), Constants.LEAD_CONVERT_CONVERTED_ERROR));

            // Checks the lead by fix phone
            ApexPages.StandardController fixPhoneLeadItemCon = new ApexPages.StandardController(fixPhoneLeadItem);
            ConvertLeadItemExtension fixPhoneController = new ConvertLeadItemExtension(fixPhoneLeadItemCon);

            // Convert to an existed account but having no opportunities
            ApexPages.StandardController leadItemController = new ApexPages.StandardController(SHUSCounsellingItem);
            ConvertLeadItemExtension controller = new ConvertLeadItemExtension(leadItemController);
            controller.appointTime.Due_Date__c = System.today() + 2;
            controller.appointTime.Due_Time__c = '15:00';
            controller.confirmConvert();

            ApexPages.StandardController BJCounsellingItemCon = new ApexPages.StandardController(BJCounsellingItem);
            ConvertLeadItemExtension convertLeadItemExt = new ConvertLeadItemExtension(BJCounsellingItemCon);
            convertLeadItemExt.appointTime.Due_Date__c = System.today() + 2;
            convertLeadItemExt.appointTime.Due_Time__c = '15:00';
            convertLeadItemExt.confirmConvert();

            // Convert to a new account and a new opportunity
            ApexPages.StandardController GZTestprepItemCon = new ApexPages.StandardController(GZTestprepItem);
            ConvertLeadItemExtension GZConvertLeadItemExt = new ConvertLeadItemExtension(GZTestprepItemCon);
            GZConvertLeadItemExt.appointTime.Due_Date__c = System.today() + 2;
            GZConvertLeadItemExt.appointTime.Due_Time__c = '15:00';
            GZConvertLeadItemExt.confirmConvert();
            // Validates a converted lead to convert agaign.
            GZConvertLeadItemExt.confirmConvert();
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                          ApexPages.getMessages(), Constants.LEAD_CONVERT_CONVERTED_ERROR));            
            GZConvertLeadItemExt.cancel();

            // Checks a lead with an existed opportunity
            ApexPages.StandardController BJTestprepItemCon = new ApexPages.StandardController(BJTestprepItem);
            ConvertLeadItemExtension existedOppLeadItemExt = new ConvertLeadItemExtension(BJTestprepItemCon);
            System.assertEquals(TRUE, CommonHelperClass.compareVfErr(
                                          ApexPages.getMessages(), Constants.LEAD_CONVERT_SLEEP_ERROR));
          
        }
    }

    static void initialSamples () {

        Account acc1 = TestObjectFactory.createAccount('19099990000');
        List<Opportunity> oppList1 = TestObjectFactory.createOpportunities(acc1);
        
        Account acc2 = TestObjectFactory.createAccount('19099990001');
        List<Opportunity> oppList2 = TestObjectFactory.createOpportunities(acc2);
    }
}