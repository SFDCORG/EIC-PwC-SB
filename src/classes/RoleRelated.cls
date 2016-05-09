public class RoleRelated {

    public static Set<ID> LocalCSManagerRole()
    {
    	Set<ID> profileIDSet = new Set<ID>();
    	profileIDSet.add('00E28000000NH71EAG'); // #留学上海分公司客服部主管
    	Return profileIDSet;
    }


    public static Set<ID> HDTMKManagerRole()
    {
    	Set<ID> profileIDSet = new Set<ID>();
    	profileIDSet.add('00E28000000NH7IEAW'); // #集团呼叫中心TMK主管
    	Return profileIDSet;
    }

    public static set<ID> XueYouRole()
    {
        Set<ID> profileIDSet = new Set<ID>();

        for(UserRole uRole:[select id from UserRole where name like '%学游%'])
        {
            profileIDSet.add(uRole.id);
        }

        Return profileIDSet;
    }
  
}