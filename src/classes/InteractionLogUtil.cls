/**************************************************************************************************
 * Name: InteractionLogUtil
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public class InteractionLogUtil {

    public static void CreateLog (String service, String logmsg) {

        InteractionLog__c log = new InteractionLog__c ();
        log.name = service + System.Now().format('yyyy-MM-dd hh:mm:ss');
        log.ServiceKey__c = service;
        insert log;
        Attachment attobject = new Attachment ();
        attobject.Name = 'log.txt';
        attobject.Body = Blob.valueOf(logmsg);
        attobject.ParentId = log.Id;
        insert attobject;
    }
}