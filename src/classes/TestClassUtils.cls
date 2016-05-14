/**************************************************************************************************
 * Name: TestClassUtils
 * Object: useful method
 * Purpose: useful class for test class
 * Requirement:
 * Author:  Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-02-16
 * Modified History:
 * 2016-02-16    Vicia Wang    Writes comments in this format
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
public class TestClassUtils {

    public static Lead createLead(Campaign campaign, String intendedCity, Boolean hasProject) {
        if (hasProject) {
            Lead lead = new Lead(Lastname = 'Test',
                                 Firstname = 'A',
                                 MobilePhone = '19099990000',
                                 Area_Code__c = '021',
                                 Phone = '99999999',
                                 Campaign__c = campaign.Id,
                                 Consultation_Mode__c = 'TMK Callout',
                                 Intended_City__c = intendedCity,
                                 Is_Counselling__c = TRUE,
                                 Is_Testprep__c = TRUE,
                                 Counselling_Project__c = Constants.US_CN + ';' + Constants.UK_CN,
                                 Testprep_Project__c = 'SAT;GRE',
                                 GPA__c = 80,
                                 College__c = 'Test University',
                                 Education_Level__c = 'Bachelor',
                                 Company = 'EIC TEST');
            return lead;

        } else {
            Lead lead = new Lead(Lastname = 'Test',
                                 Firstname = 'B',
                                 Area_Code__c = '022',
                                 Phone = '99999990',
                                 Campaign__c = campaign.Id,
                                 Consultation_Mode__c = 'TMK Callout',
                                 Intended_City__c = intendedCity,
                                 Is_Counselling__c = TRUE,
                                 Is_Scholar_Tree__c = TRUE,
                                 Counselling_Project__c = '',
                                 GPA__c = 80,
                                 College__c = 'Test University',
                                 Education_Level__c = 'Bachelor',
                                 Company = 'EIC TEST');

            if (intendedCity == Constants.CITY_GZ_CN) {
                lead.Is_Cooperative_Education__c = TRUE;
            }

            if (intendedCity == Constants.CITY_SH_CN) {
                lead.Is_NP__c = TRUE;
            }

            return lead;
        }
    }

    public static Lead createLead(Campaign campaign, String intendedCity, Boolean hasProject, String mobile, String fixPhone) {
        if (hasProject) {
            Lead lead = new Lead(Lastname = 'Test',
                                 Firstname = 'A',
                                 MobilePhone = mobile,
                                 Area_Code__c = '021',
                                 Phone = fixPhone,
                                 Campaign__c = campaign.Id,
                                 Consultation_Mode__c = 'TMK Callout',
                                 Intended_City__c = intendedCity,
                                 Is_Counselling__c = TRUE,
                                 Is_Testprep__c = TRUE,
                                 Counselling_Project__c = Constants.US_CN + ';' + Constants.UK_CN,
                                 Testprep_Project__c = 'SAT;GRE',
                                 GPA__c = 80,
                                 College__c = 'Test University',
                                 Education_Level__c = 'Bachelor',
                                 Company = 'EIC TEST');
            return lead;

        } else {
            Lead lead = new Lead(Lastname = 'Test',
                                 Firstname = 'B',
                                 Area_Code__c = '022',
                                 Phone = fixPhone,
                                 Campaign__c = campaign.Id,
                                 Consultation_Mode__c = 'TMK Callout',
                                 Intended_City__c = intendedCity,
                                 Is_Counselling__c = TRUE,
                                 Is_Scholar_Tree__c = TRUE,
                                 Counselling_Project__c = '',
                                 GPA__c = 80,
                                 College__c = 'Test University',
                                 Education_Level__c = 'Bachelor',
                                 Company = 'EIC TEST');

            if (intendedCity == Constants.CITY_GZ_CN) {
                lead.Is_Cooperative_Education__c = TRUE;
            }

            if (intendedCity == Constants.CITY_SH_CN) {
                lead.Is_NP__c = TRUE;
            }

            return lead;
        }
    }

    public static Lead createUploadedLead(Campaign campaign, String intendedCity) {
        Lead lead = new Lead(Lastname = 'Test',
                             Firstname = 'A',
                             MobilePhone = '19099990000',
                             Area_Code__c = '021',
                             Phone = '99999999',
                             Campaign__c = campaign.Id,
                             Consultation_Mode__c = 'TMK Callout',
                             Intended_City__c = intendedCity,
                             Is_Counselling__c = TRUE,
                             GPA__c = 80,
                             College__c = 'Test University',
                             Company = 'EIC TEST');

        lead.Project__c = Constants.UK_CN + ';' + 
                          'SAT' + ';' + 
                          Constants.SCHOLAR_TREE_PROJECT_CN + ';' +
                          Constants.COOPERATIVE_PROJECT_CN;

        lead.Business_Line__c = Constants.COUNSELLING_CN + ';' +
                                Constants.TESTPREP_CN + ';' +
                                Constants.SCHOLAR_TREE_CN  + ';' + 
                                Constants.COOPERATIVE_CN;
        return lead;
    }

    public static Campaign createCampaign(String campaignName,
                                          String businessLine,
                                          String channel1,
                                          String channel2,
                                          String channel3) {

        Id recordTypeId = Utils.getRecordTypeId('Campaign', 'Level 4 Promotion Channel (Approved)');
        Campaign camp = new Campaign(Name = campaignName,
                                     RecordTypeId = recordTypeId,
                                     City__c = Constants.CITY_BJ_CN,
                                     Business_Line__c = businessLine,
                                     Marketing_Channel_Lv1__c = channel1,
                                     Marketing_Channel_Lv2__c = channel2,
                                     Marketing_Channel_Lv3__c = channel3,
                                     Status = Constants.APPROVED_CN,
                                     IsActive = TRUE);
        insert camp;
        return camp;
    }

    // Creates sample account
    public static Account createAccount() {
        Id recordTypeId = Utils.getRecordTypeId('Account', 'EIC Account');
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = recordTypeId);
        insert acc;

        Contact_EIC__c contact = new Contact_EIC__c(Name = 'Test Account',
                                                    Account__c = acc.Id,
                                                    Contact_Type__c = Constants.MOBILE_CN,
                                                    UniqueContact__c = '19099990000');
        insert contact;

        return acc;
    }

    // Creates sample account
    public static Account createAccount(String mobile) {
        Id recordTypeId = Utils.getRecordTypeId('Account', 'EIC Account');
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = recordTypeId);
        insert acc;

        Contact_EIC__c contact = new Contact_EIC__c(Name = 'Test Account',
                                                    Account__c = acc.Id,
                                                    Contact_Type__c = Constants.MOBILE_CN,
                                                    UniqueContact__c = mobile);
        insert contact;

        return acc;
    }

    // Creates sample contact only
    public static void createContact(Account acc, String fixPhone) {
        Contact_EIC__c contact = new Contact_EIC__c(Name = 'Test Account',
                                                    Account__c = acc.Id,
                                                    Contact_Type__c = Constants.FIX_PHONE_CN,
                                                    UniqueContact__c = fixPhone);
        insert contact;
    }

    public static List<Opportunity> createOpportunities(Account acc) {
        Id cRTId = Utils.getRecordTypeId('Opportunity', 'Counselling');
        Id tRTId = Utils.getRecordTypeId('Opportunity', 'Testprep');
        Id scholarTreeRTId = Utils.getRecordTypeId('Opportunity', 'Scholar Tree');
        Id cooperativeRTId = Utils.getRecordTypeId('Opportunity', 'Cooperative');
        List<Opportunity> opps = new List<Opportunity>();

        Opportunity counsellingOpp = new Opportunity(Name = 'counsellingOpp',
                                                     RecordTypeId = cRTId,
                                                     AccountId = acc.Id,
                                                     CloseDate = System.today() + 30,
                                                     Intended_City__c = Constants.CITY_BJ_CN,
                                                     Intended_Office__c = 'N/A',
                                                     Department__c = 'US',
                                                     Project__c = Constants.US_CN,
                                                     StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(counsellingOpp);
        Opportunity counsellingOpp2 = new Opportunity(Name = 'counsellingOpp2',
                                                      RecordTypeId = cRTId,
                                                      AccountId = acc.Id,
                                                      CloseDate = System.today() + 30,
                                                      Intended_City__c = Constants.CITY_SH_CN,
                                                      Intended_Office__c = 'N/A',
                                                      Department__c = 'England&Ireland',
                                                      Project__c = Constants.UK_CN,
                                                      StageName = Constants.OPPORTUNITY_STAGE_CLOSED_LOST_CN);
        opps.add(counsellingOpp2);

        Opportunity testprepOpp = new Opportunity(Name = 'testprepOpp',
                                                  RecordTypeId = tRTId,
                                                  AccountId = acc.Id,
                                                  CloseDate = System.today() + 30,
                                                  Intended_City__c = Constants.CITY_BJ_CN,
                                                  Intended_Office__c = 'N/A',
                                                  Department__c = Constants.DEPARTMENT_TESTPREP_CN,
                                                  Project__c = 'SAT',
                                                  StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(testprepOpp);

        Opportunity scholarTreeOpp = new Opportunity(Name = 'scholarTreeOpp',
                                                     RecordTypeId = scholarTreeRTId,
                                                     AccountId = acc.Id,
                                                     CloseDate = System.today() + 30,
                                                     Intended_City__c = Constants.CITY_BJ_CN,
                                                     Intended_Office__c = 'N/A',
                                                     Department__c = Constants.SCHOLAR_TREE_CN,
                                                     StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(scholarTreeOpp);

        Opportunity cooperativeOpp = new Opportunity(Name = 'cooperativeOpp',
                                                     RecordTypeId = cooperativeRTId,
                                                     AccountId = acc.Id,
                                                     CloseDate = System.today() + 30,
                                                     Intended_City__c = Constants.CITY_BJ_CN,
                                                     Intended_Office__c = 'N/A',
                                                     Department__c = Constants.COOPERATIVE_CN,
                                                     StageName = Constants.OPPORTUNITY_STAGE_FOLLOWUP_CN);
        opps.add(cooperativeOpp);

        insert opps;
        return opps;
    }

    public static void initializeProjectSetup() {
        List<Project__c> projectList = new List<Project__c>();
        Project__c counsellingProjs = new Project__c(Name = Constants.COUNSELLING_CN, 
                                                     Project__c = Constants.UK_CN);
        projectList.add(counsellingProjs);

        Project__c testprepProjs = new Project__c(Name = Constants.TESTPREP_CN, 
                                                  Project__c = 'SAT');
        projectList.add(testprepProjs);

        Project__c NPProjs = new Project__c(Name = 'NP',
                                            Project__c = 'SAT');
        projectList.add(NPProjs);

        Project__c scholarTreeProjs = new Project__c(Name = Constants.SCHOLAR_TREE_CN, 
                                                     Project__c = Constants.SCHOLAR_TREE_PROJECT_CN);
        projectList.add(scholarTreeProjs);

        Project__c cooperativeProjs = new Project__c(Name = Constants.COOPERATIVE_CN, 
                                                     Project__c = Constants.COOPERATIVE_PROJECT_CN);
        projectList.add(cooperativeProjs);

        insert projectList;
    }

    public static User createUser() {

        // Gets admin profile
        Profile adminProfile = [SELECT Id 
                                FROM Profile 
                                WHERE Name = 'System Administrator' 
                                LIMIT 1];

        User user = new User(Email = 'test@eic.com.test',
                             Lastname = 'Test',
                             ProfileId = adminProfile.Id,
                             Username = String.valueOf(System.Math.random()) + '@eic.com.test',
                             Alias = String.valueOf(System.Math.random()).subString(0, 8),
                             EmailenCodingKey = 'ISO-8859-1',
                             LanguageLocaleKey = 'en_US',
                             LocalesIdKey = 'en_GB',
                             TimezonesIdKey = 'America/Los_Angeles',
                             CompanyName = 'EIC');

        insert user;

        return user;
    }

    // Creates lead itemList
    public static void createLeadItemList(Lead lead) {
        List<Lead_Item__c> leadItemList = new List<Lead_Item__c>();
        Id campaignId = [SELECT Campaign__c
                         FROM Lead
                         WHERE Id = :lead.Id].Campaign__c;

        if (lead.Is_Counselling__c) {
            List<String> cProjects = new List<String>();
            if (String.isNotBlank(lead.Counselling_Project__c)) {
                cProjects = lead.Counselling_Project__c.split(';');
            }

            if (cProjects.size() == 0) {
                leadItemList.add(createOneLeadItem (
                    lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COUNSELLING_CN, campaignId, NULL, ''));

            // If it does not have counselling projects
            } else {

                // If it has counselling projects
                for (String country :cProjects) {
                    leadItemList.add(createOneLeadItem (
                        lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COUNSELLING_CN, campaignId, country, country));
                }
            }
        }

        if (lead.Is_TestPrep__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.TESTPREP_CN, campaignId, lead.TestPrep_Project__c, ''));
        }

        if (lead.Is_NP__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, 'NP', campaignId, lead.TestPrep_Project__c, ''));
        }

        if (lead.Is_Scholar_Tree__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.SCHOLAR_TREE_CN, campaignId, Constants.SCHOLAR_TREE_PROJECT_CN, ''));
        }

        if (lead.Is_Cooperative_Education__c) {
            leadItemList.add(createOneLeadItem (
                lead, Constants.LEAD_ITEM_STATUS_NEW_CN, Constants.COOPERATIVE_CN, campaignId, lead.Cooperative_Education_Project__c, ''));
        }

        insert leadItemList;
    }

    // Creates one lead item
    private static Lead_Item__c createOneLeadItem (Lead lead, String status, String businessLine, String campaignId, String project, String country) {
        Lead_Item__c li = new Lead_Item__c(Lead__c = lead.Id,
                                           Status__c = status,
                                           Business_Line__c = businessLine,
                                           Project__c = project);
        if (country != '') {
            li.Intended_Country__c = country;
            businessLine += ';' + country;
        }

        if (String.isNotBlank(lead.MobilePhone)) {
            li.Mobile__c = lead.MobilePhone;
            li.Mobile_Unique_Key__c = lead.MobilePhone + ';' + campaignId + ';' + lead.Intended_City__c + ';' + businessLine;
        }

        if (String.isNotBlank(lead.Phone)) {
            li.Fix_Phone__c = lead.Phone;
            li.Fix_Phone_Unique_Key__c = lead.Area_Code__c == NULL ? '' : lead.Area_Code__c +  lead.Phone + ';';
            li.Fix_Phone_Unique_Key__c += campaignId + ';' + lead.Intended_City__c + ';' + businessLine;
        }
        return li;
    }

    public static Organization__c createOrg(String city, String businessLineEN, String businessLineCN) {

        Organization__c org = new Organization__c();
        org.Name = city + businessLineCN + 'org';
        org.City__c = city;
        org.Front_Desk__c = UserInfo.getUserId();
        org.RecordTypeId = Utils.getRecordTypeId('Organization__c', businessLineEN);
        org.OwnerId = UserInfo.getUserId();
        org.Department__c = businessLineCN;
        org.Office__c = 'People Square';

        return org;
  }

    public static Scheduling_Table__c createSchedulingTable(Organization__c org, String businessLineEN) {

        Scheduling_Table__c schedulingTable = new Scheduling_Table__c();
        schedulingTable.Name = org.Name + 'Scheduling Table';
        schedulingTable.Organization__c = org.Id;
        schedulingTable.Front_Desk__c = org.Front_Desk__c;
        schedulingTable.Intercept__c = 'Distribute to Consultant';
        schedulingTable.Project__c = 'SAT;GRE';
        schedulingTable.Source__c = 'Normal Opportunity';
        schedulingTable.Department__c = org.Department__c;
        schedulingTable.isActive__c = TRUE;
        schedulingTable.City__c = org.City__c;
        schedulingTable.Office__c = org.Office__c;
        schedulingTable.Manager__c = Userinfo.getUserId();
        schedulingTable.RecordTypeId = Utils.getRecordTypeId('Scheduling_Table__c', businessLineEN);
        return schedulingTable;
    }

    public static Scheduling_Table_Line__c createScheTableLine(Scheduling_Table__c schedulingTable) {

        Scheduling_Table_Line__c schedulingTableLine = new Scheduling_Table_Line__c();
        schedulingTableLine.Project__c = schedulingTable.Project__c;
        schedulingTableLine.Source__c = schedulingTable.Source__c;
        schedulingTableLine.Monday_Time__c = 'D';
        schedulingTableLine.Start_Working_Time__c = '08:00';
        schedulingTableLine.End_Working_Time__c = '23:00';
        schedulingTableLine.User__c = Userinfo.getUserId();
        schedulingTableLine.Daily_Opportunities__c = 1;
        schedulingTableLine.Monthly_Opportunities__c = 2;
        schedulingTableLine.Scheduling_Table__c = schedulingTable.Id;

        return schedulingTableLine;
    }
}