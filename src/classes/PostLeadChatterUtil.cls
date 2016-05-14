/**************************************************************************************************
 * Name: PostLeadChatterUtil
 * Object: Counselling_Project__c, FeedItem
 * Purpose: if counseling project or TestPrep project has change, post chatter
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modify History:
 * 2016-04-18    Ray Cen    Create this class
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
public with sharing class PostLeadChatterUtil {

    public static void postChatter (Lead oldLead, Lead newLead) {

        List<FeedItem> leadChatterItemList = new List<FeedItem>();
        if (oldLead.Counselling_Project__c != newLead.Counselling_Project__c) {

            String oldCounsellingProject = oldLead.Counselling_Project__c == null ? 
                '' : oldLead.Counselling_Project__c;
            String newCounsellingProject = newLead.Counselling_Project__c == null ? 
                '' : newLead.Counselling_Project__c;
            FeedItem leadFeedItem = new FeedItem(
                ParentId = newLead.Id,
                Body = UserInfo.getName() + '  '
                     + '将 留学国家 ' +
                     + '从 "' + oldCounsellingProject + '" '
                     + '更改至 "' + newCounsellingProject + '"',
                Type = 'TextPost');
            leadChatterItemList.add(leadFeedItem); 
        }

        if (oldLead.TestPrep_Project__c != newLead.TestPrep_Project__c) {

            String oldTestPrepProject = oldLead.TestPrep_Project__c == null ?
                '' : oldLead.TestPrep_Project__c;
            String newTestPrepProject = newLead.TestPrep_Project__c == null ?
                '' : newLead.TestPrep_Project__c;
            FeedItem leadFeedItem = new FeedItem(
                ParentId = newLead.Id,
                Body = UserInfo.getName() + '  '
                     + '将 考培项目 ' +
                     + '从 "' + oldTestPrepProject + '" '
                     + '更改至 "' + newTestPrepProject + '"',
                Type = 'TextPost');
            leadChatterItemList.add(leadFeedItem);
        }

        insert leadChatterItemList;
    }
}