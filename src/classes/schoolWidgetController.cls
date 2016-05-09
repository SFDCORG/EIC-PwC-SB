global with sharing class schoolWidgetController {
	public String initdata{get;set;}

    public schoolWidgetController() {
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
        initdata = response.getBody();
        system.debug(initdata);
    }

    @RemoteAction
    global static String getSchool(String url) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndPoint(url);
        request.setHeader('Authorization', 'OUkxMStDNCs1OlVNP0s/Tl46MzhMREk4TlE1VEQ0KDFXRisyUDhPezxCJDk6Tisz');
        request.setMethod('GET');
        request.setTimeout(120000);
        response = http.send(request);  
        return EncodingUtil.urlEncode(response.getBody(), 'UTF-8');
    }
}