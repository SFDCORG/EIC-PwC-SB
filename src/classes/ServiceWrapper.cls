global without sharing class ServiceWrapper{
    global class SageContract{
        private String custid;
        private String aoppid;
        private String contid;
        private String contno;
        private String contsta;
        private String contprd;
        private String contprds;
        private String contamt;
        private String contpaid;
        private String contdis;
        private String contsysdat;
        private String contpid;
        private String issubagent;
        private String contractCounsellor;
        private String sageOpportunityId;

        global SageContract(
            String custid,
            String aoppid,
            String contid,
            String contno,
            String contsta,
            String contprd,
            String contprds,
            String contamt,
            String contpaid,
            String contdis,
            String contsysdat,
            String contpid,
            String issubagent,
            String contractCounsellor,
            String sageOpportunityId){
                this.custid = custid;
                this.aoppid = aoppid;
                this.contid = contid;
                this.contno = contno;
                this.contsta = contsta;
                this.contprd = contprd;
                this.contprds = contprds;
                this.contamt = contamt;
                this.contpaid = contpaid;
                this.contdis = contdis;
                this.contsysdat = contsysdat;
                this.contpid = contpid;
                this.issubagent = issubagent;
                this.contractCounsellor = contractCounsellor;
                this.sageOpportunityId = sageOpportunityId;
        }
    }
    
    public static List<Contract__c> MapSageContract(List<SageContract> scs){
        List<Contract__c> cons = new List<Contract__c>();
        List<Opportunity> opportunities = new List<Opportunity>();
        Map<String, String> oppIdMapSageOppId = new Map<String, String>();
        Map<String, Opportunity> sageOppIdMapOpp = new Map<String, Opportunity>();
        Set<String> externalIds = new Set<String>();

        String recId = Utils.getRecordTypeId('Contract__c', 'Counselling');
        Set<String> sageOppIds = new Set<String>();
        Set<String> oppIds = new Set<String>();

        System.debug(LoggingLevel.INFO, '*** scs: ' + scs);

        for(SageContract sc : scs){
            if (String.isNotBlank(sc.sageOpportunityId)) {
                sageOppIds.add(sc.sageOpportunityId);
            }

            if (String.isNotBlank(sc.aoppid)) {                
                oppIdMapSageOppId.put(sc.aoppid, sc.sageOpportunityId);
            }
        }

        for (Opportunity opp :[
                SELECT Id, ext_Opportunity_id__c, AccountId
                FROM Opportunity
                WHERE ext_Opportunity_id__c IN :sageOppIds]) {
            sageOppIdMapOpp.put(opp.ext_Opportunity_id__c, opp);
        }

        for(SageContract sc : scs){            
            if (String.isBlank(sc.aoppid) && String.isBlank(sc.sageOpportunityId)) continue;
            if (!externalIds.contains(sc.contid)) {
                Contract__c con = new Contract__c();
                con.Account__c = sc.custid == ''?sageOppIdMapOpp.get(sc.sageOpportunityId).AccountId:sc.custid;
                con.Opportunity__c= sc.aoppid == ''?sageOppIdMapOpp.get(sc.sageOpportunityId).Id:sc.aoppid;
                con.External_Contract_Id__c = sc.contid;
                con.Contract_Number__c = sc.contno;
                con.Status__c = sc.contsta;
                con.Type__c = sc.contprd;
                con.Sage_Sub_Product__c = sc.contprds;
                con.Amount__c = sc.contamt == '' ? 0 : Decimal.valueOf(sc.contamt);
                con.Pay_Amount__c = sc.contpaid == '' ? 0 :  Decimal.valueOf(sc.contpaid);
                con.Sage_Discount__c = sc.contdis == '' ? 0 : Decimal.valueOf(sc.contdis);
                con.Contract_Date__c = sc.contsysdat == '' ?NULL: Date.valueOf(sc.contsysdat);
                con.Sage_Main_Contract_Id__c = sc.contpid;
                con.Is_Subagent__c = sc.issubagent == 'N'?FALSE:TRUE;
                con.Contract_Counsellor__c = sc.contractCounsellor;
                if(recId != ''){
                    con.RecordTypeId = recId;
                }
                cons.add(con);
                externalIds.add(sc.contid);
            }            
        }

        // Set opportunities Sage opportunity Id
        try {
            for (Opportunity opp :[
                    SELECT Id, ext_Opportunity_id__c
                    FROM Opportunity
                    WHERE Id IN :oppIdMapSageOppId.keySet()]) {
                opp.ext_Opportunity_id__c = oppIdMapSageOppId.get(opp.Id);
                opportunities.add(opp);
            }
            update opportunities;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }

        return cons;
    }

    public static List<Sage_Payment__c>  MapSagePayment(List<SagePayment> payments){
        List<Sage_Payment__c> pays = new List<Sage_Payment__c>();
        List<String> contIds = new List<String>();
        Map<String, Contract__c> contractMap = new Map<String, Contract__c>();
    
        System.debug(LoggingLevel.INFO, '*** payments: ' + payments);

        //Get external contranct and contract Id relationship
        for(SagePayment payment: payments){
            contIds.add(payment.contid);
        }
        for(Contract__c con :[SELECT Id, External_Contract_Id__c,Account__c,Opportunity__c,Opportunity__r.AccountId FROM Contract__c WHERE External_Contract_Id__c in :contIds]){
            contractMap.put(con.External_Contract_Id__c, con);
        }

        for(SagePayment payment: payments){
            Sage_Payment__c pay = new Sage_Payment__c();
            pay.Account__c = payment.custid == ''?contractMap.get(payment.contid).Opportunity__r.AccountId:payment.custid;
            pay.Opportunity__c = payment.aoppid == ''?contractMap.get(payment.contid).Opportunity__c:payment.aoppid;
            pay.Payment_Id__c = payment.payid;
            pay.Property__c = payment.property;
            pay.Amount__c = Decimal.valueOf(payment.amt);
            pay.Type__c = payment.typ;
            pay.Contract__c = contractMap.get(payment.contid).Id;
            pays.add(pay);
        }
        return pays;
    }


    global class SagePayment{       
        private String custid;
        private String aoppid;
        private String contid;
        private String payid;
        private String property;
        private String amt;
        private String typ;
        private String sta;

        global SagePayment(String custid,
            String aoppid,
            String contid,
            String payid,
            String property,
            String amt,
            String typ,
            String sta){
            this.custid = custid;
            this.aoppid = aoppid;
            this.contid = contid;
            this.payid = payid;
            this.property = property;
            this.amt = amt;
            this.typ = typ;
            this.sta = sta;

        }        
    }

    global class IntServContract{
        public String CRM_Student_ID;        //Account
        public String CRM_Opportunity_ID;    //Opportunity
        public String CRM_Contract_ID;       //External Contract Id
        public String BS_Student_Code;       //Student Code
        public String BS_Contract_Code;      //Contract code
        public String BS_Event_Type;         //Type
        public List<RegisterInfo> BS_Register_Infos;
    }

    global class RegisterInfo{
        public String Code;
        public String Date_Stamp;
        public String CS_Hour;
        public String CS_Hour_Quit;
        public String CS_hour_Effective;
        public String Receivables_Money;
        public String Pay_Money;
        public String Arrears_Money;
        public String Price;
        public String Price_Discount;
        public String Fee;
        public String Fee_Quit;
        public String Fee_Service;
        public String Fee_Quit_Service;
        public String Fee_Additional;


        public List<IntServPayment> Pay_Records;
        public List<CourseItem> Curriculas;
    }

    global class IntServPayment{
        public String DateStamp;
        public String Money;
    }

    global class CourseItem{
        public String Code;
        public String Name;
    }

    public static Contract__c MapIntServContract(IntServContract isc){        

        String recId = '';
        for( RecordType rec : [SELECT Id, RecordType.Name, SObjectType FROM RecordType 
                    WHERE RecordType.Name = 'IntServ' AND SObjectType = 'Contract__c']){
            recId = rec.Id;
        }

        Contract__c con = new Contract__c();
        con.Account__c = isc.CRM_Student_ID;
        con.Opportunity__c = isc.CRM_Opportunity_ID;
        con.External_Contract_Id__c = isc.CRM_Contract_ID;
        con.Type__c = isc.BS_Event_Type;
        if(recId != ''){
            con.RecordTypeId = recId;
        }

        return con;
    }

    public static List<Register__c> MapIntServReg(Id conId, List<RegisterInfo> regInfos){
        List<Register__c> regs = new List<Register__c>();

        for(RegisterInfo regInfo : regInfos){
            Register__c reg = new Register__c();
            reg.Contract__c = conId;

            reg.Code__c = regInfo.Code;
            reg.Date_Stamp__c = Date.valueOf(regInfo.Date_Stamp);
            reg.CS_Hour__c = Decimal.valueOf(regInfo.CS_Hour)/100;
            reg.CS_Hour_Quit__c = Decimal.valueOf(regInfo.CS_Hour_Quit)/100;
            reg.CS_hour_Effective__c = Decimal.valueOf(regInfo.CS_hour_Effective)/100;
            reg.Receivables_Money__c = Decimal.valueOf(regInfo.Receivables_Money)/100;
            reg.Pay_Money__c = Decimal.valueOf(regInfo.Pay_Money)/100;
            reg.Arrears_Money__c = Decimal.valueOf(regInfo.Arrears_Money)/100;
            reg.Price__c = Decimal.valueOf(regInfo.Price)/100;
            reg.Price_Discount__c = Decimal.valueOf(regInfo.Price_Discount)/100;
            reg.Fee__c = Decimal.valueOf(regInfo.Fee)/100;
            reg.Fee_Quit__c = Decimal.valueOf(regInfo.Fee_Quit)/100;
            reg.Fee_Service__c = Decimal.valueOf(regInfo.Fee_Service)/100;
            reg.Fee_Quit_Service__c = Decimal.valueOf(regInfo.Fee_Quit_Service)/100;
            reg.Fee_Additional__c = Decimal.valueOf(regInfo.Fee_Additional)/100;

            regs.add(reg);
        }

        return regs;
    }

    public static List<IntServ_Course__c> MapIntServCourse(Id regId, List<CourseItem> courses){
        List<IntServ_Course__c> cs = new List<IntServ_Course__c>();
        for(CourseItem item : courses){
            IntServ_Course__c c = new IntServ_Course__c();
            c.Name = item.Name;
            c.Code__c = item.Code;
            c.Register__c = regId;

            cs.add(c);
        }

        return cs;
    }

    public static List<IntServ_Payment__c> MapIntServPayment(Id regId, List<IntServPayment> pays){
        List<IntServ_Payment__c> payments = new List<IntServ_Payment__c>();
        for(IntServPayment pay: pays){
            IntServ_Payment__c payment = new IntServ_Payment__c();
            payment.Date_Stamp__c = Date.valueOf(pay.DateStamp);
            payment.Money__c = Decimal.valueOf(pay.Money)/100;
            payment.Register__c = regId;

            payments.add(payment);
        }

        return payments;
    }


    global class PaymentStatus{
        public String custid;         //SFDC客户Id
        public String aoppid;         //SFDC商机Id
        public String contid;         //Sage合同Id
        public String typ1;           //Y = 一期款收齐, N = 一期款未收齐
        public String typ2;           //Y = 全款收齐, N = 全款未收齐
    }

    global class CustInfo{
        public String custid;      //SFDC客户ID*
        public String cnname;      //客户姓名
        public String mob;         //客户手机
        public String idcard;      //客户证件号
        public String birthday;    //出生日期
        public String sex;         //性别
        public String email;       //电子邮箱
        public String qq;          //QQ
        public String msn;         //MSN
        public String homeadd;     //家庭地址

    }

    global class OppInfo{
        public String aoppid;             //SFDC 商机ID
        public String coursetype;         //机会申请层次
        public String plantime;           //拟出国时间
    }

    public static void UpdatePaymentStatus(List<PaymentStatus> pays){
        List<Contract__c> cons = new List<Contract__c>();

        for(PaymentStatus pay : pays){
            Contract__c con = new Contract__c(External_Contract_Id__c = pay.contid);

            if(pay.typ1 == 'Y'){
                con.Subscription__c = true;
            }
            else{
                con.Subscription__c = false;
            }

            if(pay.typ2 == 'Y') {
                con.Paid_In_Full__c = true;
            }
            else{
                con.Paid_In_Full__c = false;
            }

            cons.add(con);
        }      

        upsert cons External_Contract_Id__c;
    }

    public static void UpdateCustInfo(List<CustInfo> custs){
        // List<Account> accs = new List<Account>();
        // for(CustInfo cust : custs){
        //     Account acc = new Account(Id = cust.custid, RecordTypeId = Utils.getRecordTypeId('Account', 'EIC Account'));
        //     acc.Name = cust.cnname;
        //     //acc.Phone = cust.mob;
        //     acc.ID_Number__c = cust.idcard;
        //     acc.ID_Type__c = '身份证';
        //     if (cust.birthday != null && cust.birthday != ''){
        //         acc.Birthday__c = Date.valueOf(cust.birthday);
        //     }
            
        //     if (cust.sex == 'Male' || cust.sex == '男'){
        //         acc.Gender__c = '男';
        //     }
        //     else if (cust.sex == 'Female' || cust.sex == '女'){
        //         acc.Gender__c = '女';
        //     }
        //     else{
        //         acc.Gender__c = '不便透露';
        //     }

        //     accs.add(acc);
        // }
        // update accs;
    }

    public static void UpdateOppInfo(List<OppInfo> oppInfos){
        List<Opportunity> opps = new List<Opportunity>();

        for(OppInfo oppInfo : oppinfos){
            Opportunity opp = new Opportunity(Id = oppInfo.aoppid);
            if(oppInfo.plantime != null && oppInfo.plantime != ''){
                opp.Schedule_Abroad_Date__c = Date.valueOf(oppInfo.plantime);
            }           

            if (oppInfo.coursetype != null && oppInfo.coursetype != ''){
                Integer rating  = Integer.valueOf(oppInfo.coursetype);
                String strRating = '';
                for(Integer i = 1; (i <= rating ) && (i <= 5) ;i ++){
                    strRating += '★';
                }

                opp.Star_Rating__c = strRating;
            }
            

            opps.add(opp);
        }
        

        update opps;
    }


    global class ContractDetail{
        public String contid;
        public String contno;
        public String Module {get;set;}
        public String EID;
        public String Status {get;set;}
        public String uname {get;set;}
        public String memo {get;set;}


    }

    public List<ServiceWrapper.ContractDetail> jsondata;

    public static ServiceWrapper parse(String json) {
        return (ServiceWrapper)System.JSON.deserialize(json, ServiceWrapper.class);
    } 
}