@isTest
global class ConfirmOrderCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
       
        System.assertEquals('callout:Confirm_Order', req.getEndpoint(), 'Endpoint called not the expected.');
        System.assertEquals('POST', req.getMethod(), 'Method should have been POST.');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"status": "success"}');
        
        return res;
    }
    
}