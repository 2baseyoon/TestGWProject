package egovframework.covision.groupware.survey.user.web;

import java.util.List;

import egovframework.baseframework.util.SessionHelper;

public class SurveyVO {
	private String surveyID;
	private String subject;
	private String subjectHtml;
	private String isAnonymouse;
	private String isSendTodo;
	private String isSendMail;
	private String groupingType;
	private String companyCode;
	private String registerCode = SessionHelper.getSession("USERID");
	private String registerDeptCode = SessionHelper.getSession("DEPTID");
	private String reviewerCode;
	private String reviewerDeptCode;
	private String approverCode;
	private String approverDeptCode;
	private String isGrouping;
	private String surveyType;
	private String targetRespondentType;
	private String isImportance;
	private String description;
	private String inlineImage;
	private String isDescriptionUseEditor;
	private String surveyStartDate;
	private String surveyEndDate;
	private String resultViewStartDate;
	private String resultViewEndDate;
	private String state;
	private List<QuestionVO> questions;
	private List<AnswerVO> answers;
	private List<TargetVO> respondentTarget;
	private List<TargetVO> resultviewTarget;
	private int questionCount;
	private String etcOpinion;
	private String communityID;
	private String prjInfo;
	private String domainID = SessionHelper.getSession("DN_ID");
	
