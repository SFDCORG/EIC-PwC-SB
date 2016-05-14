/**************************************************************************************************
 * Name: RecordTypeLookup
 * Object: RecordType
 * Purpose: RecordType Utilities
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-11
 * Modify History:
 * 2016-05-11        Create this class
 * 2016-05-10    Allen    Format the code
 **************************************************************************************************/
public class RecordTypeLookup {

    public String fetchSql;
    public RecordTypeLookup(String soqlString) {
        fetchSql = soqlString;
    }

    public List<RecordType> objList {
        get {
            if(objList == null){
                objList = Database.query(fetchSql);
            }
            return objList;
        }
        set;
    }

    public Map<String, RecordType> objMap {
        get {
            if(objMap == null){
                objMap = new Map<String, RecordType>();
                for(RecordType obj: objList){
                    objMap.put(obj.DeveloperName, obj);
                }
            }
            return objMap;
        }
        set;
    }
}