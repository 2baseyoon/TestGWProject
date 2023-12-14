package egovframework.coviframework.vo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class ACLMapper implements Serializable{
	
	// 직렬화 대상 객체
    private static final long serialVersionUID = 1L;
    
    private String settingKey;
    
    private String synchronizeKey;
    
	// 권한 HashMap
	private Map<String, Set<String>> aclMap;
	
	// 권한별 Set
	private Set<String> S;
	private Set<String> C;
	private Set<String> D;
	private Set<String> M;
	private Set<String> E;
	private Set<String> V;
	private Set<String> R;
	
	public ACLMapper(String settingKey) {
		this.settingKey = settingKey;
		
		aclMap = new HashMap<String, Set<String>>();
		
		S = new HashSet<String>();
		C = new HashSet<String>();
		D = new HashSet<String>();
		M = new HashSet<String>();
		E = new HashSet<String>();
		V = new HashSet<String>();
		R = new HashSet<String>();
		
		aclMap.put("S", S);
		aclMap.put("C", C);
		aclMap.put("D", D);
		aclMap.put("M", M);
		aclMap.put("E", E);
		aclMap.put("V", V);
		aclMap.put("R", R);
	}
	
	public String getSettingKey() {
		return settingKey;
	}

	public void setSettingKey(String settingKey) {
		this.settingKey = settingKey;
	}

	public Set<String> getACLInfo(String aclCol) {
		return aclMap.get(aclCol);
	}
	
	public String getSynchronizeKey() {
		return synchronizeKey;
	}

	public void setSynchronizeKey(String synchronizeKey) {
		this.synchronizeKey = synchronizeKey;
	}
	
	public Map<String, Set<String>> getACLMap() {
		return aclMap;
	}
	
	public void setACLInfo(String aclCol, String objectID) {
		Set<String> aclSet = aclMap.get(aclCol);
		aclSet.add(objectID);
	}
	
	public void setACLListInfo(String aclList, String objectID) {
		Set<String> aclSet = null;
		for(int i=0; i<aclList.length(); i++) {
			String colName = String.valueOf(aclList.charAt(i));
			if(!"_".equals(colName) && aclMap.containsKey(colName)) {
				aclSet = aclMap.get(colName);
				aclSet.add(objectID);
			}
		}
	}
	
	public void clearACLInfo(String objectID) {
		S.remove(objectID);
		C.remove(objectID);
		D.remove(objectID);
		M.remove(objectID);
		E.remove(objectID);
		V.remove(objectID);
		R.remove(objectID);
	}
	
	public String getACLListInfo(String objectID) {
		char[] aclListInfo = new char[7];
		aclListInfo[0] = S.contains(objectID) ? 'S' : '_';
		aclListInfo[1] = C.contains(objectID) ? 'C' : '_';
		aclListInfo[2] = D.contains(objectID) ? 'D' : '_';
		aclListInfo[3] = M.contains(objectID) ? 'M' : '_';
		aclListInfo[4] = E.contains(objectID) ? 'E' : '_';
		aclListInfo[5] = V.contains(objectID) ? 'V' : '_';
		aclListInfo[6] = R.contains(objectID) ? 'R' : '_';
		
		return String.valueOf(aclListInfo); 
	}
}
