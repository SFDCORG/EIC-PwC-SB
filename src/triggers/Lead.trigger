trigger Lead on Lead(before insert, before update, after insert, after update, before delete) {
	if (trigger.isDelete && trigger.isBefore) {
		List<Lead_Item__c> leadItems = new List<Lead_Item__c>();
		Set<Id> leadIds = new Set<Id>();

		for (Lead lead :trigger.old) {
			leadIds.add(lead.Id);
		}

		leadItems = [SELECT Id FROM Lead_Item__c WHERE Lead__c IN :leadIds];
		delete leadItems;

	} else {
		/*if(Trigger.isBefore && Trigger.isInsert){
			if(Trigger.new.size()>1){
				//批量导入,记录批量导入移交时间
				for(Lead l : Trigger.new){
					l.TransferTime1__c = System.now();
				}
			}
		}*/
		if(Trigger.isBefore && Trigger.isUpdate){
			//记录手动移交时间
			for(Lead l : Trigger.new){
				Lead o = Trigger.oldMap.get(l.Id);
				if(l.OwnerId != o.OwnerId){
					l.ManualTransferTime__c = System.now();
				}
			}
		}

		// For some scenarios, we need ignore the triggers.
		if (!Utils.runLeadTrigger || Special_User__c.getInstance().Ignore_Lead_Trigger__c) return;
		if (trigger.isBefore) {
			if(Trigger.isUpdate){
				List<Lead> news = new List<Lead>();
				List<Lead> olds = new List<Lead>();
				for(Lead l : (List<Lead>)Trigger.new){
					Lead old = Trigger.oldMap.get(l.Id);
					if(l.Is_Cooperative_Education__c != old.Is_Cooperative_Education__c || l.Cooperative_Education_Project__c != old.Cooperative_Education_Project__c || l.Is_Counselling__c != old.Is_Counselling__c || l.Is_TestPrep__c != old.Is_TestPrep__c || l.Is_NP__c != old.Is_NP__c || l.Is_Scholar_Tree__c != old.Is_Scholar_Tree__c || l.Area_Code__c != old.Area_Code__c || l.Phone != old.Phone || l.MobilePhone != old.MobilePhone || l.Campaign__c != old.Campaign__c || l.Is_Cooperative_Education__c != old.Is_Cooperative_Education__c || l.Counselling_Project__c != old.Counselling_Project__c || l.TestPrep_Project__c != old.TestPrep_Project__c || l.Intended_City__c != old.Intended_City__c){
						news.add(l);
						olds.add(old);
					}
				}
				if(news.size()>0 || olds.size()>0){
					SplitLeadUtils.processLead(news, olds, 'isBefore');
				}
			}else{

				SplitLeadUtils.processLead(trigger.new, trigger.old, 'isBefore');
			}
			//SplitLeadUtils.processLead(trigger.new, trigger.old, 'isBefore');


		}

		if (trigger.isAfter) {
			if(Trigger.isUpdate){
				List<Lead> news = new List<Lead>();
				List<Lead> olds = new List<Lead>();
				for(Lead l : (List<Lead>)Trigger.new){
					Lead old = Trigger.oldMap.get(l.Id);
					if(l.Is_Cooperative_Education__c != old.Is_Cooperative_Education__c || l.Cooperative_Education_Project__c != old.Cooperative_Education_Project__c || l.Is_Counselling__c != old.Is_Counselling__c || l.Is_TestPrep__c != old.Is_TestPrep__c || l.Is_NP__c != old.Is_NP__c || l.Is_Scholar_Tree__c != old.Is_Scholar_Tree__c || l.Area_Code__c != old.Area_Code__c || l.Phone != old.Phone || l.MobilePhone != old.MobilePhone || l.Campaign__c != old.Campaign__c || l.Is_Cooperative_Education__c != old.Is_Cooperative_Education__c || l.Counselling_Project__c != old.Counselling_Project__c || l.TestPrep_Project__c != old.TestPrep_Project__c || l.Intended_City__c != old.Intended_City__c){
						news.add(l);
						olds.add(old);
					}
				}
				if(news.size()>0 || olds.size()>0){
					SplitLeadUtils.processLead(news, olds, 'isAfter');
				}
			}else{
				SplitLeadUtils.processLead(trigger.new, trigger.old, 'isAfter');
			}
			//SplitLeadUtils.processLead(trigger.new, trigger.old, 'isAfter');
		}
		// When the projects are changed, post the changes to chatter feed.
        if (trigger.isAfter && trigger.isUpdate) {
            PostLeadChatterUtil.postChatter((Lead)trigger.old[0], (Lead)trigger.new[0]);
        }
	}
}