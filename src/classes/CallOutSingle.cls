/**************************************************************************************************
 * Name: CalloutSingle
 * Object: Lead
 * Purpose: Web service to access the call center system so as to dial the mobile/fix phone
 * Author: Joe.Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
global class CallOutSingle {

    webService static String send(String phone, String idstr) {

        // Accesses the call center system
        Id uid = UserInfo.getUserId();
        User u = [SELECT Id, CCAgentId__c FROM User WHERE Id =: uid];
        CallOutMethod__c com = CallOutMethod__c.getValues('CallOutSingle');
        String requestUrl = com.EndPoint__c + '?';
        requestUrl = requestUrl + 'agentDn=' + u.CCAgentId__c;
        requestUrl = requestUrl + '&number=' + phone;
        requestUrl = requestUrl + '&ActivityId=' + idstr;
        requestUrl = requestUrl + '&isOpenWidow=sf';

        HttpRequest req = new HttpRequest ();
        req.setHeader('Content-type', 'application/json; charset=UTF-8');
        req.setEndpoint(requestUrl);
        req.setMethod('GET');
        req.setTimeout(120000);

        try{

            Http h = new Http ();
            HttpResponse response = h.send(req);
            String ret = response.getBody();
            ret = ret.replace('\'', '"');
            System.debug('LoggingLevel.INFO, *** ret: ' + ret);

            Object o = JSON.deserializeUntyped(ret);
            Map<String, Object> m = (Map<String, Object>) o;
            if (String.valueOf(m.get('result')) == 'ok') {

                return '外呼请求发送成功';
            } else {

                return '外呼请求发送失败:' + m.get('result');
            }

        } catch(Exception e) {

            return '外呼请求发送失败:' + e.getMessage();
        }

        return '外呼请求发送成功';
    }
}