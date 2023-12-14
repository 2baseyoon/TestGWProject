package egovframework.coviframework.vo;

import org.springframework.web.multipart.MultipartFile;

public class FileVO {
	
	private MultipartFile file;
	private String storageID;
	private String serviceType;
	private String objectID;
	private String objectType;
	private String messageID;
	private String version;
	private String saveType;
	private String lastSeq;
	private String seq;
	private String filePath;
	private String fileName;
	private String savedName;
	private String extension;
	private String size;
	private String thumbWidth;
	private String thumbheight;
	private String description;
	private String register;
	
	public FileVO(){
		//do nothing
	}

	public MultipartFile getFile() {
		return file;
	}

	public void setFile(MultipartFile file) {
		this.file = file;
	}
	
	public String getStorageID() {
		return storageID;
	}

	public void setStorageID(String storageID) {
		this.storageID = storageID;
	}

	public String getServiceType() {
		return serviceType;
	}

	public void setServiceType(String serviceType) {
		this.serviceType = serviceType;
	}

	public String getObjectID() {
		return objectID;
	}

	public void setObjectID(String objectID) {
		this.objectID = objectID;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public String getMessageID() {
		return messageID;
	}

	public void setMessageID(String messageID) {
		this.messageID = messageID;
	}

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	public String getSaveType() {
		return saveType;
	}

	public void setSaveType(String saveType) {
		this.saveType = saveType;
	}

	public String getLastSeq() {
		return lastSeq;
	}

	public void setLastSeq(String lastSeq) {
		this.lastSeq = lastSeq;
	}

	public String getSeq() {
		return seq;
	}

	public void setSeq(String seq) {
		this.seq = seq;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getSavedName() {
		return savedName;
	}

	public void setSavedName(String savedName) {
		this.savedName = savedName;
	}

	public String getExtension() {
		return extension;
	}

	public void setExtension(String extension) {
		this.extension = extension;
	}

	public String getSize() {
		return size;
	}

	public void setSize(String size) {
		this.size = size;
	}

	public String getThumbWidth() {
		return thumbWidth;
	}

	public void setThumbWidth(String thumbWidth) {
		this.thumbWidth = thumbWidth;
	}

	public String getThumbheight() {
		return thumbheight;
	}

	public void setThumbheight(String thumbheight) {
		this.thumbheight = thumbheight;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getRegister() {
		return register;
	}

	public void setRegister(String register) {
		this.register = register;
	}


}
