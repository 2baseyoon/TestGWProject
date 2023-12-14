package egovframework.covision.coviflow.govdocs.service.impl;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.service.ApprovalGovDocSvc;
import egovframework.covision.coviflow.govdocs.service.OpenDocSvc;
import egovframework.covision.coviflow.govdocs.util.AsyncTaskOpenDocConverter;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service
public class OpenDocSvcImpl extends EgovAbstractServiceImpl  implements OpenDocSvc {
	@Resource(name = "asyncTaskOpenDocConverter")
	private AsyncTaskOpenDocConverter asyncTaskOpenDocConverter;
	
	@Resource
	CoviMapperOne coviMapperOne;
	
	Logger LOGGER = LogManager.getLogger(OpenDocSvcImpl.class);
	/**
	 * 원문공개 연계정보 가공/입력
	 */
	@Override
	public void insertOpenDocInfo(CoviMap spParams) throws Exception {
		String apvMode = spParams.getString("apvMode"); 
		//CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		CoviMap bodyContext = new CoviMap();
		
		if(apvMode.equals("COMPLETE") || apvMode.equals("DISTCOMPLETE")) {
			String formInstID = spParams.getString("formInstID");
			String processID = spParams.getString("processID");
			String approvalContext = spParams.getString("approvalContext");
			String docNumber = spParams.getString("docNumber");
			
            CoviMap params = new CoviMap();
    		params.put("formInstID", formInstID);
    		params.put("processID", processID);

			if(apvMode.equals("DISTCOMPLETE")) {
	    		CoviMap docNumInfo = coviMapperOne.selectOne("user.govDoc.selectDistDocNumber", params);
	    		if(docNumInfo != null) {
	    			docNumber = docNumInfo.getString("ReceiveNo");
	    		}
			}
    		
    		CoviMap mainDocInfo = coviMapperOne.selectOne("form.formLoad.selectFormInstance", params);
    		bodyContext = CoviMap.fromObject(new String(Base64.decodeBase64(mainDocInfo.getString("BodyContext")), StandardCharsets.UTF_8));
//    		bodyContext = CoviMap.fromObject(Base64.decodeBase64(mainDocInfo.getString("BodyContext")));
    		
    		Date date = new Date();	    		
    		String DrafterID = mainDocInfo.getString("InitiatorID");
    		String DrafterName = mainDocInfo.getString("InitiatorName");
    		String DrafterDeptID = mainDocInfo.getString("InitiatorUnitID");
    		String DrafterDeptName = mainDocInfo.getString("InitiatorUnitName");
    		if(docNumber.equals("")) {
    			docNumber = mainDocInfo.getString("DocNo");
    		}
			
			String approvalName = ""; //결재권자(직위/직급)
			String approverPosisionName = ""; //결재권자(직위/직급)
			
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
					approverPosisionName = steps.getJSONObject(steps.size()-1).getJSONObject("ou").getJSONObject("person").getString("position");
				}
			}
			approvalName = DicHelper.getDicInfo(approvalName, "ko");
			approverPosisionName = DicHelper.getDicInfo(approverPosisionName, "ko");
            String subject = mainDocInfo.getString("Subject");
			String sKeepPeriod = mainDocInfo.getString("SaveTerm");
			if(sKeepPeriod.length()  == 1) sKeepPeriod = "0" + sKeepPeriod;

			// 공개
			String sPublication = bodyContext.getString("Publication");
			// 보안등급
			String sSecureLevel = "";
			sSecureLevel = ("".equals(sPublication)) ? "3" : sPublication;
			
			CoviList optionArr = new CoviList();
			if(sPublication.equals("3") && bodyContext.has("SecurityOption1")){
				if(bodyContext.getString("SecurityOption1").length() == 1) {
					optionArr.add(bodyContext.getString("SecurityOption1"));
				}
				else {
					optionArr = bodyContext.getJSONArray("SecurityOption1");
				}
			}
			
            StringBuilder tempReleaseCheck = new StringBuilder();
            int iTempVal = 0;
            boolean bCheck = false;
			// 체크 확인
			for(int k=0; k < 8; k++) {
				bCheck = false;
				
				for (int i = 0; i < optionArr.size(); i++)
				{
					iTempVal = Integer.parseInt(optionArr.get(i).toString());
					if(k+1 == iTempVal) {
						bCheck = true;
					}
				}
				
				tempReleaseCheck.append(bCheck ? "Y" : "N");
			}
			
			// 공개여부
            String sReleaseCheck = "";
            sReleaseCheck = sSecureLevel + tempReleaseCheck.toString();
            
