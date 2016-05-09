/**************************************************************************************************
 * Name: CampaignUploaderCtrl
 * Object: Campaign
 * Purpose: It is used to upload campaigns
 * Requirement: 
 * Author: Tcool Ma
 * Create Date: 2015-10-24
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public with sharing class CampaignUploaderCtrl {

    public String sObjectName { get; set; }
    public Set<String> marketingChannelLv1Set { get; set; }
    public Set<String> marketingChannelLv2Set { get; set; }
    public Set<String> marketingChannelLv3Set { get; set; }

    public CampaignUploaderCtrl () {
        getCampaignChannels();
    }

    @RemoteAction
    public static String uploadData (String data) {

        System.debug(LoggingLevel.INFO, '*** data: ' + data);
        Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        System.debug(LoggingLevel.INFO, '*** dataMap: ' + dataMap);

        List<Collection> collections = new List<Collection> ();
        SavePoint sp = Database.setSavepoint();

        // Name is upper case
        Set<String> nameSet = new Set<String> ();
        Set<String> approverSet = new Set<String> ();
        Map<String, Id> recordTypeNameMapId = new Map<String, Id> ();

        Boolean hasError = FALSE;
        try {

            // Gets user info
            User u = [SELECT ChineseNameofCity__c, Business_Line_Formula__c
                      FROM User 
                      WHERE Id = :UserInfo.getUserId()];

            // Gets LV1, LV2, Business Line, City, LV3 mappings
            Set<String> lv1Set = new Set<String> ();
            Map<String, Set<String>> lv1Lv2Map = new Map<String, Set<String>> ();
            Map<String, Set<String>> lv1Lv2Lv3Map = new Map<String, Set<String>> ();

            for (Campaign_Channel__c cc : [SELECT Marketing_Channel_Lv1__c, Marketing_Channel_Lv2__c,
                                                  Marketing_Channel_Lv3__c, Business_line__c,
                                                  City__c
                                           FROM Campaign_Channel__c
                                           WHERE Active__c = TRUE
                                           ORDER BY Marketing_Channel_Lv1__c,
                                                    Marketing_Channel_Lv2__c,
                                                    Marketing_Channel_Lv3__c]) {

                if (String.isNotBlank(cc.Marketing_Channel_Lv1__c)) {
                    lv1Set.add(cc.Marketing_Channel_Lv1__c);

                    if (String.isNotBlank(cc.Marketing_Channel_Lv2__c) && 
                       !cc.Marketing_Channel_Lv2__c.contains(Constants.CAMPAIGN_DUP_CN)) {

                        if (!lv1Lv2Map.containsKey(cc.Marketing_Channel_Lv1__c)) {

                            lv1Lv2Map.put(cc.Marketing_Channel_Lv1__c, new Set<String> ());
                        }
                        lv1Lv2Map.get(cc.Marketing_Channel_Lv1__c).add(cc.Marketing_Channel_Lv2__c);
                        String lv1Lv2 = cc.Marketing_Channel_Lv1__c + '-' + cc.Marketing_Channel_Lv2__c;

                        if (!lv1Lv2Lv3Map.containsKey(lv1Lv2)) {

                            lv1Lv2Lv3Map.put(lv1Lv2, new Set<String> ());
                        }

                        lv1Lv2Lv3Map.get(lv1Lv2).add(cc.Marketing_Channel_Lv3__c);
                    }
                }
            }
            System.debug(LoggingLevel.INFO, '*** lv1Lv2Lv3Map: ' + lv1Lv2Lv3Map);

            recordTypeNameMapId.put(Constants.LEVEL_4_PROMOTION_CHANNEL_CN,
                                    Utils.getRecordTypeId('Campaign',
                                    'Level 4 Promotion Channel (Approved)'));
            recordTypeNameMapId.put(Constants.SUBAGENT_CN,
                                    Utils.getRecordTypeId('Campaign', 'Subagent Approved'));

            // loop records
            for (String sObjectName : dataMap.keySet()) {

                if (sObjectName == 'Campaign') {

                    // get uploaded records
                    List<Campaign> campaignList = new List<Campaign> ();
                    List<Object> validatedRecordList = new List<Object> ();
                    List<Map<String, Object>> details = new List<Map<String, Object>> ();
                    List<Object> recs = (List<Object>) dataMap.get(sObjectName);

                    for (Object o : recs) {

                        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                        String error = '';

                        // Checks whether has record type
                        if (String.valueOf(objMap.get('recordType')).trim() == NULL) {
                            hasError = TRUE;
                            error += Constants.CAMPAIGN_RECORD_TYPE_NULL_ERROR;

                        } else if (String.valueOf(objMap.get('recordType')).trim() != Constants.LEVEL_4_PROMOTION_CHANNEL_CN &&
                                   String.valueOf(objMap.get('recordType')).trim() != Constants.SUBAGENT_CN) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_CHOOSE_RECORD_TYPE_ERROR;
                        }

                        // Duplicates campaign name
                        if (!nameSet.contains(String.valueOf(objMap.get('name')).trim().toUpperCase())) {
                            nameSet.add(String.valueOf(objMap.get('name')).trim().toUpperCase());
                        } else {
                            hasError = TRUE;
                            error += Constants.CAMPAIGN_DUP_IN_FILE_ERROR;
                        }

                        // Validates startDate, endDate
                        String startDateStr = String.valueOf(objMap.get('startDate'));
                        String endDateStr = String.valueOf(objMap.get('endDate'));
                        Date startDate;
                        Date endDate;

                        try {

                            startDate = Date.valueOf(startDateStr);
                        } catch (Exception ex) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_START_DATE_ERROR;
                        }

                        try {

                            endDate = Date.valueOf(endDateStr);
                        
                        } catch (Exception ex) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_END_DATE_ERROR;
                        }

                        // Validates budgetedCost
                        String budgetedCostStr = String.valueOf(objMap.get('budgetedCost'));
                        if (budgetedCostStr != NULL && String.isNotBlank(budgetedCostStr)) {

                            Decimal budgetedCost = 0;
                            try {
                                budgetedCost = Decimal.valueOf(budgetedCostStr);
                            
                            } catch (Exception ex) {
                                hasError = TRUE;
                                error += Constants.CAMPAIGN_BUDGET_ERROR;
                            }
                        }

                        // Validates LV1, LV2 => Lv3 Mapping
                        String lv1 = String.valueOf(objMap.get('marketingChannelLv1'));
                        String lv2 = String.valueOf(objMap.get('marketingChannelLv2'));
                        if (lv1Lv2Map.get(lv1) == NULL || !lv1Lv2Map.get(lv1).contains(lv2)) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_LV2_PROMOTION_CHANNEL_ERROR;
                        }

                        String lv3 = String.valueOf(objMap.get('marketingChannelLv3')).trim();
                        String lv1Lv2 = lv1 + '-' + lv2;

                        if (lv1Lv2Lv3Map.get(lv1Lv2) == NULL) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_LV3_PROMOTION_CHANNEL_ERROR;
                        
                        } else {

                            if (String.isBlank(lv3) && 
                                (lv1Lv2Lv3Map.get(lv1Lv2).contains('') || 
                                 lv1Lv2Lv3Map.get(lv1Lv2).contains(NULL))) {

                            } else if (!lv1Lv2Lv3Map.get(lv1Lv2).contains(lv3)) {

                                hasError = TRUE;
                                error += Constants.CAMPAIGN_LV3_PROMOTION_CHANNEL_ERROR;
                            }
                        }

                        if (hasError == false) {

                            validatedRecordList.add(o);

                            approverSet.add(String.valueOf(objMap.get('approver')));
                        }

                        if (String.isNotBlank(error)) {

                            details.add(createDetail(objMap, error));
                        }
                        System.debug(LoggingLevel.INFO, '*** details: ' + details);
                    }

                    // get duplicated campaigns by name set
                    Set<String> duplicatedNameSet = new Set<String> ();
                    for (Campaign c : [SELECT Name
                                      FROM Campaign
                                      WHERE Name IN :nameSet
                                      AND Status !=: Constants.CLOSED_CN]) {

                        duplicatedNameSet.add(c.Name.toUpperCase());
                    }

                    // get approvers
                    Map<String, User> approverUserMap = new Map<String, User> ();
                    for (User user : [SELECT Email
                                     FROM User
                                     WHERE Email IN :approverSet
                                     AND IsActive = TRUE]) {

                        approverUserMap.put(user.Email, user);
                    }

                    List<Object> insertObjectList = new List<Object> ();
                    for (Object o : validatedRecordList) {
                        String error = '';
                        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));

                        // Validates campaign name
                        if (duplicatedNameSet.contains(String.valueOf(objMap.get('name')).trim().toUpperCase())) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_DUP_IN_SYSTEM_ERROR;
                        }

                        // Approver mapping
                        String approver = String.valueOf(objMap.get('approver'));
                        User user = approverUserMap.get(approver);
                        if (user == NULL) {

                            hasError = TRUE;
                            error += Constants.CAMPAIGN_APPROVER_ERROR;
                        
                        } else {

                            if (String.isBlank(error)) {

                                insertObjectList.add(o);

                                Campaign campaign = new Campaign ();
                                campaign.Name = String.valueOf(objMap.get('name'));
                                campaign.RecordTypeId = recordTypeNameMapId.get(String.valueOf(objMap.get('recordType')));
                                campaign.StartDate = Date.valueOf(String.valueOf(objMap.get('startDate')));
                                campaign.EndDate = Date.valueOf(String.valueOf(objMap.get('endDate')));
                                campaign.Approver__c = approverUserMap.get(String.valueOf(objMap.get('approver'))).Id;
                                campaign.City__c = String.valueOf(objMap.get('city'));
                                campaign.Business_line__c = String.valueOf(objMap.get('businessLine'));
                                campaign.Marketing_Channel_Lv1__c = String.valueOf(objMap.get('marketingChannelLv1'));
                                campaign.Marketing_Channel_Lv2__c = String.valueOf(objMap.get('marketingChannelLv2'));
                                campaign.Marketing_Channel_Lv3__c = String.valueOf(objMap.get('marketingChannelLv3'));
                                campaign.BudgetedCost = String.isBlank(String.valueOf(objMap.get('budgetedCost'))) ? NULL : Decimal.valueOf(String.valueOf(objMap.get('budgetedCost')));
                                campaign.Description = String.valueOf(objMap.get('description'));
                                campaign.Status = Constants.APPROVED_CN;
                                campaign.IsActive = TRUE;
                                campaignList.add(campaign);
                            }
                        }

                        if (String.isNotBlank(error)) {
                            details.add(createDetail(objMap, error));
                        }
                    }
                    List<Database.SaveResult> srs = Database.insert(campaignList, false);

                    for (Integer i = 0; i < campaignList.size(); i++) {
                        Campaign c = campaignList[i];
                        Database.SaveResult sr = srs[i];
                        Object o = insertObjectList[i];
                        Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(o));

                        if (sr.isSuccess()) {
                            details.add(createDetail(objMap, ' '));
                        
                        } else {
                            hasError = TRUE;
                            details.add(createDetail(objMap, sr.getErrors()[0].getMessage()));
                        }
                    }
                    Integer noOfCampaigns = hasError ? 0 : campaignList.size();
                    collections.add(new Collection(sObjectName, details, noOfCampaigns));
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            Database.rollback(sp);
            throw ex;
            return 'Fail';
        }

        if (hasError) {
            Database.rollback(sp);
        }

        return JSON.serialize(collections);
    }

    private static Map<String, Object> createDetail (Map<String, Object> objMap, String error) {

        Map<String, Object> detail = new Map<String, Object> ();
        detail.put('错误信息', error);
        detail.put('描述', String.valueOf(objMap.get('description')));
        detail.put('预算成本', String.valueOf(objMap.get('budgetedCost')));
        detail.put('三级市场推广方式', String.valueOf(objMap.get('marketingChannelLv3')));
        detail.put('二级市场推广方式', String.valueOf(objMap.get('marketingChannelLv2')));
        detail.put('一级市场推广方式', String.valueOf(objMap.get('marketingChannelLv1')));
        detail.put('业务线', String.valueOf(objMap.get('businessLine')));
        detail.put('城市', String.valueOf(objMap.get('city')));
        detail.put('审批人', String.valueOf(objMap.get('approver')));
        detail.put('结束日期', String.valueOf(objMap.get('endDate')));
        detail.put('开始日期', String.valueOf(objMap.get('startDate')));
        detail.put('记录类型', String.valueOf(objMap.get('recordType')));
        detail.put('名称', String.valueOf(objMap.get('name')));
        return detail;
    }

    public Map<String, String> getExcelUploaderCampaignFieldMapping () {

        Map<String, String> mapping = new Map<String, String>{
            'name' => '名称',
            'recordType' => '记录类型',
            'startDate' => '开始日期',
            'endDate' => '结束日期',
            'approver' => '审批人',
            'city' => '城市',
            'businessLine' => '业务线',
            'marketingChannelLv1' => '一级市场推广方式',
            'marketingChannelLv2' => '二级市场推广方式',
            'marketingChannelLv3' => '三级市场推广方式',
            'budgetedCost' => '预算成本',
            'description' => '描述',
            'errorMessage' => '错误信息'
        };
        return mapping;
    }

    public List<String> getCities() {

        List<String> cityList = new List<String> ();
        Schema.DescribeSobjectResult dsr= Schema.getGlobalDescribe().get('Campaign').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('City__c').getDescribe();
        for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {

            cityList.add(pe.getValue());
        }
        return cityList;
    }

    public List<String> getBusinessLines() {

        List<String> businessLineList = new List<String> ();
        Schema.DescribeSobjectResult dsr= Schema.getGlobalDescribe().get('Campaign').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Business_line__c').getDescribe();
        for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            businessLineList.add(pe.getValue());
        }
        return businessLineList;
    }

    private void getCampaignChannels() {

        marketingChannelLv1Set = new Set<String> ();
        marketingChannelLv2Set = new Set<String> ();
        marketingChannelLv3Set = new Set<String> ();

        for (Campaign_Channel__c cc : [SELECT Marketing_Channel_Lv1__c, Marketing_Channel_Lv2__c,
                                              Marketing_Channel_Lv3__c, Business_line__c, 
                                              City__c
                                       FROM Campaign_Channel__c
                                       WHERE Active__c = TRUE]) {
            marketingChannelLv1Set.add(cc.Marketing_Channel_Lv1__c);
            marketingChannelLv2Set.add(cc.Marketing_Channel_Lv2__c);
            marketingChannelLv3Set.add(cc.Marketing_Channel_Lv3__c);
        }
    }

    public class Collection {

        public String sObjectName { get; set; }
        public List<Map<String, Object>> records { get; set; }
        public Integer noOfCampaigns { get; set; }

        public Collection(String s, List<Map<String, Object>> r, Integer noOfCampaigns) {
            this.sObjectName = s;
            this.records = r;
            this.noOfCampaigns = noOfCampaigns;
        }
    }
}