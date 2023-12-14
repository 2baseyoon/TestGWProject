package egovframework.covision.coviflow.govdocs.service.impl;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;




import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.service.ApprovalGovDocSvc;
import egovframework.covision.coviflow.govdocs.util.AsyncTaskOpenDocConverter;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("approvalGovDocService")
public class ApprovalGovDocImpl extends EgovAbstractServiceImpl implements ApprovalGovDocSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Resource(name = "asyncTaskOpenDocConverter")
	private AsyncTaskOpenDocConverter asyncTaskOpenDocConverter;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Override
	public List<HashMap<String, String>> selectReceiveList(String uniqueId) throws Exception {		
		return coviMapperOne.selectList("user.govDoc.selectReceiveList", uniqueId);
	}
	
	@Override
	public String selectLog(Map<String, String> map) throws Exception {
		return coviMapperOne.selectOne("user.govDoc.selectLog",map);
	}
	
	@Override
	public String selectGovAuthManage(CoviMap params) throws Exception {
		String strRet = coviMapperOne.selectOne("user.govDoc.selectGovAuthManage",params);
		return (strRet == null ? "N" : strRet);
	}
	
	@Override
	public int checkGovReceiveDoc(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.govDoc.CheckGovReceiveDoc", params);		
	}
	
	//문서유통 발송함/수신함 엑셀다운로드
	@Override
	public CoviMap selectGovDocListExcel(CoviMap params, String headerKey, String govDocs) throws Exception {
		String query = "";
		if (govDocs.equalsIgnoreCase("sendWait")) { // 발송함
			query = "user.govDoc.selectGovApvSendCmplList";
		} else if (govDocs.equalsIgnoreCase("receiveWait") || govDocs.equalsIgnoreCase("receiveGov24Wait")) { // 수신함, 문서24
			query = "user.govDoc.selectGovApvReceive";
		} else if(govDocs.equalsIgnoreCase("receiveProcess")) { // 배부완료
			query = "user.govDoc.selectGovApvReceiveExcel";
		}
			
		CoviList list = coviMapperOne.list(query, params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, headerKey));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectGovApvHistory(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list1 = coviMapperOne.list("user.govDoc.selectGovHistoryList",params);
		String strListCol = "UNIQUE_ID,PROCESSSUBJECT,FILE_NAME,PROCESS_DT,STATUS,LOG_YN,LINKURL,TOTAL_COUNT,HISTORY_SEQ,DOCTYPE,INSERT_DT";
		
 		int cnt = 0; 		
		cnt = list1.size() == 0 ? 0 : list1.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list2 = coviMapperOne.list("user.govDoc.selectGovHistoryList",params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list2, strListCol));		
		resultList.put("page", page);
		
		return resultList;
	}
	
	
	//문서유통 발송함 목록 조회
	@Override
	public CoviMap selectGovApvSend(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		String strListQuery = "user.govDoc.selectGovApvSendCmplList";

		String strListCol = "PROCESS_ID,FORM_INST_ID,DOCNUMBER,RECEIVERNAME,PROCESSSUBJECT,SENDDATE,INITIATORID,INITIATORNAME,INITIATORUNITNAME,LINKURL,RECEIVENO,INSERTED,DOCTYPE,UNIQUEID,LOG_YN,HISTORY_SEQ,GOVDOC_STATUS,LAST_SEND_DT";		
		CoviList list1 = coviMapperOne.list(strListQuery,params);
		
 		int cnt = 0;
		cnt = list1.size() == 0 ? 0 : list1.getMap(0).getInt("TOTAL_COUNT");
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list2 = coviMapperOne.list(strListQuery,params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list2, strListCol));
		resultList.put("page", page);
		
		return resultList;
	}
	
	//문서유통 수신함 목록 조회
	@Override
	public CoviMap selectGovApvReceive(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		String strListQuery = "user.govDoc.selectGovApvReceive";
		String strListCol = "PROCESSSUBJECT,INITIATORNAME,DOC_ID,DOCNUMBER,INSERTED,RECEIVERNAME,DOCTYPE,PROCESS_ID,UNIQUEID,RECEIVENO,FORMINSTID,ACCEPTDATE,LINKURL,TOTAL_COUNT,DISTRIBDEPTNAME,DISTRIBDATE,SENDTYPE,GOVDOC_STATUS,SECURITYOPTION,SECURITYTEXT";
		CoviList list1 = coviMapperOne.list(strListQuery,params);
		
		int cnt = 0;
		cnt = list1.size() == 0 ? 0 : list1.getMap(0).getInt("TOTAL_COUNT");
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list2 = coviMapperOne.list(strListQuery,params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list2, strListCol));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectGovManager(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		String strListQuery = "user.govDoc.selectGovManageList";
		CoviList list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", list);		
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectGovDocInOutManager(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.govDoc.selectGovDocManageCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("user.govDoc.selectGovDocManageList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DeptCode,DeptName,ListAuthorityName,ListAuthorityID"));
		return resultList;
	}
	
	@Override
	public int selectGovDocManager(CoviMap params) throws Exception {
		int result = (int) coviMapperOne.getNumber("user.govDoc.selectGovDocManager", params);
		return result;
	}
	
	@Override
	public void insertGovDocUser(CoviMap params) throws Exception {
		coviMapperOne.insert("user.govDoc.insertGovDocUser", params);
	}
	
	@Override
	public void deleteGovDocUser(CoviMap params) throws Exception {		
		coviMapperOne.delete("user.govDoc.deleteGovDocUser", params);
	}
	
	@Override
	public void insertGovDocInOutUser(CoviMap params) throws Exception {
		coviMapperOne.insert("user.govDoc.insertGovDocInOutUser", params);
	}
	
	@Override
	public void deleteGovDocInOutUser(CoviMap params) throws Exception {		
		coviMapperOne.delete("user.govDoc.deleteGovDocInOutUser", params);
	}
	
	@Override
	public CoviMap selectGovHistory(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();		
		String strListQuery = "user.govDoc.";
		String strListCol="";
		
		if( "history,sendWait".contains( params.getString("govDocs") ) ) {			
			strListQuery += "selectProcessGovLogDetail";
			strListCol = "RNUM,UNIQUE_ID,SEND_USER,STATUS,PROCESS_DT,LOG_YN,LOG,SEND_ID,RECEIVE_USER,DOC_ID,ORG_NM,FORM_INST_ID,PROCESS_ID,HISTORY_SEQ,REQ_RESEND_DT,RESEND_DT";	
		}		
		
		CoviList list = coviMapperOne.list(strListQuery,params);
		
		int cnt = list.size() == 0 ? 0 : list.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,strListCol));		
		resultList.put("page", page);
		
		return resultList;
	}
	

	@Override
	public CoviMap selectGovSendInfoHistory(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();		
		
		String strListCol = "PROCESSSUBJECT,DOCNUMBER,INSERTED,DISPLAYSENDNAME,ACCEPTNUMBER,UNIQUEID,ACCEPTORNAME,ACCEPTDATE,PUBLICATION";
		CoviList list = coviMapperOne.list("user.govDoc.selectGovSendInfoHistory",params);
		
		
		params.addAll(page);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,strListCol));		
		resultList.put("page", page);
		
		return resultList;
	}
	
	// Offline 문서 저장 메소드
	@Override
	public void doSaveDocList(CoviMap pObj) throws Exception {
		CoviMap formObj = new CoviMap();
		CoviMap formData = new CoviMap();
		formObj = pObj.getJSONObject("formObj");
		formData = pObj.getJSONObject("formData");
		
		CoviMap params = new CoviMap();
		
		String formInstID = formObj.getString("FormInstID");
		
		int fiscalYear = Calendar.YEAR;
		int iDocumentListType = Integer.parseInt(formObj.getString("DocListType"));
		String approvalURL = "/approval/approval_Form.do?mode=COMPLETE&forminstanceID="+formObj.getString("FormInstID")+"&formPrefix=" + formObj.getString("FormPrefix") + "&archived=true&menukind=notelist&doclisttype=89";
		
        if (iDocumentListType == 10 || iDocumentListType == 3) { // 발송
        	int serialNumber = registerDocNumber(11, fiscalYear, SessionHelper.getSession("DEPTID"), SessionHelper.getSession("DEPTNAME"));
        	
        	String formattedSerialNumber = String.format("%04d", serialNumber);
    		String sIssueDocNo = SessionHelper.getSession("DEPTNAME") + "-" + fiscalYear + "-" + formattedSerialNumber; // shortname으로 변경 필요
    		
        	CoviMap bodyContextObj = new CoviMap();
			bodyContextObj = formData.getJSONObject("BodyContext");
			bodyContextObj.put("ENFORCEDATE", egovframework.coviframework.util.ComUtils.GetLocalCurrentDate()); // 오늘 일자
			bodyContextObj.put("REGNUMBER", sIssueDocNo);
        	
        	params.put("processID", "0");
			params.put("formInstID", formInstID);
			params.put("docNumber", sIssueDocNo);
			params.put("govRecieveName", formObj.getString("GOV_RECIEVE_NAME"));
			params.put("formPrefix", formObj.getString("FormPrefix"));
			params.put("formID", formObj.getString("FormID"));
			params.put("schemaID", formObj.getString("SchemaID"));
			params.put("approvalURL", approvalURL);
			params.put("bodyContext", bodyContextObj.toString());			
			coviMapperOne.insert("user.govDoc.insertProcessGov", params);
			
			params.clear();
			params.put("formInstID", formInstID);
			params.put("No", registerDocNumber(10, fiscalYear, SessionHelper.getSession("DEPTID"), SessionHelper.getSession("DEPTNAME")) + ";");
			coviMapperOne.update("user.govDoc.updateFormNo", params);
			coviMapperOne.update("user.govDoc.updateGovSendNo", params);
        }
        else if (iDocumentListType == 20) // 접수
        {
        	String sBodyContext = "";
        	String sAttachFileInfo = "";
        	
        	params.put("formInstID", formInstID);
			CoviList list = coviMapperOne.list("form.formLoad.selectFormInstance", params);
			
			CoviList resultList = new CoviList();
			CoviMap resultObj = new CoviMap();
			resultList = CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,RuleItemInfo");
			resultObj = (CoviMap)resultList.get(0);
			
			// base64 decode 필요??
			sBodyContext = new String(Base64.decodeBase64(resultObj.getString("BodyContext")), StandardCharsets.UTF_8);
			sAttachFileInfo = new String(Base64.decodeBase64(resultObj.getString("AttachFileInfo")), StandardCharsets.UTF_8);

			params.clear();
			params.put("processID", "0");
			params.put("formInstID", formInstID);
			params.put("documentSubject", formObj.getString("DocumentSubject"));
			params.put("initiatorID", SessionHelper.getSession("USERID"));
			params.put("initiatorName", SessionHelper.getSession("USERNAME"));
			params.put("initiatorUnitID", SessionHelper.getSession("DEPTID"));
			params.put("initiatorName", SessionHelper.getSession("DEPTNAME"));
			params.put("docUser", SessionHelper.getSession("USERNAME"));
			params.put("docNumber", formObj.getString("GOV_DOC_NUMBER"));
			params.put("bodyContext", sBodyContext);
			params.put("attachInfo", sAttachFileInfo);
			params.put("linkURL", approvalURL);
			params.put("docType", "send");
			params.put("dispalySendName", formObj.getString("GOV_SEND_NAME"));
			params.put("receiveEnt", SessionHelper.getSession("DN_Code"));
			coviMapperOne.insert("user.govDoc.insertProcessGovRec", params);
			
			// 상태값 update
            // [문서접수처리(WF_PROCESSGOV_RECEIVE_ASSIGN TABLE에 추가)]
			params.clear();
			params.put("formInstID", formInstID);
			params.put("docID", formInstID);
			params.put("authorityID", SessionHelper.getSession("USERID"));
			params.put("userID", "GDocService");
			params.put("userName", "문서유통");
			params.put("deptName", "문서유통");
			params.put("status", "accept");
			coviMapperOne.insert("user.govDoc.insertProcessGovRecAssign", params);
			coviMapperOne.insert("user.govDoc.updateProcessGovRecAssign", params);
			
			params.clear();
			params.put("formInstID", formInstID);
			params.put("docID", formInstID);
			params.put("authorityID", SessionHelper.getSession("DEPTID"));
			params.put("userID", SessionHelper.getSession("USERID"));
			params.put("userName", SessionHelper.getSession("USERNAME"));
			params.put("status", "RECEIVEPROCESS");
			coviMapperOne.insert("user.govDoc.insertProcessGovRecAssign2", params);
			coviMapperOne.insert("user.govDoc.updateProcessGovRecAssign2", params);
			
			// 문서번호(접수)
			params.clear();
			params.put("formInstID", formInstID);
			params.put("No", registerDocNumber(20, fiscalYear, SessionHelper.getSession("DEPTID"), SessionHelper.getSession("DEPTNAME")));
			coviMapperOne.update("user.govDoc.updateFormNo", params);
			coviMapperOne.update("user.govDoc.updateGovReceiveNo", params);
        }  
	}
	
	public int registerDocNumber(int doclisttype, int fiscalYear, String deptCode, String deptName) throws Exception {
		CoviMap params = new CoviMap();
		
		params.put("docListType", doclisttype);
		params.put("fiscalYear", fiscalYear);
		params.put("deptCode", deptCode);
		params.put("deptName", deptName);
		params.put("categoryNumber", "");
		
		// 발송번호 발번
		coviMapperOne.update("user.govDoc.insertDocumentNumber", params);
		int serialNumber = (int)params.get("SerialNumber");
		
		return serialNumber;
	}
	
