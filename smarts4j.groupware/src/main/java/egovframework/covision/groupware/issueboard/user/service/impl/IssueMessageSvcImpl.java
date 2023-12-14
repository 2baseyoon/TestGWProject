package egovframework.covision.groupware.issueboard.user.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;



import egovframework.baseframework.util.json.JSONSerializer;

import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.admin.service.impl.BoardManageImpl;
import egovframework.covision.groupware.issueboard.user.service.IssueMessageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("IssueMessageSvc")
public class IssueMessageSvcImpl extends EgovAbstractServiceImpl implements IssueMessageSvc{
	
	private static final String DIC_NULL = ";;;;;;;;;;";  //익명 사용시 부서, 직위, 직급 모두 공백처리
	private static final String PLUS = "+";
	private static final String MINUS = "-";

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	
	@Override
	public int uploadIssueMessage(CoviMap params, List<MultipartFile> mf) throws Exception {

		List<MultipartFile> mockedFileList = new ArrayList<>();
		for (int i = 0; i < mf.size(); i++) {
			MultipartFile file = mf.get(i);
			mockedFileList.add(file);
		}
		
		if (!mockedFileList.isEmpty()) {
			for (int i = 0; i < mockedFileList.size(); i++) {
				File uploadFile = new File(FileUtil.checkTraversalCharacter(mockedFileList.get(i).getOriginalFilename()));
				mockedFileList.get(i).transferTo(uploadFile);
				
				try(FileInputStream fis = new FileInputStream(uploadFile);
						XSSFWorkbook workbook = new XSSFWorkbook(fis);
						){
					XSSFSheet sheet = workbook.getSheetAt(0); // 해당 엑셀파일의 시트(Sheet) 수
			        int rows = sheet.getPhysicalNumberOfRows(); // 해당 시트의 행의 개수
			        for (int rowIndex = 1; rowIndex < rows; rowIndex++) {
			        	XSSFRow row = sheet.getRow(rowIndex); // 각 행을 읽어온다
			        	if (row != null) {
			        		ArrayList cellValue = new ArrayList();
			        		int cells = row.getPhysicalNumberOfCells();
			            	for (int columnIndex = 0; columnIndex < cells; columnIndex++) {
			            		XSSFCell cell = row.getCell(columnIndex); // 셀에 담겨있는 값을 읽는다.
			                	String value = "";
			                	
			                	if(cell != null){
			                		switch (cell.getCellType()) { // 각 셀에 담겨있는 데이터의 타입을 체크하고 해당 타입에 맞게 가져온다.
			                    		case XSSFCell.CELL_TYPE_NUMERIC:
			                    			if( DateUtil.isCellDateFormatted(cell)) {
			                    				Date date = cell.getDateCellValue();
			                    				value = new SimpleDateFormat("yyyy-MM-dd").format(date);
			                    			}else{
			                    				value = String.valueOf(cell.getNumericCellValue());
			                    			}
			                    			break;
			                    		case XSSFCell.CELL_TYPE_STRING:
			                    			value = cell.getStringCellValue() + "";
			                    			break;
			                    		case XSSFCell.CELL_TYPE_BLANK:
			                    			value = cell.getBooleanCellValue() + "";
			                    			break;
			                    		case XSSFCell.CELL_TYPE_ERROR:
			                    			value = cell.getErrorCellValue() + "";
			                    			break;
			                    		default :
			                    			break;
			                		}
			                		if(value.equals("false")){
			                			value="";
			                		}
			                		
			                		if(value.equals("end")){
			                			// System.out.println(value);
			                		}
			                		cellValue.add(value);
			                	}
			            	}
			            	
			            	if(cellValue.size()>0){
			            		CoviMap newParams = new CoviMap();
					            newParams = params;
					            	
					            newParams.put("subject",cellValue.get(4));
					            newParams.put("projectIssueType", cellValue.get(1));
					            newParams.put("module", cellValue.get(2));
					            newParams.put("projectIssueContext", cellValue.get(5));
					            newParams.put("projectIssueSolution", cellValue.get(7));
					            newParams.put("progress", cellValue.get(8));
					            newParams.put("result", cellValue.get(9));
					            	
					            String complateCheck = null;
					            if(cellValue.get(10).equals("진행중")){
					            	complateCheck="0";
					            }else if(cellValue.get(10).equals("완료")){
					            	complateCheck="1";
					            }
					            newParams.put("complateCheck", complateCheck);
					            newParams.put("complateDate", cellValue.get(11));
					            newParams.put("etc", cellValue.get(12));
	
					            insertCreateMessage(newParams);
			            	}
			            }
			        }// inner for
				}
			}// outer for
		}
		
		
		return 1;
	}
	
