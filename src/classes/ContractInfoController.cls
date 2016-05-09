/**************************************************************************************************
 * Name: ContractInfoController
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-08
 * Modified History:
 * 2016-05-08    Allen    Format the code
***************************************************************************************************/
public class ContractInfoController {

    private ApexPages.StandardController standardController;

    public ContractInfoController (ApexPages.StandardController standardController) {

        this.standardController = standardController;
    }

    //POST Method
    public List<ServiceWrapper.ContractDetail> getContractDetailList () {

        String requestUrl = '';
        Contract__c  curContract = [SELECT External_Contract_Id__c
                                    FROM Contract__c
                                    WHERE Id =: standardController.getId()];

        User curUser = [SELECT Sage_UserName__c
                        FROM User
                        WHERE Id = :UserInfo.getUserId()];

        Contract_System__c contractDetails = Contract_System__c.getValues('Prepsmith Sage Contract Details');
        requestUrl = contractDetails.Endpoint__c +
                     'contid=' +
                     curContract.External_Contract_Id__c +
                     '&uid=' +
                     curUser.Sage_UserName__c;

        HttpRequest req = new HttpRequest ();
        req.setHeader('Content-type', 'application/json; charset=UTF-8');
        req.setEndpoint(requestUrl);
        req.setMethod('GET');
        req.setTimeout(120000);

        try {

            Http h = new Http ();
            HttpResponse response = h.send(req);
            String res = response.getBody();
            System.debug(LoggingLevel.INFO, '*** res: ' + res);
            ServiceWrapper cons = ServiceWrapper.parse(res);

            return cons.jsondata;

            if (response.getStatusCode() == 200) {

                System.debug('LoggingLevel.INFO, *** response.getBody(): ' + response.getBody());
                return null;
            } else {

                return null;
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        return null;
    }
}