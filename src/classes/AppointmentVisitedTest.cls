@isTest
private class AppointmentVisitedTest {

    @isTest static void method() {

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        System.runAs(u) {
            u.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Null_HQ_Null_Null_Null_Staff'].Id;
            update u;
            CreateUserUtil.CreateUserForAppointment();
            Account acct = new Account ();
            acct.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE DeveloperName = 'EIC_Account'
                                 AND SObjectType='Account'].Id;
            acct.Name = 'test001';
            acct.ID_Type__c = null;
            insert acct;
            Contact_EIC__c c2 = new Contact_EIC__c ();
            c2.Account__c = acct.Id;
            c2.Contact_Type__c = '手机';
            c2.UniqueContact__c = '13200000001';
            c2.isInvalid__c = false;
            c2.isPrimary__c = true;
            insert c2;  

            opp = new Opportunity ();
            opp.RecordTypeId = [SELECT Id
                                FROM RecordType
                                WHERE DeveloperName = 'Counselling'
                                AND SObjectType = 'Opportunity'].Id;
            opp.Name = 'testopp001';
            opp.AccountId = acct.Id;
            opp.StageName = '顾问跟进';
            opp.ForecastCategoryName = 'Pipeline';
            opp.CloseDate = System.Today();
            insert opp;

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '2015年10月上海百度竞价A';
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '线上';
            campaign1.Marketing_Channel_Lv2__c = 'PC';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;

            Lead l = new Lead ();
            l.MobilePhone = '13210987954';
            l.Is_Counselling__c = true;
            l.Is_TestPrep__c = true;
            l.Counselling_Project__c ='美国';
            l.TestPrep_Project__c = 'ACT';
            l.Intended_City__c = '上海';
            l.LastName = 'test123';
            l.Campaign__c = campaign1.Id;
            l.Company = 'EIC';
            l.Status = '部分转化';
            insert l;
            Lead ltemp = [SELECT Id, Status FROM Lead WHERE Id = :l.Id];

            List<Lead_Item__c> lis = [SELECT Id, Status__c, Opportunity__c
                                      FROM Lead_Item__c
                                      WHERE Lead__c = :l.Id];
            System.assert(lis.size() == 2);

            lis[0].Status__c = '关闭--转化商机成功';
            lis[0].Opportunity__c = opp.Id;
            update lis[0];
        }

        Test.startTest();
        Appoitment__c app1 = new Appoitment__c ();
        Appoitment__c app2 = new Appoitment__c ();
        User u1 = [SELECT Id, UserRole.Name
                   FROM User
                   WHERE UserName = 'sophiezhou@eic.com.testcode'];

