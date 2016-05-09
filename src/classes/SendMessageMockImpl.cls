@isTest
global class SendMessageMockImpl implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');
        res.setBody('{"code":0,"msg":"OK","result":{"count":1,"fee":1,"sid":4054749536}}');
        res.setStatusCode(200);

        return res;
    }
}