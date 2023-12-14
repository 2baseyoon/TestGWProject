package egovframework.covision.groupware.survey.user.web;

public class AnswerVO {
	private String surveyID;
	private String questionID;
	private String questionNO;
	private String questionType;
	private String groupingNo;
	private String itemID;
	private String answerItem;
	private String etcOpinion;
	private String weighting;
	private String respondentCode;
	private String respondentName;
	private String respondentLevel;
	private String respondentPosition;
	private String respondentTitle;
	private String respondentDept;
	
	public String getWeighting() {
		return weighting;
	}
	public void setWeighting(String weighting) {
		this.weighting = weighting;
	}
	public String getQuestionType() {
		return questionType;
	}
	public void setQuestionType(String questionType) {
		this.questionType = questionType;
	}
	public String getQuestionNO() {
		return questionNO;
	}
	public void setQuestionNO(String questionNO) {
		this.questionNO = questionNO;
	}
	public String getGroupingNo() {
		return groupingNo;
	}
	public void setGroupingNo(String groupingNo) {
		this.groupingNo = groupingNo;
	}
	public String getSurveyID() {
		return surveyID;
	}
	public void setSurveyID(String surveyID) {
		this.surveyID = surveyID;
	}
	public String getQuestionID() {
		return questionID;
	}
	public void setQuestionID(String questionID) {
		this.questionID = questionID;
	}
	public String getItemID() {
		return itemID;
	}
	public void setItemID(String itemID) {
		this.itemID = itemID;
	}
	public String getAnswerItem() {
		return answerItem;
	}
	public void setAnswerItem(String answerItem) {
		this.answerItem = answerItem;
	}
	public String getEtcOpinion() {
		return etcOpinion;
	}
	public void setEtcOpinion(String etcOpinion) {
		this.etcOpinion = etcOpinion;
	}
	public String getRespondentCode() {
		return respondentCode;
	}
	public void setRespondentCode(String respondentCode) {
		this.respondentCode = respondentCode;
	}
	public String getRespondentName() {
		return respondentName;
	}
	public void setRespondentName(String respondentName) {
		this.respondentName = respondentName;
	}
	public String getRespondentLevel() {
		return respondentLevel;
	}
	public void setRespondentLevel(String respondentLevel) {
		this.respondentLevel = respondentLevel;
	}
	public String getRespondentPosition() {
		return respondentPosition;
	}
	public void setRespondentPosition(String respondentPosition) {
		this.respondentPosition = respondentPosition;
	}
	public String getRespondentTitle() {
		return respondentTitle;
	}
	public void setRespondentTitle(String respondentTitle) {
		this.respondentTitle = respondentTitle;
	}
	public String getRespondentDept() {
		return respondentDept;
	}
	public void setRespondentDept(String respondentDept) {
		this.respondentDept = respondentDept;
	}
	
	@Override
	public String toString() {
		return "AnswerVO [surveyID=" + surveyID + ", questionID=" + questionID
				+ ", questionNO=" + questionNO + ", questionType="
				+ questionType + ", groupingNo=" + groupingNo + ", itemID="
				+ itemID + ", answerItem=" + answerItem + ", etcOpinion="
				+ etcOpinion + ", weighting=" + weighting + ", respondentCode="
				+ respondentCode + ", respondentName=" + respondentName
				+ ", respondentLevel=" + respondentLevel
				+ ", respondentPosition=" + respondentPosition
				+ ", respondentTitle=" + respondentTitle + ", respondentDept="
				+ respondentDept + "]";
	}
}
