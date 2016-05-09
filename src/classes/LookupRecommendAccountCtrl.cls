public without sharing class LookupRecommendAccountCtrl {

    public String searchText {get; set;}
    public String searchType {get; set;}    // AccountContact; AccountName
    public List<AccountWapper> accountList {get; set;}

    public LookupRecommendAccountCtrl() {

    }

    public void searchAccount(){
        if(String.isNotBlank(searchText)){
            if(searchType == 'AccountName'){
                accountList = new List<AccountWapper>();
                searchText = String.escapeSingleQuotes(searchText.replace('*', '%')) + '%';

                for(Account acc : [
                        SELECT  Name,
                                Phone,
                                (Select Id,StageName,Name,OwnerId,Owner.LastName From Opportunities Where StageName='签约') 
                        FROM    Account
                        WHERE   Name LIKE :searchText
                        ORDER BY Phone NULLS LAST LIMIT 100]){
                    if(acc.Opportunities!=null && acc.Opportunities.size()>0){
                        for(Opportunity opp : acc.Opportunities){
                            accountList.add(new AccountWapper(acc.Id, acc.Name, acc.Phone,opp.Name,opp.OwnerId,opp.Owner.LastName));
                        }
                    }
                    
                }
            }else if(searchType == 'AccountContact'){
                accountList = new List<AccountWapper>();
                Set<Id> ids = new Set<Id>();
                searchText = '%'+searchText+'%';
                for(Contact_EIC__c c : [
                        SELECT  Account__c,
                                Account__r.Name,
                                Account__r.Phone,
                                Encryped_Phone__c
                        FROM    Contact_EIC__c
                        WHERE   UniqueContact__c like :searchText
                        ORDER BY Account__r.Phone NULLS LAST LIMIT 100]){
                    ids.add(c.Account__r.Id);
                    //accountList.add(new AccountWapper(c.Account__c, c.Account__r.Name, c.Account__r.Phone));
                }
                List<Account> accts = [Select Id,Name,Phone,(Select Id,StageName,Name,OwnerId,Owner.LastName From Opportunities Where StageName='签约') From Account Where Id In :ids];
                for(Account acct : accts){
                    if(acct.Opportunities!=null && acct.Opportunities.size()>0){
                        for(Opportunity opp : acct.Opportunities){
                            accountList.add(new AccountWapper(acct.Id, acct.Name, acct.Phone,opp.Name,opp.OwnerId,opp.Owner.LastName));
                        }
                    }
                }
            }
        }
    }

    public class AccountWapper{
        public String accountId {get; set;}
        public String accountName {get; set;}
        public String encrypedPhone {get; set;}
        public String oppName{get;set;}
        public String ownerId{get;set;}
        public String ownerName{get;set;}

        public AccountWapper(String accountId, String accountName, String encrypedPhone, String oppName, String ownerId, String ownerName){
            this.accountId = accountId;
            this.accountName = accountName;
            this.encrypedPhone = encrypedPhone;
            this.oppName = oppName;
            this.ownerId = ownerId;
            this.ownerName = ownerName;
        }
    }

}