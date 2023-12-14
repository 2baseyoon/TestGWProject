package egovframework.covision.groupware.community.user.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import egovframework.baseframework.base.ThreadExecutorBean;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;
import egovframework.covision.groupware.portal.user.service.TemplateFileCacheSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("CommunityUserSvc")
public class CommunityUserSvcImpl extends EgovAbstractServiceImpl implements CommunityUserSvc{
	private Logger LOGGER = LogManager.getLogger(CommunityUserSvcImpl.class);
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	MessageSvc boardMessageSvc;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private TemplateFileCacheSvc templateFileCacheSvc;
	
	private final String jsPath = initJSFilePath();
	private final String htmlPath = initHTMLFilePath();
	private static final String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
	private static final String	PLUS = "+";
	private static final String	MINUS = "-";
	
	private static String initHTMLFilePath(){
		String ret;
		if(osType.equals("WINDOWS")){
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalHTML.WINDOW.path");
		} else {
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalHTML.UNIX.path");
		}
		return ret;
	}
	
	private static String initJSFilePath(){
		String ret;
		if(osType.equals("WINDOWS")){
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalJS.WINDOW.path");
		} else {
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalJS.UNIX.path");
		}
		return ret;
	}
	
	public CoviMap communityFavoritesSetting(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.communityFavoritesSetting", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CommunityName,CU_ID"));
		
		return returnObj;
	}
	
	public boolean communityFavoritesDelete(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("user.community.communityFavoritesDelete", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectUserJoinCommunity(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectUserJoinCommunity", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText,FileID,FilePath"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityHotStory(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		CoviList subSelList = new CoviList();
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String companyCode = SessionHelper.getSession("DN_Code");
		String communityMainORGDisplay = RedisDataUtil.getBaseConfig("communityMainORGDisplay", SessionHelper.getSession("DN_ID"));
		//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		
		params.put("communityMainORGDisplay", communityMainORGDisplay);
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityHotStory", params);
		
		for(int j=0; selList.size() > j; j++){
			subParams = (CoviMap) selList.get(j);
			
			if(!func.f_NullCheck(subParams.getString("FilePath")).equals("")) {
//				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + subParams.get("FilePath").toString()));
//				subParams.put("FilePath", backStorage + subParams.get("FilePath").toString());
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("FilePath").toString()));
				subParams.put("FilePath", subParams.get("FilePath").toString());
			}
			
			subSelList.add(subParams);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(subSelList, "CommunityName,CU_ID,OperatorCode,CreatorName,RegProcessDate,SearchTitle,SearchSummary,MemberCNT,MsgCount,FilePath,categoryName,FileCheck"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityFavorite(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		CoviList subSelList = new CoviList();
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String companyCode = SessionHelper.getSession("DN_Code");
		//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityFavorite", params);
		
		for(int j=0; selList.size() > j; j++){
			subParams = (CoviMap) selList.get(j);
			
			if(!func.f_NullCheck(subParams.getString("FilePath")).equals("")){
//				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + subParams.get("FilePath").toString()));
//				subParams.put("FilePath", backStorage + subParams.get("FilePath").toString());
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("FilePath").toString()));
				subParams.put("FilePath", subParams.get("FilePath").toString());
			}
			
			subSelList.add(subParams);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(subSelList, "CommunityName,CU_ID,OperatorCode,CreatorName,RegProcessDate,SearchTitle,SearchSummary,MemberCNT,MsgCount,FilePath,categoryName,FileCheck"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunitySearchWord(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunitySearchWord", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "SearchWordID,SearchWord,SearchCnt,SearchDate,RecentlyPoint,DN_ID,System,RegID,RegDate,ModID,ModDate"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityNotice(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		int totalCnt = 0;
		
		// 전체 리스트 조회
		ArrayList<String> dbList = new ArrayList<String>();
		dbList = coviMapperOne.list("user.community.selectCommunityNoticeFolder", params);
		
		params.put("list", dbList);
		
		selList = coviMapperOne.list("user.community.selectCommunityNotice", params);
	/*	totalCnt = (int) coviMapperOne.getNumber("user.community.selectCommunityNoticeTotalCnt", params);*/
				
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "MessageID,Version,FolderID,ParentID,Seq,Step,Depth,Subject,ReadCnt,CommentCnt,ReportCnt,FileCnt,FileExtension,RegistDate,CreatorName,CreatorLevel,DeleteDate,CommunityName,CU_ID,IsRead,FileID"));
		returnObj.put("totalCnt", totalCnt);
		
		return returnObj;
	}
	
	public CoviMap selectCommunityFrequent(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		CoviList subSelList = new CoviList();
		//StringUtil func = new StringUtil();
		String companyCode = SessionHelper.getSession("DN_Code");
		String communityMainORGDisplay = RedisDataUtil.getBaseConfig("communityMainORGDisplay", SessionHelper.getSession("DN_ID"));
		//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		
		params.put("communityMainORGDisplay", communityMainORGDisplay);
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityFrequent", params);
		
		//selList = CoviSelectSet.coviSelectJSON(selList, "CU_ID,CU_Code,CategoryID,CommunityType,CommunityName,CreatorCode,OperatorCode,OperatorName,MemberCount,MsgCount,Grade,Point,SearchTitle,FilePath,FolderPath,CreatorName,MemberCNT,categoryName,RegProcessDate"));
		
		for(int j=0; selList.size() > j; j++){
			CoviMap subParams = (CoviMap) selList.get(j);
			
			if(subParams.containsKey("FilePath") && StringUtil.isNotNull(subParams.get("FilePath"))){
//				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + subParams.get("FilePath").toString()));
//				subParams.put("FilePath", backStorage + subParams.get("FilePath").toString());
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("FilePath").toString()));
				subParams.put("FilePath", subParams.get("FilePath").toString());
			}
			
			/*if(!func.f_NullCheck(subParams.get("FilePath").toString()).equals("")){
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path")+subParams.get("FilePath").toString()));
			}
			*/
			subSelList.add(subParams);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(subSelList, "CU_ID,CU_Code,CategoryID,CommunityType,CommunityName,CreatorCode,CreatorName,OperatorCode,OperatorName,MemberCount,MsgCount,Grade,Point,SearchTitle,FilePath,FolderPath,CreatorName,MemberCNT,categoryName,RegProcessDate,FileCheck"));
		
		return returnObj;
	}
	
	public CoviMap selectNewCommunity(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		CoviList subSelList = new CoviList();
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String companyCode = SessionHelper.getSession("DN_Code");
		String communityMainORGDisplay = RedisDataUtil.getBaseConfig("communityMainORGDisplay", SessionHelper.getSession("DN_ID"));
		//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		
		params.put("communityMainORGDisplay", communityMainORGDisplay);
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectNewCommunity", params);
		
		for(int j=0; selList.size() > j; j++){
			subParams = (CoviMap) selList.get(j);
			
			String filePath = (subParams.get("FilePath") == null) ? "" : (String)subParams.get("FilePath");
				if(!func.f_NullCheck(filePath.trim()).equals("")){
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("FilePath").toString()));
				subParams.put("FilePath", filePath);
			}
			
			subSelList.add(subParams);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(subSelList, "CU_ID,CU_Code,CategoryID,CommunityType,CommunityName,CreatorCode,CreatorName,OperatorCode,OperatorName,MemberCount,MsgCount,Grade,Point,SearchTitle,FilePath,FolderPath,CreatorName,MemberCNT,categoryName,RegProcessDate,FileCheck"));
		
		return returnObj;
	}
	
	public CoviMap selectUserCommunityGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectUserCommunityGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,CreatorCode,AppStatus,RegRequestDate,FolderPath,SortPath,FileID,CategoryName,MembersCount,RegProcessDate,Point,MemberCount,Grade,MsgCount,DisplayName,CuAppDetail,CommunityJoin,CommunityType,num,UserCode,MemberLevel"));
		
		return returnObj;
	}
	
	public int selectUserCommunityGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectUserCommunityGridListCount", params);
	}
	
	public CoviMap selectCommunityTreeData(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityTreeData", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "FolderID,DN_ID,itemType,FolderType,FolderAlias,DisplayName,FolderName,MemberOf,FolderPath,SortKey,SortPath,IsUse,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Reserved2,hasChild,type"));
		
		return returnObj;
	}
	
	public String communitySelectCreateId(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.communitySelectCreateId", params);
		
		return value;
	}
	
	public int checkCommunityNameCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.checkCommunityNameCount", params);
	}
	
	public CoviMap selectCommunityBaseCode(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		selList = coviMapperOne.list("user.community.selectCommunityBaseCode", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		
		return returnObj;
	}
	
	public boolean createCommunityInfomation(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityInfomation", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean createCommunityDetailInfomation(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityDetailInfomation", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateCommunityStatus(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityStatus", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectCommunityInfo(CoviMap params)throws Exception{
		CoviMap subParams = new CoviMap();
		
		subParams = coviMapperOne.select("user.community.selectCommunityInfo", params);
		
		return subParams;
	}
	
	public boolean createObjectGroup(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createObjectGroup", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateObjectGroup(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			params.put("comObjectPath", coviMapperOne.selectOne("user.community.selectComObjectPath", params));
			params.put("sortPath", coviMapperOne.selectOne("user.community.selectSortPath", params));
		}
		
		cnt = coviMapperOne.update("user.community.updateObjectGroup", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateCommunityGroupCode(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityGroupCode", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectCommunityHomeCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityHomeCount", params);
	}
	
	public boolean createCommunityHome(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityHome", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateCommunityACL(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityACL", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean createCommunityACL(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityACL", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectCommunityACLCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityACLCount", params);
	}
	
	
	public int selectCommunityFolderCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityFolderCnt", params);
	}
	
	public boolean createCommunityFolder(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityFolder", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectCommunityMemberCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityMemberCount", params);
	}
	
	public boolean createCommunityMember(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityMember", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateCommunityMemberCount(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityMemberCount", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectCommunityMenuTopCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityMenuTopCount", params);
	}
	
	public boolean createBoardConfig(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createBoardConfig", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectCommunityBoardCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityBoardCount", params);
	}
	
	public boolean createCommunityMenuTop(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		if(coviMapperOne.getNumber("user.community.selectCommunityMenuTopCount", params) == 0) {
			cnt = coviMapperOne.insert("user.community.createCommunityMenuTop", params);
			
			if(cnt > 0){
				flag = true;
			}
		}
		return flag;
	}
	
	public boolean updateBoardConfig(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateBoardConfig", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int communityCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.communityCnt", params);
	}
	
	public boolean updateCommunityNameDictionary(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityNameDictionary", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean createCommunityNameDictionary(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.createCommunityNameDictionary", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectcommunityHeaderSetting(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		CoviList subSelList = new CoviList();
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String companyCode = SessionHelper.getSession("DN_Code");
		//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectcommunityHeaderSetting", params);
		
		for(int j=0; selList.size() > j; j++){
			subParams = (CoviMap) selList.get(j);
			
			if(!func.f_NullCheck(subParams.get("FilePath").toString().trim()).equals("")){
//				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + subParams.get("FilePath").toString()));
//				subParams.put("FilePath", backStorage + subParams.get("FilePath").toString());
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("FilePath").toString()));
				subParams.put("FilePath", subParams.get("FilePath").toString());
			}
			
			if(!func.f_NullCheck(subParams.get("BFilePath").toString().trim()).equals("")){
//				subParams.put("BFileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + subParams.get("BFilePath").toString()));
//				subParams.put("BFilePath", backStorage + subParams.get("BFilePath").toString());
				subParams.put("BFileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("BFilePath").toString()));
				subParams.put("BFilePath", subParams.get("BFilePath").toString());
			}
			
			subSelList.add(subParams);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CommunityName,CommunityType,MemberStatus,DetailStatus,MemberLevel,favoriteCnt,categoryName,CommunityTheme,nowDate,FilePath,FileID,BFilePath,FileCheck,BFileCheck,DN_ID,PortalID,FolderID,Gubun,DefaultBoardType"));
		
		return returnObj;
	}
	
	public CoviMap communitySubHeaderSetting(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.communitySubHeaderSetting", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "RegProcessDate,MemberCNT,visitCnt,totalVisitCnt,communityID"));
		
		return returnObj;
	}
	
	public CoviMap communityLeftUserInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		StringUtil func = new StringUtil();
		// 전체 리스트 조회
		if (!func.f_NullCheck(params.get("IsAdmin").toString().trim()).equals("") && params.get("IsAdmin").toString().trim().equals("Y")) { //관리자에서 커뮤니티 접근시 
			selList = coviMapperOne.list("user.community.communityLeftUserInfoAdmin", params);
		} else {
			selList = coviMapperOne.list("user.community.communityLeftUserInfo", params);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "NickName,UR_Code,MemberLevel,DisplayName,PhotoPath,GroupCode"));
		
		return returnObj;
	}
	
	public boolean communityFavoritesInsert(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.communityFavoritesInsert", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectCommunityVisitCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityVisitCnt", params);
	}
	
	public boolean insertCommunityVisit(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.insertCommunityVisit", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}

	public CoviMap selectCommunityTopMenu(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityTopMenu", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "UseYn,Idx,SortKey,DisplayName,FolderType"));
		
		return returnObj;
	}
	
	public boolean updateCommunityTopMenuUse(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityTopMenuUse", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateCommunityTopMenuSort(CoviMap params) throws Exception {
		int cnt = coviMapperOne.update("user.community.updateCommunityTopMenuSort", params);
		
		return true;
	}
	
	public CoviMap selectCommunityHeaderSettingList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityHeaderSettingList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "DisplayName,MultiDisplayName,FolderType,FolderID,MenuID"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityBoardLeft(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityBoardLeft", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "FolderName,FolderID,itemType,MenuID,SortPath,DisplayName,FolderType,type,IsUse,IsDisplay"));
		
		return returnObj;
	}
	
	
	public CoviMap selectCommunityTagCloud(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityTagCloud", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "Tag,Version,FolderID,MessageID"));
		
		return returnObj;
	}
	
	public int selectCommunitySelectNoticeCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunitySelectNoticeCount", params);
	}
	
	public CoviMap selectCommunitySelectNoticeList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunitySelectNoticeList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "MessageID,Version,Number,FolderID,IsInherited,ParentID,MsgType,MsgState,CategoryID,CategoryName,CategoryPath,Seq,Step,Depth,Subject,IsPopup,IsTop,PopupStartDate,PopupEndDate,TopStartDate,TopEndDate,ExpiredDate,UseSecurity,UseAnonym,IsApproval,IsUserForm,IsCheckOut,UseScrap,NoticeMedia,UseRSS,TrackBackURL,AnswerCnt,ReadCnt,CommentCnt,RecommendCnt,ScrapCnt,ReportCnt,FileCnt,FileExtension,TracbackCnt,RegistDate,CreatorCode,MultiDisplayName,CreateDate,CreatorName,CreatorLevel,CreatorPosition,CreatorTitle,CreatorDept,DeleteDate,ReservationDate,OwnerCode,LinkURL,RegistDept,RegistDeptName,ProgressState,RevisionDate,RevisionName,ListTop,UF_Value0,UF_Value1,UF_Value2,UF_Value3,UF_Value4,UF_Value5,UF_Value6,UF_Value7,UF_Value8,UF_Value9,NickName,boardFolderName,IsRead,FileID,CU_ID,CommunityName,IsDisplay"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityActivity(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityActivity", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "visitCnt,VisitDate,sortDate"));
		
		return returnObj;
	}
	
	public String selectCommunityUserLevelCheck(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.selectCommunityUserLevelCheck", params);
		
		return value;
	}
	
	public String selectCommunityTypeCheck(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.selectCommunityTypeCheck", params);
		
		return value;
	}
	
	public CoviMap selectCommunityDetailInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityDetailInfo", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "LimitFileSize,UsedFileSize,MemberCount,MsgCount,ReplyCount,OneMsgCount,VisitCount,ViewCount,Point,Grade,RegProcessDate,CU_ID,CommunityName,RegStatus,opName,crName,SearchTitle,LimitFileSize,FileSize,number,DescriptionEditor,ProvisionEditor,CategoryID,CommunityType,opDeptName,opJobPositionName,opJobLevelName,opJobTitleName,crDeptName,crJobPositionName,crJobLevelName,crJobTitleName,MemberLevel,MemberStatus,DetailStatus,DIC_Name,KoShortWord,KoFullWord,EnShortWord,EnFullWord,JaShortWord,JaFullWord,ZhShortWord,ZhFullWord,UserCode,Description,Provision,DN_ID,OperatorCode,UnRegRequestDate,UnRegProcessDate,AppStatus,AppStatusCode,ClosingMsg,DescriptionOption,ProvisionOption,FileID,JoinOption"));
		
		return returnObj;
	}
	
	public CoviMap selectCurrentLocation(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCurrentLocation", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "id,DisplayName,parentId,num"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityVisitList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityVisitList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "VisitDate,UserCode,DisplayName"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityJoinUserInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityJoinUserInfo", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "MailAddress,DisplayName,JoinOption"));
		
		return returnObj;
	}
	
	public boolean communityUserJoin(CoviMap params, String op) throws Exception {
		int cnt = 0;
		boolean flag = false;
		List list = new ArrayList();
		
		StringUtil func = new StringUtil();
		String key = "";
		if(func.f_NullCheck(op).equals("A")){
			
			params.put("MemberStatus", "R" );
			params.put("DetailStatus", "RV" );
			
			params.put("DefaultMemberLevel",coviMapperOne.getString("user.community.selectCommunityDefaultMemberLevel", params));
			
			cnt = coviMapperOne.insert("user.community.insertCommunityMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
			/*
			if(coviMapperOne.getNumber("user.community.insertCommunityGroupMemberCount", params) == 0){
				cnt = coviMapperOne.insert("user.community.insertCommunityGroupMember", params);
				if(cnt > 0){
					flag = true;
					
					cnt = coviMapperOne.insert("user.community.insertCommunityGroupMemberByGrade", params);
					if (cnt == 0) {
						flag = false;
						return flag;
					}
				}else{
					flag = false;
					return flag;
				}
			}else{
				flag = true;
			}
			*/
			
			if(coviMapperOne.getNumber("user.community.insertCommunityGroupMemberByGradeCnt", params) == 0){
				cnt = coviMapperOne.insert("user.community.insertCommunityGroupMemberByGrade", params);
				if(cnt > 0){
					flag = true;
				}else{
					flag = false;
					return flag;
				}
			}else{
				flag = true;
			}
			
			if(clearRedisCache(params)){
				
			}else{
				flag = false;
				return flag;
			}
		
		}else{
			params.put("MemberStatus", "E" );
			params.put("DetailStatus", "RA" );
			params.put("DefaultMemberLevel", "0" );
			
			cnt = coviMapperOne.insert("user.community.insertCommunityMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
			if (flag) {
				params.put("Code", "JoiningRequest");
				params.put("SubCode", ""); 
				_sendMessaging(params);
			}
		}
		
		return flag;
	}
	
	public int selectCommunityMemberDuplyCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityMemberDuplyCnt", params);
	}
	
	public String selectCommunityScheduleMenu(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.selectCommunityScheduleMenu", params);
		
		return value;
	}
	
	public int selectCommunityMemberManageGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityMemberManageGridListCount", params);
	}
	
	public CoviMap selectCommunityMemberManageGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityMemberManageGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "UR_Code,RegRequestDate,opName,opDeptName,opJobPositionName"));
		
		return returnObj;
	}
	
	public int selectCommunityDeleteMemberGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityDeleteMemberGridListCount", params);
	}
	
	public CoviMap selectCommunityDeleteMemberGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityDeleteMemberGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "UR_Code,opName,opDeptName,opJobPositionName,DetailStatus,LeaveProcessDate,LeaveMessage,RegProcessDate"));
		return returnObj;
	}
	
	public int selectCommunityMemberGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityMemberGridListCount", params);
	}
	
	public CoviMap selectCommunityMemberGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityMemberGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "UR_Code,opName,MailAddress,opDeptName,opJobPositionName,VisitCount,DetailStatus,MsgCount,ReplyCount,ViewCount,VisitDate,RegProcessDate,CuMemberLevel,memberLevel,MailAddress,PhoneNumber,PhotoPath,CommunityName"));
		return returnObj;
	}
	
	public boolean communityJoinProcess(CoviMap params, String op) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		StringUtil func = new StringUtil();
		List list = new ArrayList();
		
		String key = "";
		
		if(func.f_NullCheck(op).equals("P")){ //승인
			params.put("MemberStatus", "R" );
			params.put("DetailStatus", "RV" );
			
			params.put("DefaultMemberLevel",coviMapperOne.getString("user.community.selectCommunityDefaultMemberLevel", params));
			
			cnt = coviMapperOne.update("user.community.updateCommunityMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
			// 기존 로직에 Community 하위 그룹에 사용자 삽입 로직 주석처리
			/*
			if(coviMapperOne.getNumber("user.community.insertCommunityGroupMemberCount", params) == 0){
				cnt = coviMapperOne.insert("user.community.insertCommunityGroupMember", params);
				if(cnt > 0){
					flag = true;
				}else{
					flag = false;
					return flag;
				}
			}else{
				cnt = coviMapperOne.update("user.community.updateCommunityGroupMember", params);
				if (cnt > 0) {
					flag = true;
				} else {
					flag = false;
					return flag;
				}
			}
			*/
			
			if (coviMapperOne.getNumber("user.community.insertCommunityGroupMemberByGradeCnt", params) == 0) {
				cnt = coviMapperOne.insert("user.community.insertCommunityGroupMemberByGrade", params);
				if (cnt > 0) {
					flag = true;
				} else {
					flag = false;
					return flag;
				}
			}
			
			params.put("Code","JoiningApproval");
			params.put("SubCode", "");
			
			//TODO-COMMUNITY
			if(!_sendMessaging(params)){
				
			}
			
			if(clearRedisCache(params)){
				
			}else{
				flag = false;
				return flag;
			}
		}else if(func.f_NullCheck(op).equals("C")){ //거부
			//거부
			params.put("MemberStatus", "U" );
			params.put("DetailStatus", "RD" );
			
			params.put("DefaultMemberLevel", '0');
			
			cnt = coviMapperOne.update("user.community.updateCommunityMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
			params.put("Code","JoiningReject");
			params.put("SubCode", ""); 
			
			if(!_sendMessaging(params)){
				
			}
			
		}else if(func.f_NullCheck(op).equals("CC")){ 
			params.put("MemberStatus", "R" );
			params.put("DetailStatus", "RV" );
			
			params.put("DefaultMemberLevel",coviMapperOne.getString("user.community.selectCommunityDefaultMemberLevel", params));
			
			cnt = coviMapperOne.update("user.community.updateCommunityMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
			if(coviMapperOne.getNumber("user.community.insertCommunityGroupMemberCount", params) == 0){
				cnt = coviMapperOne.insert("user.community.insertCommunityGroupMember", params);
				if(cnt > 0){
					flag = true;
				}else{
					flag = false;
					return flag;
				}
			} else {
				cnt = coviMapperOne.update("user.community.updateCommunityGroupMember", params);
				if (cnt > 0) {
					flag = true;
				} else {
					flag = false;
					return flag;
				}
			}
			
			if (coviMapperOne.getNumber("user.community.insertCommunityGroupMemberByGradeCnt", params) == 0) {
				cnt = coviMapperOne.insert("user.community.insertCommunityGroupMemberByGrade", params);
				if (cnt > 0) {
					flag = true;
				} else {
					flag = false;
					return flag;
				}
			}
			
			if(clearRedisCache(params)){
				
			}else{
				flag = false;
				return flag;
			}
		}else if(func.f_NullCheck(op).equals("PP")){
			
			params.put("MemberStatus", "E" );
			params.put("DetailStatus", "RA" );
			params.put("DefaultMemberLevel", "0" );
			
			cnt = coviMapperOne.update("user.community.updateCommunityMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
			if(flag) {
				params.put("Code", "JoiningRequest");
				params.put("SubCode", ""); 
				_sendMessaging(params);
			}
		}
		
		return flag;
	}
	
	public CoviMap communityMemberMenageListExcelList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityMemberManageGridList", params);
		int cnt = (int) coviMapperOne.getNumber("user.community.selectCommunityMemberManageGridListCount", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "RegRequestDate,opName,opDeptName,opJobPositionName"));
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	public CoviMap communityDeleteMemberListExcelList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityDeleteMemberGridList", params);
		int cnt = (int) coviMapperOne.getNumber("user.community.selectCommunityDeleteMemberGridListCount", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "opName,opDeptName,opJobPositionName,DetailStatus,LeaveProcessDate,LeaveMessage,RegProcessDate"));
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	public CoviMap communityMemberListExcelList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityMemberGridList", params);
		int cnt = (int) coviMapperOne.getNumber("user.community.selectCommunityMemberGridListCount", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "opName,opDeptName,VisitCount,MsgCount,ReplyCount,ViewCount,VisitDate,RegProcessDate,CuMemberLevel"));
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	public CoviMap selectMemberLevelBox(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectMemberLevelBox", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		
		return returnObj;
	}
	
	public boolean communityMemberLevelChange(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.communityGroupMemberLevelChange", params);
		if (cnt > 0) {
			flag = true;
		} else {
			flag = false;
		}
		
		cnt = coviMapperOne.update("user.community.communityMemberLevelChange", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public CoviMap selectCommunityLeaveInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityLeaveInfo", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "now_date,MemberLevel,CommunityName,DisplayName,DeptName,JobPositionName,CuMemberLevel,RegProcessDate,MailAddress,CommunityName,MultiJobPositionName,MultiJobLevelName,MultiJobTitleName"));
		
		return returnObj;
	}
	
	public boolean communityMemberLeave(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.communityMemberLeave", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		cnt = coviMapperOne.update("user.community.communityGropMemberLeave", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		if (coviMapperOne.getNumber("user.community.communityGroupMemberGradeLeaveCnt", params) > 0) {
			cnt = coviMapperOne.delete("user.community.communityGroupMemberGradeLeave", params);
			if (cnt > 0) {
				flag = true;
			} else {
				flag = false;
			}
		}
		
		if (flag) {
			params.put("Code", "Withdrawal");
			this._sendMessaging(params);
		}
		
		return flag;
	}
	
	public boolean updateCommunityMemberOperatorCode(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityMemberOperatorCode", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectCommunityBoardRankInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityBoardRankInfo", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "num,UserCode,opName,MsgCount,PhotoPath"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityVisitRankInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityVisitRankInfo", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "num,UserCode,opName,VisitCount,PhotoPath"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityCallMember(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityCallMemberList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "UR_Code,opName"));
		return returnObj;
	}
	
	public String selectCommunityName(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.selectCommunityName", params);
		
		return value;
	}
	
	public boolean communityCallMemberSendMessage(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.communityCallMemberSendMessage", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean communityUpdateInfo(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		params.put("DN_ID", (int) coviMapperOne.getNumber("user.community.selectCommunityDomainID", params));
		
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Community");
		editorParam.put("imgInfo", params.getString("txtStipulationInlineImage"));
		editorParam.put("objectID", params.getString("CU_ID"));
		editorParam.put("objectType", "CU");
		editorParam.put("messageID", "0");
		editorParam.put("bodyHtml",params.getString("txtStipulationEditer"));
		
		CoviMap StipulationEditorInfo = editorService.getContent(editorParam);
		
        if(StipulationEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
        
		params.put("txtStipulationEditer", StipulationEditorInfo.getString("BodyHtml"));
		
		editorParam.put("imgInfo", params.getString("txtIntroductionInlineImage"));
		editorParam.put("bodyHtml",params.getString("txtIntroductionEditer"));
		
		CoviMap IntroductionEditorInfo = editorService.getContent(editorParam);
		
        if(IntroductionEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
        
		params.put("txtIntroductionEditer", IntroductionEditorInfo.getString("BodyHtml"));
		
		// group member 테이블에서 기존 운영자삭제
		// coviMapperOne.delete("user.community.deleteCommunityBeforeOperatorGroupMemberGrade", params);
		// 2022.07.29 group member 테이블에서 기존 운영자 정회원으로 변경
		coviMapperOne.delete("user.community.updateCommunityBeforeOperatorGroupMember", params);
		coviMapperOne.update("user.community.updateCommunityBeforeOperatorMember", params);
		
		if(coviMapperOne.getNumber("user.community.selectCommunityMemberCheckCount", params) > 0){
			cnt = coviMapperOne.update("user.community.updateCommunityOperatorMember", params);
			// 기존 사용자 그룹 9(운영자)로 변경 ( Delete -> Insert )
			coviMapperOne.delete("user.community.deleteCommunityGroupMemberGrade", params);
			coviMapperOne.insert("user.community.insertCommunityOperatorGroupMember", params);
			
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			cnt = coviMapperOne.insert("user.community.createCommunityOperatorMember", params);
			// 운영자 그룹에 추가
			coviMapperOne.insert("user.community.insertCommunityOperatorGroupMember", params);
			
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}
		
		cnt = coviMapperOne.update("user.community.communityUpdateInfo", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		cnt = coviMapperOne.update("user.community.communityGroupUpdateInfo", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		cnt = coviMapperOne.update("user.community.communityFolderUpdateInfo", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		// 운영자 변경 시 커뮤니티 게시판 담당자도 변경한다.
		cnt = coviMapperOne.update("user.community.communityFolderUpdateOnwer", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		if(coviMapperOne.getNumber("user.community.communityCnt", params) > 0){
			cnt = coviMapperOne.update("user.community.updateCommunityNameDictionary", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			cnt = coviMapperOne.insert("user.community.createCommunityNameDictionary", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}
		
		if(coviMapperOne.getNumber("user.community.communityTextDetailCnt", params) > 0){
			cnt = coviMapperOne.update("user.community.communityUpdateInfoText", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			cnt = coviMapperOne.insert("user.community.communityCreateInfoText", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}
		
		params.put("UR_Code", params.get("operatorCode"));
		// 커뮤니티 회원이 아닐경우 커뮤니티 그룹에 소속시키는 로직으로 그룹별로 회원을 포함시키는 변경로직과는 맞지않아 주석처리
		/*
		if(coviMapperOne.getNumber("user.community.insertCommunityGroupMemberCount", params) == 0){
			cnt = coviMapperOne.insert("user.community.insertCommunityGroupMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			flag = true;
		}
		*/
		
		return flag;
	}
	
	public int selectCommunityAllianceGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityAllianceGridListCount", params);
	}
	
	public CoviMap selectCommunityAllianceGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityAllianceGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CU_ID,PartiID,CommunityName,DisplayName,MailAddress,OperatorCode,RegProcessDate,MemberCount,RequestDate,ProcessingDate,RecipientID,RecipientName,RecipientMailAddress,RequesterID,RequesterName,RequesterMailAddress,statusNm,Status,keyNum,SearchTitle,ProcessingMessage,FileID")); 
		return returnObj;
	}
	
	public boolean updateCommunityMember(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.updateCommunityOpMember", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectAlianceType(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectAlianceType", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		
		return returnObj;
	}
	
	public boolean updateAllianceApprove(CoviMap params, String checkNum) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		StringUtil func = new StringUtil();
		
		if(func.f_NullCheck(checkNum).equals("X")){
			cnt = coviMapperOne.insert("user.community.createAllianceApprove", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
			
		}else{
			
			cnt = coviMapperOne.update("user.community.updateAllianceApprove", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}

		if (flag) {
			params.put("CU_ID", params.get("RecipientID"));
			params.put("Code", "PartiNotice");
			params.put("SubCode", params.get("Status"));
			
			if(!_sendMessaging(params)){
				//실패처리 안함.
			}
		}
		
		return flag;
	}
	
	public CoviMap communityAllianceList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		CoviList subSelList = new CoviList();
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String companyCode = SessionHelper.getSession("DN_Code");
		//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.communityAllianceList", params);
		
		for(int j=0; selList.size() > j; j++){
			subParams = (CoviMap) selList.get(j);
			
			if(func.f_NullCheck(subParams.get("FilePath")) != null && !(subParams.get("FilePath").toString().equals(""))){
				//subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + subParams.get("FilePath").toString()));
				subParams.put("FileCheck", fileSvc.fileIsExistsBoolean(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + subParams.get("FilePath").toString()));
			}
			
			subSelList.add(subParams);
		}
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(subSelList, "communityID,CommunityName,FilePath,categoryName,FileCheck"));
		
		return returnObj;
	}
	
	public boolean communityClosingUpdate(CoviMap params) throws Exception {
		List list = new ArrayList();
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.communityClosingUpdate", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		if (flag) {
			params.put("Code","CloseRequest");
			_sendMessaging(params);
		}
		
		return flag;
	}
	
	public boolean communityLayoutHeaderSet(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		if(coviMapperOne.getNumber("user.community.communityLayoutHeaderCount", params) > 0){
			cnt = coviMapperOne.update("user.community.communityLayoutHeaderUpdate", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
			}
		}else{
			cnt = coviMapperOne.insert("user.community.communityLayoutHeaderCreate", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
			}
		}
		
		return flag;
	}
	
	public boolean communityLayoutDoorSet(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		//Editor 처리 
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Community");
		editorParam.put("imgInfo", params.getString("BodyInlineImage"));
		editorParam.put("objectID", params.getString("CU_ID"));
		editorParam.put("objectType", "CU");
		editorParam.put("messageID", "0");
		editorParam.put("bodyHtml",params.getString("BodyText"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
        
		params.put("BodyText", editorInfo.getString("BodyHtml"));
		
		if(coviMapperOne.getNumber("user.community.communityLayoutDoorCount", params) > 0){
			cnt = coviMapperOne.update("user.community.communityLayoutDoorNotUseUpdate", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}
		
		cnt = coviMapperOne.insert("user.community.communityLayoutDoorCreate", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
		
	}
	
	public boolean communityLayoutDoorUpdate(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		//Editor 처리 
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Community");
		editorParam.put("imgInfo", params.getString("BodyInlineImage"));
		editorParam.put("objectID", params.getString("CU_ID"));
		editorParam.put("objectType", "CU");
		editorParam.put("messageID", "0");
		editorParam.put("bodyHtml",params.getString("BodyText"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
		
		params.put("BodyText", editorInfo.getString("BodyHtml"));
		
		cnt = coviMapperOne.update("user.community.communityLayoutDoorUpdate", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		return flag;
		
	}
	
	public CoviMap selectCommunityDoorList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityDoorList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "DoorID,RegistDate,IsCurrent"));
		
		return returnObj;
	}
	
	public String selectCommunityDoorText(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.selectCommunityDoorText", params);
		
		return value;
	}
	
	public boolean communityLayoutDoorChange(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.communityLayoutDoorNotUseUpdate", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		cnt = coviMapperOne.update("user.community.communityLayoutDoorChange", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		return flag;
		
	}
	
	public boolean communityLayoutDoorDelete(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("user.community.communityLayoutDoorDelete", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		return flag;
		
	}
	
	public String communitySelectDoor(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.communitySelectDoor", params);
		
		return value;
	}
	
	public String getCommunityName(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.getCommunityName", params);
		
		return value;
	}
	
	public String sendMessagingSettingUserCode(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.sendMessagingSettingUserCode", params);
		
		return value;
	}
	
	public boolean communityImgSet(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		if(coviMapperOne.getNumber("user.community.communityImgCount", params) > 0 ){
			cnt = coviMapperOne.update("user.community.communityImgCurrentUpdate", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}
		
		// 앞으로 사용하지 않음.. 사용하는쪽에서 fileid 기준으로 해당 storage정보로 경로 조회하도록 변경
		//String backServicePath = "Community/";
		String currentDay = DateHelper.getCurrentDay("yyyy/MM/dd");
		String fullPath = currentDay+"/"; //backServicePath + currentDay+"/" ;
		
		params.put("FilePath", fullPath);
		
		cnt = coviMapperOne.insert("user.community.communityImgSet", params);
		if(cnt > 0){
			
			params.put("storageControl", PLUS);
			
			cnt = coviMapperOne.update("user.community.communityFileSize", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			flag = false;
			return flag;
		}
		
		CoviList frontFileInfos = new CoviList();
		frontFileInfos.add(params);		
		
		CoviList backFileInfos = fileSvc.moveToBack(frontFileInfos, "Community/", "Community", params.get("ImageID").toString(), "NONE", "0");
		
		int size = backFileInfos.size();
		
		if(size > 0){
			for(int i = 0 ; i < backFileInfos.size() ; i++){
				CoviMap spaceJSON = backFileInfos.getJSONObject(i);
				params.put("fullPath",  fullPath + spaceJSON.getString("SavedName"));
				params.put("FileID", spaceJSON.getString("FileID"));
				
				cnt = coviMapperOne.update("user.community.communityImgPathUpdate", params);
				if(cnt > 0){
					flag = true;
				}else{
					flag = false;
					return flag;
				}
				
			}
		}else{
			flag = false;
		}
		
		return flag;
		
	}
	
	public CoviMap selectCommunityImageList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.selectCommunityImageList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "ImageID,FilePath,IsCurrent,FileID,CompanyCode,RegistDate,FullPath"));
		return returnObj;
	}
	
	public boolean communityImgDel(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		//file size 가져오기 
		int size = (int) coviMapperOne.getNumber("user.community.selectCommunityImageFileSize", params);
		
		cnt = coviMapperOne.delete("user.community.communityImgDel", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		cnt = coviMapperOne.delete("user.community.communityImgSysFileDel", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		params.put("Size", size);
		params.put("storageControl", MINUS);
		
		//파일 사이즈 크기 만큼 커뮤니티 용량 제거.
		cnt = coviMapperOne.update("user.community.communityFileSize", params);
		if(cnt > 0){
			flag = true;	
		}else{
			flag = false;
			return flag;
		}
		
		return flag;
	}
	
	public boolean communityImgChoice(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("user.community.communityImgCurrentChoice", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		cnt = coviMapperOne.update("user.community.communityImgChoice", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		return flag;
	}
	
	public int selectCommunityNoticeCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityNoticeCnt", params);
	}
	
	public boolean communitySearchWordPoint(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		if(coviMapperOne.getNumber("user.community.communitySearchWordPointCount", params) > 0){
			cnt = coviMapperOne.update("user.community.communitySearchWordPointUpdate", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			cnt = coviMapperOne.insert("user.community.communitySearchWordPoint", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}
		
		return flag;
	}
	
	public boolean communityParentCreate(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.communityParentCreate", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
			return flag;
		}
		
		return flag;
		
	}
	
	public boolean communityNewCreateSite(CoviMap params){
		CoviMap subParams = new CoviMap();
		StringUtil func = new StringUtil();
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		int cnt = 0;
		boolean flag = false;
		
		try {
			params.put("DN_ID",(int) coviMapperOne.getNumber("user.community.selectCommunityCategoryDomainID", params));
			cnt = coviMapperOne.insert("user.community.createCommunityInfomation", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("CU_ID") != null){
				// CU_Code 처리
				coviMapperOne.update("user.community.updateCommunityCode", params);
				
				//Editor 처리
				CoviMap editorParam = new CoviMap();
				editorParam.put("serviceType", "Community");
				editorParam.put("imgInfo", params.getString("txtStipulationInlineImage"));
				editorParam.put("objectID", params.getString("CU_ID"));
				editorParam.put("objectType", "CU");
				editorParam.put("messageID", "0");
				editorParam.put("bodyHtml", params.getString("txtStipulationEditer"));
				
				CoviMap StipulationEditorInfo = editorService.getContent(editorParam);
				
		        if(StipulationEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
		        	throw new Exception("InlineImage move BackStorage Error");
		        }
				
				params.put("txtStipulationEditer", StipulationEditorInfo.getString("BodyHtml"));
				
				editorParam.put("imgInfo", params.getString("txtIntroductionInlineImage"));
				editorParam.put("bodyHtml", params.getString("txtIntroductionEditer"));
				
				CoviMap IntroductionEditorInfo = editorService.getContent(editorParam);
				
		        if(IntroductionEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
		        	throw new Exception("InlineImage move BackStorage Error");
		        }
				
				params.put("txtIntroductionEditer", IntroductionEditorInfo.getString("BodyHtml"));
				
				cnt = coviMapperOne.insert("user.community.createCommunityDetailInfomation", params);
				if(cnt > 0){
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
				cnt = coviMapperOne.update("user.community.createCommunityInfomationCode", params);
				if(cnt < 1){
					throw new Exception("");
				}
			}
			
			cnt = coviMapperOne.update("user.community.updateCommunityStatus", params);
			if(cnt > 0){
				subParams = coviMapperOne.select("user.community.selectCommunityInfo", params);
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.insert("user.community.createObjectGroup", subParams);
			if(cnt > 0){
				if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
					subParams.put("comObjectPath", coviMapperOne.selectOne("user.community.selectComObjectPath", subParams));
					subParams.put("sortPath", coviMapperOne.selectOne("user.community.selectSortPath", subParams));
				}
				
				cnt = coviMapperOne.update("user.community.updateObjectGroup", subParams);
				if(cnt > 0){
					params.put("IsDisplay",'Y');
					params.put("IsUse",'Y');
				}else{
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.update("user.community.updateCommunityGroupCode", params);
			if(cnt > 0){
				//SUCCESS
			}else{
				throw new Exception("");
			}
			
			//커뮤니티 홈 체크
			if(coviMapperOne.getNumber("user.community.selectCommunityHomeCount", params) > 0){
				cnt = coviMapperOne.insert("user.community.createCommunityHome", params);
				if(cnt > 0){
					params.put("ObjectType", "CU");
					params.put("SubjectType", "CM");
					params.put("SubjectCode", subParams.get("CategoryID").toString());
				}else{
					throw new Exception("");
				}
			}
			
			//커뮤니티 기본 권한 설정
			if(coviMapperOne.getNumber("user.community.selectCommunityACLCount", params) > 0){
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM", "S____VR", "S", "_", "_", "_", "_", "V", "R", "U", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "3");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM", "_______", "_", "_", "_", "_", "_", "_", "_", "U", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					params.put("userLevel", "0");
				}
			}else{
				//insert
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM", "S____VR", "S", "_", "_", "_", "_", "V", "R", "C", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "3");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM", "_______", "_", "_", "_", "_", "_", "_", "_", "C", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "0");
				}
			}
			
			params.put("CommunityName", subParams.get("CommunityName"));
			params.put("CommunityMultiName", subParams.get("CommunityName"));
			params.put("DN_ID", subParams.get("DN_ID"));
			
			List list = new ArrayList();
			
			String sSecLevel = RedisDataUtil.getBaseConfig("DefaultSecurityLevel", SessionHelper.getSession("DN_ID"))
					.equals("") ? "90"
							: RedisDataUtil.getBaseConfig("DefaultSecurityLevel", SessionHelper.getSession("DN_ID"));
			
			params.put("CommunityType", subParams.get("CommunityType"));
			params.put("MemberOf", "0");
			params.put("SortKey", "1");
			params.put("SortPath", "000000000000001;");
			params.put("MenuID", params.get("CU_ID"));
			params.put("SecurityLevel", sSecLevel);
			params.put("IsInherited", "Y");
			params.put("Reserved2", "");
			params.put("FolderType", "Root");
			params.put("DefaultBoardType", subParams.get("DefaultBoardType"));
			
			String MemberOf = "";
			
			cnt = coviMapperOne.insert("user.community.createCommunityFolder", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("FolderID") != null){
				MemberOf = params.get("FolderID").toString();
				
				if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR", "SC__EVR", "S", "C", "_", "_", "E", "V", "R", "C", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			list = coviMapperOne.list("user.community.communityFolderList", params);
			
			String CommunityName = params.get("CommunityName").toString();
			
			if(list.size() > 0){
				CoviMap FolderParams = new CoviMap();
				for(int j = 0; j < list.size(); j++){
					FolderParams = (CoviMap) list.get(j);
					FolderParams.put("CU_ID", params.get("CU_ID"));
					
					params.put("FolderType", FolderParams.get("FolderType"));
					
					if(FolderParams.get("FolderType").equals("Schedule")){
						params.put("MemberOf", RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
						params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
						params.put("SortKey", FolderParams.get("SortKey"));
						params.put("SortPath", coviMapperOne.getString("user.community.selectCommunityScheduleMenu", params));
						params.put("SecurityLevel", "90");
						params.put("IsInherited", 'N');
						params.put("Reserved2", RedisDataUtil.getBaseConfig("FolderDefaultColor"));
						params.put("CommunityName", CommunityName);
						params.put("CommunityMultiName", CommunityName);
						
						cnt = coviMapperOne.insert("user.community.createCommunityFolder", params);
						//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
						//일정 권한일 경우 공개형일 경우라도 회사 권한을 넣지 않는다.
						if(cnt > 0 || params.get("FolderID") != null){
							if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "CM" ,"SCDMEVR", "S", "C", "D", "M", "E", "V", "R", "C", params.get("userID").toString(), subParams.getString("DN_ID"), "C")){
								throw new Exception("");
							}
						}else{
							throw new Exception("");
						}
					}else{
						params.put("MemberOf", MemberOf);
						params.put("SortKey", FolderParams.get("SortKey"));
						params.put("SortPath", "");
						params.put("MenuID", params.get("CU_ID"));
						params.put("SecurityLevel", sSecLevel);
						params.put("IsInherited", "Y");
						params.put("Reserved2", "");
						params.put("CommunityName", FolderParams.get("FolderName"));
						params.put("CommunityMultiName", FolderParams.get("DisplayFolderName"));
						
						cnt = coviMapperOne.insert("user.community.createCommunityFolder", params);
						//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
						if(cnt > 0 || params.get("FolderID") != null){
							
							// 한줄 게시판일 경우 공개형일 경우라도 회사 권한을 넣지 않는다.
							if(FolderParams.get("FolderType").equals("QuickComment")){
								if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR", "SC__EVR", "S", "C", "_", "_", "E", "V", "R", "C", params.get("userID").toString(), subParams.getString("DN_ID"), "C")){
									throw new Exception("");
								}
							}else {
								if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR", "SC__EVR", "S", "C", "_", "_", "E", "V", "R", "C", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
									throw new Exception("");
								}
							}
							
							params.put("userCode", params.getString("userID"));
							if(!createBoardConfig(params)) { //board_config 추가 
								throw new Exception("");
							}
						}else{
							throw new Exception("");
						}
						
						if(FolderParams.get("FolderType").equals("QuickComment")){
							CoviMap QuickParams = new CoviMap();
							List mf = new ArrayList();
							
							QuickParams.put("folderID", params.get("FolderID").toString());
							QuickParams.put("subject", FolderParams.get("FolderName"));
							QuickParams.put("bodyText", " ");
							QuickParams.put("body", " ");
							QuickParams.put("bodySize", 1);
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
					if(coviMapperOne.getNumber("user.community.selectCommunityMenuTopCount", params) == 0){
						cnt = coviMapperOne.insert("user.community.createCommunityMenuTop", params);
						if(cnt > 0){
							
						}else{
							throw new Exception("");
						}
						
					}
				}
			}
			
			params.put("SubjectCode", subParams.get("DomainCode").toString());
			
			//커뮤니티 그룹 권한 설정
			if(coviMapperOne.getNumber("user.community.selectCommunityACLCount", params) > 0){
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM", "S____VR", "S", "_", "_", "_", "_", "V", "R", "U", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}else{
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM", "S____VR", "S", "_", "_", "_", "_", "V", "R", "C", params.get("userID").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}
			
			//커뮤니티 운영자로 등록 
			if(coviMapperOne.getNumber("user.community.selectCommunityMemberCount", params) > 0){
				cnt = coviMapperOne.update("user.community.updateCommunityOpMember", params);
				if(cnt > 0){
					cnt = coviMapperOne.update("user.community.updateCommunityMemberOperatorCode", params);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}else{
				cnt = coviMapperOne.insert("user.community.createCommunityMember", params);
				if(cnt > 0){
					cnt = coviMapperOne.update("user.community.updateCommunityMemberOperatorCode", params);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}	
				}else{
					throw new Exception("");
				}
			}
			
			if( coviMapperOne.getNumber("user.community.communityCnt", params) > 0){
				cnt = coviMapperOne.update("user.community.updateCommunityNameDictionary", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}else{
				cnt = coviMapperOne.insert("user.community.createCommunityNameDictionary", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}
			
			params.put("CommunityName", CommunityName);
			params.put("DIC_Code", "CU_" + params.get("CU_ID"));
			
			//Portal 등록
			params.put("PortalTag", RedisDataUtil.getBaseConfig("communityPortalTag"));
			params.put("LayoutSizeTag", RedisDataUtil.getBaseConfig("communityLayoutSizeTag"));
			
			cnt = coviMapperOne.insert("user.community.createCommunityWebPortal", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("PortalID") != null){
				
			}else{
				throw new Exception("");
			}
			
			CoviList portalList = new CoviList();
			
			//Portal Webpart 조회 /등록
			portalList = coviMapperOne.list("user.community.communityDefaultPortalList", params);
			
			if(portalList.size() > 0 ){
				CoviMap PortalParams = new CoviMap();
				for(int k = 0; k < portalList.size(); k++){					
					PortalParams = (CoviMap) portalList.get(k);
					PortalParams.put("PortalID", params.get("PortalID"));
					PortalParams.put("CU_ID", params.get("CU_ID"));
					PortalParams.put("userID", params.get("userID"));
					PortalParams.put("DataJSON", "[]");
					
					cnt = coviMapperOne.insert("user.community.createCommunityWebPart", PortalParams);
					//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
					if(cnt > 0 || PortalParams.get("WebpartID") != null){
						
					}else{
						throw new Exception("");
					}
					
					cnt = coviMapperOne.insert("user.community.createCommunityLayout", PortalParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}
			}
			
			params.put("UR_Code", params.get("userID"));
			params.put("Code", "CreateRequest");
			params.put("SubCode", "");
			
			//TODO-COMMUNITY
			if(!_sendMessaging(params)){
				
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
	
	public boolean ACL(String ObjectID,String ObjectType,String SubjectCode,String SubjectType, String AclList, String Security, String Create, String Delete, String Modify, String Execute, String View, String Read, String Type, String userID, String dnID, String CommunityType){
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
		aclParams.put("userCode", userID);
		
		try {
			if(func.f_NullCheck(Type).equals("U")){
				
				count = coviMapperOne.update("user.community.updateCommunityACL", aclParams);
				if(count > 0){
					return true;
				}else{
					return false;
				}
				
			}else if(func.f_NullCheck(Type).equals("C")){
				
				count = coviMapperOne.insert("user.community.createCommunityACL", aclParams);
				
				if (aclParams.get("ObjectType").toString().equals("FD")) {
					CoviMap gradeParams = new CoviMap();
					CoviMap gradeMap = new CoviMap();
					
					gradeParams.put("lang", SessionHelper.getSession("lang"));
					gradeParams.put("domainID", SessionHelper.getSession("DN_ID"));
					
					List gradeList = new ArrayList();
					gradeList = coviMapperOne.list("user.community.selectCommunityGradeList", gradeParams);
					
					if (gradeList.size() > 0) {
						for (int i = 0; i < gradeList.size(); ++i) {
							gradeMap = (CoviMap)gradeList.get(i);
							
							String subjectCode = aclParams.get("SubjectCode").toString().length() > 9 ? "CommunityGrade" + aclParams.get("SubjectCode").toString().substring(9) + "_" + gradeMap.get("Code") : aclParams.get("SubjectCode").toString();
							String aclList = "";
							String security = "S";
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
							gradeAclParams.put("userCode", aclParams.get("userID"));
							
							coviMapperOne.insert("user.community.createCommunityACL", gradeAclParams);
						}
					}
					
					// 공개 커뮤니티 생성일 경우 비회원의 게시물 조회를 위해서 회사에 조회, 읽기 권한 부여
					if(func.f_NullCheck(CommunityType).equals("P")){
						String aclList = "";
						String security = "_";
						String create = "_";
						String delete = "_";
						String modify = "_";
						String execute = "_";
						String view = "V";
						String read = "R";
						
						aclList = security + create + delete + modify + execute + view + read;
						
						CoviMap companyAclParams = new CoviMap();
						
						companyAclParams.put("ObjectID", aclParams.get("ObjectID"));
						companyAclParams.put("ObjectType", aclParams.get("ObjectType"));
						companyAclParams.put("SubjectType", aclParams.get("SubjectType"));
						companyAclParams.put("AclList", aclList);
						companyAclParams.put("Security", security);
						companyAclParams.put("Create", create);
						companyAclParams.put("Delete", delete);
						companyAclParams.put("Modify", modify);
						companyAclParams.put("Execute",execute);
						companyAclParams.put("View", view);
						companyAclParams.put("Read", read);
						companyAclParams.put("userCode", aclParams.get("userID"));
						companyAclParams.put("DomainID", dnID);
						
						coviMapperOne.insert("user.community.createCommunityCompanyACL", companyAclParams);
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
	
	public CoviList getWebpartList(CoviMap params) throws Exception {
		CoviList webpartList  = new CoviList();
		CoviList list = coviMapperOne.list("user.community.getWebpartList", params);
		
		if(!list.isEmpty()){
			webpartList = CoviSelectSet.coviSelectJSON(list, "WebpartID,LayoutDivNumber,WebpartOrder,DisplayName,HtmlFilePath,JsFilePath,JsModuleName,Preview,Resource,ScriptMethod,MinHeight,DataJSON,ExtentionJSON,WebpartType");
		}
		
		return webpartList;
	}
	
	public String getJavascriptString(CoviList webPartList) throws Exception {
		StringBuilder builder = new StringBuilder();
		CoviList jsFiles = new CoviList();
		
		for(int i = 0 ; i < webPartList.size(); i++){
			String jsFilePath = webPartList.getJSONObject(i).getString("JsFilePath");
			
			if(jsFilePath==null || jsFilePath.equals("") || jsFiles.contains(jsFilePath)){
				continue;
			}
			
			String sCurrentJS = templateFileCacheSvc.readAllText(SessionHelper.getSession("lang"),jsPath+jsFilePath, "UTF8");
			builder.append(sCurrentJS+System.getProperty("line.separator"));
			
			jsFiles.add(jsFilePath);
		}
		
		return builder.toString();
	}
	
	public String getLayoutTemplate(CoviList webPartList, CoviMap params) throws Exception {
		Pattern p = null;
		Matcher m = null;
		
		String portalTag = Objects.toString(coviMapperOne.selectOne("user.community.selectPortalTag",params), "");
		
		String layoutHTML = new String(Base64.decodeBase64(portalTag), StandardCharsets.UTF_8);
		StringBuilder builder = new StringBuilder(layoutHTML);

		p = Pattern.compile("\\{\\{\\s*doc.layout.div(\\d+)\\s*\\}\\}");
		m = p.matcher(builder.toString());
		StringBuffer layoutResult = new StringBuffer(builder.length());
		while(m.find()){ 
			StringBuilder divHtml = new StringBuilder("");
			for(int i = 0;i<webPartList.size();i++){
				CoviMap webpart = webPartList.getJSONObject(i);
				
				if(webpart.getString("LayoutDivNumber").equals(m.group(1))){
					String webpartID = webpart.getString("WebpartID");
					String preview = new String(Base64.decodeBase64(webpart.getString("Preview")), StandardCharsets.UTF_8);
					int minHeight = webpart.getInt("MinHeight");
					
					if(webpart.getString("WebpartOrder").indexOf('-')>-1){ //Server-Rendering
						divHtml.append(String.format("<div id=\"WP%s\" style=\"min-height:%dpx;\">%s</div>",webpartID, minHeight, preview));
					}else{  //Client-Rendering
						divHtml.append(String.format("<div id=\"WP%s\" style=\"min-height:%dpx;\" ><center>%s</center></div>", webpartID, minHeight, preview));
					}
					
				}
				
			}
			m.appendReplacement(layoutResult,divHtml.toString());
		}
		m.appendTail(layoutResult);
		
		return layoutResult.toString();
	}
	
	
	public Object getWebpartData(final CoviList webPartArray) throws Exception {
		CoviMap sessionObj = SessionHelper.getSession();
		// aclArray = CoviList.fromObject(RedisDataUtil.getACL(sessionObj.getString("USERID"), sessionObj.getString("DN_ID"))); 
		CoviList retWebPartArr = new CoviList();
		Set<Future<Object>> set = new HashSet<Future<Object>>();
		
		for (final Object webPart: webPartArray) {
			 Callable<Object> task = new Callable<Object>(){
			 	@Override
				public Object call() throws Exception {
					CoviMap callRet = (CoviMap) webPart;
					String viewHtml = "";
					
					if(callRet.has("HtmlFilePath") && (!callRet.getString("HtmlFilePath").equals(""))){
						viewHtml = new String(Base64.encodeBase64(
								templateFileCacheSvc.readAllText(sessionObj.getString("lang"), htmlPath + callRet.getString("HtmlFilePath"), "UTF8").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
					}
					
					String initMethod = new String(Base64.encodeBase64(callRet.getString("ScriptMethod").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
					callRet.put("viewHtml", viewHtml);
					callRet.put("initMethod", initMethod);
					
					//Server-SideRendering
					if(callRet.getString("WebpartOrder").indexOf('-')>-1){
						callRet.put("data", getWebpartQueryData(callRet));
					}
					
					return callRet;
				}
			};
			
			Future<Object> future = ThreadExecutorBean.getInstance().submit(task);
			set.add(future);
		}
		
		for (Future<Object> future : set) {
			CoviMap temp = new CoviMap();
			CoviMap futureObj = (CoviMap)future.get();
			temp.put("webPartID", futureObj.getString("WebpartID"));
			temp.put("jsModuleName", futureObj.getString("JsModuleName"));
			temp.put("webpartOrder", futureObj.getString("WebpartOrder"));
			temp.put("extentionJSON", futureObj.getString("ExtentionJSON"));
			temp.put("displayName", futureObj.getString("DisplayName"));
			temp.put("viewHtml", futureObj.getString("viewHtml"));
			temp.put("initMethod", futureObj.getString("initMethod"));
			temp.put("webpartType", futureObj.getString("WebpartType"));
			
			if(futureObj.getString("WebpartOrder").indexOf('-')>-1){
				temp.put("data", futureObj.getString("data"));
			}
			
			retWebPartArr.add(temp);
		}
		
		return retWebPartArr;
	}
	
	public CoviList getWebpartQueryData(CoviMap webpart) throws Exception{
		CoviList returnWebPartData = new CoviList();
		CoviList dataJson = webpart.getJSONArray("DataJSON");
		
		for(int i = 0 ; i < dataJson.size(); i++){
			try{
				CoviMap oWebpart = dataJson.getJSONObject(i);
				
				CoviMap param = new CoviMap();
				
				CoviList xmlParamData = oWebpart.getJSONArray("paramData");
				
				
				for(int j = 0; j<xmlParamData.size();j++){
					CoviMap obj = xmlParamData.getJSONObject(j);
					
					param.put( obj.getString("key"),  getXmlParamData(obj.getString("value"),obj.getString("type")));
				}
				
				CoviList list = coviMapperOne.list(oWebpart.getString("queryID"),param);
				
				returnWebPartData.add(CoviSelectSet.coviSelectJSON(list,oWebpart.getString("resultKey")));
			} catch(NullPointerException e){
				returnWebPartData.add(new CoviList());
			} catch(Exception e){
				returnWebPartData.add(new CoviList());
			}
		}
		
		return returnWebPartData;
	}
	
	//xml Parameter 값을 실제 값으로 변경
	private String getXmlParamData(String value, String type){
		String result = "";
		try{
			if(value!=null){
				switch (type) {
				case "session":
					result = SessionHelper.getSession(value);
					break;
				case "fixed":
					result = value;
					break;
				case "config":
					result = RedisDataUtil.getBaseConfig(value);
					break;
				case "acl":
					/**
					 * ACL 정보를 조회하여 IN 절로 생성
					 * Data Format : ObjectType|aclColName|aclValue 
					 * Ex). FD|View|V
					 */
					String[] aclConf = (value.equals("") ? "FD|View|V|Community".split("[|]") : value.split("[|]") ) ;
					
					String objectType = (aclConf.length >= 1 ? aclConf[0] : "FD");
					String aclColName = (aclConf.length >= 2 ? aclConf[1] : "View");
					String aclValue = (aclConf.length >= 3 ? aclConf[2] : "V");
					String serviceType = (aclConf.length >= 4 ? aclConf[3] : "Community");
					
					Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), objectType, serviceType, aclValue);
					
					String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
					
					if(objectArray.length > 0){
						result = "(" + ACLHelper.join(objectArray, ",") + ")";
					}
					
					break;
				default:
					result = "";
					break;
				}
			}
		} catch(NullPointerException e){
			result ="";
		} catch(Exception e){
			result ="";
		}
		
		return result;
	}
	
	public boolean communityGroupMember(CoviMap params){
		boolean flag = true ;
		
		int cnt = 0;
		
		if(coviMapperOne.getNumber("user.community.insertCommunityGroupMemberCount", params) == 0){
			cnt = coviMapperOne.insert("user.community.insertCommunityGroupMember", params);
			if(cnt > 0){
				flag = true;
			}else{
				flag = false;
				return flag;
			}
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean clearRedisCache(CoviMap params){	
		
		boolean flag = true;
		
		List list = new ArrayList();
		
		String key = "";
		
		list = coviMapperOne.list("user.community.communityUserDomainList", params);
		
		if(list.size() > 0 ){
			CoviMap ChacheParams = new CoviMap();
			
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			for(int j = 0; j < list.size(); j ++){
				ChacheParams = (CoviMap) list.get(j);
				
				key = RedisDataUtil.PRE_H_ACL +  ChacheParams.get("DomainID").toString() + "_" + params.get("UR_Code").toString() + "_*";
				
				if(StringUtils.isNoneBlank(key)){
					instance.removeAll(key);
				}
				
			}
		}
		
		return flag;
	}
	
	public boolean _sendMessaging(CoviMap params){
		CoviList list = new CoviList();
		params.put("lang", SessionHelper.getSession("lang"));
		
		try {
			CoviMap FolderParams = new CoviMap();
			String receivers = "";
			
			if(params.get("Code").equals("CreateRequest") || params.get("Code").equals("CloseRequest")){
				params.put("domainID", params.getString("DN_ID"));
				list = coviMapperOne.list("framework.authority.selectAdminList", params);
			} else if(params.get("Code").equals("JoiningRequest") || params.get("Code").equals("Withdrawal") || params.get("Code").equals("PartiNotice")){
				list = coviMapperOne.list("admin.community.sendMessagingCommunityOperator", params);
			} else if(params.get("Code").equals("Invited")){
				receivers = params.getString("receiverCode");
			} else if (params.get("Code").equals("JoiningApproval") || params.get("Code").equals("JoiningReject")){
				receivers = params.getString("UR_Code");
			}
			
			if(list.size() > 0){
				for(int j = 0; j < list.size(); j ++){
					CoviMap receiverMap = (CoviMap) list.get(j);
					if (j > 0) receivers += ";";
					receivers += receiverMap.getString("UserCode");
				}
			}
			
			if ("".equals(receivers)) return false;		// 수신자가 없으면 로직 종료
			
			FolderParams.put("ReceiversCode", receivers);
			FolderParams.put("ExceptersCode", "");
			
			CoviMap communityInfoParams;
			if(params.get("Code").equals("PartiNotice")){
				communityInfoParams = new CoviMap();
				communityInfoParams.put("CU_ID", params.getString("communityID"));
			} else {
				communityInfoParams = params;
			}
			CoviMap communityInfoMap = coviMapperOne.selectOne("user.community.selectCommunityInfo", communityInfoParams);
			
			String txtCommunityName = communityInfoMap.getString("CommunityName");
			
			FolderParams.put("Code", params.get("Code"));
			FolderParams.put("Category", "Community");
			
			CoviMap dicMap = new CoviMap();
			CoviMap dicParams = new CoviMap(); 
			ArrayList<String> dicList = new ArrayList<String>();

			if(FolderParams.get("Code").equals("CreateRequest")){		// 개설요청
				if(!params.get("SubCode").equals("SCCA")){			// Skip Create Community Approve. 관리자가 커뮤니티 생성할 경우이므로, 사용자 서비스에서는 올수 없는 값으로 판단.
					dicList = new ArrayList<String>(Arrays.asList(
						"lbl_communityName", "msg_communityCreateRequest"
					));
					String msgStr = "§msg_communityCreateRequest§";			// 커뮤니티 개설을 요청합니다
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
					FolderParams.put("URL", "/groupware/layout/community_CommunityOpen.do?CLSYS=conf&CLMD=manage&CLBIZ=Conf&seldomainid="+SessionHelper.getSession("DN_ID")+"&seldomaincode="+SessionHelper.getSession("DN_Code"));
					FolderParams.put("Title", ""+ txtCommunityName);
					FolderParams.put("Message", msgStr);
					FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
				} else {
					return false;
				}
			}else if(FolderParams.get("Code").equals("CuMemberContact")){
				FolderParams.put("Title", "커뮤니티 : "+txtCommunityName+" 커뮤니티 알림");
				FolderParams.put("Message", txtCommunityName+" 커뮤니티 알림");
				FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}else if(FolderParams.get("Code").equals("PartiNotice")){		// 제휴알림
				String stateName =  coviMapperOne.getString("user.community.selectAlianceTypeName", params);
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "CuPartiStatus_CuPartiStatus", "msg_communityPartiNotice", "lbl_Contents"
				));
				String msgStr = "§msg_communityPartiNotice§";			// 제휴 커뮤니티에서 발신된 알림입니다
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§CuPartiStatus_CuPartiStatus§ : " + stateName;
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_Contents§ :";
				msgStr += "&lt;br&gt;" + params.getString("RequestMessage");
				FolderParams.put("Title", "["+ stateName +"] " + txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "/groupware/layout/community_CommunityAllianceManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+params.getString("CU_ID"));
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}
			else if(FolderParams.get("Code").equals("JoiningRequest")){		// 가입요청
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_Requester", "msg_communityJoiningRequest"
				));
				String msgStr = "§msg_communityJoiningRequest§";			// 커뮤니티 가입을 요청합니다
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_Requester§ : " + SessionHelper.getSession("UR_Name");
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "/groupware/layout/community_CommunityMemberManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+params.getString("CU_ID"));
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}else if(FolderParams.get("Code").equals("JoiningApproval")){	// 가입승인
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityJoiningApproval"
				));
				String msgStr = "§msg_communityJoiningApproval§";			// 커뮤니티 가입요청이 승인되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "/groupware/layout/userCommunity/communityMain.do?communityId="+params.getString("CU_ID")+"&C="+params.getString("CU_ID"));
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}else if(FolderParams.get("Code").equals("JoiningReject")){		// 가입거절
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityJoiningReject"
				));
				String msgStr = "§msg_communityJoiningReject§";			// 커뮤니티 가입요청이 거부되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "");
				FolderParams.put("MobileURL", "");
			}else if(FolderParams.get("Code").equals("Invited")){			// 초대
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "lbl_InvitationMessage", "msg_CommunityInvited"
				));
				String msgStr = "§msg_CommunityInvited§";				// 커뮤니티에 초대되었습니다.
				msgStr += "&lt;br&gt;" + "§lbl_communityName§ : " + txtCommunityName;
				msgStr += "&lt;br&gt;" + "§lbl_InvitationMessage§ :";
				msgStr += "&lt;br&gt;" + params.getString("bodyText");
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "/groupware/layout/userCommunity/communityMain.do?communityId="+params.getString("CU_ID")+"&C="+params.getString("CU_ID"));
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}else if(FolderParams.get("Code").equals("CloseRequest")){		// 폐쇄신청
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityCloseRequest"
				));
				String msgStr = "§msg_communityCloseRequest§";			// 커뮤니티 폐쇄를 신청합니다
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "/groupware/layout/community_CommunityClose.do?CLSYS=conf&CLMD=manage&CLBIZ=Conf&seldomainid="+SessionHelper.getSession("DN_ID")+"&seldomaincode="+SessionHelper.getSession("DN_Code"));
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}else if(FolderParams.get("Code").equals("Withdrawal")) {
				FolderParams.put("Title", txtCommunityName);
				if (params.get("isForce").toString().equalsIgnoreCase("true")) {	//강제 탈퇴
					dicList = new ArrayList<String>(Arrays.asList(
						"lbl_communityName", "msg_communityWithdrawalForce", "lbl_Withdrawal_Reason"
					));
					String msgStr = "§msg_communityWithdrawalForce§";			// 커뮤니티에서 강제탈퇴 되었습니다
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_Withdrawal_Reason§ :";
					msgStr += "&lt;br&gt;&nbsp;&nbsp;" + params.getString("LeaveMessage");
					FolderParams.put("Title", txtCommunityName);
					FolderParams.put("Message", msgStr);
					FolderParams.put("URL", "");
					FolderParams.put("ReceiversCode", params.getString("UR_Code"));
				} else {
					dicList = new ArrayList<String>(Arrays.asList(
						"lbl_communityName", "msg_communityWithdrawal", "lbl_Activity_User"
					));
					String msgStr = "§msg_communityWithdrawal§";			// 커뮤니티에서 회원이 탈퇴했습니다.
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_Activity_User§ : " + SessionHelper.getSession("USERNAME");
					FolderParams.put("Title", txtCommunityName);
					FolderParams.put("Message", msgStr);
					FolderParams.put("URL", "/groupware/layout/community_CommunityMemberManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+params.getString("CU_ID"));
				}
				
				FolderParams.put("MobileURL", "");
			}
			
			dicParams.put("dicArr", dicList.toArray());    
			
			dicMap = messageSvc.getDicInfo(dicParams); 
			if (dicMap.size() > 0) {
				FolderParams.put("ReservedStr4", CoviMap.toJSONString(dicMap));
			}
			
			notifyCommunityAlarm(FolderParams);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} 
		return true;
	}
	
	public List sendMessagingList(CoviMap params)throws Exception{
		
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.sendMessagingList", params);
		
		return selList;
	}
	
	public List sendMessagingListAdmin(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.sendMessagingListAdmin", params);
		
		return selList;	
	}
	
	public List sendMessagingCommunityOperator(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		params.put("lang", SessionHelper.getSession("lang"));
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.community.sendMessagingCommunityOperator", params);
		
		return selList;	
	}
	
	public boolean sendMessaging(CoviMap params){
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("user.community.sendMessaging", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityApprovCheck(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityApprovCheck", params);
	}
	
	public int selectCommunityHomepageCheck(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityHomepageCheck", params);
	}
	
	public int selectCommunityDomainCheck(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCommunityDomainCheck", params);
	}
	
	//수신자 정보 DB에서 검색하여 메일주소 설정 --> 통합알림으로 변경
	public int communitySendSimpleMail(CoviMap params) throws Exception{
		this._sendMessaging(params);
		
		return 0;
	}
	
	public int sendMessagingSettingCnt(CoviMap params) throws Exception{
		return (int) coviMapperOne.getNumber("user.community.sendMessagingSettingCnt", params);
	}
	
	public void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
		CoviMap notiParam = new CoviMap(pNotifyParam);
		notiParam.put("ObjectType", "CU");
		notiParam.put("ServiceType", "Community");
		notiParam.put("MsgType", pNotifyParam.get("Code"));						//커뮤니티 알림 코드
		notiParam.put("PopupURL", pNotifyParam.getString("URL"));
		notiParam.put("GotoURL", pNotifyParam.getString("URL"));
//		notiParam.put("MobileURL", pNotifyParam.getString("MobileURL"));
		notiParam.put("MessagingSubject", pNotifyParam.getString("Title"));
		notiParam.put("MessageContext", pNotifyParam.get("Message"));
		notiParam.put("ReceiverText", pNotifyParam.getString("Message"));
		notiParam.put("SenderCode", SessionHelper.getSession("USERID"));		//송신자
		notiParam.put("RegistererCode", SessionHelper.getSession("USERID"));
//		notiParam.put("ReceiversCode", pNotifyParam.getString("ReceiversCode"));		//조회된 수신자 코드
		notiParam.put("DomainID", SessionHelper.getSession("DN_ID"));
		notiParam.put("ReservedStr4", pNotifyParam.getString("ReservedStr4"));
		MessageHelper.getInstance().createNotificationParam(notiParam);
		messageSvc.insertMessagingData(notiParam);
	}
	
	public String selectTargetCallMemberSendMessage(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("user.community.selectTargetCallMemberSendMessage", params);
		
		return value;
	}
	
	public int selectCurrentFileSizeByCommunity(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("user.community.selectCurrentFileSizeByCommunity", params);
	}

	@Override
	public CoviMap selectCommunityDataWebpart(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.community.selectCommunityDataWebpart", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CU_ID,FilePath,CommunityName,MemberCNT,CategoryName"));
		
		return resultList;
	}
	
}
