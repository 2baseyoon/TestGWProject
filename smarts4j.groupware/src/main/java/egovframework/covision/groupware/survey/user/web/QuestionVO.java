package egovframework.covision.groupware.survey.user.web;

import java.util.List;

public class QuestionVO {
	private String questionID;
	private int questionNO;
	private String paragraph;
	private String question;
	private String description;
	private String questionType;
	private String isRequired;
	private String requiredInfo;
	private String isEtc;
	private int groupingNo;
	private String groupName;
	private int nextDefaultQuestionNO;
	private int nextGroupingNo;
	private List<ItemVO> items;
	private int itemCount;
	private String groupDivOptions;
	
	public int getNextDefaultQuestionNO() {
		return nextDefaultQuestionNO;
	}
	public void setNextDefaultQuestionNO(int nextDefaultQuestionNO) {
		this.nextDefaultQuestionNO = nextDefaultQuestionNO;
	}
	public String getGroupDivOptions() {
		return groupDivOptions;
	}
	public void setGroupDivOptions(String groupDivOptions) {
		this.groupDivOptions = groupDivOptions;
	}
	public String getQuestionID() {
		return questionID;
	}
	public void setQuestionID(String questionID) {
		this.questionID = questionID;
	}
	public int getQuestionNO() {
		return questionNO;
	}
	public void setQuestionNO(int questionNO) {
		this.questionNO = questionNO;
	}
	public String getParagraph() {
		return paragraph;
	}
	public void setParagraph(String paragraph) {
		this.paragraph = paragraph;
	}
	public String getQuestion() {
		return question;
	}
	public void setQuestion(String question) {
		this.question = question;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getQuestionType() {
		return questionType;
	}
	public void setQuestionType(String questionType) {
		this.questionType = questionType;
	}
	public String getIsRequired() {
		return isRequired;
	}
	public void setIsRequired(String isRequired) {
		this.isRequired = isRequired;
	}
	public String getRequiredInfo() {
		return requiredInfo;
	}
	public void setRequiredInfo(String requiredInfo) {
		this.requiredInfo = requiredInfo;
	}
	public String getIsEtc() {
		return isEtc;
	}
	public void setIsEtc(String isEtc) {
		this.isEtc = isEtc;
	}
	public int getGroupingNo() {
		return groupingNo;
	}
	public void setGroupingNo(int groupingNo) {
		this.groupingNo = groupingNo;
	}
	public String getGroupName() {
		return groupName;
	}
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}
	public int getNextGroupingNo() {
		return nextGroupingNo;
	}
	public void setNextGroupingNo(int nextGroupingNo) {
		this.nextGroupingNo = nextGroupingNo;
	}
	public List<ItemVO> getItems() {
		return items;
	}
	public void setItems(List<ItemVO> items) {
		this.items = items;
	}
	public int getItemCount() {
		return itemCount;
	}
	public void setItemCount(int itemCount) {
		this.itemCount = itemCount;
	}
	
	@Override
	public String toString() {
		return "QuestionVO [questionID=" + questionID + ", questionNO="
				+ questionNO + ", paragraph=" + paragraph + ", question="
				+ question + ", description=" + description + ", questionType="
				+ questionType + ", isRequired=" + isRequired + ", requiredInfo=" + requiredInfo + ", isEtc="
				+ isEtc + ", groupingNo=" + groupingNo + ", groupName="
				+ groupName + ", nextDefaultQuestionNO="
				+ nextDefaultQuestionNO + ", nextGroupingNo=" + nextGroupingNo
				+ ", items=" + items + ", itemCount=" + itemCount
				+ ", groupDivOptions=" + groupDivOptions + "]";
	}
}
