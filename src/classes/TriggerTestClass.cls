@isTest
private class TriggerTestClass {
   @testSetup static void setup()
  {   
      Profile p = [SELECT Id FROM Profile WHERE id=: ProfileRelated.adminlv2];
      
      UserRole role= new UserRole();
      role.Name='test';
      role.DeveloperName='Counselling_SH_Renguang_ASIA_Null_Incharge1';
      insert role;


      User loginUser = new User(Alias = 'standt', Email='standarduser@testorg.com',

      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',

      LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=role.Id,

      TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrayuat@testorg.com');



     System.runAs(loginUser) {
      
      
      
      Account acc= new Account();
      acc.Name='test';
      insert acc;
   
      
      User userToCreate = new User();
      userToCreate.FirstName = 'David1';
      userToCreate.LastName  = 'Liu1';
      userToCreate.Email     = 'dvdkliu+sfdc199@gmail.com';
      userToCreate.Username  = 'sfdc-dreamer1cenray@gmail.com';
      userToCreate.Alias     = 'fatty1';
      userToCreate.ProfileId = '00e28000000yygR';
      userToCreate.TimeZoneSidKey    = 'America/Denver';
      userToCreate.LocaleSidKey      = 'en_US';
      userToCreate.EmailEncodingKey  = 'UTF-8';
      userToCreate.LanguageLocaleKey = 'en_US'; 
      userToCreate.UserRoleId=role.Id;
      insert userToCreate;

      User u = new User();
      u.FirstName = 'David';
      u.LastName  = 'Liu';
      u.Email     = 'dvdkliu+sfdc99@gmail.com';
      u.Username  = 'sfdc-dreamersfdc-dreamer1cenray@gmail.com';
      u.Alias     = 'fatty';
      u.TimeZoneSidKey    = 'America/Denver';
      u.LocaleSidKey      = 'en_US';
      u.EmailEncodingKey  = 'UTF-8';
      u.LanguageLocaleKey = 'en_US';
      U.Manager=userToCreate;
      u.UserRoleId=role.Id;
      u.ProfileId='00e28000000IpJs';
      insert u; 


      Opportunity o= new Opportunity();
      o.CloseDate=System.today();
      o.name='test';
      o.AccountId=acc.Id;
      o.sys_UnlockStage__c=true;  
      o.StageName='顾问跟进';
      o.OwnerId=u.Id;
      o.sys_UnlockStage__c=false;
      insert o;


      
      Approval_Log__c a1= new Approval_Log__c();
      a1.Approval_Status__c='待审批';
      a1.Opportunity__c=o.Id;
      a1.Approver__c=u.Id;
      a1.Description__c='test';
      insert a1;

      Approval_Log__c a2= new Approval_Log__c();
      a2.Approval_Status__c='待审批';
      a2.Opportunity__c=o.Id;
      a2.Approver__c=u.Id;
      a2.Description__c='test';
      insert a2;


      Scheduling_Table__c scheTable= new Scheduling_Table__c();
      scheTable.name='tes1';
      scheTable.Project__c='1;1;1;';
      scheTable.Source__c='2;2;2;';
      scheTable.isActive__c=true;
      scheTable.Intercept__c='分配至顾问';
      scheTable.Manager__c=u.Id;
      scheTable.Front_Desk__c=u.id;
      insert scheTable;

     
   }
  }


    static testMethod void testAccountUpdateTrigger()
   {  
        test.StartTest();

        Account acount= new Account();
        acount.name='test';
        insert acount;

        Contact_EIC__c contat  = new Contact_EIC__c();
        contat.isPrimary__c = true;
        contat.Name='test';
        contat.Contact_Type__c='手机';
        contat.Account__c=acount.Id;
        contat.Relationship__c= 'OneSelf';
        contat.UniqueContact__c='13671999387';
        insert contat;

        Contact_EIC__c contat2  = new Contact_EIC__c();
        contat2.isPrimary__c = true;
        contat2.Name='test2';
        contat2.Contact_Type__c='手机';
        contat2.Account__c=acount.Id;
        contat2.Relationship__c= 'OneSelf';
        contat2.UniqueContact__c='13671999384';
        insert contat2;
        test.StopTest();
   
   }



    static testMethod void testupdateApprovalLogTrigger(){
      

      Profile pp1 = [SELECT Id FROM Profile WHERE id=: ProfileRelated.adminlv2 LIMIT 1];
      
      // UserRole role1= new UserRole();
      // role1.Name='Counselling_SH_Null_SalesAN_Null_Managertest';
      // role1.DeveloperName='Counselling_SH_Null_SalesAN_Null_Managertest1';
      // insert role1;


      User loginUserapp = new User(
        Alias = 'stdaabb', 
        Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', 
        LastName='Testing', 
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', 
        ProfileId = pp1.Id, 
        // UserRoleId=role1.Id,
        TimeZoneSidKey='America/Los_Angeles', 
        UserName='stduserrayuatapproval@testorg.com.test');


      test.StartTest();
      // System.runAs(loginUserapp) {
        User u=[select id from user where Username='sfdc-dreamersfdc-dreamer1cenray@gmail.com' limit 1];
        Opportunity o=[select StageName, id,OwnerId ,sys_UnlockStage__c from Opportunity limit 1];
        Approval_Log__c log = new Approval_Log__c();
        log.approver__c=u.id;
        log.Opportunity__c=o.id;
        insert log;
        update log;
      // }
      test.StopTest();
   }
   
   static testMethod void testScheduleTableOrderIndicator(){
      test.StartTest();
      User u=[select id from user where Username='sfdc-dreamersfdc-dreamer1cenray@gmail.com' limit 1];
    
      Scheduling_Table_Order__c scheTablOrder1=new Scheduling_Table_Order__c();
      scheTablOrder1.User__c=u.Id;
      scheTablOrder1.Order__c=1;
      scheTablOrder1.Count__c=1;
      scheTablOrder1.Scheduling_Table__c=[select id from Scheduling_Table__c limit 1].ID;


      Scheduling_Table_Order__c scheTablOrder2=new Scheduling_Table_Order__c();
      scheTablOrder2.User__c=u.Id;
      scheTablOrder2.Order__c=2;
      scheTablOrder2.Count__c=0;
      scheTablOrder2.Scheduling_Table__c=[select id from Scheduling_Table__c limit 1].ID;

      insert scheTablOrder1; insert scheTablOrder2;
      scheTablOrder2.Count__c=1;
      update scheTablOrder2;



      test.StopTest();
   }

   static testMethod void testinsertOppLog(){
     test.StartTest();
     Opportunity o=[select id, OwnerId from Opportunity limit 1];
     User userToCreate=[select id from user where LastName='Liu1' limit 1];
     o.OwnerId=userToCreate.Id;
     update o;
     test.stopTest();
   }

   static testMethod void testtablesourceProjects()
   {
     
     Scheduling_Table__c tab= [select id, Source__c,Project__c,isActive__c from Scheduling_Table__c limit 1];

     test.StartTest();
     tab.Source__c='3;3;3';

     update tab;
     test.stopTest();

   }

   static testMethod void testappointCreated()
   {
      
      test.StartTest();
      User u=[select id from user where Username='sfdc-dreamersfdc-dreamer1cenray@gmail.com' limit 1];
      Opportunity o=[select id from Opportunity limit 1];

      Appoitment__c app= new Appoitment__c();
      app.Due_Date__c=system.today();
      app.Due_Time__c='09:00';
      app.RecordTypeID='012280000009e0G';
      app.Assign_To__c=u.Id;
      app.Status__c= '跟进中';
      app.Opportunity__c=o.id;
      app.Description__c='';
      app.Duration__c='1';
      app.name='dte';
      insert app;

      
      Appoitment__c app2= new Appoitment__c();
      app2.Opportunity__c= o.Id; 
      app2.Status__c='跟进'; 
      app2.Duration__c='0.5'; 
      app2.recordTypeID=recordTypeRelated.FrontDeskVisit_App; 
      app2.sys_unlock_app__c=true;
      app2.Appointment_Type__c='前台到访'; 
      insert app2;

      Appoitment__c app3= new appoitment__c();
      app3.Due_Date__c=system.today();
      app3.Due_Time__c='09:00';
      app3.RecordTypeID='012280000009e0G';
      app3.Assign_To__c=u.Id;
      app3.Status__c= '已到访';
      app3.Opportunity__c=o.id;
      app3.Description__c='';
      app3.Duration__c='1';
      app3.name='dte';
      insert app3;

      test.stopTest();
   }


   static testMethod void testupdateAccout()
   {
      test.StartTest();
      
      User loginUser = new User(Alias = 'stadndt', Email='standarduse1r@testorg.com',

      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',

      LocaleSidKey='en_US', ProfileId =ProfileRelated.centerManger,

      TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrayuat1@testorg.com');

      insert loginUser;
      

      Account b= new Account();
      b.Name='tes1t';
      b.OwnerId=loginUser.id;
      insert b;

      Opportunity o= new Opportunity();

      o.Name='test';

      o.CloseDate=System.today();

      o.AccountId=b.Id;

      o.sys_UnlockStage__c=true;

      o.StageName='顾问跟进';

      o.OwnerId=userinfo.getUserId();

      o.sys_UnlockStage__c=false;

      insert o;

      System.runAs(loginUser)
      {
          b.Name='test255splitemethod:testtesttttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest255splitemethod:testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest';
          b.Birthday__c=System.today();
          b.Address__c='shanghai hongkou district';
          update b;
      }

      test.stopTest();
   }

   static testMethod void testopp()
   {
      User u=[select id from user where Username='sfdc-dreamersfdc-dreamer1cenray@gmail.com' limit 1];

      Account a= new Account();
      a.Name='test1212';
      insert a;

      test.StartTest();
      Opportunity o= new Opportunity();
      o.CloseDate=System.today();
      o.name='test';
      o.Account=a;
      o.sys_UnlockStage__c=true;  
      o.StageName='test';
      o.OwnerId=u.Id;
      o.sys_UnlockStage__c=false;
      insert o;
      
      User loginUser = new User(Alias = 'stadndt', Email='standarduse1r@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', 
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId =ProfileRelated.HQmarketingCS,
                                TimeZoneSidKey='America/Los_Angeles', 
                                UserName='standarduserrayuat1@testorg.com');

      insert loginUser;
      

        Appoitment__c app3= new appoitment__c();
        Date tdate=system.today();
        app3.Due_Date__c=tdate.addDays(1);
        app3.Due_Time__c='09:00';
        app3.RecordTypeID='012280000009e0G';
        app3.Assign_To__c=u.Id;
        app3.Opportunity__c=o.id;
        app3.Duration__c='1';
        app3.name='dte';
        app3.CreatedByID=loginUser.Id;
        insert app3;

  
      o.stageName='签约';
      update o;

      test.stopTest();


   }  
}