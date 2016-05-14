/**************************************************************************************************
 * Name: LookupCampaignCtrl
 * Object: Campaign
 * Purpose: It is used to look up campaign from new lead page
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2015-10-24
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public without sharing class LookupCampaignCtrl {

    public List<Campaign> campaignList { get; set; }
    public String searchTextCity { get; set; }
    public String searchTextBusinessLine { get; set; }
    public String searchTextOther { get; set; }
    public String lv1 { get; set; }
    public String lv2 { get; set; }
    public String lv3 { get; set; }

    public List<SelectOption> marketingChannelLv1List { get; set; }
    public List<SelectOption> marketingChannelLv2List { get; set; }
    public List<SelectOption> marketingChannelLv3List { get; set; }

    public Map<String, Set<String>> lv1Lv2Map { get; set; }
    public Map<String, Set<String>> lv1Lv2Lv3Map { get; set; }

    private User u;
    private String soql = '';
    private Boolean needCheck = false;
    private Set<String> defaultCampaignSet = new Set<String>();
    private Set<String> excludedCampaignSet = new Set<String>();
    private Set<String> excludedCampaignMarketingChannelLv1Set = new Set<String>();
    private String selectStr = 'SELECT '
                            +  'Name, '
                            +  'StartDate, '
                            +  'EndDate, '
                            +  'City__c, '
                            +  'Marketing_Channel_Lv1__c, '
                            +  'Marketing_Channel_Lv2__c, '
                            +  'Marketing_Channel_Lv3__c, '
                            +  'Business_line__c '
                            +  'FROM Campaign '
                            +  'WHERE Status = \'审批通过\' '
                            +  'AND IsActive = true ';
    private String orderByStr = 'ORDER BY EndDate DESC, Name ASC LIMIT 100';

    public LookupCampaignCtrl() {

        campaignList = new List<Campaign>();

        needCheckUserForLv3();
        getDefaultCampaignList();
        getExcludedCampaignList();
        getExcludedCampaignsMarketingChannelLv1();

        selectStr += 'AND Name NOT IN :excludedCampaignSet '
                   + 'AND Marketing_Channel_Lv1__c NOT IN :excludedCampaignMarketingChannelLv1Set ';

        getCampaigns();
        getCampaignChannels();
    }

    // Searches campaign
    public void searchCampaign() {

        String conditions = getSearchConditions();

        if (conditions != '') {
            campaignList.clear();

            soql = selectStr;
            soql += conditions;
            soql += orderByStr;

            System.debug(LoggingLevel.INFO, '*** soql: ' + soql);
            system.debug(soql);
            List<Campaign> cList = (List<Campaign>) Database.query(soql);
            System.debug(LoggingLevel.INFO, '*** cList: ' + cList);
            campaignList.addAll(filterCampaign(cList));
        
        } else {
            getCampaigns();
        }
    }

    // Gets default campaign list
    private void getCampaigns() {
        campaignList.clear();

        soql = selectStr;
        soql += 'AND Name IN :defaultCampaignSet ';

        soql += orderByStr;

        List<Campaign> cList = (List<Campaign>) Database.query(soql);
        campaignList.addAll(cList);
    }

    private String getSearchConditions() {

        String conditions = '';
        if (String.isNotBlank(searchTextCity)) {
            searchTextCity = '%' + String.escapeSingleQuotes(searchTextCity.replace('*', '%')) + '%';
            conditions += 'AND Name LIKE :searchTextCity ';
        }

        if (String.isNotBlank(searchTextBusinessLine)) {
            searchTextBusinessLine = '%' + String.escapeSingleQuotes(searchTextBusinessLine.replace('*', '%')) + '%';
            conditions += 'AND Name LIKE :searchTextBusinessLine ';
        }

        if (String.isNotBlank(searchTextOther)) {
            searchTextOther = '%' + String.escapeSingleQuotes(searchTextOther.replace('*', '%')) + '%';
            conditions += 'AND Name LIKE :searchTextOther ';
        }

        System.debug(LoggingLevel.INFO, '*** conditions: ' + conditions);
        return conditions;
    }

    // Searches campaign with filters
    public void searchCampaignByFilters() {

        campaignList.clear();

        soql = selectStr;
        String conditions = getSearchConditions();

        if (String.isNotBlank(conditions)) {
            soql += conditions;
        }

        if (String.isNotBlank(lv1) && lv1 != '--无--') {
            soql += 'AND Marketing_Channel_Lv1__c =  \'' + lv1 + '\' ';
        }
        if (String.isNotBlank(lv2) && lv2 != '--无--') {
            soql += 'AND Marketing_Channel_Lv2__c = \'' + lv2 + '\' ';
        }
        if (String.isNotBlank(lv3) && lv3 != '--无--') {
            soql += 'AND Marketing_Channel_Lv3__c = \'' + lv3 + '\' ';
        }
        soql += orderByStr;

        System.debug(LoggingLevel.INFO, '*** soql: ' + soql);

        List<Campaign> cList = (List<Campaign>)Database.query(soql);

        campaignList.addAll(filterCampaign(cList));
    }

    // Gets marketing channel lv2 by lv1
    public void getLv2ByLv1() {

        marketingChannelLv2List.clear();
        marketingChannelLv3List.clear();
        marketingChannelLv2List.add(new SelectOption('--无--', '--无--'));
        marketingChannelLv3List.add(new SelectOption('--无--', '--无--'));

        for (String lv2 : lv1Lv2Map.get(lv1)) {
            if (!lv2.contains('（重复）')) {
                marketingChannelLv2List.add(new SelectOption(lv2, lv2));
            }
        }
    }

    // Gets marketing channel lv3 by lv1 + lv2
    public void getLv3ByLv1Lv2() {

        marketingChannelLv3List.clear();
        marketingChannelLv3List.add(new SelectOption('--无--', '--无--'));
        String lv1Lv2 = lv1 + '-' + lv2;
        if (lv1Lv2Lv3Map.get(lv1Lv2) != null) {
            for (String lv3 : lv1Lv2Lv3Map.get(lv1Lv2)) {
                if (String.isNotBlank(lv3) && !lv3.contains('（重复）')) {
                    marketingChannelLv3List.add(new SelectOption(lv3, lv3));
                }
            }
        }
    }

    // Checks whether need to validate marketing channel lv3 for current user
    private void needCheckUserForLv3() {

        u = [SELECT ChineseNameofCity__c,
                    Business_Line_Formula__c,
                    Profile.Name,
                    UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()];

        if (u.Profile.Name.contains('分公司') ||
            u.Profile.Name.contains('分校') ||
            u.Profile.Name.contains('前台')) {

            needCheck = true;
        }
    }

    // Excludes campaigns for some conditions
    private List<Campaign> filterCampaign(List<Campaign> campaignList) {

        List<Campaign> filteredCampaignList = new List<Campaign>();
        for (Campaign c : campaignList) {

            if (c.Marketing_Channel_Lv2__c=='Live800其他' ||
                c.Marketing_Channel_Lv3__c=='顾问互荐' ||
                c.Marketing_Channel_Lv3__c=='考培教服推荐') {
                continue;
            }

            if (u.Profile.Name.contains('呼叫中心') &&
                c.Marketing_Channel_Lv1__c=='合作招生') {
                continue;
            }

            String uCNCity = '';
            if ((u.ChineseNameofCity__c == '顺德' ||
                u.ChineseNameofCity__c == '珠海') &&
                u.Business_Line_Formula__c == '留学') {
                uCNCity = '广州';

            } else {

                uCNCity = u.ChineseNameofCity__c;
            }
            if (needCheck) {
                if (c.Marketing_Channel_Lv1__c == '线下') {
                    if (c.City__c == uCNCity && (c.Business_line__c == u.Business_Line_Formula__c ||
                                                (c.Business_line__c == '全部' && u.Business_Line_Formula__c == '集团') ||
                                                (c.Business_line__c == '考培' && u.Business_Line_Formula__c == '合作办学'))) {
                        filteredCampaignList.add(c);
                    }
                } else {
                    filteredCampaignList.add(c);
                }
            } else {
                filteredCampaignList.add(c);
            }
        }
        return filteredCampaignList;
    }

    // Gets campaign channels mapping data from Campaign_Channel__c object
    private void getCampaignChannels() {

        marketingChannelLv1List = new List<SelectOption>();
        marketingChannelLv2List = new List<SelectOption>();
        marketingChannelLv3List = new List<SelectOption>();

        Set<String> lv1Set = new Set<String>();

        lv1Lv2Map = new Map<String, Set<String>>();
        lv1Lv2Lv3Map = new Map<String, Set<String>>();

        // get LV1, LV2, Business Line, City, LV3 mappings
        List<Campaign_Channel__c> ccs = new List<Campaign_Channel__c>();
        if (u.Profile.Name.indexOf('呼叫中心')!=-1 ) {
            ccs = [SELECT Marketing_Channel_Lv1__c,
                          Marketing_Channel_Lv2__c,
                          Marketing_Channel_Lv3__c,
                          Business_line__c,
                          City__c
                   FROM Campaign_Channel__c
                   WHERE Active__c = true
                   AND Marketing_Channel_Lv1__c !='合作招生' 
                   AND Marketing_Channel_Lv2__c != 'Live800其他'
                   AND Marketing_Channel_Lv3__c != '顾问互荐' 
                   AND Marketing_Channel_Lv3__c != '考培教服推荐'
                   ORDER BY Marketing_Channel_Lv1__c,
                            Marketing_Channel_Lv2__c,
                            Marketing_Channel_Lv3__c];

        } else if (u.Profile.Name.indexOf('合作办学')!=-1 ) {
            ccs = [SELECT  Marketing_Channel_Lv1__c,
                           Marketing_Channel_Lv2__c,
                           Marketing_Channel_Lv3__c,
                           Business_line__c,
                           City__c
                    FROM Campaign_Channel__c
                    WHERE Active__c = true 
                    AND Business_line__c = '合作办学'
                    ORDER BY Marketing_Channel_Lv1__c,
                             Marketing_Channel_Lv2__c,
                             Marketing_Channel_Lv3__c];
        } else{
            ccs = [SELECT Marketing_Channel_Lv1__c,
                          Marketing_Channel_Lv2__c,
                          Marketing_Channel_Lv3__c,
                          Business_line__c,
                          City__c
                    FROM Campaign_Channel__c
                    WHERE Active__c = true 
                    AND Marketing_Channel_Lv2__c !='Live800其他'
                    AND Marketing_Channel_Lv3__c != '顾问互荐'
                    AND Marketing_Channel_Lv3__c != '考培教服推荐'
                    ORDER BY Marketing_Channel_Lv1__c,
                             Marketing_Channel_Lv2__c,
                             Marketing_Channel_Lv3__c];
        }

        for (Campaign_Channel__c cc : ccs) {

            if (String.isNotBlank(cc.Marketing_Channel_Lv1__c)) {
                lv1Set.add(cc.Marketing_Channel_Lv1__c);

                // Creates lv1 => lv2 map
                if (String.isNotBlank(cc.Marketing_Channel_Lv2__c)) {

                    if (!lv1Lv2Map.containsKey(cc.Marketing_Channel_Lv1__c)) {

                        lv1Lv2Map.put(cc.Marketing_Channel_Lv1__c, new Set<String>());
                    }

                    lv1Lv2Map.get(cc.Marketing_Channel_Lv1__c).add(cc.Marketing_Channel_Lv2__c);

                    Boolean isValid = false;
                    String uCNCity = '';
                    if ((u.ChineseNameofCity__c == '顺德' ||
                         u.ChineseNameofCity__c == '珠海') &&
                         u.Business_Line_Formula__c == '留学') {
                        uCNCity = '广州';

                    } else {
                        uCNCity = u.ChineseNameofCity__c;
                    }

                    if (needCheck) {
                        if (cc.Marketing_Channel_Lv1__c == '线下') {
                            if (cc.City__c == uCNCity
                                && (cc.Business_line__c == u.Business_Line_Formula__c
                                    || (cc.Business_line__c == '全部' && u.Business_Line_Formula__c == '集团'))) {
                                isValid = true;
                            }
                        } else {
                            isValid = true;
                        }
                    }

                    // Creates lv1 + lv2 => lv3 map
                    if (!needCheck || isValid) {
                        String lv1Lv2 = cc.Marketing_Channel_Lv1__c + '-' + cc.Marketing_Channel_Lv2__c;
                        if (!lv1Lv2Lv3Map.containsKey(lv1Lv2)) {
                            lv1Lv2Lv3Map.put(lv1Lv2, new Set<String>());
                        }
                        lv1Lv2Lv3Map.get(lv1Lv2).add(cc.Marketing_Channel_Lv3__c);
                    }
                }
            }
        }

        marketingChannelLv1List.clear();
        marketingChannelLv1List.add(new SelectOption('--无--', '--无--'));
        for (String lv1 : lv1Set) {
            if (!excludedCampaignMarketingChannelLv1Set.contains(lv1)) {
                marketingChannelLv1List.add(new SelectOption(lv1, lv1));
            }
        }
    }

    private void getDefaultCampaignList() {

        for (DefaultCampaignList__c dc : DefaultCampaignList__c.getAll().values()) {

            defaultCampaignSet.add(dc.Name);
        }
    }

    private void getExcludedCampaignList() {

        for (ExcludedCampaignList__c ec : ExcludedCampaignList__c.getAll().values()) {

            excludedCampaignSet.add(ec.Name);
        }
    }

    private void getExcludedCampaignsMarketingChannelLv1() {

        for (ExcludedCampaignsMarketingChannelLv1__c ec : ExcludedCampaignsMarketingChannelLv1__c.getAll().values()) {

            if (ec.Role__c == 'All') {

                excludedCampaignMarketingChannelLv1Set.add(ec.Marketing_Channel_Lv1__c);
            } else {

                if (u.UserRole.Name != null && u.UserRole.Name.contains(ec.Role__c)) {
                    excludedCampaignMarketingChannelLv1Set.add(ec.Marketing_Channel_Lv1__c);
                }
            }
        }
    }
}