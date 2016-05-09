@isTest
public class CreateUserUtil {

    public static void CreateUserForAppointment() {

        List<User> us = new List<User> ();
        User sophie = new User ();
        sophie.Username= 'sophiezhou@eic.com.testcode';
        sophie.Email = 'sophiezhou@eiceducation.com.cn.testcode';
        sophie.Lastname = 'sophie';
        sophie.Firstname = 'zhou';
        sophie.Alias = 'sophie';
        sophie.ProfileId = [SELECT Id FROM Profile WHERE Name = '集团市场部呼叫中心主管'].Id;
        sophie.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Marketing_HQ_Null_CS_TMK_Incharge'].Id;
        sophie.TimeZoneSidKey = 'GMT';
        sophie.LocaleSidKey = 'en_US';
        sophie.EmailEncodingKey = 'ISO-8859-1';
        sophie.LanguageLocaleKey = 'en_US';
        sophie.UserPermissionsMobileUser = false;
        us.add(sophie);

        User grouptmk400a = new User ();
        grouptmk400a.Username= 'grouptmk400a@eic.com.testcode';
        grouptmk400a.Email = 'grouptmk400a@eiceducation.com.cn.testcode';
        grouptmk400a.Lastname = 'grouptmk400a';
        grouptmk400a.Firstname = 'zhou';
        grouptmk400a.Alias = 'tmk400a';
        grouptmk400a.ProfileId = [SELECT Id FROM Profile WHERE Name='集团市场部呼叫中心主管'].Id;
        grouptmk400a.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName='Marketing_HQ_Null_CS_TMK_Incharge'].Id;
        grouptmk400a.TimeZoneSidKey = 'GMT';
        grouptmk400a.LocaleSidKey = 'en_US';
        grouptmk400a.EmailEncodingKey = 'ISO-8859-1';
        grouptmk400a.LanguageLocaleKey = 'en_US';
        grouptmk400a.UserPermissionsMobileUser = false;
        us.add(grouptmk400a);

        User desk = new User ();
        desk.Username= 'desk@eic.com.testcode';
        desk.Email = 'desk@eiceducation.com.cn.testcode';
        desk.Lastname = 'desk';
        desk.Firstname = 'zhou';
        desk.Alias = 'desk';
        desk.ProfileId = [SELECT Id FROM Profile WHERE Name='分公司分校前台'].Id;
        desk.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName='Counselling_SH_Renguang_CS_Null_Reception'].Id;
        desk.TimeZoneSidKey = 'GMT';
        desk.LocaleSidKey = 'en_US';
        desk.EmailEncodingKey = 'ISO-8859-1';
        desk.LanguageLocaleKey = 'en_US';
        desk.UserPermissionsMobileUser = false;
        us.add(desk);

        User own = new User ();
        own.Username= 'own@eic.com.testcode';
        own.Email = 'own@eiceducation.com.cn.testcode';
        own.Lastname = 'own';
        own.Firstname = 'zhou';
        own.Alias = 'own';
        own.ProfileId = [SELECT Id FROM Profile WHERE Name='分公司分校销售顾问'].Id;
        own.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName='Counselling_SH_Renguang_AN_Null_Consultant'].Id;
        own.TimeZoneSidKey = 'GMT';
        own.LocaleSidKey = 'en_US';
        own.EmailEncodingKey = 'ISO-8859-1';
        own.LanguageLocaleKey = 'en_US';
        own.UserPermissionsMobileUser = false;
        us.add(own);

        insert us;
    }

    public static void CreateUserForServicingTable() {

        List<User> us = new List<User> ();
        User sophie = new User ();
        sophie.Username= 'sophiezhou@eiceducation.com.cn.testcode';
        sophie.Email = 'sophiezhou@eiceducation.com.cn.testcode';
        sophie.Lastname = 'sophie';
        sophie.Firstname = 'zhou';
        sophie.Alias = 'sophie';
        sophie.ProfileId = [SELECT Id FROM Profile WHERE Name='集团市场部呼叫中心主管'].Id;
        sophie.TimeZoneSidKey = 'GMT';
        sophie.LocaleSidKey = 'en_US';
        sophie.EmailEncodingKey = 'ISO-8859-1';
        sophie.LanguageLocaleKey = 'en_US';
        sophie.UserPermissionsMobileUser = false;
        us.add(sophie);

        User grouptmk400a = new User ();
        grouptmk400a.Username= 'grouptmk400a@eic.com.testcode';
        grouptmk400a.Email = 'grouptmk400a@eiceducation.com.cn.testcode';
        grouptmk400a.Lastname = 'grouptmk400a';
        grouptmk400a.Firstname = 'zhou';
        grouptmk400a.Alias = 'tmk400a';
        grouptmk400a.ProfileId = [SELECT Id FROM Profile WHERE Name='集团市场部呼叫中心主管'].Id;
        grouptmk400a.TimeZoneSidKey = 'GMT';
        grouptmk400a.LocaleSidKey = 'en_US';
        grouptmk400a.EmailEncodingKey = 'ISO-8859-1';
        grouptmk400a.LanguageLocaleKey = 'en_US';
        grouptmk400a.UserPermissionsMobileUser = false;
        us.add(grouptmk400a);

        User cherry = new User ();
        cherry.Username= 'cherry@eiceducation.com.cn.testcode';
        cherry.Email = 'cherry@eiceducation.com.cn.testcode';
        cherry.Lastname = 'cherry';
        cherry.Firstname = 'cherry';
        cherry.Alias = 'cherry';
        cherry.ProfileId = [SELECT Id FROM Profile WHERE Name='集团IT系统管理员'].Id;
        cherry.TimeZoneSidKey = 'GMT';
        cherry.LocaleSidKey = 'en_US';
        cherry.EmailEncodingKey = 'ISO-8859-1';
        cherry.LanguageLocaleKey = 'en_US';
        cherry.UserPermissionsMobileUser = false;
        us.add(cherry);

        insert us;
    }
}