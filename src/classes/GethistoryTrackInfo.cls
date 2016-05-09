public  class GethistoryTrackInfo {

    public static List<AccountHistory> getAccounthisotryInfo(Datetime catchDatetime, ID accountID) {

        return   [SELECT Id, AccountId, Field, 
                         CreatedById, CreatedBy.Name,        
                         IsDeleted, CreatedDate,
                         NewValue, OldValue
                         FROM AccountHistory where accountID=:accountID 
                         order by CreatedDate desc ];
                        
    }
}