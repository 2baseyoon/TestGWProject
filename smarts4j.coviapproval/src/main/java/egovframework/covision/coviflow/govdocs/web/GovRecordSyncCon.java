package egovframework.covision.coviflow.govdocs.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.record.AbstractRecordManager;
import egovframework.covision.coviflow.govdocs.record.ExecRecordRunnable;
import egovframework.covision.coviflow.govdocs.record.handler.AuthHandler;
import egovframework.covision.coviflow.govdocs.record.manager.RecordClassifyMgr;
import egovframework.covision.coviflow.govdocs.record.manager.RecordProductMgr;
import egovframework.covision.coviflow.govdocs.record.manager.RecordTransferMgr;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.legacy.service.MessageSvc;
import egovframework.covision.coviflow.user.service.RecordGfileListSvc;
import egovframework.covision.coviflow.user.service.SeriesListSvc;

@Controller
public class GovRecordSyncCon {
	
	private Logger LOGGER = LogManager.getLogger(GovRecordSyncCon.class);
	
	@Autowired
	private RecordGfileListSvc recordGfileListSvc;
	
	@Autowired
	private GovRecordSyncSvc govRecordSyncSvc;
	
	@Autowired
	private SeriesListSvc seriesListSvc;
	
	@Autowired
	private MessageSvc messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * doRecrodReceiveFile - 기록물철 
	 * @param recvFileName
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "govDocs/doRecrodReceiveFile.do")
	public @ResponseBody void doRecrodReceiveFile(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String recvFileName = StringUtil.replaceNull(request.getParameter("xmlFilePath"));
		LOGGER.info("Received govDocs File name : {}", recvFileName);
		
		AbstractRecordManager rif = null;
		if(recvFileName.contains("NEW_UNIT_FILE")){
			rif = new RecordClassifyMgr(govRecordSyncSvc, new AuthHandler());
		} else if(recvFileName.contains("PROD")){
			rif = new RecordProductMgr(govRecordSyncSvc, new AuthHandler());
		} else if(recvFileName.contains("TRANS")){
			rif = new RecordTransferMgr(govRecordSyncSvc, new AuthHandler());
		}
		if(rif == null)
			throw new IllegalArgumentException();
		
		rif.receiveFile(FileUtil.checkTraversalCharacter(recvFileName));
	}
	
	/**
	 * getRecordStatus - 기록물철 건수 현황 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "govDocs/getRecordStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getRecordStatus(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap jsonObj = new CoviMap();
		
		int gfileCnt = 0;
		int docCnt = 0;
		
		try	{
			
			CoviMap params1 = new CoviMap();
			CoviList coviList1 = new CoviList();
			CoviList coviList2 = new CoviList();
			
			String[] recordClassNumArr = StringUtil.replaceNull(request.getParameter("RecordClassNum")).split(";");				
			if("ALL".equals(request.getParameter("mode"))){
				params1.put("endYear", request.getParameter("BaseYear"));
				params1.put("recordDeptCode", request.getParameter("RecordDeptCode"));
				params1.put("recordStatusArr", new String[]{"2", "3", "4", "6", "7", "8", "9"});
				
				coviList1 = govRecordSyncSvc.selectRecordGFileData(params1);
				if(!coviList1.isEmpty()){
					recordClassNumArr = new String[coviList1.size()];
					for(int i = 0; i < coviList1.size(); i++){
						recordClassNumArr[i] = (String)((CoviMap)coviList1.get(i)).get("RECORDCLASSNUM");
					}
				}
				params1.put("recordClassNumArr", recordClassNumArr);
				coviList2 = govRecordSyncSvc.selectRecordDocList(params1);
			} else {
				params1.put("recordClassNumArr", recordClassNumArr);
				coviList1 = govRecordSyncSvc.selectRecordGFileData(params1);
				coviList2 = govRecordSyncSvc.selectRecordDocList(params1);
			}	
			gfileCnt = coviList1.size();
			docCnt = coviList2.size();	
			
			jsonObj.put("recordFile", gfileCnt);
			jsonObj.put("recordDoc", docCnt);
			
			jsonObj.put("status", Return.SUCCESS);
			
			String lang = SessionHelper.getSession("lang");
			if("ko".equals(lang)){
				jsonObj.put("message", "기록물 철 : "+ gfileCnt +"건, 문서 : "+ docCnt +"건\n\n진행하시겠습니까?");
			} else {
				jsonObj.put("message", "Record Filing : "+ gfileCnt +", Files : "+ docCnt +"\n\nWould you like to proceed?");
			}
			
			
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			jsonObj.put("status", Return.FAIL);
			jsonObj.put("message", isDevMode.equalsIgnoreCase("Y")?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			jsonObj.put("status", Return.FAIL);
			jsonObj.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			jsonObj.put("status", Return.FAIL);
			jsonObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return jsonObj;
	}
	
	/**
	 * doStatusRecord - 기록물철 현황보고
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "govDocs/doStatusReport.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap doStatusReport(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		int result = 0;
		
		int gfileCnt = 0;
		
		try	{
			
			AuthHandler auth = new AuthHandler();
			String msg = auth.lineCheck();
			if("00000".equals(msg)){
				
				CoviMap params1 = new CoviMap();
				CoviList coviList1 = new CoviList();
				
				String[] recordClassNumArr = request.getParameter("RecordClassNum").split(";");
				
				if("ALL".equals(request.getParameter("mode"))){
					params1.put("endYear", request.getParameter("BaseYear"));
					params1.put("recordDeptCode", request.getParameter("RecordDeptCode"));
					params1.put("recordStatusArr", new String[]{"2", "3", "4", "6", "7", "8", "9"});
					
					coviList1 = govRecordSyncSvc.selectRecordGFileData(params1);
					if(!coviList1.isEmpty()){
						recordClassNumArr = new String[coviList1.size()];
						for(int i = 0; i < coviList1.size(); i++){
							recordClassNumArr[i] = (String)((CoviMap)coviList1.get(i)).get("RECORDCLASSNUM");
						}
					}
					params1.put("recordClassNumArr", recordClassNumArr);
				} else {
					params1.put("recordClassNumArr", recordClassNumArr);
					coviList1 = govRecordSyncSvc.selectRecordGFileData(params1);
				}
				
				gfileCnt = coviList1.size();
				
				if(gfileCnt > 0){
					//현재 사용자 ID
					String userID = SessionHelper.getSession("USERID");
					
					CoviMap params = new CoviMap();
					params.put("mode", request.getParameter("mode"));
					params.put("endYear", request.getParameter("BaseYear"));
					params.put("recordDeptCode", request.getParameter("RecordDeptCode"));
					params.put("recordClassNumArr", recordClassNumArr);
					
					ExecRecordRunnable th = new ExecRecordRunnable(govRecordSyncSvc, messageSvc, params, "PRODUCT", userID);
					Thread t = new Thread(th);
					t.start();
				}
				
			} else {
				result = 1;
			}
			
			if(result == 0){
				returnList.put("status", Return.SUCCESS);
				String lang = SessionHelper.getSession("lang");
				if("ko".equals(lang)){
					returnList.put("message", "기록물 이관처리가 진행 중입니다.\n잠시 후 확인해주세요.");
				} else {
					returnList.put("message", "Status report processing is in progress.\nPlease check later.");
				}
				
			}else if(result == 1){
				returnList.put("status", Return.FAIL);
				String lang = SessionHelper.getSession("lang");
				if("ko".equals(lang)){
					returnList.put("message", "기록물 관리시스템의 연결이 원할하지 않습니다.\n연결 상태를 확인해주세요.");
				} else {
					returnList.put("message", "The Connection to the records management system is not good.\nPlease check the connection status.");
				}
				
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * doStatusRecord - 기록물철 이관요청
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 * 
	 * @한국투자공사 적용소스로 기록관시스템 이관기능. (연구소코멘트는 //@로 주석시작)
	 * @ .txt
	 * @ 1. 기록물철관련 .txt파일생성.(RD01ZA0_TRANS_GFILE_211202173358.txt)
		   - 기록물철(TRANS_GFILE) > 문서(TRANS_DOC) > 기록물철 히스토리(TRANS_GFILEHIST) > TRANS_DOCHIST(빈파일), TRANS_SPRECORD(빈파일) > TRANS_PAGE
		 2. datafile xml변환 > 전송 후 결과리턴 
			- TRANS_LIST.xml 생성(1에서 생성한 txt 경로와 이름정보가 담김)
		 3. createTransferEfile() > pdf생성 및 첨부파일 복사 
			- 폴더생성(RD01ZA0000072021000001001)후 본문 PDF생성 및 첨부파일 복사
			- shellcmd 명령어 phantomjs통해서 결재 url호출하여 pdf생성
		 4. attachfile xml변환 > 전송 후 결과리턴
			- TRANS_EFILE.xml 생성 (본문pdf 및 첨부파일 정보)
		 5. 기록물철정보 xml변환 > 전송.
			- TRANS_END.xml 생성 
		 6. 이관결과(오류 or 작업완료) 메일 발송
	 */
	@RequestMapping(value = "govDocs/doTransRecord.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap doTransRecord(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		int result = 0;
		
		int gfileCnt = 0;
		//int docCnt = 0;
		
		try	{
			
			AuthHandler auth = new AuthHandler(); //@ 주석처리
			String msg = auth.lineCheck(); //@ 주석처리 msg = "00000"
			
			if("00000".equals(msg)){
				CoviMap params1 = new CoviMap();
				CoviList coviList1 = new CoviList();
				//CoviList coviList2 = new CoviList();
				
				String[] recordClassNumArr = request.getParameter("RecordClassNum").split(";");
				
				if("ALL".equals(request.getParameter("mode"))){
					params1.put("endYear", request.getParameter("BaseYear"));
					params1.put("recordDeptCode", request.getParameter("RecordDeptCode"));
					params1.put("recordStatusArr", new String[]{"2", "3", "4", "6", "7", "8", "9"});
					
					coviList1 = govRecordSyncSvc.selectRecordGFileData(params1);
					if(!coviList1.isEmpty()){
						recordClassNumArr = new String[coviList1.size()];
						for(int i = 0; i < coviList1.size(); i++){
							recordClassNumArr[i] = (String)((CoviMap)coviList1.get(i)).get("RECORDCLASSNUM");
						}
					}
					params1.put("recordClassNumArr", recordClassNumArr);
//					coviList2 = govRecordSyncSvc.selectRecordDocList(params1);
				} else {
					params1.put("recordClassNumArr", recordClassNumArr);
					coviList1 = govRecordSyncSvc.selectRecordGFileData(params1);
//					coviList2 = govRecordSyncSvc.selectRecordDocList(params1);
				}
				
				gfileCnt = coviList1.size();
//				docCnt = coviList2.size();
				
				if(gfileCnt > 0){
					//현재 사용자 ID
					String userID = SessionHelper.getSession("USERID");
					
					CoviMap params = new CoviMap();
					params.put("mode", request.getParameter("mode"));
					params.put("endYear", request.getParameter("BaseYear"));
					params.put("recordDeptCode", request.getParameter("RecordDeptCode"));
					params.put("recordClassNumArr", recordClassNumArr);
					
					ExecRecordRunnable th = new ExecRecordRunnable(govRecordSyncSvc, messageSvc, params, "TRANS", userID);
					Thread t = new Thread(th);
					t.start();
				}
				
				
			} else {
				result = 1;
			}
			
			if(result == 0){
				returnList.put("status", Return.SUCCESS);
				String lang = SessionHelper.getSession("lang");
				if("ko".equals(lang)){
					returnList.put("message", "기록물철 이관처리가 진행 중입니다.\n잠시 후 확인해주세요.");
				} else {
					returnList.put("message", "Transfer report processing is in progress.\nPlease check later.");
				}
				
			}else if(result == 1){
				returnList.put("status", Return.FAIL);
				String lang = SessionHelper.getSession("lang");
				if("ko".equals(lang)){
					returnList.put("message", "기록물 관리시스템의 연결이 원할하지 않습니다.\n연결 상태를 확인해주세요.");
				} else {
					returnList.put("message", "The Connection to the records management system is not good.\nPlease check the connection status.");
				}
				
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "govDocs/selectGovRecordDocInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectGovSenderMasterUpper(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("processID", request.getParameter("processID"));
			
			CoviMap resultList = govRecordSyncSvc.selectGovRecordDocInfo(params);
			
			if(resultList != null) {
				
			}
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
}
