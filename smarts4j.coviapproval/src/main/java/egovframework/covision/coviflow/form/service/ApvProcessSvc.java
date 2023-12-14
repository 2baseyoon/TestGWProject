package egovframework.covision.coviflow.form.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface ApvProcessSvc {
	public String doProcess(CoviMap pObj, CoviMap processFormDataReturn) throws Exception;

	public CoviMap doCreateInstance(String processType, CoviMap pObj, List<MultipartFile> mf) throws Exception;

	public CoviMap doCreateInstance(String processType, CoviMap pObj, List<MultipartFile> mf, CoviMap mfList) throws Exception;

	public void setPrivateDomainDataForDraft(CoviMap fParams) throws Exception;

	public void updateFormInstDocNumber(String FormInstID) throws Exception;

	public boolean chkCommentWrite(String ur_code, String password) throws Exception;

	public void doReserve(CoviMap formObj) throws Exception;

	public CoviMap getBatchApvLine(CoviMap params) throws Exception;

	public void doForward(CoviMap formObj) throws Exception;

	public void deleteArchiveInProcess(CoviMap params) throws Exception;

	public int getWorkitemAbortCount(CoviMap formObj) throws Exception;

	public CoviList selectAutoDeputyList(CoviMap params) throws Exception;

	CoviList selectAutoRecList() throws Exception;

	public void updateMarkAutoApprove(String taskID, String mark) throws Exception;

	public String doCommentAttachFileSave(List<MultipartFile> mf_comment, CoviMap formObj) throws Exception;

	CoviMap getRecApvline(CoviMap appvLine) throws Exception;

	public CoviList selectReservedDraftList() throws Exception;

	// FIDO
	public String selectFidoStatus(CoviMap params) throws Exception;

	public boolean getIsUsePasswordForm(String formPrefix) throws Exception;

	public CoviMap draftCommentSecure(CoviMap formObj) throws Exception;
	
	public boolean getAuthByTaskID(CoviMap param) throws Exception;
	
	public String getDraftKey(CoviMap params) throws Exception;
		
	public CoviMap getFormInfoList(String fiid) throws Exception;
	
	public void doConsultationRequest(CoviMap formObj) throws Exception;

	public void doConsultation(CoviMap formObj) throws Exception;

	public void consultationRequstCancel(CoviMap formObj) throws Exception;

	public int deleteFormInstacne(CoviMap params) throws Exception;

	public CoviMap getLastModifiedDate(CoviMap params) throws Exception;

	public void doEditProcess(CoviMap formObj) throws Exception;
}
