/**************************************************************************************************
 * Name: miniPhone_opp_cls
 * Object: Scheduling_Table_Order__c
 * Purpose: Show a mini phone on the Opporutnity page for showing the main contact 
 * Author: Ray Cen (ray.cen@cn.pwc.com)
 * Create Date: 2015-12-14
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments AND optimizes the code
 **************************************************************************************************/

public with sharing class miniPhone_opp_cls {

    public  Id currentReocrdID              {get; set;}
    public List<ContactWrapper> contactList {get; set;}
    private String accountId;
    private Boolean showSwitch;



    public miniPhone_opp_cls(ApexPages.StandardController controller) {

        currentReocrdID= ApexPages.CurrentPage().getparameters().get('id');
        contactList= new List<ContactWrapper>();
        accountId=[select AccountID from Opportunity where id =: currentReocrdID][0].accountId;

        Set<ID> assIDs= new Set<ID>();

        List<Appoitment__c> apps=[select id, Assign_To__c from Appoitment__c where Opportunity__c =:currentReocrdID];

        List<Opportunity> opps=[select id, IsXueYou__c from Opportunity where id=:currentReocrdID];

        for(Appoitment__c app:apps)
        {
            assIDs.add(app.Assign_To__c);
        }
        showSwitch=false;

        String rolename=[select name from UserRole where id=:userinfo.getUserRoleId()][0].name;
        Boolean xueyouPermission=opps[0].IsXueYou__c && rolename.contains('学游');

        if(checkCurrentUserPermission(generateAccessiableUserGroup())||assIDs.contains(UserInfo.getUserId())||xueyouPermission)
          GenerateDisplayList();
    }

    public PageReference showContactNumber()
    {
        if(showSwitch==false)
        {
            getCompletedContactNumber();
            trackContactNumberViewrHistory();
            showSwitch=true;
        }
        return null;
    }



    private void  GenerateDisplayList()
    {

       List<Contact_EIC__c> contats= [select ID,Encryped_Phone__c,UniqueContact__c,Contact_Type__c ,isPrimary__c,ContactNumber__c
                                      from Contact_EIC__c
                                      where Account__c=:accountId
                                      And  Contact_Type__c in ('座机','手机','mig_type')];

       ContactDisplay__c encryptionSwitch=[select DisplayPhoneNumber__c from ContactDisplay__c limit 1 ];

       for(Contact_EIC__c cont:contats)
       {

            ContactWrapper conw= new ContactWrapper();
            conw.type=cont.Contact_Type__c;
            showSwitch=encryptionSwitch.DisplayPhoneNumber__c;
            conw.displayNumber=encryptionSwitch.DisplayPhoneNumber__c==true?cont.UniqueContact__c:cont.Encryped_Phone__c;
            conw.completeNumber=cont.ContactNumber__c;
            conw.phoneNumberAttribution = '';
            conw.isprimary=cont.isPrimary__c==true?true:false;
            contactList.add(conw);
       }
    }


    private Boolean checkCurrentUserPermission(Set<ID> oppGroupIDs)
    {
        return oppGroupIDs.contains(UserInfo.getUserId());
    }

     private Set<ID> generateAccessiableUserGroup()
    {

        Set<ID> oppGroupIDs= OppOwnerGroupGenerate.getOpportuniyOwnerGroup(accountId);
        Set<ID> adminGroupIDs= OppOwnerGroupGenerate.getAdminGroup();
        oppGroupIDs.addall(adminGroupIDs);

        if(OpportuinityRelatedController.checkEditPermissoin(currentReocrdID))
        {
            oppGroupIDs.add(UserInfo.getUserID());
        }

        return oppGroupIDs;
    }


    public class ContactWrapper
    {

       public  String  type           {get;set;}
       public  String  displayNumber  {get;set;}
       private String  completeNumber {get;set;}
       public  String  phoneNumberAttribution {get;set;}
       public  Boolean isprimary      {get;set;}

    }

     private void trackContactNumberViewrHistory()
    {

      HistoryTrackObjectRelatedController.createHisotryRecords(system.now(),UserInfo.getUserId(),accountId);
    }



     private void getCompletedContactNumber()
    {
        Map<String, String> phoneNumberAttributionMap = getPhoneNumberAttribution();
        for(ContactWrapper conw: contactList)
        {

           conw.displayNumber=conw.completeNumber;
           conw.phoneNumberAttribution = phoneNumberAttributionMap.get(conw.completeNumber);

        }

    }

    // get phone number attribution for each phone number
    private Map<String, String> getPhoneNumberAttribution(){
        Map<String, String> phoneNumberAttributionMap = new Map<String, String>();
        try{
            for(ContactWrapper conw : contactList){
                if(String.isNotBlank(conw.completeNumber) && (conw.type == '手机'||conw.type == 'mig_type')){
                    Http h = new Http();

                    HttpRequest req = new HttpRequest();
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');
                    req.setHeader('Accept', 'application/json;charset=utf-8');
                    req.setEndpoint('http://tcc.taobao.com/cc/json/mobile_tel_segment.htm?tel=' + conw.completeNumber.replace(' [E]', ''));

                    req.setTimeout(120000);
                    req.setMethod('POST');

                    HttpResponse res = h.send(req);
                    System.debug(LoggingLevel.INFO, '*** res: ' + res.getBody());


                    if(res.getStatusCode() == 200){
                        String resString = res.getBody();
                        System.debug(LoggingLevel.INFO, '*** resString: ' + resString);

                        String carrier = resString.substringAfter('carrier:\'');
                        if(String.isNotBlank(carrier)){
                            carrier = carrier.substring(0, carrier.indexOf('\''));
                            System.debug(LoggingLevel.INFO, '*** carrier: ' + carrier);
                        }else{
                            carrier = '未知';
                        }

                        phoneNumberAttributionMap.put(conw.completeNumber, '(' + carrier + ')');
                    }else{
                        phoneNumberAttributionMap.put(conw.completeNumber, '(未知)');
                    }
                }
            }
        }catch(Exception ex){

        }
        return phoneNumberAttributionMap;
    }
}


/*__GetZoneResult_ = {
    mts:'1585078',
    province:'江苏',
    catName:'中国移动',
    telString:'15850781443',
    areaVid:'30511',
    ispVid:'3236139',
    carrier:'江苏移动'
}*/