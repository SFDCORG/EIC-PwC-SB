public with sharing class IntendedSchoolListViewController {
	public Map<String,String> facultyMap {get;set;}
	public Map<String,String> majorMap {get;set;}
	public Map<String,String> degreeMap {get;set;}
	public Id oppId {get;set;}
	public List<schoolWrap> iSchoolWraps{get;set;}
    public IntendedSchoolListViewController(ApexPages.StandardController con) {
    	//oppId = con.getId();
    	oppId = ApexPages.currentPage().getParameters().get('Id');
    	facultyMap = new Map<String,String>();
    	majorMap = new Map<String,String>();
    	degreeMap = new Map<String,String>();
    	CallOutMethod__c cm = CallOutMethod__c.getValues('PrepSmithAPIStagingCriteria');
        String endpoint =  cm.EndPoint__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndPoint(endpoint);
        request.setHeader('Authorization', 'OUkxMStDNCs1OlVNP0s/Tl46MzhMREk4TlE1VEQ0KDFXRisyUDhPezxCJDk6Tisz');
        request.setMethod('GET');
        request.setTimeout(120000);
        response = http.send(request);  
        system.debug(response.getBody());
        Map<String,Object>initdata =(Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        Map<String,Object>data = (Map<String,Object>)initdata.get('data');
        List<object> faculties = (List<object>)data.get('faculty');
        List<object> degrees = (List<object>)data.get('degree_type');
        for(Object o : faculties){
        	Map<string,object> obj = (Map<String,object>)o;
        	facultyMap.put(String.valueOf(obj.get('uuid')),String.valueOf(obj.get('chinese_name')));
        	List<Object> ms = (List<object>)obj.get('systemmajor');
        	for(Object m : ms){
        		Map<String,object> mobj = (Map<String,object>)m;
        		majorMap.put(String.valueOf(mobj.get('uuid')),String.valueOf(mobj.get('chinese_name')));
        	}
        }

        for(Object o : degrees){
        	Map<string,object> obj = (Map<String,object>)o;
        	degreeMap.put(String.valueOf(obj.get('uuid')),String.valueOf(obj.get('chinese_name')));
        }
        system.debug(majorMap);

        List<Intended_School__c>iSchools = [SELECT Id, Opportunity__c, Description__c, UUID_School__c, UUID_Major__c, UUID_Degree__c, UUID_Faculty__c, SchoolNameBak__c FROM Intended_School__c Where Opportunity__c = :oppId];

        iSchoolWraps = new List<schoolWrap>();
        Set<String> uuids = new Set<String>();
        for(Intended_School__c is : iSchools){
            if(is.UUID_School__c!=null && is.UUID_School__c !=''){
                uuids.add(is.UUID_School__c);
            }
        }
        String schoolParam = JSON.serialize(uuids);

        CallOutMethod__c cm1 = CallOutMethod__c.getValues('SchoolMultiUUID');
        String endpoint1 =  cm1.EndPoint__c;
        endpoint1 += '?uuids='+EncodingUtil.urlEncode(schoolParam, 'UTF-8');
        Http http1 = new Http();
        HttpRequest request1 = new HttpRequest();
        HttpResponse response1 = new HttpResponse();
        request1.setEndPoint(endpoint1);
        request1.setHeader('Authorization', 'OUkxMStDNCs1OlVNP0s/Tl46MzhMREk4TlE1VEQ0KDFXRisyUDhPezxCJDk6Tisz');
        request1.setMethod('GET');
        request1.setTimeout(120000);
        response1 = http1.send(request1);  
        system.debug(response1.getBody());
        Map<String,Object> result = new Map<String,Object>();
        result = (Map<String,Object>)JSON.deserializeUntyped(response1.getBody());
        List<object> schoolList =(List<object>)result.get('data');
        if(String.valueOf(result.get('result'))=='failled'){
            for(Intended_School__c is : iSchools){
                schoolWrap w = new schoolWrap();
                if(is.UUID_School__c != '' && is.UUID_School__c!=null){
                    w.school = is.UUID_School__c;
                }else{
                    w.school = is.SchoolNameBak__c;
                }
                system.debug(is.UUID_Major__c);
                w.major = majorMap.get(is.UUID_Major__c);
                system.debug(w.major);
                w.faculty = facultyMap.get(is.UUID_Faculty__c);
                w.degree = degreeMap.get(is.UUID_Degree__c);
                w.sid = is.Id;
                iSchoolWraps.add(w);
            }
            return;
        }
        for(Intended_School__c is : iSchools){
            schoolWrap w = new schoolWrap();
            if(is.UUID_School__c != '' && is.UUID_School__c!=null){
                w.school = is.UUID_School__c;
            }else{
                w.school = is.SchoolNameBak__c;
            }
            system.debug(is.UUID_Major__c);
            w.major = majorMap.get(is.UUID_Major__c);
            system.debug(w.major);
            w.faculty = facultyMap.get(is.UUID_Faculty__c);
            w.degree = degreeMap.get(is.UUID_Degree__c);
            w.sid = is.Id;
            for(object obj : schoolList){
                Map<String,Object> schoolMap = (Map<String,Object>)obj;
                if(is.UUID_School__c== String.valueOf(schoolMap.get('uuid'))){
                    w.school = String.valueOf(schoolMap.get('english_name'))+' '+String.valueOf(schoolMap.get('chinese_name'));
                    w.url = String.valueOf(schoolMap.get('url'));
                }
            }
        	iSchoolWraps.add(w);
        }



    }

    public void deleteItem(){
        String sid = ApexPages.CurrentPage().getParameters().get('itemId');
    	Intended_School__c s = new Intended_School__c();
        s.Id = sid;
        try{
    		delete s;
    		system.debug('aaa');
    		Integer i = 0;
    		for(schoolWrap sw : iSchoolWraps){
    			if(sw.sid == sid){
    				system.debug(i);
    				iSchoolWraps.remove(i);
    				break;
    			}
    			i++;
    		}
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'aaa'));
    		return;
    	}catch(Exception e){
    		system.debug(e.getMessage());
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
    		return;
    	}
    	
    }


    public Class schoolWrap{
    	public String school{get;set;}
    	public String degree{get;set;}
    	public String faculty{get;set;}
    	public String major{get;set;}
    	public String sid{get;set;}
        public String url{get;set;}
    }
}