@isTest
private class OpportunitiesAssignPageControllerTest {


   @testSetup static void setup()
   { 
   		Account acc= new Account();
      	acc.Name='AccQuickSearch';
      	insert acc;

      	Contact_EIC__c contat  = new Contact_EIC__c();
        contat.isPrimary__c = true;
        contat.Name='test';
        contat.Contact_Type__c='手机';
        contat.Account__c=acc.Id;
        contat.Relationship__c= 'OneSelf';
        contat.UniqueContact__c='13671999387';
        insert contat;

        Opportunity o= new Opportunity();
      	o.CloseDate=System.today();
      	o.name='test';
      	o.RecordTypeID=RecordTypeRelated.Counselling_Opp;
      	o.AccountId=acc.Id;
      	o.sys_UnlockStage__c=true;  
      	o.StageName='顾问跟进';
      	o.sys_UnlockStage__c=false;
      	o.Intended_City__c= '上海';
      	o.Project__c='澳大利亚';
      	o.Consultation_Mode__c='普通商机';
      	insert o;

      	OpportunityTeamMember oppMember= new OpportunityTeamMember();
        oppMember.OpportunityId=o.Id;
        oppMember.UserId=userinfo.getUserId();
        oppMember.TeamMemberRole= 'Team Member';
        insert oppMember;


        Organization__c org= new Organization__c();
	    org.name='test';
	    org.City__c='上海';
	    org.Front_Desk__c=UserInfo.getUserId();
	    org.RecordTypeID='012280000009bCeAAI';
	    org.OwnerId=userInfo.getUserId();
	    org.Department__c='澳新部';
	    org.Office__c='人民广场';
	    insert org;

	    Organization__c org1= new Organization__c();
	    org1.name='test';
	    org1.City__c='上海';
	    org1.Front_Desk__c=UserInfo.getUserId();
	    org1.RecordTypeID='012280000009bCeAAI';
	    org1.OwnerId=userInfo.getUserId();
	    org1.Department__c='客服部';
	    org1.Office__c='人民广场';
	    org1.Org_Manager__c=userInfo.getUserId();
	    insert org1;


	    Scheduling_Table__c sctable=new Scheduling_Table__c();
	    sctable.Name='test';
	    sctable.Organization__c=org.Id;
	    sctable.Front_Desk__c=org.Front_Desk__c;
	    sctable.Intercept__c= '分配至顾问';
	    sctable.Project__c='澳大利亚';
	    sctable.Source__c='普通商机';
	    sctable.Department__c=org.Department__c;
	    sctable.isActive__c=true;
	    sctable.City__c='上海';
	    sctable.Manager__c=userinfo.getUserId();
	    sctable.RecordTypeID='012280000009b2U';
	    insert sctable;

	    Scheduling_Table_Line__c sctline= new Scheduling_Table_Line__c();
	    sctline.Project__c='澳大利亚';
	    sctline.Source__c='普通商机';
	    sctline.Monday_Time__c='D';
	    sctline.Start_Working_Time__c= '08:00';
	    sctline.End_Working_Time__c= '23:00';
	    sctline.User__c=userinfo.getUserId();
	    sctline.Daily_Opportunities__c=1;
	    sctline.Monthly_Opportunities__c=2;
	    sctline.Scheduling_Table__c=sctable.Id;
	    insert sctline;

	    Scheduling_Table_Order__c schOrder=new Scheduling_Table_Order__c();
	    schOrder.Indicator__c=true;
	    schOrder.Order__c=1;
	    schOrder.Scheduling_Table__c=sctable.Id;
	    schOrder.User__c=userinfo.getUserId();
	    insert schOrder;

	    WorkTimesV2__c wt= new WorkTimesV2__c();
	    wt.A__c='08:30-17:30';
	    wt.B__c='09:00-18:00';
	    wt.C__c='10:00-19:00';
	    wt.D__c='0:00-23:00';
	    wt.Enable_Table_Record_Type__c='TestPrep;';
	    insert wt;

	    Appoitment__c app2= new Appoitment__c();
        Date dt= System.today();
        app2.Appointment_Type__c='首次到访';  
        app2.Due_Date__c=dt.addDays(-1);
        app2.Due_Time__c= '08:00';
        app2.Opportunity__c=o.Id;
        app2.RecordTypeId=RecordTypeRelated.Invitation_App;
        app2.Assign_To__c=userInfo.getUserId();
        app2.Status__c='跟进中';
        insert app2;    


   }
    
   static testMethod void FunctionTest()
   {    
 		test.StartTest();

 		Opportunity opp=[select id, 
 		                        Intended_City__c, 
 		                        Project__c,RecordTypeID,
 		                        StageName,Source__c,
 		                        sys_Department__c,
                                sys_UnlockStage__c, 
                                OwnerID,
                                RecordType.DeveloperName,
                                sys_LastAssignTime__c,
                                sys_LastContactTime__c
                                from Opportunity][0];

        Appoitment__c app=[select id from Appoitment__c limit 1];
        
 		PageReference myVfPage = Page.OpportunitiesAssignPage;
        Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
        ApexPages.currentPage().getParameters().put('ID',opp.Id);
        ApexPages.currentPage().getParameters().put('appointId',app.Id);
        OpportunitiesAssignPageController oppassign= new OpportunitiesAssignPageController(new ApexPages.StandardController(opp));
        oppassign.getappDateTime();

        //Opportunity Directly Assign
        oppassign.assignMethod='OppDirectly';
        oppassign.assignMethodSelect();
        oppassign.selectedUserID=userinfo.getUserId();
        oppassign.showAllDirectlyUsers();
        oppassign.selectuser();
        oppassign.assignOpp();



        //scheduling Table Assign
        oppassign.assignMethod='CC';
        oppassign.assignMethodSelect();
        oppassign.selectedscheTableID=oppassign.scheTables[0].id;
        oppassign.selectScheTable();
        oppassign.showAllUsers();
        oppassign.selectedscehTableLineID=oppassign.scheTablines[0].schedulingTableLine.ID;
        oppassign.selectScheTableLine();
        oppassign.assignOpp();
        //oppassign.finish();


        //low star pool Assign
        oppassign.assignMethod='Pool';
        oppassign.assignMethodSelect();
        oppassign.assignOpp();
   
        oppassign.cancel();

 		test.StopTest();
   }

    
}