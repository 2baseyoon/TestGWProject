package egovframework.covision.coviflow.form.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.form.service.NonApvProcessSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;




@Service("NonApvProcessSvc")
public class NonApvProcessSvcImpl extends EgovAbstractServiceImpl implements NonApvProcessSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Override
	public CoviMap getCirculationReadListData(CoviMap map) throws Exception {
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectCirculationReadListData", map);
		
		CoviMap circulationReadListObj = new CoviMap();

		circulationReadListObj.put("list",CoviSelectSet.coviSelectJSON(list, "ReadDate,Comment,Kind,SenderName,SenderID,ReceiptDate,UserCode,DeptName,UserName,ReceiptName,CirculationBoxID,ReceiptType"));
		return circulationReadListObj;
		
	}

	@Override
	public int deleteCirculationReadData(String circulationBoxID, String modID) throws Exception {		
		CoviMap map = new CoviMap();
		map.put("CirculationBoxID", circulationBoxID);
		map.put("ModID", modID);
		return coviMapperOne.update("form.nonApvProcess.updateCirculationReadData", map);
	}

	@Override
	public CoviMap getCirculationReadListDataStore(CoviMap map) throws Exception {
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectCirculationReadListDataStore", map);		
		CoviMap circulationReadListObj = new CoviMap();
		circulationReadListObj.put("list",CoviSelectSet.coviSelectJSON(list, "ReadDate,Comment,Kind,SenderName,SenderID,ReceiptDate,UserCode,DeptName,UserName,ReceiptName,CirculationBoxID,ReceiptType"));
		return circulationReadListObj;
		
	}

	@Override
	public int deleteCirculationReadDataStore(String circulationBoxID, String modID) throws Exception {		
		CoviMap map = new CoviMap();
		map.put("CirculationBoxID", circulationBoxID);
		map.put("ModID", modID);
		return coviMapperOne.update("form.nonApvProcess.updateCirculationReadDataStore", map);
	}
	
	@Override
	public CoviMap getHistoryListData(String fiid) throws Exception {
		CoviMap historyListObj = new CoviMap();
		CoviList historyListArr = new CoviList();
		CoviList historyListArrTemp = null;
		
		CoviMap map = new CoviMap();
		map.put("formInstID", fiid);
			
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectHistoryListData", map);
		historyListArrTemp = CoviSelectSet.coviSelectJSON(list, "Revision,ModDate,UR_Name,ModValue,FieldName");
		
		String changeDic = DicHelper.getDic("lbl_apv_change");
		
		//목록 표시 변수
		String sRevision = "";
		String temp = DicHelper.getDic("lbl_apv_writer"); // 기안자 
		String apvLinetemp = "";
		String bodytemp = "";
		String filetemp = "";
		String datetemp = "";
		int j = 1;
		for(int i = 0;i<historyListArrTemp.size();i++){
			CoviMap historyObj = historyListArrTemp.getJSONObject(i);
			CoviMap tempObj = new CoviMap();
			if(historyObj.getInt("Revision")==(j)){ //DB revision 1부터 시작
				sRevision = historyObj.getString("Revision");
				
				tempObj.put("Revision",sRevision);
				tempObj.put("sRevision",sRevision);
				tempObj.put("UR_Name",temp);
				tempObj.put("APST", apvLinetemp); //결재선
				tempObj.put("Contents", bodytemp); //결재 본문
				tempObj.put("ATTACH_FILE_INFO", filetemp); //첨부파일
				tempObj.put("ModDate", datetemp); //첨부파일
				
				historyListArr.add(tempObj);
				temp = historyObj.getString("UR_Name"); //변경날짜
				datetemp = historyObj.getString("ModDate"); //변경날짜
				
				j = j + 1;
				
				bodytemp = "";
                apvLinetemp = "";
                filetemp = "";
                bodytemp = "";
                
			}
			
			switch(historyObj.getString("FieldName")){
            	case "ApprovalLine":
            		break;
				case "isModApprovalLine":
	            	apvLinetemp = changeDic;
	                break;
	            case "AttachFileInfo":
	            case "FileInfos":
	            	filetemp = changeDic;
	                break;
	            default:
	            	bodytemp = changeDic;
	                break;
			}
		}
		
		if(!list.isEmpty()){
			CoviMap initiatorObj = new CoviMap();
			initiatorObj.put("Revision", 0);
			initiatorObj.put("sRevision", j);
			initiatorObj.put("ModDate", datetemp);
			initiatorObj.put("UR_Name", temp);
			initiatorObj.put("APST", apvLinetemp);
			initiatorObj.put("Contents", bodytemp);
			initiatorObj.put("ATTACH_FILE_INFO",filetemp);
			
			historyListArr.add(initiatorObj);
		}
		
		historyListObj.put("list",historyListArr);
		
		return historyListObj;
	}

	@Override
	public CoviMap getReceiptReadListData(CoviMap map) throws Exception {
		
		CoviMap receiptReadListObj = new CoviMap();
							
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectReceiptReadListData", map);
		receiptReadListObj.put("list",selectJSONForReceiptList(CoviSelectSet.coviSelectJSON(list,"ProcessID,WorkItemID,UserCode,UserName,WorkItemState,ProcessState,DocSubject,WorkItemFinished,BusinessState,DSCR,ProcessStarted,ProcessFinished,PerformerState,ChargeName,ActualKind")));
		
		return receiptReadListObj;
	}

	//workitemState 와 prcessState를 다국어 값으로 변경 ex).528->종료
	private CoviList selectJSONForReceiptList(CoviList jsonArray){
		
		CoviList returnList = new CoviList();
		
		//접수, 대기, 취소, 진행, 반려, 승인
		CoviMap dicCode = DicHelper.getDicAll("btn_apv_receipt;lbl_apv_inactive;btn_apv_cancel;lbl_apv_Processing;lbl_apv_reject;lbl_apv_Approved;lbl_apv_completed;").getJSONObject(0); //
		
		for (int i = 0; i < jsonArray.size(); i++) {
			CoviMap temp = jsonArray.getJSONObject(i);
			String resultState = "";
			if(temp.optString("PerformerState").equals("0")){
				resultState = dicCode.getString("btn_apv_cancel")+"/"+dicCode.getString("btn_apv_cancel");
			}
			else{
				switch(temp.getString("WorkItemState")){
				 case "528":
					 resultState = dicCode.getString("btn_apv_receipt");
					 break;
				 case "288":
					 resultState = dicCode.getString("lbl_apv_inactive");
					 break;
				 case "544":
				 case "545":
				 case "546":
					 resultState = dicCode.getString("btn_apv_cancel");
					 break;
				 default:
					 resultState = "";
				}
				
				switch(temp.getString("ProcessState")){
				 case "528":
					 resultState += "/" + dicCode.getString("lbl_apv_completed");
					 break;
				 case "288":
					 resultState += "/" + dicCode.getString("lbl_apv_Processing");
					 break;
				 case "544":
				 case "545":
				 case "546":
					 resultState += "/" + dicCode.getString("btn_apv_cancel");
					 break;
				 default:
					 resultState += "";
				}
			}
			
			if(temp.optString("BusinessState").substring(0,5).equals("02_02")){
				temp.put("BusinessStateName", dicCode.getString("lbl_apv_reject")); //반려
			}else if(temp.optString("BusinessState").substring(0,5).equals("02_01")){
				temp.put("BusinessStateName", dicCode.getString("lbl_apv_Approved")); //승인
			}else{
				temp.put("BusinessStateName", ""); //승인
			}
			
			// 타임존 처리
			if(temp.containsKey("WorkItemFinished")){
				temp.put("WorkItemFinished", ComUtils.TransDateLocalFormat(temp.getString("WorkItemFinished"), ComUtils.UR_DateFullFormat));
			}
			if(temp.containsKey("ProcessStarted")){
				temp.put("ProcessStarted", ComUtils.TransDateLocalFormat(temp.getString("ProcessStarted"), ComUtils.UR_DateFullFormat));
			}
			if(temp.containsKey("ProcessFinished")){
				temp.put("ProcessFinished", ComUtils.TransDateLocalFormat(temp.getString("ProcessFinished"), ComUtils.UR_DateFullFormat));
			}
			
			temp.put("stateName", resultState);
			returnList.add(temp);
		}
		
		return returnList;
	}
	
	@Override
	public String getParentProcessID1(String processID, String fiid) throws Exception {
		
		CoviMap map = new CoviMap();
		
		map.put("ProcessID", processID);
		map.put("fiid", fiid);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.getParentProcessID1", map);
		
		if(!list.isEmpty())	
			return list.getMap(0).getString("ParentProcessID");
		else
			return null;
	}

	@Override
	public String getParentProcessID2(String processID, String fiid) throws Exception {
		
		CoviMap map = new CoviMap();
		
		map.put("ProcessID", processID);
		map.put("fiid", fiid);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.getParentProcessID2", map);
		
		if(!list.isEmpty())	
			return list.getMap(0).getString("ParentProcessID");
		else
			return null;
	}

	@Override
	public CoviMap getReceiptReadListDataExcel(String processID1, String processID2, String selectKey) throws Exception {
		CoviMap receiptReadListObj = new CoviMap();
		
		CoviMap map = new CoviMap();		
		map.put("ProcessID1", processID1);
		map.put("ProcessID2", processID2);	
						
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectReceiptReadListData", map);

		receiptReadListObj.put("list",CoviSelectSet.coviSelectJSON(list, selectKey));
		return receiptReadListObj;
	}

	@Override
	public CoviMap getExistingCirculationList(String fiid, String kind) throws Exception {
		
		CoviMap existingCirculationListObj = new CoviMap();
		
		CoviMap map = new CoviMap();
		map.put("fiid", fiid);
		map.put("kind", kind);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.SelectExistingCirculationList", map);
		existingCirculationListObj.put("list",CoviSelectSet.coviSelectJSON
				(list, "ReceiptDate,SenderName,SenderID,FormInstID,Subject,ReadDate,ProcessID,ReceiptID,ReceiptName,Kind,Comment,ReceiptType,DeptID,DeptName"));

		return existingCirculationListObj;
	}

	@Override
	public CoviMap getExistingCirculationListStored(String fiid, String kind) throws Exception {
		
		CoviMap existingCirculationListObj = new CoviMap();
		
		CoviMap map = new CoviMap();
		map.put("fiid", fiid);
		map.put("kind", kind);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.SelectExistingCirculationListStored", map);
		existingCirculationListObj.put("list",CoviSelectSet.coviSelectJSON
				(list, "ReceiptDate,SenderName,SenderID,FormInstID,Subject,ReadDate,ProcessID,ReceiptID,ReceiptName,Kind,Comment,ReceiptType,DeptID,DeptName"));

		return existingCirculationListObj;
	}

	@Override
	public int setCirculation(CoviMap circulationDataObj) throws Exception {				
		return coviMapperOne.insert("form.nonApvProcess.InsertCirculationBox", circulationDataObj);
	}

	@Override
	public int setCirculationStored(CoviMap circulationDataObj) throws Exception {				
		return coviMapperOne.insert("form.nonApvProcess.InsertCirculationBoxStored", circulationDataObj);
	}

	@Override
	public int setCirculationDescription(CoviMap circulationDataObj) throws Exception {
		return coviMapperOne.insert("form.nonApvProcess.InsertCirculationBoxDescription", circulationDataObj);
	}

	@Override
	public int setCirculationDescriptionStored(CoviMap circulationDataObj) throws Exception {
		return coviMapperOne.insert("form.nonApvProcess.InsertCirculationBoxDescriptionStored", circulationDataObj);
	}

	@Override
	public CoviMap getHistoryModifiedData(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap temp = new CoviMap();
		CoviList changNameArray = new CoviList();
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectHistoryModifiedData", params);
		
		changNameArray = CoviSelectSet.coviSelectJSON(list, "Revision,FieldName,ModValue");
		
		for(int i = 0;i<changNameArray.size(); i++){
			String fieldName = changNameArray.getJSONObject(i).getString("FieldName");
			
			switch(fieldName){
			
			case "BodyContext":
			case "BodyData":
				changNameArray.getJSONObject(i).putOrigin("ModValue",new String(Base64.decodeBase64(changNameArray.getJSONObject(i).optString("ModValue").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
				break;
			case "ApprovalLine":
				break;
			case "FileInfos":
			case "AttachFileInfo":
				if(!changNameArray.getJSONObject(i).optString("ModValue").equals("")){
					CoviList fileInfos = CoviMap.fromObject(new String(Base64.decodeBase64(changNameArray.getJSONObject(i).optString("ModValue").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8)).getJSONArray("FileInfos");
					changNameArray.getJSONObject(i).put("ModValue",fileInfos);
				}
				else
					changNameArray.getJSONObject(i).put("ModValue","");
				
				break;
			default:
				changNameArray.getJSONObject(i).put("FieldName", "FormInstanceInfo."+fieldName);
			}
		}
		temp.put("Table", changNameArray);
		returnList.put("list",temp);
		return returnList;
	}
	
	// 추가 의견 등록
	@Override
	public int insertComment(CoviMap params) throws Exception {
		//IsComment를 Y로 변경
		coviMapperOne.update("form.comment.updateIsComment", params);
		
		return coviMapperOne.insert("form.comment.insert",params);
	}		
	
	public void setCommentMessage(CoviMap formObj) throws Exception {
		CoviList receivers = new CoviList();
		CoviList messageInfos = new CoviList();

		String status = "";
		String type = formObj.getString("type");
		String kind = formObj.getString("kind");
		String taskId = formObj.has("taskId") ? formObj.getString("taskId") : "";
		String formInstId = formObj.getString("formInstId");
		
		receivers = formObj.getJSONArray("receivers");
		
		if(kind.equalsIgnoreCase("lastapprove")) {
			status = "COMMENT";
		} else {
			status = "REDRAFT_WITHDRAW_COMMENT";
		}
		
		if(!receivers.isEmpty()) {
			for(int idx = 0; idx < receivers.size(); idx ++) {
				CoviMap messageInfo = new CoviMap();
				
				CoviMap receiver = receivers.getJSONObject(idx);
				
				messageInfo.put("UserId", receiver.getString("UserId"));
				messageInfo.put("Subject", receiver.getString("Subject"));
				messageInfo.put("Initiator", receiver.getString("Initiator"));
				messageInfo.put("Status", status); 
				messageInfo.put("ProcessId", receiver.getString("ProcessId")); 
				messageInfo.put("WorkitemId", receiver.getString("WorkitemId"));
				messageInfo.put("FormInstId", receiver.getString("FormInstId"));
				messageInfo.put("FormName", receiver.getString("FormName"));
				messageInfo.put("Type", "UR");
				
				messageInfo.put("ApproveCode", SessionHelper.getSession("USERID"));
				messageInfo.put("SenderID", SessionHelper.getSession("USERID"));
				
				messageInfo.put("Comment", ComUtils.RemoveScriptAndStyle(formObj.getString("comment")));
				
				messageInfos.add(messageInfo);
			}
		} else if(type.equalsIgnoreCase("ALL")) {
			CoviMap params = new CoviMap();
			
			params.put("TaskID", taskId);
			params.put("FormInstID", formInstId);
			
			CoviList list = coviMapperOne.list("form.comment.selectCommentMessage", params);
			receivers = CoviSelectSet.coviSelectJSON(list, "UserCode,DeputyID,WorkItemID,ProcessID,Subject,FormName,InitiatorID");

			for(int idx = 0; idx < receivers.size(); idx ++) {
				CoviMap messageInfo = new CoviMap();
				
				CoviMap receiver = receivers.getJSONObject(idx);
				
				messageInfo.put("UserId", receiver.getString("UserCode"));
				messageInfo.put("Subject", receiver.getString("Subject"));
				messageInfo.put("Initiator", receiver.getString("InitiatorID"));
				messageInfo.put("Status", status); 
				messageInfo.put("ProcessId", receiver.getString("ProcessID")); 
				messageInfo.put("WorkitemId", receiver.getString("WorkItemID"));
				messageInfo.put("FormInstId", formInstId);
				messageInfo.put("FormName", receiver.getString("FormName"));
				messageInfo.put("Type", "UR");
				
				messageInfo.put("ApproveCode", SessionHelper.getSession("USERID"));
				messageInfo.put("SenderID", SessionHelper.getSession("USERID"));
				
				messageInfo.put("Comment", ComUtils.RemoveScriptAndStyle(formObj.getString("comment")));
				
				messageInfos.add(messageInfo);
				
				if(receiver.getString("DeputyID") != null && !receiver.optString("DeputyID").equals("")) {
					messageInfo.put("UserId", receiver.getString("DeputyID"));
					
					messageInfos.add(messageInfo);
				}
			}
		}
		
		// 알림발송
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") +	"/approval"; 
		String httpCommURL = approvalURL + "/legacy/setmessage.do";
		
		if(!messageInfos.isEmpty()) {
			CoviMap params2 = new CoviMap(); 
			params2.put("MessageInfo",  messageInfos);

			HttpsUtil httpsUtil = new HttpsUtil();
			httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8",  null);	
		}
	}
	
	public String doCommentAttachFileSave(List<MultipartFile> commentAttachFiles) throws Exception{
		// 첨부파일 처리
		//CoviMap fileObj = new CoviMap();
		CoviList fileInfos = new CoviList();
		List<CoviMap> savedCommentAttachFiles = new ArrayList<>();
		
		String objectID = "0";
		String serviceType = "Approval";
		String servicePath = "";
		String objectType = "DEPT";
		//String messageID = formObj.optString("FormInstID");
		String commentMessageID = "0";
		boolean isClear = false;
		
		if (commentAttachFiles != null && !commentAttachFiles.isEmpty()) {
			//fileObj = FileUtil.fileUpload(commentAttachFiles);					// 양식 첨부파일에서 MessageID는 FormInstanceID
			fileInfos = fileUtilSvc.uploadToBack(null, commentAttachFiles, servicePath , serviceType, objectID, objectType, commentMessageID, isClear);
			//fileInfos = fileObj.getJSONArray("fileInfos");
			
			for(int i=0; i<fileInfos.size(); i++) {
				CoviMap tmp = new CoviMap();
				tmp.put("id", ((CoviMap)fileInfos.get(i)).optString("FileID").trim());
				tmp.put("name", ((CoviMap)fileInfos.get(i)).optString("FileName"));
				tmp.put("savedname", ((CoviMap)fileInfos.get(i)).optString("SavedName"));
				
				savedCommentAttachFiles.add(tmp);
			}
		}
		
		return savedCommentAttachFiles.toString();
	}
	
	@Override
	public CoviMap getSeriesListData(CoviMap params) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("form.nonApvProcess.selectSeriesListDataCnt", params);
		
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectSeriesListData", params);
		returnObj.put("list",CoviSelectSet.coviSelectJSON(list, "LFCode,LFName,MFCode,MFName,SFCode,SFName,SeriesCode,SeriesName,SeriesDescription,functionlevel1,functionlevel2,functionlevel3"));
		returnObj.put("page", page);

		return returnObj;
	}
	
	@Override
	public List<Object> selectArrayProc(String formInstID) throws Exception {
		List<Object> list = coviMapperOne.selectList("user.govDoc.selectArrayProc", formInstID);
		return list;
	}
	
	@Override
	public CoviMap getRecordListData(CoviMap params) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("form.nonApvProcess.selectRecordListDataCnt", params);
		
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectRecordListData", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(list, "RecordClassNum,RecordDeptCode,ProductYear,EndYear,RecordSeq,RecordCount,RecordSubject,RecordType,RecordTypeName,KeepPeriod,KeepPeriodName,KeepMethod,KeepMethodName,KeepPlace,KeepPlaceName,WorkCharger,RecordClass,RecordClassName,RecordFileCode,SeriesPath"));
		returnObj.put("page", page);

		return returnObj;
	}
	
	@Override
	public CoviMap getFavRecordListData(CoviMap params) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		params.put("UserCode", SessionHelper.getSession("USERID"));
		
		int cnt = (int) coviMapperOne.getNumber("form.nonApvProcess.selectFavRecordListDataCnt", params);
		
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectFavRecordListData", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(list, "RecordClassNum,RecordDeptCode,ProductYear,EndYear,RecordSeq,RecordCount,RecordSubject,RecordType,RecordTypeName,KeepPeriod,KeepPeriodName,KeepMethod,KeepMethodName,KeepPlace,KeepPlaceName,WorkCharger,RecordClass,RecordClassName,RecordFileCode,SeriesPath"));
		returnObj.put("page", page);

		return returnObj;
	}

	@Override
	public int toggleRecordFav(CoviMap params) throws Exception {		
		int returnValue = 0;
		
		String[] arrRecordClassNum = params.getString("RecordClassNum").split(",");
		String action = params.getString("action");
		
		for(int i = 0; i < arrRecordClassNum.length; i++) {
			if(!arrRecordClassNum[i].equals("")) {
				params.put("RecordClassNum", arrRecordClassNum[i]);
				 if(action.equals("I")) {
					returnValue = coviMapperOne.insert("form.nonApvProcess.insertRecordFav", params);
				} else if(action.equals("D")) {
					returnValue = coviMapperOne.delete("form.nonApvProcess.deleteRecordFav", params);
				}
			}
		}
		
		return returnValue;
	}

	@Override
	public CoviMap getFormInfoListStore(String fiid) throws Exception {
		
		CoviMap map = new CoviMap();
		map.put("fiid", fiid);
		CoviList list = coviMapperOne.list("form.nonApvProcess.SelectFormInfoStored", map);
		
		CoviMap circulationReadListObj = new CoviMap();

		circulationReadListObj.put("list",CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,InitiatorID,FormID,FormPrefix,FormName,FormSubject,IsSecureDoc,IsFile,DocNo,Reserved2"));
		return circulationReadListObj;
		
	}
	
	@Override
	public int getExistingCirculationCnt(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("form.nonApvProcess.selectExistingCirculationCnt", params);
	}

	@Override
	public int getExistingCirculationStoreCnt(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("form.nonApvProcess.selectExistingCirculationStoreCnt", params);
	}
	
	@Override
	public int selectCirculationAuth(CoviMap params) {
		return (int) coviMapperOne.getNumber("form.nonApvProcess.selectCirculationAuth", params);
	}	
	
	@Override
	public boolean getRecordDocAuthData(CoviMap params) throws Exception {
		boolean isAuth = false;
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectRecordDocAuthData", params);
		if (list.size() > 0) {
			String secureLevel = list.getJSONObject(0).getString("SECURELEVEL"); // 기록물 보안등급
			String securityLevel = list.getJSONObject(0).getString("SECURITYLEVEL"); // 사용자 보안등급

			try {
				int secureLevelInt = Integer.parseInt(secureLevel);
				int securityLevelInt = Integer.parseInt(securityLevel);
				
				// 기록물 보안등급 보다 사용자 보안등급 숫자가 낮아야 권한이 있음.
				if (secureLevelInt >= securityLevelInt) {
					isAuth = true;
				}
			} catch (NullPointerException npE) {
				// 권한 값이 숫자가 아닌경우는 문자열 비교처리.
				if (secureLevel.equalsIgnoreCase(securityLevel)) {
					isAuth = true;
				}
			} catch (Exception ex) {
				// 권한 값이 숫자가 아닌경우는 문자열 비교처리.
				if (secureLevel.equalsIgnoreCase(securityLevel)) {
					isAuth = true;
				}
			}
		}
		return isAuth;
	}
	
	@Override
	public int insertRecordDocRead(CoviMap params) throws Exception {
		int result = 0;
		int cnt = (coviMapperOne.select("form.nonApvProcess.selectRecordDocReadCnt", params)).getInt("CNT");

		if(cnt == 0)
			result = coviMapperOne.insert("form.nonApvProcess.insertRecordDocRead",params);
		return result;
	}

	@Override
	public CoviMap getRecordDocReaderListData(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("form.nonApvProcess.selectRecordDocReaderListDataCnt", params);
		
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("form.nonApvProcess.selectRecordDocReaderListData", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(list, "UserName,UserCode,DeptName,PositionName,TitleName,LevelName,ReadDate"));
		returnObj.put("page", page);

		return returnObj;
	}
	
	@Override
	public String getOriginWorkItemID(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("form.workitem.selectOriginWorkItemID", params);
	}
	
	@Override
	public int selectTotalSearch(CoviMap params) {
		int result = coviMapperOne.update("form.nonApvProcess.selectTotalSearch", params);
		return result;
	}
}
