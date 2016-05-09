/**************************************************************************************************
 * Name: DuplicatedLeadViewControllerTest
 * Object: Lead, Lead_Item__c
 * Purpose: a test class for searching duplicated lead by mobile/fixed phone
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-05
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
@isTest
private class DuplicatedLeadViewControllerTest {

    static testMethod void testDuplicatedLeadViewController () {

        User user = TestObjectFactory.createUser();
        Utils.runLeadTrigger = FALSE;

        System.runAs(user) {
            List<Lead> leadList = new List<Lead> ();

            Campaign BankofChina = TestObjectFactory.createCampaign(
                'BOC', Constants.COUNSELLING_CN, 'Offline', 'Business Cooperation', 'BSH');

            Lead SHlead = TestObjectFactory.createLead(
                BankofChina, Constants.CITY_SH_CN, TRUE, '19099990000', '22220000');
            leadList.add(SHlead);

            Lead BJlead = TestObjectFactory.createLead(
                BankofChina, Constants.CITY_BJ_CN, TRUE, '19099990000', '');
            leadList.add(BJlead);

            Lead GZlead = TestObjectFactory.createLead(
                BankofChina, Constants.CITY_GZ_CN, TRUE, '', '22220000');
            leadList.add(GZlead);
            insert leadList;

            for (Lead lead :leadList) {
                TestObjectFactory.createLeadItemList(lead);
            }

            PageReference duplicatedLeadViewPage = Page.DuplicatedLeadView;
            Test.setCurrentPage(duplicatedLeadViewPage);
            ApexPages.StandardController SHLeadCon = new ApexPages.StandardController (SHlead);
            DuplicatedLeadViewController SHInitialController = new DuplicatedLeadViewController (SHLeadCon);
            System.assertEquals(3, SHInitialController.dupLeadItems.size());
            
            ApexPages.StandardController BJLeadCon = new ApexPages.StandardController (BJlead);
            DuplicatedLeadViewController BJInitialController = new DuplicatedLeadViewController (BJLeadCon);
            System.assertEquals(3, BJInitialController.dupLeadItems.size());

            ApexPages.StandardController GZLeadCon = new ApexPages.StandardController (GZlead);
            DuplicatedLeadViewController GZInitialController = new DuplicatedLeadViewController (GZLeadCon);
            System.assertEquals(3, GZInitialController.dupLeadItems.size());
        }
    }
}