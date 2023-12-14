package egovframework.covision.groupware.board.user.service.impl;

import java.io.File;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;



import egovframework.baseframework.util.json.JSONSerializer;

import org.apache.commons.httpclient.NameValuePair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.base.Enums.Return;
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
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.admin.service.UserDefFieldManageSvc;
import egovframework.covision.groupware.board.admin.service.impl.BoardManageImpl;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("MessageSvc")
public class MessageSvcImpl extends EgovAbstractServiceImpl implements MessageSvc{
	
	private static final String DIC_NULL = ";;;;;;;;;;";  //익명 사용시 부서, 직위, 직급 모두 공백처리
	private static final String PLUS = "+";
	private static final String MINUS = "-";

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private EditorService editorService;

	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private UserDefFieldManageSvc userDefFieldManageSvc;
	
	@Override
	public int selectMessageGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectMessageGridCount", params);
	}
	
	/**
	 * @param params DomainID, MenuID, FolderID
	 * @description 게시 관리자 게시물 Grid 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageGridList",params);
		resultList.put("list", list);

		return resultList;
	}
	
	/**
	 * @param params DomainID, MenuID, FolderID
	 * @description 게시물 엑셀 데이터 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageExcelList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageGridList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list));

		return resultList;
	}

	
	/**
	 * selectNormalMessageGridCount
	 * @param params DomainID, MenuID, FolderID
	 * @description 일발 폴더/게시판 타입 게시를 개수 count
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectNormalMessageGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectNormalMessageGridCount", params);
	}	
	
	/**
	 * selectNormalMessageGridList
	 * @param params MenuID, FolderID
	 * @description 일발 폴더/게시판 타입 게시물 Grid 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectNormalMessageGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		//params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.message.selectNormalMessageGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,MenuID,FolderID,FolderName,FolderPath,ListTop,IsTop,Subject,MsgType,MsgState,DeleteDate,FileID,FileCnt,FileExtension,ThumbImageID,CategoryPath,CategoryName,CreatorCode,CreatorName,CreatorDept,CreateDate,MailAddress,RequestorMailAddress,ReadCnt,CommentCnt,EmpNo,Number,RegistDept,RegistDeptName,OwnerCode,OwnerName,FolderOwnerCode,RevisionDate,RevisionName,RegistDate,AnswerCnt,RecommendCnt,UF_Value0,UF_Value1,UF_Value2,UF_Value3,UF_Value4,UF_Value5,UF_Value6,UF_Value7,UF_Value8,UF_Value9,Seq,Depth,IsCheckOut,IsRead,IsSecurity,UseAnonym,UsePubDeptName,RNUM,LinkURL,MultiFolderType"));
		return resultList;
	}
	
	/**
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap selectNormalMessageExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectNormalMessageGridList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list));

		return resultList;
	}
	
	/**
	 * selectSearchMessageGridCount
	 * @param params bizSection
	 * @description 일반 폴더/게시판 타입 게시를 개수 count
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectSearchMessageGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectSearchMessageGridCount", params);
	}	
	
	/**
	 * selectSearchMessageGridList
	 * @param params bizSection
	 * @description 일반 폴더/게시판 타입 게시물 Grid 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectSearchMessageGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.message.selectSearchMessageGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,FolderName,ListTop,IsTop,Subject,MsgType,DeleteDate,FileID,FileCnt,FileExtension,CategoryPath,CategoryName,CreatorCode,CreatorName,CreateDate,ReadCnt,CommentCnt,EmpNo,Number,RegistDept,RegistDeptName,RevisionDate,RevisionName,RegistDate,AnswerCnt,RecommendCnt,UF_Value0,UF_Value1,UF_Value2,UF_Value3,UF_Value4,UF_Value5,UF_Value6,UF_Value7,UF_Value8,UF_Value9,Seq,Depth,IsCheckOut"));
		return resultList;
	}
	
	/**
	 * selectDistributeGridExcelList
	 * @param params
	 * @description 문서배포 Excel Grid 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDistributeGridExcelList(CoviMap params) throws Exception{
		
		CoviMap resultList = new CoviMap();
		CoviList list;
		int cnt; 
		
		if("Receive".equals(params.getString("boxType"))){
			list = coviMapperOne.list("user.message.selectDistributeGridList",params);
//			cnt = (int) coviMapperOne.getNumber("user.message.selectDistributeGridCount", params);
		} else {
			list = coviMapperOne.list("user.message.selectDistributeSendGridList",params);
//			cnt = (int) coviMapperOne.getNumber("user.message.selectDistributeSendGridCount", params);
		}
		

		resultList.put("list",CoviSelectSet.coviSelectJSON(list));
//		resultList.put("cnt", cnt);
		
		return resultList;
	}
	
	@Override
	public int selectDistributeGridCount(CoviMap params) throws Exception {
		int cnt = 0;
		if("Receive".equals(params.getString("boxType"))){
			cnt = (int) coviMapperOne.getNumber("user.message.selectDistributeGridCount", params);
		} else {
			cnt = (int) coviMapperOne.getNumber("user.message.selectDistributeSendGridCount", params);
		}
		return cnt;
	}
	
	
	/**
	 * selectDistributeGridList
	 * @param params
	 * @description 문서배포 Grid 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDistributeGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		//params.put("lang", SessionHelper.getSession("lang"));
		CoviList list;
		
		if("Receive".equals(params.getString("boxType"))){
			list = coviMapperOne.list("user.message.selectDistributeGridList",params);
		} else {
			list = coviMapperOne.list("user.message.selectDistributeSendGridList",params);
		}
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "RecommendCnt,FileCnt,ReadCnt,DisCnt,ConfirmType,DistributeID,DistributeVersion,DistributeMsg,DistributeDate,DistributerCode,DistributerName,MailAddress,Number,IsCheckOut,OwnerCode,MessageID,Version,FolderID,FolderName,Subject,DeleteDate,MsgType,CreatorCode,CreatorName,CreateDate,ReadCnt,CommentCnt,EmpNo,Number,RegistDept,RegistDeptName,RevisionDate,RevisionName,RegistDate,IsCheckOut,DisReadCnt"));
		return resultList;
	}
	
	@Override
	public CoviMap selectMessageTagList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageTagList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "Version,Tag"));
		return resultList;
	}
	
	@Override
	public CoviMap selectMessageLinkList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageLinkList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "LinkID,Title,Url"));
		return resultList;
	}
	
	@Override
	public CoviMap selectLinkedMessageList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectLinkedMessageList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,FolderID,Version,DisplayName"));
		return resultList;
	}
	
	@Override
	public CoviMap selectLinkedFeedMessageList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("user.message.selectLinkedFeedMessageList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "FeedMessageID,FeedVersion,Subject"));
		return resultList;
	}
	
	//승인함, 요청함 승인선 조회
	@Override
	public CoviMap selectProcessActivityList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
		CoviList list = coviMapperOne.list("user.message.selectProcessActivityList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "State,ActivityType,ActorRole,ActorName,CompleteDate"));
		return resultList;
	}
	
	// 승인프로세스 - 승인자 목록 조회(등록자 제외)
	@Override
	public List<CoviMap> selectProcessActorList(CoviMap params) throws Exception {
		return coviMapperOne.selectList("user.message.selectProcessActorList", params);
	}
	
	//문서관리 개정 이력 조회
	@Override
	public CoviMap selectRevisionHistory(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
		CoviList list = coviMapperOne.list("user.message.selectRevisionHistory",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,Subject,IsCurrent,RevisionName,UserCode,RevisionDate,RevisionTime"));
		return resultList;
	}
	
	
	@Override
	public int selectDocInOutHistoryGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectCheckInHistoryGridCount", params);
	}
	
	//문서관리 체크인/아웃 이력 조회
	@Override
	public CoviMap selectDocInOutHistoryGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectCheckInHistoryGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "Version,HistoryType,ActType,RegistDate,ActorName,ActorCode,CO_Date,CI_Date,Comment,DeptName"));
		return resultList;
	}
	
	//최신 공지 게시글 조회
	@Override
	public CoviMap selectNoticeMessageList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		
		if (params.get("isWebpart") != null && params.get("isWebpart").equals("Y")) {
			int cnt = 0;
			cnt = (int) coviMapperOne.getNumber("user.message.selectNoticeMessageNotReadCnt", params);
			result.put("cnt", cnt);
		}
		
		CoviList list = coviMapperOne.list("user.message.selectNoticeMessageList",params);
		result.put("list",CoviSelectSet.coviSelectJSON(list, "MenuID,FolderID,Subject,Version,MessageID,FolderName,CommentCnt,CreatorCode,CreateDate,CreatorName,FolderOwnerCode,ListTop,FileID,unReadCnt"));
		return result;
	}
	
	//최신 게시, 문서 게시글 조회
	@Override
	public CoviMap selectLatestMessageList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("user.message.selectLatestMessageList",params);
		result.put("list",CoviSelectSet.coviSelectJSON(list, "MenuID,FolderName,FolderID,Subject,Version,MessageID,FolderName,CreateDate,CreatorName"));
		return result;
	}
	
	//팝업공지 게시글 조회
	@Override
	public CoviMap selectPopupNoticeList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("webpart.board.selectPopupNoticeList",params);
		result.put("list",CoviSelectSet.coviSelectJSON(list, "MenuID,FolderName,FolderID,Subject,Version,MessageID,FolderName,CreateDate,FolderOwnerCode,FolderType,CreatorCode,OwnerCode,RegistDept,UseMessageAuth,UseMessageReadAuth"));
		return result;
	}
	
	//링크사이트 게시글 조회
	@Override
	public CoviMap selectSystemLinkBoardList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectSystemLinkBoardList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,IsInherited,IsCurrent,IsCheckOut,ParentID,MsgType,MsgState,CategoryID,KeepYear,Number,Seq,Step,Depth,Subject,BodyText,TableHistory,TableBody,HistoryBody,HistoryText,PopupStartDate,PopupEndDate,TopStartDate,TopEndDate,ExpiredDate,BodyFormID,UseSecurity,UseAnonym,IsPopup,IsTop,IsApproval,IsUserForm,UseScrap,NoticeMedia,UseRss,UseReplyNotice,UseCommNotice,TrackBackURL,AnswerCnt,ReadCnt,SatisfactionPoint,ScrapCnt,ReportCnt,FileCnt,FileExtension,TracbackCnt,IsMobile,ProgressState,CheckOuterCode,RegistDate,DeleteDate,CreatorCode,OwnerCode,RegistDept,RevisionCode,CreateDate,CreatorName,CreatorLevel,CreatorPosition,CreatorTitle,CreatorDept,ModifierCode,ModifyDate,ScheduleStartDate,ScheduleEndDate,ScheduleDisplayColor,LinkURL,ScheduleStartHour,ScheduleStartMinute,ScheduleEndHour,ScheduleEndMinute,IsAllDay,ReservationDate,AnonymousPW,SecurityLevel,UsePubDeptName,UseMessageReadAut,UseCommMap,OpenType"));
		return resultList;
	}
	
	//게시 분류 목록 조회
	@Override
	public CoviList selectTypeList(CoviMap params) throws Exception {
		String colName = "fieldID,fieldCnt,fieldName";
		CoviList list = coviMapperOne.list("user.message.selectTypeList", params);
		return CoviSelectSet.coviSelectJSON(list, colName);
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
	public int createMessage(CoviMap params, List<MultipartFile> mf) throws Exception {
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
			
			if("Y".equals(params.getString("isAdminNotice")) && "C".equals(params.getString("msgState"))){
				notifyCreateMessage(params);
			}
		}
		
		if(createFlag > 0){
		    CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "Board");  //BizSection
		    editorParam.put("imgInfo", params.getString("bodyInlineImage"));
		    editorParam.put("backgroundImage", params.getString("bodyBackgroundImage"));
		    editorParam.put("objectID", params.getString("folderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", params.getString("messageID"));  
		    editorParam.put("frontStorageURL", params.getString("frontStorageURL"));  
		    editorParam.put("bodyHtml", params.getString("body"));

		    CoviMap editorInfo = editorService.getEscapeContent(editorParam);
		    
            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
            	throw new Exception("InlineImage move BackStorage Error");
            }
            
		    params.put("body", editorInfo.getString("BodyHtml"));
		    params.put("bodySize", editorInfo.getString("BodyHtml").length());
		    
			
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			coviMapperOne.insert("user.message.createContents", params);
			
			updateMessageReadAuth(params);	//열람권한 설정
			updateMessageAuth(params);		//상세권한 설정
			updateMessageTag(params);		//태그 설정
			updateMessageLink(params);		//링크 설정
			updateLinkedMessage(params);	//연결글, 바인더 설정
			updateUserDefFieldValue(params);//사용자 정의 필드 설정
			
			//경조사 게시판으로 설정된 항목의 경우 값 변경
			if(params.get("folderID").equals(RedisDataUtil.getBaseConfig("eventBoardID")) ){	//경조사 게시판용: 화면상에 설정한 사용자정의 필드 순서대로...
				params.put("eventDate", params.get("eventDate"));		//Date
				params.put("eventType", params.get("eventType"));		//행사 종류: 생일, 결혼, 돌잔치
				params.put("eventOwner", params.get("eventOwnerCode"));							//OwnerCode
				coviMapperOne.insert("user.message.createMessageEvent", params);				//board_message_event
			}
			
			if("migrate".equals(params.get("mode")) || "revision".equals(params.get("mode"))){	//개정의 경우 파일 삭제가 존재 하지 않고 추가, 복사만 존재하기 때문에 별도 구현
				migrateMessageSysFile(params, mf);
			} else {
				updateMessageSysFile(params, mf);
			}
			
			// 승인 프로세스 생성 및 알림 발송
			// 모든 승인 프로세스는 게시글 버전이 1인 경우에만 생성됨
			if(((!params.get("mode").equals("reply") && "Y".equals(params.get("isApproval"))) || 
					(params.get("mode").equals("reply") && "Y".equals(params.get("isApproval")) && "Y".equals(params.get("isReplyApproval")))) && !"T".equals(params.get("msgState")) && params.getInt("version") == 1) {
				
				int processFlag = updateMessageProcess(params);
				if(processFlag > 0){	//승인 처리 이후 승인 요청 대상 알림
					notifyRequestProcess(params);
				}
			}
			
			// 다중분류 처리
			if(params.getString("bizSection").equals("Doc")
				&& (params.getString("multiFolderID") != null && !params.getString("multiFolderID").equals(""))){
				String multiFolderIDs[] = params.getString("multiFolderID").split(";");
				params.put("multiFolderIDs", multiFolderIDs);
				
				coviMapperOne.insert("user.message.createMessageFolder", params);
			}
		}
		return createFlag;	
	}
	
	/**
	 * 간편게시 작성
	 * @return
	 * @throws Exception
	 */
	@Override
	public int createSimpleMessage(CoviMap params) throws Exception {
		//작성자 정보 조회 및 설정
		params.put("creatorCode", params.get("userCode"));
		selectCreatorInfo(params);
		setParamByBizSection(params);
		
		//게시글 정보  추가: board_message
		int createFlag = 0;
		params.put("version", "1");	//생성시에는 무조건 버전 1로 고정 
		createFlag = coviMapperOne.insert("user.message.createMessage", params);
		params.put("seq", params.get("messageID"));
		
		if(createFlag > 0 || params.get("messageID") != null ){
			createFlag = 1; 
			//Editor 처리
		    CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "Board");  //BizSection
		    editorParam.put("imgInfo", params.getString("bodyInlineImage"));
			editorParam.put("backgroundImage", params.getString("bodyBackgroundImage"));
		    editorParam.put("objectID", params.getString("folderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", params.getString("messageID"));  
		    editorParam.put("frontStorageURL", params.getString("frontStorageURL"));  
		    editorParam.put("bodyHtml",params.getString("body"));   
			
		    CoviMap editorInfo = editorService.getEscapeContent(editorParam);
			
            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
            	throw new Exception("InlineImage move BackStorage Error");
            }
		    
		    params.put("body", editorInfo.getString("BodyHtml"));
		    params.put("bodySize", editorInfo.getString("BodyHtml").length());
			
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			coviMapperOne.insert("user.message.createContents", params);
			
			if(StringUtil.isNotNull(params.get("aclList"))){
				CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("aclList"), "utf-8"));
				for(int i = 0; i < aclArray.size(); i++){
					CoviMap aclObj = aclArray.getJSONObject(i);
					String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
					params.put("messageID", params.get("messageID"));
					params.put("version", params.get("version"));			//문서관리용 버전
					params.put("targetCode", aclObj.get("SubjectCode"));	//대상객체 코드
					params.put("targetType", aclObj.get("SubjectType"));	//대상객체 유형
					params.put("aclList", aclShard[0]+aclShard[1]+aclShard[2]+aclShard[3]+aclShard[4]+aclShard[6]);
					params.put("security", aclShard[0]);
					params.put("create", aclShard[1]);
					params.put("delete", aclShard[2]);
					params.put("modify", aclShard[3]);
					params.put("execute", aclShard[4]);
					params.put("read", aclShard[6]);
					params.put("description", "");
                    params.put("isSubInclude", aclObj.get("IsSubInclude"));
					params.put("registerCode", SessionHelper.getSession("USERID"));
					coviMapperOne.insert("user.message.createMessageAuth", params);	//messageReadAuth 데이터 insert
				}
				
			}
		}
		return createFlag;
	}
	
	/**
	 * 게시글 수정
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int updateMessage(CoviMap params, List<MultipartFile> mf) throws Exception {
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
			editorParam.put("backgroundImage", params.getString("bodyBackgroundImage"));
		    editorParam.put("objectID", params.getString("folderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", params.getString("messageID"));  
		    editorParam.put("frontStorageURL", params.getString("frontStorageURL"));  
		    editorParam.put("bodyHtml",params.getString("body"));   
			
		    CoviMap editorInfo = editorService.getEscapeContent(editorParam);
		    
            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
            	throw new Exception("InlineImage move BackStorage Error");
            }
            
		    params.put("body", editorInfo.getString("BodyHtml"));
		    params.put("bodySize", editorInfo.getString("BodyHtml").length());
			
			coviMapperOne.insert("user.message.updateContents", params);
			
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
				coviMapperOne.insert("user.message.deleteMessageEvent", params);				//board_message_event 기존 이벤트 삭제
				coviMapperOne.insert("user.message.createMessageEvent", params);				//board_message_event 신규 이벤트 추가
			}
			
			//승인프로세스를 사용하지 않을 경우에는 기존
			if(!params.getString("chkTemp").equals("false") && "Y".equals(params.get("isApproval"))){
				updateMessageProcess(params);
			}
			if("OnWriting".equals(params.get("boardType")) && "C".equals(params.getString("msgState")) ) {
				params.put("seq", params.get("messageID"));
	
				// 게시판 담당자 알림 기능 사용 여부 조회 IsAdminNotice Y/N
				CoviMap managerMap = coviMapperOne.select("user.board.selectBoardManager", params);
				params.addAll(managerMap);
				if ("Y".equals(params.getString("isAdminNotice"))) {
					notifyCreateMessage(params);
				}
			}
			
			// 다중분류 처리
			if(params.getString("bizSection").equals("Doc")){
				coviMapperOne.delete("user.message.deleteMessageFolder", params);
				
				if((params.getString("multiFolderID") != null && !params.getString("multiFolderID").equals(""))){
					String multiFolderIDs[] = params.getString("multiFolderID").split(";");
					params.put("multiFolderIDs", multiFolderIDs);
					
					coviMapperOne.insert("user.message.createMessageFolder", params);
				}
				
			}
			
			//[본사운영] SCC - 품질관리 연동 start
			// 프로젝트에서는 지우셔도 됩니다...
			String domainID = SessionHelper.getSession("DN_ID");
			String useSCCBoard = RedisDataUtil.getBaseConfig("useSCCBoard", domainID);		 // SCC 연동 사용여부
			
			if(useSCCBoard.equalsIgnoreCase("Y")) {
				CoviMap sccBoardID = RedisDataUtil.getBaseCodeGroupDic("SCC_Error_BoardID");
				Iterator<String> keys = sccBoardID.keys();
				
				while(keys.hasNext()) {
					String key = keys.next();
					
					if(params.getString("folderID").equals(sccBoardID.getString(key))){
						params.put("folderType", key);
						updateSCCState(params);
						break;
					}
				}
			}
			//[본사운영] SCC - 품질관리 연동 end
		}
		return updateFlag;
	}
	
	/**
	 * 게시글 삭제 - 호출하는 DB스크립트 XML의 위치는 Admin과 동일
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int deleteMessage(CoviMap params) throws Exception {
		StringUtil func = new StringUtil();
		
		//게시글 정보  수정: board_message
		coviMapperOne.update("admin.message.updateCurrentFileSizeByMessage", params);
		int deleteFlag = coviMapperOne.update("admin.message.deleteMessage", params);
		
		if("C".equals(func.f_NullCheck(params.getString("CSMU")))){
			params.put("storageControl", MINUS);
			coviMapperOne.update("user.community.updateCurrentFileSizeByMessage", params);
		}
		
		if(deleteFlag > 0){
			coviMapperOne.delete("user.message.deleteMessageEvent", params);	//board_message_event: 웹파트 표시용 데이터 삭제
			//하위 게시글 검색
			params.put("messageIDs", coviMapperOne.select("admin.message.selectLowerMessageID", params).get("messageIDs"));
			params.put("messageIDArr", params.getString("messageIDs").split(","));
			if(params.get("messageIDs")!=null){
				coviMapperOne.update("admin.message.deleteLowerMessage", params);
			}
			coviMapperOne.insert("admin.message.createHistory", params);
		}
		return deleteFlag;
	}
	
	/**
	 * 임시 저장 게시물 삭제
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int deleteTempMessage(CoviMap params) throws Exception{
		StringUtil func = new StringUtil();

		if("update".equals(params.get("mode"))) {
			coviMapperOne.delete("user.message.deleteUserDefFieldValue", params);
			coviMapperOne.delete("user.message.deleteMessageDefFieldValue", params);
			coviMapperOne.delete("user.message.deleteMessageEvent", params);
		}
		
		//게시글 정보  수정: board_message
		coviMapperOne.update("admin.message.updateCurrentFileSizeByMessage", params);
		int deleteFlag = coviMapperOne.delete("admin.message.deleteTempMessage", params);
		
		if("C".equals(func.f_NullCheck(params.getString("CSMU")))){
			params.put("storageControl", MINUS);
			coviMapperOne.update("user.community.updateCurrentFileSizeByMessage", params);
		}
		
		if(deleteFlag > 0){
			coviMapperOne.delete("user.message.deleteMessageEvent", params);	//board_message_event: 웹파트 표시용 데이터 삭제
			//하위 게시글 검색
			params.put("messageIDs", coviMapperOne.select("admin.message.selectLowerMessageID", params).get("messageIDs"));
			params.put("messageIDArr", params.getString("messageIDs").split(","));
			if(params.get("messageIDs")!=null){
				coviMapperOne.update("admin.message.deleteLowerMessage", params);
			}
		}
		return deleteFlag;
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
				params.put("isSubInclude", aclObj.get("IsSubInclude"));
				params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
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
		if(StringUtil.isNotNull(params.getString("linkedMessage"))){
			CoviList linkArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(URLEncoder.encode(params.getString("linkedMessage"), "utf-8"), "utf-8"));
			for(int i=0;i<linkArray.size();i++){
				CoviMap linkObj = linkArray.getJSONObject(i);
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
		
		//사용자 정의 필드를 사용할 경우 fieldList변수 체크 수행
		if(StringUtil.isNotNull(params.get("fieldList"))){
			CoviList fieldArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("fieldList"), "utf-8"));
			
			for(int i=0;i<fieldArray.size();i++){
				CoviMap fieldObj = fieldArray.getJSONObject(i);
				cnt = 0;
				fieldObj.put("FieldValue", ComUtils.RemoveScriptTag(fieldObj.getString("FieldValue")));
				fieldObj.put("FieldText", ComUtils.RemoveScriptTag(fieldObj.getString("FieldText")));
				fieldArray.set(i, fieldObj);
				
				params.put("userFormID", fieldObj.get("UserFormID"));	//UserFormID
				params.put("fieldValue", fieldObj.get("FieldValue"));	//Field Value
				
				cnt = coviMapperOne.update("user.message.updateUserDefFieldValue", params);	//board_userform_value
				if (cnt == 0) {
					cnt = coviMapperOne.insert("user.message.createUserDefFieldValue", params);	//board_userform_value
				}
			}
			
			// 사용자 정의 필드값 재정 후 해당 메시지의 board_message_userform_value 데이터 재생성
			userDefFieldManageSvc.restoreUserDefFieldValue(params);
		}
		
		
		return cnt;
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
	
	//게시글 상세보기 내용 조회
	public CoviMap selectMessageDetail(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		boolean readFlagStr = Boolean.parseBoolean(params.getString("readFlagStr"));
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
		
		if(readFlagStr){
			//조회수 변경 및 조회기록 정보 추가
			int readFlag = (int) coviMapperOne.getNumber("user.message.selectMessageReader",params);
			if( readFlag == 0 ){
				coviMapperOne.insert("user.message.createMessageReader", params);
				coviMapperOne.update("user.message.updateReadCount", params);
			}
		}
		
		CoviMap messageDetail = new CoviMap();
		messageDetail.addAll(coviMapperOne.select("user.message.selectMessageDetail",params));
		return messageDetail;
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
			String creatorName = params.getString("creatorName");
			
			if(!creatorName.equals(DicHelper.getDic("lbl_Anonymity")) && !creatorName.equals("")) {
				params.put("creatorName", creatorName);
			}else {
				params.put("creatorName",DicHelper.getDic("lbl_Anonymity"));
			}
		} else {
			
			//[본사운영] 품질관리 - SCC 연동일 경우 세션값 조회하지 않음
			//관리자에서 커뮤니티 생성 시 운영자가 현재 세션이 아닐 수 있음
			if(!params.containsKey("sccKey") && params.getString("creatorCode").equals(SessionHelper.getSession("USERID"))) {
				params.put("URBG_ID", SessionHelper.getSession("URBG_ID"));
			}
			
			//sys_object_user_basegroup 테이블에서 작성자 정보 조회
			params.addAll(coviMapperOne.select("user.message.selectCreatorProfileData", params));
		}
	}

	//게시판, 문서관리 분기처리 후 parameter 설정
	public void setParamByBizSection(CoviMap params) throws Exception{
		String number = null;		//글번호, 문서번호
		String ownerCode = null;
		if("Board".equals(params.get("bizSection")) || "Community".equals(params.get("bizSection"))){	//일반 게시판 게시번호 발번 규칙
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
	
	//문서이관, 개정, 복사에 사용
	public void migrateMessageSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
			StringUtil func = new StringUtil();
		
			String uploadPath = params.getString("bizSection") + File.separator;	// Board, Doc를 붙여서 서비스 타입별 디렉터리 관리
			String orgPath = "";
			if("revision".equals(params.get("mode"))){
				orgPath = params.getString("bizSection") + File.separator;
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
	
	/**
	 * selectUserDefFieldValue
	 * @description 게시글별 사용자정의 필드 데이터 조회
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserDefFieldValue(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectUserDefFieldValue",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "UserFormID,FieldValue"));
		return resultList;
	}
	
	/**
	 * updateDefFieldValue
	 * @description 게시글별 사용자정의 필드 데이터 변경
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap updateUserDefFieldValueOne(CoviMap params) throws Exception {
		CoviMap resulrMap = new CoviMap();
		
		int result = coviMapperOne.update("user.message.updateMessageUserDefFieldValue", params);
		if (result == 0) result = coviMapperOne.insert("user.message.createUserDefFieldValue", params);
		
		// 게시글별 사용자정의 필드 데이터 변경 후 해당 메시지의 board_message_userform_value 값 재생성
		userDefFieldManageSvc.restoreUserDefFieldValue(params);
		
		coviMapperOne.insert("user.message.createHistory", params);
			
		resulrMap.put("status", Return.SUCCESS);
		resulrMap.put("updateCnt", result);
		
		return resulrMap;
	}
	
	/**
	 * moveMessage
	 * @description 게시글 이동
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public int moveMessage(CoviMap params) throws Exception {
		//1. 게시글 이동 전 용량 정보 수정
		params.put("storageControl", MINUS);
		coviMapperOne.update("user.message.updateCurrentFileSizeByMessage", params);
		//2. 게시물 이동
		int moveFlag = coviMapperOne.update("user.message.moveMessage", params);
		
		if(moveFlag > 0){
			//3. 게시글 첨부파일,본문 정보 FolderID변경
			params.put("seq", params.get("messageID"));
			params.put("depth", 0);
			params.put("step", 0);
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			
			coviMapperOne.update("user.message.moveMessageFile", params);
			coviMapperOne.update("user.message.moveMessageContents", params);
			
			// 사용자 정의필드 정보 삭제
			coviMapperOne.update("user.message.deleteUserDefFieldValue", params);
			coviMapperOne.update("user.message.deleteMessageDefFieldValue", params);
			
			//4. 처리 이력 기록
			coviMapperOne.insert("user.message.createHistory", params);
			coviMapperOne.insert("user.message.createMoveHistory", params);
			
			//5. 옮겨진 폴더의 사용중인 용량 정보 변경
			params.put("storageControl", PLUS);
			coviMapperOne.update("user.message.updateCurrentFileSizeByMessage", params);
		}
		return moveFlag;
	}

	/**
	 * copyMessage
	 * @description 게시글 복사, 문서관리에서는 사용하지 않음
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public int copyMessage(CoviMap params) throws Exception {
		//작성자 정보 조회 및 설정
		params.put("creatorCode", params.get("userCode"));
		params.put("ownerCode", params.get("userCode"));
		params.put("useAnonym", params.get("useAnonym"));
		params.put("creatorName", params.get("creatorName"));
		selectCreatorInfo(params);
		
		// 1.게시글 번호 생성
		params.put("numberingRule", RedisDataUtil.getBaseConfig("UseBoardCategoryNumber"));
		String number = coviMapperOne.getString("user.message.selectNumberByBoard", params);
		params.put("number", number);
		
		// 2.게시글 복사
		int moveFlag = coviMapperOne.insert("user.message.copyMessage", params);
		
		if(moveFlag > 0){
			String orgMessageID = params.getString("orgMessageID");
			
			// 3.게시글 첨부파일 용량 정보 변경
//			params.put("storageControl", PLUS);
			params.put("seq", params.get("messageID"));
			params.put("depth", 0);
			params.put("step", 0);
			params.put("orgMessageID", "");
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			
			// 4.첨부 파일, 본문 정보, 사용자저의 필드 정보 복사
//			coviMapperOne.update("user.message.copyMessageFile", params);
			List mf = new ArrayList();
			params.put("orgMessageID", orgMessageID);
			migrateMessageSysFile(params, mf);
			
			coviMapperOne.update("user.message.copyMessageContents", params);
//			coviMapperOne.update("user.message.copyMessageUserDefField", params);
			
			// 5. 처리 이력 기록
			coviMapperOne.insert("user.message.createHistory", params);
			coviMapperOne.insert("user.message.createCopyHistory", params);
		}
		return moveFlag;
	}
	
	/**
	 * scrapMessage
	 * @description 게시글 복사, 문서관리에서는 사용하지 않음
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public int scrapMessage(CoviMap params) throws Exception {
		// 1.게시글 스크랩
		params.put("creatorCode", params.get("userCode"));
		selectCreatorInfo(params);
		
		int moveFlag = coviMapperOne.insert("user.message.scrapMessage", params);
		if(moveFlag > 0){
			List mf = new ArrayList(); 
			migrateMessageSysFile(params, mf);
			
			coviMapperOne.insert("user.message.scrapMessageContents", params);
			return coviMapperOne.update("user.message.updateScrapMessageSeq", params);
		}
		return moveFlag;
	}
	
	@Override
	public int reportMessage(CoviMap params) throws Exception {
		// 1.신고 이력 생성
		coviMapperOne.insert("user.message.createHistory", params);
		coviMapperOne.insert("user.message.reportMessage", params);
		// 2. 게시 신고 회수 +1
		return coviMapperOne.update("user.message.updateMessageCnt", params);
	}

	@Override
	public int checkExistReport(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.checkExistReport", params);
	}
	
	
	//게시물 승인: 알림 기능 누락
	@Override
	public int acceptMessage(CoviMap params) throws Exception {
		// 1. sys_process_activity에서 step번호, substep 번호, LastStep번호 조회
		params.put("state", "7");
		params.addAll((CoviMap)coviMapperOne.selectOne("user.message.selectProcessActivityStep", params));
		params.addAll((CoviMap)coviMapperOne.selectOne("user.message.selectProcessActivitySubStep", params));
		params.addAll((CoviMap)coviMapperOne.selectOne("user.message.selectProcessActivityLastSubStep", params));
		params.addAll((CoviMap)coviMapperOne.selectOne("user.message.selectProcessActivityLastStep", params));
		
		// 2. 최종 승인 여부 확인
		if(params.getInt("step") == params.getInt("lastStep") && params.getInt("subStep") == (params.getInt("lastSubStep")-1)){
			//최종 승인
			// 3-1. 최종승인일 경우 sys_process_activity, sys_process, board_message 상태값 변경 
					//승인:7
			coviMapperOne.update("user.message.updateProcessActivity", params);
			coviMapperOne.update("user.message.updateProcess", params);
			coviMapperOne.update("user.message.updateMessageWorkState", params);
		
			//최종승인 알림
			notifyProcessComplete(params);
		} else {
			//최종승인이 아님
			// 3-2. 최종승인이 아닐 경우 다음 승인자 상태값 변경
			coviMapperOne.update("user.message.updateProcessActivity", params);
			
			if(params.getInt("subStep") == (params.getInt("lastSubStep")-1)){
				// 4. 병렬 승인자 확인 후 다음 승인자 상태값 변경
				params.put("step", params.getInt("step")+1);
				coviMapperOne.update("user.message.updateNextApproverState", params);
			}
			//승인 요청 게시글 정보 조회
			CoviMap notiParams = coviMapperOne.select("user.message.selectApprovalMessageInfo", params);
			notiParams.put("instanceID", params.get("processID"));
			notiParams.put("bizSection", params.get("bizSection"));
			notifyRequestProcess(notiParams);
		}
		return coviMapperOne.insert("user.message.createHistory", params);
	}
	
	
	@Override
	public int rejectMessage(CoviMap params) throws Exception {
		params.put("state", "9");	//거부: 9
		params.addAll((CoviMap)coviMapperOne.selectOne("user.message.selectProcessActivityStep", params));
		coviMapperOne.update("user.message.updateProcessActivity", params);
		coviMapperOne.update("user.message.updateProcessActivityParallel", params);
		coviMapperOne.update("user.message.updateProcess", params);
		coviMapperOne.update("user.message.updateMessageWorkState", params);
		
		notifyProcessReject(params);
		
		return coviMapperOne.insert("user.message.createHistory", params);
	}
	
	//체크아웃 상태 변경 전 확인
	@Override
	public int selectMessageCheckOutStatus(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectMessageCheckOutStatus", params);
	}
	
	//체크아웃 상태 변경
	@Override
	public int updateCheckOutState(CoviMap params) throws Exception{
		if("Out".equals(params.getString("actType"))){
			params.put("isCheckOut", "Y");
			params.put("checkOuterCode", params.get("userCode"));
		} else {
			params.put("isCheckOut", "N");
			params.put("checkOuterCode", null);
		}
		
		int updateFlag = coviMapperOne.update("user.message.updateCheckOutState", params);
		if(updateFlag > 0){
			if("Out".equals(params.getString("actType"))){
				coviMapperOne.insert("user.message.createCheckInOutHistory", params);
			} else if ("Renew".equals(params.getString("actType"))){
				params.put("version", params.getInt("version")+1);
				params.put("actType", "Revision");
				params.put("isCurrent", "N");
				coviMapperOne.insert("user.message.createCheckInOutHistory", params);
			} else {
				coviMapperOne.update("user.message.updateCheckInOutHistory", params);
			}
		}
		return 0;
	}
	
	//게시글 수정 요청
	@Override
	public int requestModifyMessage(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.message.createRequestModifyMessage", params);
	}
	
	// 이전글/다음글 조회
	@Override
	public CoviMap selectPrevNextMessage(CoviMap params ) throws Exception {
		CoviMap result = new CoviMap();
		if("Normal".equals(params.getString("boardType"))){
			result.addAll(coviMapperOne.select("user.message.selectNormalPrevNextMessage",params));
		} else {
			result.addAll(coviMapperOne.select("user.message.selectPrevNextMessage",params));
		}
		return result;
	}
	
	@Override
	public CoviMap selectBodyFormData(CoviMap params ) throws Exception {
		return coviMapperOne.select("user.message.selectBodyFormData",params);
	}
	
	@Override
	public CoviMap selectContentMessage(CoviMap params) throws Exception{
		return coviMapperOne.select("user.message.selectContentMessage", params);
	}
	
	@Override
	public CoviMap selectMessageOwner(CoviMap params) throws Exception{
		return coviMapperOne.select("user.message.selectMessageOwner", params);
	}
	
	@Override
	public String selectBoardGroupName(CoviMap params) throws Exception{
		return coviMapperOne.selectOne("user.message.selectBoardGroupName", params);
	}

	@Override
	public String selectMultiFolderName(CoviMap params) throws Exception{
		return coviMapperOne.selectOne("user.message.selectMultiFolderName", params);
	}
	
	@Override
	public int distributeDoc(CoviMap params) throws Exception{
		int cnt = 0;
		coviMapperOne.insert("user.message.createDistribution", params);
		
		if(params.get("distributeID") != null){
			CoviList targetArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("targetList"), "utf-8"));
			for(int i=0;i<targetArray.size();i++){
				CoviMap targetObj = targetArray.getJSONObject(i);
				params.put("targetType", targetObj.get("TargetType"));
				params.put("targetCode", targetObj.get("TargetCode"));
				coviMapperOne.insert("user.message.createDistributionTarget", params);			//배포대상자 정보 추가
				coviMapperOne.insert("user.message.updateDistributionTargetAuth", params);
				cnt += coviMapperOne.insert("user.message.createDistributionConfirm", params);	//배포문서 확인 정보 추가
				
				//문서 수신 알림
				CoviMap notiParams = coviMapperOne.select("user.message.selectMessageInfo", params);
				
				notiParams.put("ServiceType", "Doc");
				notiParams.put("MsgType", "DocReceived");//문서수신
				notiParams.put("bizSection", "Doc");
				params.addAll(notiParams);
				String goToUrl = createMessageUrl(params);
				String mobileUrl = createMessageMobileUrl(params);
				notiParams.put("PopupURL", goToUrl);
				notiParams.put("GotoURL", goToUrl);
				notiParams.put("MobileURL", mobileUrl);
				notiParams.put("MessagingSubject", params.getString("subject"));
				notiParams.put("MessageContext", createMessageContext(params));
				notiParams.put("ReceiverText", params.getString("subject"));
				notiParams.put("SenderCode", SessionHelper.getSession("USERID"));
				notiParams.put("RegistererCode", SessionHelper.getSession("USERID"));
				notiParams.put("ReceiversCode", targetObj.get("TargetCode"));
				MessageHelper.getInstance().createNotificationParam(notiParams);
				messageSvc.insertMessagingData(notiParams);
			}
		}
		return cnt;
	}
	
	//mobile
	//게시글 상세보기 내용 조회_simple
	@Override
	public CoviMap selectMessageDetailSimple(CoviMap params) throws Exception {
		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
		
		CoviMap result = new CoviMap();
		result.put("list", coviMapperOne.select("user.message.selectMessageDetailSimple", params));
		
		return result;
	}
	
	//게시글 조회자 리스트 조회
	@Override
	public CoviMap selectMessageViewerGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("user.message.selectMessageViewerGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,ReaderCode,DisplayName,JobPositionName,DeptName,ReadDate,ReaderPhoto"));
		return resultList;
	}
	
	//게시글 조회자 리스트 count 조회
	@Override
	public int selectMessageViewerGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectMessageViewerGridCount", params);
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
//		notiParams.put("MessagingSubject", "[답글 알림]" + params.getString("subject"));
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
//		notiParams.put("ReceiverText", "[답글 알림]" + params.getString("subject"));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("ownerCode"));		//원본글 소유자
		notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
		notiParams.put("ReservedStr1", params.getString("ReservedStr1"));
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
			
			// 등록알림 수신자, 제외자에 대한 파라미터 처리
			String receivers = (String)params.get("Receivers");
			String excepters = (String)params.get("Excepters");
			if (receivers == null) receivers = "";
			if (excepters == null) excepters = "";
			
			// 예약 게시일 경우 IsDelay = Y, ReservedDate 예약게시일
			if(params.has("reservationDate") && !"".equals(params.getString("reservationDate"))) {
				notiParams.put("IsDelay", "Y");
				notiParams.put("ReservedDate", params.get("reservationDate"));
			}
			
			// 게시분류 담당자
			String categoryManagerCode = "";
			if(params.has("categoryManagerCode") && !"".equals(params.getString("categoryManagerCode"))) {
				categoryManagerCode = params.getString("categoryManagerCode");
			}
			
			notiParams.put("ServiceType", params.getString("bizSection"));
			notiParams.put("MsgType", "BoardMsgRegi");
			notiParams.put("PopupURL", goToUrl);
			notiParams.put("GotoURL", goToUrl);
			notiParams.put("MobileURL", mobileUrl);
			notiParams.put("MessagingSubject", params.getString("subject"));
			notiParams.put("MessageContext", createMessageContext(params));
			// notiParams.put("ReceiverText", "[등록 알림]" + params.getString("subject"));
			notiParams.put("ReceiverText", params.getString("subject"));
			notiParams.put("SenderCode", params.getString("userCode"));
			notiParams.put("RegistererCode", params.getString("userCode"));
			notiParams.put("ReceiversCode", receivers.concat(";").concat(managerCode).concat(";").concat(categoryManagerCode).replaceAll(";;", ";")); // 등록알림 수신자 (게시분류에 담당자가 있으면 추가)
			notiParams.put("ExceptersCode", excepters.replaceAll(";;", ";")); // 등록알림 제외자
			notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
			notiParams.put("ReservedStr1", params.getString("ReservedStr1"));
			
			// 예약게시글 삭제를 위해 messageID 등록
			notiParams.put("MessageID", params.getString("messageID"));
			 
			MessageHelper.getInstance().createNotificationParam(notiParams);
			messageSvc.insertMessagingData(notiParams);
		} else {
			//TODO: 게시판 담당자가 존재 하지 않을때 처리, 화면단에서는 필수 입력값이므로 별도 처리는 하지 않음
		}
	}
	
	//승인 요청 알림
	public void notifyRequestProcess(CoviMap params) throws Exception{
		String approverCode = coviMapperOne.selectOne("user.message.selectNextApprover", params);
		CoviMap notiParams = new CoviMap();
		String bizSection = params.getString("bizSection");
		
		notiParams.put("ServiceType", bizSection);
		notiParams.put("MsgType", "ApprovalRequest_"+bizSection);
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
	
	/**
	 * 게시글 승인 완료
	 * @param CoviMap params
	 * 	userCode
	 *  processID
	 *  messageID
	 *  
	 * @throws Exception
	 */
	//TODO: 승인완료/반려의 경우 parameter 추가하여 처리 가능 하지만 추가 알림 기능에 따라 취합 예정
	public void notifyProcessComplete(CoviMap params) throws Exception{
		CoviMap notiParams = coviMapperOne.select("user.message.selectMessageInfo", params);
		String bizSection = params.getString("bizSection");
		
		notiParams.put("ServiceType", bizSection);
		notiParams.put("MsgType", "ApprovalCompleted_"+bizSection);		//게시 승인 완료
		params.addAll(notiParams);
		
		String goToUrl = createMessageUrl(params);
		String mobileUrl = createMessageMobileUrl(params);
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", mobileUrl);
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));				//최종승인자 (세션)
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("creatorCode"));		//게시 작성자
		notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}
	
	/**
	 * 게시글 반려 알림
	 * @param params
	 * @throws Exception
	 */
	//TODO: 승인완료/반려의 경우 parameter 추가하여 처리 가능 하지만 추가 알림 기능에 따라 취합 예정
	public void notifyProcessReject(CoviMap params) throws Exception{
		CoviMap notiParams = coviMapperOne.select("user.message.selectMessageInfo", params);
		String bizSection = params.getString("bizSection");
		
		notiParams.put("ServiceType", bizSection);
		notiParams.put("MsgType", "Reject_"+bizSection);		//게시 반려
		params.addAll(notiParams);
		
		String goToUrl = createMessageUrl(params);
		String mobileUrl = createMessageMobileUrl(params);
		
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", mobileUrl);
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));				//현재 승인자
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("creatorCode"));		//게시 작성자
		notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}
	
	
	/**
	 * [본사운영] 품질관리 - SCC 연동: 게시 등록 API 
	 * @return createFlag
	 * @throws Exception
	 */
	@Override
	public int createSCCMessage(CoviMap params) throws Exception {
		//작성자 정보 조회 및 설정
		params.put("creatorCode", params.get("userCode"));
		selectCreatorInfo(params);
		setParamByBizSection(params);
		
		//게시글 정보  추가: board_message
		int createFlag = 0;
		params.put("version", "1");	//생성시에는 무조건 버전 1로 고정 
		createFlag = coviMapperOne.insert("user.message.createMessage", params);
		params.put("seq", params.get("messageID"));
		
		if(createFlag > 0 || params.get("messageID") != null ){
			createFlag = 1; 
			//Editor 처리 - SCC 연동 시 불필요
			
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			coviMapperOne.insert("user.message.createContents", params);
			coviMapperOne.insert("user.message.insertSCCMappingInfo", params); 
			
			if(StringUtil.isNotNull(params.get("aclList"))){
				CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("aclList"), "utf-8"));
				for(int i = 0; i < aclArray.size(); i++){
					CoviMap aclObj = aclArray.getJSONObject(i);
					String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
					params.put("messageID", params.get("messageID"));
					params.put("version", params.get("version"));			//문서관리용 버전
					params.put("targetCode", aclObj.get("SubjectCode"));	//대상객체 코드
					params.put("targetType", aclObj.get("SubjectType"));	//대상객체 유형
					params.put("aclList", aclShard[0]+aclShard[1]+aclShard[2]+aclShard[3]+aclShard[4]+aclShard[6]);
					params.put("security", aclShard[0]);
					params.put("create", aclShard[1]);
					params.put("delete", aclShard[2]);
					params.put("modify", aclShard[3]);
					params.put("execute", aclShard[4]);
					params.put("read", aclShard[6]);
					params.put("description", "");
					params.put("isSubInclude", aclObj.get("IsSubInclude"));
					params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
					params.put("registerCode", SessionHelper.getSession("USERID"));
					coviMapperOne.insert("user.message.createMessageAuth", params);	//messageReadAuth 데이터 insert
				}
				
			}
			
			CoviMap userFormID = getSCCUserFormID(params.getString("folderType"));
			
			CoviList userFormList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.message.selectSCCUserForm", params),"UserFormID,FieldText,FieldValue");
			
			for(Object map : userFormList) {
				CoviMap userForm = (CoviMap)map;
				
				if(userForm.getString("UserFormID").equals(userFormID.getString("projectName"))) {
					userForm.put("FieldText", params.getString("projectName"));
					userForm.put("FieldValue", params.getString("projectName"));
					
					break;
				}
			}
			
			
			params.put("fieldList", userFormList.toString());
			
			updateUserDefFieldValue(params);
		}
		return createFlag;
	}
	
	/**
	 * [본사운영] 품질관리 - SCC 연동: 사용자 정의 필드 조회
	 * @return userFormID
	 * @throws Exception
	 */
	private CoviMap getSCCUserFormID(String folderType) throws Exception {
		CoviList userFormBaseCode = new CoviList();
		CoviMap userFormID = new CoviMap();
		
		String type="Error";
		String key = "SCC_" + folderType + type + "UserForm";		//ex. SCC_CPErrorUserForm, SCC_MPErrorUserForm 등
		
		userFormBaseCode = RedisDataUtil.getBaseCode(key);
		
		for(Object obj : userFormBaseCode) {
			CoviMap jsonObj = (CoviMap)obj;
			userFormID.put(jsonObj.getString("Code"), jsonObj.getString("CodeName"));
		}
		
		return userFormID;
	}
	
	private void updateSCCState(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap userFormID = new CoviMap(); //parameter 별 userformID 값 
		CoviMap resultMap = new CoviMap();
		
		CoviMap sccInfo = coviMapperOne.select("user.message.selectSCCKey", params);
		
		if(sccInfo.isEmpty() || !sccInfo.containsKey("SCCKey") || sccInfo.getString("SCCKey").isEmpty()) { //SCC 연동 아닐경우
			return ;
		}
		
		String sccKey = sccInfo.getString("SCCKey");
		String sccType = Objects.toString(sccInfo.get("SCCType"), "CS");

		resultMap.put("key", sccKey);
		resultMap.put("folderType", params.getString("folderType"));
		
		userFormID = getSCCUserFormID(params.getString("folderType"));
		
		if(StringUtil.isNotNull(params.get("fieldList"))){
			CoviList fieldArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("fieldList"), "utf-8"));
			
			for(int i=0;i<fieldArray.size();i++){
				CoviMap fieldObj = fieldArray.getJSONObject(i);
				
				if(fieldObj.getString("UserFormID").equals(userFormID.getString("state"))){
					resultMap.put("state", fieldObj.getString("FieldValue"));
				}else if(fieldObj.getString("UserFormID").equals(userFormID.getString("manager_name"))) {
					resultMap.put("manager_name", fieldObj.getString("FieldValue"));
				}else if(fieldObj.getString("UserFormID").equals(userFormID.getString("duedate"))) {
					resultMap.put("duedate", fieldObj.getString("FieldValue"));
				}else if(fieldObj.getString("UserFormID").equals(userFormID.getString("reason"))) {
					resultMap.put("reason_code", fieldObj.getString("FieldValue"));
					resultMap.put("reason_text", fieldObj.getString("FieldText"));
				}
			}
		
			String url = "";
			
			if(sccType.equalsIgnoreCase("HR")) {
				url = RedisDataUtil.getBaseConfig("sccUpdateStateURL_HR"); 
			}else {
				url = RedisDataUtil.getBaseConfig("sccUpdateStateURL"); 
			}
			
			
			String bodydata = "<?xml version='1.0' encoding='utf-8'?>";
			bodydata += "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>";
			bodydata += "<soap:Body>";
			bodydata += "<UpdateProgressState xmlns='http://tempuri.org/'>";
			bodydata += "<key>" + resultMap.getString("key") + "</key>";
			bodydata += "<folderType>" + resultMap.getString("folderType") + "</folderType>";
			bodydata += "<state>" + resultMap.getString("state") + "</state>";
			bodydata += "<manager_name>" + resultMap.getString("manager_name") + "</manager_name>";
			bodydata += "<duedate>" + resultMap.getString("duedate") + "</duedate>";
			bodydata += "<reason_code>" + resultMap.getString("reason_code") + "</reason_code>";
			bodydata += "<reason_text>" + resultMap.getString("reason_text") + "</reason_text>";
			bodydata += "</UpdateProgressState>";
			bodydata += "</soap:Body>";
			bodydata += "</soap:Envelope>";
			
			HttpClientUtil httpClient = new HttpClientUtil();
			
			resultList = httpClient.httpClientNetConnect(url, bodydata, "POST");
			
			int status = (int) resultList.get("status");
			
			String reMsg = resultList.get("body").toString().toLowerCase();
			
		}
		
	}
	
	
	public String createMessageUrl(CoviMap params){
		//returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");			// Domain
		
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		
		String returnUrl = "";
		
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();
		  
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");			// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");	
		}
		
		//승인 요청 게시 메뉴 URL로 생성 else 게시 상세보기 URL생성
		if(params.getString("bizSection").equals("Board") || params.getString("bizSection").equals("Community")){
			if(params.getString("MsgType").indexOf("ApprovalRequest_") > -1){
				returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardList.do");	// {Domain}/groupware/layout/board_BoardList.do
				returnUrl += "?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Approval&menuID=" + params.get("menuID");
			}else{
				returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardView.do");	// {Domain}/groupware/layout/board_BoardView.do
				returnUrl += "?CLSYS=board&CLMD=user&CLBIZ=Board";
				returnUrl += String.format("&menuID=%s&version=1&folderID=%s&messageID=%s", params.get("menuID"), params.get("folderID"), params.get("messageID")) ;
				returnUrl += "&viewType=List&boardType=Normal&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&page=1&pageSize=10";
			}
			
			if (!params.getString("menuCode").equals("")){	// 메뉴코드가 있는 경우 url에 포함
				returnUrl += "&menuCode="+params.getString("menuCode");
			} else if (!params.getString("menuID").equals("")){
				CoviMap menuParams = new CoviMap(params);
				menuParams.put("domainID", SessionHelper.getSession("DN_ID"));
				CoviMap menuCodeMap = this.coviMapperOne.select("user.board.seleceMenuCode", menuParams);
				if (!"".equals(menuCodeMap.getString("MenuCode"))) {
					returnUrl += "&menuCode=" + menuCodeMap.getString("MenuCode");
				}
			}
			
			if (!params.getString("communityId").equals("")){//커뮤니티인 경우 
				returnUrl += "&CSMU=C&communityId="+params.getString("communityId");
			}
		}else if(params.getString("bizSection").equals("Doc")){
			if(params.getString("MsgType").indexOf("ApprovalRequest_") > -1){
				returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardList.do");	// {Domain}/groupware/layout/board_BoardList.do
				returnUrl += "?CLSYS=doc&CLMD=user&CLBIZ=Doc&boardType=Approval&menuID=" + params.get("menuID");
			}
			else if(params.getString("MsgType").indexOf("DocReceived") > -1){
				returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardList.do");	// {Domain}/groupware/layout/board_BoardList.do
				returnUrl += "?CLSYS=doc&CLMD=user&CLBIZ=Doc&boardType=DistributeDoc";
			}
			else{
				returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardView.do");	// {Domain}/groupware/layout/board_BoardView.do
				returnUrl += "?CLSYS=doc&CLMD=user&CLBIZ=Doc";
				returnUrl += String.format("&menuID=%s&version=1&folderID=%s&messageID=%s", params.get("menuID"), params.get("folderID"), params.get("messageID")) ;
				returnUrl += "&viewType=List&boardType=Normal&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&page=1&pageSize=10";
			}
		}
		
		return returnUrl;
	}
	
	public String createMessageMobileUrl(CoviMap params){
		String returnUrl = "";
		
		//승인 요청 게시 메뉴 URL로 생성 else 게시 상세보기 URL생성
		if(params.getString("bizSection").equals("Board")){
			if(params.getString("MsgType").indexOf("ApprovalRequest_") > -1){
				returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "list.do");	// {Domain}/groupware/mobile/board/list.do
				returnUrl += "?boardtype=Approval";
			}else{
				returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "view.do");	// {Domain}/groupware/mobile/board/view.do
				returnUrl += "?boardtype=Normal";
				returnUrl += "&folderid=" + params.get("folderID");
				returnUrl += "&messageid=" + params.get("messageID");
				returnUrl += "&cuid=";
				returnUrl += "&version=1";
				returnUrl += "&page=1&searchtext=";
			}
			
			if (!params.getString("menuCode").equals("")){	// 메뉴코드가 있는 경우 url에 포함
				returnUrl += "&menucode="+params.getString("menuCode");
			} else if (!params.getString("menuID").equals("")){
				CoviMap menuParams = new CoviMap(params);
				menuParams.put("domainID", SessionHelper.getSession("DN_ID"));
				CoviMap menuCodeMap = this.coviMapperOne.select("user.board.seleceMenuCode", menuParams);
				if (!"".equals(menuCodeMap.getString("MenuCode"))) {
					returnUrl += "&menucode=" + menuCodeMap.getString("MenuCode");
				}
			}
		}else if(params.getString("bizSection").equals("Doc")){
			if(params.getString("MsgType").indexOf("ApprovalRequest_") > -1){
				returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "doc", "list.do");	// {Domain}/groupware/mobile/doc/list.do
				returnUrl += "?menucode=DocMain&boardtype=DocTotal";
			}
			else if(params.getString("MsgType").indexOf("DocReceived") > -1){
				returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "doc", "list.do");	// {Domain}/groupware/mobile/doc/view.do
				returnUrl += "?menucode=DocMain&boardtype=DocTotal";
			}
			else{
				returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "doc", "view.do");	// {Domain}/groupware/mobile/doc/view.do
				returnUrl += "?boardtype=Normal";
				returnUrl += "&folderid=" + params.get("folderID");
				returnUrl += "&messageid=" + params.get("messageID");
				returnUrl += "&cuid=";
				returnUrl += "&version=1";
				returnUrl += "&page=1&searchtext=";
			}
		}
		
		return returnUrl;
	}
	
	
	public String createMessageContext(CoviMap params){
		return params.getString("subject");
		//공통으로 처리
		/*
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
		return strHTML;*/
	}
	@Override
	public int createMailToMessage(CoviMap params, List<MultipartFile> mf) throws Exception {
		//작성자 정보 조회 및 설정
		params.put("creatorCode", params.get("userCode"));
		selectCreatorInfo(params);
		setParamByBizSection(params);
		
		//게시글 정보  추가: board_message
		int createFlag = 0;
		params.put("version", "1");	//생성시에는 무조건 버전 1로 고정 
		createFlag = coviMapperOne.insert("user.message.createMessage", params);
		params.put("seq", params.get("messageID"));
		
		if(createFlag > 0 || params.get("messageID") != null ){
			createFlag = 1; 
			//Editor 처리
		    CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "Board");  //BizSection
		    editorParam.put("imgInfo", params.getString("bodyInlineImage"));
			editorParam.put("backgroundImage", params.getString("bodyBackgroundImage"));
		    editorParam.put("objectID", params.getString("folderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", params.getString("messageID"));  
		    editorParam.put("frontStorageURL", params.getString("frontStorageURL"));  
		    editorParam.put("bodyHtml",params.getString("body"));
		    editorParam.put("isMailToBoardYn", "Y");
			
		    CoviMap editorInfo = editorService.getEscapeContent(editorParam);
		    
            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
            	throw new Exception("InlineImage move BackStorage Error");
            }
		    
		    params.put("body", editorInfo.getString("BodyHtml"));
		    params.put("bodySize", editorInfo.getString("BodyHtml").length());
			
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			coviMapperOne.insert("user.message.createContents", params);
			
			if(StringUtil.isNotNull(params.get("aclList"))){
				CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("aclList"), "utf-8"));
				for(int i = 0; i < aclArray.size(); i++){
					CoviMap aclObj = aclArray.getJSONObject(i);
					String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
					params.put("messageID", params.get("messageID"));
					params.put("version", params.get("version"));			//문서관리용 버전
					params.put("targetCode", aclObj.get("SubjectCode"));	//대상객체 코드
					params.put("targetType", aclObj.get("SubjectType"));	//대상객체 유형
					params.put("aclList", aclShard[0]+aclShard[1]+aclShard[2]+aclShard[3]+aclShard[4]+aclShard[6]);
					params.put("security", aclShard[0]);
					params.put("create", aclShard[1]);
					params.put("delete", aclShard[2]);
					params.put("modify", aclShard[3]);
					params.put("execute", aclShard[4]);
					params.put("read", aclShard[6]);
					params.put("description", "");
					params.put("isSubInclude", aclObj.get("IsSubInclude"));
					params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
					params.put("registerCode", SessionHelper.getSession("USERID"));
					coviMapperOne.insert("user.message.createMessageAuth", params);	//messageReadAuth 데이터 insert
				}
				
			}
			
			if("migrate".equals(params.get("mode")) || "revision".equals(params.get("mode"))){	//개정의 경우 파일 삭제가 존재 하지 않고 추가, 복사만 존재하기 때문에 별도 구현
				migrateMessageSysFile(params, mf);
			} else {
				updateMessageSysFile(params, mf);
			}
		}
		return createFlag;
	}
	
	//문서 권한요청을 위한 기본적인 메세지 정보 조회 (제목, 소유자)
	public CoviMap selectRequestAuthMessageInfo(CoviMap params) throws Exception {		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
		
		CoviMap msgData = new CoviMap();
		msgData.addAll(coviMapperOne.select("user.message.selectRequestAuthMessageInfo",params));
		return msgData;
	}
	// 웹파트 추천영상 데이터 조회
	public CoviMap selectMovieBoardList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("webpart.board.selectMovieBoardList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,MenuID,Subject,RegistDate,ReadCnt,CreatorCode,CreatorLevel,CreatorPosition,CreatorTitle,CreatorName,ServiceType,FilePath,SavedName,FullPath,FileID,Extention"));
		
		return resultList;
	}
	
	public CoviMap getMessageInfo(CoviMap pParams) {
		CoviMap returnMap = new CoviMap();
		CoviMap msgMap = coviMapperOne.select("user.message.selectMessageInfo", pParams);
		returnMap.put("MenuID", msgMap.getString("menuID"));
		returnMap.put("FolderID", msgMap.getString("folderID"));
		returnMap.put("MessageID", msgMap.getString("messageID"));
		returnMap.put("Version", msgMap.getString("version"));
		returnMap.put("CreatorCode", msgMap.getString("creatorCode"));
		returnMap.put("Subject", msgMap.getString("subject"));
		return returnMap;
	}
	
	public void createFileDownloadToMessageReader(CoviMap params) throws Exception {
		int readFlag = (int) coviMapperOne.getNumber("user.message.selectMessageReader",params);

		if(readFlag == 0){
			coviMapperOne.insert("user.message.createMessageReader", params);
			coviMapperOne.update("user.message.updateReadCount", params);
		}
	}
	
}
