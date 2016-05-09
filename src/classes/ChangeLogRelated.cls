/**************************************************************************************************
 * Name: ChangeLogRelated
 * Object: Change_Log__c
 * Purpose:  Generate kinds of change log history.
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-08    Allen    Format the code
 **************************************************************************************************/
global class ChangeLogRelated {

    // Generates a single opp change log 
    webservice static String CreateOppChangeLog(Opportunity orginalOpp,
                                                String fromUserID,
                                                String toUserID,
                                                String selectedscheTabID,
                                                String type) {

        Change_Log__c ocl = new Change_Log__c ();
        ocl.From_User__c = fromUserID;
        ocl.To_User__c = toUserID;
        ocl.Opportunity__c = orginalOpp.Id;

        if (selectedscheTabID != '') {
            ocl.Scheduling_Table__c=selectedscheTabID;
        }

        if (type ==' 分配至顾问') ocl.Type__c = '排班表分配 - 直接到顾问';
        else if (type == '分配至主管') ocl.Type__c = '排班表分配 - 主管截流';
        else if (type == '分配至前台') ocl.Type__c = '排班表分配 - 前台截流';
        else ocl.Type__c=type;
        insert ocl;

        if (type == '分配至顾问' || type == '指定接收人' ) {
            insert ActivityRelated.generateTaskAlert('有新商机分配给你！',
                                                     '',
                                                     toUserID,
                                                     System.Now(),
                                                     System.Today(),
                                                     orginalOpp.Id);
        } else {

            insert ActivityRelated.generateTaskAlert('您有一个商机被回收',
                                                   '',
                                                   fromUserID,
                                                   System.Now(),
                                                   System.Today(),
                                                   orginalOpp.Id);
            orginalOpp.sys_isManagerRetrieve__c = true;
            update orginalOpp;

            return ocl.Id;
        }

        orginalOpp.sys_isManagerRetrieve__c = false;
        update orginalOpp;
        return ocl.Id;
    }

    // Generates a contact update/insert log
    public static void CreateContactChangeLog(String type, Contact_EIC__c newcontact, Contact_EIC__c oldcontact) {

        Change_Log__c ocl = new Change_Log__c ();
        ocl.New_Contact_Number__c = newcontact.Contact_Type__c + ' ' + newcontact.Encryped_Phone__c;
        ocl.Account__c = newcontact.Account__c;
        ocl.Type__c = type;

        if (type == '新增联系方式' || type == '失效联系方式') {

            if (newcontact.isPrimary__c) {

                ocl.New_Contact_Number__c += '(主要联系方式)';
            }

            insertNewContactAlert(newcontact,type);
        } else if (type == '更改主要联系方式') {

            ocl.Old_Contact_Number__c = oldcontact.Contact_Type__c + ' ' + oldcontact.Encryped_Phone__c;
        }

        else if (type == '更改紧急联系方式') {

            ocl.New_Contact_Number__c += ' [E]';
            insertNewContactAlert(newcontact, type);
        }

        if (!ProfileRelated.adminProfileSet().contains(UserInfo.getProfileId())) {

            insert ocl;
        }
    }

    // Generates a contact insert / update alert
    private static void insertNewContactAlert (Contact_EIC__c contat, String type) {

        Account ac = [SELECT Name FROM Account WHERE Id = :contat.Account__c LIMIT 1];
        String des = '';
        String content = '客户' + ac.name + type + '：' + contat.Contact_Type__c + '  ' + contat.Encryped_Phone__c;

        for (Opportunity idd : [SELECT OwnerID FROM Opportunity WHERE AccountID = :ac.Id]) {

            if (idd.OwnerId != UserInfo.getUserId()) {

                insert ActivityRelated.generateTaskAlert(content,des,
                                                         idd.OwnerId,
                                                         System.Now(),
                                                         System.Today(),
                                                         contat.Account__c);
            }
        }
    }

    // Generates change log and alert for bulk opps
    public static void createOppChangeLogBulk (Map<Opportunity, Id> oldUserOppMap) {

        List<Change_Log__c> oppChangelog = new List<Change_Log__c> ();
        List<Task> tazks = new List<Task> ();
        List<Opportunity> opps = new List<Opportunity> ();

        for (Opportunity opp : oldUserOppMap.keySet()) {
            Change_Log__c ocl = new Change_Log__c ();
            ocl.From_User__c = oldUserOppMap.get(opp);
            ocl.To_User__c = opp.OwnerID;
            ocl.Type__c = ocl.To_User__c == UserInfo.getUserId() ? '商机批量回收' : '商机批量分配';
            ocl.Opportunity__c = opp.Id;
            oppChangelog.add(ocl);

            String subject = ocl.To_User__c == UserInfo.getUserId() ? '您有一个商机被回收！' : '有新商机分配给你！';
            ID assignUserid = ocl.To_User__c == UserInfo.getUserId() ?  ocl.From_User__c : ocl.To_User__c;

            opp.sys_isManagerRetrieve__c = ocl.To_User__c == UserInfo.getUserId();
            opps.add(opp);
            tazks.add(ActivityRelated.generateTaskAlert(subject,
                                                        '',
                                                        assignUserid,
                                                        System.Now(),
                                                        System.Today(),
                                                        ocl.Opportunity__c));
        }

        if (oppChangelog.size() > 0) {

            insert oppChangelog;
            insert tazks;
            update opps;
        }
    }

    public static void updateChangelogInfo(ID changlogIDs, ID recuser) {

        List<Change_Log__c> ocl = [SELECT RecommendedUser__c FROM Change_Log__c WHERE Id = :changlogIDs];

        if (ocl.size() > 0) {
            ocl[0].RecommendedUser__c = recuser;
        }

        update ocl;
    }

    public static void createOppLossLog (Map<Opportunity, ID> newoppApprover) {

        List<Change_Log__c> changlogs = new  List<Change_Log__c> ();

        for (Opportunity opp : newoppApprover.keySet()) {

            Change_Log__c ocl = new Change_Log__c ();
            ocl.From_User__c = opp.OwnerId;
            ocl.To_User__c = newoppApprover.get(opp);
            ocl.Opportunity__c = opp.Id;
            ocl.Type__c = '商机流失';
            changlogs.add(ocl);
        }

        if (changlogs.size() > 0) insert changlogs;
    }
}