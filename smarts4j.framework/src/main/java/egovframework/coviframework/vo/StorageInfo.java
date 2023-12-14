package egovframework.coviframework.vo;

public class StorageInfo {
	private int storageID;
	private int domainID;
	private String serviceType;
	private long lastSeq;
	private String filePath;
	private String inlinePath;
	private char isActive;
	private String description;
	private String reserved1;
	private String reserved2;
	private String reserved3;
	private String reserved4;
	private String reserved5;
		
	public StorageInfo(int storageID, int domainID, String serviceType, long lastSeq, String filePath,
			String inlinePath, char isActive, String description, String reserved1, String reserved2, String reserved3,
			String reserved4, String reserved5) {
		this.storageID = storageID;
		this.domainID = domainID;
		this.serviceType = serviceType;
		this.lastSeq = lastSeq;
		this.filePath = filePath;
		this.inlinePath = inlinePath;
		this.isActive = isActive;
		this.description = description;
		this.reserved1 = reserved1;
		this.reserved2 = reserved2;
		this.reserved3 = reserved3;
		this.reserved4 = reserved4;
		this.reserved5 = reserved5;
	}
	
	public int getStorageID() {
		return storageID;
	}
	public int getDomainID() {
		return domainID;
	}
	public String getServiceType() {
		return serviceType;
	}
	public long getLastSeq() {
		return lastSeq;
	}
	public String getFilePath() {
		return filePath;
	}
	public String getInlinePath() {
		return inlinePath;
	}
	public char getIsActive() {
		return isActive;
	}
	public String getDescription() {
		return description;
	}
	public String getReserved1() {
		return reserved1;
	}
	public String getReserved2() {
		return reserved2;
	}
	public String getReserved3() {
		return reserved3;
	}
	public String getReserved4() {
		return reserved4;
	}
	public String getReserved5() {
		return reserved5;
	}
}
