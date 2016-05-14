public class Constants {


    private static RecordTypeLookup appointmentRTLookup{get{
        if(appointmentRTLookup == null){
           appointmentRTLookup = new RecordTypeLookup('SELECT id, DeveloperName FROM RecordType WHERE SObjectType = \'Appoitment__c\'');
        } return appointmentRTLookup;
    }
    set;}
    private static RecordTypeLookup opportunityRTLookup{get{
        if(opportunityRTLookup == null){
           opportunityRTLookup = new RecordTypeLookup('SELECT id, DeveloperName FROM RecordType WHERE SObjectType = \'Opportunity\'');
        } return opportunityRTLookup;
    }
    set;}
    private static RecordTypeLookup campaignRTLookup{get{
        if(campaignRTLookup == null){
           campaignRTLookup = new RecordTypeLookup('SELECT id, DeveloperName FROM RecordType WHERE SObjectType = \'Campaign\'');
        } return campaignRTLookup;
    }
    set;}
    private static RecordTypeLookup organizationRTLookup{get{
        if(organizationRTLookup == null){
           organizationRTLookup = new RecordTypeLookup('SELECT id, DeveloperName FROM RecordType WHERE SObjectType = \'Organization__c\'');
        } return organizationRTLookup;
    }set;}

    //////////////////////////////
    //
    // Appointment related constants
    //
    //////////////////////////////

    public static Id APP_RT_INVITATION_ID{
        get{
            return appointmentRTLookup.objMap.get('Invitation').Id;
        }
        set;
    }
    public static Id APP_RT_ASSIGNMENT_ID{
        get{
            return appointmentRTLookup.objMap.get('Assignment').Id;
        }
        set;
    }
    public static Id APP_RT_CONS_REFERRAL_FOLLOW_UP_ID{
        get{
            return appointmentRTLookup.objMap.get('Consultant_Referral_Follow_Up').Id;
        }
        set;
    }
    public static Id APP_RT_FDA_VISITED_ID{
        get{
            return appointmentRTLookup.objMap.get('Front_Desk_Visit').Id;
        }
        set;
    }

    //////////////////////////////
    //
    // Contract related constants
    //
    //////////////////////////////

    // Record Types
    private static RecordTypeLookup contractRTLookup = new RecordTypeLookup('SELECT id, DeveloperName FROM RecordType WHERE SObjectType = \'Contract__c\'');
    public static Id CONTRACT_RT_COUNSELLING_ID{
        get{
            return contractRTLookup.objMap.get('Counselling').Id;
        }
        set;
    }

    //////////////////////////////
    //
    // Opportunity related constants
    //
    //////////////////////////////

    // Record Types
    public static Id OPP_RT_TESTPREP_ID{
        get{
            return opportunityRTLookup.objMap.get('TestPrep').Id;
        }
        set;
    }
    public static Id OPP_RT_COUNSELLING_ID{
        get{
            return opportunityRTLookup.objMap.get('Counselling').Id;
        }
        set;
    }
    public static Id OPP_RT_COOPERATIVE_ID{
        get{
            return opportunityRTLookup.objMap.get('Cooperative').Id;
        }
        set;
    }
    public static Id OPP_RT_SCHOLAR_TREE_ID{
        get{
            return opportunityRTLookup.objMap.get('Scholar_Tree').Id;
        }
        set;
    }
    public static Id OPP_RT_SUBAGENT_ID{
        get{
            return opportunityRTLookup.objMap.get('Subagent').Id;
        }
        set;
    }
    public static String OPP_RT_TESTPREP_NAME = System.Label.Testprep;
    public static String OPP_RT_COUNSELLING_NAME = System.Label.Counselling;
    public static String OPP_RT_COOPERATIVE_NAME = System.Label.Cooperative;
    public static String OPP_RT_SCHOLAR_TREE_NAME = System.Label.ScholarTree;

    public static List<string> OPP_ALL_EIC_RECORD_TYPES = new List<String>{
        OPP_RT_TESTPREP_NAME, OPP_RT_COUNSELLING_NAME, OPP_RT_COOPERATIVE_NAME, OPP_RT_SCHOLAR_TREE_NAME
    };

    // Record Type Groups
    public static final Set<Id> OPP_RT_TESTPREP_COOP_IDS= new Set<Id>{
      OPP_RT_TESTPREP_ID,
      OPP_RT_COOPERATIVE_ID};

    //////////////////////////////
    //
    // Role related constants
    //
    //////////////////////////////

    // Roles
       // Get All Roles
    public static List<UserRole> userRoleList {
        get {
            if (userRoleList == null) {
                userRoleList = [Select Id, Name
                                From UserRole];
            }
            return userRoleList;
        }
        set;
    }

    public static Map<String, Id> roleNameIdMap {
        get {
            if (roleNameIdMap == null) {
                roleNameIdMap = new Map<String, Id>();
                for (UserRole role: userRoleList) {
                    roleNameIdMap.put(role.Name, role.Id);
                }
            }
            return roleNameIdMap;
        }
        set;
    }

    // Roles
    public static Id ROLE_TMK_HQ_STAFF_ID{
        get {

            return roleNameIdMap.get('集团呼叫中心TMK');
        }
        set;
    }

    public static Id ROLE_SALES_SH_MANAGER_ID{
        get {

            return roleNameIdMap.get('留学上海分公司澳新部销售主管');
        }
        set;
    }


    // Role Groups


    //////////////////////////////
    //
    // Profile related constants
    //
    //////////////////////////////

    public static Id PROFILE_SYS_ADMIN_ID{
        get{
            return profileNameIdMap.get(System.Label.System_Administrator);
        }
        set;
    }
    public static Id PROFILE_TMK_CUSTOMER_SERVICE_ID{
        get{
            return profileNameIdMap.get('集团市场部呼叫中心专员');
        }
        set;
    }
    public static Id PROFILE_TMK_CUSTOMER_SERVICE_MANAGER_ID{
        get{
            return profileNameIdMap.get('集团市场部呼叫中心主管');
        }
        set;
    }

    public static Id PROFILE_SALES_MANAGER_ID{
        get{
            return profileNameIdMap.get('分公司分校销售主管');
        }
        set;
    }

    public static Id PROFILE_MARKET_SUBAGENT_ID{
        get{
            return profileNameIdMap.get('分公司市场下级代理');
        }
        set;
    }

    public static Id PROFILE_LOCAL_CS_MANAGER_ID{
        get{
            return profileNameIdMap.get('分公司分校客服主管');
        }
        set;
    }

    public static Id PROFILE_LOCAL_CS_ID{
        get{
            return profileNameIdMap.get('分公司分校客服专员');
        }
        set;
    }

    public static Id PROFILE_COUNSELLING_CS_FRONT_DESK_ID{
        get{
            return profileNameIdMap.get('留学分公司客服前台主管');
        }
        set;
    }

    public static List<Profile> profileIdList {
        get {
            if (profileIdList == null) {
                profileIdList = [
                    Select Id, Name
                    From Profile
                ];
            }
            return profileIdList;
        }
        set;
    }

    public static Map<String, Id> profileNameIdMap {
        get {
            if (profileNameIdMap == null) {
                profileNameIdMap = new Map<String, Id>();
                for (Profile prof: profileIdList) {
                    profileNameIdMap.put(prof.Name, prof.Id);
                }
            }
            return profileNameIdMap;
        }
        set;
    }

    // Profile Groups
    public static final Set<Id> TMK_PROFILE_IDS = new Set<Id>{
        PROFILE_TMK_CUSTOMER_SERVICE_ID,
        PROFILE_TMK_CUSTOMER_SERVICE_MANAGER_ID};

    public static final Set<Id> TMK_AND_SYS_ADMIN_PROFILE_IDS = new Set<Id>{
        PROFILE_SYS_ADMIN_ID,
        PROFILE_TMK_CUSTOMER_SERVICE_ID,
        PROFILE_TMK_CUSTOMER_SERVICE_MANAGER_ID};

    public static final Set<Id> CENTER_CUSTOMER_SERVICE_PROFILE_IDS = new Set<Id>{
        PROFILE_LOCAL_CS_MANAGER_ID,
        PROFILE_LOCAL_CS_ID,
        PROFILE_COUNSELLING_CS_FRONT_DESK_ID};

    //////////////////////////////
    //
    // Campaign related constants
    //
    //////////////////////////////

    public static final String CAMP_RESOURCE_EXCHANGE_GROUP_NAME = '集团客服资源互换';
    public static final String CAMP_CUSTOMER_REFERRAL_GROUP_NAME = '集团客服互荐';

    // Record Types
    public static Id CAMP_RT_LEVEL_4_PROMO_CHANNEL{
        get{
            return campaignRTLookup.objMap.get('Level_4_Promotion_Channel').Id;
        }
        set;
    }

    //////////////////////////////
    //
    // Lead related constants
    //
    //////////////////////////////

    public static final Set<String> COOPERATIVE_EDUCATION_CITIES = new Set<String> { '广州' };
    public static final Set<String> TESTPREP_CITIES = new Set<String> { '上海', '北京', '南京', '厦门', '广州',
                                                                        '成都', '杭州', '武汉', '济南', '深圳',
                                                                        '珠海', '重庆', '长沙' };
    public static final Set<String> NP_CITIES = new Set<String> { '上海' };

    //////////////////////////////
    //
    // Organization related constants
    //
    //////////////////////////////

    // Record Types
    public static Id ORG_RT_TESTPREP_ID{
        get{
            if(ORG_RT_TESTPREP_ID == null)
            {
                ORG_RT_TESTPREP_ID = organizationRTLookup.objMap.get('TestPrep').Id;
            }
            return ORG_RT_TESTPREP_ID;
        }
        set;}
    public static Id ORG_RT_COUNSELLING_ID{
        get{
            if(ORG_RT_COUNSELLING_ID == null)
            {
                ORG_RT_COUNSELLING_ID = organizationRTLookup.objMap.get('Counselling').Id;
            }
            return ORG_RT_COUNSELLING_ID;
        }
        set;}
    public static Id ORG_RT_COOPERATIVE_ID{
        get{
            if(ORG_RT_COOPERATIVE_ID == null)
            {
                ORG_RT_COOPERATIVE_ID = organizationRTLookup.objMap.get('Cooperative').Id;
            }
            return ORG_RT_COOPERATIVE_ID;
        }
        set;}

    //////////////////////////////
    //
    // Business Line related constants
    //
    //////////////////////////////

    public static String BL_TESTPREP_NAME = System.Label.Testprep;
    public static String BL_COUSELLING_NAME = System.Label.Counselling;
    public static String BL_COOPERATIVE_NAME = System.Label.Cooperative;
    public static String BL_SCHOLAR_TREE_NAME = System.Label.ScholarTree;
    public static String BL_NP_NAME = System.Label.Np;

    public static final List<String> ALL_BUSINESS_LINE_NAMES = new List<String>{
        BL_TESTPREP_NAME, BL_COUSELLING_NAME, BL_COOPERATIVE_NAME, BL_SCHOLAR_TREE_NAME, BL_NP_NAME
    };

    // Declares AccountQuickSearch.cls Message 
    public static String NO_RESULT = '未搜索到该用户请尝试用联系方式搜索';
    public static String SEARCH_CONTENT_LENGTH_INCORRECT = '请输入大于两个字符';

    // Declares Appointments' record types' chinese name 
    public static String APP_INVITATION = '邀约'; // Appointment invitation record type chinese name 
    public static String APP_ASSIGNMENT = '任务'; // Appointment assignment record type chinese name 
    public static String APP_REMINDER = '提醒'; // Appointment reminder record type chinese name 

    // Declares Appoitments' statuc__c picklist Value
    public static String APP_VISITED = '已到访'; //  Customer already vistied center
    public static String APP_NEXT_TIME_VISIT = '再约'; // Invite customer, but customer won't show, and  will come next time.
    public static String APP_COMPLETED = '已完成'; // Assingments had been completed on time
    public static String APP_COMPLETED_DELAY = '逾期完成'; // Assingments had not been completed on time
    public static String APP_EXPIRED = '已失效'; // Appointments expired
    public static String APP_UNCOMPLETED = '未完成'; // Assingments haven't be completed yet
    public static String APP_FOLLOWING ='跟进中'; // Appointments are still following by course cousltant
    public static String APP_NOVISIT = '未到访'; // Customer won't show, and don't willing to come next time.
    public static String APP_FOLLOWUP_RESULT_REFUSE_CN = '拒绝回访';
    
    public static List<String> APP_CLOSED_STATUSES = new List<String>{
        APP_VISITED,
        APP_NEXT_TIME_VISIT,
        APP_COMPLETED,
        APP_COMPLETED_DELAY,
        APP_EXPIRED
    };

    // Declares Appointments' Appointment_Type__c picklist Value
    public static String APP_FIRST_DAY_ASS = '第0天任务'; // 1st day assignment
    public static String APP_THIRD_DAY_ASS = '第3天任务'; // 3rd day assignment
    public static String APP_FIFTH_DAY_ASS = '第5天任务'; // 5th day assignment
    public static String APP_SEVENTH_DAY_ASS = '第7天任务'; // 7th day assignment
    public static String APP_SIXTH_DAY_ASS = '第6天任务'; // 6th day assignment
    public static String APP_FIRST_SHOWUP_CN = '首次到访邀约'; // first time visited
    public static String APP_FDA_TYPE_CN = '前台到访'; // FDA Visited Type
    public static String APP_TYPE_INVITE_AGAIN = '再次到访邀约';

    // Declare associate deparement
    public static String CUSTOMER_SERVER = '客服'; // Customer server

    // Declare AppointmentOwnerChangeController'message
    public static String NO_ASSIGNMENT_SELECTED = '请先选择所需要分配的工作任务';
    public static String CHANGE_WITH_NO_ACCESS_APP = '只能修改我的未完成第五天任务到指定接收人，请检查您的视图筛选条件';
    public static String NO_SELECTED_ACCEPTOR = '请选择分配用户后再进行分配';

    // Declares the campaign upload function message
    public static String CAMPAIGN_RECORD_TYPE_NULL_ERROR = '记录类型不能为空; ';
    public static String CAMPAIGN_CHOOSE_RECORD_TYPE_ERROR = '请根据模板选择正确的记录类型; ';
    public static String CAMPAIGN_DUP_IN_FILE_ERROR = '文件内名称重复; ';
    public static String CAMPAIGN_START_DATE_ERROR = '开始日期格式不正确; ';
    public static String CAMPAIGN_END_DATE_ERROR = '结束日期格式不正确; ';
    public static String CAMPAIGN_BUDGET_ERROR = '预算成本格式不正确; ';
    public static String CAMPAIGN_LV2_PROMOTION_CHANNEL_ERROR = '二级推广方式不匹配; ';
    public static String CAMPAIGN_LV3_PROMOTION_CHANNEL_ERROR = '三级推广方式不匹配; ';
    public static String CAMPAIGN_DUP_IN_SYSTEM_ERROR = '系统内名称重复; ';
    public static String CAMPAIGN_APPROVER_ERROR = '审批人不存在; ';

    // Delcares campaign channel handler message
    public static String CAMPAIGN_CHANNEL_HAS_DUP_ERROR = '该市场推广渠道在本批数据中重复！';
    public static String CAMPAIGN_CHANNEL_HAS_EXISTED_ERROR = '该市场推广渠道已存在！';
    public static String CAMPAIGN_CHANNEL_HAS_INACTIVE_ERROR = '该市场推广渠道已存在, 但是未激活！';
    
    // Declares lead convertion message
    public static String LEAD_CONVERT_NO_ITEM_ERROR = '您没有选择需要转化的意向, 请返回线索页面重新选择转化意向.';
    public static String LEAD_CONVERT_CONVERTED_ERROR = '此意向已经被转化, 请重新选择意向转化.';
    public static String LEAD_CONVERT_SLEEP_ERROR = '此线索商机已存在. 确认转化后, 此线索将会转化不成功休眠.';
    public static String LEAD_CONVERT_CONTACT_ERROR = '转化时, 座机和区号必须一起填写.';
    public static String LEAD_CONVERT_COUNTRY_ERROR = '转化时, 留学商机必须要填写国家.';
    public static String LEAD_CONVERT_PROJECT_ERROR = '转化时, 考培商机请选择至少一个项目.';
    public static String LEAD_CONVERT_COOPERATIVE_ERROR = '转化时, 合作办学商机请选择至少一个项目.';
    public static String LEAD_CONVERT_APPOINT_TIME_ERROR = '转化时, 邀约时间请同时填写日期和时间.';
    public static String LEAD_CONVERT_CONTACTS_ERROR = '线索联系方式中,与已有客户联系方式重复, 请联系管理员合并.';
    public static String LEAD_CONVERT_CONFLICT_ERROR = '因转化冲突, 请重新点击转化.';

    // Declares consultant referral message
    public static String CONSULTANT_REFERRAL_WITH_OPEN_OPP_ERROR = '无法顾问互荐, 您推荐的意向城市已有未关闭考培商机, 且不符合二次推荐条件';
    public static String CONSULTANT_REFERRAL_SECOND_ERROR = '无法顾问互荐, 您推荐的意向城市已有未关闭考培商机, 且已做过二次推荐';
    public static String CONSULTANT_REFERRAL_SCHEDULING_TABLE_ERROR = '您选择的意向城市和校区, 没有对应的排班表, 请先联系意向城市的校区主管创建排班表';
    public static String CONSULTANT_REFERRAL_CREATE_APP_NAME_INFO = '工作安排名将会保存后自动生成';

    // Declares lead split function message
    public static String LEAD_SPLIT_ERROR = '您不能删除此意向业务, 此意向业务已转化为商机(唯一码:';
    public static String LEAD_CREATION_PROMPT_INFO = '又来了新的线索';
    public static String SPLIT_ACCOUNT_ERROR = '拆分客户';

    // Declares mass convert lead
    public static String MASS_CONVERT_NO_ITEM_ERROR = '没有未转化的意向, 请重新选择.';

    // Declares lead picklist value
    public static String LEAD_STATUS_CONVERTED_DUP_CN = '关闭--重复线索转化成功';
    public static String LEAD_STATUS_CONVERTED_WON_CN = '关闭--转化商机成功';
    public static String LEAD_STATUS_WHOLE_CONVERTED_CN = '全部转化';
    public static String LEAD_STATUS_WHOLE_CONVERTED_VISITED_CN = '全部转化(到访)';
    public static String LEAD_STATUS_PARTIAL_CONVERTED_CN = '部分转化';
    public static String LEAD_STATUS_PARTIAL_CONVERTED_VISITED_CN = '部分转化(到访)';
    public static String LEAD_PHONE_STATUS_HASACCOUNT_CN = '可以导入线索, 但已存在客户!';
    public static String LEAD_PHONE_STATUS_HASLEAD_CN = '可以导入线索, 但已存在重复号码线索!';

    // Declares the lead item picklist value
    public static String LEAD_ITEM_STATUS_NEW_CN = '新建';
    public static String LEAD_ITEM_STATUS_FOLLOWUP_CN = '跟进中';
    public static String LEAD_ITEM_STATUS_SLEEP_AUTO_CN = '休眠自动';
    public static String LEAD_ITEM_STATUS_SLEEP_MANUALLY_CN = '休眠手动';
    public static String LEAD_ITEM_STATUS_LOST_SLEEP_MANUALLY_CN = '流失';
    public static String LEAD_ITEM_STATUS_CONVERTED_DUP_CN = '关闭--重复线索转化成功';
    public static String LEAD_ITEM_STATUS_CONVERTED_DUP_VISITED_CN = '关闭--重复线索转化成功(到访)';
    public static String LEAD_ITEM_STATUS_CONVERTED_WON_CN = '关闭--转化商机成功';
    public static String LEAD_ITEM_STATUS_CONVERTED_WON_VISITED_CN = '关闭--转化商机成功(到访)';
    public static String LEAD_ITEM_STATUS_OPEN_OPP_CN = '不能创建, 已存在未关闭商机！';
    public static String LEAD_ITEM_STATUS_WON_OPP_CN = '不能创建, 已存在已赢单商机！';
    public static String LEAD_ITEM_STATUS_HAS_LEAD_CN = '不能创建, 已存在未转化线索!';
    public static String LEAD_ITEM_STATUS_DUP_IN_CAMPAIGN_CN = '市场活动内重复';

    // Declares contact picklist value
    public static String CONTACT_RELATIONSHIP_CN = '客户本人';

    // Declares opportunity StagName picklist value
    public static String OPPORTUNITY_STAGE_UNASSIGNED = '待分配';
    public static String OPPORTUNITY_STAGE_FOLLOWUP_CN = '顾问跟进';
    public static String OPPORTUNITY_STAGE_CLOSED_LOST_CN = '流失';
    public static String OPPORTUNITY_STAGE_LOW_STAR = '低星资源池';
    public static String OPPORTUNITY_STAGE_CLOSED_WON = '签约';

    // Declares opportunity Transfer_Status__c picklist Value
    public static String OPPORTUNITY_TRANSFER_STATUS_ING = '转移中';

    // Declares common Chinese labels
    public static String VIEW_DETAILS_CN = '查看详情';
    public static String UNKNOWN_CN = '待定';   
    public static String MOBILE_CN = '手机';
    public static String FIX_PHONE_CN = '座机';
    public static String WECHAT_CN = '微信';
    public static String EMAIL_CN = '邮箱';
    public static String TESTPREP_CN = '考培';
    public static String COUNSELLING_CN = '留学';
    public static String STUDY_ABROAD_CN = '学游';
    public static String MINORITY_LANGUAGE_CN = '小语种';
    public static String DEPARTMENT_MINORITY_LANGUAGE_CN = '小语种部'; 
    public static String MINORITY_LANGUAGE_FRENCH_CN = '小语种-法语';
    public static String SCHOLAR_TREE_CN = '学树堂';
    public static String SCHOLAR_TREE_PROJECT_CN = '学树堂项目';
    public static String COOPERATIVE_CN = '合作办学';
    public static String COOPERATIVE_PROJECT_CN = '国际预科';
    public static String OTHER_PRODUCT_CN = '其它产品';
    public static String ACCOUNT_CN = '客户';
    public static String OPPORTUNITY_CN = '商机';
    public static String DEPARTMENT_TESTPREP_CN = '考试培训部门';
    public static String COOPERATIVE_ADMISSIONS_CN = '合作招生';
    public static String ADMISSIONS_REPRESENTATIVE_CN = '招生代表';
    public static String REFERRAL_CN = '推荐';
    public static String FIRST_REFERRAL_CN = '一次推荐';
    public static String SECOND_REFERRAL_CN = '二次推荐';
    public static String CONSULTANT_REFERRAL_CN = '顾问互荐';
    public static String TESTPREP_SA_REFERRAL_CN = '考培教服推荐';
    public static String OLD_CUSTOMER_REFERRAL_CN = '老客户推荐';
    public static String LEVEL_4_PROMOTION_CHANNEL_CN = '四级推广方式';
    public static String SUBAGENT_CN = '下级代理';
    public static String CLOSED_CN = '关闭';
    public static String APPROVED_CN = '审批通过';
    public static String CAMPAIGN_DUP_CN = '（重复）';
    public static String US_CN = '美国';
    public static String UK_CN = '英国';
    public static String CITY_BJ_CN = '北京';
    public static String CITY_SH_CN = '上海';
    public static String CITY_GZ_CN = '广州';
    public static String CITY_SZ_CN = '深圳';
    public static String F2F_CONSULTING_CN = '面询';
    public static String BRANCH_CONSULTING_CALLOUT_CN = '分公司分校顾问外呼';
    public static String SYSTEM_ADMIN_PROFILE_CN = '系统管理员';
    public static String SUCCESS_CN = '成功';    
    public static String OFFLINE_CN = '线下';

    // Declare SchedulingTableCreation chinese message
    public static String NO_SELECTED_PROJECT_OR_SOURCE = '请在排班表基本信息中先选择合适的项目及来源';
    public static String NO_SHCEDULING_TABLE_LINE = '请先创建排班表详情';
    public static String SCHED_TABLE_NAME_EMPTY = '排班表名称 不能为空';
    public static String SCHED_TABLE_PROJECT_SOURCE_EMPTY = '排班表接收商机项目/接收商机来源不能为空';
    public static String SCHED_TABLE_MANAGER_EMPTY = '排班管理员 不能为空';
    public static String SCHED_TABLE_INTERCEPT_EMPTY = '分配截流 不能为空';
    public static String SCHED_LINE_USER_EMPTY = '顾问不能为空';
    public static String SCHED_LINE_PROJECT_EMPTY = '排班表详情接收商机项目不能为空';
    public static String SCHED_LINE_TIME_EMPTY = '排班表详情工作结束及开始时间不能为空';
    public static String SCHED_LINE_STARTTIME_EMPTY = '排班表详情工作开始时间不能为空';
    public static String SCHED_LINE_ENDTIME_EMPTY = '排班表详情工作结束时间不能为空';
    public static String SCHED_LINE_USER_DUPLICATE = '排班表存在重复顾问';
    public static String SCHED_LINE_PROJECT_SOURCE_EMPTY = '负责项目及负责来源 不可为空';
    public static String JOB_CYCLE = '班次时间';

    // Declares OpportunityOwnerChangeController chinese message
    public static String NO_SELECTED_OPPS = '请先选择所需要分配的商机';
    public static String CHANGE_WITH_NO_ACCESS_OPPS = '请检查视图筛条件包含非下级代理商机,无法分配';
    public static String CONTAIN_TRANSFERING_OPPS = '请检查此次批量更改商机所有人的所有商机，存在正在转移过程中的商机，请等待当前批次转移结束后，再次操作';
}