            params.clear();
    		params.put("DOC_MNGE_CARD_ID", formInstID);//문서고유번호
    		params.put("UNIT_TASK_ID", "");
    		params.put("MNGE_TASK_ID", "");
    		params.put("UNIT_TASK_NM", "");
    		params.put("MNGE_TASK_NM", "");
    		params.put("UNIT_TASK_CARD_NM", "");
    		params.put("MNGE_TASK_CARD_NM", "");
    		params.put("SJ", subject);//문서제목(필수)
    		params.put("DOC_OBJET_DTLS", "");
    		params.put("CREAT_DT", new SimpleDateFormat ("yyyyMMddhhmmss").format(date));//생산일자(필수) - 14bytes
    		params.put("NST_CD", ComUtils.getProperties("govdocs.properties").getProperty("opendoc.sendOrgCode"));//기관코드(필수)
    		params.put("NST_NM", ComUtils.getProperties("govdocs.properties").getProperty("opendoc.sendOrgName"));//기관명(필수)
    		params.put("DEPT_CD", DrafterDeptID);//부서코드(필수)
    		params.put("DEPT_NM", DrafterDeptName);//부서명(필수)
    		params.put("REPORTR_NMPN", DrafterName);//보고자성명(필수) - 기안자
    		params.put("DOC_NO", "");//문서번호(ID?)
    		params.put("DOC_NO_NM", docNumber);//문서번호명(필수)
    		params.put("PRSRV_PD_NUM", sKeepPeriod);//보존기간수, (01:1년,03:3년,05:5년,10:10년,25:30년,30:준영구,40:영구)(필수)
    		params.put("OPP_YN", sReleaseCheck);//공개여부(필수), 1NNNNNNNNN....
    		// FIXME
    		params.put("CLSDR_BASIS_DC", "-");//비공개근거내역(필수)
    		params.put("CLSDR_RESN_DC", "-");//비공개사유내역(필수)
    		
