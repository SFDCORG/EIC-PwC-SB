/**************************************************************************************************
 * Name: OpportunityApplyLostExtension
 * Object: Opportunity
 * Purpose: transfer to apply lost page with some logic
 * Author: Ray Cen ()
 * Create Date: 2016-05-10
 * Modified History: 
 * 2016-05-10 Vicia Wang    Writes comments in this format and fetch it from the JS button
***************************************************************************************************/
public with sharing class OpportunityApplyLostExtension {
	public static String INVALID_USER_FOR_APPLY_LOST = '非商机跟进人，无申请流失权限';
	public static String INVALID_OPPORTUNITY_STAGE = '此状态无法申请流失，如有需要请联系管理员';
	public static String EAST_CHINA_NORTH_CHINA = '华东华北';
	public static String EAST_CHINA_NORTH_CHINA_MANAGER_EMAIL = 'keirakou@eiceducation.com.cn';
	public static String OTHER_REGION_MANAGER_EMAIL = 'leeli@eiceducation.com.cn';
	public static String APPLY_LOST_NAME_DEFAULT_VALUE = '日志名在保存后将会自动生成';

	public Set<String> validStageSet = new Set<String> {
		'顾问跟进', '确认有效', 
		'邀约', '到访', '订金',
		'低星资源池', '待分配'};

	public Set<String> validUserRoleSet = new Set<String> {
		'销售', '运营', 
		'客服', '呼叫'};

    public Set<String> validUserProfileSet = new Set<String> {
    	'销售', '校长'};

	Opportunity opp = new Opportunity();
	User currentUser = new User();
	String approverEmail = '';
    Boolean isReadyApplyLost = FALSE;

    public OpportunityApplyLostExtension(ApexPages.StandardController con) {
        
        opp = [SELECT Name, OwnerId, 
                      StageName, IsXueYou__c, 
                      Xueyou_Territory__c
        	   FROM Opportunity
        	   WHERE Id = : con.getId()];

        currentUser = [SELECT UserRole.Name, Profile.Name, 
        					  ProfileId
        			   FROM User
        			   WHERE Id = : UserInfo.getUserId()];	   	

	    if (validateCurrentUser()) {
	    	if (validateOpportunityStage()) {
                isReadyApplyLost = TRUE;
    			// Validates study abroad opportunity
	    		if (opp.IsXueYou__c) {
	    			if (opp.Xueyou_Territory__c == EAST_CHINA_NORTH_CHINA) {
	    				approverEmail = EAST_CHINA_NORTH_CHINA_MANAGER_EMAIL;
	    			
	    			} else {
	    				approverEmail = OTHER_REGION_MANAGER_EMAIL;
	    			}	    			
	    		}
	    	
	    	} else {
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
	    			                                       INVALID_OPPORTUNITY_STAGE));
	    		return;
	    	}
	    
	    } else {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
	    											   INVALID_USER_FOR_APPLY_LOST));
	    	return;
	    }
    }

    // Validates the opportunity stage
    Boolean validateOpportunityStage() {

    	if (validStageSet.contains(opp.StageName)) {
    		return TRUE;
    	
    	} else {
    		return FALSE;
    	}
    }

    // Validate the current user's role and profile
    Boolean validateCurrentUser() {
    	
    	Boolean isValid = FALSE;

    	if ((opp.OwnerId == currentUser.Id && (validateCurrentUserRole() || validateCurrentUserProfile())) ||
    		validateAdminProfile()) {
    		isValid = TRUE;
    	}

    	return isValid;
    }

    // Validates current user role
    Boolean validateCurrentUserRole() {

    	Boolean isValid = FALSE;

        if (String.isBlank(currentUser.UserRoleId)) {
            return isValid;
        }

    	for (String keyword : validUserRoleSet) {
    		if (currentUser.UserRole.Name.contains(keyword)) {
    			isValid = TRUE;
    			break;
    		}
    	}

    	return isValid;
    }

    // Validates current user profile name
    Boolean validateCurrentUserProfile() {

    	Boolean isValid = FALSE;

    	for (String keyword : validUserProfileSet) {
    		if (currentUser.Profile.Name.contains(keyword)) {
    			isValid = TRUE;
    			break;
    		}
    	}

    	return isValid;
    }

    // Validates current user profile is an admin profile
    Boolean validateAdminProfile() {
    	return ProfileRelated.adminProfileSet().contains(currentUser.ProfileId);
    }

    // Goes to apply lost page
    public PageReference applyLostPage() {

        if (isReadyApplyLost) {
            if (opp.IsXueYou__c) {

                String studyAbroadRTId = Utils.getRecordTypeId('Approval_Log__c', 'Xueyou Opportunity Status');  
                PageReference studyAbroadPage = new PageReference(
                    '/a0D/e?RecordType=' + studyAbroadRTId +
                    '&CF00N28000005sVHt=' + opp.Name + '&CF00N28000005sVHt_lkid=' + opp.Id + 
                    '&Name=' + APPLY_LOST_NAME_DEFAULT_VALUE + 
                    '&00N280000097LEF=' + approverEmail);

                return studyAbroadPage;
            
            } else {
                
                String nonStudyAbroadRTId = Utils.getRecordTypeId('Approval_Log__c', 'Opportunity Status');         
                PageReference nonStudyAbroadPage = new PageReference(
                    '/a0D/e?RecordType=' + nonStudyAbroadRTId +
                    '&CF00N28000005sVHt=' + opp.Name + '&CF00N28000005sVHt_lkid=' + opp.Id + 
                    '&Name=' + APPLY_LOST_NAME_DEFAULT_VALUE);
                
                return nonStudyAbroadPage;
            }  
        
        } else {
            return NULL;
        }    	    	
    }
}