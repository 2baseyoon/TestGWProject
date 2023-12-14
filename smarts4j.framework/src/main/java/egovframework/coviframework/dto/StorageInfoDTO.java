package egovframework.coviframework.dto;

import egovframework.coviframework.vo.StorageInfo;

public class StorageInfoDTO {
	private int storageID;
	private int domainID;
	private String serviceType;
	private long lastSeq;
	private String filePath;
	private String inlinePath;
	private char isActive;
	private String description;

	public int getStorageID() {
		return storageID;
	}

	public void setStorageID(int storageID) {
		this.storageID = storageID;
	}

	public int getDomainID() {
		return domainID;
	}

	public void setDomainID(int domainID) {
		this.domainID = domainID;
	}

	public String getServiceType() {
		return serviceType;
	}

	public void setServiceType(String serviceType) {
		this.serviceType = serviceType;
	}

	public long getLastSeq() {
		return lastSeq;
	}

	public void setLastSeq(long lastSeq) {
		this.lastSeq = lastSeq;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public String getInlinePath() {
		return inlinePath;
	}

	public void setInlinePath(String inlinePath) {
		this.inlinePath = inlinePath;
	}

	public char getIsActive() {
		return isActive;
	}

	public void setIsActive(char isActive) {
		this.isActive = isActive;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public StorageInfo toEntity() {
		return new StorageInfo(storageID, domainID, serviceType, lastSeq, 
				filePath, inlinePath, isActive, description,
				description, serviceType, inlinePath, filePath, description);
	}
}
