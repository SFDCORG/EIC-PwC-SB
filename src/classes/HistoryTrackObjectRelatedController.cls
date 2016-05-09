public class HistoryTrackObjectRelatedController {

  public static void createHisotryRecords(Datetime viewtime, ID viewuserID, ID sobID)
  {
    Phone_View_Log__c phoneviewlog = new Phone_View_Log__c();
    phoneviewlog.User_Name__c = viewuserID;
    phoneviewlog.View_Time__c = viewtime;
    phoneviewlog.Account__c = sobID;
    try
    {
      insert phoneviewlog;
    }
    catch(Exception e)
    {
      ApexPages.addMessages(e);
    }
  }

  public static void createLeadHistoryRecords(Datetime viewTime, ID viewUserID, ID leadId)
  {
    Lead_Phone_View_Log__c phoneViewLog = new Lead_Phone_View_Log__c();
    phoneViewLog.User__c = viewUserID;
    phoneViewLog.View_Time__c = viewTime;
    phoneViewLog.Lead__c = leadId;
    try
    {
      insert phoneViewLog;
    }
    catch(Exception e)
    {
      ApexPages.addMessages(e);
    }
  }
}