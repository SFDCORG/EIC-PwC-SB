/**************************************************************************************************
 * Name: Live800Test
 * Object: Campaign, Lead, Lead_Item__c
 * Purpose: test class for Live800DataWrapper to test the live800 interface
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
@isTest
private class Live800Test {

    @isTest static void method1() {

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        System.runAs(u) {
            User sophie = new User ();
            sophie.Username= 'sophiezhou@eic.com.testcode';
            sophie.Email = 'sophiezhou@eiceducation.com.cn.testcode';
            sophie.Lastname = 'sophie';
            sophie.Firstname = 'zhou';
            sophie.Alias = 'sophie';
            sophie.ProfileId = [SELECT Id FROM Profile WHERE Name='集团市场部呼叫中心主管'].Id;
            sophie.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName='Marketing_HQ_Null_CS_TMK_Incharge'].Id;
            sophie.TimeZoneSidKey = 'GMT';
            sophie.LocaleSidKey = 'en_US';
            sophie.EmailEncodingKey = 'ISO-8859-1';
            sophie.LanguageLocaleKey = 'en_US';
            sophie.UserPermissionsMobileUser = false;
            insert sophie;

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '百度';
            campaign1.IsActive = TRUE;
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '百度';
            campaign1.Marketing_Channel_Lv2__c = '百度';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;

            Campaign campaign2 = new Campaign ();
            campaign2.Name = 'Live800其他';
            campaign2.IsActive = TRUE;
            campaign2.StartDate = System.Today();
            campaign2.EndDate = System.Today().addDays(30);
            campaign2.Approver__c = UserInfo.getUserId();
            campaign2.Marketing_Channel_Lv1__c = 'Live800其他';
            campaign2.Marketing_Channel_Lv2__c = 'Live800其他';
            campaign2.Marketing_Channel_Lv3__c = 'Live800其他';
            insert campaign2;

            Campaign campaign3 = new Campaign ();
            campaign3.Name = '直接访问';
            campaign3.IsActive = TRUE;
            campaign3.StartDate = System.Today();
            campaign3.EndDate = System.Today().addDays(30);
            campaign3.Approver__c = UserInfo.getUserId();
            campaign3.Marketing_Channel_Lv1__c = '直接访问';
            campaign3.Marketing_Channel_Lv2__c = '直接访问';
            campaign3.Marketing_Channel_Lv3__c = '直接访问';
            insert campaign3;

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/Live800ForIntServ';
            req.addParameter('MOBILE', '13309876535');
            req.addParameter('COLUMN1', '综合英语');
            req.addParameter('COLUMN2', '上海');
            req.addParameter('COLUMN3', '百度');
            req.addParameter('COLUMN4', '');
            req.addParameter('COLUMN5', '');
            req.addParameter('CUSTNAME', 'phoebetang');
            req.addParameter('NOTE', 'nnttt');
            req.addParameter('CONSULTCOUNTRY', '');
            req.addParameter('NAME', 'kkk1');
            req.addParameter('EMAIL', '');
            req.addParameter('COLUMN6', '上海校区');
            req.addParameter('PHONE', '010-1234567');
            req.addParameter('COLUMN7', '2');
            req.addParameter('COLUMN8', 'klkl');
            req.addParameter('COLUMN9', 'hello');
            req.addParameter('QQ', '1234567');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            Live800ForIntServ.doGet();

            req.requestURI = '/Live800ForIntServ'; 
            req.addParameter('PHONE', '010-1234567'); 
            req.addParameter('COLUMN1', '');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res; 
            Live800ForIntServ.doGet();

            req.requestURI = '/Live800ForIntServ'; 
            req.addParameter('PHONE', ''); 
            req.addParameter('COLUMN1', '综合英语');
            req.addParameter('QQ', 'abcd');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res; 
            Live800ForIntServ.doGet();

            req.requestURI = '/Live800ForIntServ'; 
            req.addParameter('COLUMN6', ''); 
            req.addParameter('QQ', '');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res; 
            Live800ForIntServ.doGet();

            req.requestURI = '/Live800ForIntServ'; 
            req.addParameter('COLUMN6', '上海地区'); 
            RestContext.request = req;
            RestContext.response = res;
            Live800ForIntServ.doGet();

            req.requestURI = '/Live800ForIntServ';
            req.addParameter('COLUMN6', '上海校区');
            req.addParameter('COLUMN3', '直接访问');
            RestContext.request = req;
            RestContext.response = res;
            Live800ForIntServ.doGet();
            List<Lead> ls = [SELECT Id, Campaign__r.Name FROM Lead WHERE MobilePhone = '13309876535'];

            req.requestURI = '/Live800ForIntServ';
            req.addParameter('COLUMN3', '启德网站');
            RestContext.request = req;
            RestContext.response = res;
            Live800ForIntServ.doGet();
        
            req.requestURI = '/Live800ForIntServ'; 
            req.addParameter('COLUMN3', '百度'); 
            RestContext.request = req;
            RestContext.response = res; 
            Live800ForIntServ.doGet();
            Live800ForIntServ.doGet();

            ls = [SELECT Id FROM Lead];
            delete ls;
            
            Servicing_Table__c st = new Servicing_Table__c();
            st.User__c = sophie.Id;
            st.Order_No__c = '1';
            st.Business_Line__c= '留学,考培';
            st.Intended_City__c= '全部';
            st.IsLocal__c = '本地异地';
            st.IsActived__c = true;
            st.MonS1__c = '0';
            st.MonE1__c = '24';
            st.MonS2__c = '0';
            st.MonE2__c = '24';
            st.TueS1__c = '0';
            st.TueE1__c = '24';
            st.TueS2__c = '0';
            st.TueE2__c = '24';
            st.WedS1__c = '0';
            st.WedE1__c = '24';
            st.WedS2__c = '0';
            st.WedE2__c = '24';
            st.ThuS1__c = '0';
            st.ThuE1__c = '24';
            st.ThuS2__c = '0';
            st.ThuE2__c = '24';
            st.FriS1__c = '0';
            st.FriE1__c = '24';
            st.FriS2__c = '0';
            st.FriE2__c = '24';
            st.SatS1__c = '0';
            st.SatE1__c = '24';
            st.SatS2__c = '0';
            st.SatE2__c = '24';
            st.SunS1__c = '0';
            st.SunE1__c = '24';
            st.SunS2__c = '0';
            st.SunE2__c = '24';
            insert st;
            req.requestURI = '/Live800ForIntServ';
            req.addParameter('CONSULTCOUNTRY', '美国');
            RestContext.request = req;
            RestContext.response = res; 
            Live800ForIntServ.doGet();
        }
    }

    @isTest static void method2() {

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        System.runAs(u) {

            User sophie = new User ();
            sophie.Username = 'sophiezhou@eic.com.testcode';
            sophie.Email = 'sophiezhou@eiceducation.com.cn.testcode';
            sophie.Lastname = 'sophie';
            sophie.Firstname = 'zhou';
            sophie.Alias = 'sophie';
            sophie.ProfileId = [SELECT Id FROM Profile WHERE Name = '集团市场部呼叫中心主管'].Id;
            sophie.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Marketing_HQ_Null_CS_TMK_Incharge'].Id;
            sophie.TimeZoneSidKey = 'GMT';
            sophie.LocaleSidKey = 'en_US';
            sophie.EmailEncodingKey = 'ISO-8859-1';
            sophie.LanguageLocaleKey = 'en_US';
            sophie.UserPermissionsMobileUser = false;
            insert sophie;

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '百度';
            campaign1.IsActive = TRUE;
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '百度';
            campaign1.Marketing_Channel_Lv2__c = '百度';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;

            Campaign campaign2 = new Campaign ();
            campaign2.Name = 'Live800其他';
            campaign2.IsActive = TRUE;
            campaign2.StartDate = System.Today();
            campaign2.EndDate = System.Today().addDays(30);
            campaign2.Approver__c = UserInfo.getUserId();
            campaign2.Marketing_Channel_Lv1__c = 'Live800其他';
            campaign2.Marketing_Channel_Lv2__c = 'Live800其他';
            campaign2.Marketing_Channel_Lv3__c = 'Live800其他';
            insert campaign2; 

            Campaign campaign3 = new Campaign ();
            campaign3.Name = '直接访问';
            campaign3.IsActive = TRUE;
            campaign3.StartDate = System.Today();
            campaign3.EndDate = System.Today().addDays(30);
            campaign3.Approver__c = UserInfo.getUserId();
            campaign3.Marketing_Channel_Lv1__c = '直接访问';
            campaign3.Marketing_Channel_Lv2__c = '直接访问';
            campaign3.Marketing_Channel_Lv3__c = '直接访问';
            insert campaign3;

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.addParameter('AREA', '');
            req.addParameter('COLUMN10', '');
            req.addParameter('COLUMN11', 'saberlawei');
            req.addParameter('COLUMN1', '');
            req.addParameter('COLUMN2', '');
            req.addParameter('COLUMN3', '百度');
            req.addParameter('COLUMN4', '');
            req.addParameter('COLUMN5', '');
            req.addParameter('COLUMN6', '');
            req.addParameter('COLUMN7', '英国');
            req.addParameter('COLUMN8', 'PC咨询');
            req.addParameter('COLUMN9', '');
            req.addParameter('COMPANYNAME', '上海');
            req.addParameter('CUSTNAME', 'phoebetang');
            req.addParameter('EMAIL', '');
            req.addParameter('MOBILE', '15809091212');
            req.addParameter('MSN', 'Y');
            req.addParameter('NAME', 'kkk2');
            req.addParameter('NOTE', '');
            req.addParameter('PHONE', '');
            req.addParameter('QQ', '');
            req.addParameter('TRAININGITEM', '');
            req.addParameter('URL', '');
            RestContext.request = req;
            RestContext.response = res;
            Live800ForAboard.doGet();

            req.addParameter('COMPANYNAME', '');
            Live800ForAboard.doGet();

            req.addParameter('COMPANYNAME', '上海');
            req.addParameter('PHONE', '0101234567');
            Live800ForAboard.doGet();

            req.addParameter('PHONE', '010-1234567');
            req.addParameter('QQ', 'abcd');
            Live800ForAboard.doGet();

            req.addParameter('QQ', '');
            req.addParameter('COMPANYNAME', '');
            Live800ForAboard.doGet();

            req.addParameter('COMPANYNAME', '上海');
            req.addParameter('COLUMN7', '');
            Live800ForAboard.doGet();

            req.addParameter('COLUMN7', '澳新（学游）');
            req.addParameter('TRAININGITEM', '雅思');
            req.addParameter('COLUMN3', '');
            Live800ForAboard.doGet();

            req.addParameter('COLUMN3', '直接访问');
            Live800ForAboard.doGet();

            req.addParameter('COLUMN3', '启德网站');
            Live800ForAboard.doGet();
            Live800ForAboard.doGet();
            List<Lead> ls = [SELECT Id, Campaign__r.Name FROM Lead];
            delete ls;
            req.addParameter('COLUMN3', '启德网站');
            Live800ForAboard.doGet();
        }
    }
}