        System.runAs(u1) {
            app1 = new Appoitment__c ();
            app1.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType='Appoitment__c'
                                 AND DeveloperName='Invitation'].Id;
            app1.Opportunity__c = opp.Id;
            app1.Assign_To__c = UserInfo.getUserId();
            app1.Due_Date__c = System.Today();
            app1.Due_Time__c = '10:00';
            app1.Appointment_Type__c = '首次到访邀约';
            insert app1;
        }

        User own = [SELECT Id FROM User WHERE Username = 'own@eic.com.testcode'];
        opp.OwnerId = own.Id;
        update opp;

        Appoitment__c app = new Appoitment__c ();
        app.Opportunity__c = opp.Id;
        app.RecordTypeId = [SELECT Id
                            FROM RecordType
                            WHERE SObjectType = 'Appoitment__c'
                            AND DeveloperName = 'Front_Desk_Visit'].Id;
        insert app;
        List<Appoitment__c> applist = [SELECT Id, TMKAppStatus__c 
                                       FROM Appoitment__c
                                       WHERE Id = :app1.Id];
        for (Appoitment__c obj : applist) {

            System.assert(obj.TMKAppStatus__c == '已到访');
        }

        List<Lead_Item__c> ls = [SELECT Id, Status__c, Lead__c, Lead__r.Status 
                                 FROM Lead_Item__c
                                 WHERE Opportunity__c = :opp.Id
                                 AND Status__c = '关闭--转化商机成功(到访)'];
        System.assert(ls.size() > 0);
        Lead llt = [SELECT Id, Status FROM Lead WHERE MobilePhone='13210987954'];
        System.assert(llt.Status == '部分转化(到访)');
        Test.stopTest();
    }

    @isTest static void method1 () {

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        System.runAs(u) {

            u.UserRoleId = [SELECT Id
                            FROM UserRole
                            WHERE DeveloperName = 'Null_HQ_Null_Null_Null_Staff'].Id;
            update u;
            CreateUserUtil.CreateUserForAppointment();
            Account acct = new Account ();
            acct.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE DeveloperName='EIC_Account'
                                 AND SObjectType='Account'].Id;
            acct.Name = 'test001';
            acct.ID_Type__c = null;
            insert acct;
            Contact_EIC__c c2 = new Contact_EIC__c ();
            c2.Account__c = acct.Id;
            c2.Contact_Type__c = '手机';
            c2.UniqueContact__c = '13200000001';
            c2.isInvalid__c = false;
            c2.isPrimary__c = true;
            insert c2;  

            opp = new Opportunity ();
            opp.RecordTypeId = [SELECT Id
                                FROM RecordType
                                WHERE DeveloperName = 'Counselling'
                                AND SObjectType = 'Opportunity'].Id;

            opp.Name = 'testopp001';
            opp.AccountId = acct.Id;
            opp.StageName = '顾问跟进';
            opp.ForecastCategoryName = 'Pipeline';
            opp.CloseDate = System.Today();
            insert opp;

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '2015年10月上海百度竞价A';
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '线上';
            campaign1.Marketing_Channel_Lv2__c = 'PC';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;   

            Lead l = new Lead ();
            l.MobilePhone = '13210987954';
            l.Is_Counselling__c = true;
            l.Is_TestPrep__c = true;
            l.Counselling_Project__c ='美国';
            l.TestPrep_Project__c = 'ACT';
            l.Intended_City__c = '上海';
            l.LastName = 'test123';
            l.Campaign__c = campaign1.Id;
            l.Company = 'EIC';
            l.Status= '全部转化';
            insert l;  
            Lead ltemp = [SELECT Id, Status
                          FROM Lead
                          WHERE Id = :l.Id];

            List<Lead_Item__c> lis = [SELECT Id, Status__c, Opportunity__c
                                      FROM Lead_Item__c
                                      WHERE Lead__c = :l.Id];
            System.assert(lis.size() == 2);   

            lis[0].Status__c = '关闭--重复线索转化成功';
            lis[0].Opportunity__c = opp.Id;
            update lis[0];
        }

        Test.startTest();
        Appoitment__c app1 = new Appoitment__c ();
        Appoitment__c app2 = new Appoitment__c ();
        User u1 = [SELECT Id, UserRole.Name
                   FROM User
                   WHERE UserName = 'sophiezhou@eic.com.testcode'];

        System.runAs(u1) {

            app1 = new Appoitment__c ();
            app1.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = 'Invitation'].Id;
            app1.Opportunity__c = opp.Id;
            app1.Assign_To__c = UserInfo.getUserId();
            app1.Due_Date__c = System.Today();
            app1.Due_Time__c = '10:00';
            app1.Appointment_Type__c = '首次到访邀约';
            insert app1;

            app2 = new Appoitment__c ();
            app2.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = 'Invitation'].Id;
            app2.Opportunity__c = opp.Id;
            app2.Assign_To__c = UserInfo.getUserId();
            app2.Appointment_Type__c = '首次到访邀约';
            app2.Due_Date__c = System.Today();
            app2.Due_Time__c = '16:00';
            insert app2;
        }

        test.stopTest();
    }

    @isTest static void method2() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        System.runAs(u) {

            u.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Null_HQ_Null_Null_Null_Staff'].Id;
            update u;
            CreateUserUtil.CreateUserForAppointment();
            Account acct = new Account ();
            acct.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE DeveloperName='EIC_Account'
                                 AND SObjectType='Account'].Id;
            acct.Name = 'test001';
            acct.ID_Type__c = null;
            insert acct;
            Contact_EIC__c c2 = new Contact_EIC__c ();
            c2.Account__c = acct.Id;
            c2.Contact_Type__c= '手机';
            c2.UniqueContact__c = '13200000001';
            c2.isInvalid__c = false;
            c2.isPrimary__c = true;
            insert c2;  

            opp = new Opportunity();
            opp.RecordTypeId = [SELECT Id
                                FROM RecordType
                                WHERE DeveloperName = 'Counselling'
                                AND SObjectType = 'Opportunity'].Id;
            opp.Name = 'testopp001';
            opp.AccountId = acct.Id;
            opp.StageName = '顾问跟进';
            opp.ForecastCategoryName = 'Pipeline';
            opp.CloseDate = System.Today();
            insert opp; 

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '2015年10月上海百度竞价A';
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '线上';
            campaign1.Marketing_Channel_Lv2__c = 'PC';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;   

            Lead l = new Lead ();
            l.MobilePhone='13210987954';
            l.Is_Counselling__c = true;
            l.Is_TestPrep__c = true;
            l.Counselling_Project__c ='美国';
            l.TestPrep_Project__c = 'ACT';
            l.Intended_City__c = '上海';
            l.LastName = 'test123';
            l.Campaign__c = campaign1.Id;
            l.Company = 'EIC';
            l.Status= '全部转化';
            insert l;
            Lead ltemp = [SELECT Id,Status FROM Lead WHERE Id = :l.Id];

            List<Lead_Item__c> lis = [SELECT Id, Status__c, Opportunity__c
                                      FROM Lead_Item__c
                                      WHERE Lead__c = :l.Id];
            System.assert(lis.size() == 2);

            lis[0].Status__c = '关闭--重复线索转化成功';
            lis[0].Opportunity__c = opp.Id;
            update lis[0];
        }

        Test.startTest();
        Appoitment__c app1 = new Appoitment__c ();
        Appoitment__c app2 = new Appoitment__c ();
        User u1 = [SELECT Id, UserRole.Name
                   FROM User
                   WHERE UserName = 'sophiezhou@eic.com.testcode'];

        System.runAs(u1) {

            List<Appoitment__c> aps = new List<Appoitment__c> ();
            app1 = new Appoitment__c ();
            app1.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = 'Invitation'].Id;
            app1.Opportunity__c = opp.Id;
            app1.Assign_To__c = UserInfo.getUserId();
            app1.Due_Date__c = System.Today();
            app1.Due_Time__c = '10:00';
            app1.Appointment_Type__c = '首次到访邀约';
            aps.add(app1);

            app2 = new Appoitment__c ();
            app2.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = 'Invitation'].Id;
            app2.Opportunity__c = opp.Id;
            app2.Assign_To__c = UserInfo.getUserId();
            app2.Due_Date__c = System.Today();
            app2.Due_Time__c = '10:00';
            app2.Appointment_Type__c = '首次到访邀约';
            aps.add(app2);
            insert aps;
        }

        User own = [SELECT Id FROM User WHERE Username = 'own@eic.com.testcode'];
        opp.OwnerId = own.Id;
        update opp;

        Appoitment__c app = new Appoitment__c ();
        app.Opportunity__c = opp.Id;
        app.RecordTypeId = [SELECT Id
                            FROM RecordType
                            WHERE SObjectType = 'Appoitment__c'
                            AND DeveloperName = 'Front_Desk_Visit'].Id;
        insert app;

        test.stopTest();
    }

    @isTest static void method3() {

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        System.runAs(u) {

            u.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Null_HQ_Null_Null_Null_Staff'].Id;
            update u;
            CreateUserUtil.CreateUserForAppointment();
            Account acct = new Account ();
            acct.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE DeveloperName = 'EIC_Account'
                                 AND SObjectType = 'Account'].Id;
            acct.Name = 'test001';
            acct.ID_Type__c = null;
            insert acct;
            Contact_EIC__c c2 = new Contact_EIC__c ();
            c2.Account__c = acct.Id;
            c2.Contact_Type__c = '手机';
            c2.UniqueContact__c = '13200000001';
            c2.isInvalid__c = false;
            c2.isPrimary__c = true;
            insert c2;

            opp = new Opportunity ();
            opp.RecordTypeId = [SELECT Id
                                FROM RecordType
                                WHERE DeveloperName = 'Counselling'
                                AND SObjectType = 'Opportunity'].Id;
            opp.Name = 'testopp001';
            opp.AccountId = acct.Id;
            opp.StageName = '顾问跟进';
            opp.ForecastCategoryName = 'Pipeline';
            opp.CloseDate = System.Today();
            insert opp;

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '2015年10月上海百度竞价A';
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '线上';
            campaign1.Marketing_Channel_Lv2__c = 'PC';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;

            Lead l = new Lead ();
            l.MobilePhone='13210987954';
            l.Is_Counselling__c = true;
            l.Is_TestPrep__c = true;
            l.Counselling_Project__c ='美国';
            l.TestPrep_Project__c = 'ACT';
            l.Intended_City__c = '上海';
            l.LastName = 'test123';
            l.Campaign__c = campaign1.Id;
            l.Company = 'EIC';
            l.Status= '全部转化';
            insert l;  
            Lead ltemp = [SELECT Id, Status FROM Lead WHERE Id = :l.Id];
            System.debug(ltemp); 

            List<Lead_Item__c> lis = [SELECT Id, Status__c, Opportunity__c
                                      FROM Lead_Item__c
                                      WHERE Lead__c = :l.Id];
            System.assert(lis.size() == 2);

            lis[0].Status__c = '关闭--重复线索转化成功';
            lis[0].Opportunity__c = opp.Id;
            update lis[0];
        }

        Test.startTest();
        Appoitment__c app1 = new Appoitment__c ();
        Appoitment__c app2 = new Appoitment__c ();
        User u1 = [SELECT Id, UserRole.Name
                   FROM User
                   WHERE UserName = 'sophiezhou@eic.com.testcode'];

        System.runAs(u1) {

            List<Appoitment__c> aps = new List<Appoitment__c> ();
            app1 = new Appoitment__c ();
            app1.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = 'Invitation'].Id;
            app1.Opportunity__c = opp.Id;
            app1.Assign_To__c = UserInfo.getUserId();
            app1.Due_Date__c = System.Today();
            app1.Due_Time__c = '10:00';
            app1.Appointment_Type__c = '首次到访邀约';
            insert app1;
        }

        User own = [SELECT Id FROM User WHERE Username = 'own@eic.com.testcode'];
        opp.OwnerId = own.Id;
        update opp;

        System.runAs(own) {

            app2 = new Appoitment__c ();
            TriggerShouldRun.AppointmentShouldRun = false;
            app2.RecordTypeId = [SELECT Id
                                 FROM RecordType
                                 WHERE SObjectType = 'Appoitment__c'
                                 AND DeveloperName = 'Invitation'].Id;
            app2.Opportunity__c = opp.Id;
            app2.Assign_To__c = UserInfo.getUserId();
            app2.Due_Date__c = System.Today();
            app2.Due_Time__c = '16:00';
            app2.Appointment_Type__c = '首次到访邀约';
            insert app2;
            TriggerShouldRun.AppointmentShouldRun = true;
            app2.Status__c = '已到访';
            update app2;
        }
        test.stopTest();
    }

    @isTest static void method4 () {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = null;
        Lead l = new Lead ();
        System.runAs(u) {

            u.UserRoleId = [SELECT Id
                            FROM UserRole
                            WHERE DeveloperName = 'Null_HQ_Null_Null_Null_Staff'].Id;
            update u;
            CreateUserUtil.CreateUserForAppointment();

            Campaign campaign1 = new Campaign ();
            campaign1.Name = '2015年10月上海百度竞价A';
            campaign1.StartDate = System.Today();
            campaign1.EndDate = System.Today().addDays(30);
            campaign1.Approver__c = UserInfo.getUserId();
            campaign1.Marketing_Channel_Lv1__c = '线上';
            campaign1.Marketing_Channel_Lv2__c = 'PC';
            campaign1.Marketing_Channel_Lv3__c = '百度';
            insert campaign1;

            l.MobilePhone = '13210987954';
            l.Is_Counselling__c = true;
            l.Is_TestPrep__c = true;
            l.Counselling_Project__c ='美国';
            l.TestPrep_Project__c = 'ACT';
            l.Intended_City__c = '上海';
            l.LastName = 'test123';
            l.Campaign__c = campaign1.Id;
            l.Company = 'EIC';
            l.Status= '全部转化';
            insert l;
            Lead ltemp = [SELECT Id, Status FROM Lead WHERE Id = :l.Id];
        }

        Test.startTest();
        Appoitment__c app1 = new Appoitment__c ();
        Appoitment__c app2 = new Appoitment__c ();
        List<Appoitment__c> aps = new List<Appoitment__c> ();
        app1 = new Appoitment__c ();
        app1.RecordTypeId = [SELECT Id
                             FROM RecordType
                             WHERE SObjectType = 'Appoitment__c'
                             AND DeveloperName = 'Lead_Follow_Up'].Id;
        app1.Lead__c = l.Id;
        app1.Follow_Up_Result__c = '无人接听-1';
        app1.Description__c = 'xxxx';
        insert app1;

        app1.Follow_Up_Result__c = '拒绝回访';
        app1.Description__c = 'yyyy';
        update app1;
        test.stopTest();
    }
}