    		params.put("RCEPT_DOC_NO", "");//접수문서번호
    		params.put("DOC_RGST_SE_CD", "01");//문서등록구분코드
    		params.put("OPERTN_DOC_NO", "");//시행문서번호
    		params.put("OPERTN_DOC_SJ", "");//시행문서제목
    		params.put("LIST_OPP_YN", "Y");//목록공개여부(필수), Y/N ???
    		params.put("INFO_TY_CD", "01");//정보유형코드, 01:전자결재, 02:
    		params.put("NEW_UPDT_SE_CD", "NEW");//신규,수정 구분 (NEW,UPD)
    		params.put("LAST_SNCTR_NMPN", approvalName);//최종결재자명(필수)
    		params.put("LAST_SNCTR_OFPS_CLSF_NM", approverPosisionName);//최종결재자직위직급(필수)
    		params.put("REDG_LMTT_END_YMD", new SimpleDateFormat ("yyyyMMdd").format(date));//열람제한종료일자(필수), yyyyMMdd
    		params.put("RCORD_WATERSEASN_ID", "");//기록물철ID
    		params.put("RCEPT_RGST_NO", "");//접수등록번호
    		params.put("DOC_HOLD_SYS_CD", "01");//문서보유시스템코드(필수)
    		// 추가파라미터
    		params.put("PROCESSID", processID);
    		params.put("APPROVALCONTEXT", approvalContext);
    		params.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_READY);//전송상태
    		params.put("REGISTUSERCODE", "SYSTEM");
    		
    		coviMapperOne.insert("user.govDoc.openDoc.insertGovOpenDocMaster", params);
    		// 파일은 PDF  변환후 일괄 입력.
    		
    		TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
				@Override
				public void afterCommit() {
					try {
						// 시행문 변환 및  PDF변환 실행 (비동기 Background)
						asyncTaskOpenDocConverter.executeOpenDocConvert(spParams);
					}catch(IOException ioe) {
						LOGGER.error(ioe.getLocalizedMessage(), ioe); 
					}catch (NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch (Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			});
		}
	}

	/**
	 * @param : @param params
	 * @Method : selectOpenDocList
	 * 원문공개 마스터 목록 조회
	 */
	@Override
	public CoviMap selectOpenDocList(CoviMap params) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = coviMapperOne.list("user.govDoc.openDoc.selectGovOpenDocMaster", params);
		
 		int cnt = 0; 		
		cnt = list.isEmpty() ? 0 : list.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));		
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap updateOpenDocInfo(CoviMap params) throws Exception {
		// 완료문서 편집시 문서공개 범위가 변경되었을 수 있으므로 원문공개 마스터에 정보를 갱신한다.
		// 변경범위 : 본문, 제목, 공개여부, 보존년한
		CoviMap mainDocInfo = coviMapperOne.selectOne("form.formLoad.selectFormInstance", params);
		String sBodyContext = new String(Base64.decodeBase64(mainDocInfo.getString("BodyContext")), StandardCharsets.UTF_8);
		CoviMap bodyContext = CoviMap.fromObject(sBodyContext);
		
		String sKeepPeriod = mainDocInfo.getString("SaveTerm");
		if(sKeepPeriod.length()  == 1) sKeepPeriod = "0" + sKeepPeriod;

		// 공개
		String sPublication = bodyContext.optString("Publication");
		// 보안등급
		String sSecureLevel = (sPublication.isEmpty()) ? "3" : sPublication;
		
		CoviList optionArr = new CoviList();
		if(sPublication.equals("3") && bodyContext.has("SecurityOption1")){
			if(bodyContext.getString("SecurityOption1").length() == 1) {
				optionArr.add(bodyContext.getString("SecurityOption1"));
			}
			else {
				optionArr = bodyContext.getJSONArray("SecurityOption1");
			}
		}
		
        StringBuilder tempReleaseCheck = new StringBuilder();
        int iTempVal = 0;
        boolean bCheck = false;
		// 체크 확인
		for(int k=0; k < 8; k++) {
			bCheck = false;
			for (int i = 0; i < optionArr.size(); i++){
				iTempVal = Integer.parseInt(optionArr.get(i).toString());
				if(k+1 == iTempVal) {
					bCheck = true;
				}
			}
			
			tempReleaseCheck.append(bCheck ? "Y" : "N");
		}
		
		// 공개여부
        String sReleaseCheck = sSecureLevel + tempReleaseCheck.toString();
        
        params.clear();
        String formInstID = mainDocInfo.getString("FormInstID");
        String subject = mainDocInfo.getString("Subject");
        params.put("DOC_MNGE_CARD_ID", formInstID);//문서고유번호
        params.put("SJ", subject);//문서제목(필수)
		params.put("PRSRV_PD_NUM", sKeepPeriod);//보존기간수, (01:1년,03:3년,05:5년,10:10년,25:30년,30:준영구,40:영구)(필수)
		params.put("OPP_YN", sReleaseCheck);//공개여부(필수), 1NNNNNNNNN....
		params.put("NEW_UPDT_SE_CD", "UPT");//신규,수정 구분 (NEW,UPT)
		params.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_UPDATE);//전송상태
		params.put("CHGUSERCODE", SessionHelper.getSession("USERID"));
		
		coviMapperOne.update("user.govDoc.openDoc.updateGovOpenDocMaster", params);
		
		params.put("formInstID", formInstID);//문서고유번호
		TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
			@Override
			public void afterCommit() {
				try {
					// 시행문 변환 및  PDF변환 실행 (비동기 Background)
					asyncTaskOpenDocConverter.executeOpenDocConvert(params);
				} catch (NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				} catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		});
		
		return null;
	}
	
	@Override
	public int updateOpenDocStatus(CoviMap params) throws Exception {
		return coviMapperOne.update("user.govDoc.openDoc.updateState", params);
	}
	
	@Override
	public CoviMap selectGovHistory(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		String strListQuery = "user.govDoc.openDoc.selectSendHistory";
		
		CoviList list = coviMapperOne.list(strListQuery,params);	
		int cnt = list.isEmpty() ? 0 : list.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));		
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap selectGovStatistics(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		String strListQuery = "user.govDoc.openDoc.selectSendStatistics";
		
		CoviList list = coviMapperOne.list(strListQuery,params);	
		int cnt = list.isEmpty() ? 0 : list.getMap(0).getInt("TOTAL_COUNT");
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));		
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public int deleteHistory(CoviMap params) throws Exception {
		return coviMapperOne.delete("user.govDoc.openDoc.deleteHistory", params);
	}

	@Override
	public int updateOpenDocStatStatus(CoviMap params) throws Exception {
		return coviMapperOne.update("user.govDoc.openDoc.updateStatSatus", params);
	}

	@Override
	public CoviMap selectOpenDocFileList(CoviMap params) throws Exception {
		CoviList	list = coviMapperOne.list("user.govDoc.openDoc.selectGovOpenDocFileList", params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list",FileUtil.getFileTokenArray(CoviSelectSet.coviSelectJSON(list, "Gubun,FileID,FilePath,FileName,Size")));
		return resultList;
	}
}
