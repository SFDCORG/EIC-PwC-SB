/**************************************************************************************************
 * Name: ProfileRelated
 * Object: Profile
 * Purpose: Utility for Profile
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Ray Cen    Create this class
 **************************************************************************************************/
global class ProfileRelated {
    public static String centerManger = '00e28000000IwBUAA0';          // #总经理/校长
    public static String FDA = '00e28000000IpILAA0';                   // #分公司分校前台
    public static String FDACS= '00e28000000J2ATAA0';                  // #分校客服前台
    public static String localCS = '00e28000000IsqYAAS';               // #分公司分校客服专员
    public static String CCCSManager = '00e28000000J2AUAA0';           // #分校销售客服主管
    public static String localCSManager = '00e28000000IwGGAA0';        // #分公司分校客服主管
    public static String localmrk = '00e28000000IomDAAS';              // #分公司分校市场专员
    public static String localmrkManager = '00e28000000IwGVAA0';       // #分公司分校市场主管
    public static String ccManager = '00e28000000IpJsAAK';             // #分公司分校销售主管
    public static String ccGroupManager = '00e28000000IwG6AAK';        // #分公司分校销售组长
    public static String cc = '00e28000000ImYrAAK';                    // #分公司分校销售顾问
    public static String HQmarketing = '00e28000000Iom8AAC';           // #集团市场部专员
    public static String HQmarketingManger = '00e28000000IwGfAAK';     // #集团市场部经理/总监
    public static String HQmarketingCS = '00e28000000IomIAAS';         // #集团市场部呼叫中心专员
    public static String HQmarketingCSManager = '00e28000000IwGaAAK';  // #集团市场部呼叫中心主管
    public static String HQOperation = '00e28000000IwGkAAK';           // #集团运营中心主管
    public static String HQOperationManager = '00e28000000IwGuAAK';    // #集团运营中心总监
    public static String HQDpOperationManager = '00e28000000IwGpAAK';  // #集团运营中心项目部经理/总监
    public static String adminlv2 = '00e28000000yygRAAQ';               // #system administrator
    public static String adminlv1 = '00e28000000IwGzAAK';               // #系统管理员
    public static String rolloutraining = '00e28000000J7DBAA0';         // Rollout Trainer
    public static String bot = '00e28000000IwzYAAS' ;                   //Prepsmith Bot
    public static String bot2 = '00e28000000IxHTAA0' ;                  //Prepsmith Bot2
    public static String testprepFDA = '00e28000000J7GeAAK' ;           //Prepsmith Bot2


    public static String testlocalCS = '00e28000000J7GjAAK' ;           //考培分校客服专员
    public static String testlocalCSManager = '00e28000000J7GoAAK' ;    //考培分校客服主管
    public static String testlocalmrk = '00e28000000J7GtAAK' ;          //考培分校市场专员
    public static String testlocalmrkManager = '00e28000000J7GyAAK' ;   //考培分校市场主管
    public static String testcenterManger = '00e28000000J7HDAA0' ;      //考培分校校长
    public static String testCCManager = '00e28000000J7H3AAK' ;         //考培分校销售主管
    public static String testCC = '00e28000000J7H8AAK' ;                //考培分校销售顾问
    public static String subAgent = '00e28000000JANQAA4';               //下级代理
    public static String channelStaff = '00e28000000JC6TAAW';           //渠道专员
    public static String marketSubAgent = '00e28000000JCRFAA4';         //分公司下级代理


    public static String conFDACS= '00e28000000JCCwAAO';                  //留学分公司客服前台专员
    public static String conFDACSManager= '00e28000000JCCmAAO';           //留学分公司客服前台专员

    // following profile can add contacts and view deciphering contacts number
    public static Set<ID> addViewContactsProfileSet()
    {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(centerManger);// #总经理/校长
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(CCCSManager); // #分校销售客服主管
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(cc); // #分公司分校销售顾问
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);
        
        profileIDSet.add(testcenterManger);
        profileIDSet.add(testCCManager);
        profileIDSet.add(testCC);

        return profileIDSet;
    }


    //only view the encrypt contact
    public static Set<ID> addViewAllContactsProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(FDACS); 
        profileIDSet.add(localCS);//分公司分校客服专员
        profileIDSet.add(localCSManager);//分公司分校客服主管
        profileIDSet.add(HQmarketingCS);//集团市场部呼叫中心专员
        profileIDSet.add(HQmarketingCSManager);//集团市场部呼叫中心主管
        profileIDSet.add(rolloutraining);

        profileIDSet.add(testlocalCSManager);
        profileIDSet.add(testlocalCS);

        profileIDSet.add(conFDACS);
        profileIDSet.add(conFDACSManager);

        return profileIDSet;
    }

    // In opportunity assign process, following profile can use the compensate opp function or not.
    public static Set<ID> oppcompensateProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(centerManger); // #总经理/校长
        profileIDSet.add(FDA); // #分公司分校前台
        profileIDSet.add(FDACS);
        profileIDSet.add(testprepFDA); 
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(CCCSManager);
        profileIDSet.add(testcenterManger);
        profileIDSet.add(testCCManager);
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);

        profileIDSet.add(conFDACS);
        profileIDSet.add(conFDACSManager);
        Return profileIDSet; //pending 
    }

 
    public static Set<ID> oppSchedulingTableOptionvisiableProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(centerManger);// #总经理/校长
        profileIDSet.add(FDA); // #分公司分校前台
        profileIDSet.add(FDACS); 
        profileIDSet.add(testprepFDA);
        profileIDSet.add(localCS);//分公司分校客服专员
        profileIDSet.add(localCSManager);//分公司分校客服主管
        profileIDSet.add(localmrk);//分公司分校市场专员
        profileIDSet.add(localmrkManager);//分公司分校市场主管
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(CCCSManager);
        profileIDSet.add(testcenterManger);
        profileIDSet.add(testCCManager);
        profileIDSet.add(testlocalCSManager);
        profileIDSet.add(testlocalCS);
        profileIDSet.add(testlocalmrk);
        profileIDSet.add(testlocalmrkManager);
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(HQmarketing);//集团市场部专员
        profileIDSet.add(HQmarketingManger);//集团市场部经理/总监
        profileIDSet.add(HQmarketingCS);//集团市场部呼叫中心专员
        profileIDSet.add(HQmarketingCSManager);//集团市场部呼叫中心主管
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);
        profileIDSet.add(marketSubAgent);
        profileIDSet.add(localmrk);
        profileIDSet.add(localmrkManager);
        profileIDSet.add(HQmarketing);
        profileIDSet.add(HQmarketingManger);
        profileIDSet.add(conFDACS);
        profileIDSet.add(conFDACSManager);
        Return profileIDSet;
    }
    
    public static Set<ID> oppGLobalTMKOptionvisiableProfileSet() {
       Set<ID> profileIDSet = new Set<ID>();
       
         profileIDSet.add(centerManger); // #总经理/校长
         profileIDSet.add(ccManager); // #分公司分校销售主管
         profileIDSet.add(ccGroupManager); //分公司分校销售组长
         profileIDSet.add(CCCSManager);
         profileIDSet.add(HQOperation);//集团运营中心主管
         profileIDSet.add(HQOperationManager);//集团运营中心总监
         profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
         profileIDSet.add(adminlv1);//系统管理员
         profileIDSet.add(adminlv2);//system administrator

       Return profileIDSet;
    }

    public static Set<ID> oppLocalTMKOptionvisiableProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
       
        profileIDSet.add(centerManger); // #总经理/校长
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(CCCSManager);
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator

        Return profileIDSet;
    }

    public static Set<ID> oppPoolOptionvisiableProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(cc); // #分公司分校销售顾问
        profileIDSet.add(centerManger); // #总经理/校长
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(CCCSManager);
        profileIDSet.add(testcenterManger);
        profileIDSet.add(testCCManager);
        profileIDSet.add(testCC);
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);

        return profileIDSet;
    }

    public static Set<ID> adminProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(adminlv2); // #system admin
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(bot);
        profileIDSet.add(bot2);

        return profileIDSet;
    }

    public static Set<ID> oppDirecltyAssignProfileSet() {   
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(centerManger); // #总经理/校长
        profileIDSet.add(FDA); // #分公司分校前台
        profileIDSet.add(FDACS); //#分公司前台客服
        profileIDSet.add(testprepFDA);
        profileIDSet.add(CCCSManager);
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(testcenterManger);
        profileIDSet.add(testCCManager);
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);
        profileIDSet.add(conFDACS);
        profileIDSet.add(conFDACSManager);
        Return profileIDSet;
    }

    public static Set<ID>   getFDAProfileSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(FDA);//#分公司分校前台
        profileIDSet.add(FDACS);
        profileIDSet.add(centerManger); // #总经理/校长
        profileIDSet.add(testcenterManger); // #分公司考培校长
        profileIDSet.add(testprepFDA);
       // profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);
        profileIDSet.add(conFDACS);
        profileIDSet.add(conFDACSManager);
        Return profileIDSet;
    }


    public static Set<ID>   getCCManagerSet()  {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(ccManager);
        profileIDSet.add(ccGroupManager);
        profileIDSet.add(CCCSManager);
        profileIDSet.add(testcenterManger);
        profileIDSet.add(testCCManager);
        profileIDSet.add(centerManger);
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);
        Return profileIDSet;
    }


    public static Set<ID> getTMKCallCenterSet() { 
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(HQmarketingCS);
        profileIDSet.add(HQmarketingCSManager);
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);

        Return profileIDSet;
    }

    public static Set<ID> getLocalCSSet() { 
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(localCS);
        profileIDSet.add(localCSManager);
        profileIDSet.add(CCCSManager);
        profileIDSet.add(testlocalCSManager);
        profileIDSet.add(testlocalCS);
        profileIDSet.add(adminlv2);
        profileIDSet.add(FDACS);
        profileIDSet.add(conFDACS);
        profileIDSet.add(conFDACSManager);
        Return profileIDSet;
    }

    webservice static Boolean checkFDAprofile(String profileID) {
        return getFDAProfileSet().contains(profileID)||adminProfileSet().contains(profileID);
    }

    webservice static Boolean checkAdminprofile(String profileID) {
       return adminProfileSet().contains(profileID);
    }

    public static ID getProfileIDofUser(Id userid) {
       return [SELECT ProfileId FROM User WHERE Id = :userid LIMIT 1].ProfileId;
    }

    public static Set<ID> appCreattionpermissionSet() {
        Set<ID> profileIDSet = new Set<ID>();
        profileIDSet.add(ccManager); // #分公司分校销售主管
        profileIDSet.add(ccGroupManager); //分公司分校销售组长
        profileIDSet.add(cc);
        profileIDSet.add(CCCSManager);
        profileIDSet.add(HQOperation);//集团运营中心主管
        profileIDSet.add(HQOperationManager);//集团运营中心总监
        profileIDSet.add(HQDpOperationManager);//集团运营中心项目部经理/总监
        profileIDSet.add(adminlv1);//系统管理员
        profileIDSet.add(adminlv2);//system administrator
        profileIDSet.add(rolloutraining);
        profileIDSet.add(testcenterManger);
        profileIDSet.add(centerManger);

        return profileIDSet;
    }
}