	public String getSurveyID() {
		return surveyID;
	}
	public void setSurveyID(String surveyID) {
		this.surveyID = surveyID;
	}
	public String getSubject() {
		return subject;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public String getSubjectHtml() {
		return subjectHtml;
	}
	public void setSubjectHtml(String subjectHtml) {
		this.subjectHtml = subjectHtml;
	}
	public String getIsAnonymouse() {
		return isAnonymouse;
	}
	public void setIsAnonymouse(String isAnonymouse) {
		this.isAnonymouse = isAnonymouse;
	}
	public String getIsSendTodo() {
		return isSendTodo;
	}
	public void setIsSendTodo(String isSendTodo) {
		this.isSendTodo = isSendTodo;
	}
	public String getIsSendMail() {
		return isSendMail;
	}
	public void setIsSendMail(String isSendMail) {
		this.isSendMail = isSendMail;
	}
	public String getGroupingType() {
		return groupingType;
	}
	public void setGroupingType(String groupingType) {
		this.groupingType = groupingType;
	}
	public String getCompanyCode() {
		return companyCode;
	}
	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}
	public String getRegisterCode() {
		return registerCode;
	}
	public void setRegisterCode(String registerCode) {
		this.registerCode = registerCode;
	}
	public String getRegisterDeptCode() {
		return registerDeptCode;
	}
	public void setRegisterDeptCode(String registerDeptCode) {
		this.registerDeptCode = registerDeptCode;
	}
	public String getReviewerCode() {
		return reviewerCode;
	}
	public void setReviewerCode(String reviewerCode) {
		this.reviewerCode = reviewerCode;
	}
	public String getReviewerDeptCode() {
		return reviewerDeptCode;
	}
	public void setReviewerDeptCode(String reviewerDeptCode) {
		this.reviewerDeptCode = reviewerDeptCode;
	}
	public String getApproverCode() {
		return approverCode;
	}
	public void setApproverCode(String approverCode) {
		this.approverCode = approverCode;
	}
	public String getApproverDeptCode() {
		return approverDeptCode;
	}
	public void setApproverDeptCode(String approverDeptCode) {
		this.approverDeptCode = approverDeptCode;
	}
	public String getIsGrouping() {
		return isGrouping;
	}
	public void setIsGrouping(String isGrouping) {
		this.isGrouping = isGrouping;
	}
	public String getSurveyType() {
		return surveyType;
	}
	public void setSurveyType(String surveyType) {
		this.surveyType = surveyType;
	}
	public String getTargetRespondentType() {
		return targetRespondentType;
	}
	public void setTargetRespondentType(String targetRespondentType) {
		this.targetRespondentType = targetRespondentType;
	}
	public String getIsImportance() {
		return isImportance;
	}
	public void setIsImportance(String isImportance) {
		this.isImportance = isImportance;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getInlineImage() {
		return inlineImage;
	}
	public void setInlineImage(String inlineImage) {
		this.inlineImage = inlineImage;
	}
	public String getIsDescriptionUseEditor() {
		return isDescriptionUseEditor;
	}
	public void setIsDescriptionUseEditor(String isDescriptionUseEditor) {
		this.isDescriptionUseEditor = isDescriptionUseEditor;
	}
	public String getSurveyStartDate() {
		return surveyStartDate;
	}
	public void setSurveyStartDate(String surveyStartDate) {
		this.surveyStartDate = surveyStartDate;
	}
	public String getSurveyEndDate() {
		return surveyEndDate;
	}
	public void setSurveyEndDate(String surveyEndDate) {
		this.surveyEndDate = surveyEndDate;
	}
	public String getResultViewStartDate() {
		return resultViewStartDate;
	}
	public void setResultViewStartDate(String resultViewStartDate) {
		this.resultViewStartDate = resultViewStartDate;
	}
	public String getResultViewEndDate() {
		return resultViewEndDate;
	}
	public void setResultViewEndDate(String resultViewEndDate) {
		this.resultViewEndDate = resultViewEndDate;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public List<QuestionVO> getQuestions() {
		return questions;
	}
	public void setQuestions(List<QuestionVO> questions) {
		this.questions = questions;
	}
	public List<AnswerVO> getAnswers() {
		return answers;
	}
	public void setAnswers(List<AnswerVO> answers) {
		this.answers = answers;
	}
	public List<TargetVO> getRespondentTarget() {
		return respondentTarget;
	}
	public void setRespondentTarget(List<TargetVO> respondentTarget) {
		this.respondentTarget = respondentTarget;
	}
	public List<TargetVO> getResultviewTarget() {
		return resultviewTarget;
	}
	public void setResultviewTarget(List<TargetVO> resultviewTarget) {
		this.resultviewTarget = resultviewTarget;
	}
	public int getQuestionCount() {
		return questionCount;
	}
	public void setQuestionCount(int questionCount) {
		this.questionCount = questionCount;
	}
	public String getEtcOpinion() {
		return etcOpinion;
	}
	public void setEtcOpinion(String etcOpinion) {
		this.etcOpinion = etcOpinion;
	}
	public String getCommunityID() {
		return communityID;
	}
	public void setCommunityID(String communityID) {
		this.communityID = communityID;
	}
	public String getPrjInfo() {
		return prjInfo;
	}
	public void setPrjInfo(String prjInfo) {
		this.prjInfo = prjInfo;
	}
	public String getDomainID() {
		return domainID;
	}
	public void setDomainID(String domainID) {
		this.domainID = domainID;
	}
	
	@Override
	public String toString() {
		return "SurveyVO [surveyID=" + surveyID + ", subject=" + subject + ", subjectHtml=" + subjectHtml
				+ ", isAnonymouse=" + isAnonymouse + ", isSendTodo=" + isSendTodo + ", isSendMail=" + isSendMail
				+ ", groupingType=" + groupingType + ", companyCode=" + companyCode + ", registerCode=" + registerCode
				+ ", registerDeptCode=" + registerDeptCode + ", reviewerCode=" + reviewerCode + ", reviewerDeptCode="
				+ reviewerDeptCode + ", approverCode=" + approverCode + ", approverDeptCode=" + approverDeptCode
				+ ", isGrouping=" + isGrouping + ", surveyType=" + surveyType + ", targetRespondentType="
				+ targetRespondentType + ", isImportance=" + isImportance + ", description=" + description
				+ ", inlineImage=" + inlineImage + ", isDescriptionUseEditor=" + isDescriptionUseEditor
				+ ", surveyStartDate=" + surveyStartDate + ", surveyEndDate=" + surveyEndDate + ", resultViewStartDate="
				+ resultViewStartDate + ", resultViewEndDate=" + resultViewEndDate + ", state=" + state + ", questions="
				+ questions + ", answers=" + answers + ", respondentTarget=" + respondentTarget + ", resultviewTarget="
				+ resultviewTarget + ", questionCount=" + questionCount + ", etcOpinion=" + etcOpinion
				+ ", communityID=" + communityID + ", prjInfo=" + prjInfo + ", domainID=" + domainID + "]";
	}
}
