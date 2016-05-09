/************************************************
Collect Deposit Service
@Test url: https://{instance_url}.Salesforce.com/services/apexrest/CollectDepositRestful

{
    "deposit": {
        "CRM_Student_ID":"",        // CRM 系统学员ID
        "CRM_Opportunity_ID":"",    // CRM 系统商机ID
        "BS_Student_Code":"",       // 业务系统学员编码
        "Earnest_Money_Status":0,   // 定金状态，0【无定金】， 1【有定金】, 2【定金已使用】，3【定金已退】
        "Earnest_Money_List":[      //定金列表
            {
            "Code":"0001",      //编码，编码长度20 位
            "Money":200,        //金额（单位为分，100 表示1 元）
            "Money_Quit":0,     //退掉的金额（单位为分，100 表示1 元）
            "Money_Use":200,    //使用的金额，定转费（单位为分，100 表示1 元）
            "Money_Lave":0      //剩余的金额（单位为分，100 表示1 元）
            },
            {
            "Code":"0002",      //编码，编码长度20 位
            "Money":300,        //金额（单位为分，100 表示1 元）
            "Money_Quit":100,   //退掉的金额（单位为分，100 表示1 元）
            "Money_Use":200,    //使用的金额，定转费（单位为分，100 表示1 元）
            "Money_Lave":0      //剩余的金额（单位为分，100 表示1 元）
            }
        ]
    }
}

************************************************/
@RestResource(urlMapping = '/CollectDepositRestful')
global class CollectDepositRestful {

    @HttpPost
    global static String collectDeposic (CollectDepositService.DepositWrapper deposit) {

        try{

            CollectDepositService.updateDeposit(deposit);
        }catch(Exception e) {

            String message = 'Cause: ' + e.getCause();
            message += 'Stack Trace: ' + e.getStackTraceString();
            message += 'Message: ' + e.getMessage();
            return JSON.serialize(message);
        }

        return JSON.serialize('订金信息同步成功!');
    }
}