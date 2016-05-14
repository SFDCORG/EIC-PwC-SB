/**************************************************************************************************
 * Name: Live800DataWrapper
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
global class Live800DataWrapper {

    global class IntServCon {
        public String Name; //文本
        public String gender; //后台维护
        public String phone; //固话,号码
        public String mobile; //手机号
        public String qq; //QQ
        public String email; //邮箱
        public String Column1; //咨询课程
        public String Column2; //省
        public String Column3; //媒体来源
        public String Column4; //网址,下拉框,后台维护
        public String Column5; //搜索词
        public String Column6; //意向校区
        public String Column7; //权重
        public String Column8; //聊天记录
        public String CUSTNAME; //创建人
        public String OPPO_WebService; //?
        public String OPPO_Updateby; //修改人
        public String Compwebsite; //客户备注
        public String NOTE; //机会备注
        public String CONSULTCOUNTRY; //留学国家，考培挖掘留学
    }

    global class AboardCon {
        public String NAME; //姓名
        public String PHONE; //电话
        public String MOBILE; //手机
        public String QQ; //QQ
        public String EMAIL; //Email
        public String COLUMN11; //分配客服,可空
        public String CUSTNAME; //(网询客服)    
        public String AREA; //访客区域
        public String URL; //
        public String NOTE; //备注
        public String COLUMN3; //搜索引擎来源
        public String COLUMN7; //咨询国家
        public String COMPANYNAME; //分公司
        public String MSN; //是否异地
        public String COLUMN2; //网站论坛来源
        public String COLUMN1; //报纸来源
        public String COLUMN4; //校园宣传来源
        public String COLUMN5; //启德学校来源, 已经改成"附属产品"
        public String COLUMN6; //其他渠道来源
        public String COLUMN8; //咨询新渠道分类
        public String COLUMN9; //关键词
        public String COLUMN10; //访问网址
        public String TRAININGITEM; //咨询课程
    }

    public static String InsertIntServLead (IntServCon con) {
        Lead lead = new Lead();
        List<Campaign> cams = new List<Campaign> ();
        String intendCity = '';
        lead.Is_Counselling__c = false;
        lead.Is_TestPrep__c = true;
        lead.Consultation_Mode__c = '网询';
        lead.LastName = con.Name;
        lead.Company = con.Name;
        lead.Gender__c = con.gender;

        // Receives the fix phone format
        if (String.isNotBlank(con.phone)) {
            List<String> fixPhone = con.phone.split('-');
            if (fixPhone.size() < 2) {

                return generateResponse('1', '座机请以区号-座机格式上传。');

            } else {
                lead.Area_Code__c = fixPhone[0];
                lead.Phone = fixPhone[1];
            }
        }

        lead.MobilePhone = con.mobile;
        if (con.qq != null && con.qq != '') {
            lead.QQ__c = Long.valueOf(con.qq.trim());
        }
        lead.Email = con.email;

        if (String.isBlank(con.Column1)) {

            return generateResponse('1', '上传CRM失败，没有考培项目。');
        }

        lead.TestPrep_Project__c = testPrepMap.get(con.Column1.trim());
        lead.Province__c = con.Column2;
        lead.Lead_Source__c = 'Live 800';

        if (con.Column6 != null && con.Column6 != '') {
            lead.Intended_City__c = cityMap.get(con.Column6);
            if (lead.Intended_City__c == null) {

                return generateResponse('1', '意向校区匹配不到意向城市。');
            }
            intendCity = cityMap.get(con.Column6);
        } else {

            return generateResponse('1', '对应的意向校区为空，请您确认!');
        }
        lead.Customer_Service__c = con.CUSTNAME;
        lead.Description = '客户备注：' + con.Compwebsite + '\r\n机会备注: ' + con.NOTE;
        lead.ChatLog__c = con.Column8;

        // 4级广告来源 查询关键字：当前年，当前月，来源关键字
        lead.Live800Channel__c = con.Column3;
        if (con.Column3 == '直接访问' ||
            con.Column3 == '留学官网' ||
            con.Column3 == '启德网站' ||
            con.Column3 == '移动网站') {
            cams = [SELECT Id, Name FROM Campaign WHERE Name =: con.Column3 AND Isactive = TRUE];
            if (cams.size() > 0) {
                lead.Campaign__c = cams[0].Id;

            } else {
                cams = [SELECT Id, Name FROM Campaign WHERE Name = 'Live800其他' AND Isactive = TRUE];
                lead.Campaign__c = cams[0].Id;
            }
        } else {
            String str = con.Column3;
            String queryStr = 'SELECT Id, Name FROM Campaign WHERE Name = \'' + str + '\' AND Isactive = TRUE';
            cams  = Database.query(queryStr);
            if (cams.size() > 0) {
                lead.Campaign__c = cams[0].Id;
            }
            else{
                cams = [SELECT Id, Name FROM Campaign WHERE Name = 'Live800其他' AND Isactive = TRUE];
                lead.Campaign__c = cams[0].Id;
            }
        }
        String isLocal = '';
        if (con.Column2.contains(intendCity)) {
            isLocal = '本地';

        } else {
            isLocal = '异地';
        }

        lead.OwnerId = GetAssignOwner('考培', intendCity, isLocal);
        lead.Is_Local__c = isLocal == '本地' ? TRUE : FALSE;
        if (String.isNotBlank(con.CONSULTCOUNTRY)) {
            Live800Flag.isTestPrepToCounselling = true;
            lead.Is_Counselling__c = true;
            lead.Counselling_Project__c = con.CONSULTCOUNTRY;
        }

        try {

            insert lead;
            CreateActivity(lead.OwnerId);
            if (cams[0].Name == 'Live800其他') {

                return generateResponse('0', '四级推广方式为：Live800其他');

            } else {

                return generateResponse('0', '四级推广方式为：' + con.Column3);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            if (e.getMessage().contains('商机')) {

                return generateResponse('1', '此资源已有重复商机。');

            }  else if (e.getMessage().contains('线索')) {

                return generateResponse('1', '此资源已有重复线索。');
            
            } else {
                return generateResponse('1',e.getMessage());
            }
        }
    }

    public static String InsertAboardLead(AboardCon con) {
        Lead lead = new Lead();
        List<Campaign> cams = new List<Campaign> ();
        if (String.isBlank(con.COMPANYNAME)) {

            return generateResponse('1', '没有输入意向城市。');
        }
        String intendCity = con.COMPANYNAME;
        if (con.COMPANYNAME.indexOf('北京海淀') != -1) {

            intendCity = '北京';
            lead.Intended_Office__c = '海淀';
        }

        System.debug(LoggingLevel.INFO, '*** con: ' + con);
        lead.Is_Counselling__c = true;
        lead.Is_TestPrep__c = false;
        lead.Consultation_Mode__c = '网询';
        lead.LastName = con.Name;
        lead.Company = con.Name;
        lead.Customer_Service__c = con.CUSTNAME;
        lead.Other_Product__c = con.COLUMN5;

        // Receives the fix phone format
        if (String.isNotBlank(con.PHONE)) {
            List<String> fixPhone = con.PHONE.split('-');
            if (fixPhone.size() < 2) {
                return generateResponse('1', '座机请以区号-座机格式上传。');

            } else {
                lead.Area_Code__c = fixPhone[0];
                lead.Phone = fixPhone[1];
            }
        }

        lead.MobilePhone = con.MOBILE;
        if (con.QQ != null && con.QQ != '') {
            lead.QQ__c = Long.valueOf(con.QQ.trim());
        }
        lead.Email = con.EMAIL;
        lead.Lead_Source__c = 'Live 800';
        lead.Description = con.NOTE;
        lead.Intended_City__c = con.COMPANYNAME;
        if (con.COMPANYNAME.indexOf('北京海淀') != -1) {
            lead.Intended_City__c = '北京';
            lead.Intended_Office__c = '海淀';
        }
        if (lead.Intended_City__c == null || lead.Intended_City__c == '') {

            return generateResponse('1', '意向城市为空');
        }
        if (String.isBlank(con.COLUMN7)) {

            return generateResponse('1', '没有留学国家。');
        }

        lead.Counselling_Project__c = con.COLUMN7.trim();
        if (lead.Counselling_Project__c.indexOf('学游') != -1) {
            lead.StudyTourResource__c = '网询学游直客';
        }
        if (String.isNotBlank(con.TRAININGITEM)) {
            Live800Flag.isCounsellingToTestPrep = true;
            lead.Is_TestPrep__c = true;
            lead.TestPrep_Project__c = testPrepMap.get(con.TRAININGITEM);
        }

        // 4级广告来源 查询关键字：当前年，当前月，来源关键字
        if (con.Column3 == null ||
            con.Column3.length() < 2 ||
            con.Column3 == '') {

            return generateResponse('1', '媒体来源必须填写' + con.Column3);
        } else {
            String media = con.Column3.substring(con.Column3.indexOf('-') + 1, con.Column3.length()); //谷歌搜索
            lead.Live800Channel__c = media;
            if (media == '直接访问' ||
                media == '留学官网' ||
                media == '启德网站' ||
                media == '移动网站') {
                cams = [SELECT Id, Name FROM Campaign WHERE Name = :media AND Isactive = TRUE];
                if (cams.size() > 0) {
                    lead.Campaign__c = cams[0].Id;
                } else {
                    cams = [SELECT Id, Name FROM Campaign WHERE Name = 'Live800其他' AND Isactive = TRUE];
                    lead.Campaign__c = cams[0].Id;
                }

            } else {
                String str = media;
                String queryStr = 'SELECT Id, Name FROM Campaign WHERE Name = \'' + str + '\' AND Isactive = TRUE';
                cams  = Database.query(queryStr);
                if (cams.size() > 0) {
                    lead.Campaign__c = cams[0].Id;
                }
                else{
                    cams = [SELECT Id, Name FROM Campaign WHERE Name = 'Live800其他' AND Isactive = TRUE];
                    lead.Campaign__c = cams[0].Id;
                }
            }
        }

        String isLocal = con.MSN == 'Y' ? '本地' : '异地';
        lead.OwnerId = GetAssignOwner('留学', intendCity, isLocal);
        lead.Is_Local__c = isLocal == '本地' ? TRUE : FALSE;

        try {
            insert lead;
            CreateActivity(lead.OwnerId);

            if (cams[0].Name == 'Live800其他') {

                return generateResponse('0', '四级推广方式为：Live800其他');
            } else {

                return generateResponse('0', '四级推广方式为：' + con.Column3);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            if (e.getMessage().contains('商机')) {

                return generateResponse('1', '此资源已有重复商机。');
            } else if (e.getMessage().contains('线索')) {

                return generateResponse('1', '此资源已有重复线索。');
            } else {
                return generateResponse('1', e.getMessage());
            }
        }
    }

    // Type = 留学|考培; intendCity = 意向城市;isLocal = 本地|异地
    private static String GetAssignOwner(String type, String intendCity, String isLocal) {
        String ownerId = '';

        String query1 = 'SELECT User__c, IsAssigned__c FROM Servicing_Table__c'
            + ' WHERE IsActived__c=true AND Business_Line__c LIKE \'%' + type + '%\''
            + ' AND (Intended_City__c = \'' + intendCity + '\' or Intended_City__c =\'全部\')'
            + ' AND IsLocal__c like \'%' + isLocal + '%\''
            + ' AND (IsWorking_123__c = TRUE OR IsWorking_45__c = TRUE OR IsWorking_67__c = TRUE)'
            + ' ORDER BY Order_No__c ASC';

        System.debug(LoggingLevel.INFO, '*** query1: ' + query1);
        List<Servicing_Table__c> serv1 = Database.query(query1);

        if (serv1.size() > 0) {
            List<Servicing_Table__c> serv1True = new List<Servicing_Table__c> ();
            List<Servicing_Table__c> serv1False = new List<Servicing_Table__c> ();
            for(Servicing_Table__c serv : serv1) {
                if (serv.IsAssigned__c) {
                    serv1True.add(serv);

                } else{
                    serv1False.add(serv);
                }
            }

            if (serv1False.size() == 0) {
                for(Servicing_Table__c serv : serv1) {
                    serv.IsAssigned__c = FALSE; 
                }
                ownerId = serv1[0].User__c;
                serv1[0].IsAssigned__c = TRUE;
                update serv1;

            } else{
                ownerId = serv1False[0].User__c;
                serv1False[0].IsAssigned__c = TRUE;

                update serv1False[0];
            }

        // if 结果 = 0 则分配给第二天最早的符合条件的记录
        } else {
            String dayOfWeek = System.now().format('EEEE');
            String nextworking = '';
            if (dayOfWeek == 'Monday' || dayOfWeek == 'Tuesday' || dayOfWeek == 'Wednesday' || dayOfWeek == 'Thursday') {
                nextworking = 'NextWorking_1234__c';

            } else {

                nextworking = 'NextWorking_567__c';
            }

            String query2 = 'SELECT User__c, IsAssigned__c' 
                + ' FROM Servicing_Table__c Where IsActived__c=true And Business_Line__c Like \'%' + type + '%\''
                + ' AND (Intended_City__c = \'' + intendCity + '\' or Intended_City__c =\'全部\')'
                + ' AND IsLocal__c like \'%' + isLocal + '%\''
                + ' ORDER BY ' + nextworking + ', Order_No__c ASC';
            List<Servicing_Table__c> serv2 = Database.query(query2);
            if (serv2.size() > 0) {
                List<Servicing_Table__c> serv2True = new List<Servicing_Table__c> ();
                List<Servicing_Table__c> serv2False = new List<Servicing_Table__c> ();
                for(Servicing_Table__c serv : serv2) {
                    if (serv.IsAssigned__c) {
                        serv2True.add(serv);

                    } else{
                        serv2False.add(serv);
                    }
                }

                if (serv2False.size() == 0) {
                    for(Servicing_Table__c serv : serv2) {
                        serv.IsAssigned__c = FALSE; 
                    }
                    ownerId = serv2[0].User__c;
                    serv2[0].IsAssigned__c = TRUE;
                    update serv2;

                } else {
                    ownerId = serv2False[0].User__c;
                    serv2False[0].IsAssigned__c = TRUE;
                    update serv2False[0];
                }

            } else{
                Group g = [SELECT Id FROM Group WHERE DeveloperName = 'TMK_Incharge' AND Type = 'Queue'];
                ownerId = g.Id;
            }
        }
        return ownerId;
    }

    public static String generateResponse(String success, String msg) {
        RET resp = new RET();
        resp.code = success;
        resp.msg = msg;
        system.debug(JSON.serialize(resp));
        return JSON.serialize(resp);
    }

    public class RET {
        public String code;
        public String msg;
    }

    private static void CreateActivity(String ownerId) {

        // If the owner is a queue, we don't create a reminder
        if (ownerId.substring(0, 3) == '00G') return;
        Task task = new Task ();
        task.OwnerId = ownerId;
        task.Subject = 'New Live 800 Call';
        task.IsReminderSet = TRUE;
        task.ReminderDateTime = System.Now();
        insert task;
    }

    public static Map<String, String> testPrepMap = new Map<String, String> {
        '综合英语' => '综合项目',
        'SAT' => 'SAT',
        'IELTS' => '雅思',
        'TOEFL' => '托福',
        '托福' => '托福',
        '雅思' => '雅思',
        'SAT/SSAT' => 'SAT',
        'GRE/GMAT' => 'GRE',
        '预科' => null,
        '网络课程' => null,
        '其他（AP/PTE/留学/等）' => null,
        '其他' => null,
        'VIP' => null,
        '小语种' => null
    };

    public static Map<String, String> counsellingMap = new Map<String, String> {
        '新西兰' => '新西兰',
        '澳洲' => '澳大利亚',
        '澳大利亚' => '澳大利亚',
        '英国' => '英国',
        '加拿大' => '加拿大',
        '美国' => '美国',
        '德国' => '德国',
        '荷兰' => '荷兰',
        '爱尔兰' => '爱尔兰',
        '瑞士' => '瑞士',
        '法国' => '法国',
        '日本' => '日本',
        '新加坡' => '新加坡',
        '韩国' => '韩国',
        '马来西亚' => '马来西亚',
        '西班牙' => '西班牙',
        '香港' => '香港',
        '澳门' => '澳门',
        '芬兰' => '芬兰',
        '意大利' => '意大利',
        '瑞典' => '瑞典',
        '挪威' => '挪威',
        '丹麦' => '丹麦',
        '比利时' => '比利时',
        '匈牙利' => '匈牙利',
        '波兰' => '波兰',
        '奥地利' => '奥地利',
        '台湾' => '台湾',
        '学游-美国' => '学游-美国',
        '学游-加拿大' => '学游-加拿大',
        '学游-澳新' => '学游-澳新',
        '学游-英爱' => '学游-英爱',
        '学游-欧洲' => '学游-欧洲',
        '学游-亚洲' => '学游-亚洲'
    };

    public static Map<String, String> cityMap = new Map<String, String>{
        '广州校区' => '广州',
        '珠海校区' => '珠海',
        '深圳校区' => '深圳',
        '长沙校区' => '长沙',
        '济南校区' => '济南',
        '成都校区' => '成都',
        '南京校区' => '南京',
        '上海校区' => '上海',
        '厦门校区' => '厦门',
        '杭州校区' => '杭州',
        '重庆校区' => '重庆',
        '武汉校区' => '武汉',
        '国贸分校' => '北京',
        '人大分校' => '北京',
        '银网分校' => '北京',
        '广州' => '广州',
        '珠海' => '珠海',
        '深圳' => '深圳',
        '长沙' => '长沙',
        '济南' => '济南',
        '成都' => '成都',
        '南京' => '南京',
        '上海' => '上海',
        '厦门' => '厦门',
        '杭州' => '杭州',
        '重庆' => '重庆',
        '武汉' => '武汉',
        '北京' => '北京'
    };
}