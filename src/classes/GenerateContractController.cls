public with sharing class GenerateContractController {
    Opportunity opp = new Opportunity();
    List<String> phones = new List<String>();

    Contract_System__c sageSystem = Contract_System__c.getValues('Prepsmith Sage Contract');
    Contract_System__c sageSubcontract = Contract_System__c.getValues('Prepsmith Sage SubContract');
    Contract_System__c sageMinoritySystem = Contract_System__c.getValues('Prepsmith Sage Minority Contract');
    Contract_System__c sageMinoritySubcontract = Contract_System__c.getValues('Prepsmith Sage Minority SubContract');
    Contract_System__c jiaowuSystem = Contract_System__c.getValues('Prepsmith Jiaowu Register');

    public GenerateContractController() {
        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        
        opp = [
            SELECT 
                (SELECT External_Contract_Id__c FROM Contracts__r WHERE Sage_Main_Contract_Id__c IN (NULL, '')),
                Account.Merge_Customer_Ids__c, Account.ext_Customer_id__c, Account.Name, Account.Gender__c, Account.ID_Number__c, Account.Is_Emergency__c,
                ext_Opportunity_id__c, C_Baoming_Type__c, AccountId, RecordType.Name, Contract_City__c, Department__c, Consultation_Mode__c, Project__c,
                Level_4_Promotion_Channel__r.Name, Level_4_Promotion_Channel__r.Marketing_Channel_Lv1__c, Level_4_Promotion_Channel__c, Intended_Office__c
                FROM Opportunity 
                WHERE Id =: oppId];

        for (Contact_EIC__c contact :[SELECT Unique_Contact__c FROM Contact_EIC__c WHERE Account__c = :opp.AccountId AND Contact_Type__c IN ('手机', '座机', 'mig_type', '紧急联系方式') AND isInvalid__c = FALSE]) {
            if (String.isNotBlank(contact.Unique_Contact__c) && !contact.Unique_Contact__c.contains('@')) {
                phones.add(contact.Unique_Contact__c);
            }
        }
    }

    public PageReference sendPostRequest() {
        User currentUser = [SELECT Sage_UserName__c, Paike_UserName__c FROM User WHERE Id =:UserInfo.getUserId()];

        if (opp.RecordType.Name == 'Counselling') {
            String requestUrl;
                if (opp.Department__c == '小语种部') {
                    // Create main contract
                    if (opp.Contracts__r.size() == 0) {
                        SASGPicklistMapping__c valmap = SASGPicklistMapping__c.getAll().get('SASGPicklistMapping');
                        Map<String,String> schoolMap = SASGMapConstruct(valmap,'LITA_Minority_School__c');
                        Map<String,String> branchMap = SASGMapConstruct(valmap,'LITA_Minority_Branch__c');
                        Map<String,String> projmap = SASGMapConstruct(valmap,'Project__c');

                        requestUrl = sageMinoritySystem.Endpoint__c;
                        requestUrl += 'custid=' + opp.AccountId;                
                        requestUrl += '&oldcustid=' + opp.Account.ext_Customer_id__c;
                        requestUrl += '&oldaoppid=' + opp.ext_Opportunity_id__c;
                        requestUrl += '&aoppid=' + opp.Id;
                        requestUrl += '&cnname=' + opp.Account.Name;
                        requestUrl += '&issubagent=' + 'N';
                        requestUrl += '&merge_list=' + opp.Account.Merge_Customer_Ids__c;
                        if (phones.size() > 0) {
                            requestUrl += '&mob=' + phones[0];  
                        } else {
                            requestUrl += '&mob=' + '';
                        }

                        if (opp.Account.Is_Emergency__c) {
                            requestUrl += '&isemergency=Y';
                        } else {
                            requestUrl += '&isemergency=N';
                        }

                        if (opp.Level_4_Promotion_Channel__r.Marketing_Channel_Lv1__c == '合作招生') {
                            requestUrl += '&campaignId=' + opp.Level_4_Promotion_Channel__c;
                            requestUrl += '&campaignName=' + opp.Level_4_Promotion_Channel__r.Name;

                        } else {
                            requestUrl += '&campaignId=NULL';
                            requestUrl += '&campaignName=NULL';
                        }
                        requestUrl += '&idcard=' + opp.Account.ID_Number__c;
                        requestUrl += '&method=M';
                        requestUrl += '&school=' + String.valueOf(Utils.minoritySchoolMap.get(opp.Intended_Office__c) == NULL?'6013':Utils.minoritySchoolMap.get(opp.Intended_Office__c));
                        requestUrl += '&branch=' + String.valueOf(Utils.minorityBranchMap.get(opp.Intended_Office__c) == NULL?'6024':Utils.minorityBranchMap.get(opp.Intended_Office__c));
                        requestUrl += '&intention=' + String.valueOf(projmap.get(opp.Project__c)==NULL?'others':projmap.get(opp.Project__c));       

                    // Create the subcontract
                    } else {
                        requestUrl = sageMinoritySubcontract.Endpoint__c;
                        if (opp.Level_4_Promotion_Channel__r.Marketing_Channel_Lv1__c == '合作招生') {
                            requestUrl += '&campaignId=' + opp.Level_4_Promotion_Channel__c;
                            requestUrl += '&campaignName=' + opp.Level_4_Promotion_Channel__r.Name;

                        } else {
                            requestUrl += '&campaignId=NULL';
                            requestUrl += '&campaignName=NULL';
                        }
                        requestUrl += '&contid=' + opp.Contracts__r[0].External_Contract_Id__c;
                    }

                } else {
                    // Create main contract
                    if (opp.Contracts__r.size() == 0) {
                        requestUrl = sageSystem.Endpoint__c;
                        SASGPicklistMapping__c valmap = SASGPicklistMapping__c.getAll().get('SASGPicklistMapping');
                        Map<String,String> citymap = SASGMapConstruct(valmap,'Contract_City__c');
                        Map<String,String> projmap = SASGMapConstruct(valmap,'Project__c');
                        Map<String,String> depmap = SASGMapConstruct(valmap,'Department__c');
                        Map<String,String> methodmap = SASGMapConstruct(valmap,'Consultation_Mode__c');
                        requestUrl += 'custid=' + opp.AccountId;                
                        requestUrl += '&oldcustid=' + opp.Account.ext_Customer_id__c;
                        requestUrl += '&oldaoppid=' + opp.ext_Opportunity_id__c;
                        requestUrl += '&aoppid=' + opp.Id;
                        requestUrl += '&cnname=' + opp.Account.Name;
                        requestUrl += '&issubagent=' + 'N';
                        requestUrl += '&merge_list=' + opp.Account.Merge_Customer_Ids__c;
                        if (phones.size() > 0) {
                            requestUrl += '&mob=' + phones[0];  
                        } else {
                            requestUrl += '&mob=' + '';
                        }

                        if (opp.Level_4_Promotion_Channel__r.Marketing_Channel_Lv1__c == '合作招生') {
                            requestUrl += '&campaignId=' + opp.Level_4_Promotion_Channel__c;
                            requestUrl += '&campaignName=' + opp.Level_4_Promotion_Channel__r.Name;
                            
                        } else {
                            requestUrl += '&campaignId=NULL';
                            requestUrl += '&campaignName=NULL';
                        }

                        if (opp.Account.Is_Emergency__c) {
                            requestUrl += '&isemergency=Y';
                        } else {
                            requestUrl += '&isemergency=N';
                        }

                        requestUrl += '&idcard=' + opp.Account.ID_Number__c;
                        requestUrl += '&method='+ String.valueOf(methodmap.get(opp.Consultation_Mode__c)==NULL?'W':methodmap.get(opp.Consultation_Mode__c))+
                                      '&country='+ String.valueOf(projmap.get(opp.Project__c)==NULL?'US':projmap.get(opp.Project__c)) +
                                      '&cpy='+ String.valueOf(citymap.get(opp.Contract_City__c)==NULL?'ABC':citymap.get(opp.Contract_City__c));
                        
                        if (opp.Department__c == '学游项目部') {
                            requestUrl += '&dep=AAX';

                        } else {
                            requestUrl += '&dep='+ String.valueOf(Utils.countryMapDeptCode.get(opp.Project__c) ==NULL?'AAC':Utils.countryMapDeptCode.get(opp.Project__c));
                        }

                    // Create the subcontract
                    } else {
                        requestUrl = sageSubcontract.Endpoint__c;
                        if (opp.Level_4_Promotion_Channel__r.Marketing_Channel_Lv1__c == '合作招生') {
                            requestUrl += '&campaignId=' + opp.Level_4_Promotion_Channel__c;
                            requestUrl += '&campaignName=' + opp.Level_4_Promotion_Channel__r.Name;

                        } else {
                            requestUrl += '&campaignId=NULL';
                            requestUrl += '&campaignName=NULL';
                        }
                        requestUrl += '&contid=' + opp.Contracts__r[0].External_Contract_Id__c;
                    }   
                }
                
        
            PageReference newContractPage = new PageReference(requestUrl);
            System.debug(LoggingLevel.INFO, '*** requestUrl: ' + requestUrl);
            newContractPage.setRedirect(TRUE);
            return newContractPage;

        } else {
            String mobile;
            if (phones.size() > 0) {
                mobile = phones[0]; 
            } else {
                mobile = '';
            }          

            String requestUrl = jiaowuSystem.Endpoint__c;
            String requestStr = '';
            if (opp.Contracts__r.size() > 0) {
                JiaowuHeader jwHeader = new JiaowuHeader(
                    getCBaoMingType(), opp.AccountId, opp.Id, 
                    opp.Account.ext_Customer_id__c, 
                    opp.ext_Opportunity_id__c, 1, 
                    opp.Contracts__r[0].External_Contract_Id__c, opp.Account.Name,
                    mobile, getGenderType(), 
                    currentUser.Paike_UserName__c,
                    opp.Account.Merge_Customer_Ids__c);
                requestStr = JSON.serialize(jwHeader);

            } else {
                JiaowuHeader jwHeader = new JiaowuHeader(
                    getCBaoMingType(), opp.AccountId, 
                    opp.Id, opp.Account.ext_Customer_id__c, 
                    opp.ext_Opportunity_id__c,0, '', 
                    opp.Account.Name, mobile, getGenderType(),
                    currentUser.Paike_UserName__c,
                    opp.Account.Merge_Customer_Ids__c);
                requestStr = JSON.serialize(jwHeader);
            }
            
            requestStr = 'JSONData=' +requestStr;
            requestStr = requestStr.escapeEcmaScript();
            requestStr = EncodingUtil.urlEncode(requestStr, 'UTF-8');
            requestUrl += requestStr;

            PageReference jiaowuContractPage = new PageReference(requestUrl);
            jiaowuContractPage.setRedirect(TRUE);
            return jiaowuContractPage;
        }       
    }


    //POST Method
    public Map<String,String> SASGMapConstruct(SASGPicklistMapping__c obj,String s){
        String val1 = '';
        String val2 = '';
        if(s=='Project__c'){
            val1 = obj.CRMCountry1__c+((obj.CRMCountry2__c==NULL || obj.CRMCountry2__c=='')?'':(','+obj.CRMCountry2__c));
            val2 = obj.SASGCountry1__c+((obj.SASGCountry2__c==NULL || obj.SASGCountry2__c=='')?'':(','+obj.SASGCountry2__c));
        }else if(s=='Contract_City__c'){
            val1 = obj.CRMCity1__c+((obj.CRMCity2__c==NULL || obj.CRMCity2__c=='')?'':(','+obj.CRMCity2__c));
            val2 = obj.SASGCity1__c+((obj.SASGCity2__c==NULL || obj.SASGCity2__c=='')?'':(','+obj.SASGCity2__c));
        }else if(s=='Department__c'){
            val1 = obj.CRMDepartment1__c+((obj.CRMDepartment2__c==NULL || obj.CRMDepartment2__c=='')?'':(','+obj.CRMDepartment2__c));
            val2 = obj.SASGDepartment1__c+((obj.SASGDepartment2__c==NULL || obj.SASGDepartment2__c=='')?'':(','+obj.SASGDepartment2__c));
        }else if(s=='Consultation_Mode__c'){
            val1 = obj.CRMMethod1__c+((obj.CRMMethod2__c==NULL || obj.CRMMethod2__c=='')?'':(','+obj.CRMMethod2__c));
            val2 = obj.SASGMethod1__c+((obj.SASGMethod2__c==NULL || obj.SASGMethod2__c=='')?'':(','+obj.SASGMethod2__c));
        }

        if(val1.length()==0 || val2.length()==0){
            return new Map<String,String>();
        }
        List<String> array1 = val1.split(',');
        List<String> array2 = val2.split(',');
        if(array1.size() != array2.size()){
            return new Map<String,String>();
        }
        Map<String,String> m = new Map<String,String>();
        for(Integer i = 0; i<array1.size(); i++){
            m.put(array1[i],array2[i]);
        }
        return m;

    }

    public class SageNewContract {
        public String result;
        public String msg;

    }

    public class JiaowuHeader {
        Integer Page_Type;
        String CRM_Student_ID;
        String CRM_Opportunity_ID;

        String Old_CRM_Student_ID;
        String Old_CRM_Opportunity_ID;

        Integer CRM_Opportunity_Type;
        String CRM_Contract_ID;     
        String CRM_Student_Name;
        String CRM_Student_Phone;
        Integer CRM_Student_Sex;        
        String BS_User_Name;
        // String BS_User_Password;
        String Old_CRM_Student_IDs;

        public JiaowuHeader (
                Integer Page_Type, String CRM_Student_ID, String CRM_Opportunity_ID, String Old_CRM_Student_ID, String Old_CRM_Opportunity_ID,
                Integer CRM_Opportunity_Type, String CRM_Contract_ID, String CRM_Student_Name, String CRM_Student_Phone, Integer CRM_Student_Sex, 
                String BS_User_Name,
                String Old_CRM_Student_IDs) {
            this.Page_Type = Page_Type;
            this.CRM_Student_ID = CRM_Student_ID;
            this.CRM_Opportunity_ID = CRM_Opportunity_ID;
            this.Old_CRM_Student_ID = Old_CRM_Student_ID;
            this.Old_CRM_Opportunity_ID = Old_CRM_Opportunity_ID;
            this.CRM_Opportunity_Type = CRM_Opportunity_Type;
            this.CRM_Contract_ID = CRM_Contract_ID;     
            this.CRM_Student_Name = EncodingUtil.urlEncode(CRM_Student_Name, 'UTF-8');
            this.CRM_Student_Phone = CRM_Student_Phone;
            this.CRM_Student_Sex = CRM_Student_Sex;     
            this.BS_User_Name = EncodingUtil.urlEncode(BS_User_Name, 'UTF-8');
            this.Old_CRM_Student_IDs = Old_CRM_Student_IDs;
            // this.BS_User_Password = BS_User_Password;
        }
    }

    public Integer getCBaoMingType() {
        if (opp.C_Baoming_Type__c == '自选课程报名') {
            return 1;
        } else if (opp.C_Baoming_Type__c == '多班级连报') {
            return 2;
        } else if (opp.C_Baoming_Type__c == '中途插班报名') {
            return 3;
        } else if (opp.C_Baoming_Type__c == '定金报名') {
            return 5;
        } else if (opp.C_Baoming_Type__c == '仅服务费报名') {
            return 6;
        } else {
            return 0;
        }
    }

    public Integer getGenderType() {
        if (opp.Account.Gender__c == '女') {
            return 1;
        } else {
            return 0;
        }
    }
}