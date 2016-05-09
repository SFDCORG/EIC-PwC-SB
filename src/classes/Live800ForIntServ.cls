/**************************************************************************************************
 * Name: Live800ForIntServ
 * Object: Lead, Lead_Item__c
 * Purpose: REST API for creating lead from live800 testprep interface, 
 * Author: Matthew Sun ()
 * Create Date:
 * Modified History: 
 * 2016-05-07 Vicia Wang   Writes comments in this format
***************************************************************************************************/
@RestResource(urlMapping='/Live800ForIntServ/*')
global class Live800ForIntServ {
    @HttpGet
    global static String doGet() {
        Map<String, String> mapParam = RestContext.request.params;

        Live800DataWrapper.IntServCon msgCard = new Live800DataWrapper.IntServCon();
        InteractionLogUtil.CreateLog('Live800ForIntServ',JSON.serialize(mapParam));
        
        msgCard.Name = mapParam.get('NAME');                        //文本
        msgCard.gender = mapParam.get('GENDER');                    //后台维护
        msgCard.phone = mapParam.get('PHONE');                      //固话,号码
        msgCard.mobile = mapParam.get('MOBILE');                    //手机号
        msgCard.qq = mapParam.get('QQ');                            //QQ
        msgCard.email = mapParam.get('EMAIL');                      //邮箱
        msgCard.Column1 = mapParam.get('COLUMN1');                  //咨询课程
        msgCard.Column2 = mapParam.get('COLUMN2');                  //省
        msgCard.Column3 = mapParam.get('COLUMN3');                  //媒体来源
        msgCard.Column4 = mapParam.get('COLUMN4');                  //网址,下拉框,后台维护
        msgCard.Column5 = mapParam.get('COLUMN5');                  //搜索词
        msgCard.Column6 = mapParam.get('COLUMN6');                  //意向校区
        msgCard.Column7 = mapParam.get('COLUMN7');                  //权重
        msgCard.CUSTNAME = mapParam.get('CUSTNAME');                //创建人
        msgCard.OPPO_WebService = mapParam.get('OPPO_WebService');  //?
        msgCard.OPPO_Updateby = mapParam.get('OPPO_Updateby');      //修改人
        msgCard.Compwebsite = mapParam.get('Compwebsite');          //客户备注
        msgCard.NOTE = mapParam.get('NOTE');                        //机会备注
        msgCard.CONSULTCOUNTRY = mapParam.get('CONSULTCOUNTRY');    //留学国家
        msgCard.Column8 = mapParam.get('COLUMN8');

        String ret = '';
        try {
            ret = Live800DataWrapper.InsertIntServLead(msgCard);
        
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            RET resp = new RET();
            resp.code = '1';
            resp.msg = e.getMessage();
            return JSON.serialize(resp);
        }
        
        return ret;
    }

    public class RET {
        public String code;
        public String msg;
    }
}