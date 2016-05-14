/**************************************************************************************************
 * Name: LeadUploaderTest
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class LeadUploaderTest {

    @isTest
    private static void testLeadUploader() {

        List<Project__c> projectList = new List<Project__c> ();
        Project__c p1 = new Project__c ();
        p1.Name = 'NP';
        p1.Project__c = 'ACT;AE;GMAT;GRE;SAT;SSAT;Subjects;托福;雅思;合作办学;中学项目;综合项目';
        projectList.add(p1);

        Project__c p2 = new Project__c ();
        p2.Name = '学树堂';
        p2.Project__c = '学树堂项目';
        projectList.add(p2);

        Project__c p3 = new Project__c ();
        p3.Name = '留学';
        p3.Project__c = '爱尔兰;澳大利亚;德国;法国;韩国;加拿大;美国;日本;新西兰;意大利;英国;荷兰;西班牙;芬兰;瑞士;瑞典;挪威;丹麦;马来西亚;新加坡;香港;澳门;台湾;奥地利;波兰;匈牙利;比利时;学游-美国;学游-加拿大;学游-澳新;学游-英爱;学游-欧洲;学游-亚洲;小语种';
        projectList.add(p3);

        Project__c p4 = new Project__c ();
        p4.Name = '考培';
        p4.Project__c = 'ACT;AE;GMAT;GRE;SAT;SSAT;Subjects;托福;雅思;合作办学;中学项目;综合项目';
        projectList.add(p4);

        Project__c p5 = new Project__c ();
        p5.Name = '合作办学';
        p5.Project__c = '合作办学项目';
        projectList.add(p5);
        insert projectList;

        ExcelUploaderOwnerMapping__c om1 = new ExcelUploaderOwnerMapping__c ();
        om1.Name = '1';
        om1.City__c = '集团';
        om1.Business_line__c = '全部';
        om1.Consultation_Mode__c = '集团TMK外呼';
        om1.Owner_Id__c = UserInfo.getUserId();
        insert om1;

        Campaign c1 = new Campaign ();
        c1.Name = '2015年12月PC百度品专UAT';
        c1.StartDate = System.today();
        c1.EndDate = System.today().addDays(30);
        c1.Approver__c = UserInfo.getUserId();
        c1.City__c = '集团';
        c1.Business_line__c = '全部';
        c1.Marketing_Channel_Lv1__c = '线上';
        c1.Marketing_Channel_Lv2__c = 'PC端';
        c1.Marketing_Channel_Lv3__c = '百度';
        c1.IsActive = true;
        insert c1;

        Test.startTest();

        String data = '{"销售线索":"","参考数据":[{"consultationMode":"400呼入呼叫中心","intendedCity":"北京","businessLine":"NP","project":"ACT;AE;GMAT;GRE;SAT;SSAT;Subjects;托福;雅思;合作办学;中学项目;综合项目"},{"consultationMode":"电询分公司分校","intendedCity":"长沙","businessLine":"学树堂","project":"学树堂项目"},{"consultationMode":"集团TMK外呼","intendedCity":"成都","businessLine":"学游","project":"学游-美国;学游-加拿大;学游-澳新;学游-英爱;学游-欧洲;学游-亚洲"},{"consultationMode":"面询","intendedCity":"大连","businessLine":"留学","project":"爱尔兰;澳大利亚;德国;法国;韩国;加拿大;美国;日本;新西兰;意大利;英国;荷兰;西班牙;芬兰;瑞士;瑞典;挪威;丹麦;马来西亚;新加坡;香港;澳门;台湾;奥地利;波兰;匈牙利;比利时;学游-美国;学游-加拿大;学游-澳新;学游-英爱;学游-欧洲;学游-亚洲;小语种"},{"consultationMode":"网询","intendedCity":"东莞","businessLine":"考培","project":"ACT;AE;GMAT;GRE;SAT;SSAT;Subjects;托福;雅思;合作办学;中学项目;综合项目"},{"consultationMode":"分公司分校顾问外呼","intendedCity":"福州","businessLine":"留学;考培"},{"consultationMode":"分公司分校客服外呼","intendedCity":"广州"},{"intendedCity":"杭州"},{"intendedCity":"济南"},{"intendedCity":"昆明"},{"intendedCity":"南昌"},{"intendedCity":"南京"},{"intendedCity":"宁波"},{"intendedCity":"青岛"},{"intendedCity":"汕头"},{"intendedCity":"上海"},{"intendedCity":"深圳"},{"intendedCity":"沈阳"},{"intendedCity":"石家庄"},{"intendedCity":"天津"},{"intendedCity":"武汉"},{"intendedCity":"西安"},{"intendedCity":"厦门"},{"intendedCity":"烟台"},{"intendedCity":"郑州"},{"intendedCity":"重庆"},{"intendedCity":"珠海"}],"Lead":[{"name":"谢丽霞2","mobile":"18611200002","areaCode":"021","phone":"35689038","campaignExternalCode":"2015年12月PC百度品专UAT","consultationMode":"集团TMK外呼","businessLine":"留学;考培","intendedCity":"上海","project":"美国","extensionAgent":" ","description":" ","errorMessage":" "},{"name":"谢丽霞3","mobile":"18611200003","campaignExternalCode":"2015年12月PC百度品专UAT","consultationMode":"集团TMK外呼","businessLine":"留学;考培","intendedCity":"沈阳","project":"英国","areaCode":" ","extensionAgent":" ","description":" ","phone":" ","errorMessage":" "},{"name":"谢丽霞4","mobile":"18611200004","campaignExternalCode":"2015年12月PC百度品专UAT","consultationMode":"集团TMK外呼","businessLine":"留学;考培","intendedCity":"上海","project":" ","areaCode":" ","extensionAgent":" ","description":" ","phone":" ","errorMessage":" "},{"name":"谢丽霞5","mobile":"18611200004","campaignExternalCode":"2015年12月PC百度品专UAT","consultationMode":"集团TMK外呼","businessLine":"留学;考培","intendedCity":"沈阳","project":"韩国","areaCode":" ","extensionAgent":" ","description":" ","phone":" ","errorMessage":" "},{"name":"谢丽霞6","areaCode":"021","phone":"35689038","campaignExternalCode":"2015年12月PC百度品专UAT","consultationMode":"集团TMK外呼","businessLine":"留学;考培","intendedCity":"沈阳","project":"韩国","extensionAgent":" ","description":" ","mobile":" ","errorMessage":" "},{"name":"谢丽霞7","areaCode":" ","phone":" ","campaignExternalCode":"PC百度品专UAT","consultationMode":"集团TMK外呼","businessLine":"留学;考培","intendedCity":"沈阳","project":"韩国","extensionAgent":" ","description":" ","mobile":"18611200009","errorMessage":" "}]}';

        ExcelUploaderV3Ctrl leadUploader = new ExcelUploaderV3Ctrl ();
        leadUploader.sObjectName = 'Lead';
        leadUploader.getExcelUploaderPreleadFieldMapping();
        leadUploader.getIntendedCities();
        leadUploader.getConsultationModes();
        leadUploader.getBusinessLines();

        ExcelUploaderV3Ctrl.uploadData(data);
        ExcelUploaderV3Ctrl.uploadData(data);

        Test.stopTest();

        List<Lead> leadList = [SELECT Id FROM Lead];
        System.assertEquals(3, leadList.size());
    }
}