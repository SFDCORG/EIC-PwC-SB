/**************************************************************************************************
 * Name: NewCampaignV2Ext
 * Object: Lead
 * Purpose: It is used to create / edit campaign
 * Requirement: 
 * Author: Tcool Ma
 * Create Date: 2015-10-24
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public with sharing class NewCampaignV2Ext {

    public String mode { get; set; }
    public String renderedSection { get; set; }
    public Campaign campaign { get; set; }
    public Boolean hasError { get; set; }
    public Boolean editable { get; set; }
    public String ownerName { get; set; }
    public String recordTypeName { get; set; }
    public String lv1 { get; set; }
    public String lv2 { get; set; }
    public String lv3 { get; set; }

    public List<SelectOption> marketingChannelLv1List { get; set; }
    public List<SelectOption> marketingChannelLv2List { get; set; }
    public List<SelectOption> marketingChannelLv3List { get; set; }
    public Map<String, Set<String>> lv1Lv2Map { get; set; }
    public Map<String, Set<String>> lv1Lv2Lv3Map { get; set; }

    private User u;
    private Boolean needCheck = false;

    private String campaignId;
    private Set<String> uneditableStatusSet = new Set<String> {
        '审批通过'
    };

    public NewCampaignV2Ext (ApexPages.StandardController con) {

        hasError = false;
        editable = true;
        renderedSection = '1';
        campaignId = ApexPages.currentPage().getParameters().get('id');
        needCheckUserForLv3();
        getCampaignChannels();
        if (String.isBlank(campaignId)) {
            createCampaign();
        } else {
            editCampaign();
        }
    }

    // Saves campaign
    public void saveCampaign () {

        hasError = false;
        try{
            lv1 = lv1 == '--无--' ? '' : lv1;
            lv2 = lv2 == '--无--' ? '' : lv2;
            lv3 = lv3 == '--无--' ? '' : lv3;

            campaign.Marketing_Channel_Lv1__c = lv1;
            campaign.Marketing_Channel_Lv2__c = lv2;
            campaign.Marketing_Channel_Lv3__c = lv3;

            if (mode == '1') {
                insert campaign;
            } else {
                update campaign;
            }

        } catch (DmlException dmlex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, dmlex.getDmlMessage(0)));
            hasError = true;
            return;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
            hasError = true;
            return;
        }
    }

    // save
    public PageReference save () {

        saveCampaign();
        if (hasError) {
            return null;
        }
        return new PageReference('/' + campaign.Id);
    }

    // cancel
    public PageReference cancel () {

        String returnUrl = ApexPages.currentPage().getParameters().get('retURL');

        if (String.isNotBlank(returnUrl)) {
            return new PageReference(returnUrl);
        } else {
            return new PageReference('/701');
        }
    }

    // check whether need to validate marketing channel lv3 for current user
    private void needCheckUserForLv3() {

        u = [SELECT ChineseNameofCity__c,
                    Business_Line_Formula__c,
                    UserRole.Name
             FROM User 
             WHERE Id = :UserInfo.getUserId()];
        if (String.isNotBlank(u.UserRole.Name) && (u.UserRole.Name.contains('分公司') || 
            u.UserRole.Name.contains('分校') ||
            u.UserRole.Name.contains('前台'))) {
            needCheck = true;
        }
    }

    // create campaign
    private void createCampaign() {

        mode = '1';

        // set default value
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Level_4_Promotion_Channel' LIMIT 1];
        campaign = new Campaign();
        campaign.Status = '草稿';
        campaign.BudgetedCost = null;
        campaign.ActualCost = null;

        if (rt != null) {
            campaign.RecordTypeId = rt.Id;
        }
        recordTypeName = '四级推广方式';
        ownerName = UserInfo.getName();
        
        if (u.ChineseNameofCity__c != 'N/A') {
            campaign.City__c = u.ChineseNameofCity__c;
        } else {
            campaign.City__c = '';
        }
        if (u.Business_Line_Formula__c == '集团') {
            campaign.Business_line__c = '全部';
        } else {
            campaign.Business_line__c = u.Business_Line_Formula__c;
        }
        lv1 = '--无--';
        lv2 = '--无--';
        lv3 = '--无--';
    }

    // edit campaign
    private void editCampaign () {
        mode = '2'; // edit
        for (Campaign c : [SELECT Name,
                                  City__c,
                                  StartDate,
                                  Business_line__c,
                                  EndDate,
                                  Marketing_Channel_Lv1__c,
                                  Marketing_Channel_Lv2__c,
                                  Marketing_Channel_Lv3__c,
                                  Approver__c,
                                  Is_Precise__c,
                                  RecordTypeId,
                                  Owner.Name,
                                  Status,
                                  IsActive,
                                  BudgetedCost,
                                  ActualCost,
                                  Description,
                                  Lead_Total_Number__c,
                                  RecordType.Name
                           FROM Campaign
                           WHERE Id = :campaignId]) {
            campaign = c;
        }

        if (campaign == null) {
            hasError = true;
            editable = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '市场推广不存在或者已删除!'));
            return;
        }

        if (campaign.RecordType.Name == 'Level 4 Promotion Channel') {
            recordTypeName = '四级推广方式';
        } else if (campaign.RecordType.Name == 'Level 4 Promotion Channel (Approved)') {
            recordTypeName = '四级推广方式(审批通过)';
        } else if (campaign.RecordType.Name == 'Subagent') {
            recordTypeName = 'Subagent';
            renderedSection = '0';
        } else if (campaign.RecordType.Name == 'Subagent Approved') {
            recordTypeName = 'Subagent Approved';
            renderedSection = '0';
        }

        lv1 = campaign.Marketing_Channel_Lv1__c;
        lv2 = campaign.Marketing_Channel_Lv2__c;
        ownerName = campaign.Owner.Name;
        lv3 = campaign.Marketing_Channel_Lv3__c;

        System.debug(LoggingLevel.INFO, '*** campaign: ' + campaign);
    }

    // get campaign channels mapping data from Campaign_Channel__c object
    private void getCampaignChannels() {

        marketingChannelLv1List = new List<SelectOption>();
        marketingChannelLv2List = new List<SelectOption>();
        marketingChannelLv3List = new List<SelectOption>();
        marketingChannelLv1List.add(new SelectOption('--无--', '--无--'));
        marketingChannelLv2List.add(new SelectOption('--无--', '--无--'));
        marketingChannelLv3List.add(new SelectOption('--无--', '--无--'));

        // get LV1, LV2, Business Line, City, LV3 mappings
        Set<String> lv1Set = new Set<String>();
        Set<String> lv2Set = new Set<String>();
        Set<String> lv3Set = new Set<String>();

        lv1Lv2Map = new Map<String, Set<String>>();
        lv1Lv2Lv3Map = new Map<String, Set<String>>();

        for (Campaign_Channel__c cc : [SELECT  Marketing_Channel_Lv1__c,
                                               Marketing_Channel_Lv2__c,
                                               Marketing_Channel_Lv3__c,
                                               Business_line__c,
                                               City__c
                                       FROM Campaign_Channel__c
                                       WHERE Active__c = true
                                       ORDER BY Marketing_Channel_Lv1__c,
                                                Marketing_Channel_Lv2__c,
                                                Marketing_Channel_Lv3__c]) {

            if (String.isNotBlank(cc.Marketing_Channel_Lv1__c)) {
                lv1Set.add(cc.Marketing_Channel_Lv1__c);

                if (String.isNotBlank(cc.Marketing_Channel_Lv2__c) && !cc.Marketing_Channel_Lv2__c.contains('（重复）')) {

                    lv2Set.add(cc.Marketing_Channel_Lv2__c);
                    if (String.isNotBlank(cc.Marketing_Channel_Lv3__c) && !cc.Marketing_Channel_Lv3__c.contains('（重复）')) {
                        lv3Set.add(cc.Marketing_Channel_Lv3__c);
                    }

                    // create lv1 => lv2 map
                    if (!lv1Lv2Map.containsKey(cc.Marketing_Channel_Lv1__c)) {
                        lv1Lv2Map.put(cc.Marketing_Channel_Lv1__c, new Set<String>());
                    }
                    lv1Lv2Map.get(cc.Marketing_Channel_Lv1__c).add(cc.Marketing_Channel_Lv2__c);

                    // create lv1 + lv2 => lv3 map
                    String lv1Lv2 = cc.Marketing_Channel_Lv1__c + '-' + cc.Marketing_Channel_Lv2__c;
                    if (!lv1Lv2Lv3Map.containsKey(lv1Lv2)) {
                        lv1Lv2Lv3Map.put(lv1Lv2, new Set<String>());
                    }
                    lv1Lv2Lv3Map.get(lv1Lv2).add(cc.Marketing_Channel_Lv3__c);
                }
            }
        }

        for (String lv1 : lv1Set) {
            marketingChannelLv1List.add(new SelectOption(lv1, lv1));
        }

        for (String lv2 : lv2Set) {
            marketingChannelLv2List.add(new SelectOption(lv2, lv2));
        }

        for (String lv3 : lv3Set) {
            marketingChannelLv3List.add(new SelectOption(lv3, lv3));
        }
    }
}