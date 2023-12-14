package egovframework.core.properties.dto;

import java.util.Objects;

import egovframework.baseframework.data.CoviMap;

public class StandardSettingSaveRequest {

	private String standardType;
	
	private String type;
	
	private String isSaaS;
	
	private String dbType;
	
	private String wasType;
	
	private String setKey;
	
	private String setValue;
	
	private String description;
	
	private String name;
	
	private String id;
	
	public boolean isId() {
		if (Objects.isNull(this.id) || id.isEmpty()) {
			return false;
		}
		return true;
	}
	
	public CoviMap toCoviMap() {
		return new CoviMap() {{
			this.put("standardType", standardType);
			this.put("type", type);
			this.put("isSaaS", isSaaS);
			this.put("dbType", dbType);
			this.put("wasType", wasType);
			this.put("setKey", setKey);
			this.put("setValue", setValue);
			this.put("description", description);
			this.put("name", name);
			this.put("id", id);
		}};
	}

	public String getStandardType() {
		return standardType;
	}

	public void setStandardType(String standardType) {
		this.standardType = standardType;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
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

	public String getSetKey() {
		return setKey;
	}

	public void setSetKey(String setKey) {
		this.setKey = setKey;
	}

	public String getSetValue() {
		return setValue;
	}

	public void setSetValue(String setValue) {
		this.setValue = setValue;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
}
