/**************************************************************************************************
 * Name: Live800ForAboard
 * Object: Lead
 * Purpose: REST API for live800 counselling name card
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
 * Test url: https://{instance_url}.salesforce.com/services/apexrest/Live800ForAboard
***************************************************************************************************/
@RestResource(urlMapping = '/Live800ForAboard')
global class Live800ForAboard {

    @HttpGet
    global static String doGet() {
		Live800DataWrapper.AboardCon msgCard = new Live800DataWrapper.AboardCon ();
        Map<String, String> mapParam = RestContext.request.params;
        InteractionLogUtil.CreateLog('Live800ForAboard', JSON.serialize(mapParam));
	    msgCard.NAME = mapParam.get('NAME');
		msgCard.PHONE = mapParam.get('PHONE');
		msgCard.MOBILE = mapParam.get('MOBILE');
		msgCard.QQ = mapParam.get('QQ');
		msgCard.EMAIL = mapParam.get('EMAIL');
		msgCard.COLUMN11 = mapParam.get('COLUMN11');
		msgCard.CUSTNAME = mapParam.get('CUSTNAME');
		msgCard.AREA = mapParam.get('AREA');
		msgCard.URL = mapParam.get('URL');
		msgCard.NOTE = mapParam.get('NOTE');
		msgCard.COLUMN3 = mapParam.get('COLUMN3');
		msgCard.COLUMN7 = mapParam.get('COLUMN7');
		msgCard.COMPANYNAME = mapParam.get('COMPANYNAME');
		msgCard.MSN = mapParam.get('MSN');
		msgCard.COLUMN2 = mapParam.get('COLUMN2');
		msgCard.COLUMN1 = mapParam.get('COLUMN1');
		msgCard.COLUMN4 = mapParam.get('COLUMN4');
		msgCard.COLUMN5 = mapParam.get('COLUMN5');
		msgCard.COLUMN6 = mapParam.get('COLUMN6');
		msgCard.COLUMN8 = mapParam.get('COLUMN8');
		msgCard.COLUMN9 = mapParam.get('COLUMN9');
		msgCard.COLUMN10 = mapParam.get('COLUMN10');
		msgCard.TRAININGITEM = mapParam.get('TRAININGITEM');

        String ret = '';
        try {
            ret = Live800DataWrapper.InsertAboardLead(msgCard);

        } catch (Exception e) {
            RET resp = new RET();
			resp.code = '1';
			resp.msg = e.getMessage();
			return JSON.serialize(resp);
        }
        return ret;
    }

    public class RET{
		public String code;
		public String msg;
	}
}