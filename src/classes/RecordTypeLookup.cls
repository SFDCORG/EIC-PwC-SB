public class RecordTypeLookup {
    public String fetchSql;
    public RecordTypeLookup(String soqlString){
        fetchSql = soqlString;
    }
    public List<RecordType> objList{
        get {
            if(objList == null){
                objList = Database.query(fetchSql);
            }
            return objList;
        }
        set;
    }
    public Map<String, RecordType> objMap{
        get{
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