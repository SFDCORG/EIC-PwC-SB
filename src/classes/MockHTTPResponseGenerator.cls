@isTest
global class MockHTTPResponseGenerator implements HttpCalloutMock {
	//global static String dataType = 'Criteria';

	global HttpResponse respond(HTTPRequest req){
    Url baseUrl = new URL(req.getEndpoint());
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    if(baseUrl.getPath()=='/SingleCall/Success'){
      res.setBody('{"result":"ok"}');
    }else if(baseUrl.getPath()=='/SingleCall/Error'){
      res.setBody('{"result":"failed"}');
    }else if(baseUrl.getPath()=='/SingleCall/Exception'){
      res.setBody('{result:failed}');
    }else if(baseUrl.getPath()=='/Criteria'){
      res.setBody('{"result": "success","data": {"faculty": [{"systemmajor": [{"system_major_id": 1,"english_name": "Finance","chinese_name": "金融","system_major_english_profile": null,"system_major_chinese_profile": null,"uuid": "44418cc7-ef7b-4cf0-b3ec-baadffdf338f","createdAt": null,"updatedAt": null,"id": 1,"faculty_systemmajor": 1,"systemmajor_faculty": 1}],"faculty_id": 1,"english_name": "Business","chinese_name": "商科","faculty_profile_english": null,"faculty_profile_chinese": null,"uuid": "824be818-09a0-4609-bfd8-eea757ba61cb","createdAt": null,"updatedAt": null}],"degree_type": [{"degree_type_id": 13,"english_name": "College","chinese_name": "大专","duration": null,"degree_type_english_profile": null,"iso1": null,"iso2": null,"iso3": null,"degree_type_chinese_profile": null,"uuid": "dc5345e0-7020-4c39-995a-21fa76fcf7fc","createdAt": null,"updatedAt": null}],"country": [{"uuid": "9533906d-a776-4fb6-89b0-ddb4e0062726","english_name": "China","chinese_name": "中国","iso2": "CN","iso3": "CHN"}]}}');
    }else if(baseUrl.getPath()=='/GetSchools/Success'){
      res.setBody('{"result":"success","data":[{"uuid":"1-1-1","degree":"dc5345e0-7020-4c39-995a-21fa76fcf7fc","faculty":"824be818-09a0-4609-bfd8-eea757ba61cb","major":"44418cc7-ef7b-4cf0-b3ec-baadffdf338f","url":"www.baidu.com"},{"uuid":"1-1-1","degree":"dc5345e0-7020-4c39-995a-21fa76fcf7fc","faculty":"824be818-09a0-4609-bfd8-eea757ba61cb","major":"44418cc7-ef7b-4cf0-b3ec-baadffdf338f","url":"www.baidu.com"}]}');
    }else if(baseUrl.getPath()=='/GetSchools/Failed'){
      res.setBody('{"result":"failled"}');
    }else if(baseUrl.getPath()=='/SearchSchool'){
      res.setBody('');
    }
    res.setStatusCode(200);
    return res;
	}
    
}