//	@Override
//	public int updateGovRecvStatus(CoviMap params) throws Exception { 
//		return coviMapperOne.update("user.govDoc.updateProcessGovRecvStatus",params);
//	}
	
	@Override
	public int insertDocumentNumber(CoviMap params) throws Exception { 
		Calendar cal = Calendar.getInstance();
		int fiscalYear = cal.get(Calendar.YEAR);
		
		String[] doc = RedisDataUtil.getBaseConfig("govDocAccept").split(";"); //문서유통 접수번호 발번 
		
		params.put("docListType", doc[0]); //15
		params.put("fiscalYear", String.valueOf(fiscalYear));
		params.put("deptCode", doc[1]); //SH
		params.put("deptName", doc[2]); //수협중앙회문서실
		params.put("categoryNumber", "");
		
		if(params.get("status").equals("accept")) { //접수시에만 접수번호 발번 후 serialNumber 1씩 증가
			int insertDocNumber = coviMapperOne.update("user.govDoc.insertDocumentNumber",params);
		}
		
		CoviList list = coviMapperOne.list("user.govDoc.selectDocumentNumber", params);
		List<Map<String, Object>> listMap = list;
		int serialNumber = Integer.parseInt(String.valueOf(listMap.get(0).get("SerialNumber")));
		String deptName = (String) listMap.get(0).get("DeptName");
		
		String formattedSerialNumber = String.format("%04d", serialNumber);
		String displayedNumber = deptName+"-"+formattedSerialNumber;
		params.put("displayedNumber", displayedNumber);
		params.put("SerialNumber", serialNumber);
		
		if(params.get("status").equals("accept")) { //접수 시에 바뀌는 displayedNumber  update
			int updateDocNumber = coviMapperOne.update("user.govDoc.updateDocumentNumber",params);
		}
		
		params.put("userId", SessionHelper.getSession("USERID"));
		return coviMapperOne.update("user.govDoc.updateProcessGovRecvStatus",params);
	}
	
	@Override
	public CoviMap selectGovAuthManageList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		CoviList list = coviMapperOne.list("user.govDoc.selectGovAuthManageList", params);
		
		resultList.put("list", list);		
		resultList.put("page", page);
		
		return resultList;
	}
	
	
	// 기록물철 다안기안 이관
	@Override
	public void executeRecordDocInsert(CoviMap spParams) throws Exception {
		String apvMode = spParams.getString("apvMode"); 
		if(apvMode.equals("COMPLETE") || apvMode.equals("DISTCOMPLETE")) {		
			String divisionType = apvMode;
			
			String formInstID = spParams.getString("formInstID");
			String processID = spParams.getString("processID");
			String approvalContext = spParams.getString("approvalContext");
			String docNumber = spParams.getString("docNumber");
			String bodyContext = spParams.getString("bodyContext");
			
			CoviMap formInfoExt = new CoviMap();
			formInfoExt = spParams.getJSONObject("formInfoExt");
			
    		// 메인테이블
			String mainTable = formInfoExt.getString("MainTable");
			// 서브테이블
			String subTable1 = formInfoExt.getString("SubTable1");
			
            CoviMap params = new CoviMap();
    		params.put("formInstID", formInstID);
    		params.put("processID", processID);
    		params.put("subTable1", subTable1);
    		params.put("mainTable", mainTable);

			String parentFiid = "";
			String recordSeq = ""; //생산기관등록번호	
			int rowSeq = 0; //n안
			if(apvMode.equals("DISTCOMPLETE")) {
	    		CoviMap prodInfo = coviMapperOne.selectOne("user.govDoc.selectProductInfo", params);
	    		if(prodInfo != null) {
	    			parentFiid = prodInfo.getString("FormInstID");
	    			recordSeq = prodInfo.getString("RecordSeq");
	    			rowSeq = prodInfo.getInt("RowSeq");
	    			
	        		params.put("parentFormInstID", parentFiid);
	    		}
	    		
	    		CoviMap docNumInfo = coviMapperOne.selectOne("user.govDoc.selectDistDocNumber", params);
	    		if(docNumInfo != null) {
	    			docNumber = docNumInfo.getString("ReceiveNo");
	    		}
			}
    		
			// 메인테이블 조회
    		CoviMap mainDocInfo = coviMapperOne.selectOne("user.govDoc.selectDocMainInfo", params);

    		Date date = new Date();	    		
    		SimpleDateFormat fmt = null;
    		
    		fmt = new SimpleDateFormat ("yyyyMMddHHmm");
    		String sProductDate = fmt.format(date);
    		fmt = new SimpleDateFormat ("yyyyMMdd");
    		String sCompleteDate = fmt.format(date);
    		
    		// 기안자 정보 조회
    		String DrafterID = mainDocInfo.getString("DRAFTER_ID");
    		String DrafterName = mainDocInfo.getString("DRAFTER_NAME");
    		String DrafterDeptID = mainDocInfo.getString("DRAFTER_DEPT");
    		String DrafterDeptName = mainDocInfo.getString("DRAFTER_DEPTNM");
    		if(apvMode.equals("COMPLETE") && docNumber.equals("")) {
    			docNumber = mainDocInfo.getString("DocNo");
    		}
			
			String approvalName = ""; //결재권자(직위/직급)
			String reDrafterID = ""; //재기안자(업무담당자) ID
			String reDrafterName = ""; //재기안자(업무담당자) 이름
			String receiptDeptID = ""; //수신부서 ID
			String receiptDeptName = ""; //수신부서 이름

			int divisionIdx = 0;
			
			CoviMap approvalLine = CoviMap.fromObject(approvalContext);
			Object divisionObj = ((CoviMap)approvalLine.get("steps")).get("division");
			CoviList divisions = new CoviList();
			
			if(divisionObj instanceof CoviMap){
				CoviMap divisionJsonObj = (CoviMap)divisionObj;
				divisions.add(divisionJsonObj);
			} else {
				divisions = (CoviList)divisionObj;
				divisionIdx = divisions.size()-1;
			}
			
			if(divisions != null){
				CoviMap division = (CoviMap)divisions.get(divisionIdx);
				
				Object stepO = division.get("step");
				CoviList steps = new CoviList();
				if(stepO instanceof CoviMap){
					CoviMap stepJsonObj = (CoviMap)stepO;
					steps.add(stepJsonObj);
				} else {
					steps = (CoviList)stepO;
				}	
				// 재기안자
				if(steps != null){
					if(divisionIdx > 0) {
						reDrafterID = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("code");
						reDrafterName = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("name");
						receiptDeptID = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("oucode");
						receiptDeptName = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("ouname");
					}
					approvalName = steps.getJSONObject(steps.size()-1).getJSONObject("ou").getJSONObject("person").getString("name");
				}
			}
			
			// 서브테이블 조회
			int sub_cnt = (int) coviMapperOne.getNumber("user.govDoc.selectDocSubCnt", params); // 안 개수
			CoviList subDocInfoList =  new CoviList();
			if(sub_cnt > 0) {
				subDocInfoList = coviMapperOne.list("user.govDoc.selectDocSubInfo", params); // 안별 정보
			} else {
	    		params.put("processID", processID);
				subDocInfoList = coviMapperOne.list("user.govDoc.selectDocTempInfo", params);
			}
    		
			// 안 별 기록물 정보 조회 및 이관
    		for(int i = 0; i < subDocInfoList.size(); i++) {
    			CoviMap docInfo = subDocInfoList.getMap(i);
    			
                String sBODY_HTML = docInfo.getString("MULTI_BODY_CONTEXT_HTML");
                String sBODY_HWP = docInfo.getString("MULTI_BODY_CONTEXT_HWP");
                String sReceiptList = docInfo.getString("MULTI_RECEIPT_LIST");
                String sReceiptName = docInfo.getString("MULTI_RECEIVENAMES");
                String sReceiptOnlyName = "";
                if(apvMode.equals("COMPLETE") && sReceiptName != null && !sReceiptName.equals("")) { //기안부서 완료 시 수신부서명만 따로 저장
                	StringBuffer buf = new StringBuffer();
                	for(int j = 0; j < sReceiptName.split(";").length; j++) {
                		buf.append(sReceiptName.split(";")[j].split(":")[2].split("\\^")[0]);
                		if(j < sReceiptName.split(";").length-1) buf.append(", ");
                	}
                	sReceiptOnlyName = buf.toString();
                }
    			String sTitle = docInfo.getString("MULTI_TITLE");
    			String sRegistCheck = docInfo.getString("MULTI_REGIST_CHECK");
    			String sKeepPeriod = docInfo.getString("MULTI_KEEP_PERIOD");
    			String sSecureLevel = docInfo.getString("MULTI_SECURE_LEVEL");
                String sReleaseCheck = docInfo.getString("MULTI_RELEASE_CHECK");
                String sReleaseRestriction = docInfo.getString("MULTI_RELEASE_RESTRICTION");
                String sSpecialRecord = docInfo.getString("MULTI_SPECIAL_RECORD");
                String sRecordClassNum = docInfo.getString("MULTI_RECORD_CLASS_NUM");
                String sRecordSubject = docInfo.getString("MULTI_RECORD_SUBJECT");
                String sDivisionType = apvMode; //sRegistCheck.indexOf("접수") > -1 ? "접수" : "생산";

    			String fiscalYear = sCompleteDate.substring(0, 4);
                
                Map<String, Object> paramsC = new HashMap<>();
    			paramsC.put("registCheck", sRegistCheck);
    			paramsC.put("fiscalYear", fiscalYear);
    			paramsC.put("deptCode", apvMode.equals("COMPLETE") ? DrafterDeptID : receiptDeptID);

	    		coviMapperOne.insert("user.govDoc.insertGovRecordSerial", paramsC);
    			String serialNumber = (String)paramsC.get("SerialNumber");

				String productNum = (apvMode.equals("COMPLETE") ? DrafterDeptID : receiptDeptID) + serialNumber; //생산(접수)등록번호
                
                params.clear();

        		params.put("formInstID", formInstID);
                if(apvMode.equals("DISTCOMPLETE")) {
            		params.put("parentFormInstID", parentFiid);
                }
                params.put("DivisionType", divisionType);
        		params.put("DrafterID", (apvMode.equals("COMPLETE") ? DrafterID : reDrafterID));
        		params.put("DrafterName", (apvMode.equals("COMPLETE") ? DrafterName : reDrafterName));
        		params.put("DrafterDeptID", (apvMode.equals("COMPLETE") ? DrafterDeptID : receiptDeptID));
        		params.put("DrafterDeptName", (apvMode.equals("COMPLETE") ? DrafterDeptName : receiptDeptName));

        		params.put("RegistCheck", sRegistCheck);
        		params.put("ProductDate", sProductDate);
        		params.put("ProductNum", productNum);
        		params.put("OldProductNum", docNumber);
        		params.put("AttachNum", "00"); //분리등록번호 00으로 고정
        		params.put("RecordSubject", sTitle);
        		params.put("RecordPageCount", "000001"); //쪽수 000001로 고정
        		params.put("ApprovalName", approvalName);
        		params.put("ProposalName", (apvMode.equals("COMPLETE") ? DrafterName : reDrafterName));
        		params.put("CompleteDate", sCompleteDate);
        		params.put("ReceiptName", (apvMode.equals("COMPLETE") ? sReceiptOnlyName : DrafterDeptName)); //기안부서(생산) 완료 시 수신부서들, 수신부서(접수) 완료 시 기안부서 넣기
        		params.put("DistNum", (apvMode.equals("DISTCOMPLETE") ? serialNumber : ""));
        		params.put("RecordSeq", (apvMode.equals("COMPLETE") ? productNum : recordSeq));
        		params.put("RecordCheck", "1"); //전자기록물여부 1로 고정
        		params.put("RecordClassNum", sRecordClassNum);
        		params.put("SpecialRecord", sSpecialRecord);
        		params.put("ReleaseCheck", sReleaseCheck);
        		params.put("ReleaseRestriction", sReleaseRestriction);
        		params.put("SecureLevel", sSecureLevel);
        		params.put("KeepPeriod", sKeepPeriod);
        		params.put("ContentSummary", ""); //시청각기록물
        		params.put("RecordType", ""); //시청각기록물
        		params.put("RecordClass", "1"); //기록물구분 1로 고정
        		params.put("ModifyCheck", "0"); //수정여부 0으로 고정
        		params.put("RejectCheck", "0"); //반려여부 0으로 고정
        		params.put("ApprovalDocLink", "/approval/approval_Form.do?mode=COMPLETE&processID="+processID+"&forminstanceID="+formInstID);
        		params.put("RecordFilePath", ""); //TODO: 결재문서 파일로 저장
        		params.put("DivisionType", sDivisionType);
        		params.put("RowSeq", apvMode.equals("DISTCOMPLETE") ? rowSeq : i+1);
        		params.put("RegisterID", (apvMode.equals("COMPLETE") ? DrafterID : reDrafterID));
        		
        		// 기록물 저장
        		coviMapperOne.insert("user.govDoc.insertRecordDoc", params);
    		}    		
		}
	}
	
	// 기록물 등록대장_단건 
	@SuppressWarnings("unchecked")
	@Override
	public void executeRecordDocSingleInsert(CoviMap spParams) throws Exception {
		String apvMode = spParams.getString("apvMode"); 
  		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		
		CoviMap params1 = new CoviMap();
		params1.put("FormInstID", spParams.getString("formInstID"));
		int cnt = (int) coviMapperOne.getNumber("form.recorddocinfo.selectRecordDocCnt", params1);
		
		if(cnt > 0){
			if(apvMode.equals("DRAFT")) { // draft process일때  기안 시 기록물철 저장
				CoviMap params = new CoviMap();
				params.put("ProcessID", spParams.getString("processID"));
				params.put("FormInstID", spParams.getString("formInstID"));
				coviMapperOne.update("form.recorddocinfo.updateRecordDocProcess", params); // RECORD_DOC_INFO UPDATE STATE("I -> P")
			}
			
			if(apvMode.equals("COMPLETE")) { // draft의 경우 발신부서완료시, request의 경우 처리부서 완료시 

				String formInstID = spParams.getString("formInstID");		

				String approvalContext = spParams.getString("approvalContext");
				String docNumber = spParams.getString("docNumber");
				String recordSeq = ""; 		 //생산기관등록번호
				
				// 1. 결재문서 FormInstance 데이터 조회
	            CoviMap params = new CoviMap();
	    		params.put("formInstID", formInstID);

	    		CoviMap mainDocInfo = coviMapperOne.selectOne("form.formLoad.selectFormInstance", params);  
	    		String sTitle = mainDocInfo.getString("Subject");

	    		String DrafterDeptName = mainDocInfo.getString("InitiatorUnitName");
	    		if(docNumber.equals("")) {
	    			docNumber = mainDocInfo.getString("DocNo");
	    		}
	    		// 2. 결재선 조회

				CoviMap approvalLine = CoviMap.fromObject(approvalContext);
				Object divisionObj = ((CoviMap)approvalLine.get("steps")).get("division");
				CoviList divisions = new CoviList();
				if(divisionObj instanceof CoviMap){ 
					CoviMap divisionJsonObj = (CoviMap)divisionObj;
					divisions.add(divisionJsonObj);
				} else { 
					divisions = (CoviList)divisionObj;

				}
				CoviList reapprovalDeptNames = new CoviList(); // 수신부서 리스트
				
				CoviList resultData = new CoviList();
				if (divisions != null) {
					for (int i = 0; i < divisions.size(); i++) { // request process의 경우 처리부서이름 조회필요
						CoviMap divisionMap = (CoviMap) divisions.get(i);
				        if (i > 0) { 
				        	reapprovalDeptNames.add(divisionMap.getString("ouname"));
				        }
					}
					
				    for (int i = 0; i < divisions.size(); i++) {
				        CoviMap divisionMap = (CoviMap) divisions.get(i);

				        String divisiontype = divisionMap.getString("divisiontype"); // SEND OR RECEIVE
				        String processID = divisionMap.getString("processID"); 		 // processID
				        String DeptCode = divisionMap.getString("oucode"); 			 // 부서코드
				        String DeptName = divisionMap.getString("ouname"); 			 // 부서이름
				        
				        CoviMap dataMap = new CoviMap();
				        dataMap.put("divisiontype", divisiontype);
				        dataMap.put("processID", processID);
				        dataMap.put("DeptCode", DeptCode);
				        dataMap.put("DeptName", DeptName);

				        Object stepO = divisionMap.get("step"); 
				        CoviList steps = new CoviList();
				        if (stepO instanceof CoviMap) {
				            CoviMap stepJsonObj = (CoviMap) stepO; 
				            steps.add(stepJsonObj);
				        } else {
				            steps = (CoviList) stepO; 
				        }

				        CoviList approvalIDs = new CoviList(); 		// 발신부서 결재자 ID 리스트
				        CoviList approvalNames = new CoviList(); 	// 발신부서 결재자 이름 리스트
				        CoviList reapprovalIDs = new CoviList(); 	// 수신부서 결재자 ID 리스트
				        CoviList reapprovalNames = new CoviList();  // 수신부서 결재자 이름 리스트
				        
				        if (steps != null) {
				            for (int j = 0; j < steps.size(); j++) {
				                if (divisiontype.equals("send") && j == 0) { 	  	   // 발신부서 기안자정보
				                    String DrafterID = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("code");
				                    String DrafterName = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("name");                 
				                    dataMap.put("DrafterID", DrafterID);
				                    dataMap.put("DrafterName", DrafterName);
				                } else if (divisiontype.equals("send") && j > 0) {     // 발신부서 결재자정보
				                    String approvalID = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("code");
				                    String approvalName = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("name");
				                    approvalIDs.add(approvalID);
				                    approvalNames.add(approvalName);
				                } else if (divisiontype.equals("receive") && j == 0) { // 수신부서 담당자정보
				                    String reDrafterID = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("code");
				                    String reDrafterName = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("name");
				                    dataMap.put("reDrafterID", reDrafterID);
				                    dataMap.put("reDrafterName", reDrafterName);
				                } else if (divisiontype.equals("receive") && j > 0) {  // 수신부서 결재자정보
				                    String reapprovalID = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("code");
				                    String reapprovalName = steps.getJSONObject(j).getJSONObject("ou").getJSONObject("person").getString("name");
				                    reapprovalIDs.add(reapprovalID);
				                    reapprovalNames.add(reapprovalName);
				                }
				            }
				            
				            if (divisiontype.equalsIgnoreCase("send")) {
				                dataMap.put("approvalID", join(approvalIDs, ","));
				                dataMap.put("approvalName", join(approvalNames, ","));   
				                dataMap.put("reapprovalDeptNames", join(reapprovalDeptNames, ","));
				            } else if (divisiontype.equalsIgnoreCase("receive")) {
				                dataMap.put("reapprovalID", join(reapprovalIDs, ","));
				                dataMap.put("reapprovalName", join(reapprovalNames, ","));
				            }
				        }
	    
				        // 결과 리스트에 추가
				        resultData.add(dataMap);
				    }
				}
				
				// 3. 생산날짜 생성
	    		Date date = new Date();	    		
	    		SimpleDateFormat fmt = null;
	    		
	    		fmt = new SimpleDateFormat ("yyyyMMddHHmm");
	    		String sProductDate = fmt.format(date);
	    		fmt = new SimpleDateFormat ("yyyyMMdd");
	    		String sCompleteDate = fmt.format(date);

				
				// 4. 수신처리스트 조회(draft process), request process의 경우는 forminstance 테이블에 수신처(처리부서)정보가 X
	            String sReceiptName = mainDocInfo.getString("ReceiveNames"); 
	            String sReceiptOnlyName = "";
	            if(sReceiptName != null && !sReceiptName.equals("")) { 
	            	StringBuffer buf = new StringBuffer();
	            	for(int j = 0; j < sReceiptName.split(";").length; j++) {
	            		 buf.append(sReceiptName.split(";")[j].split(":")[2].split("\\^")[0]);
	            	}
	            	sReceiptOnlyName = buf.toString();
	            }
	            
	            // 5. 각 부서별로 등록대장에 insert 작업
				for (Object obj : resultData) {
				    CoviMap dataMap = (CoviMap) obj;
				    String processID = dataMap.getString("processID");
				    String divisionType = dataMap.getString("divisiontype");
				    divisionType = "send".equals(divisionType) ? "COMPLETE" : "receive".equals(divisionType) ? "DISTCOMPLETE" : "UNKNOWN";
				    String DeptCode = dataMap.getString("DeptCode");
				    String DeptName = dataMap.getString("DeptName");
				    
				    String DrafterID = dataMap.getString("DrafterID"); 			 // 발신부서 - 기안자
				    String DrafterName = dataMap.getString("DrafterName"); 		 // 발신부서 - 기안자이름
					String approvalName = dataMap.getString("approvalName"); 	 // 발신부서 - 결재자리스트
					String reDrafterID = dataMap.getString("reDrafterID");   	 // 수신부서 - 담당자
					String reDrafterName = dataMap.getString("reDrafterName");   // 수신부서 - 담당자이름
					String reapprovalName = dataMap.getString("reapprovalName"); // 수신부서 - 결재자리스트
					String ReceiptName = ""; //기안부서(생산) 완료 시 수신부서들, 수신부서(접수) 완료 시 기안부서 넣기
					
					if (divisionType.equals("COMPLETE")) {
						String receiveDeptNames = dataMap.getString("reapprovalDeptNames"); 		 // 결재선에서 조회한 수신부서리스트
						if (sReceiptOnlyName.equals("")) { ReceiptName = (String) receiveDeptNames;} // draft process이면 sReceiptOnlyName사용,request면 reapprovalDeptNames사용
						else { ReceiptName = sReceiptOnlyName;}
					}
					
					// 부서별 등록번호 조회
					String fiscalYear = sCompleteDate.substring(0, 4);        	

					Map<String, Object> paramsC = new HashMap<>();
					if (divisionType.equals("COMPLETE")) {paramsC.put("registCheck", "1");} // 발신부서면 1(생산), 수신부서면 2(접수)
					else {paramsC.put("registCheck", "2");}
					paramsC.put("fiscalYear", fiscalYear);
					paramsC.put("deptCode", DeptCode);
					
					int count = coviMapperOne.selectOne("user.govDoc.checkGovRecord", paramsC); 
					int serialNumber = 0;
					String productNum = "";

					if (count == 1) { // 등록번호 있을 경우 +1 
					    coviMapperOne.update("user.govDoc.updateGovRecordSerial", paramsC);
					    serialNumber = (int)paramsC.get("SerialNumber");
					} else { // 등록번호 없을 경우 새로 insert
					    coviMapperOne.insert("user.govDoc.insertGovRecordSerial", paramsC);
					    serialNumber = (int)paramsC.get("SerialNumber");
					}
					productNum = "P-" + DeptCode + "-" + serialNumber; //생산(접수)등록번호
					if (divisionType.equals("COMPLETE")) {
						recordSeq = productNum; 
					}
					
				    CoviMap paramP = new CoviMap();
				    paramP.put("processID", processID);
				    CoviList mapObj = coviMapperOne.list("form.recorddocinfo.selectRecordDocInfo", paramP); // processID로 조회

				    if (!mapObj.isEmpty()) {
		                CoviMap gRecordDocInfo = (CoviMap) mapObj.get(0);
		                String sRecordClassNum = gRecordDocInfo.getString("RECORDCLASSNUM");
		                String sReleaseCheck = gRecordDocInfo.getString("RELEASECHECK");
		                String sKeepPeriod = gRecordDocInfo.getString("KEEPPERIOD");
		                String sSecureLevel = gRecordDocInfo.getString("SECURELEVEL");
		                String sSpecialRecord = gRecordDocInfo.getString("SPECIALRECORD");
		                String sRegistCheck = gRecordDocInfo.getString("REGISTCHECK");
						
			            params.clear();
			
			    		params.put("formInstID", formInstID);
			    		params.put("DrafterDeptID", DeptCode);			// 기록부서
			    		params.put("DrafterDeptName", DeptName);		// 기록부서명
			    		params.put("RegistCheck", sRegistCheck); 		// 전자기록물여부 (1:전자기록물, 2:비전자기록물)
			    		params.put("ProductDate", sProductDate); 		// 생산(접수)등록일자
			    		params.put("ProductNum", productNum);    		// 생산(접수)등록번호
			    		params.put("OldProductNum", docNumber);  		// 결재문서번호
			    		params.put("AttachNum", "00"); 			 		// 분리등록번호 00으로 고정
			    		params.put("RecordSubject", sTitle);     		// 결재문서 제목
			    		params.put("RecordPageCount", "000001"); 		// 쪽수 000001로 고정
			    		params.put("ApprovalName", (divisionType.equals("COMPLETE") ? approvalName : reapprovalName)); // 결재자
			    		params.put("ProposalName", (divisionType.equals("COMPLETE") ? DrafterName : reDrafterName));   // 기안자
			    		params.put("CompleteDate", sCompleteDate); 		// 완료일자 (시행일자)
			    		params.put("ReceiptName", (divisionType.equals("COMPLETE") ? ReceiptName : DrafterDeptName)); // 기안부서(생산) 완료 시 수신부서들, 수신부서(접수) 완료 시 기안부서 넣기
			    		params.put("DistNum", (divisionType.equals("COMPLETE") ? "" : serialNumber));    			  // 문서과배부번호
			    		params.put("RecordSeq", recordSeq); 			// 생산기관등록번호
			    		params.put("RecordCheck", "1"); 				// 전자기록물여부 1로 고정
			    		params.put("RecordClassNum", sRecordClassNum);  // 기록물철코드
			    		params.put("SpecialRecord", sSpecialRecord); 	// 특수기록물
			    		params.put("ReleaseCheck", sReleaseCheck); 		// 공개여부
			    		params.put("ReleaseRestriction", ""); 			// 부분공개 (미사용)
			    		params.put("KeepPeriod", sKeepPeriod);			// 보존기간
			    		params.put("ContentSummary", ""); 				// 내용요약		
			    		params.put("RecordType", ""); 					// 기록물형태
			    		params.put("RecordClass", "1"); 				// 기록물구분 1로 고정 (1:신, 2:구)
			    		params.put("ModifyCheck", "0"); 				// 수정여부 0으로 고정 
			    		params.put("RejectCheck", "0"); 				// 반려여부 0으로 고정  
			    		params.put("ApprovalDocLink", "/approval/approval_Form.do?mode=COMPLETE&processID="+processID+"&forminstanceID="+formInstID); // 결재문서 URL	    		
			    		params.put("SecureLevel", sSecureLevel);		// 열람범위
			    		params.put("DivisionType", divisionType);		// COMPLETE OR DISTCOMPLETE		    
			    		params.put("RowSeq", "1"); 						// 기록물 안번호(단건은 1고정) 
			    		params.put("RegisterID", (divisionType.equals("COMPLETE") ? DrafterID : reDrafterID)); // 등록자ID
			    		params.put("RecordFilePath", ""); 				// 첨부파일 정보
			    				
			    		coviMapperOne.insert("user.govDoc.insertRecordDoc", params); // GOV_RECORD_DOC INSERT
			    		
			    		params.clear();
						params.put("ProcessID", processID);
						params.put("FormInstID", formInstID);
				
						coviMapperOne.update("form.recorddocinfo.updateRecordDocState", params); // RECORD_DOC_INFO UPDATE STATE("P -> E")
						// I :기안시 저장(발신일때 processID없는 상태), P:기안시 저장 후 연동, E: 완료시 연동
				    	} 
					}
				} else if(apvMode.equals("DISTCOMPLETE")) { // process가 draft일경우 수신처 완료시 
					String divisionType = apvMode;
					
					String formInstID = spParams.getString("formInstID");
					String processID = spParams.getString("processID"); // draft process ID
					String approvalContext = spParams.getString("approvalContext");
					String docNumber = spParams.getString("docNumber");
					
					// 1. 결재문서 FormInstance 데이터 조회
		            CoviMap params = new CoviMap();
		    		params.put("formInstID", formInstID);

		    		params.put("processID", processID);
		    		CoviMap mainDocInfo = coviMapperOne.selectOne("form.formLoad.selectFormInstance", params); 
		    		String sTitle = mainDocInfo.getString("Subject");
		    		String DrafterDeptName = mainDocInfo.getString("InitiatorUnitName");
		    		if(docNumber.equals("")) {
		    			docNumber = mainDocInfo.getString("DocNo");
		    		}
		    		
		    		String recordSeq = ""; //생산기관등록번호	
		    		CoviMap prodInfo = coviMapperOne.selectOne("user.govDoc.selectOrgProductInfo", params);
		    		if(prodInfo != null) {
		    			recordSeq = prodInfo.getString("RecordSeq");
		    		}
					
		    		// 2. 결재선 조회
					String approvalName = ""; 	 // 결재자
					String reDrafterID = ""; 	 // 재기안자(업무담당자) ID
					String reDrafterName = "";   // 재기안자(업무담당자) 이름
					String receiptDeptID = ""; 	 // 수신부서코드
					String receiptDeptName = ""; // 수신부서이름
		
					int divisionIdx = 0;
					
					CoviMap approvalLine = CoviMap.fromObject(approvalContext);
					Object divisionObj = ((CoviMap)approvalLine.get("steps")).get("division");
					CoviList divisions = new CoviList();
					if(divisionObj instanceof CoviMap){
						CoviMap divisionJsonObj = (CoviMap)divisionObj;
						divisions.add(divisionJsonObj);
					} else {
						divisions = (CoviList)divisionObj;
						divisionIdx = divisions.size()-1;
					}
					
					if(divisions != null){
						CoviMap division = (CoviMap)divisions.get(divisionIdx);
						
						Object stepO = division.get("step");
						CoviList steps = new CoviList();
						if(stepO instanceof CoviMap){
							CoviMap stepJsonObj = (CoviMap)stepO;
							steps.add(stepJsonObj);
						} else {
							steps = (CoviList)stepO;
						}	
						
						if(steps != null){
							if(divisionIdx > 0) {
								reDrafterID = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("code");
								reDrafterName = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("name");
								receiptDeptID = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("oucode");
								receiptDeptName = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("ouname");
							}
							approvalName = steps.getJSONObject(steps.size()-1).getJSONObject("ou").getJSONObject("person").getString("name");
						}
					}
					
					// 3. 생산날짜 생성
		    		Date date = new Date();	    		
		    		SimpleDateFormat fmt = null;
		    		
		    		fmt = new SimpleDateFormat ("yyyyMMddHHmm");
		    		String sProductDate = fmt.format(date);
		    		fmt = new SimpleDateFormat ("yyyyMMdd");
		    		String sCompleteDate = fmt.format(date);
		    		
		            // 4. 등록대장에 insert 작업
					CoviList mapObj = coviMapperOne.list("form.recorddocinfo.selectRecordDocInfo", params); // processID로 조회

		            if (!mapObj.isEmpty()) {
		                CoviMap gRecordDocInfo = (CoviMap) mapObj.get(0);
		                String sPROCESSID = gRecordDocInfo.getString("PROCESSID");
		                String sRecordClassNum = gRecordDocInfo.getString("RECORDCLASSNUM");
		                String sReleaseCheck = gRecordDocInfo.getString("RELEASECHECK");
		                String sKeepPeriod = gRecordDocInfo.getString("KEEPPERIOD");
		                String sSecureLevel = gRecordDocInfo.getString("SECURELEVEL");
		                String sSpecialRecord = gRecordDocInfo.getString("SPECIALRECORD");
		                String sRegistCheck = gRecordDocInfo.getString("REGISTCHECK");
							            
						String fiscalYear = sCompleteDate.substring(0, 4);
			            
						Map<String, Object> paramsC = new HashMap<>();
						paramsC.put("registCheck", sRegistCheck);
						paramsC.put("fiscalYear", fiscalYear);
						paramsC.put("deptCode", receiptDeptID);
						
						int count = coviMapperOne.selectOne("user.govDoc.checkGovRecord", paramsC); // 등록번호 조회
						int serialNumber = 0;

						if (count == 1) { // 등록번호 있을 경우 +1 
						    coviMapperOne.update("user.govDoc.updateGovRecordSerial", paramsC);
						    serialNumber = (int)paramsC.get("SerialNumber");
						} else { // 등록번호 없을 경우 새로 insert
						    coviMapperOne.insert("user.govDoc.insertGovRecordSerial", paramsC);
						    serialNumber = (int)paramsC.get("SerialNumber");
						}
			
						String productNum = "P-" + receiptDeptID + "-" + serialNumber; //생산(접수)등록번호
			            
			            params.clear();
			
			    		params.put("formInstID", formInstID);
			            params.put("parentFormInstID", formInstID);
			    		params.put("DrafterDeptID", receiptDeptID); 	// 기록부서
			    		params.put("DrafterDeptName", receiptDeptName); // 기록부서명
			    		params.put("RegistCheck", sRegistCheck); 		// 전자기록물여부 (1:전자기록물, 2:비전자기록물)
			    		params.put("ProductDate", sProductDate); 		// 생산(접수)등록일자
			    		params.put("ProductNum", productNum);    		// 생산(접수)등록번호
			    		params.put("OldProductNum", docNumber);  		// 결재문서번호
			    		params.put("AttachNum", "00"); 			 		// 분리등록번호 00으로 고정
			    		params.put("RecordSubject", sTitle);     		// 결재문서 제목
			    		params.put("RecordPageCount", "000001"); 		// 쪽수 000001로 고정
			    		params.put("ApprovalName", approvalName); 		// 결재자
			    		params.put("ProposalName", reDrafterName); 		// 기안자
			    		params.put("CompleteDate", sCompleteDate); 		// 완료일자 (시행일자)
			    		params.put("ReceiptName", DrafterDeptName);	    // 수신부서(접수) 완료 시 기안부서
			    		params.put("DistNum", serialNumber);   		    // 문서과배부번호
			    		params.put("RecordSeq", recordSeq); 			// 생산기관등록번호
			    		params.put("RecordCheck", "1"); 				// 전자기록물여부 1로 고정
			    		params.put("RecordClassNum", sRecordClassNum);  // 기록물철코드
			    		params.put("SpecialRecord", sSpecialRecord); 	// 특수기록물
			    		params.put("ReleaseCheck", sReleaseCheck); 		// 공개여부
			    		params.put("ReleaseRestriction", ""); 			// 부분공개 (미사용)
			    		params.put("KeepPeriod", sKeepPeriod);			// 보존기간
			    		params.put("ContentSummary", ""); 			    // 내용요약 	
			    		params.put("RecordType", ""); 					// 기록물형태
			    		params.put("RecordClass", "1"); 				// 기록물구분 1로 고정 (1:신, 2:구)
			    		params.put("ModifyCheck", "0"); 				// 수정여부 0으로 고정  ->미사용
			    		params.put("RejectCheck", "0"); 				// 반려여부 0으로 고정 -> 미사용
			    		params.put("ApprovalDocLink", "/approval/approval_Form.do?mode=COMPLETE&processID="+sPROCESSID+"&forminstanceID="+formInstID); // 결재문서 URL	    		
			    		params.put("SecureLevel", sSecureLevel);		// 열람범위
			    		params.put("DivisionType", divisionType);		// COMPLETE OR DISTCOMPLETE		    
			    		params.put("RowSeq", "1"); 						// 기록물 안번호(단건은 1고정) 
			    		params.put("RegisterID", reDrafterID); // 등록자ID
			    		params.put("RecordFilePath", ""); 				// 첨부파일 정보
			    				
			    		coviMapperOne.insert("user.govDoc.insertRecordDoc", params); // GOV_RECORD_DOC INSERT
			    		
			    		params.clear();
						params.put("ProcessID", sPROCESSID);
						params.put("FormInstID", formInstID);
				
						coviMapperOne.update("form.recorddocinfo.updateRecordDocState", params); // RECORD_DOC_INFO UPDATE STATE("P -> E")
						// I :기안시 저장(발신일때 processID없는 상태), P:기안시 저장 후 연동, E: 완료시 연동
		            }
			}
		}
	}
		
	// Custom join function for CoviList
	private String join(CoviList list, String delimiter) {
	    StringBuilder result = new StringBuilder();
	    for (int i = 0; i < list.size(); i++) {
	        result.append(list.get(i));
	        if (i < list.size() - 1) {
	            result.append(delimiter);
	        }
	    }
	    return result.toString();
	}
	
	// 기록물 등록대장 등록(KIC 등록기준)
	@Override
	public void executeRecordDocInsert_KIC(CoviMap spParams) throws Exception {
		String apvMode = spParams.getString("apvMode"); 
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		
		if(apvMode.equals("COMPLETE") || apvMode.equals("DISTCOMPLETE")) {		
			String divisionType = apvMode;
			
			String formInstID = spParams.getString("formInstID");
			String processID = spParams.getString("processID");
			String approvalContext = spParams.getString("approvalContext");
			String docNumber = spParams.getString("docNumber");
			//String bodyContext = spParams.getString("bodyContext");
			
            CoviMap params = new CoviMap();
    		params.put("formInstID", formInstID);
    		params.put("processID", processID);

			String recordSeq = ""; //생산기관등록번호				
			if(apvMode.equals("DISTCOMPLETE")) {
	    		CoviMap prodInfo = coviMapperOne.selectOne("user.govDoc.selectProductInfo", params);
	    		if(prodInfo != null) {
	    			recordSeq = prodInfo.getString("RecordSeq");
	    		}
	    		
	    		CoviMap docNumInfo = coviMapperOne.selectOne("user.govDoc.selectDistDocNumber", params);
	    		if(docNumInfo != null) {
	    			docNumber = docNumInfo.getString("ReceiveNo");
	    		}
			}
    		
    		CoviMap mainDocInfo = coviMapperOne.selectOne("form.formLoad.selectFormInstance", params);

    		Date date = new Date();	    		
    		SimpleDateFormat fmt = null;
    		
    		fmt = new SimpleDateFormat ("yyyyMMddHHmm");
    		String sProductDate = fmt.format(date);
    		fmt = new SimpleDateFormat ("yyyyMMdd");
    		String sCompleteDate = fmt.format(date);
    		
    		String DrafterID = mainDocInfo.getString("InitiatorID");
    		String DrafterName = mainDocInfo.getString("InitiatorName");
    		String DrafterDeptID = mainDocInfo.getString("InitiatorUnitID");
    		String DrafterDeptName = mainDocInfo.getString("InitiatorUnitName");
    		if(docNumber.equals("")) {
    			docNumber = mainDocInfo.getString("DocNo");
    		}
			
			String approvalName = ""; //결재권자(직위/직급)
			String reDrafterID = ""; //재기안자(업무담당자) ID
			String reDrafterName = ""; //재기안자(업무담당자) 이름
			String receiptDeptID = ""; //수신부서 ID
			String receiptDeptName = ""; //수신부서 이름

			int divisionIdx = 0;
			
			CoviMap approvalLine = CoviMap.fromObject(approvalContext);
			Object divisionObj = ((CoviMap)approvalLine.get("steps")).get("division");
			CoviList divisions = new CoviList();
			if(divisionObj instanceof CoviMap){
				CoviMap divisionJsonObj = (CoviMap)divisionObj;
				divisions.add(divisionJsonObj);
			} else {
				divisions = (CoviList)divisionObj;
				divisionIdx = divisions.size()-1;
			}
			
			if(divisions != null){
				CoviMap division = (CoviMap)divisions.get(divisionIdx);
				
				Object stepO = division.get("step");
				CoviList steps = new CoviList();
				if(stepO instanceof CoviMap){
					CoviMap stepJsonObj = (CoviMap)stepO;
					steps.add(stepJsonObj);
				} else {
					steps = (CoviList)stepO;
				}	
				
				if(steps != null){
					if(divisionIdx > 0) {
						reDrafterID = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("code");
						reDrafterName = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("name");
						receiptDeptID = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("oucode");
						receiptDeptName = steps.getJSONObject(0).getJSONObject("ou").getJSONObject("person").getString("ouname");
					}
					approvalName = steps.getJSONObject(steps.size()-1).getJSONObject("ou").getJSONObject("person").getString("name");
				}
			}
			/*
			int sub_cnt = (int) coviMapperOne.getNumber("user.govDoc.selectHwpDocSubCnt", params);
			CoviList subDocInfoList =  new CoviList();
			if(sub_cnt > 0) {
				subDocInfoList = coviMapperOne.list("user.govDoc.selectHwpDocSubInfo", params);
			} else {
	    		params.put("processID", processID);
	    		params.put("deptCode", receiptDeptID);
				subDocInfoList = coviMapperOne.list("user.govDoc.selectDocTempInfo", params);
			}
    		
    		for(int i = 0; i < subDocInfoList.size(); i++) {
    			CoviMap docInfo = subDocInfoList.getMap(i);
                
    		}    
    		*/
            String sReceiptName = mainDocInfo.getString("ReceiveNames");
            String sReceiptOnlyName = "";
            if(apvMode.equals("COMPLETE") && sReceiptName != null && !sReceiptName.equals("")) { //기안부서 완료 시 수신부서명만 따로 저장
            	StringBuffer buf = new StringBuffer();
            	for(int j = 0; j < sReceiptName.split(";").length; j++) {
            		 buf.append(sReceiptName.split(";")[j].split(":")[2].split("\\^")[0]);
            		if(j < sReceiptName.split(";").length-1) buf.append(", ");
            	}
            	sReceiptOnlyName = buf.toString();
            }
            
            //String subject = bodyContext.getString("Subject");
            String subject = mainDocInfo.getString("Subject");
			String sTitle = mainDocInfo.getString("Subject");
			String sRegistCheck = "1";		// 등록구분 ( 1 : 일반문서 생산.발송,   2 : 일반문서 접수)
			String sKeepPeriod = mainDocInfo.getString("SaveTerm");
			if(sKeepPeriod.length() == 1) sKeepPeriod = "0" + sKeepPeriod;
			// 대외공개
			String sPublicAction = mainDocInfo.getString("PublicAction");
			// 비공개 사유
			String sSecurityOption = mainDocInfo.getString("SecurityOption");
			//String sSecurityOption1 = bodyContext.getString("SecurityOption1");
			// 전체문서함에  문서목록 공개범위
			String sInternalDisclosure = mainDocInfo.getString("InternalDisclosure");
			// 비공개 사유
			String sSecurityReason = bodyContext.getString("SecurityReasonText");
			// 비공개 기간
			String sSecurityPeriod = mainDocInfo.getString("SecurityPeriod");
			
			// 보안등급
			String sSecureLevel = "";
			sSecureLevel = ("".equals(sPublicAction)) ? "3" : sPublicAction;
			
//			JSONParser jsonParser = new JSONParser();
//	        CoviMap jsonObj = (CoviMap) jsonParser.parse("SecurityOption1");
			
			
			//JSONArray OptionArr = bodyContext.getJSONArray("SecurityOption1");
			CoviList OptionArr = new CoviList();
			if(sPublicAction.equals("3") && bodyContext.has("SecurityOption1")){
				if(bodyContext.getString("SecurityOption1").length() == 1) {
					OptionArr.add(bodyContext.getString("SecurityOption1"));
				}
				else {
					OptionArr = bodyContext.getJSONArray("SecurityOption1");
				}
			}
			
            StringBuilder tempReleaseCheck = new StringBuilder();
            int iTempVal = 0;
            boolean bCheck = false;
			// 체크 확인
			for(int k=0; k < 8; k++) {
				bCheck = false;
				
				for (int i = 0; i < OptionArr.size(); i++)
				{
					iTempVal = Integer.parseInt(OptionArr.get(i).toString());
					if(k+1 == iTempVal) {
						bCheck = true;
					}
				}
				
				tempReleaseCheck.append(bCheck ? "Y" : "N");
			}
			
			// 공개여부
            String sReleaseCheck = "";
            String sReleaseCheckDisclosure = "";
            if(sInternalDisclosure.equals("1")) sReleaseCheckDisclosure = "3";
            else if(sInternalDisclosure.equals("2")) sReleaseCheckDisclosure = "2";
            if(sInternalDisclosure.equals("3")) sReleaseCheckDisclosure = "1";
            
            sReleaseCheck = sReleaseCheckDisclosure + tempReleaseCheck.toString();
            
            // 공개제한부분표시
            String sReleaseRestriction = "";
            // 특수기록물
            String sSpecialRecord = "";
            
            // 단위업무 관련 저장
            // 단위업무 팝업창에서 선택한 분류번호
            String sRecordClassNum = ""; //bodyContext.getString("RECORD_CLASS_NUM");
            String sRecordSubject = "";	//bodyContext.getString("RECORD_SUBJECT");
            /*
            CoviMap RecordResultData	= new CoviMap();
			CoviMap Recordparams = new CoviMap();
					
			Recordparams.put("ProcessID", processID);
				*/
			
			//RecordResultData = selectTaskRecordInfo(Recordparams);
			
            sRecordClassNum = spParams.getString("RECORD_CLASS_NUM");
            sRecordSubject = spParams.getString("RECORD_SUBJECT");
			
			//sRecordClassNum = (RecordResultData.has("BUSINESSDATA9")) ? RecordResultData.getString("BUSINESSDATA9") : "";
			//sRecordSubject = (RecordResultData.has("BUSINESSDATA10")) ? RecordResultData.getString("BUSINESSDATA10") : "";
			
			if(sRecordClassNum.equals("")) {
				sRecordClassNum = (bodyContext.has("RECORD_CLASS_NUM")) ? bodyContext.getString("RECORD_CLASS_NUM") : "";
				sRecordSubject = (bodyContext.has("RECORD_SUBJECT")) ? bodyContext.getString("RECORD_SUBJECT") : "";
			}
            
            String sDivisionType = apvMode; //sRegistCheck.indexOf("접수") > -1 ? "접수" : "생산";
            //String sSubFiid = StringUtils.isEmpty(mainDocInfo.getString("FormInstID")) ? formInstID : docInfo.getString("MULTI_FORM_INST_ID");
            String sSubFiid = "";
            
			String fiscalYear = sCompleteDate.substring(0, 4);
            
            Map<String, Object> paramsC = new HashMap<>();
			paramsC.put("registCheck", sRegistCheck);
			paramsC.put("fiscalYear", fiscalYear);
			paramsC.put("deptCode", apvMode.equals("COMPLETE") ? DrafterDeptID : receiptDeptID);

    		coviMapperOne.insert("user.govDoc.insertGovRecordSerial", paramsC);
			String serialNumber = (String)paramsC.get("SerialNumber");

			String productNum = "I" + (apvMode.equals("COMPLETE") ? DrafterDeptID : receiptDeptID) + serialNumber; //생산(접수)등록번호
            
            params.clear();

    		params.put("formInstID", formInstID);
            if(apvMode.equals("DISTCOMPLETE")) {
        		params.put("parentFormInstID", formInstID);
            }
            params.put("DivisionType", divisionType);
    		params.put("DrafterID", (apvMode.equals("COMPLETE") ? DrafterID : reDrafterID));
    		params.put("DrafterName", (apvMode.equals("COMPLETE") ? DrafterName : reDrafterName));
    		params.put("DrafterDeptID", (apvMode.equals("COMPLETE") ? DrafterDeptID : receiptDeptID));
    		params.put("DrafterDeptName", (apvMode.equals("COMPLETE") ? DrafterDeptName : receiptDeptName));

    		params.put("RegistCheck", sRegistCheck);
    		params.put("ProductDate", sProductDate);
    		params.put("ProductNum", productNum);
    		params.put("OldProductNum", docNumber);
    		params.put("AttachNum", "00"); //분리등록번호 00으로 고정
    		params.put("RecordSubject", sTitle);
    		params.put("RecordPageCount", "000001"); //쪽수 000001로 고정
    		params.put("ApprovalName", approvalName);
    		params.put("ProposalName", (apvMode.equals("COMPLETE") ? DrafterName : reDrafterName));
    		params.put("CompleteDate", sCompleteDate);
    		params.put("ReceiptName", (apvMode.equals("COMPLETE") ? sReceiptOnlyName : DrafterDeptName)); //기안부서(생산) 완료 시 수신부서들, 수신부서(접수) 완료 시 기안부서 넣기
    		params.put("DistNum", (apvMode.equals("DISTCOMPLETE") ? serialNumber : ""));
    		params.put("RecordSeq", (apvMode.equals("COMPLETE") ? productNum : recordSeq));
    		params.put("RecordCheck", "1"); //전자기록물여부 1로 고정
    		params.put("RecordClassNum", sRecordClassNum);
    		params.put("SpecialRecord", sSpecialRecord);
    		params.put("ReleaseCheck", sReleaseCheck);
    		params.put("ReleaseRestriction", sReleaseRestriction);
    		params.put("SecureLevel", sSecureLevel);
    		params.put("KeepPeriod", sKeepPeriod);
    		params.put("ContentSummary", ""); //시청각기록물
    		params.put("RecordType", ""); //시청각기록물
    		params.put("RecordClass", "1"); //기록물구분 1로 고정
    		params.put("ModifyCheck", "0"); //수정여부 0으로 고정
    		params.put("RejectCheck", "0"); //반려여부 0으로 고정
    		params.put("ApprovalDocLink", "/approval/approval_Form.do?mode=COMPLETE&processID="+processID+"&forminstanceID="+formInstID);
    		params.put("RecordFilePath", ""); //TODO: 결재문서 파일로 저장
    		params.put("DivisionType", sDivisionType);
    		params.put("RegisterID", (apvMode.equals("COMPLETE") ? DrafterID : reDrafterID));

    		coviMapperOne.insert("user.govDoc.insertRecordDoc", params);
    		
		}
	}
	
	
	@Override
	public CoviMap selectRecordDocComboData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		String strListQuery = "";
		CoviList list = new CoviList();
		
		strListQuery = "user.govDoc.selectBaseCodeForRecordDoc";
		
		params.put("CodeGroup", "RecordDocSearchType");
		list = coviMapperOne.list(strListQuery, params);
		resultList.put("SearchTypeList", list);		
		
		params.put("CodeGroup", "RegistCheck");
		list = coviMapperOne.list(strListQuery, params);
		resultList.put("RegistCheckList", list);

		strListQuery = "user.govDoc.selectGFileListForRecordDoc";
		params.put("columnCode", "ProductYear");
		params.put("columnName", "ProductYear");
		list = coviMapperOne.list(strListQuery, params);
		resultList.put("ProductYearList", list);

		params.put("columnCode", "RecordDeptCode");
		params.put("columnName", "RecordProductName");
		list = coviMapperOne.list(strListQuery, params);
		resultList.put("RecordDeptList", list);
		
		// 단위업무
		strListQuery = "user.govDoc.selectRecordSeriesForRecordDoc";
		list = coviMapperOne.list(strListQuery, params);
		resultList.put("RecordSeriesList", list);
		
		// 기록물철
		strListQuery = "user.govDoc.selectRecordListForRecordDoc";
		list = coviMapperOne.list(strListQuery, params);
		resultList.put("RecordList", list);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectRecordDocList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		CoviList list = new CoviList();
		int cnt = (int) coviMapperOne.getNumber("user.govDoc.selectRecordDocListCnt", params);
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list = coviMapperOne.list("user.govDoc.selectRecordDocList", params);
			
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "RecordDocumentID,FormInstID,RecordSubject,ProductYear,RecordCheckName,DocSubject,ProductDate,ProductNum,OldProductNum,RecordProductName,ApprovalName,ProposalName,ReceiptName,FunctionName,RecordClassNum"));		
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap selectRecordDocListExcel(CoviMap params, String headerKey) throws Exception {
		CoviList list = coviMapperOne.list("user.govDoc.selectRecordDocListExcel", params);
		 
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, headerKey));
		 
		return resultList;
	}
	
	@Override
	public void deleteRecordDoc(CoviMap params) throws Exception {		
		coviMapperOne.update("user.govDoc.deleteRecordDoc", params);
	}
	
	@Override
	public void changeFileOfRecordDoc(CoviMap params) throws Exception {		
		coviMapperOne.update("user.govDoc.changeFileOfRecordDoc", params);
	}
	
	@Override
	public void saveDocTempInfo(CoviMap params) throws Exception {		
		int cnt = (int) coviMapperOne.getNumber("user.govDoc.selectDocTempCnt", params);
		if(cnt > 0) {
			coviMapperOne.update("user.govDoc.updateDocTempInfo", params);
		} else {
			coviMapperOne.insert("user.govDoc.insertDocTempInfo", params);
		}
	}

	@Override
	public CoviMap selectDocTempInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap map = coviMapperOne.select("user.govDoc.selectDocTempInfo", params);
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "MULTI_TITLE,MULTI_REGIST_CHECK,MULTI_RECORD_CLASS_NUM,MULTI_RECORD_SUBJECT,MULTI_ADDRESS,MULTI_SPECIAL_RECORD,MULTI_RELEASE_CHECK,MULTI_RELEASE_RESTRICTION,MULTI_KEEP_PERIOD,MULTI_SECURE_LEVEL"));
		return resultList;
	}	

	@Override
	public CoviMap selectRecordDocInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap map = coviMapperOne.select("user.govDoc.selectRecordDocInfo", params);
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "RECORDDEPTCODE,RECORDPRODUCTNAME,REGISTCHECK,REGISTCHECK_NAME,PRODUCTDATE,PRODUCTNUM,OLDPRODUCTNUM,ATTACHNUM,TITLE,RECORDPAGECOUNT,APPROVALNAME,PROPOSALNAME,COMPLETEDATE,RECEIPTNAME,DISTNUM,RECORDSEQ,RECORDCHECK,RECORDCHECK_NAME,RECORDCLASSNUM,RECORDSUBJECT,SPECIALRECORD,SPECIALRECORD_NAME,RELEASECHECK,RELEASECHECK_NAME,RELEASERESTRICTION,KEEPPERIOD,KEEPPERIOD_NAME,CONTENTSUMMARY,RECORDTYPE,RECORDCLASS,RECORDCLASS_NAME,MODIFYCHECK,MODIFYCHECK_NAME,REJECTCHECK,REJECTCHECK_NAME,APPROVALDOCLINK,RECORDFILEPATH,SECURELEVEL,SECURELEVEL_NAME,DIVISIONTYPE,FORMINSTID,PARENTFORMINSTID,DELETEDATE"));
		return resultList; 
	}

	@Override
	public void saveRecordDocInfo(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("user.govDoc.selectRecordDocCnt", params);
		if(cnt > 0) {
			coviMapperOne.update("user.govDoc.updateRecordDocInfo", params);
		} else {
			coviMapperOne.insert("user.govDoc.insertRecordDocInfo", params);
		}
	}
	
	public String doRecordAttachFileSave(List<MultipartFile> mf_record, String strOrgFileInfo, String strDelFileInfo) throws Exception{
		// 첨부파일 처리
		//CoviMap fileObj = new CoviMap();
		CoviList fileInfos = new CoviList();
		List<CoviMap> actionRecord_Attach = new ArrayList<CoviMap>();
		
		String objectID = "0";
		String serviceType = "Approval";
		String servicePath = "";
		String objectType = "DEPT";
		//String messageID = formObj.optString("FormInstID");
		String docMessageID = "0";
		boolean isClear = false;
		
		if(StringUtils.isNotBlank(strOrgFileInfo)) {
			CoviList ArrOrgFile = CoviList.fromObject(strOrgFileInfo);
            String[] delArr = strDelFileInfo.split("[|]");

			for(int j = 0; j < ArrOrgFile.size(); j++){
				CoviMap jObj = (CoviMap) ArrOrgFile.get(j);
				if( !Arrays.asList(delArr).contains(jObj.get("name")))
					actionRecord_Attach.add(jObj);
			}
		}
		
		if (mf_record != null && mf_record.size() > 0) {
			//fileObj = FileUtil.fileUpload(mf_record);
			fileInfos = fileUtilSvc.uploadToBack(null, mf_record, servicePath , serviceType, objectID, objectType, docMessageID, isClear);
			//fileInfos = fileObj.getJSONArray("fileInfos");
			
			for(int i=0; i<fileInfos.size(); i++) {
				CoviMap tmp = new CoviMap();
				tmp.put("id", ((CoviMap)fileInfos.get(i)).optString("FileID").trim());
				tmp.put("name", ((CoviMap)fileInfos.get(i)).optString("FileName"));
				tmp.put("savedname", ((CoviMap)fileInfos.get(i)).optString("SavedName"));
				tmp.put("size", ((CoviMap)fileInfos.get(i)).optString("Size"));
				
				actionRecord_Attach.add(tmp);
			}
		}
		
		return actionRecord_Attach.isEmpty() ? "" : actionRecord_Attach.toString();
	}
	
	@Override
	public CoviList selectExcelData(CoviMap params, String queryID) throws Exception {		
	
		return coviMapperOne.list(queryID, params);
	}	
	
	@Override
	public CoviMap selectGovSendHistory(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();		
		String strListQuery = "user.govDoc.";
		String strListCol="";
		
		if( "history,sendWait".contains( params.getString("govDocs") ) ) {
			strListQuery += "selectGovSendHistory";
			strListCol = "RNUM,UNIQUE_ID,FIRST_SEND_DT,REQ_SEND_CNT,STATUS,LAST_SEND_DT,SEND_ID,RESEND_REQ_CNT,RESEND_PROC_CNT,RESEND_FLAG,DOC_ID,ORG_NM,FORM_INST_ID,PROCESS_ID";			
		}		
		
		CoviList list = coviMapperOne.list(strListQuery,params);		
		int cnt = list.size() == 0 ? 0 : list.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,strListCol));		
		resultList.put("page", page);
		
		return resultList;
	}
	
	// 결재문서 프로세스ID로 TASK 정보(BUSINESSDATA9, 10 정보 가져오기)
	@Override
	public CoviMap selectTaskRecordInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap map = coviMapperOne.select("user.govDoc.selectTaskRecordInfo", params);
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "PROCESSID,BUSINESSDATA9,BUSINESSDATA10"));
		return resultList;
	}	
	
	//문서24 개인회신여부 및 FormInstID 누적 update 
	@Override
	public void updateReplyStatusInfo(CoviMap params) throws Exception {
		coviMapperOne.update("user.govDoc.updateReplyFlag", params);

	}

	// 기록물 분리
	@Override
	public int updateRecordDocSeparation(CoviMap params) throws Exception {		
		return coviMapperOne.update("user.govDoc.updateRecordDocSeparation", params);
	}
	
	// 발신처 관리
	@Override
	public CoviMap selectGovSenderMasterList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list1 = coviMapperOne.list("user.govDoc.selectGovSenderMasterList",params);
		String strListCol = "SEND_ID,SENDER_TYPE,DEPT_NAME,DISPLAY_NAME,OUNAME,NAME,CAMPAIGN_T,CAMPAIGN_F,HOMEPAGE,EMAIL,TEL,FAX,ZIP_CODE,ADDRESS,LOGO,SYMBOL,STAMP,USAGE_STATE,CREATE_DATE";
		
 		int cnt = 0;
		cnt = list1.size() == 0 ? 0 : list1.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list2 = coviMapperOne.list("user.govDoc.selectGovSenderMasterList",params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list2, strListCol));		
		resultList.put("page", page);
		return resultList;
	}
	
	@Override
	public CoviList selectGovSenderMaster(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.govDoc.selectGovSenderMaster",params);
		return list;
	}
	
	@Override
	public CoviList selectGovSenderMasterUpper(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.govDoc.getGovSenderMasterUpper",params);
		return list;
	}
	
	@Override
	public int insertSenderMasterData(CoviMap params) throws Exception {
		int result = coviMapperOne.insert("user.govDoc.insertSenderMasterData", params);
		return result;
	}
	
	@Override
	public int updateSenderMasterData(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.govDoc.updateSenderMasterData", params);
		return result;
	}
	
	@Override
	public int deleteSenderMasterData(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.govDoc.deleteSenderMasterData", params);
		return result;
	}
	/*
	@Override
	public int insertImgUploadData(CoviMap params) throws Exception {
		int result = coviMapperOne.insert("user.govDoc.insertImgUploadData", params);
		if(result > 0) {
			coviMapperOne.insert("user.govDoc.updateSenderMasterImgData", params);
		}
		return result;
	}
	*/
	@Override
	public int deleteImgUploadData(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.govDoc.updateSenderMasterImgData", params);
		return result;
	}
	
	@Override
	public int selectRecordAdmin(CoviMap params) throws Exception {
		int result = (int) coviMapperOne.getNumber("user.govDoc.selectRecordAdmin", params);
		return result;
	}
	
	@Override
	public int selectRecordDeptAdmin(CoviMap params) throws Exception {
		int result = (int) coviMapperOne.selectOne("user.govDoc.selectRecordDeptAdminCnt", params);
		return result;
	}
}
