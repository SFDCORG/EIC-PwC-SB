/**************************************************************************************************
 * Name: SchedulingTableOrderGenerationTest
 * Object: /
 * Purpose:  Test the Table Order Generation Function
 * Author: Ray Cen
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 **************************************************************************************************/

@isTest
private class SchedulingTableOrderGenerationTest {
    static testMethod void testScheTableOrderGeneration() {
        
        User thisUser = [SELECT Id 
                         FROM User 
                         WHERE Id = :UserInfo.getUserId()];

        System.runAs(thisUser) {
            User uuser = TestObjectFactory.createSalesUser();
            uuser.Username = 'sche@test.com.eic.pwc';
            uuser.User_External_Id__c = '201605211738';
            uuser.lastName = 'peter';
            uuser.firstName = '';
            insert uuser;
        }

        User lineUser = [SELECT Id, firstName, lastName, Name
                         FROM User
                         WHERE Username = 'sche@test.com.eic.pwc' Limit 1];

        Organization__c org = TestObjectFactory.createOrgs();
        insert org;
        Scheduling_Table__c sctable = TestObjectFactory.createSchedulingTable(org);
        insert sctable;
        Scheduling_Table_Line__c sctline = TestObjectFactory.createScheTableLine(sctable);
        sctline.User__c = lineUser.Id;
        sctline.Compensation_Opportunity_Num__c = 1;
        insert sctline;
        Scheduling_Table_Line__c sctline2 = TestObjectFactory.createScheTableLine(sctable);
        sctline2.User__c = UserInfo.getUserId();
        insert sctline2;
        Scheduling_Table_Order__c sctOrder = TestObjectFactory.createScheTableOrder(sctable);
        insert sctOrder;
        Scheduling_Table_Order__c sctOrder2 = TestObjectFactory.createScheTableOrder(sctable);
        insert sctOrder2;

        test.StartTest();

        // Test Normal Order Generation Process
        PageReference myVfPageUpdate = Page.Beta1_SchedulingTableCreation;
        Test.setCurrentPageReference(myVfPageUpdate);
        ApexPages.currentPage().getParameters().put('ID', sctable.Id);
        SchedulingTableOrderGenerationController scheOrder = new SchedulingTableOrderGenerationController();
        System.assertEquals(2, scheOrder.existingTableOrders.size());
        System.assertEquals(2, scheOrder.schedulingTableLines.size());
        System.debug('LoggingLevel.INFO, *** : ' + lineUser.Name);
        scheOrder.textLine = 'peter';
        scheOrder.expandRichBoxValue();
        scheOrder.generationOrder();
        List<Scheduling_Table_Order__c> results = [SELECT Id, Count__c, User__c
                                                   FROM Scheduling_Table_Order__c];

        Scheduling_Table_Order__c lineUserOrder = [SELECT Id, Count__c, User__c
                                                   FROM Scheduling_Table_Order__c
                                                   WHERE User__c = :sctline.User__c Limit 1];
        System.assertEquals(3, results.size());
        System.assertEquals(-1, lineUserOrder.Count__c);
        
        // Adds a user who is don't in the related table's line item, an error message will show on the page
        scheOrder.textLine = 'Linda';
        scheOrder.expandRichBoxValue();
        scheOrder.generationOrder();
        System.debug('LoggingLevel.INFO, *** : ' + ApexPages.getMessages());
        System.assertEquals(true, CommonHelperClass.compareVfErr(ApexPages.getMessages(), '请检测第：4行, 无效用户'));
        scheOrder.cancel();

        test.stopTest();
    }
}