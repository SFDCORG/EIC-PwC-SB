/**************************************************************************************************
 * Name: OpportunityTMKChangeOwnerCtl
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public without sharing class OpportunityTMKChangeOwnerCtl {

    public String  oppId { get; set; }
    public Opportunity opp { get; set; }
    public String newOwnerID { get; set; }
    public String user { get; set; }
    public OpportunityTMKChangeOwnerCtl (ApexPages.StandardController sd) {

        oppId = sd.getId();
        opp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :oppId];
        user = Userinfo.getName();
    }

    public PageReference assignOpp () {

        try {
            opp.OwnerId = newOwnerID;
            update opp;
            PageReference ref = new PageReference('/' + opp.Id);
            return ref;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public PageReference cancel () {
        PageReference ref = new PageReference('/' + oppId);
        return ref;
    }
}