	public void insertCreateMessage(CoviMap params){
		params.put("creatorCode", params.get("userCode"));
		
		params.addAll(coviMapperOne.select("user.message.selectCreatorProfileData", params));

		String numberingRule = RedisDataUtil.getBaseConfig("UseBoardCategoryNumber");
		params.put("numberingRule", numberingRule);
		
		String number = coviMapperOne.getString("user.message.selectNumberByBoard", params);
		
		params.put("isCurrent", "Y");		//최신버전
		params.put("isCheckOut", "N");		//체크아웃 여부
		params.put("number", number);
		params.put("version", "1");
		params.put("useSecurity", "N");
		params.put("useAnonym", "N");
		params.put("useScrap", "N");
		
		int createFlag = coviMapperOne.insert("user.message.createMessage", params);
		if(createFlag < 0) {
			if(params.get("messageID") != null) {
				createFlag = 1;
			}
		}
		
		params.put("seq", params.get("messageID"));
		
		coviMapperOne.update("user.message.updateMessageSeq", params);
		
		coviMapperOne.insert("user.issuemessage.createContents", params);
		
	}

	@Override
	public int selectNormalMessageGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.issuemessage.selectNormalMessageGridCount", params);
	}	

	@Override
	public CoviMap selectNormalMessageGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.issuemessage.selectNormalMessageGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,MenuID,FolderID,FolderName,FolderPath,ListTop,IsTop,Subject,MsgType,DeleteDate,FileID,FileCnt,FileExtension,CategoryPath,CategoryName,CreatorCode,CreatorName,CreatorDept,CreateDate,MailAddress,RequestorMailAddress,ReadCnt,CommentCnt,EmpNo,Number,RegistDept,RegistDeptName,OwnerCode,OwnerName,FolderOwnerCode,RevisionDate,RevisionName,RegistDate,AnswerCnt,RecommendCnt,UF_Value0,UF_Value1,UF_Value2,UF_Value3,UF_Value4,UF_Value5,UF_Value6,UF_Value7,UF_Value8,UF_Value9,Seq,Depth,IsCheckOut,IsRead,UseAnonym,ProjectName,ProjectManager,ProductType,Module"));
		return resultList;
	}
	
	@Override
	public CoviMap selectNormalMessageExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.issuemessage.selectNormalMessageGridList",params);
		int cnt = (int) coviMapperOne.getNumber("user.issuemessage.selectNormalMessageGridCount", params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, params.getString("headerKey")));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * createMessage 게시글, 문서 추가
	 * 
	 * 1. selectCreatorInfo : 익명게시 사용 여부 확인 이후 작성자 정보 조회 ( creatorLevel, Name, Position... )
	 * 2. setParamByBizSection : 통합게시, 문서관리 구분 후 문서번호(number) , 담당자 설정 (ownerCode)
	 * 3. 게시글 추가, 답글, 개정 분기 처리
	 * 4. 추가, 답글, 개정 처리 이후 게시글별 옵션 추가
	 * 5. 첨부파일
	 * 6. 승인프로세스
	 * 
	 * @description 게시글 추가
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int createIssueMessage(CoviMap params, List<MultipartFile> mf) throws Exception {
		//작성자 정보 조회 및 설정
		params.put("creatorCode", params.get("userCode"));
		selectCreatorInfo(params);
		setParamByBizSection(params);

		//게시글 정보  추가: board_message
		int createFlag = 0;
		if("revision".equals(params.get("mode"))){	//개정
			//게시글 개정: 개정의 경우 원본 게시글의 MessageID를 orgMessageID를 사용.
			params.put("orgMessageID",params.get("messageID")); 
			createFlag = coviMapperOne.insert("user.message.revisionMessage", params);	//기존 게시글정보를 기준으로 version 정보 및 변경된 정보로 board_message에 추가
			
			//개정 이후 버전정보 +1하여 옵션 등록
			params.put("actType", "In");
			coviMapperOne.update("user.message.updateCheckInOutHistory", params);	//개정 히스토리 등록
			
			params.put("version", params.getInt("version")+1);
			coviMapperOne.update("user.message.updatePrevMessage", params);
			
			//체크인, 체크아웃 히스토리에 개정으로 추가 
			params.put("actType", "Revision");
			coviMapperOne.insert("user.message.createCheckInOutHistory", params);
		} else if("reply".equals(params.get("mode"))){	//답글
			params.put("version", "1");	//생성시에는 무조건 버전 1로 고정 
			params.put("orgMessageID",params.get("seq")); 
			createFlag = coviMapperOne.insert("user.message.createMessage", params);
			if(createFlag < 0) {
				if(params.get("messageID") != null) {
					createFlag = 1;
				}
			}
			
			coviMapperOne.update("user.message.updatePrevReplyMessage", params);	//등록되있는 답글 step전체 +1
			params.put("depth", params.getInt("depth")+1 );
			params.put("step", params.getInt("step")+1);
			
			//답글알림 Y/N
			String noticeFlag = coviMapperOne.selectOne("user.message.selectOriginReplyNotice", params);	//useReplyNotice
			if("Y".equals(noticeFlag)){		
				insertReplyNotification(params);
			}
		} else  {	//create, binder
			params.put("version", "1");	//생성시에는 무조건 버전 1로 고정 
			createFlag = coviMapperOne.insert("user.message.createMessage", params);
			if(createFlag < 0) {
				if(params.get("messageID") != null) {
					createFlag = 1;
				}
			}
			
			params.put("seq", params.get("messageID"));
			
			//게시판 담당자 알림 기능 사용 여부 조회 IsAdminNotice Y/N
			CoviMap managerMap = coviMapperOne.select("user.board.selectBoardManager", params);
			params.addAll(managerMap);
			if("Y".equals(params.getString("isAdminNotice")) 
					&& "C".equals(params.getString("msgState"))){
				notifyCreateMessage(params);
			}
		}
		
		if(createFlag > 0){
		    CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "Board");  //BizSection
		    editorParam.put("imgInfo", params.getString("bodyInlineImage")); 
		    editorParam.put("objectID", params.getString("folderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", params.getString("messageID"));  
		    editorParam.put("frontStorageURL", params.getString("frontStorageURL"));  
		    editorParam.put("bodyHtml",params.getString("body"));   
		    
		    CoviMap editorInfo = editorService.getEscapeContent(editorParam);
		    
		    params.put("body", editorInfo.getString("BodyHtml"));
		    params.put("bodySize", editorInfo.getString("BodyHtml").length());
		    
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			
			if(params.get("complateCheck").equals("")){
				params.put("complateCheck", null);
			}
			
			coviMapperOne.insert("user.issuemessage.createContents", params);
			
			updateMessageReadAuth(params);	//열람권한 설정
			updateMessageAuth(params);		//상세권한 설정
			updateMessageTag(params);		//태그 설정
			updateMessageLink(params);		//링크 설정
			updateLinkedMessage(params);	//연결글, 바인더 설정
			updateUserDefFieldValue(params);//사용자 정의 필드 설정
			
			//경조사 게시판으로 설정된 항목의 경우 값 변경
			if(params.get("folderID").equals(RedisDataUtil.getBaseConfig("eventBoardID")) ){	//경조사 게시판용: 화면상에 설정한 사용자정의 필드 순서대로...
				params.put("eventDate", params.get("eventDate"));		//Date
				params.put("eventType", params.get("eventType"));	//행사 종류: 생일, 결혼, 돌잔치
				params.put("eventOwner", params.get("eventOwnerCode"));							//OwnerCode
				coviMapperOne.insert("user.message.createMessageEvent", params);				//board_message_event
			}
			
			if("migrate".equals(params.get("mode")) || "revision".equals(params.get("mode"))){	//개정의 경우 파일 삭제가 존재 하지 않고 추가, 복사만 존재하기 때문에 별도 구현
				migrateMessageSysFile(params, mf);
			} else {
				updateMessageSysFile(params, mf);
			}
			
			//답글일 경우 seq를 원본 게시글로 설정
			if(!params.get("mode").equals("reply")){
				//승인 프로세스는 답글 및 임시저장일 때는 설정하지 않음
				if(!"T".equals(params.get("msgType")) && "Y".equals(params.get("isApproval"))){
					int processFlag = updateMessageProcess(params);
					if(processFlag > 0){	//승인 처리 이후 승인 요청 대상 알림
						notifyRequestProcess(params);
					}
				}
			}
		}
		return createFlag;	
	}
	
	//게시 작성자 정보 조회 및 설정
	public void selectCreatorInfo(CoviMap params) throws Exception {
		//클래스가 아니라 스크립트xml에서 처리할지 고민
		if("Y".equals(params.get("useAnonym"))){
			//익명 설정값은 JSP에서 설정된 값을 그대로 사용 (creatorName)
			params.put("creatorLevel", DIC_NULL);
			params.put("creatorPosition", DIC_NULL);
			params.put("creatorTitle", DIC_NULL);
			params.put("creatorDept", DIC_NULL);
		} else {
			//sys_object_user_basegroup 테이블에서 작성자 정보 조회
			params.addAll(coviMapperOne.select("user.message.selectCreatorProfileData", params));
		}
	}
	
	//게시판, 문서관리 분기처리 후 parameter 설정
	public void setParamByBizSection(CoviMap params) throws Exception{
		String number = null;		//글번호, 문서번호
		String ownerCode = null;
		if("Board".equals(params.get("bizSection"))){	//일반 게시판 게시번호 발번 규칙
			//게시글 번호 발번 규칙: 발번규칙은 변경되지 않음.
			String numberingRule = RedisDataUtil.getBaseConfig("UseBoardCategoryNumber");
			params.put("numberingRule", numberingRule);
			
			number = coviMapperOne.getString("user.message.selectNumberByBoard", params);
		} else {
			if(StringUtil.isNotNull(params.get("isAutoDocNumber")) && "Y".equals(params.get("isAutoDocNumber"))){
				//1. 문서번호 자동 발번 기능 사용
				String prefix = coviMapperOne.getString("user.message.selectAutoDocNumber", params);
				params.put("prefix", prefix.split(";")[0]);
				coviMapperOne.insert("user.message.updateAutoDocNumber", params);
				number = prefix.replaceAll(";", "");
			} else {
				//2. 문서번호 수동 입력
				number = params.getString("docNumber");
			}
			//문서함 소유자, 담당자 코드설정(관리자가 설정하지 않았을시 게시글 등록자 정보를 입력)
			if(StringUtil.isNotNull(params.get("ownerCode"))){
				ownerCode = params.getString("ownerCode");
			} else {
				ownerCode = params.getString("userCode");
			}
			params.put("ownerCode", ownerCode);	//담당자, 소유자
		}
		params.put("isCurrent", "Y");		//최신버전
		params.put("isCheckOut", "N");		//체크아웃 여부
		params.put("number", number);		//게시번호, 문서번호 설정
	}
	
	//답글 알림
	public void insertReplyNotification(CoviMap params) throws Exception{
		String orgMediaType = coviMapperOne.selectOne("user.message.selectOriginMediaType", params);//원본글 알림매체 조회
		String goToUrl = createMessageUrl(params);
		String mobileUrl = createMessageMobileUrl(params);
		CoviMap notiParams = new CoviMap();
		
		notiParams.put("ServiceType", params.getString("bizSection"));
		notiParams.put("MsgType", "BoardReply");
		notiParams.put("MediaType", orgMediaType);
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", mobileUrl);
//			notiParams.put("MessagingSubject", "[답글 알림]" + params.getString("subject"));
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
//			notiParams.put("ReceiverText", "[답글 알림]" + params.getString("subject"));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("ownerCode"));		//원본글 소유자
		notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}
	
	//게시글 등록 담당자 알림
	public void notifyCreateMessage(CoviMap params) throws Exception{
		String managerCode = params.getString("managerCode");
		if(!managerCode.isEmpty()){
			String goToUrl = createMessageUrl(params);
			String mobileUrl = createMessageMobileUrl(params);
			CoviMap notiParams = new CoviMap();
			
			notiParams.put("ServiceType", params.getString("bizSection"));
			notiParams.put("MsgType", "BoardMsgRegi");
			notiParams.put("PopupURL", goToUrl);
			notiParams.put("GotoURL", goToUrl);
			notiParams.put("MobileURL", mobileUrl);
			notiParams.put("MessagingSubject", params.getString("subject"));
			notiParams.put("MessageContext", createMessageContext(params));
//				notiParams.put("ReceiverText", "[등록 알림]" + params.getString("subject"));
			notiParams.put("ReceiverText", params.getString("subject"));
			notiParams.put("SenderCode", params.getString("userCode"));
			notiParams.put("RegistererCode", params.getString("userCode"));
			notiParams.put("ReceiversCode", managerCode);		//게시판 담당자
			notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
			MessageHelper.getInstance().createNotificationParam(notiParams);
			messageSvc.insertMessagingData(notiParams);
		} else {
			//TODO: 게시판 담당자가 존재 하지 않을때 처리, 화면단에서는 필수 입력값이므로 별도 처리는 하지 않음
		}
	}
	
	/**
	 * updateMessageReadAuth
	 * @description 열람권한 일괄삭제 후 추가
	 * @return JSONObject
	 * @throws Exception
	 */
	public int updateMessageReadAuth(CoviMap params) throws Exception {
		//추가할때는 삭제하지 않아도 된다 !!!
		if("update".equals(params.get("mode")) ){
			params.put("objectID", params.get("folderID"));
			coviMapperOne.delete("user.message.deleteMessageReadAuth", params);
		}
		
		//상세권한 설정값이 없다면 열람권한 추가
		if("Y".equals(params.get("useMessageReadAuth")) && StringUtil.isNotNull(params.get("messageReadAuth"))){
			String[] readAuth = params.getString("messageReadAuth").split(";");
			for(int authCnt = 0; authCnt < readAuth.length; authCnt++){
				CoviMap authParam = new CoviMap();
				authParam.put("bizSection", params.get("bizSection"));
				authParam.put("objectID", params.get("folderID"));
				authParam.put("messageID", params.get("messageID"));
				authParam.put("targetCode", readAuth[authCnt].split("\\|")[0]);
				authParam.put("targetType", readAuth[authCnt].split("\\|")[1]);
				authParam.put("isSetting", "Y");		//Y: 직접설정, N: 시스템설정
				authParam.put("userCode", params.get("userCode"));
				coviMapperOne.insert("user.message.createMessageReadAuth", authParam);	//messageReadAuth 데이터 insert
			}
		}
		return 0;	//우선 0리턴 체크할게 없어ㅇㅇ...추후에도 체크할 필요가 없다면 void로 변경
	}
	
	/**
	 * updateMessageAuth
	 * @description 상세권한 일괄삭제 후 추가
	 * @return JSONObject
	 * @throws Exception
	 */
	public int updateMessageAuth(CoviMap params) throws Exception {
		//추가할때는 삭제하지 않아도 된다 !!!
		if("update".equals(params.get("mode")) ){
			coviMapperOne.delete("user.message.deleteMessageAuth", params);
		}
		int cnt = 0;
		//aclList에 데이터가 있어야한다.
		if(StringUtil.isNotNull(params.get("aclList"))){
			CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("aclList"), "utf-8"));
			for(int i=0;i<aclArray.size();i++){
				CoviMap aclObj = aclArray.getJSONObject(i);
				String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
				params.put("messageID", params.get("messageID"));
				params.put("version", params.get("version"));		//문서관리용 버전
				params.put("targetCode", aclObj.get("TargetCode"));	//대상객체 코드
				params.put("targetType", aclObj.get("TargetType"));	//대상객체 유형
				params.put("aclList", aclObj.get("AclList"));
				params.put("security", aclShard[0]);
				params.put("create", aclShard[1]);
				params.put("delete", aclShard[2]);
				params.put("modify", aclShard[3]);
				params.put("execute", aclShard[4]);
				params.put("read", aclShard[5]);
				params.put("description", "");
				params.put("registerCode", SessionHelper.getSession("USERID"));
				cnt += coviMapperOne.insert("user.message.createMessageAuth", params);	//messageReadAuth 데이터 insert
			}
			
		}
		return cnt;
	}
	
	/**
	 * updateMessageTag
	 * @description 태그 정보 일괄삭제 후 추가
	 * @return JSONObject
	 * @throws Exception
	 */
	public int updateMessageTag(CoviMap params) throws Exception {
		if("update".equals(params.get("mode")) ){
			coviMapperOne.delete("user.message.deleteMessageTag", params);
		}
		int cnt = 0;
		if(StringUtil.isNotNull(params.get("tagList"))){
			CoviList tagArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("tagList"), "utf-8"));
			for(int i=0;i<tagArray.size();i++){
				CoviMap tagObj = tagArray.getJSONObject(i);
				params.put("version", params.get("version"));		//문서관리용 버전
				params.put("tag", tagObj.get("Tag"));				//태그 정보
				cnt += coviMapperOne.insert("user.message.createMessageTag", params);	//messageReadAuth 데이터 insert
			}
		}
		return cnt;
	}
	
	public int updateMessageLink(CoviMap params) throws Exception {
		if("update".equals(params.get("mode")) ){
			coviMapperOne.delete("user.message.deleteMessageLink", params);
		}
		int cnt = 0;
		//UseMessageAuth가 Y, aclList에 데이터가 있어야한다.
		if(StringUtil.isNotNull(params.get("linkList"))){
			CoviList linkArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("linkList"), "utf-8"));
			for(int i=0;i<linkArray.size();i++){
				CoviMap linkObj = linkArray.getJSONObject(i);
				params.put("title", linkObj.get("Title"));	//링크 이름
				params.put("url", linkObj.get("Link"));		//링크 URL
				cnt += coviMapperOne.insert("user.message.createMessageLink", params);	//messageReadAuth 데이터 insert
			}
			
		}
		return cnt;
	}
	
	//연결 게시글, 바인더 수정 
	public int updateLinkedMessage(CoviMap params) throws Exception {
		if("update".equals(params.get("mode")) ){
			coviMapperOne.delete("user.message.deleteLinkedMessage", params);
		}
		int cnt = 0;
		//UseMessageAuth가 Y, aclList에 데이터가 있어야한다.
		if(StringUtil.isNotNull(params.get("linkedMessage"))){
			CoviList linkArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("linkedMessage"), "utf-8"));
			for(int i=0;i<linkArray.size();i++){
				CoviMap linkObj = linkArray.getJSONObject(i);
				params.put("version", params.get("version"));		//버젼
				params.put("targetID", linkObj.get("MessageID"));	//연결된 게시글
				cnt += coviMapperOne.insert("user.message.createLinkedMessage", params);	//createLinkedMessage 데이터 insert
			}
			
		}
		return cnt;
	}
	/**
	 * updateUserDefFieldValue
	 * @description 사용자정의 필드 설정값 일괄삭제 후 추가
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int updateUserDefFieldValue(CoviMap params) throws Exception {
		int cnt = 0;
		//update의 경우 수정되는 값을 일괄 삭제후 추가
		if("update".equals(params.get("mode")) ){
			coviMapperOne.delete("user.message.deleteUserDefFieldValue", params);		//board_userform_value
			coviMapperOne.delete("user.message.deleteMessageDefFieldValue", params);	//board_message_userform_value
			coviMapperOne.delete("user.message.deleteMessageEvent", params);			//board_message_event
		}
		
		//사용자 정의 필드를 사용할 경우 fieldList변수 체크 수행
		if(StringUtil.isNotNull(params.get("fieldList"))){
			CoviList fieldArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("fieldList"), "utf-8"));
			for(int i=0;i<fieldArray.size();i++){
				CoviMap fieldObj = fieldArray.getJSONObject(i);
				params.put("userFormID", fieldObj.get("UserFormID"));	//UserFormID
				params.put("fieldValue", fieldObj.get("FieldValue"));	//Field Value
				cnt += coviMapperOne.insert("user.message.createUserDefFieldValue", params);	//board_userform_value
			}
			
			if(cnt > 0){	//사용자정의 필드 정보 등록 후 화면 표시용 테이블 데이터 등록
				params.put("fieldArray", fieldArray);
				coviMapperOne.insert("user.message.createMessageDefFieldValue", params);	//board_message_userform_value
			}
		}
		return cnt;
	}
	
	//문서이관, 개정, 복사에 사용
	public void migrateMessageSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		StringUtil func = new StringUtil();
	
		String uploadPath = params.getString("bizSection") + File.separator;	// Board, Doc를 붙여서 서비스 타입별 디렉터리 관리
		String orgPath = "";
		if("revision".equals(params.get("mode"))){
			orgPath =  params.getString("bizSection") + File.separator;
		} else {
			orgPath = "Board" + File.separator;
		}
		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath , params.getString("bizSection"), params.getString("folderID"), "FD", params.getString("messageID"), params.getString("version"));
		//CHECK: 파일 업로드 후 파일 개수외에 확장자 정보를 필요로 할 수 있음
		
		params.put("storageControl", PLUS);
		coviMapperOne.update("user.message.updateCurrentFileSizeByMessage", params);	//게시글 점유 용량 업데이트
		
		if("C".equals(func.f_NullCheck(params.getString("CSMU")))){
			coviMapperOne.update("user.community.updateCurrentFileSizeByMessage", params);
		}
	}
	
	//파일 업로드 및 폴더 용량 정보 수정
	public void updateMessageSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		StringUtil func = new StringUtil();
		params.put("storageControl", MINUS);
		coviMapperOne.update("user.message.updateCurrentFileSizeByMessage", params);
		
		if("C".equals(func.f_NullCheck(params.getString("CSMU")))){
			coviMapperOne.update("user.community.updateCurrentFileSizeByMessage", params);
		}
		
		if(!"create".equals(params.get("mode")) && "0".equals(params.get("fileCnt")) ){
			//수정, 개정시 파일 첨부 정보가 없을 경우 삭제처리
			params.put("ServiceType", params.get("bizSection"));
			params.put("ObjectID", params.get("folderID"));
			params.put("ObjectType", "FD");
			params.put("MessageID", params.get("messageID"));
			params.put("Version", params.get("version"));
			coviMapperOne.delete("user.message.deleteFile", params);
		} else {
			String uploadPath = params.getString("bizSection") + File.separator;	// Board, Doc를 붙여서 서비스 타입별 디렉터리 관리
			CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
			CoviList fileObj = fileSvc.uploadToBack(fileInfos, mf, uploadPath , params.getString("bizSection"), params.getString("folderID"), "FD", params.getString("messageID"), params.getString("version"));
			//CHECK: 파일 업로드 후 파일 개수외에 확장자 정보를 필요로 할 수 있음
			
			//System.out.println(fileObj);
			params.put("storageControl", PLUS);
			coviMapperOne.update("user.message.updateCurrentFileSizeByMessage", params);	//게시글 점유 용량 업데이트
			
			//커뮤니티 용량 업데이트
			if("C".equals(func.f_NullCheck(params.getString("CSMU")))){
				coviMapperOne.update("user.community.updateCurrentFileSizeByMessage", params);
				
				//용량체크
				int num = (int) coviMapperOne.getNumber("user.community.selectCurrentFileSizeByMessage", params);
				
				if(num > 0){
					//용량 초과
					TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
					throw new Exception("MAX");
				}
			}
		}
		
	}
	
	/**
	 * updateMessageProcess
	 * @description 승인프로세스 정의 및 승인선 데이터 등록
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int updateMessageProcess(CoviMap params) throws Exception {
		//사용자정의 프로세스를 사용할경우 processActivityList변수의 값이 있는지 확인 
		if(StringUtil.isNotNull(params.get("processActivityList"))){
			//관리자 승인프로세스 정의 메소드 사용
			BoardManageImpl manageImpl = new BoardManageImpl();
			params.put("objectType", "BoardMsg");
			params.put("objectID", params.get("messageID"));
			params.put("displayName", "게시 사용자정의 승인 프로세스");	//CHECK: Fixed된 값으로 사용됨
			manageImpl.updateApprovalProcess(params);
		}
		//Board_U_ProcessIndiData_C
		//운영자 정의 프로세스 일경우에는 processID를 조회
		int processFlag = coviMapperOne.insert("user.message.createProcess", params);
		if(processFlag > 0){
			//게시물 등록자 본인의 정보 등록
			params.put("actorCode", SessionHelper.getSession("USERID"));
			params.put("actorName", SessionHelper.getSession("UR_Name"));
			params.put("actorLevel", SessionHelper.getSession("UR_JobLevelName"));
			params.put("actorPosition", SessionHelper.getSession("UR_JobPositionName"));
			params.put("actorTitle", SessionHelper.getSession("UR_JobTitleName"));
			params.put("actorDept", SessionHelper.getSession("DEPTNAME"));
			coviMapperOne.insert("user.message.createActivity", params);
			
			//sys_process_performer 정보를 activity에 등록
			coviMapperOne.insert("user.message.createPerformerActivity", params);
		}
		//com_process 테이블에 정보 insert
		//com_process_activity 테이블에 정보 insert
		return processFlag;
	}
	
	//승인 요청 알림
	public void notifyRequestProcess(CoviMap params) throws Exception{
		String approverCode = coviMapperOne.selectOne("user.message.selectNextApprover", params);
		CoviMap notiParams = new CoviMap();
		
		notiParams.put("ServiceType", "Board");
		notiParams.put("MsgType", "ApprovalRequest_Board");
		params.addAll(notiParams);
		
		String goToUrl = createMessageUrl(params);
		String mobileUrl = createMessageMobileUrl(params);
		
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", mobileUrl);
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
		//notiParams.put("ReceiverText", "[승인 요청]" + params.getString("subject"));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", approverCode);		//승인자
		notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}
	
	public String createMessageUrl(CoviMap params){
		//returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");			// Domain
		
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		
		String returnUrl = "";
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");			// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");	
		}
		
		//승인 요청 게시 메뉴 URL로 생성 else 게시 상세보기 URL생성
		if("ApprovalRequest_Board".equals(params.getString("MsgType"))){
			returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardList.do");	// {Domain}/groupware/layout/board_BoardView.do
			returnUrl += "?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Approval&menuID=" + params.get("menuID");
		} else {
			returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardView.do");	// {Domain}/groupware/layout/board_BoardView.do
			returnUrl += "?CLSYS=board&CLMD=user&CLBIZ=Board";
			returnUrl += String.format("&menuID=%s&version=1&folderID=%s&messageID=%s", params.get("menuID"), params.get("folderID"), params.get("messageID")) ;
			returnUrl += "&viewType=List&boardType=Normal&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&page=1&pageSize=10";
		}

		return returnUrl;
	}
	
	public String createMessageMobileUrl(CoviMap params){
		String returnUrl = "";
		
		//승인 요청 게시 메뉴 URL로 생성 else 게시 상세보기 URL생성
		if("ApprovalRequest_Board".equals(params.getString("MsgType"))){
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "view.do");	// {Domain}//groupware/mobile/board/view.do
			returnUrl += "?menucode=BoardMain&boardtype=Total";
		} else {
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "view.do");	// {Domain}/groupware/layout/board_BoardView.do
			returnUrl += "?boardtype=Normal";
			returnUrl += "&folderid=" + params.get("folderID");
			returnUrl += "&messageid=" + params.get("messageID");
			returnUrl += "&cuid=";
			returnUrl += "&version=1";
			returnUrl += "&page=1&searchtext=";
		}

		return returnUrl;
	}
	
	public String createMessageContext(CoviMap params){
		String strHTML = "";	//알림 메일 본문
		
		strHTML += "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>";
		strHTML += "<body>"
				+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
						+ "<tr>"
						+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
								+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
										+ "<tr>"
										+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
										+ DicHelper.getDic("BizSection_" + params.getString("bizSection")) + "(" + params.get("bizSection") + ")"	//Title
										+"</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>"
						+ "<tr>"
						+ "<td bgcolor=\"#ffffff\" style=\"padding: 30px 0 30px 20px; border-left: 1px solid #e8ebed;border-right: 1px solid #e8ebed;font-size:12px;\">"
								+ "<!-- 문서현황 시작-->"
								+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\">"
										+ "<tr>"
										+ "<td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; padding: 10px 10px 10px 10px; color: #888;\">"
												+ "<span  style=\"font: bold dotum,'돋움', Apple-Gothic,sans-serif;color: #888; font-size:12px; \" line-height=\"30\">"
												+ params.get("subject")		//Context
												+ "</span>"
												+ " <br />"
										+ "</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>";
		
		strHTML += "</table></td></tr>"
				+ "<tr>"
				+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">"
						+ "<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
								+ "<tr>"
								+ "<th width=\"100\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" align=\"left\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;color: #666666; padding-left: 12px; border-right: 1px solid #b1b1b1;\">"
										+ "Title"
								+ "</th>"
								+ "<td width=\"536\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #808080; padding: 0 10px;\">"
										+ "<a href=\""+ params.get("GotoURL")	//URL : 페이지 연결 URL
												+ "\" style=\"cursor: pointer;\">"
										+ params.get("subject")	//SUBJECT : 제목
										+ "</a>"
								+ "</td>"
								+ "</tr>"
						+ "</table>"
				+ "</td>"
				+ "</tr>"
				+ "</table></td></tr>";
		
		strHTML += "</table></body></html>";
		return strHTML;
	}
	
	
	
	//게시글 상세보기 내용 조회
	public CoviMap selectIssueMessageDetail(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userCode", SessionHelper.getSession("USERID"));
		
		//조회수 변경 및 조회기록 정보 추가
		int readFlag = (int) coviMapperOne.getNumber("user.message.selectMessageReader",params);
		if( readFlag == 0 ){
			coviMapperOne.insert("user.message.createMessageReader", params);
			coviMapperOne.update("user.message.updateReadCount", params);
		}
		
		CoviMap messageDetail = new CoviMap();
		messageDetail.addAll(coviMapperOne.select("user.issuemessage.selectMessageDetail",params));
		return messageDetail;
	}
	
	/**
	 * 게시글 수정
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int updateIssueMessage(CoviMap params, List<MultipartFile> mf) throws Exception {
		//작성자 정보 조회 및 설정
		String prevAnony = coviMapperOne.selectOne("user.message.selectPrevAnonyFlag", params);
		params.put("prevAnony", prevAnony);
		if("Y".equals(prevAnony)){
			params.put("creatorCode", coviMapperOne.selectOne("user.message.selectCreatorCode", params));
		} else {
			params.put("creatorCode", params.get("userCode"));
		}
		
		selectCreatorInfo(params);
		//게시글 정보  수정: board_message
		int updateFlag = coviMapperOne.update("user.message.updateMessage", params);		
		
		if(updateFlag > 0){
			
		    CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "Board");  //BizSection
		    editorParam.put("imgInfo", params.getString("bodyInlineImage")); 
		    editorParam.put("objectID", params.getString("folderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", params.getString("messageID"));  
		    editorParam.put("frontStorageURL", params.getString("frontStorageURL"));  
		    editorParam.put("bodyHtml",params.getString("body"));   
			
		    CoviMap editorInfo = editorService.getEscapeContent(editorParam);
		    
		    params.put("body", editorInfo.getString("BodyHtml"));
		    params.put("bodySize", editorInfo.getString("BodyHtml").length());
		    
		    if(params.get("complateCheck").equals("")){
				params.put("complateCheck", null);
			}
			coviMapperOne.insert("user.issuemessage.updateContents", params);
			
			updateMessageReadAuth(params);	//열람권한 설정: sys_read_acl
			updateMessageAuth(params);		//상세권한 설정: board_message_acl
			updateMessageTag(params);		//태그 설정: board_message_tag
			updateMessageLink(params);		//링크 설정: board_message_link
			updateLinkedMessage(params);	//연결글, 바인더 설정: board_linked
			updateUserDefFieldValue(params);//사용자 정의 필드 설정: board_userform, board_userform_option, board_userform_value
			updateMessageSysFile(params, mf);
			
			//경조사 게시판으로 설정된 항목의 경우 값 변경
			if(params.get("folderID").equals(RedisDataUtil.getBaseConfig("eventBoardID")) ){	//경조사 게시판용
				params.put("eventDate", params.get("eventDate"));	//Date
				params.put("eventType", params.get("eventType"));	//행사 종류: 생일, 결혼, 돌잔치
				params.put("eventOwner", params.get("eventOwnerCode"));							//OwnerCode
				coviMapperOne.insert("user.message.createMessageEvent", params);				//board_message_event
			}
			
			//승인프로세스를 사용하지 않을 경우에는 기존
			if("Y".equals(params.get("isApproval"))){
				updateMessageProcess(params);
			}
			if("OnWriting".equals(params.get("boardType")) &&
					"C".equals(params.getString("msgState")) ) {
				params.put("seq", params.get("messageID"));
	
				// 게시판 담당자 알림 기능 사용 여부 조회 IsAdminNotice Y/N
				CoviMap managerMap = coviMapperOne.select("user.board.selectBoardManager", params);
				params.addAll(managerMap);
				if ("Y".equals(params.getString("isAdminNotice"))) {
					notifyCreateMessage(params);
				}
			}
		}
		return updateFlag;
	}
}
