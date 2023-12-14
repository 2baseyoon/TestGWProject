package egovframework.core.properties.dto;

import egovframework.baseframework.data.CoviMap;

public class StandardSettingListRequest {

	private String standardType;
	
	private String isSaaS;
	
	private String dbType;
	
	private String wasType;
	
	private String type;
	
	private String setKey;
	
	private String name;

	public CoviMap toCoviMap() {
		return new CoviMap() {{
			this.put("standardType", standardType);
			this.put("isSaaS", isSaaS);
			this.put("dbType", dbType);
			this.put("wasType", wasType);
			this.put("type", type);
			this.put("setKey", setKey);
			this.put("name", name);
		}};
	}
	
	public String getStandardType() {
		return standardType;
	}

	public void setStandardType(String standardType) {
		this.standardType = standardType;
	}

	public String getIsSaaS() {
		return isSaaS;
	}

	public void setIsSaaS(String isSaaS) {
		this.isSaaS = isSaaS;
	}

	public String getDbType() {
		return dbType;
	}

	public void setDbType(String dbType) {
		this.dbType = dbType;
	}

	public String getWasType() {
		return wasType;
	}

	public void setWasType(String wasType) {
		this.wasType = wasType;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getSetKey() {
		return setKey;
	}

	public void setSetKey(String setKey) {
		this.setKey = setKey;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
