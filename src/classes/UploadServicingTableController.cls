/**************************************************************************************************
 * Name: UploadServicingTableController
 * Object: Servicing_Table__c
 * Purpose: Update Servicing table
 * Author: Vicia Wang (vicia.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-05-08    Vicia Wang    Create this class
 **************************************************************************************************/
public without sharing class UploadServicingTableController {

    public UploadServicingTableController() {}

    @RemoteAction
    public static List<ErrorWrap> uploadData (String param) {

        System.debug('LoggingLevel.INFO, *** param: ' + param);
        List<Servicing_Table__c> srvTable = new List<Servicing_Table__c> ();
        List<ErrorWrap> errorList = new List<ErrorWrap> ();
        String data = EncodingUtil.urlDecode(param, 'UTF-8');
        Map<String,Object> dm = (Map<String,Object>) JSON.deserializeUntyped(data);
        List<Object> itemList = (List<Object>) dm.get('TMK值班表');
        Set<String> usernames = new Set<String> ();

        for (Object o : itemList) {
            Map<String,Object> obj = (Map<String,Object>) o;
            usernames.add(String.valueOf(obj.get('外呼人员')));
        }
        System.debug('LoggingLevel.INFO, *** usernames: ' + usernames);

        // Query all the users
        List<User> us = [SELECT Id,UserName FROM User 
                         WHERE UserName IN :usernames 
                         AND (Profile.Name='集团市场部呼叫中心专员' OR
                              Profile.Name='集团市场部呼叫中心主管')];

        Map<String,Id> userMap = new Map<String,Id> ();
        for (User u : us) {
            userMap.put(u.Username, u.Id);
        }

        Integer flag = 0;
        for (Object o : itemList) {

            Map<String,Object> obj = (Map<String,Object>) o;
            Servicing_Table__c st = new Servicing_Table__c ();

            if (userMap.containsKey(String.valueOf(obj.get('外呼人员')))) {
                st.User__c = userMap.get(String.valueOf(obj.get('外呼人员')));
                st.Order_No__c = String.valueOf(obj.get('优先级'));
                st.Business_Line__c = String.valueOf(obj.get('业务线'));
                st.Intended_City__c = String.valueOf(obj.get('意向城市'));
                st.IsLocal__c = String.valueOf(obj.get('本地异地'));
                st.MonS1__c = String.valueOf(obj.get('星期一开始时间1')) == '' ? null : String.valueOf(obj.get('星期一开始时间1'));
                st.MonE1__c = String.valueOf(obj.get('星期一结束时间1')) == '' ? null : String.valueOf(obj.get('星期一结束时间1'));
                st.MonS2__c = String.valueOf(obj.get('星期一开始时间2')) == '' ? null : String.valueOf(obj.get('星期一开始时间2'));
                st.MonE2__c = String.valueOf(obj.get('星期一结束时间2')) == '' ? null : String.valueOf(obj.get('星期一结束时间2'));
                st.TueS1__c = String.valueOf(obj.get('星期二开始时间1')) == '' ? null : String.valueOf(obj.get('星期二开始时间1'));
                st.TueE1__c = String.valueOf(obj.get('星期二结束时间1')) == '' ? null : String.valueOf(obj.get('星期二结束时间1'));
                st.TueS2__c = String.valueOf(obj.get('星期二开始时间2')) == '' ? null : String.valueOf(obj.get('星期二开始时间2'));
                st.TueE2__c = String.valueOf(obj.get('星期二结束时间2')) == '' ? null : String.valueOf(obj.get('星期二结束时间2'));
                st.WedS1__c = String.valueOf(obj.get('星期三开始时间1')) == '' ? null : String.valueOf(obj.get('星期三开始时间1'));
                st.WedE1__c = String.valueOf(obj.get('星期三结束时间1')) == '' ? null : String.valueOf(obj.get('星期三结束时间1'));
                st.WedS2__c = String.valueOf(obj.get('星期三开始时间2')) == '' ? null : String.valueOf(obj.get('星期三开始时间2'));
                st.WedE2__c = String.valueOf(obj.get('星期三结束时间2')) == '' ? null : String.valueOf(obj.get('星期三结束时间2'));
                st.ThuS1__c = String.valueOf(obj.get('星期四开始时间1')) == '' ? null : String.valueOf(obj.get('星期四开始时间1'));
                st.ThuE1__c = String.valueOf(obj.get('星期四结束时间1')) == '' ? null : String.valueOf(obj.get('星期四结束时间1'));
                st.ThuS2__c = String.valueOf(obj.get('星期四开始时间2')) == '' ? null : String.valueOf(obj.get('星期四开始时间2'));
                st.ThuE2__c = String.valueOf(obj.get('星期四结束时间2')) == '' ? null : String.valueOf(obj.get('星期四结束时间2'));
                st.FriS1__c = String.valueOf(obj.get('星期五开始时间1')) == '' ? null : String.valueOf(obj.get('星期五开始时间1'));
                st.FriE1__c = String.valueOf(obj.get('星期五结束时间1')) == '' ? null : String.valueOf(obj.get('星期五结束时间1'));
                st.FriS2__c = String.valueOf(obj.get('星期五开始时间2')) == '' ? null : String.valueOf(obj.get('星期五开始时间2'));
                st.FriE2__c = String.valueOf(obj.get('星期五结束时间2')) == '' ? null : String.valueOf(obj.get('星期五结束时间2'));
                st.SatS1__c = String.valueOf(obj.get('星期六开始时间1')) == '' ? null : String.valueOf(obj.get('星期六开始时间1'));
                st.SatE1__c = String.valueOf(obj.get('星期六结束时间1')) == '' ? null : String.valueOf(obj.get('星期六结束时间1'));
                st.SatS2__c = String.valueOf(obj.get('星期六开始时间2')) == '' ? null : String.valueOf(obj.get('星期六开始时间2'));
                st.SatE2__c = String.valueOf(obj.get('星期六结束时间2')) == '' ? null : String.valueOf(obj.get('星期六结束时间2'));
                st.SunS1__c = String.valueOf(obj.get('星期日开始时间1')) == '' ? null : String.valueOf(obj.get('星期日开始时间1'));
                st.SunE1__c = String.valueOf(obj.get('星期日结束时间1')) == '' ? null : String.valueOf(obj.get('星期日结束时间1'));
                st.SunS2__c = String.valueOf(obj.get('星期日开始时间2')) == '' ? null : String.valueOf(obj.get('星期日开始时间2'));
                st.SunE2__c = String.valueOf(obj.get('星期日结束时间2')) == '' ? null : String.valueOf(obj.get('星期日结束时间2'));

                if ((st.MonE1__c != null && st.MonS1__c == null) ||
                    (st.MonE1__c == null && st.MonS1__c != null) ||
                    (st.MonE2__c != null && st.MonS2__c == null) ||
                    (st.MonE2__c == null && st.MonS2__c != null) ||
                    (st.MonE1__c != null && st.MonS1__c != null
                        && Integer.valueOf(st.MonE1__c) < Integer.valueOf(st.MonS1__c)) || 
                    (st.MonE2__c != null && st.MonS2__c != null 
                        && Integer.valueOf(st.MonE2__c) < Integer.valueOf(st.MonS2__c))) {

                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期一的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if ((st.TueE1__c != null && st.TueS1__c == null)||
                    (st.TueE1__c == null && st.TueS1__c != null)||
                    (st.TueE2__c != null && st.TueS2__c == null)||
                    (st.TueE2__c == null && st.TueS2__c != null)||
                    (st.TueE1__c != null && st.TueS1__c != null 
                        && Integer.valueOf(st.TueE1__c) < Integer.valueOf(st.TueS1__c)) || 
                    (st.TueE2__c != null && st.TueS2__c != null 
                        && Integer.valueOf(st.TueE2__c) < Integer.valueOf(st.Tues2__c))) {

                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期二的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if ((st.WedE1__c != null && st.WedS1__c == null)||
                    (st.WedE1__c == null && st.WedS1__c != null)||
                    (st.WedE2__c != null && st.WedS2__c == null)||
                    (st.WedE2__c == null && st.WedS2__c != null)||
                    (st.WedE1__c != null && st.WedS1__c != null 
                        && Integer.valueOf(st.WedE1__c) < Integer.valueOf(st.WedS1__c)) || 
                    (st.WedE2__c != null && st.WedS2__c != null 
                        && Integer.valueOf(st.WedE2__c) < Integer.valueOf(st.Weds2__c))) {

                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期三的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if ((st.ThuE1__c != null && st.ThuS1__c == null) || 
                    (st.ThuE1__c == null && st.ThuS1__c != null) || 
                    (st.ThuE2__c != null && st.ThuS2__c == null) ||
                    (st.ThuE2__c == null && st.ThuS2__c != null) ||
                    (st.ThuE1__c != null && st.ThuS1__c != null && Integer.valueOf(st.ThuE1__c) < Integer.valueOf(st.ThuS1__c)) || 
                    (st.ThuE2__c != null && st.ThuS2__c!= null && Integer.valueOf(st.ThuE2__c) < Integer.valueOf(st.Thus2__c))) {
                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期四的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if ((st.FriE1__c != null && st.FriS1__c == null) ||
                    (st.FriE1__c == null && st.FriS1__c != null) ||
                    (st.FriE2__c != null && st.FriS2__c == null) ||
                    (st.FriE2__c == null && st.FriS2__c != null) ||
                    (st.FriE1__c != null && st.FriS1__c != null 
                        && Integer.valueOf(st.FriE1__c) < Integer.valueOf(st.FriS1__c)) || 
                    (st.FriE2__c != null && st.FriS2__c != null 
                        && Integer.valueOf(st.FriE2__c) < Integer.valueOf(st.Fris2__c))) {

                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期五的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if ((st.SatE1__c != null && st.SatS1__c == null) ||
                    (st.SatE1__c == null && st.SatS1__c != null) ||
                    (st.SatE2__c != null && st.SatS2__c == null) ||
                    (st.SatE2__c == null && st.SatS2__c != null) ||
                    (st.SatE1__c != null && st.SatS1__c != null 
                        && Integer.valueOf(st.SatE1__c) < Integer.valueOf(st.SatS1__c)) || 
                    (st.SatE2__c != null && st.SatS2__c != null 
                        && Integer.valueOf(st.SatE2__c) < Integer.valueOf(st.Sats2__c))) {

                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期六的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if ((st.SunE1__c != null && st.SunS1__c == null) ||
                    (st.SunE1__c == null && st.SunS1__c != null) ||
                    (st.SunE2__c != null && st.SunS2__c == null)||
                    (st.SunE2__c == null && st.SunS2__c != null)||
                    (st.SunE1__c != null && st.SunS1__c != null 
                        && Integer.valueOf(st.SunE1__c) < Integer.valueOf(st.SunS1__c)) || 
                    (st.SunE2__c != null && st.SunS2__c != null 
                        && Integer.valueOf(st.SunE2__c) < Integer.valueOf(st.Suns2__c))) {

                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期日的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if (st.Order_No__c == '') {
                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '星期日的时间范围不对';
                    errorList.add(ew);
                    continue;
                }

                if (st.Business_Line__c == '') {
                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '业务线不能为空';
                    errorList.add(ew);
                    continue;
                }

                if (st.Intended_City__c == '') {
                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '意向城市不能为空';
                    errorList.add(ew);
                    continue;
                }

                if (st.IsLocal__c == '') {
                    ErrorWrap ew = new ErrorWrap ();
                    ew.index = flag;
                    ew.username = String.valueOf(obj.get('外呼人员'));
                    ew.msg = '本地异地不能为空';
                    errorList.add(ew);
                    continue;
                }
                srvTable.add(st);

            } else {
                ErrorWrap ew = new ErrorWrap ();
                ew.index = flag;
                ew.username = String.valueOf(obj.get('外呼人员'));
                ew.msg = '用户不存在或者用户不是TMK用户';
                errorList.add(ew);
            }

            flag++;
        }

        if (errorList.size() > 0) {
            return errorList;
        }

        // Deletes old data and insert new data
        try {

            List<Servicing_Table__c> oldList = [SELECT Id
                                                FROM Servicing_Table__c 
                                                WHERE IsActived__c = false];
            if (oldList.size() > 0) {
                delete oldList;
            }

            if (srvTable.size() > 0) {

                List<Database.SaveResult> srList = Database.insert(srvTable, false);
                Integer index = 0;
                for (Database.SaveResult sr : srList) {

                    if (sr.isSuccess()) {
                        Map<String,Object> obj = (Map<String,Object>)itemList[index];
                        ErrorWrap ew = new ErrorWrap ();
                        ew.index = index;
                        ew.username = String.valueOf(obj.get('外呼人员'));
                        ew.msg = '导入成功';
                        errorList.add(ew);
                    } else {

                        Map<String,Object> obj = (Map<String,Object>) itemList[index];
                        ErrorWrap ew = new ErrorWrap ();
                        ew.index = index;
                        ew.username = String.valueOf(obj.get('外呼人员'));
                        ew.msg = sr.getErrors()[0].getMessage();
                        errorList.add(ew);
                    }
                    index++;
                }
            }

            return errorList;
        } catch(Exception e) {
            ErrorWrap ew = new ErrorWrap ();
            ew.index = 0;
            ew.username = '';
            ew.msg = '导入异常' + e.getMessage();
            errorList.add(ew);
            return errorList;
        }
    }

    public Class ErrorWrap {

        public String msg { get; set; }
        public Integer index { get; set; }
        public String username { get; set; }
    }
}