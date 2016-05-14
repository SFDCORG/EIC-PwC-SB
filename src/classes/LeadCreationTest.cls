/**************************************************************************************************
 * Name: LeadCreationTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class LeadCreationTest {

    @isTest static void tmkCreateCooperativeLead () {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Campaign_Channel__c channel;
        Campaign campaign;
        Campaign_Channel__c channel2;
        Campaign campaign2;
        Organization__c org;
        User tmkUser;
        Account acc;

        System.runAs(thisUser) {

            tmkUser = TestObjectFactory.createTmkUser('tmkUser');
            insert tmkUser;

            acc = TestObjectFactory.createAccount();
            insert acc;

            channel = TestObjectFactory.createCampaignChannel();
            insert channel;

            campaign = TestObjectFactory.createCoopCampaign(channel);
            insert campaign;

            channel2 = TestObjectFactory.createGzCoopCampaignChannel();
            insert channel2;

            campaign2 = TestObjectFactory.createAllCampaign(channel2);
            insert campaign2;

            org = TestObjectFactory.createCoopOrg();
            insert org;
        }

        Test.startTest();

        System.runAs(tmkUser){

            // Create a lead with 3 business lines, 4 expected lead items
            Lead lead = new Lead ();
            lead.LastName = 'tmkLeadTest';
            lead.Company = 'EIC';
            lead.Status = '全未转化-新建';
            lead.Campaign__c = campaign.Id;
            lead.Consultation_Mode__c = '集团TMK外呼';
            lead.Intended_City__c = '广州';
            lead.Is_Cooperative_Education__c = true;
            lead.Cooperative_Education_Project__c = '学术英语;国际预科';
            lead.Is_Counselling__c = true;
            lead.Counselling_Project__c = '美国;加拿大';
            lead.Is_TestPrep__c = true;
            lead.TestPrep_Project__c = 'SAT,GRE';
            lead.MobilePhone = '13500000001';

            insert lead;
            system.debug(lead);

            // Verify that the lead was created
            System.assertNotEquals(lead.Id, NULL);

            // Verify that 4 lead items were created
            List<Lead_Item__c> leadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                            FROM Lead_Item__c
                                            WHERE Lead__c = :lead.Id];
            System.AssertEquals(leadItems.size(), 4);
            system.debug(leadItems);

            // Verify that a Canada Counselling lead item was created
            List<Lead_Item__c> canadaLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c, Intended_Country__c
                                                  FROM Lead_Item__c
                                                  WHERE Lead__c = :lead.Id
                                                  AND Business_Line__c = '留学'
                                                  AND Intended_Country__c = '加拿大'];

            System.AssertEquals(canadaLeadItems.size(), 1);
            System.AssertEquals(canadaLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(canadaLeadItems[0].Project__c, '加拿大');

            // Verify that a USA Counselling lead item was created
            List<Lead_Item__c> usaLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c, Intended_Country__c
                                               FROM Lead_Item__c
                                               WHERE Lead__c = :lead.Id
                                               AND Business_Line__c = '留学'
                                               AND Intended_Country__c = '美国'];

            System.AssertEquals(usaLeadItems.size(), 1);
            System.AssertEquals(usaLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(usaLeadItems[0].Project__c, '美国');

            // Verify that 1 testprep lead item was created and verify that it is as expected
            List<Lead_Item__c> testprepLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                    FROM Lead_Item__c
                                                    WHERE Lead__c = :lead.Id
                                                    AND Business_Line__c = '考培'];

            System.AssertEquals(testprepLeadItems.size(), 1);
            System.AssertEquals(testprepLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(testprepLeadItems[0].Project__c, 'SAT,GRE');

            // Verify that 1 cooperative lead item was created and verify that it is as expected
            List<Lead_Item__c> coopLeadItems = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                FROM Lead_Item__c
                                                WHERE Lead__c = :lead.Id AND Business_Line__c = '合作办学'];

            System.AssertEquals(coopLeadItems.size(), 1);
            System.AssertEquals(coopLeadItems[0].Intended_City__c, '广州');
            System.AssertEquals(coopLeadItems[0].Project__c, '学术英语;国际预科');

            Utils.runLeadTrigger = TRUE;

            // Create a lead with coop and fixed phone
            Lead leadFixed = new Lead ();
            leadFixed.LastName = 'tmkLeadTestfixed';
            leadFixed.Company = 'EIC';
            leadFixed.Status = '全未转化-新建';
            leadFixed.Campaign__c = campaign.Id;
            leadFixed.Consultation_Mode__c = '集团TMK外呼';
            leadFixed.Intended_City__c = '广州';
            leadFixed.Is_Cooperative_Education__c = true;
            leadFixed.Cooperative_Education_Project__c = '学术英语';
            leadFixed.Phone = '55555555';
            leadFixed.Area_Code__c = '021';

            insert leadFixed;
            system.debug(leadFixed);

            // Verify that the lead was created
            System.assertNotEquals(leadFixed.Id, NULL);

            // Verify that 4 lead items were created
            List<Lead_Item__c> leadItemsFixed = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                 FROM Lead_Item__c
                                                 WHERE Lead__c = :leadFixed.Id];
            System.AssertEquals(leadItemsFixed.size(), 1);

            // Verify that 1 cooperative lead item was created and verify that it is as expected
            List<Lead_Item__c> coopLeadItems2 = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                 FROM Lead_Item__c
                                                 WHERE Lead__c = :leadFixed.Id
                                                 AND Business_Line__c = '合作办学'];

            System.AssertEquals(coopLeadItems2.size(), 1);
            System.AssertEquals(coopLeadItems2[0].Intended_City__c, '广州');
            System.AssertEquals(coopLeadItems2[0].Project__c, '学术英语');

            Utils.runLeadTrigger = TRUE;

            // Create a lead with coop and fixed phone
            Lead leadDupeFixed = new Lead ();
            leadDupeFixed.LastName = 'tmkLeadTestDupeFixed';
            leadDupeFixed.Company = 'EIC';
            leadDupeFixed.Status = '全未转化-新建';
            leadDupeFixed.Campaign__c = campaign.Id;
            leadDupeFixed.Consultation_Mode__c = '集团TMK外呼';
            leadDupeFixed.Intended_City__c = '广州';
            leadDupeFixed.Is_Cooperative_Education__c = true;
            leadDupeFixed.Cooperative_Education_Project__c = '学术英语';
            leadDupeFixed.Phone = '55555555';
            leadDupeFixed.Area_Code__c = '021';

            try {

                insert leadDupeFixed;
                System.assertNotEquals(leadDupeFixed.Id, NULL);
            } catch(Exception e) {

                Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.Error_Duplicate_Contact_For_Lead) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                System.AssertEquals(leadDupeFixed.Id, null);
            }

            Utils.runLeadTrigger = TRUE;

            // Create a lead with coop and fixed phone
            Lead leadDupeMobile = new Lead ();
            leadDupeMobile.LastName = 'tmkLeadTestDupeMobile';
            leadDupeMobile.Company = 'EIC';
            leadDupeMobile.Status = '全未转化-新建';
            leadDupeMobile.Campaign__c = campaign.Id;
            leadDupeMobile.Consultation_Mode__c = '集团TMK外呼';
            leadDupeMobile.Intended_City__c = '广州';
            leadDupeMobile.Is_Cooperative_Education__c = true;
            leadDupeMobile.Cooperative_Education_Project__c = '学术英语';
            leadDupeMobile.MobilePhone = '13500000001';

            try {
              insert leadDupeMobile;
              System.assertNotEquals(leadDupeMobile.Id, NULL);
            } catch(Exception e) {
              Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.Error_Duplicate_Contact_For_Lead) ? true : false;
              System.AssertEquals(expectedExceptionThrown, true);
              System.AssertEquals(leadDupeMobile.Id, null);
            }

            Utils.runLeadTrigger = TRUE;

            // Creates a lead with coop and fixed phone
            Lead leadNotDupe = new Lead ();
            leadNotDupe.LastName = 'tmkLeadTestDiffCampaign';
            leadNotDupe.Company = 'EIC';
            leadNotDupe.Status = '全未转化-新建';
            leadNotDupe.Campaign__c = campaign2.Id;
            leadNotDupe.Consultation_Mode__c = '集团TMK外呼';
            leadNotDupe.Intended_City__c = '广州';
            leadNotDupe.Is_Cooperative_Education__c = true;
            leadNotDupe.Cooperative_Education_Project__c = '学术英语';
            leadNotDupe.MobilePhone = '13500000001';

            insert leadNotDupe;
            System.assertNotEquals(leadNotDupe.Id, NULL);

            // Verify that 1 cooperative lead item was created and verify that it is as expected
            List<Lead_Item__c> coopLeadItems3 = [SELECT Name, Business_Line__c, Project__c, Intended_City__c
                                                 FROM Lead_Item__c
                                                 WHERE Lead__c = :leadNotDupe.Id
                                                 AND Business_Line__c = '合作办学'];

            System.AssertEquals(coopLeadItems3.size(), 1);
            System.AssertEquals(coopLeadItems3[0].Intended_City__c, '广州');
            System.AssertEquals(coopLeadItems3[0].Project__c, '学术英语');

            Utils.runLeadTrigger = TRUE;
            Opportunity opp = TestObjectFactory.createCoopOpportunity(acc.Id, tmkUser);
            insert opp;
            Contact_EIC__c contact = new Contact_EIC__c ();
            contact.Account__c = acc.Id;
            contact.Contact_Type__c= '手机';
            contact.UniqueContact__c = '13500000000';
            contact.isInvalid__c = false;
            contact.isPrimary__c = true;
            insert contact;

            Lead leadDupeOpp = new Lead ();
            leadDupeOpp.LastName = 'tmkLeadTestDupeOpp';
            leadDupeOpp.Company = 'EIC';
            leadDupeOpp.Status = '全未转化-新建';
            leadDupeOpp.Campaign__c = campaign2.Id;
            leadDupeOpp.Consultation_Mode__c = '集团TMK外呼';
            leadDupeOpp.Intended_City__c = '广州';
            leadDupeOpp.Is_Cooperative_Education__c = true;
            leadDupeOpp.Cooperative_Education_Project__c = '学术英语';
            leadDupeOpp.MobilePhone = '13500000000';

            try {
              insert leadDupeOpp;
              System.assertNotEquals(leadDupeMobile.Id, NULL);

            } catch(Exception e) {
              Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.Error_Duplicate_Lead) ? true : false;
              System.AssertEquals(expectedExceptionThrown, true);
              System.AssertEquals(leadDupeOpp.Id, null);
            }

            Utils.runLeadTrigger = TRUE;

            // Create a coop lead in a non coop city
            Lead leadNotCoopCity = new Lead ();
            leadNotCoopCity.LastName = 'tmkLeadTestWrongCity';
            leadNotCoopCity.Company = 'EIC';
            leadNotCoopCity.Status = '全未转化-新建';
            leadNotCoopCity.Campaign__c = campaign.Id;
            leadNotCoopCity.Consultation_Mode__c = '集团TMK外呼';
            leadNotCoopCity.Intended_City__c = '厦门';
            leadNotCoopCity.Is_Cooperative_Education__c = true;
            leadNotCoopCity.Cooperative_Education_Project__c = '学术英语;国际预科';
            leadNotCoopCity.MobilePhone = '13500000002';

            try {
              insert leadNotCoopCity;
              System.assertNotEquals(leadNotCoopCity.Id, NULL);
            } catch(Exception e) {
              Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.Error_Not_Coop_City) ? true : false;
              System.AssertEquals(expectedExceptionThrown, true);
              System.AssertEquals(leadNotCoopCity.Id, null);
            }
        }
        Test.stopTest();
    }
}