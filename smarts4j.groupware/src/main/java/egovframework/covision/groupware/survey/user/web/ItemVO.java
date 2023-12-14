package egovframework.covision.groupware.survey.user.web;

import java.util.List;

public class ItemVO {
	private String itemID;
	private int itemNO;
	private String item;
	private int nextQuestionNO;
	private String itemDivOptions;
	private String fileIds;
	private String updateFileIds;
	private String deleteFileIds;
	
	public String getFileIds() {
		return fileIds;
	}
	public void setFileIds(String fileIds) {
		this.fileIds = fileIds;
	}
	public String getUpdateFileIds() {
		return updateFileIds;
	}
	public void setUpdateFileIds(String updateFileIds) {
		this.updateFileIds = updateFileIds;
	}
	public String getDeleteFileIds() {
		return deleteFileIds;
	}
	public void setDeleteFileIds(String deleteFileIds) {
		this.deleteFileIds = deleteFileIds;
	}
	public String getItemDivOptions() {
		return itemDivOptions;
	}
	public void setItemDivOptions(String itemDivOptions) {
		this.itemDivOptions = itemDivOptions;
	}
	public String getItemID() {
		return itemID;
	}
	public void setItemID(String itemID) {
		this.itemID = itemID;
	}
	public int getItemNO() {
		return itemNO;
	}
	public void setItemNO(int itemNO) {
		this.itemNO = itemNO;
	}
	public String getItem() {
		return item;
	}
	public void setItem(String item) {
		this.item = item;
	}
	public int getNextQuestionNO() {
		return nextQuestionNO;
	}
	public void setNextQuestionNO(int nextQuestionNO) {
		this.nextQuestionNO = nextQuestionNO;
	}
	
	@Override
	public String toString() {
		return "ItemVO [itemID=" + itemID + ", itemNO=" + itemNO + ", item="
				+ item + ", nextQuestionNO=" + nextQuestionNO
				+ ", itemDivOptions=" + itemDivOptions + ", fileIds=" + fileIds
				+ ", updateFileIds=" + updateFileIds + ", deleteFileIds="
				+ deleteFileIds + "]";
	}
}
