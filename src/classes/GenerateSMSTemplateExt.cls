public with sharing class GenerateSMSTemplateExt {
    public String fieldAPI { get; set; }
    public String mergeField;
    public Map<String, Schema.SObjectType> allObjMap;
    public List<SelectOption> fieldAPIList { get; set; }
    public SMS_Template__c SMSTemplate { get; set; }

    private String relatedTo;

    public GenerateSMSTemplateExt(ApexPages.StandardController controller) {
        SMSTemplate = (SMS_Template__c)controller.getRecord();
        allObjMap = Schema.getGlobalDescribe();
        fieldAPIList = new List<SelectOption>();

        if(SMSTemplate.Related_To__c == '客户'){
            relatedTo = 'Account';
        }else if(SMSTemplate.Related_To__c == '销售线索'){
            relatedTo = 'Lead';
        }else if(SMSTemplate.Related_To__c == '商机'){
            relatedTo = 'Opportunity';
        }

        if (allObjMap.get(relatedTo) == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, '"相关项"'  + relatedTo +  '没有找到, 请使用相关项选项卡中的值.'));
            return;
        }

        Schema.SobjectType d = allObjMap.get(relatedTo);
        fieldAPIList.add(new SelectOption('', ''));
        Integer i = 0;
        for (String s : d.getDescribe().fields.getMap().keySet()) {
            if (i == 99) break; 

            Schema.DescribeFieldResult f = d.getDescribe().fields.getMap().get(s).getDescribe();
            String label = String.valueOf(f.getLabel());
            fieldAPIList.add(new SelectOption(s, label));
            i ++;
        }

        fieldAPIList.sort();

        addLeftFieldLabel();
    }

    public void save(){
        update SMSTemplate;
    }

    // generate api field list
    public void addLeftFieldLabel() {
        if (allObjMap.get(relatedTo) == null) return;

        Schema.SobjectType d = allObjMap.get(relatedTo);
        Integer i = 0;
        for (String s :d.getDescribe().fields.getMap().keySet()) {
                i ++;
                if (i < 99) continue;                
                Schema.DescribeFieldResult f = d.getDescribe().fields.getMap().get(s).getDescribe();
                String label = String.valueOf(f.getLabel());
                FieldAPIList.add(new SelectOption(s, label));
        }

        FieldAPIList.sort();
    }

    public void setMergeField(String mergeField) {
        this.mergeField = mergeField;    
    }

    public String getMergeField() {
        if (fieldAPI == null || fieldAPI == '' ) {
           return null;
        } else {
            return  '{!' + relatedTo + '.' + fieldAPI +'}';    
        }
    }
}