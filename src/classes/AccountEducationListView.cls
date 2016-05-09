/**************************************************************************************************
 * Name: AccountEducationListView
 * Object: Lead
 * Purpose: Visualforce shows the current account's education history via the interface
 * Author: Joe Zhou (yuyu.zhou@cn.pwc.com)
 * Create Date: 2016-05-06
 * Modified History: 
 * 2016-05-06    Vicia Wang    Writes comments in this format
 * 2016-05-06    Allen         Format the code
***************************************************************************************************/
public with sharing class AccountEducationListView {

    private static String AUTHORIZATION_CODE = 'OUkxMStDNCs1OlVNP0s/Tl46MzhMREk4TlE1VEQ0KDFXRisyUDhPezxCJDk6Tisz';

	public Map<String, String> facultyMap { get; set; }
	public Map<String, String> majorMap { get; set; }
	public Map<String, String> degreeMap { get; set; }
	public Id acctId { get; set; }
	public List<SchoolWrap> SchoolWraps { get; set; }

    public AccountEducationListView (ApexPages.StandardController con) {
    	Id acctId = con.getId();
    	facultyMap = new Map<String, String> ();
    	majorMap = new Map<String, String> ();
    	degreeMap = new Map<String, String> ();

    	CallOutMethod__c cm = CallOutMethod__c.getValues('PrepSmithAPIStagingCriteria');
        String endpoint =  cm.EndPoint__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndPoint(endpoint);
        request.setHeader('Authorization', AUTHORIZATION_CODE);
        request.setMethod('GET');
        request.setTimeout(120000);
        response = http.send(request);
        System.debug('LoggingLevel.INFO, *** response.getBody(): ' + response.getBody());

        Map<String, Object> initdata = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> data = (Map<String, Object>) initdata.get('data');
        List<object> faculties = (List<object>) data.get('faculty');
        List<object> degrees = (List<object>) data.get('degree_type');
        for (Object o : faculties) {
        	Map<string, object> obj = (Map<String, object>) o;
        	facultyMap.put(String.valueOf(obj.get('uuid')), String.valueOf(obj.get('chinese_name')));
        	List<Object> ms = (List<object>) obj.get('systemmajor');
        	for (Object m : ms) {
        		Map<String, object> mobj = (Map<String, object>) m;
        		majorMap.put(String.valueOf(mobj.get('uuid')), String.valueOf(mobj.get('chinese_name')));
        	}
        }

        for (Object o : degrees) {
        	Map<string, object> obj = (Map<String, object>) o;
        	degreeMap.put(String.valueOf(obj.get('uuid')), String.valueOf(obj.get('chinese_name')));
        }
        System.debug('LoggingLevel.INFO, *** majorMap: ' + majorMap);

        List<Education__c> eduSchools = [SELECT Account__c, UUID_School__c,
                                                UUID_Major__c, UUID_Degree__c,
                                                UUID_Faculty__c, SchoolNameBak__c
                                         FROM Education__c
                                         WHERE Account__c = :acctId];

        SchoolWraps = new List<SchoolWrap> ();
        Set<String> uuids = new Set<String> ();
        for (Education__c is : eduSchools) {
            if (is.UUID_School__c != null && is.UUID_School__c != '') {
                uuids.add(is.UUID_School__c);
            }
        }

        String schoolParam = JSON.serialize(uuids);
        System.debug('LoggingLevel.INFO, *** schoolParam: ' + schoolParam);

        CallOutMethod__c cm1 = CallOutMethod__c.getValues('SchoolMultiUUID');
        String endpoint1 =  cm1.EndPoint__c;
        endpoint1 += '?uuids=' + EncodingUtil.urlEncode(schoolParam, 'UTF-8');
        Http http1 = new Http();
        HttpRequest request1 = new HttpRequest();
        HttpResponse response1 = new HttpResponse();
        request1.setEndPoint(endpoint1);
        request1.setHeader('Authorization', AUTHORIZATION_CODE);
        request1.setMethod('GET');
        request1.setTimeout(120000);
        response1 = http1.send(request1);
        system.debug(response1.getBody());
        Map<String, Object> result = new Map<String, Object> ();
        result = (Map<String, Object>) JSON.deserializeUntyped(response1.getBody());

        if (String.valueOf(result.get('result')) == 'failled') {
            for (Education__c is : eduSchools) {
                SchoolWrap w = new SchoolWrap ();
                if (is.UUID_School__c != null && is.UUID_School__c != '') {
                    w.school = is.UUID_School__c;

                } else {
                    w.school = is.SchoolNameBak__c;
                }
                w.major = majorMap.get(is.UUID_Major__c);
                w.faculty = facultyMap.get(is.UUID_Faculty__c);
                w.degree = degreeMap.get(is.UUID_Degree__c);
                w.sid = is.Id;
                SchoolWraps.add(w);
            }
            return;
        }

        List<object> schoolList =(List<object>) result.get('data');
        for (Education__c is : eduSchools) {
            SchoolWrap w = new SchoolWrap ();
            if (is.UUID_School__c != null && is.UUID_School__c != '') {
                w.school = is.UUID_School__c;
            } else {
                w.school = is.SchoolNameBak__c;
            }

            w.major = majorMap.get(is.UUID_Major__c);
            w.faculty = facultyMap.get(is.UUID_Faculty__c);
            w.degree = degreeMap.get(is.UUID_Degree__c);
            w.sid = is.Id;

            for (object obj : schoolList) {
                Map<String, Object> schoolMap = (Map<String, Object>) obj;
                if (is.UUID_School__c== String.valueOf(schoolMap.get('uuid'))) {
                    w.school = String.valueOf(schoolMap.get('english_name')) + ' ' +
                               String.valueOf(schoolMap.get('chinese_name'));
                    w.url = String.valueOf(schoolMap.get('url'));
                }
            }
        	SchoolWraps.add(w);
        }
    }

    // Deletes the education history
    public void deleteItem() {
    	String sid = ApexPages.CurrentPage().getParameters().get('itemId');
    	Education__c s = new Education__c ();
    	s.Id = sid;
    	try{
    		delete s;
    		Integer i = 0;
    		for (SchoolWrap sw : SchoolWraps) {
    			if (sw.sid == sid) {
    				SchoolWraps.remove(i);
    				break;
    			}
    			i++;
    		}
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'aaa'));
    		return;

        } catch (Exception e) {
            System.debug('LoggingLevel.ERROR, *** e.getMessage(): ' + e.getMessage());
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    		return;
    	}
    }

    public Class SchoolWrap{
    	public String school { get; set; }
    	public String degree { get; set; }
    	public String faculty { get; set; }
    	public String major { get; set; }
    	public String sid { get; set; }
        public String url { get; set; }
    }
}