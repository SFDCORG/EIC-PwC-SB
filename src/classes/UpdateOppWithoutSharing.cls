/**************************************************************************************************
 * Name: UpdateOppWithoutSharing
 * Object: Opportunity
 * Purpose: Update opportunity owner
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18		Vicia Wang    Create this class
 **************************************************************************************************/
public without sharing class UpdateOppWithoutSharing {
    public static void doUpdateOwner(Id oppId, Id userId) {
		List<Opportunity> ls = [
			SELECT Id, OwnerId FROM Opportunity 
			WHERE Id = :oppId
			AND StageName IN ('低星资源池','流失')
		];

		if (ls.size() == 0) {
			return;
		}

		Opportunity l = ls[0];
		try {
			if (l.OwnerId != userId) {
				if (UserInfo.getProfileId() == '00e28000000IwGaAAK'
						|| UserInfo.getProfileId() == '00e28000000IomIAAS') {
					l.OwnerId = userId;
					update l;
				}
			}	
		} catch(Exception e) {
			System.debug('update Opportunity failed'+e.getMessage());
		}
	}
}