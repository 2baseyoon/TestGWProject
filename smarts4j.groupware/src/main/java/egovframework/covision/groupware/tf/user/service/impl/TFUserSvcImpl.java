package egovframework.covision.groupware.tf.user.service.impl;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.spec.KeySpec;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.StringTokenizer;

import javax.annotation.Resource;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
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
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.tf.user.service.TFUserSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("TFUserSvc")
public class TFUserSvcImpl extends EgovAbstractServiceImpl implements TFUserSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private MessageSvc boardMessageSvc;
	
	private static Logger LOGGER = LogManager.getLogger(TFUserSvcImpl.class);
	
	@Override
	public CoviMap selectUserJoinTF(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserJoinTF", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText,FilePath"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap selectUserTempTFGridList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserTempTFGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "CU_ID,TF_DN_ID,SearchTitle,CommunityName,CreatorCode,TF_MajorDept,RegistDate,TF_Period,TF_PM,TF_Admin,TF_AdminCount,TF_Member,TF_MemberCount,num"));
		
		return returnObj;
	}
	
	@Override
	public int selectUserTempTFGridListCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.selectUserTempTFGridListCount", params);
	}
	
	@Override
	public boolean deleteTempTFTeamRoom(CoviMap params) throws Exception {
		String[] arrCU_ID = params.getString("CU_IDs").split(",");
		int cnt = 0;
		boolean flag = false;
		
		for(int i = 0; i < arrCU_ID.length; i++) {
			params.put("CU_ID", arrCU_ID[i]);
			params.put("ServiceType", "Community");//TFRoom
			params.put("ObjectType", "TF");
			
			cnt = coviMapperOne.delete("user.tf.deleteTempTFTeamRoom", params);
			
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				break;
			}
		}
		
		return flag;
	}
	
	@Override
	public CoviMap selectUserTFGridList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserTFGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,AppStatus,AppStatusName,RegRequestDate,RegProcessDate,MemberCount,MsgCount,VisitCount,Point,Grade,OperatorCode,OperatorName,TF_DN_ID,TF_DomainName,TF_DeptCode,DomainCode,GroupCode,CreatorCode,CreatorName,Description,DescriptionEditor,FilePath,TF_Period,DisplayName,UserCode,MailAddress,CuAppDetail,CommunityJoin,CommunityType,num,TF_PM,TF_Admin,TF_Member,MEMBER_CNT,TF_PM_CODE,TF_PM_MAIL"));
		
		return returnObj;
	}
	
	@Override
	public int selectUserTFGridListCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.selectUserTFGridListCount", params);
	}
	
	@Override
	public CoviMap selectUserMyTFGridList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserMyTFGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,AppStatus,AppStatusName,RegRequestDate,RegProcessDate,MemberCount,MsgCount,VisitCount,Point,Grade,SearchSummary,OperatorCode,OperatorName,DomainCode,GroupCode,CreatorCode,CreatorName,Description,DescriptionEditor,FilePath,UR_Code,TF_Period,DisplayName,UserCode,MailAddress,CuAppDetail,CommunityJoin,CommunityType,num,TF_PM,TF_Admin,TF_Member,TF_AVGProgress,TF_WProgress"));
		
		return returnObj;
	}
	
	@Override
	public int selectUserMyTFGridListCount(CoviMap params) throws Exception {
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		return (int) coviMapperOne.getNumber("user.tf.selectUserMyTFGridListCount", params);
	}
	
	@Override
	public CoviMap selectUserAdminTFGridList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserAdminTFGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,AppStatus,AppStatusName,RegRequestDate,RegProcessDate,MemberCount,MsgCount,VisitCount,Point,Grade,SearchSummary,OperatorCode,OperatorName,DomainCode,GroupCode,CreatorCode,CreatorName,Description,DescriptionEditor,FilePath,TF_Period,CuAppDetail,CommunityJoin,CommunityType,num,TF_PM,TF_Admin,TF_Member"));
		
		return returnObj;
	}
	
	@Override
	public int selectUserAdminTFGridListCount(CoviMap params) throws Exception {
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
				
		return (int) coviMapperOne.getNumber("user.tf.selectUserAdminTFGridListCount", params);
	}

	@Override
	public String selectMemberGrade(CoviMap params) throws Exception {
		String value = "";

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		value = coviMapperOne.getString("user.tf.selectMemberGrade", params);
		
		return value;
	}
	
	@Override
	public String deleteTFTeamRoom(CoviMap params) throws Exception {
		CoviMap delACL = new CoviMap();
		String register = null;
		String memberLevel = null;
		String communityName = null;
		
		String PMLevel = RedisDataUtil.getBaseConfig("TFPMLevel");
		String AdminLevel = RedisDataUtil.getBaseConfig("TFAdminLevel");
		String userCode = SessionHelper.getSession("UR_Code");
		
		int cnt = 0;
		String noACL = "";
		String[] arrCU_ID = params.getString("CU_IDs").split(",");
		
		for(int i = 0; i < arrCU_ID.length; i++) {
			CoviMap aclParams = new CoviMap();
			aclParams.put("CU_ID", arrCU_ID[i]);
			aclParams.put("UR_Code", userCode);
			
			delACL = coviMapperOne.select("user.tf.selectDeleteACL", aclParams);
			
			register = delACL.containsKey("Register") ? delACL.getString("Register") : "";
			memberLevel = delACL.containsKey("MemberLevel") ? delACL.getString("MemberLevel") : "";
			communityName = delACL.getString("CommunityName");
			
			if((!memberLevel.equals("") && (memberLevel.equals(PMLevel) || memberLevel.equals(AdminLevel))) || (!register.equals("") && register.equals(userCode))){
				cnt = coviMapperOne.update("user.tf.deleteTFTeamRoom", aclParams);
				
				if(cnt <= 0) {
					noACL = "ERROR";
					break;
				}
			}else{
				noACL += communityName + ",";
			}
		}
		
		return noACL;
	}
	
	@Override
	public boolean updateTFTeamRoomStatus(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = true;
		String AppStatus = params.getString("AppStatus");
		StringUtil func = new StringUtil();
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		switch(AppStatus) {
		case "RV":
		case "RS":
			params.put("RegStatus", "R");
			params.put("IsUse", "Y");
			params.put("IsDisplay", "Y");
			params.put("DateFieldName", "RegProcessDate");
			break;
		case "RD":
			params.put("RegStatus", "P");
			params.put("DateFieldName", "RegProcessDate");
			break;
		case "UV":
		case "UF":
			params.put("RegStatus", "U");
			params.put("IsDisplay", "N");
			params.put("DateFieldName", "UnRegProcessDate");
			break;
		case "UD":
			params.put("RegStatus", "R");
			params.put("DateFieldName", "UnRegProcessDate");
			break;
		default:
			flag = false;
		}
		
		if(flag) {
			cnt = coviMapperOne.update("user.tf.updateTFTeamRoomStatus", params);
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				if(params.getString("IsDisplay") != null && !params.getString("IsDisplay").equals("")){
					coviMapperOne.update("user.tf.updateTFTeamRoomDisplayStatus", params);
				}
			}
			
			if(cnt < 0) 
				flag = false;
		}
		
		return flag;
	}
	
	@Override
	public boolean updateTFTeamRoom(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) {
		int cnt = 0;
		boolean flag = false;
		
		try {
			cnt = coviMapperOne.update("user.tf.updateTFInfomation", params);
			if(cnt > 0){
				//Editor 처리
				CoviMap editorParam = new CoviMap();
				editorParam.put("serviceType", "Community");//TFRoom
				editorParam.put("objectID", "0");
				editorParam.put("objectType", "TF");
				editorParam.put("messageID", params.getString("CU_ID"));
				editorParam.put("imgInfo", params.getString("txtContentInlineImage"));
				editorParam.put("bodyHtml",params.getString("txtContentEditer"));
				
				CoviMap ContentEditorInfo = editorService.getContent(editorParam);
				
	            if(ContentEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
	            	throw new Exception("InlineImage move BackStorage Error");
	            }
				
				params.put("txtContentEditor", ContentEditorInfo.getString("BodyHtml"));
				
				cnt = coviMapperOne.update("user.tf.updateTFDetailInfomation", params);
				if(cnt > 0){
					if(fileInfos != null) {
						CoviMap filesParams = new CoviMap();
						filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
						filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
						filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
						filesParams.put("MessageID", params.getString("CU_ID"));
						filesParams.put("ObjectID", "0");
						filesParams.put("ObjectType", "TF");
						updateTFSysFile(filesParams, mf);
					}
				}else{
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			// TF팀룸 멤버 추가
			if(!TFMember(params.getString("CU_ID"), params.getString("txtTFCode"), params.getString("txtPMCode"), params.getString("txtAdminCode"), params.getString("txtMemberCode"))){
				throw new Exception("");
			}
			
			flag = true;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
		}
		
		return flag;
	}
	
	@Override
	public int checkTFNameCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.checkTFNameCount", params);
	}
	
	@Override
	public int checkTFCodeCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.checkTFCodeCount", params);
	}
	
	@Override
	public boolean tempSaveTFTeamRoom(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		int existCnt = (int) coviMapperOne.getNumber("user.tf.selectTempSaveTFTeamRoom", params);
		
		if(existCnt == 0) {
			cnt = coviMapperOne.insert("user.tf.tempSaveTFTeamRoom", params);
		} else {
			cnt = coviMapperOne.insert("user.tf.updateTempSaveTFTeamRoom", params);
		}
		
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community");//TFRoom
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", params.getString("CU_ID"));
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "TF");
			if(existCnt == 0) {
				insertTFSysFile(filesParams, mf);
			} else {
				updateTFSysFile(filesParams, mf);
			}
		}
		
		if(cnt > 0 || (existCnt == 0 && params.get("CU_ID") != null)){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	@Override
	public CoviMap createTFTeamRoom(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf){
		CoviMap returnObj = new CoviMap();
		
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		int cnt = 0;
		boolean flag = false;
		String tempCID = params.getString("CU_ID");
		
		try {
			cnt = coviMapperOne.insert("user.tf.createTFInfomation", params);
			
			returnObj.put("CU_ID", params.getString("CU_ID"));
			
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("CU_ID") != null){
				//Editor 처리
				CoviMap editorParam = new CoviMap();
				editorParam.put("serviceType", "Community");//TFRoom
				editorParam.put("objectID", "0");
				editorParam.put("objectType", "TF");
				editorParam.put("messageID", params.getString("CU_ID"));
				editorParam.put("imgInfo", params.getString("txtContentInlineImage"));
				editorParam.put("bodyHtml",params.getString("txtContentEditer"));
				
				CoviMap ContentEditorInfo = editorService.getContent(editorParam);
				
	            if(ContentEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
	            	throw new Exception("InlineImage move BackStorage Error");
	            }
				
				params.put("txtContentEditor", ContentEditorInfo.getString("BodyHtml"));
				
				cnt = coviMapperOne.insert("user.tf.createTFDetailInfomation", params);
				if(cnt > 0){
					if(fileInfos != null){
						CoviMap filesParams = new CoviMap();
					filesParams.put("ServiceType","Community");//fileInfos.getString("ServiceType")
						filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
						filesParams.put("MessageID", params.getString("CU_ID"));
						filesParams.put("ObjectID", "0");
						filesParams.put("ObjectType", "TF");
						insertTFSysFile(filesParams, mf);
					}
					
					params.put("ObjectID", params.get("CU_ID"));
					params.put("RegStatus", "P");
					params.put("AppStatus", "RA");
				}else{
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				//TODO : Oracle 쿼리 추가 필요
				//cnt = coviMapperOne.update("user.tf.createTFInfomationCode", params);
				//if(cnt < 1){
				//	throw new Exception("");
				//}
			}
			
			cnt = coviMapperOne.update("user.tf.updateTFStatus", params);
			if(cnt > 0){
				subParams = coviMapperOne.select("user.tf.selectTFInfo", params);
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.insert("user.tf.createObjectGroup", subParams);
			if(cnt > 0){
				if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
					//TODO : Oracle 쿼리 추가 필요
					subParams.put("comObjectPath", coviMapperOne.selectOne("user.tf.selectComObjectPath", subParams));
					subParams.put("sortPath", coviMapperOne.selectOne("user.tf.selectSortPath", subParams));
				}
				
				cnt = coviMapperOne.update("user.tf.updateObjectGroup", subParams);
				if(cnt > 0){
					params.put("IsDisplay",'Y');
					params.put("IsUse",'Y');
				}else{
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.update("user.tf.updateTFGroupCode", params);
			if(cnt > 0){
				//SUCCESS
			}else{
				throw new Exception("");
			}
			
			//커뮤니티 홈 체크
			if(coviMapperOne.getNumber("user.tf.selectCommunityHomeCount", params) > 0){
				cnt = coviMapperOne.insert("user.tf.createCommunityHome", params);
				if(cnt > 0){
					/*params.put("ObjectType", "TF");
					params.put("SubjectType", "TM");*/
					params.put("ObjectType", "CU");
					params.put("SubjectType", "CM");
					params.put("SubjectCode", subParams.get("CategoryID").toString());
				}else{
					throw new Exception("");
				}
			}
			
			//커뮤니티 기본 권한 설정
			if(coviMapperOne.getNumber("user.tf.selectTFACLCount", params) > 0){
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "U", params.get("userID").toString(), "Y")){
						throw new Exception("");
					}
					
					params.put("userLevel", "4");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "U", params.get("userID").toString(), "Y")){
						throw new Exception("");
					}
					params.put("userLevel", "0");
				}
			}else{
				//insert
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "C", params.get("userID").toString(), "Y")){
						throw new Exception("");
					}
					
					params.put("userLevel", "4");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "C", params.get("userID").toString(), "Y")){
						throw new Exception("");
					}
					
					params.put("userLevel", "0");
				}
			}
			
			params.put("CommunityName", subParams.get("CommunityName"));
			params.put("DN_ID", subParams.get("DN_ID"));
			
			List list = new ArrayList();
			
			params.put("CommunityType", subParams.get("CommunityType"));
			
			params.put("MemberOf", "0");
			params.put("SortKey",  "1");
			params.put("SortPath", "000000000000001;");
			params.put("MenuID",  params.get("CU_ID"));
			params.put("SecurityLevel",  "0");
			params.put("IsInherited", "Y");
			params.put("Reserved2", "");
			params.put("FolderType", "Root");
			params.put("DefaultBoardType", subParams.get("DefaultBoardType"));
			
			String MemberOf = "";
			
			cnt = coviMapperOne.insert("user.tf.createTFFolder", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("FolderID") != null ){
				MemberOf = params.get("FolderID").toString();
				
				if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR" ,"_C__EVR", "_", "C", "_", "_", "E", "V", "R", "C", params.get("userID").toString(), "Y")){
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			String CommunityName = params.get("CommunityName").toString();
			list = coviMapperOne.list("user.tf.tfFolderList", params);
			//도메인 기준 우선 확인. 없을 경우 그룹공용으로 조회 함
			if(list.size() == 0 ){
				params.remove("DN_ID");
				params.put("DN_ID", "0");
				list = coviMapperOne.list("user.tf.tfFolderList", params);
				params.remove("DN_ID");
				params.put("DN_ID", subParams.get("DN_ID"));
			}
			
			if(list.size() > 0){
				CoviMap FolderParams = new CoviMap();
				for(int j = 0; j < list.size(); j++){
					FolderParams = (CoviMap) list.get(j);
					FolderParams.put("CU_ID", params.get("CU_ID"));
					
					params.put("FolderType", FolderParams.get("FolderType"));
					
					if(FolderParams.get("FolderType").equals("Schedule")){
						params.put("MemberOf",  RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
						params.put("MenuID",  RedisDataUtil.getBaseConfig("ScheduleMenuID"));
						params.put("SortKey", FolderParams.get("SortKey"));
						params.put("SortPath",  coviMapperOne.getString("user.tf.selectTFScheduleMenu", params));
						params.put("SecurityLevel",  "90");
						params.put("IsInherited", 'N');
						params.put("Reserved2", RedisDataUtil.getBaseConfig("FolderDefaultColor"));
						params.put("CommunityName",CommunityName );
						cnt = coviMapperOne.insert("user.tf.createTFFolder", params);
						//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
						if(cnt > 0 || params.get("FolderID") != null){
							if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "CM" ,"SCDMEVR", "S", "C", "D", "M", "E", "V", "R", "C", params.get("userID").toString(), "Y")){
								throw new Exception("");
							}
						}else{
							throw new Exception("");
						}
					}else{
						params.put("MemberOf", MemberOf);
						params.put("SortKey",  FolderParams.get("SortKey"));
						params.put("SortPath", "");
						params.put("MenuID",  params.get("CU_ID"));
						params.put("SecurityLevel",  "0");
						params.put("IsInherited", "Y");
						params.put("Reserved2", "");
						params.put("CommunityName",FolderParams.get("FolderName") );
						
						cnt = coviMapperOne.insert("user.tf.createTFFolder", params);
						//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
						if(cnt > 0 || params.get("FolderID") != null){
							if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR" ,"_C__EVR", "_", "C", "_", "_", "E", "V", "R", "C", params.get("userID").toString(), "Y")){
								throw new Exception("");
							}
						}else{
							throw new Exception("");
						}
						
						if(FolderParams.get("FolderType").equals("QuickComment")){
							CoviMap QuickParams = new CoviMap();
							
							QuickParams.put("folderID", params.get("FolderID").toString());
							QuickParams.put("subject", FolderParams.get("FolderName"));
							QuickParams.put("bodyText", " ");
							QuickParams.put("body", " ");
							QuickParams.put("bodySize",1);
							QuickParams.put("bizSection", "Board");
							QuickParams.put("isInherited", "N");
							QuickParams.put("msgType", "O");
							QuickParams.put("msgState", "C");
							QuickParams.put("step", 0);
							QuickParams.put("depth", 0);
							QuickParams.put("isApproval", "N");
							QuickParams.put("useSecurity", "N");
							QuickParams.put("isPopup", "N");
							QuickParams.put("isTop", "N");
							QuickParams.put("isUserForm", "N");
							QuickParams.put("useScrap", "N");
							QuickParams.put("useRSS", "N");
							QuickParams.put("useReplyNotice", "N");
							QuickParams.put("useCommNotice", "N");
							QuickParams.put("fileCnt", 0);
							QuickParams.put("fileInfos", "[]");
							QuickParams.put("userCode", params.get("userID"));
							QuickParams.put("ownerCode", params.get("userID"));
							QuickParams.put("mode", "create");
							int createFlag = boardMessageSvc.createMessage(QuickParams, mf);
							if(createFlag > 0){
								
							}else{
								boardMessageSvc.deleteMessage(QuickParams);
								throw new Exception("");
							}
						}
					}
					
					//상단 메뉴 등록
					if(coviMapperOne.getNumber("user.tf.selectTFMenuTopCount", params) == 0){
						cnt = coviMapperOne.insert("user.tf.createTFMenuTop", params);
						if(cnt > 0){
							
						}else{
							throw new Exception("");
						}
					}
				}
			}
			
			params.put("SubjectCode", subParams.get("DomainCode").toString());
			
			//TF팀룸 그룹 권한 설정
			if(coviMapperOne.getNumber("user.tf.selectTFACLCount", params) > 0 ){
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "U", params.get("userID").toString(), "Y")){
					throw new Exception("");
				}
			}else{
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "C", params.get("userID").toString(), "Y")){
					throw new Exception("");
				}
			}
			
			// TF팀룸 멤버 추가
			if(!TFMember(params.getString("CU_ID"), params.getString("txtTFCode"), params.getString("txtPMCode"), params.getString("txtAdminCode"), params.getString("txtMemberCode"))){
				throw new Exception("");
			}
			
			// TF명 다국어
			if( coviMapperOne.getNumber("user.tf.tfCnt", params) > 0){
				cnt = coviMapperOne.update("user.tf.updateTFNameDictionary", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}else{
				cnt = coviMapperOne.insert("user.tf.createTFNameDictionary", params);
				if(cnt > 0){
								
				}else{
					throw new Exception("");
				}
			}
			
			params.put("CommunityName",CommunityName);
			params.put("DIC_Code", "CU_"+params.get("CU_ID"));
			
			//다국어 
			cnt = coviMapperOne.insert("user.tf.createTFFolderDictionary", params);
			if(cnt > 0){
				
			}else{
				throw new Exception("");
			}
			
			//Portal 등록
			params.put("PortalTag", RedisDataUtil.getBaseConfig("communityPortalTag"));
			params.put("LayoutSizeTag", RedisDataUtil.getBaseConfig("communityLayoutSizeTag"));
			
			cnt = coviMapperOne.insert("user.tf.createTFWebPortal", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("PortalID") != null){
				
			}else{
				throw new Exception("");
			}
			
			List portalList = new ArrayList();
			
			//Portal Webpart 조회 /등록
			portalList = coviMapperOne.list("user.tf.tfDefaultPortalList", params);
			
			if(portalList.size() > 0 ){
				CoviMap PortalParams = new CoviMap();
				for(int k = 0; k < portalList.size(); k ++){
					PortalParams = (CoviMap) portalList.get(k);
					PortalParams.put("PortalID", params.get("PortalID"));
					PortalParams.put("CU_ID", params.get("CU_ID"));
					PortalParams.put("userID", params.get("userID"));
					
					cnt = coviMapperOne.insert("user.tf.createTFWebPart", PortalParams);
					//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
					if(cnt > 0 || PortalParams.get("WebpartID") != null){
					
					}else{
						throw new Exception("");
					}
					
					cnt = coviMapperOne.insert("user.tf.createTFLayout", PortalParams);
					if(cnt > 0){
					
					}else{
						throw new Exception("");
					}
				}
			}
			
			params.put("UR_Code",params.get("userID"));
			params.put("Code","CreateRequest");
			params.put("SubCode", "");
			
			//TODO-COMMUNITY
			/*
			 * if(!_sendMessaging(params)){
			 * 
			 * }
			 */
			
			params.put("CU_ID", tempCID);
			cnt = coviMapperOne.delete("user.tf.deleteTempTFTeamRoom", params);
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				if(params.getString("Code") == null)
					coviMapperOne.delete("user.tf.deleteTempTFFile", params);
			}
			///if(cnt > 0){
			//	
			//}else{
			//	throw new Exception("");
			//}
			
			flag = true;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
			
			returnObj.put("status", false);
			return returnObj;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
			
			returnObj.put("status", false);
			return returnObj;
		}
		
		returnObj.put("status", flag);
		
		return returnObj;
	}
	
	public boolean TFMember(String CU_ID, String CU_Code, String txtPMCode, String txtAdminCode, String txtMemberCode) {
		int cnt;
		
		CoviMap params = new CoviMap();
		params.put("CU_ID", CU_ID);
		params.put("CU_Code", CU_Code);
		params.put("TF_PMCode", txtPMCode);
		params.put("TF_AdminCode", txtAdminCode);
		params.put("TF_MemberCode", txtMemberCode);
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		//기존 멤버 전부 탈퇴 처리
		cnt = coviMapperOne.update("user.tf.updateMemberLS", params);
		if(cnt < 0){
			return false;
		}
		
		//기존 base group member 삭제
		cnt = coviMapperOne.delete("user.tf.deleteBaseGroupMember", params);
		if(cnt < 0){
			return false;
		}
		
		//PM Level 멤버 추가
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		
		StringTokenizer st = new StringTokenizer(txtPMCode, ";");
		while (st.hasMoreTokens()) {
			String userID = st.nextToken();
			params.put("userID", userID);
			if(!callMemberManage(params)) {
				return false;
			}
		}
		
		//Admin Level 멤버 추가
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		
		st = new StringTokenizer(txtAdminCode, ";");
		while (st.hasMoreTokens()) {
			String userID = st.nextToken();
			params.put("userID", userID);
			if(!callMemberManage(params)) {
				return false;
			}
		}
		
		//Member Level 멤버 추가
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		st = new StringTokenizer(txtMemberCode, ";");
		while (st.hasMoreTokens()) {
			String userID = st.nextToken();
			params.put("userID", userID);
			if(!callMemberManage(params)) {
				return false;
			}
		}
		
		//TF 멤버수 업데이트
		cnt = coviMapperOne.update("user.tf.updateTFMemberCount", params);
		if(cnt < 0){
			return false;
		}
		
		return true;
	}
	
	public boolean callMemberManage(CoviMap params) {
		int cnt;
		int memberCnt = 0;
		
		//기존회원일 경우
		memberCnt = (int) coviMapperOne.getNumber("user.tf.selectTFMemberCount", params);
		if(memberCnt > 0){
			cnt = coviMapperOne.update("user.tf.updateTFMember", params);
			if(cnt < 0){
				return false;
			}
			//sys_object_group_member에 등록되지 않았을 경우
			memberCnt = (int) coviMapperOne.getNumber("user.tf.selectBaseGroupMember", params);
			if(memberCnt == 0) {
				cnt = coviMapperOne.insert("user.tf.insertBaseGroupMember", params);
				if(cnt < 0) {
					return false;
				}
			}
		} else {
			cnt = coviMapperOne.insert("user.tf.createTFMember", params);
			if(cnt < 0){
				return false;
			}
			//sys_object_group_member에 등록되지 않았을 경우
			memberCnt = (int) coviMapperOne.getNumber("user.tf.selectBaseGroupMember", params);
			if(memberCnt == 0) {
				cnt = coviMapperOne.insert("user.tf.insertBaseGroupMember", params);
				if(cnt < 0) {
					return false;
				}
			}
		}
		
		return true;
	}
	
	public boolean ACL(String ObjectID,String ObjectType,String SubjectCode,String SubjectType, String AclList, String Security, String Create, String Delete, String Modify, String Execute, String View, String Read, String Type, String userID, String IsInclude){
		CoviMap aclParams = new CoviMap();
		int count = 0;
		
		StringUtil func = new StringUtil();
		
		aclParams.put("ObjectID", ObjectID);
		aclParams.put("ObjectType", ObjectType);
		aclParams.put("SubjectCode", SubjectCode);
		aclParams.put("SubjectType", SubjectType);
		aclParams.put("AclList", AclList);
		aclParams.put("Security", Security);
		aclParams.put("Create", Create);
		aclParams.put("Delete", Delete);
		aclParams.put("Modify", Modify);
		aclParams.put("Execute", Execute);
		aclParams.put("View", View);
		aclParams.put("Read", Read);
		aclParams.put("IsInclude", IsInclude);
		aclParams.put("userCode", userID);
		
		try {
			if(func.f_NullCheck(Type).equals("U")){
				count = coviMapperOne.update("user.tf.updateTFACL", aclParams);
				
				if(count > 0){
					return true;
				}else{
					return false;
				}
			}else if(func.f_NullCheck(Type).equals("C")){
				count = coviMapperOne.insert("user.tf.createTFACL", aclParams);
				
				if (aclParams.get("ObjectType").toString().equals("FD")) {
					CoviMap gradeParams = new CoviMap();
					CoviMap gradeMap = new CoviMap();
					
					gradeParams.put("lang", SessionHelper.getSession("lang"));
					gradeParams.put("domainID", SessionHelper.getSession("DN_ID"));
					
					List gradeList = new ArrayList();
					gradeList = coviMapperOne.list("user.tf.selectTFGradeList", gradeParams);
					
					if (gradeList.size() > 0) {
						for (int i = 0; i < gradeList.size(); ++i) {
							gradeMap = (CoviMap)gradeList.get(i);
							
							String subjectCode = aclParams.get("SubjectCode").toString().length() > 9 ? "TFGrade" + aclParams.get("SubjectCode").toString().substring(9) + "_" + gradeMap.get("Code") : aclParams.get("SubjectCode").toString();
							String aclList = "";
							String security = gradeMap.get("Code").toString().equals("9") ? "S" : "_";
							String create = "C";
							String delete = gradeMap.get("Code").toString().equals("9") ? "D" : "_";
							String modify = gradeMap.get("Code").toString().equals("9") ? "M" : "_";
							String execute = "E";
							String view = "V";
							String read = "R";
							
							aclList = security + create + delete + modify + execute + view + read;
							
							CoviMap gradeAclParams = new CoviMap();
							
							gradeAclParams.put("ObjectID", aclParams.get("ObjectID"));
							gradeAclParams.put("ObjectType", aclParams.get("ObjectType"));
							gradeAclParams.put("SubjectCode", subjectCode);
							gradeAclParams.put("SubjectType", aclParams.get("SubjectType"));
							gradeAclParams.put("AclList", aclList);
							gradeAclParams.put("Security", security);
							gradeAclParams.put("Create", create);
							gradeAclParams.put("Delete", delete);
							gradeAclParams.put("Modify", modify);
							gradeAclParams.put("Execute",execute);
							gradeAclParams.put("View", view);
							gradeAclParams.put("Read", read);
							gradeAclParams.put("IsInclude", aclParams.get("IsInclude"));
							gradeAclParams.put("userCode", aclParams.get("userID"));
							
							coviMapperOne.insert("user.tf.createTFACL", gradeAclParams);
						}
					}
				}
				
				if(count > 0){
					return true;
				}else{
					return false;
				}
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}
		
		return true;
	}
	
	public boolean _sendMessaging(CoviMap params){
		List list = new ArrayList();
		
		try {
			if(params.get("Code").equals("CreateRequest")){
				CoviMap map = new CoviMap();
				
				map.put("CU_ID", params.getString("CU_ID"));
				map.put("UserCode", params.getString("userID"));
				
				String cuName = coviMapperOne.getString("user.tf.getTFName", map);
				
				map.put("CommunityName", cuName);
				
				list.add(map);
			}else if(params.get("Code").equals("JoiningRequest") || params.get("Code").equals("CreateReject")){
				list = coviMapperOne.list("user.tf.sendMessagingCommunityOperator", params);
			}else{
				list = coviMapperOne.list("user.tf.sendMessagingList", params);
			}
			
			if(list.size() > 0){
				CoviMap FolderParams = new CoviMap();
				
				for(int j = 0; j < list.size(); j ++){
					FolderParams = (CoviMap) list.get(j);
					FolderParams.put("Code", params.get("Code"));
					FolderParams.put("Category", "TF");
				
					if(FolderParams.get("Code").equals("CloseApproval")){
						//전체
						FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 폐쇄 승인 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName") +" 폐쇄신청이 승인되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CloseReject")){
						//관리자만
						FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 폐쇄 거부 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName") +"가 폐쇄거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CloseRestoration")){
						//관리자만
						FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 폐쇄 복원 알림");
						FolderParams.put("Message", "폐쇄된 "+ FolderParams.get("CommunityName") +" TF팀룸이 관리자에 의해 복원되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CreateApproval")){
						//관리자
						if(params.get("SubCode").equals("CCAR")){
							FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 개설 거부 알림");
							FolderParams.put("Message", FolderParams.get("CommunityName") +" 개설신청이 거부되었습니다.");
						}else{
							FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 개설 승인 알림");
							FolderParams.put("Message", FolderParams.get("CommunityName") +" 개설신청이 승인되었습니다.");
						}
						
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("CreateRequest")){
						//관리자
						if(params.get("SubCode").equals("SCCA")){
							FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 생성 알림");
							FolderParams.put("Message", FolderParams.get("CommunityName") +" TF팀룸이 생성되었습니다.");
						}else{
							FolderParams.put("Title", "TF팀룸 : "+ FolderParams.get("CommunityName") + " 신청 알림");
							FolderParams.put("Message", FolderParams.get("CommunityName") + " TF팀룸이 신청되었습니다.");
						}
						
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("ForcedApproval")){
						//전체
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 강제 폐쇄 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸이 관리자에 의해 강제로 폐쇄되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("CuMemberContact")){
						//확인필요.
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" TF팀룸 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 알림");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("Invited")){
						//등록한 사용자만
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" TF팀룸 초대 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+ "TF팀룸에 초대되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("JoiningApproval")){
						//커뮤니티 사용자
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 가입 승인 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 가입이 승인되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("JoiningReject")){
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 가입 거부 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 가입이 거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("PartiNotice")){
						//Target 제휴 커뮤니티 관리자
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 제휴 요청 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 제휴가 요청되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("CloseRequest")){
						//관리자
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 폐쇄 신청 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 폐쇄가 신청되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}
					
					notifyCommunityAlarm(FolderParams);
				}
			}else{
				if(coviMapperOne.getNumber("user.tf.sendMessagingSettingCnt", params) == 0){
					CoviMap FolderParams = new CoviMap();
					
					String cuName = coviMapperOne.getString("user.tf.getTFName", params);
					String userCode = coviMapperOne.getString("user.tf.sendMessagingSettingUserCode", params);
					
					FolderParams.put("Category", "Community");
					FolderParams.put("UserCode", userCode);
					FolderParams.put("Code", params.get("Code"));
					
					if(params.get("Code").equals("CloseApproval")){
						FolderParams.put("Title", "TF팀룸 : "+ cuName + " 폐쇄 승인 알림");
						FolderParams.put("Message", cuName +" 폐쇄신청이 승인되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CloseReject")){
						FolderParams.put("Title", "TF팀룸 : "+ cuName + " 폐쇄 거부 알림");
						FolderParams.put("Message", cuName +" 폐쇄신청이 거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CloseRequest")){
						FolderParams.put("Title", "TF팀룸 : "+cuName+" 폐쇄 신청 알림");
						FolderParams.put("Message", cuName+" TF팀룸 폐쇄가 신청되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CloseRestoration")){
						FolderParams.put("Title", "TF팀룸 : "+ cuName + " 폐쇄 복원 알림");
						FolderParams.put("Message", "폐쇄된 "+ cuName +" TF팀룸이 관리자에 의해 복원되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CreateApproval")){
						if(params.get("SubCode").equals("CCAR")){
							FolderParams.put("Title", "TF팀룸 : "+ cuName + " 개설 거부 알림");
							FolderParams.put("Message", cuName +" 개설신청이 거부되었습니다.");
						}else{
							FolderParams.put("Title", "TF팀룸 : "+ cuName + " 개설 승인 알림");
							FolderParams.put("Message", cuName +" 개설신청이 승인되었습니다.");
						}
						
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CreateRequest")){
						if(params.get("SubCode").equals("SCCA")){
							FolderParams.put("Title", "TF팀룸 : "+ cuName + " TF팀룸 생성 알림");
							FolderParams.put("Message", cuName +" TF팀룸이 생성되었습니다.");
						}else{
							FolderParams.put("Title", "TF팀룸 : "+ cuName + " TF팀룸 신청 알림");
							FolderParams.put("Message", cuName + " TF팀룸이 신청되었습니다.");
						}
						
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("ForcedApproval")){
						FolderParams.put("Title", "TF팀룸 : "+cuName+" 강제 폐쇄 알림");
						FolderParams.put("Message", cuName+" TF팀룸이 관리자에 의해 강제로 폐쇄되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CuMemberContact")){
						FolderParams.put("Title", "TF팀룸 : "+cuName+" TF팀룸 알림");
						FolderParams.put("Message", cuName+" TF팀룸 알림");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("Invited")){
						FolderParams.put("Title", "TF팀룸 : "+cuName+" TF팀룸 초대 알림");
						FolderParams.put("Message", cuName+ " TF팀룸이 초대되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("JoiningApproval")){
						//커뮤니티 사용자
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 가입 승인 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 가입이 승인되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(FolderParams.get("Code").equals("JoiningReject")){
						FolderParams.put("Title", "TF팀룸 : "+FolderParams.get("CommunityName")+" 가입 거부 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" TF팀룸 가입이 거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("PartiNotice")){
						FolderParams.put("Title", "TF팀룸 : "+cuName+" 제휴 요청 알림");
						FolderParams.put("Message", cuName+" TF팀룸 제휴가 요청되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}else if(params.get("Code").equals("CreateRejectl")){
						FolderParams.put("Title", "TF팀룸 : "+cuName+" 개설 거부 알림");
						FolderParams.put("Message", cuName+" TF팀룸 개설이 거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF");
						FolderParams.put("MobileURL", "/groupware/mobile/tf/main.do?menucode=TFMain");
					}
					
					notifyCommunityAlarm(FolderParams);
				}
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}
		
		return true;
	}
	
	public void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
		CoviMap notiParam = new CoviMap();
		notiParam.put("ObjectType", "TF");
		notiParam.put("ServiceType", "Community");								//TFRoom
		notiParam.put("MsgType", pNotifyParam.get("Code"));						//커뮤니티 알림 코드
		notiParam.put("PopupURL", pNotifyParam.getString("URL"));
		notiParam.put("GotoURL", pNotifyParam.getString("URL"));
		notiParam.put("MobileURL", pNotifyParam.getString("MobileURL"));
		notiParam.put("MessagingSubject", pNotifyParam.getString("Title"));
		notiParam.put("MessageContext", pNotifyParam.get("Message"));
		notiParam.put("ReceiverText", pNotifyParam.getString("Message"));
		notiParam.put("SenderCode", SessionHelper.getSession("USERID"));		//송신자
		notiParam.put("RegistererCode", SessionHelper.getSession("USERID"));
		notiParam.put("ReceiversCode", pNotifyParam.getString("UserCode"));		//조회된 수신자 코드
		notiParam.put("DomainID", SessionHelper.getSession("DN_ID"));
		MessageHelper.getInstance().createNotificationParam(notiParam);
		messageSvc.insertMessagingData(notiParam);
	}
	
	@Override
	public CoviMap selectTFTempSaveData(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviList selList = new CoviList();
		
		selList = coviMapperOne.list("user.tf.selectTFTempSaveData", params);
		
		returnObj.put("data", CoviSelectSet.coviSelectJSON(selList, "CU_ID,CU_Code,DN_ID,MN_ID,Gubun,CommunityType,CommunityName,JoinOption,LimitFileSize,UsedFileSize,SearchTitle,CreatorCode,RegistDate,Reserved1,Reserved2,DefaultBoardType,Secret,TF_DN_ID,TF_MajorDeptCode,TF_MajorDept,TF_StartDate,TF_EndDate,TF_PM,TF_PMCode,TF_PMCount,TF_Admin,TF_AdminCode,TF_AdminCount,TF_Member,TF_MemberCode,TF_MemberCount,TF_Cost,TF_Benefit,TF_Rist,TF_DocLinks,TF_CollaboLinks"));
		
		return returnObj;
	}
	
	public void insertTFSysFile(CoviMap params, List<MultipartFile> mf) throws Exception {
		String uploadPath = params.getString("ServiceType") + File.separator;
		String orgPath = params.getString("ServiceType") + File.separator;
		
		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath, params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
	}
	
	public void updateTFSysFile(CoviMap params, List<MultipartFile> mf) throws Exception {
		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		
		// 기존에 있는 파일 전부 삭제 시
		if(fileInfos.size() == 0 && params.getInt("fileCnt") == 0 && mf.size() == 0){
			fileSvc.deleteFileDbAll(params);
		} else {
			String uploadPath = params.getString("ServiceType") + File.separator;
			
			CoviList fileObj = fileSvc.uploadToBack(fileInfos, mf, uploadPath , params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
		}
	}
	
	@Override
	public CoviMap selectTFDetailInfo(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviList selList = new CoviList();
		
		params.put("ViewerLevel", RedisDataUtil.getBaseConfig("TFViewerLevel"));
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("DN_ID", SessionHelper.getSession("DN_ID"));
		
		selList = coviMapperOne.list("user.tf.selectTFDetailInfo", params);
		
		returnObj.put("data", CoviSelectSet.coviSelectJSON(selList, "CU_ID,CU_Code,CategoryID,DN_ID,MN_ID,CommunityType,CommunityName,JoinOption,RegStatus,AppStatus,AppStatusName,ClosingMsg,LastNumber,DefaultMemberLevel,RegRequestDate,RegProcessDate,UnRegRequestDate,UnRegProcessDate,LimitFileSize,UsedFileSize,MemberCount,MsgCount,ReplyCount,OneMsgCount,VisitCount,ViewCount,MeetingUserCount,MeetingPaRate,Point,Grade,SearchTitle,SearchSummary,CreatorCode,CreatorName,CreatorLevel,CreatorPosition,CreatorTitle,CreatorDept,OperatorCode,OperatorName,ProcesserCode,MenuSyncTime,Reserved1,Reserved2,DefaultBoardType,Secret,Gubun,TF_State,TF_StateName,TF_DN_ID,TF_DomainName,TF_MajorDeptCode,TF_MajorDept,TF_StartDate,TF_EndDate,TF_Cost,TF_Benefit,TF_Risk,TF_DocLinks,TF_Viewer,TF_Member,TF_Admin,TF_PM,Description,DescriptionEditor,TF_PM_CODE,TF_PM_MAIL,MEMBER_CNT,TF_CollaboLinks,TF_GUBUN"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityBoardLeft(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectCommunityBoardLeft", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "FolderName,FolderID,itemType,MenuID,SortPath,DisplayName,FolderType,type"));
		
		return returnObj;
	}
	
	//특정 Task 정보 조회
	@Override
	public CoviMap getTaskData(CoviMap params) throws Exception {
		return coviSelectJSONForTaskList(coviMapperOne.select("user.tf.selectTaskData", params), "AT_ID,CU_ID,CommunityName,ATName,Gubun,TaskState,TaskStateCode,StartDate,EndDate,RegistDate,RegisterCode,UpdateDate,RegisterName,Progress,Weight,MemberOf,SortKey,SortPath,Member,UpdaterCode,ATPath,Description,MEM_ATName,");
	}
	
	//수행자 정보 조회
	@Override
	public CoviList getTaskPerformer(CoviMap params) throws Exception {
		return coviSelectJSONForTaskList(coviMapperOne.list("user.tf.selectTaskPerformerList", params),"Code,Type,Name,DeptName");
	}
	
	//업무관리용
	@SuppressWarnings("unchecked")
	public CoviList coviSelectJSONForTaskList(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap taskDic = getTaskDic();
		CoviList returnArray = new CoviList();
		
		if (clist != null && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {
				CoviMap newObject = new CoviMap();
				
				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					
					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							if (ar.equals("TaskState")) {
								newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));
							} else {
								newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
							}
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		
		return returnArray;
	}
	
	//업무관리용 
	@SuppressWarnings("unchecked")
	public  CoviMap coviSelectJSONForTaskList(CoviMap obj, String str) throws Exception {
		String [] cols = str.split(",");
		CoviMap taskDic = getTaskDic();
		CoviMap newObject = new CoviMap();
		
		for(int j=0; j<cols.length; j++){
			Set<String> set = obj.keySet();
			Iterator<String> iter = set.iterator();
			
			while(iter.hasNext()){
				String ar = (String)iter.next();
				if(ar.equals(cols[j].trim())){
					if (ar.equals("TaskState")) {
						newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+obj.getString(cols[j])),obj.getString(cols[j])));	
					} else {
						newObject.put(cols[j], obj.getString(cols[j]));
					}
				}
			}
		}
		
		return newObject;
	}
	
	// 업무관리에서 사용하는 다국어 값 세팅
	public CoviMap getTaskDic() throws Exception {
		CoviMap taskDic = new CoviMap();
		CoviMap taskState = RedisDataUtil.getBaseCodeGroupDic("TaskState");
		//JSONObject workState = RedisDataUtil.getBaseCodeGroupDic("FolderState");
		
		for(Object key : taskState.keySet()){
			String strKey = key.toString();
			taskDic.put("TaskState_"+strKey, taskState.getString(strKey) );
		}
		
		/*for(Object key : workState.keySet()){
			String strKey = key.toString();
			taskDic.put("FolderState_"+strKey, workState.getString(strKey) );
		}*/
		
		taskDic.put("", "");
		
		return taskDic;
	}
	
	/*
	 * isDuplicationSaveName: 한 커뮤니티 내 동일한 타입의 이름 중복 확인 (저장 수정 용)
	 * type: Task
	 * originName: 저장명
	 * originID: 수정 시 사용( 기존 폴더 또는 업무 ID)
	 * targetCUID: 저장될 커뮤니티 위치
	 * isModify: Y or N
	 */
	@Override
	public CoviMap isDuplicationSaveName(String type, String originName, String originID, String targetCUID, String isModify) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String tempName = "";
		
		CoviMap params = new CoviMap();
		params.put("isModify", isModify);
		params.put("CU_ID", targetCUID);
		
		if(type.equalsIgnoreCase("TASK")){
			params.put("AT_ID", originID);
			tempName = originName;
			
			int loopCnt = 0; //중복 횟수;
			int dupCnt = 0 ;
			
			while(true){
				params.put("ATName", tempName);
				
				dupCnt = (int)coviMapperOne.getNumber("user.tf.checkDuplicationTask", params);
				
				if(dupCnt > 0 ){
					tempName = originName +" ("+ (loopCnt+1) + ")";
				}else{
					break;
				}
				
				loopCnt++;
			}
			
			returnObj.put("saveName",tempName);
			if(loopCnt <= 0){
				returnObj.put("isDuplication",  "N");  // Y: 중복, N: 중복X
			}else{
				returnObj.put("isDuplication",  "Y");  // Y: 중복, N: 중복X
			}
			
		}else{
			returnObj.put("isDuplication",  "Y");  // Y: 중복, N: 중복X
			returnObj.put("saveName",  "");
		}
		
		return returnObj;
	}
	
	//작업 정보 저장
	@Override
	public void saveTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		/*
		 * taskObj Data Format - 저장용
		 {
		  "FolderID": "8",
		  "Subject": "기능명세서 작성",
		  "State": "Waiting",
		  "StartDate": "2017-10-18",
		  "EndDate": "2017-10-19",
		  "inlineImage": "",
		  "Description": "지난 조사를 참고하여 작성",
		  "RegisterCode": "bjlsm2",
		  "OwnerCode": "bjlsm2",
		  "PerformerList": [
			{
			  "PerformerCode": "yjlee"
			},
			{
			  "PerformerCode": "gypark"
			},
			{
			  "PerformerCode": "RD2"
			}
		  ]
		}
		 * */
		//Editor 처리
		/*사용하지 않아 주석처리2019.09
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Task");
		editorParam.put("imgInfo", taskObj.getString("InlineImage"));
		editorParam.put("objectID", taskObj.getString("FolderID"));
		editorParam.put("objectType", "TKFD");
		editorParam.put("messageID", "0");
		editorParam.put("bodyHtml",taskObj.getString("Description"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		*/
		//기본 정보 저장
		CoviMap params = new CoviMap();
		params.put("CU_ID", taskObj.getString("CU_ID"));
		params.put("ATName", taskObj.getString("ATName"));
		//params.put("Description", editorInfo.getString("BodyHtml"));
		params.put("State", taskObj.getString("State"));
		params.put("Progress", taskObj.getString("Progress"));
		params.put("Weight", taskObj.getString("Weight"));
		params.put("SortKeyValue", taskObj.getString("SortKey"));
		params.put("Gubun", taskObj.getString("Gubun"));
		params.put("MemberOf", taskObj.getString("MemberOf"));
		params.put("RegisterCode", taskObj.getString("RegisterCode"));
		params.put("Mode", taskObj.getString("Mode"));
		params.put("useProgressOption", taskObj.getString("useProgressOption"));
		
		if(!taskObj.getString("StartDate").equals("")){ params.put("StartDate", taskObj.getString("StartDate").replace(".", "-")); }
		if(!taskObj.getString("EndDate").equals("")){ params.put("EndDate", taskObj.getString("EndDate").replace(".", "-")); }
		
		coviMapperOne.insert("user.tf.insertTaskData", params);
		
		params.put("CU_ID", Integer.parseInt(taskObj.getString("CU_ID")));
		params.put("AT_ID", Integer.parseInt(params.getString("AT_ID")));
		
		coviMapperOne.update("user.tf.updateActvityProgress", params);
		
		String AT_ID = params.getString("AT_ID");
		String CU_ID = taskObj.getString("CU_ID");
		
		//editorParam.put("messageID", taskID);
		//editorParam.addAll(editorInfo);
		
		//editorService.updateFileMessageID(editorParam);
		
		//sortpath 저장
		int cnt = updateTaskSortPath(params);
		
		//수행자 정보 저장
		CoviList performerList = taskObj.getJSONArray("PerformerList");
		
		//수행자가 지정된 경우 실행
		if(performerList != null && performerList.size() > 0){
			params.put("arrPerformer", performerList);
			
			coviMapperOne.insert("user.tf.insertTaskPerformerData",params);
			
			// 통합 알림 설정
			CoviMap notiParams = new CoviMap();
			StringBuilder receiversCode = new StringBuilder();
			
			for (int i = 0; i < performerList.size(); i++) {
				CoviMap performerData = performerList.getJSONObject(i);
				
				String memberCode = performerData.getString("PerformerCode");
				//receiversCode += ";" + memberCode;
				receiversCode.append(";").append(memberCode);
			}
			
			notiParams.put("bizSection", "TF");
			notiParams.put("msgType", "ActivityRegi");
			notiParams.put("subject", taskObj.getString("ATName"));
			notiParams.put("userCode", taskObj.getString("RegisterCode"));
			notiParams.put("receiversCode", receiversCode.toString());
			notiParams.put("CU_ID", CU_ID);
			notiParams.put("AT_ID", AT_ID);
			
			notifyCreateMessage(notiParams);
		}
		
		// [Added][FileUpload]
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", AT_ID);
			filesParams.put("ObjectID", CU_ID);
			filesParams.put("ObjectType", "TFAT");
			insertTFSysFile(filesParams, mf);
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("PjtCode", taskObj.getString("CU_ID"));
			params.put("TaskCode", AT_ID);
			params.put("TaskName", taskObj.getString("ATName"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",taskObj.getString("State"));
			params.put("TaskPercent", taskObj.getString("Progress"));
			params.put("TaskEtc", taskObj.getString("ATName") + "등록");
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "P");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	//업무 정보 수정
	@Override
	public void modifyTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		/*
		 * taskObj Data Format - 수정
		 {
		  "TaskID": "1",
		  "Subject": "기능명세서 작성",
		  "State": "Waiting",
		  "StartDate": "2017-10-18",
		  "EndDate": "2017-10-19",
		  "Description": "지난 조사를 참고하여 작성",
		  "PerformerList": [  ]
		}
		 * */
		
		String AT_ID = taskObj.getString("AT_ID");
		String CU_ID = taskObj.getString("CU_ID");
		
		//Editor 처리
		/*
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Task");
		editorParam.put("imgInfo", taskObj.getString("InlineImage"));
		editorParam.put("objectID", taskObj.getString("FolderID"));
		editorParam.put("objectType", "TKFD");
		editorParam.put("messageID", taskObj.getString("TaskID"));
		editorParam.put("bodyHtml",taskObj.getString("Description"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		*/
		
		//기본 정보 수정
		CoviMap params = new CoviMap();
		params.put("CU_ID", taskObj.getString("CU_ID"));
		params.put("AT_ID", taskObj.getString("AT_ID"));
		params.put("ATName", taskObj.getString("ATName"));
		//params.put("Description",  editorInfo.getString("BodyHtml"));
		params.put("State", taskObj.getString("State"));
		params.put("Progress", taskObj.getString("Progress"));
		params.put("Weight", taskObj.getString("Weight"));
		params.put("SortkeyValue", taskObj.getString("SortKey"));
		params.put("Gubun", taskObj.getString("Gubun"));
		params.put("MemberOf", taskObj.getString("MemberOf"));
		params.put("Mode", taskObj.getString("Mode"));
		params.put("useProgressOption", taskObj.getString("useProgressOption"));
		
		if(! taskObj.getString("StartDate").equals("")){
			params.put("StartDate", taskObj.getString("StartDate").replace(".", "-"));
		}
		if(! taskObj.getString("EndDate").equals("")){
			params.put("EndDate", taskObj.getString("EndDate").replace(".", "-"));
		}
		
		coviMapperOne.update("user.tf.updateTaskData", params);
		
		params.put("CU_ID", Integer.parseInt(taskObj.getString("CU_ID")));
		params.put("AT_ID", Integer.parseInt(taskObj.getString("AT_ID")));
		
		coviMapperOne.update("user.tf.updateActvityProgress", params);
		
		//sortpath 저장
		int cnt = updateTaskSortPath(params);
		
		//수행자 정보 수정
		CoviList performerList = taskObj.getJSONArray("PerformerList");
		
		coviMapperOne.delete("user.tf.deleteTaskPerformerData", params);
		
		if(performerList != null && performerList.size() > 0){
			params.put("arrPerformer", performerList);
			
			coviMapperOne.insert("user.tf.insertTaskPerformerData",params);
			
			// 통합 알림 설정
			CoviMap notiParams = new CoviMap();
			StringBuilder receiversCode = new StringBuilder();
			
			for (int i = 0; i < performerList.size(); i++) {
				CoviMap performerData = performerList.getJSONObject(i);
				
				String memberCode = performerData.getString("PerformerCode");
				//receiversCode += ";" + memberCode;
				receiversCode.append(";").append(memberCode);
			}
			
			if (taskObj.getString("Progress") != null && Integer.parseInt(taskObj.getString("Progress")) == 100
				&& taskObj.getString("State").equals("Complete")) {
				notiParams.put("msgType", "ActivityComp"); // 완료
			} else {
				notiParams.put("msgType", "ActivityModi"); // 수정
			}
			
			notiParams.put("bizSection", "TF");
			notiParams.put("subject", taskObj.getString("ATName"));
			notiParams.put("userCode", taskObj.getString("UpdaterCode"));
			notiParams.put("receiversCode", receiversCode.toString());
			notiParams.put("CU_ID", CU_ID);
			notiParams.put("AT_ID", AT_ID);
			
			notifyCreateMessage(notiParams);
		}
		
		// [Added][FileUpload]
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
			filesParams.put("MessageID", AT_ID);
			filesParams.put("ObjectID", CU_ID);
			filesParams.put("ObjectType", "TFAT");
			updateTFSysFile(filesParams, mf);
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("PjtCode", taskObj.getString("CU_ID"));
			params.put("TaskCode",  taskObj.getString("AT_ID"));
			params.put("TaskName", taskObj.getString("ATName"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",taskObj.getString("State"));
			params.put("TaskPercent", taskObj.getString("Progress"));
			params.put("TaskEtc", taskObj.getString("ATName") + "수정");
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "P");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
		
	}
	
	@Override
	public void deleteTaskData(CoviMap params) throws Exception {
		coviMapperOne.delete("user.tf.deleteTaskPerformerData", params);
		coviMapperOne.delete("user.tf.deleteTaskData",params);
	}
	
	@Override
	public int updateTaskSortPath(CoviMap params) throws Exception {
		int cnt = 0;
		StringUtil func = new StringUtil();
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		//하위 게시판 검색
		params.put("CU_ID", params.get("CU_ID"));
		params.put("AT_ID", params.get("AT_ID"));
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			String ATPath =  coviMapperOne.selectOne("user.tf.selectActivityFullPath", params);
			params.put("ATPath", ATPath);
		}
		cnt = coviMapperOne.update("user.tf.updateTaskSortPath", params);
		return cnt;
	}
	
	@Override
	public CoviMap getLevelTaskList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.tf.selectLevelTaskList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "AT_ID,ATName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectTaskGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("user.tf.selectTaskGridList", params);
		
		if(params.containsKey("headerKey")){
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, params.getString("headerKey")));
		}else{
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "AT_ID,CU_ID,CommunityName,ATName,Gubun,TaskState,TaskStateCode,StartDate,EndDate,RegistDate,RegisterCode,UpdateDate,RegisterName,Progress,Weight,MemberOf,SortKey,SortPath,Member,UpdaterCode,ATPath,isOwner"));
		}
		
		return resultList;
	}
	
	@Override
	public int selectTaskGridListCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.selectTaskGridListCount", params);
	}
	
	@Override
	public int selectMyTaskGridListCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.selectMyTaskGridListCount", params);
	}
	
	@Override
	public CoviMap selectMyTaskGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("user.tf.selectMyTaskGridList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "AT_ID,CU_ID,CommunityName,ATName,Gubun,TaskState,TaskStateCode,StartDate,EndDate,RegistDate,RegisterCode,UpdateDate,RegisterName,Progress,Weight,MemberOf,SortKey,SortPath,Member,UpdaterCode,ATPath"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectActivityProgress(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			coviMapperOne.delete("user.tf.dropTT_CalTable", params);
		}
		/*임시테이블 생성*/
		coviMapperOne.insert("user.tf.createTT_CalTable", params);
		/*달력데이터채우기*/
		coviMapperOne.insert("user.tf.insertTT_CalTable", params);
		
		/*달력 최대,최소값 가져오기 및 채우기*/
		CoviMap map = (CoviMap) (coviMapperOne.list("user.tf.selecttt_CalTableMaxMin", params)).get(0);
		params.put("MaxSEQ", map.getString("MaxSEQ"));
		params.put("MinSEQ", map.getString("MinSEQ"));
		
		/*헤더 기준일 출력*/
		CoviList headerlist = coviMapperOne.list("user.tf.selecttt_CalTable", params);
		
		/*리스트 가져오기*/
		CoviList list = coviMapperOne.list("user.tf.selectTFActivityProgress", params);
		
		resultList.put("headerlist", CoviSelectSet.coviSelectJSON(headerlist, "SolarDate,OrderWeekInMonth,SEQ"));
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "AT_ID,CU_ID,ParentName,ATName,Gubun,TaskState,TaskStateCode,StartDate,EndDate,RegistDate,RegisterCode,UpdateDate,RegisterName,Progress,Weight,MemberOf,SortKey,SortPath,Member,UpdaterCode,ATPath,ProgressPoint,MaxSEQ,StartPoint,EndPoint,TF_Period"));
		
		/* ########### 임시테이블 삭제 ########### */
		coviMapperOne.update("user.tf.dropTT_CalTable", params);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectActivityMinMaxDate(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("user.tf.selectActivityMinMaxDate", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MinDate,MaxDate"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectTFPrintData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		/*헤더 기준일 출력*/
		CoviList info = coviMapperOne.list("user.tf.selectTFPrintInfo", params);
		/*Task 리스트 가져오기*/
		CoviList tasklist = coviMapperOne.list("user.tf.selectTFPrintTaskList", params);
		/*Activity 리스트 가져오기*/
		CoviList memberlist = coviMapperOne.list("user.tf.selectTFPrintTaskMemberList", params);
		
		resultList.put("info", CoviSelectSet.coviSelectJSON(info, "CommunityName,AppStatus,MultiDisplayName,TF_MajorDeptCode,Description,DescriptionEditor,TF_StartDate,TF_EndDate,TF_Date,TF_Code,TF_Benefit,TF_Risk"));
		resultList.put("tasklist", CoviSelectSet.coviSelectJSON(tasklist, "AT_ID,ParentName,ATName,StartDate,EndDate,AT_Date,Progress,Budget,SortPath,FileName"));
		resultList.put("memberlist", CoviSelectSet.coviSelectJSON(memberlist, "AT_ID,ATName,PerformerCode,MultiDisplayName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap TFLeftUserInfo(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		StringUtil func = new StringUtil();
		
		// 전체 리스트 조회
		if (!func.f_NullCheck(params.get("IsAdmin").toString().trim()).equals("") && params.get("IsAdmin").toString().trim().equals("Y")) { //관리자에서 커뮤니티 접근시 
			selList = coviMapperOne.list("user.tf.TFLeftUserInfoAdmin", params);
		} else {
			selList = coviMapperOne.list("user.tf.TFLeftUserInfo", params);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "NickName,UR_Code,MemberLevel,DisplayName,PhotoPath,GroupCode,MemberlevelCode"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap getTFMemberInfo(CoviMap params) throws Exception {
		CoviList memberList = coviMapperOne.list("user.tf.selectTFMemberList", params); //투입인력
		
		CoviMap resultList = new CoviMap();
		resultList.put("memberList", CoviSelectSet.coviSelectJSON(memberList, "UserCode,NickName"));
		
		return resultList;
	}
	
	public int insertProjectTaskByExcel(CoviMap params) throws Exception {
		int rtn = 0;
		String prjcode = params.getString("CU_ID");
		
		ArrayList<ArrayList<Object>> dataList = extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		String parentA = "0";
		String parentB = "0";
		String CategoryMod = "A";
		int taskCode = 0;
		
		int maxSortKey = this.getMaxTaskSortKey(params);
		maxSortKey++;
		
		for (ArrayList list : dataList) {
			CoviMap paramMap = new CoviMap();
			
			if(!list.get(0).toString().trim().equals("")){
				CategoryMod = "A";
				//paramMap.put("MemberOf", "0");
				paramMap.put("ATName"  , list.get(0).toString().trim());
			} else if (!list.get(1).toString().trim().equals("")){
				CategoryMod = "B";
				paramMap.put("MemberOf", parentA);
				paramMap.put("ATName"  , list.get(1).toString().trim());
			} else if (!list.get(2).toString().trim().equals("")){
				CategoryMod = "C";
				paramMap.put("MemberOf", parentB);
				paramMap.put("ATName"  , list.get(2).toString().trim());
			}
			
			paramMap.put("CU_ID", prjcode);
			paramMap.put("Gubun", "A");
			if(list.size() > 5 &&list.get(5).toString().indexOf("(") > -1) {
				paramMap.put("MemCode", list.get(5).toString().substring(list.get(5).toString().indexOf("(")+1).replace(")", ""));
			}
			else {
				paramMap.put("MemCode", "" );
			}
			//   ,#{Weight}
			//   ,#{Progress}
			paramMap.put("StartDate", list.get(3).toString().replace(".", "-"));
			paramMap.put("EndDate", list.get(4).toString().replace(".", "-"));
			
			if(list.size() > 6 && !list.get(6).toString().trim().equals("")){
				paramMap.put("Weight", list.get(6).toString().trim().substring(0, list.get(6).toString().indexOf(".")));
			}else{
				paramMap.put("Weight", "0" );
			}
			
			if(list.size() > 7 && !list.get(7).toString().trim().equals("")){
				paramMap.put("Progress", list.get(7).toString().trim().substring(0, list.get(7).toString().indexOf(".")));
				paramMap.put("State", "Process");
			}else{
				paramMap.put("Progress", "0" );
				paramMap.put("State", "Waiting");
			}
			
			paramMap.put("RegisterCode", SessionHelper.getSession("USERID"));
			paramMap.put("SortKeyValue", maxSortKey + rtn);
			
			taskCode = insertProjectTaskExcel(paramMap);
			rtn++;
			
			if(CategoryMod.equalsIgnoreCase("A")){
				parentA = Integer.toString(taskCode);
			} else if(CategoryMod.equalsIgnoreCase("B")){
				parentB = Integer.toString(taskCode);
			}
		}
		
		return rtn;
	}
	
	// 엑셀 데이터 추출
	private ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
		Workbook wb = null;
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			ArrayList<Object> tempList = null;
			Iterator<Row> rowIterator = sheet.iterator();
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
					tempList = new ArrayList<>();
					
					for (int i=0; i<row.getLastCellNum(); i++) {
						Cell cell = row.getCell(i, Row.CREATE_NULL_AS_BLANK);
						
						switch (cell.getCellType()) {
						case Cell.CELL_TYPE_BOOLEAN :
							tempList.add(cell.getBooleanCellValue());
							break;
						case Cell.CELL_TYPE_NUMERIC : 
							if(DateUtil.isCellDateFormatted(cell)){
								tempList.add(new SimpleDateFormat("yyyy-MM-dd").format(cell.getDateCellValue()));
							}else{
								tempList.add(cell.getNumericCellValue());
							}
							break;
						case Cell.CELL_TYPE_STRING : 
							tempList.add(cell.getStringCellValue());
							break;
						case Cell.CELL_TYPE_FORMULA : 
							tempList.add(cell.getCellFormula());
							break;
						default : 
							tempList.add(cell.getStringCellValue());
							break;
						}
					}
					
					returnList.add(tempList);
				}
			}
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (wb != null) { try{wb.close();}catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (file != null){
				if(file.delete()) {
					LOGGER.info("file : " + file.toString() + " delete();");
				}
			}
		}
		
		return returnList;
	}
	
	// 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
		File tmp = null;
		
		try {
			tmp = File.createTempFile("upload", ".tmp");
			mFile.transferTo(tmp);
			
			return tmp;
		} catch (IOException ioE) {
			if (tmp != null) {
				if(tmp.delete()) {
					LOGGER.info("file : " + tmp.toString() + " delete();");
				}
			}
			
			throw ioE;
		}
	}
	
	// 프로젝트상세현황 > 업무등록 > excel upload
	public int insertProjectTaskExcel(CoviMap params) throws Exception {
		//기본정보 저장
		coviMapperOne.insert("user.tf.insertTaskData",params);
		
		int AT_ID = params.getInt("AT_ID");
		
		//sortpath 저장
		int cnt = updateTaskSortPath(params);
		
		//수행자 정보 저장
		if(!params.getString("MemCode").equalsIgnoreCase("")){
			//JSONArray performerList = taskObj.getJSONArray("PerformerList");
			CoviMap performerData = new CoviMap();
			performerData.put("PerformerCode", params.getString("MemCode"));
			CoviList performerList = new CoviList();
			performerList.add(performerData);
			//수행자가 지정된 경우 실행
			if(performerList != null && performerList.size() > 0){
				params.put("arrPerformer", performerList);
				
				coviMapperOne.insert("user.tf.insertTaskPerformerData",params);
			}
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("PjtCode", params.getString("CU_ID"));
			params.put("TaskCode", AT_ID);
			params.put("TaskName", params.getString("ATName"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",params.getString("State"));
			params.put("TaskPercent", params.getString("Progress"));
			params.put("TaskEtc", params.getString("ATName")+"엑셀등록");
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "P");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
		
		return AT_ID;
	}
	
	//프로젝트 1단계 정렬값 최대값 구하기
	public int getMaxTaskSortKey(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.selectMaxTaskSortKey", params);
	}
	
	//프로젝트 진도율 구하기
	@Override
	public CoviList selectTFProgressInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.tf.selectProjectProgress", params);
		return CoviSelectSet.coviSelectJSON(list, "CU_ID,CommunityName,TF_StartDate,TF_EndDate,TF_MajorDept,TF_TERM,TF_AVGProgress,TF_WProgress");
	}
	
	//가중치 구하기
	@Override
	public int selectSumTaskWeight(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.tf.checkSumTaskWeight", params);
		
	/*	
		CoviMap returnObj = new CoviMap();
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.checkSumTaskWeight", params);
		returnObj.put("data",CoviSelectSet.coviSelectJSON(selList, "SumWeight"));
		return returnObj;*/
	}
	
	@Override
	public String eumChannelCreate(CoviMap params) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap paramsObj = new CoviMap();
		CoviMap result = new CoviMap();
		String eumServerUrl = RedisDataUtil.getBaseConfig("eumServerUrl");
		String returnStr = "";
		
		paramsObj.put("name", params.getString("name"));
		paramsObj.put("roomType", "C");
		paramsObj.put("description", "");
		paramsObj.put("categoryCode", "PROJECT");
		paramsObj.put("openType", params.getString("openType"));
		paramsObj.put("secretKey", params.getString("secretKey"));
		paramsObj.put("members", params.getString("members"));
		paramsObj.put("authMembers", params.getString("authMembers"));
		paramsObj.put("CSJTK", params.getString("CSJTK"));
		
		result = httpClient.httpRestAPIConnect(eumServerUrl+"/server/na/s/channel/room", "json", "POST", paramsObj.toString(), "");
		
		if(CoviMap.fromObject(result.toString()).getJSONObject("body").getString("status").equals("SUCCESS")){
			returnStr = CoviMap.fromObject(result.toString()).getJSONObject("body").getJSONObject("result").getJSONObject("room").getString("roomId");
		}else{
			returnStr = CoviMap.fromObject(result.toString()).getJSONObject("body").getString("status");
		}
		
		return returnStr;
	}
	
	@Override
	public String pb_encrypt(String ciphertext) throws Exception {
		String iv = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.channel.iv"));
		String passphrase = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.passPhrase"));
		String salt = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.salt"));
		int iterationCount = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.iterationCount")));
		int keySize = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.keysize")));
		
		SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
		KeySpec spec = new PBEKeySpec(passphrase.toCharArray(), Hex.decodeHex(salt.toCharArray()), iterationCount, keySize);
		
		SecretKey key = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");
		spec = null;
		Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
		cipher.init(Cipher.ENCRYPT_MODE, key, new IvParameterSpec(Hex.decodeHex(iv.toCharArray())));
		key = null;
		
		byte[] encrypted = cipher.doFinal(ciphertext.getBytes("UTF-8"));
		
		return new String(Base64.encodeBase64(encrypted), StandardCharsets.UTF_8);
	}
	
	@Override
	public String pb_decrypt(String ciphertext) throws Exception {
		String iv = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.channel.iv"));
		String passphrase = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.passPhrase"));
		String salt = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.salt"));
		int iterationCount = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.iterationCount")));
		int keySize = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.eum.keysize")));
		
		SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
		KeySpec spec = new PBEKeySpec(passphrase.toCharArray(), Hex.decodeHex(salt.toCharArray()), iterationCount, keySize);
		
		SecretKey key = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");
		spec = null;
		Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
		cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(Hex.decodeHex(iv.toCharArray())));
		key = null;
		
		byte[] decrypted = cipher.doFinal(Base64.decodeBase64(ciphertext.getBytes("UTF-8")));
		
		return new String(decrypted, StandardCharsets.UTF_8);
	}
	
	// 통합 알림
	private void notifyCreateMessage(CoviMap params) throws Exception {
		String goToUrl = createMessageUrl(params);
		CoviMap notiParams = new CoviMap();
		
		notiParams.put("ServiceType", params.getString("bizSection"));
		notiParams.put("MsgType", params.getString("msgType"));
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", ""); // 프로젝트 룸 모바일이 없으므로 빈 값 넘김
		notiParams.put("MessageContext", createMessageContext(notiParams));
		notiParams.put("SenderCode", params.getString("userCode"));
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("receiversCode"));
		
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}
	
	// URL 생성(PC)
	public String createMessageUrl(CoviMap params){
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		String returnUrl = "";
		
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");	// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
		}
		
		returnUrl += String.format("/%s/%s/%s", "groupware", "tf", "goActivitySetPopup.do");	// {Domain}/groupware/tf/goActivitySetPopup.do
		returnUrl += "?CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&";
		returnUrl += String.format("&C=%s&ActivityId=%s", params.get("CU_ID"), params.get("AT_ID"));
		returnUrl += "&mode=MODIFY";
		
		return returnUrl;
	}
	
	public String createMessageContext(CoviMap params){
		StringBuilder sHTML = new StringBuilder(); // 알림 메일 본문
		
		sHTML.append("<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>");
		sHTML.append("<body>");
		sHTML.append("<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">");
		sHTML.append("<tr>");
		sHTML.append("<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >");
		sHTML.append("<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">");
		sHTML.append("<tr>");
		sHTML.append("<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">");
		sHTML.append(DicHelper.getDic("BizSection_" + params.getString("ServiceType")) + "(" + params.getString("ServiceType") + ")");
		sHTML.append("</td>");
		sHTML.append("</tr>");
		sHTML.append("</table>");
		sHTML.append("</td>");
		sHTML.append("</tr>");
		sHTML.append("<tr>");
		sHTML.append("<td bgcolor=\"#ffffff\" style=\"padding: 30px 0 30px 20px; border-left: 1px solid #e8ebed;border-right: 1px solid #e8ebed;font-size:12px;\">");
		sHTML.append("<!-- 문서현황 시작-->");
		sHTML.append("<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\">");
		sHTML.append("<tr>");
		sHTML.append("<td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; padding: 10px 10px 10px 10px; color: #888;\">");
		sHTML.append("<span  style=\"font: bold dotum,'돋움', Apple-Gothic,sans-serif;color: #888; font-size:12px; \" line-height=\"30\">");
		sHTML.append(params.getString("subject"));
		sHTML.append("</span>");
		sHTML.append(" <br />");
		sHTML.append("</td>");
		sHTML.append("</tr>");
		sHTML.append("</table>");
		sHTML.append("</td>");
		sHTML.append("</tr>");
		sHTML.append("</table></td></tr>");
		sHTML.append("<tr>");
		sHTML.append("<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">");
		sHTML.append("<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">");
		sHTML.append("<tr>");
		sHTML.append("<th width=\"100\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" align=\"left\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;color: #666666; padding-left: 12px; border-right: 1px solid #b1b1b1;\">");
		sHTML.append("Title");
		sHTML.append("</th>");
		sHTML.append("<td width=\"536\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #808080; padding: 0 10px;\">");
		sHTML.append("<a href=\""+ params.getString("GotoURL") + "\" style=\"cursor: pointer;\">");
		sHTML.append(params.getString("subject"));
		sHTML.append("</a>");
		sHTML.append("</td>");
		sHTML.append("</tr>");
		sHTML.append("</table>");
		sHTML.append("</td>");
		sHTML.append("</tr>");
		sHTML.append("</table></td></tr>");
		sHTML.append("</table></body></html>");
		
		return sHTML.toString();
	}
	
	@Override
	public CoviList selectUserMailList(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList list = coviMapperOne.list("user.tf.selectUserMailList", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,DN,UserName,label,value,MailAddress");
	}
	
	@Override
	public CoviList selectUserTFGridListGroupCount(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.tf.selectUserTFGridListGroupCount", params);
		return CoviSelectSet.coviSelectJSON(list, "AppStatus,Cnt");	
	}
	
	@Override
	public CoviList getUserEmailInfo(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList list = coviMapperOne.list("user.tf.getUserEmailInfo", params);
		return CoviSelectSet.coviSelectJSON(list, "MailAddress,UserName");
	}
}

