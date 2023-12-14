package egovframework.covision.groupware.community.admin.service.impl;

import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.community.admin.service.CommunitySvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("CommunitySvc")
public class CommunitySvcImpl extends EgovAbstractServiceImpl implements CommunitySvc{
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	MessageSvc boardMessageSvc;
	
	@Autowired
	private MessageService messageSvc;
	
	private Logger LOGGER = LogManager.getLogger(CommunitySvcImpl.class);
	
	public CoviMap selectCommunityDomain(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityDomain", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "DomainID,DomainCode,DisplayName"));
		
		return returnObj;
	}
	
	public CoviMap selectCommunityTreeData(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityTreeData", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "FolderID,DN_ID,itemType,FolderType,FolderAlias,DisplayName,FolderName,MemberOf,FolderPath,SortKey,SortPath,IsUse,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Reserved2,hasChild,type"));
		
		return returnObj;
	}
	
	public int selectCommunityGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityGridListCount", params);
	}
	
	public CoviMap selectCommunityGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CategoryID,DN_ID,MN_ID,FolderType,FolderAlias,DisplayName,MemberOf,FolderPath,SortKey,SortPath,IsUse,Description,RegisterCode,RegDisplayName,RegistDate"));
		
		return returnObj;
	}
	
	public int selectCommunitySubGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunitySubGridListCount", params);
	}
	
	public CoviMap selectCommunitySubGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunitySubGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList));
		
		return returnObj;
	}
	
	public boolean updateCategoryUseChange(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCategoryUseChange", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public CoviMap setCurrentLocation(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.setCurrentLocation", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "DisplayName,num"));
		
		return returnObj;
	}
	
	public String selectCategoryID(CoviMap params)throws Exception {
		return coviMapperOne.getString("admin.community.selectCategoryID", params);
	}
	
	public String selectDICCode(CoviMap params)throws Exception {
		return coviMapperOne.getString("admin.community.selectDICCode", params);
	}
	
	public CoviMap selectCommunityBaseCode(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityBaseCode", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		
		return returnObj;
	}
	
	public boolean updateCommunityProperty(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		StringUtil func = new StringUtil();
		String SortPath = "";
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			SortPath = coviMapperOne.selectOne("admin.community.selectCommunitySortPath", params);
			params.put("SortPath", SortPath);
		}
		
		cnt = coviMapperOne.update("admin.community.updateCommunityProperty", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public CoviMap selectProperty(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectProperty", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CategoryID,DN_ID,MN_ID,FolderType,FolderAlias,DisplayName,MemberOf,FolderPath,SortKey,SortPath,IsUse,Description,RegisterCode,RegDisplayName,RegistDate,parentDisplayName,MultiDisplayName"));
		return returnObj;
	}
	
	public boolean updateCommunitySubProperty(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		StringUtil func = new StringUtil();
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			String[] arrSubCategoryID =  func.f_NullCheck(params.getString("subCategoryID")).split(",");
			
			for(String categoryID : arrSubCategoryID) {
				CoviMap subCagetoryParam = new CoviMap();
				subCagetoryParam.put("CategoryID", categoryID);
				subCagetoryParam.put("IsUse", params.getString("IsUse"));
				
				String sortPath = coviMapperOne.selectOne("admin.community.selectCommunitySortPath",subCagetoryParam);
				subCagetoryParam.put("SortPath", sortPath);
				
				cnt += coviMapperOne.update("admin.community.updateCommunitySubProperty", subCagetoryParam);
			}
		} else {
			cnt = coviMapperOne.update("admin.community.updateCommunitySubProperty", params);
		}
		
		if(cnt >= params.getInt("subCnt")){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean updateCommunityDictionary(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityDictionary", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int communityDictionaryCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.communityDictionaryCnt", params);
	}
	
	public boolean createCommunityDictionary(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityDictionary", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public CoviMap selectCommunitySubProperty(CoviMap params)throws Exception{
		return coviMapperOne.select("admin.community.selectCommunitySubProperty", params);
	}
	
	public boolean createCommunityProperty(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityProperty", params);
		//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
		if(cnt > 0 || params.get("CategoryID")!= null){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean deleteCategory(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		// 분류항목 삭체처리 : DeleteDate 에 날짜 기입.
		cnt = coviMapperOne.update("admin.community.deleteCategory", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		// 분류명 안의 커뮤니티들은 사용자에게 보여질 수 없기 때문에 강제폐쇄.
		// 간편관리자와 운영 환경 모두 같은 service로 같은 프로세스 동작한다.
		// 1. 해당 분류에 속해있는 커뮤니티ID를 검색한다.
		CoviList cList = new CoviList();
		CoviMap cMap = new CoviMap();
		cList = coviMapperOne.list("admin.community.selectCommunityInCategory", params);

		params.put("RegStatus", "U");
		params.put("AppStatus", "UF");
		params.put("IsDisplay",'N');
		params.put("Community",'Y');
		params.put("Code","ForcedApproval"); 		// 강제폐쇄.
		params.put("UserCode", SessionHelper.getSession("USERID")); 	// sendMessaging()처리 시 필요한 UserCode 값.
				
		// 2. communityID 당 강제폐쇄 처리. community/closeCommunity.do 와 동일하게 처리.
		for (int i=0; i<cList.size(); i++ ) {
			cMap = (CoviMap) cList.get(i);
			params.put("CU_ID", cMap.get("CU_ID"));
			cnt = coviMapperOne.update("admin.community.updateCommunityStatus", params);
			
			params.put("IsUse",'Y');
			cnt = coviMapperOne.update("admin.community.updateCommunityGroupCode", params);
			
			params.put("IsUse",'N');
			cnt = coviMapperOne.update("admin.community.updateCommunityGroupFD", params);
		
			/*communitySvc.updateCommunityCacheSync(params);*/ // 폐쇄처리 로직에 주석처리 되어 있었음.
			
			//TODO-COMMUNITY
			// CommunityCon.java의 sendMessaging 메서드를 구현.
			List list = new ArrayList();
			params.put("lang",SessionHelper.getSession("lang"));
			list = sendMessagingCommunityOperator(params); 	// params의 "Code"값이 "ForcedApproval".
			if (list.size() > 0) {
				CoviMap FolderParams = new CoviMap();
				for (int j=0; j<list.size(); j++) {
					FolderParams = (CoviMap) list.get(j);
					FolderParams.put("Code", params.get("Code"));
					FolderParams.put("Category", "Community");
					FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티가 관리자에 의해 강제로 폐쇄되었습니다.");
					FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티가 관리자에 의해 강제로 폐쇄되었습니다.");
					FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
					FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					
					notifyCommunityAlarm(FolderParams);
				}
			}
		}

		// flag값은 분류항목에 대한 것만 표시.
		return flag;
	}
	
	public boolean moveCommunityCategory(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.moveCommunityCategory", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean updateCommunitySortProperty(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		String SortPath = "";
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			SortPath = coviMapperOne.selectOne("admin.community.selectCommunitySortPath",params);
			params.put("SortPath", SortPath);
		}
		
		cnt = coviMapperOne.update("admin.community.updateCommunitySortProperty", params);
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
		
		cnt = coviMapperOne.update("admin.community.updateCommunityStatus", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		if (flag) {
			if ("RD".equals(params.getString("AppStatus"))) {
				params.put("Code","CreateRejectl");
				params.put("SubCode","CCAR");
			} else if ("UF".equals(params.getString("AppStatus"))) {
				params.put("Code","ForcedApproval");
			}
			this._sendMessaging(params);
		}
		
		return flag;
	}
	
	public int checkCommunityNameCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.checkCommunityNameCount", params);
	}
	
	public int checkCommunityAliasCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.checkCommunityAliasCount", params);
	}
	
	public int communityCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.communityCnt", params);
	}
	
	public boolean updateCommunityNameDictionary(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityNameDictionary", params);
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
		
		cnt = coviMapperOne.insert("admin.community.createCommunityNameDictionary", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean createCommunityInfomation(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityInfomation", params);
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
		
		cnt = coviMapperOne.insert("admin.community.createCommunityDetailInfomation", params);
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
		
		cnt = coviMapperOne.update("admin.community.updateCommunityGroupCode", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean updateCommunityGroupFD(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityGroupFD", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean updateCommunityCacheSync(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityCacheSync", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityHomeCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityHomeCount", params);
	}
	
	public boolean createCommunityHome(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityHome", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityACLCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params);
	}
	
	public CoviMap selectCommunityInfo(CoviMap params)throws Exception{
		return coviMapperOne.select("admin.community.selectCommunityInfo", params);
	}
	
	public boolean updateCommunityACL(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityACL", params);
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
		
		cnt = coviMapperOne.insert("admin.community.createCommunityACL", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityMemberCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityMemberCount", params);
	}
	
	public int selectCommunityGroupCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityGroupCount", params);
	}
	
	public boolean createCommunityMember(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityMember", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean createCommunityGroup(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityGroup", params);
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
		
		cnt = coviMapperOne.update("admin.community.updateCommunityMemberCount", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean createCommunityFolder(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityFolder", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityMenuTopCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityMenuTopCount", params);
	}
	
	public boolean createCommunityMenuTop(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createCommunityMenuTop", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityBoardCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityBoardCount", params);
	}
	
	public boolean createBoardConfig(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createBoardConfig", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean updateBoardConfig(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateBoardConfig", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public boolean createObjectGroup(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.createObjectGroup", params);
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
			params.put("comObjectPath", coviMapperOne.selectOne("admin.community.selectComObjectPath", params));
			params.put("sortPath", coviMapperOne.selectOne("admin.community.selectSortPath", params));
		}
		
		cnt = coviMapperOne.update("admin.community.updateObjectGroup", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public CoviMap selectCommunityInfomation(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityInfomation", params);
		
		CoviMap returnObj = new CoviMap();

		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,CreatorCode,AppStatus,RegRequestDate,FolderPath,SortPath,CategoryName,MembersCount,RegProcessDate,Point,MemberCount,Grade,MsgCount,DisplayName,CuAppDetail,CommunityJoin,CommunityType,JoinOption,CommunityType,RegStatus,AppStatus,LimitFileSize,MultiDisplayName,DisplayName,DefaultBoardType,DefaultMemberLevel,Keyword,Description,Provision,Reserved1,Reserved2,CategoryID,OperatorCode"));
		
		return returnObj;
	}
	
	public boolean editCommunityInfomation(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.editCommunityInfomation", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public int selectCommunityDetailInfomationCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityDetailInfomationCount", params);
	}
	
	public boolean updateCommunityDetailInfomation(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityDetailInfomation", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	@Override
	public boolean insertTodoSendMessage(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.insertTodoSendMessage", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	@Override
	public CoviMap selectCommunityOperatorInfo(CoviMap params)throws Exception{
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(coviMapperOne.list("admin.community.selectCommunityOperatorInfo", params), "OperatorCode,CommunityName,MailAddress"));
		
		return returnObj;
	}
	
	public int selectCommunityOpenGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityOpenGridListCount", params);
	}
	
	public CoviMap selectCommunityOpenGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityOpenGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CreatorDept,DisplayName,CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,DN_NM,SearchTitle,CommunityName,CreatorCode,AppStatus,RegRequestDate,FolderPath,SortPath,CategoryName,MembersCount,RegProcessDate,Point,MemberCount,Grade,MsgCount,CuAppDetail,CommunityJoin,CommunityType,Keyword,Description,Provision"));
		return returnObj;
	}
	
	public int selectCommunityCloseGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityCloseGridListCount", params);
	}
	
	public CoviMap selectCommunityCloseGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityCloseGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CreatorDept,DisplayName,CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,DN_NM,SearchTitle,CommunityName,CreatorCode,AppStatus,RegRequestDate,FolderPath,SortPath,CategoryName,MembersCount,RegProcessDate,Point,MemberCount,Grade,MsgCount,CuAppDetail,CommunityJoin,CommunityType,Keyword,Description,Provision,RegStatus,UnRegRequestDate,UnRegProcessDate"));
		return returnObj;
	}
	
	public boolean staticCommunityUpdate(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		if(params.get("AppStatus").equals("UV") || params.get("AppStatus").equals("RF")){
			params.put("IsUse", "N");
		}else{
			params.put("IsUse", "Y");
		}
		
		coviMapperOne.update("admin.community.staticCommunityGrMemberUpdate", params);
		coviMapperOne.update("admin.community.staticCommunityGrUpdate", params);
		coviMapperOne.delete("admin.community.DelCommunityFavorite", params);
		cnt = coviMapperOne.update("admin.community.staticCommunityUpdate", params);
		
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		if (flag) {
			if ("UV".equals(params.getString("AppStatus"))) {
				params.put("Code","CloseApproval");
			} else if ("UD".equals(params.getString("AppStatus"))) {
				params.put("Code","CloseReject");
			}
			this._sendMessaging(params);
		}
		
		return flag;
	}
	
	public int selectCommunityStaticGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityStaticGridListCount", params);
	}
	
	public CoviMap selectCommunityStaticGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityStaticGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "LimitFileSize,UsedFileSize,MemberCount,MsgCount,ReplyCount,OneMsgCount,VisitCount,ViewCount,Point,Grade,RegProcessDate,CU_ID,number,CommunityName,DisplayName,RegStatus,FileSize"));
		return returnObj;
	}
	
	public int selectCommunityStaticSubGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityStaticSubGridListCount", params);
	}
	
	public CoviMap selectCommunityStaticSubGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityStaticSubGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "YYYYMMDD,CU_ID,MN_ID,MemberCount,MsgCount,ReplyCount,OneMsgCount,VisitCount,ViewCount,Point,Grade,Difference,RegistDate,MeetingUserCount,MeetingPaRate"));
		return returnObj;
	}
	
	public List selectCommunityExcelLogDaily(CoviMap params)throws Exception{
		return coviMapperOne.list("admin.community.selectCommunityExcelLogDaily", params);
	}
	
	public CoviMap selectCommunityExcelInfo(CoviMap params)throws Exception{
		return coviMapperOne.select("admin.community.selectCommunityExcelInfo", params);
	}
	
	public int selectCommunityExcelInfoCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityExcelInfoCount", params);
	}
	
	public CoviMap selectCommunityStaticGridExcelList(CoviMap params)throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityStaticGridList", params);
		
		int cnt = (int) coviMapperOne.getNumber("admin.community.selectCommunityStaticGridListCount", params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(selList, "number,CommunityName,Grade,Point,MemberCount,VisitCount,MsgCount,ViewCount,ReplyCount,FileSize,RegStatus,DisplayName,RegProcessDate"));
		resultList.put("cnt", cnt);
		
		return resultList;
	}
	
	public CoviMap selectCommunityBoardSettingGridList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityBoardSettingGridList", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "num,S_ORDER,DN_NAME,DN_ID,CommunityType,CommunityTypeName,FolderType,FolderTypeName,BoardName,exDisplayName,MemberOf,SortKey,IsUse,Description,P_LEVEL,MenuID"));
		return returnObj;
	}
	
	public int selectCommunityBoardSettingGridListCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityBoardSettingGridListCount", params);
	}
	
	public boolean updateBoardSettingUseChange(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateBoardSettingUseChange", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateBoardSetting(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateBoardSetting", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean createBoardSetting(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.createBoardSetting", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectCommunityFolderType(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectCommunityFolderType", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		
		return returnObj;
	}
	
	public CoviMap communityBoardSettingInfo(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.communityBoardSettingInfo", params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "DN_ID,CommunityType,FolderType,BoardName,exDisplayName,SortKey,IsUse,Description,MenuID,MultiDisplayName"));
		
		return returnObj;
	}
	
	public int selectCommunityFolderCnt(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityFolderCnt", params);
	}
	
	public String selectCommunityScheduleMenu(CoviMap params)throws Exception{
		return coviMapperOne.getString("admin.community.selectCommunityScheduleMenu", params);
	}
	
	public boolean updateCommunityMemberOperatorCode(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public List communityMemberActivity(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.communityMemberActivity", params);
		
		return selList;
	}
	
	public boolean communityMemberActivityPoint(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.communityMemberActivityPoint", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public List communityActivity(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.communityActivity", params);
		
		return selList;
	}
	
	public boolean communityActivityPoint(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.communityActivityPoint", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean communityActivityPointHistory(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.community.communityActivityPointHistory", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateCommunityMember(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.community.updateCommunityMember", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	public String selectCommunityAlias(CoviMap params)throws Exception{
		return coviMapperOne.getString("admin.community.selectCommunityAlias", params);
	}
	
	public boolean restoreCommunity(CoviMap params){
		int cnt = 0;
		boolean flag = false;
		CoviMap subParams = new CoviMap();
		
		StringUtil func = new StringUtil();
		try {
			cnt = coviMapperOne.update("admin.community.updateCommunityStatus", params);
			if(cnt > 0){
				params.put("IsDisplay",'Y');
				params.put("IsUse",'Y');
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.update("admin.community.updateCommunityGroupCode", params);
			if(cnt > 0){
				subParams = coviMapperOne.select("admin.community.selectCommunityInfo", params);
				
				params.put("domainID", subParams.getString("DN_ID"));
				
				if(coviMapperOne.getNumber("admin.community.selectCommunityGroupSubCnt", params) < 1){
					//커뮤니티 하위 그룹 생성
					List gradeCodeList = new ArrayList();
					gradeCodeList = coviMapperOne.list("admin.community.selectCommunityGradeList", subParams);
					
					if (gradeCodeList.size() > 0) {
						CoviMap GradeParams = new CoviMap();
						for (int j = 0; j < gradeCodeList.size(); ++j) {
							GradeParams = (CoviMap)gradeCodeList.get(j);
							subParams.put("GradeName", GradeParams.get("CodeName"));
							subParams.put("GradeCode", GradeParams.get("Code"));
							subParams.put("CU_ID", params.get("CU_ID"));
							//하위그룹 인서트
							coviMapperOne.insert("admin.community.createObjectGroupSub", subParams);
							//하위그룹 인서트 후 GrupPath, SortPath, OUPath 업데이트
							
							CoviMap objectMap = new CoviMap();
							objectMap = coviMapperOne.select("admin.community.selectObjectGroupInfo", subParams);
							
							subParams.put("GroupPath", objectMap.get("GroupPath"));
							subParams.put("SortPath", objectMap.get("SortPath"));
							subParams.put("ApprovalUnitCode", objectMap.get("ApprovalUnitCode"));
							subParams.put("ReceiptUnitCode", objectMap.get("ReceiptUnitCode"));
							
							coviMapperOne.update("admin.community.updateObjectGroupSub", subParams);
						}
					}
					
					subParams.put("UR_Code", subParams.get("OperatorCode"));
					cnt = coviMapperOne.insert("admin.community.insertCommunityGroupMemberMasterGrade", subParams);
					if (cnt > 0) {
						
					} else {
						throw new Exception("");
					}
				}
			}else{
				throw new Exception("");
			}
			
			//커뮤니티 홈 체크
			if(coviMapperOne.getNumber("admin.community.selectCommunityHomeCount", params) > 0){
				cnt = coviMapperOne.insert("admin.community.createCommunityHome", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}
			
			params.put("ObjectType", "CU");
			params.put("SubjectType", "CM");
			
			params.put("SubjectCode", subParams.get("CategoryID").toString());
			
			//커뮤니티 기본 권한 설정
			if(coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params) > 0 ){
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					params.put("userLevel", "3");
					
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "0");
				}
			}else{
				//insert
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "3");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "0");
				}
			}
			
			params.put("CommunityName", subParams.get("CommunityName"));
			params.put("DN_ID", subParams.get("DN_ID"));
			
			String CommunityName = params.get("CommunityName").toString();
			
			params.put("CommunityName",CommunityName);
			params.put("txtCommunityName", CommunityName);
			params.put("DIC_Code", "CU_"+params.get("CU_ID"));
			
			params.put("SubjectCode", subParams.get("DomainCode").toString());
			
			//커뮤니티 그룹 권한 설정
			if(coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params) > 0 ){
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}else{
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}
			
			subParams.put("userID", subParams.get("OperatorCode"));
			
			//커뮤니티 운영자로 등록 
			if(coviMapperOne.getNumber("admin.community.selectCommunityMemberCount", subParams) > 0 ){
				
				cnt = coviMapperOne.update("admin.community.updateCommunityMember", subParams);
				if(cnt > 0){
					cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", subParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}else{
				
				cnt = coviMapperOne.insert("admin.community.createCommunityMember", subParams);
				if(cnt > 0){
					cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", subParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}
			
			/*//Portal 등록
			params.put("PortalTag", RedisDataUtil.getBaseConfig("communityPortalTag"));
			params.put("LayoutSizeTag", RedisDataUtil.getBaseConfig("communityLayoutSizeTag"));
			
			cnt = coviMapperOne.insert("admin.community.createCommunityWebPortal", params);
			if(cnt > 0){
				
			}else{
				return flag;
			}
			
			List portalList = new ArrayList();
			
			//Portal Webpart 조회 /등록
			portalList = coviMapperOne.list("admin.community.communityDefaultPortalList", params);
			
			if(portalList.size() > 0 ){
				CoviMap PortalParams = new CoviMap();
				for(int k = 0; k < portalList.size(); k ++){
					PortalParams = (CoviMap) portalList.get(k);
					PortalParams.put("PortalID", params.get("PortalID"));
					PortalParams.put("CU_ID", params.get("CU_ID"));
					PortalParams.put("userID", params.get("userID"));
					
					cnt = coviMapperOne.insert("admin.community.createCommunityWebPart", PortalParams);
					if(cnt > 0){
						
					}else{
						return flag;
					}
					
					cnt = coviMapperOne.insert("admin.community.createCommunityLayout", PortalParams);
					if(cnt > 0){
						
					}else{
						return flag;
					}
				}
			}*/
			
			flag = true;
			
			if (flag) {
				params.put("Code", "CloseRestoration");
				this._sendMessaging(params);
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
		}
		
		return flag;
	}
	
	public boolean communityNewCreateSite(CoviMap params){
		int cnt = 0;
		boolean flag = false;
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		CoviMap subParams = new CoviMap();
		
		StringUtil func = new StringUtil();
		try {
			
			String maxID = coviMapperOne.selectOne("admin.community.maxID", params); 
			
			params.put("CU_Code", maxID);
			
			cnt = coviMapperOne.insert("admin.community.createCommunityInfomation", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("CU_ID") != null){
				cnt = coviMapperOne.insert("admin.community.createCommunityDetailInfomation", params);
				if(cnt > 0){
					params.put("ObjectID", params.get("CU_ID"));
					params.put("RegStatus", "R");
					params.put("AppStatus", "RV");
				}else{
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				cnt = coviMapperOne.update("admin.community.createCommunityInfomationCode", params);
				if(cnt < 1){
					throw new Exception("");
				}
			}
			
			cnt = coviMapperOne.update("admin.community.updateCommunityStatus", params);
			if(cnt > 0){
				subParams = coviMapperOne.select("admin.community.selectCommunityInfo", params);
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.insert("admin.community.createObjectGroup", subParams);
			if(cnt > 0){
				
				if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
					subParams.put("comObjectPath", coviMapperOne.selectOne("admin.community.selectComObjectPath", subParams));
					subParams.put("sortPath", coviMapperOne.selectOne("admin.community.selectSortPath", subParams));
				}
				
				cnt = coviMapperOne.update("admin.community.updateObjectGroup", subParams);
				if(cnt > 0){
					params.put("IsDisplay",'Y');
					params.put("IsUse",'Y');
				}else{
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.update("admin.community.updateCommunityGroupCode", params);
			if(cnt > 0){
				subParams = coviMapperOne.select("admin.community.selectCommunityInfo", params);
				subParams.put("domainID", subParams.getString("DN_ID"));
				
				//커뮤니티 하위 그룹 생성
				List gradeCodeList = new ArrayList();
				gradeCodeList = coviMapperOne.list("admin.community.selectCommunityGradeList", subParams);
				
				if (gradeCodeList.size() > 0) {
					CoviMap GradeParams = new CoviMap();
					for (int j = 0; j < gradeCodeList.size(); ++j) {
						GradeParams = (CoviMap)gradeCodeList.get(j);
						subParams.put("GradeName", GradeParams.get("CodeName"));
						subParams.put("GradeCode", GradeParams.get("Code"));
						subParams.put("CU_ID", params.get("CU_ID"));
						//하위그룹 인서트
						coviMapperOne.insert("admin.community.createObjectGroupSub", subParams);
						//하위그룹 인서트 후 GrupPath, SortPath, OUPath 업데이트
						
						CoviMap objectMap = new CoviMap();
						objectMap = coviMapperOne.select("admin.community.selectObjectGroupInfo",  subParams);
						
						subParams.put("GroupPath", objectMap.get("GroupPath"));
						subParams.put("SortPath", objectMap.get("SortPath"));
						subParams.put("ApprovalUnitCode", objectMap.get("ApprovalUnitCode"));
						subParams.put("ReceiptUnitCode", objectMap.get("ReceiptUnitCode"));
						
						coviMapperOne.update("admin.community.updateObjectGroupSub", subParams);
					}
				}
			}else{
				throw new Exception("");
			}
			
			//커뮤니티 홈 체크
			if(coviMapperOne.getNumber("admin.community.selectCommunityHomeCount", params) > 0){
				cnt = coviMapperOne.insert("admin.community.createCommunityHome", params);
				if(cnt > 0){
					params.put("ObjectType", "CU");
					params.put("SubjectType", "CM");
					
					params.put("SubjectCode", subParams.get("CategoryID").toString());
				}else{
					throw new Exception("");
				}
			}
			
			//커뮤니티 기본 권한 설정
			if(coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params) > 0 ){
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					params.put("userLevel", "3");
					
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "0");
				}
			}else{
				//insert
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "3");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
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
			
			String MemberOf = "";
			
			cnt = coviMapperOne.insert("admin.community.createCommunityFolder", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("FolderID") != null){
				MemberOf = params.get("FolderID").toString();
				if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR" ,"SC__EVR", "S", "C", "_", "_", "E", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}else{
				throw new Exception("");
			}
			
			params.put("DefaultBoardType", subParams.get("DefaultBoardType"));
			
			list = coviMapperOne.list("admin.community.communityFolderList", params);
			
			String CommunityName = params.get("CommunityName").toString();
			
			if(list.size() > 0 ){
				CoviMap FolderParams = new CoviMap();
				for(int j = 0; j < list.size(); j ++){
					FolderParams = (CoviMap) list.get(j);
					FolderParams.put("CU_ID", params.get("CU_ID"));
					params.put("FolderType", FolderParams.get("FolderType"));
					
					if(FolderParams.get("FolderType").equals("Schedule")){
						params.put("MemberOf",  RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
						params.put("MenuID",  RedisDataUtil.getBaseConfig("ScheduleMenuID"));
						params.put("SortKey", FolderParams.get("SortKey"));
						params.put("SortPath",  coviMapperOne.getString("admin.community.selectCommunityScheduleMenu", params));
						params.put("SecurityLevel",  "90");
						params.put("IsInherited", 'N');
						params.put("Reserved2", RedisDataUtil.getBaseConfig("FolderDefaultColor"));
						params.put("CommunityName", CommunityName);
						cnt = coviMapperOne.insert("admin.community.createCommunityFolder", params);
						//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
						//일정 권한일 경우 공개형일 경우라도 회사 권한을 넣지 않는다.
						if(cnt > 0 || params.get("FolderID") != null ){
							if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "CM" ,"SCDMEVR", "S", "C", "D", "M", "E", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), "C")){
								throw new Exception("");
							}
						}else{
							throw new Exception("");
						}
					}else{
						params.put("MemberOf", MemberOf);
						params.put("SortKey", FolderParams.get("SortKey"));
						params.put("SortPath", "");
						params.put("MenuID",  params.get("CU_ID"));
						params.put("SecurityLevel",  "0");
						params.put("IsInherited", "Y");
						params.put("Reserved2", "");
						params.put("CommunityName",FolderParams.get("FolderName") );
						cnt = coviMapperOne.insert("admin.community.createCommunityFolder", params);
						//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
						if(cnt > 0 || params.get("FolderID") != null){
							if(!ACL(params.get("FolderID").toString(), "FD", subParams.get("CU_Code").toString(), "GR" ,"SC__EVR", "S", "C", "_", "_", "E", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
								throw new Exception("");
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
							
							QuickParams.put("folderID",params.get("FolderID").toString());
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
							QuickParams.put("fileCnt",0);
							QuickParams.put("fileInfos","[]");
							QuickParams.put("userCode",subParams.get("OperatorCode"));
							QuickParams.put("ownerCode",subParams.get("OperatorCode"));
							QuickParams.put("mode","create");
							
							int createFlag = boardMessageSvc.createMessage(QuickParams, mf);
							if(createFlag > 0){
								
							}else{
								boardMessageSvc.deleteMessage(QuickParams);
								throw new Exception("");
							}
						}
					}
					
					//상단 메뉴 등록
					if(coviMapperOne.getNumber("admin.community.selectCommunityMenuTopCount", params) == 0){
						cnt = coviMapperOne.insert("admin.community.createCommunityMenuTop", params);
						if(cnt > 0){
							
						}else{
							throw new Exception("");
						}
					}
				}
			}
			
			params.put("SubjectCode", subParams.get("DomainCode").toString());
			
			//커뮤니티 그룹 권한 설정
			if(coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params) > 0 ){
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}else{
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}
			
			subParams.put("userID", subParams.get("OperatorCode"));
			subParams.put("UR_Code", subParams.get("userID"));
			
			//커뮤니티 운영자로 등록 
			if(coviMapperOne.getNumber("admin.community.selectCommunityMemberCount", subParams) > 0 ){
				cnt = coviMapperOne.update("admin.community.updateCommunityMember", subParams);
				if(cnt > 0){
					cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", subParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}else{
				cnt = coviMapperOne.insert("admin.community.createCommunityMember", subParams);
				if(cnt > 0){
					cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", subParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}
			
			if(coviMapperOne.getNumber("admin.community.selectCommunityGroupCount", params) > 0 ){
				cnt = coviMapperOne.insert("admin.community.createCommunityGroup", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}
			
			if(coviMapperOne.getNumber("admin.community.communityCnt", params) > 0){
				cnt = coviMapperOne.update("admin.community.updateCommunityNameDictionary", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}else{
				cnt = coviMapperOne.insert("admin.community.createCommunityNameDictionary", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}
			
			params.put("CommunityName",CommunityName);
			params.put("DIC_Code", "CU_"+params.get("CU_ID"));
			
			//Portal 등록
			params.put("PortalTag", RedisDataUtil.getBaseConfig("communityPortalTag"));
			params.put("LayoutSizeTag", RedisDataUtil.getBaseConfig("communityLayoutSizeTag"));
			
			cnt = coviMapperOne.insert("admin.community.createCommunityWebPortal", params);
			//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
			if(cnt > 0 || params.get("PortalID") != null){
				
			}else{
				throw new Exception("");
			}
			
			List portalList = new ArrayList();
			
			//Portal Webpart 조회 /등록
			portalList = coviMapperOne.list("admin.community.communityDefaultPortalList", params);
					
			if(portalList.size() > 0 ){
				for(int k = 0; k < portalList.size(); k ++){
					CoviMap PortalParams = (CoviMap) portalList.get(k);
					PortalParams.setConvertJSONObject(false);
					
					PortalParams.put("PortalID", params.get("PortalID"));
					PortalParams.put("CU_ID", params.get("CU_ID"));
					PortalParams.put("userID", params.get("userID"));
					PortalParams.put("DataJSON", PortalParams.getString("DataJSON"));
					
					cnt = coviMapperOne.insert("admin.community.createCommunityWebPart", PortalParams);
					//2019.05 mssql 추가 시 cnt -1로 넘어와서 처리함
					if(cnt > 0 || PortalParams.get("WebpartID") != null){
						
					}else{
						throw new Exception("");
					}
					
					cnt = coviMapperOne.insert("admin.community.createCommunityLayout", PortalParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}
			}
			
			/*
			if(coviMapperOne.getNumber("admin.community.insertCommunityGroupMemberCount", subParams) == 0){
				cnt = coviMapperOne.insert("admin.community.insertCommunityGroupMember", subParams);
				if(cnt > 0){
					flag = true;
				}else{
					flag = false;
					throw new Exception("");
				}
			}else{
				flag = true;
			}
			*/
			
			cnt = coviMapperOne.insert("admin.community.insertCommunityGroupMemberMasterGrade", subParams);
			if (cnt > 0) {
				
			} else {
				throw new Exception("");
			}
			
			params.put("Code","CreateRequest");
			params.put("SubCode","SCCA"); //SKIP Create Community Approve 
			
			//TODO-COMMUNITY
			if(!_sendMessaging(params)){
				
			}
			
			/*params.put("UR_Code", subParams.get("OperatorCode")); 
			
			if(clearRedisCache(params)){
				
			}else{
				return flag;
			}
			*/
			
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
	
	public boolean openCommunity(CoviMap params) {
		int cnt = 0;
		boolean flag = false;
		CoviMap subParams = new CoviMap();
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		StringUtil func = new StringUtil();
		try {
			cnt = coviMapperOne.update("admin.community.updateCommunityStatus", params);
			if(cnt > 0){
				params.put("IsDisplay",'Y');
				params.put("IsUse",'Y');
			}else{
				throw new Exception("");
			}
			
			cnt = coviMapperOne.update("admin.community.updateCommunityGroupCode", params);
			if(cnt > 0){
				subParams = coviMapperOne.select("admin.community.selectCommunityInfo", params);
				subParams.put("domainID",  subParams.getString("DN_ID"));
				
				//커뮤니티 하위 그룹 생성
				List gradeCodeList = new ArrayList();
				gradeCodeList = coviMapperOne.list("admin.community.selectCommunityGradeList", subParams);
				
				if (gradeCodeList.size() > 0) {
					CoviMap GradeParams = new CoviMap();
					for (int j = 0; j < gradeCodeList.size(); ++j) {
						GradeParams = (CoviMap)gradeCodeList.get(j);
						subParams.put("GradeName", GradeParams.get("CodeName"));
						subParams.put("GradeCode", GradeParams.get("Code"));
						subParams.put("CU_ID", params.get("CU_ID"));
						//하위그룹 인서트
						coviMapperOne.insert("admin.community.createObjectGroupSub", subParams);
						//하위그룹 인서트 후 GrupPath, SortPath, OUPath 업데이트
						
						CoviMap objectMap = new CoviMap();
						objectMap = coviMapperOne.select("admin.community.selectObjectGroupInfo",  subParams);
						
						subParams.put("GroupPath", objectMap.get("GroupPath"));
						subParams.put("SortPath", objectMap.get("SortPath"));
						subParams.put("ApprovalUnitCode", objectMap.get("ApprovalUnitCode"));
						subParams.put("ReceiptUnitCode", objectMap.get("ReceiptUnitCode"));
						
						coviMapperOne.update("admin.community.updateObjectGroupSub", subParams);
					}
				}
				
			}else{
				throw new Exception("");
			}
			
			//커뮤니티 홈 체크
			if(coviMapperOne.getNumber("admin.community.selectCommunityHomeCount", params) > 0){
				cnt = coviMapperOne.insert("admin.community.createCommunityHome", params);
				if(cnt > 0){
					subParams = coviMapperOne.select("admin.community.selectCommunityInfo", params);
				}else{
					throw new Exception("");
				}
			}
			
			params.put("ObjectType", "CU");
			params.put("SubjectType", "CM");
			
			params.put("SubjectCode", subParams.get("CategoryID").toString());
			
			//커뮤니티 기본 권한 설정
			if(coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params) > 0 ){
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					params.put("userLevel", "3");
					
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "0");
				}
			}else{
				//insert
				if(func.f_NullCheck(subParams.get("CommunityType")).equals("P")){
					//공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
						throw new Exception("");
					}
					
					params.put("userLevel", "3");
				}else{
					//비공개
					if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
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
			
			String MemberOf = "";
			
			String CommunityName = params.get("CommunityName").toString();
			
			params.put("CommunityName",CommunityName);
			params.put("txtCommunityName", CommunityName);
			params.put("DIC_Code", "CU_"+params.get("CU_ID"));
			
			params.put("SubjectCode", subParams.get("DomainCode").toString());
			
			//커뮤니티 그룹 권한 설정
			if(coviMapperOne.getNumber("admin.community.selectCommunityACLCount", params) > 0 ){
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "U", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}else{
				if(!ACL(params.get("ObjectID").toString(), "CU", subParams.get("DomainCode").toString(), "CM" ,"S____VR", "S", "_", "_", "_", "_", "V", "R", "C", subParams.get("OperatorCode").toString(), subParams.getString("DN_ID"), subParams.getString("CommunityType"))){
					throw new Exception("");
				}
			}
			
			subParams.put("userID", subParams.get("OperatorCode"));
			subParams.put("UR_Code", subParams.get("userID"));
			
			//커뮤니티 운영자로 등록 
			if(coviMapperOne.getNumber("admin.community.selectCommunityMemberCount", subParams) > 0 ){
				cnt = coviMapperOne.update("admin.community.updateCommunityMember", subParams);
				if(cnt > 0){
					cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", subParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}else{
				cnt = coviMapperOne.insert("admin.community.createCommunityMember", subParams);
				if(cnt > 0){
					cnt = coviMapperOne.update("admin.community.updateCommunityMemberOperatorCode", subParams);
					if(cnt > 0){
						
					}else{
						throw new Exception("");
					}
				}else{
					throw new Exception("");
				}
			}
			
			if(coviMapperOne.getNumber("admin.community.selectCommunityGroupCount", params) > 0 ){
				cnt = coviMapperOne.insert("admin.community.createCommunityGroup", params);
				if(cnt > 0){
					
				}else{
					throw new Exception("");
				}
			}
			
			/*
			if(coviMapperOne.getNumber("admin.community.insertCommunityGroupMemberCount", subParams) == 0){
				cnt = coviMapperOne.insert("admin.community.insertCommunityGroupMember", subParams);
				if(cnt > 0){
					flag = true;
					
					coviMapperOne.insert("admin.community.insertCommunityGroupMemberMasterGrade", subParams);
				}else{
					throw new Exception("");
				}
			}else{
				flag = true;
			}
			*/
			
			cnt = coviMapperOne.insert("admin.community.insertCommunityGroupMemberMasterGrade", subParams);
			if (cnt > 0) {
				
			} else {
				throw new Exception("");
			}
			
			/*//Portal 등록
			params.put("PortalTag", RedisDataUtil.getBaseConfig("communityPortalTag"));
			params.put("LayoutSizeTag", RedisDataUtil.getBaseConfig("communityLayoutSizeTag"));
			
			cnt = coviMapperOne.insert("admin.community.createCommunityWebPortal", params);
			if(cnt > 0){
				
			}else{
				return flag;
			}
			
			List portalList = new ArrayList();
			
			//Portal Webpart 조회 /등록
			portalList = coviMapperOne.list("admin.community.communityDefaultPortalList", params);
			
			if(portalList.size() > 0 ){
				CoviMap PortalParams = new CoviMap();
				for(int k = 0; k < portalList.size(); k ++){
					PortalParams = (CoviMap) portalList.get(k);
					PortalParams.put("PortalID", params.get("PortalID"));
					PortalParams.put("CU_ID", params.get("CU_ID"));
					PortalParams.put("userID", params.get("userID"));
					
					cnt = coviMapperOne.insert("admin.community.createCommunityWebPart", PortalParams);
					if(cnt > 0){
						
					}else{
						return flag;
					}
					
					cnt = coviMapperOne.insert("admin.community.createCommunityLayout", PortalParams);
					if(cnt > 0){
						
					}else{
						return flag;
					}
				}
			}*/
			
			flag = true;
			
			if (flag) {
				params.put("Code","CreateApproval");
				params.put("SubCode","CCAC");
				this._sendMessaging(params);
			}
			
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
				count = coviMapperOne.update("admin.community.updateCommunityACL", aclParams);
				if(count > 0){
					return true;
				}else{
					return false;
				}
			}else if(func.f_NullCheck(Type).equals("C")){
				count = coviMapperOne.insert("admin.community.createCommunityACL", aclParams);
				
				if (aclParams.get("ObjectType").toString().equals("FD")) {
					CoviMap gradeParams = new CoviMap();
					CoviMap gradeMap = new CoviMap();
					
					gradeParams.put("lang", SessionHelper.getSession("lang"));
					gradeParams.put("domainID", dnID);
					
					List gradeList = new ArrayList();
					gradeList = coviMapperOne.list("admin.community.selectCommunityGradeList", gradeParams);
					
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
	
	
	public int selectCommunityRootDuplyCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunityRootDuplyCount", params);
	}
	
	public int selectCommunitySortDuplyCount(CoviMap params)throws Exception{
		return (int) coviMapperOne.getNumber("admin.community.selectCommunitySortDuplyCount", params);
	}
	
	public boolean communityMemberActivityPointHistory(CoviMap params) throws Exception {
		int resultCnt = 0; 
		
		resultCnt = coviMapperOne.update("admin.community.updateCommunityMemberActivityPointHistory", params);
		
		if(resultCnt == 0){
			resultCnt = coviMapperOne.insert("admin.community.communityMemberActivityPointHistory", params);
		}
				
		return resultCnt > 0;
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
	
	public List sendMessagingList(CoviMap params)throws Exception{
		
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.sendMessagingList", params);
		
		return selList;
	}
	
	public List sendMessagingCommunityOperator(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.sendMessagingCommunityOperator", params);
		
		return selList;
	}

	private boolean _sendMessaging(CoviMap params){
		String[] availableMessageType = {"CreateRequest","CreateApproval","CreateRejectl","ForcedApproval","CloseApproval","CloseReject","CloseRestoration"};
		List<String> availableMessageTypeList = new ArrayList<String>(Arrays.asList(availableMessageType));
		
		if (!availableMessageTypeList.contains(params.getString("Code"))) {
			return false;
		}
		
		try {
			CoviList list = new CoviList();
			list = coviMapperOne.list("admin.community.sendMessagingCommunityOperator", params);
			
			CoviMap FolderParams = new CoviMap();
			String receivers = "";
			if(list.size() > 0){
				for(int j = 0; j < list.size(); j ++){
					CoviMap receiverMap = (CoviMap) list.get(j);
					if (j > 0) receivers += ";";
					receivers += receiverMap.getString("UserCode");
				}
			}
			FolderParams.put("ReceiversCode", receivers);
			FolderParams.put("ExceptersCode", "");
			FolderParams.put("Code", params.get("Code"));
			FolderParams.put("Category", "Community");
			
			CoviMap dicMap = new CoviMap();
			CoviMap dicParams = new CoviMap(); 
			ArrayList<String> dicList = new ArrayList<String>();
			
			CoviMap communityInfoMap = coviMapperOne.selectOne("user.community.selectCommunityInfo", params);
			String txtCommunityName = communityInfoMap.getString("CommunityName");
			
			if(FolderParams.get("Code").equals("CreateRequest")){			// 개설 요청. 관리자가 개설하는 경우
				if(params.get("SubCode").equals("SCCA")){			// Skip Create Community Approve. 관리자가 커뮤니티 생성할 경우만 처리
					dicList = new ArrayList<String>(Arrays.asList(
						"lbl_communityName", "msg_communitySCCA", "lbl_communitySCCA"
					));
					String msgStr = "§msg_communitySCCA§";			// 관리자에 의해 커뮤니티가 개설되었습니다.
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
					FolderParams.put("Title", "[§lbl_communitySCCA§]" + txtCommunityName);
					FolderParams.put("Message", msgStr);
					FolderParams.put("URL", "/groupware/layout/userCommunity/communityMain.do?communityId="+params.getString("CU_ID")+"&C="+params.getString("CU_ID"));
					FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
				} else {
					return false;
				}
			}else if(FolderParams.get("Code").equals("CreateApproval")){	// 개설 승인
				if(params.get("SubCode").equals("CCAR")){					// 개설 거부
					dicList = new ArrayList<String>(Arrays.asList(
						"lbl_communityName", "msg_communityCreateRejectl", "TodoMsgType_CreateRejectl"
					));
					String msgStr = "§msg_communityCreateRejectl§";			// 커뮤니티 개설신청이 거부되었습니다.
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
					FolderParams.put("Title", "[§TodoMsgType_CreateRejectl§]"+ txtCommunityName);
					FolderParams.put("Message", msgStr);
					FolderParams.put("URL", "");
					FolderParams.put("MobileURL", "");
				}else{
					dicList = new ArrayList<String>(Arrays.asList(
						"lbl_communityName", "msg_communityCreateApproval"
					));
					String msgStr = "§msg_communityCreateApproval§";			// 커뮤니티 개설신청이 승인되었습니다.
					msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
					FolderParams.put("Title", txtCommunityName);
					FolderParams.put("Message", msgStr);
					FolderParams.put("URL", "/groupware/layout/userCommunity/communityMain.do?communityId="+params.getString("CU_ID")+"&C="+params.getString("CU_ID"));
					FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
				}
			}else if(FolderParams.get("Code").equals("CreateRejectl")){		// 개설 거부
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityCreateRejectl"
				));
				String msgStr = "§msg_communityCreateRejectl§";			// 커뮤니티 개설신청이 거부되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "");
				FolderParams.put("MobileURL", "");
			}else if(FolderParams.get("Code").equals("CloseApproval")){		// 폐쇠 승인
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityCloseApproval"
				));
				String msgStr = "§msg_communityCloseApproval§";			// 커뮤니티 폐쇄신청이 승인되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "");
				FolderParams.put("MobileURL", "");
			}else if(FolderParams.get("Code").equals("CloseReject")){		// 폐쇠 거부
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityCloseReject"
				));
				String msgStr = "§msg_communityCloseReject§";			// 커뮤니티 폐쇄신청이 거부되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "");
				FolderParams.put("MobileURL", "");
			}else if(FolderParams.get("Code").equals("CloseRestoration")){		// 복원 알림
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityCloseRestoration"
				));
				String msgStr = "§msg_communityCloseRestoration§";			// 커뮤니티가 관리자에 의해 폐쇄 상태에서 복원되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "/groupware/layout/userCommunity/communityMain.do?communityId="+params.getString("CU_ID")+"&C="+params.getString("CU_ID"));
				FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
			}else if(FolderParams.get("Code").equals("ForcedApproval")){		// 강제 폐쇠
				dicList = new ArrayList<String>(Arrays.asList(
					"lbl_communityName", "msg_communityForcedApproval"
				));
				String msgStr = "§msg_communityForcedApproval§";			// 커뮤니티가 관리자에 의해 강제로 폐쇄되었습니다.
				msgStr += "&lt;br&gt;" + "&nbsp;&nbsp;§lbl_communityName§ : " + txtCommunityName;
				FolderParams.put("Title", txtCommunityName);
				FolderParams.put("Message", msgStr);
				FolderParams.put("URL", "");
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
	
	public List selectUserAllPwChange(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.community.selectUserAllPwChange", params);
		
		return selList;
	}
	
	public boolean updatePwChange(CoviMap params){
		int cnt = 0;
		boolean flag = false;
		
		String bReturn = "E0";
		boolean isSync = false;
		String apiURL = null;
		String sMode = "?job=modifyPass";
		String sDomain = null;
		StringUtil func = new StringUtil();
		
		String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")); 
		
		try {
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL","1") + sMode;
			
			sDomain = params.get("dn").toString();
			
			String sLogonID = URLEncoder.encode(params.get("UserCode").toString(),"UTF-8");
			
			AES aes = new AES(key, "N");
			
			String sLogonPW = aes.encrypt(params.get("Mobile").toString());
			
		/*	apiURL = apiURL + "&id="+sLogonID+"@"+sDomain+"&pw="+sLogonPW;*/
			
			apiURL = apiURL + "&id="+sLogonID+"&domain="+sDomain+"&pw="+sLogonPW;
			
			CoviMap jObj = getJson(apiURL);
			
			if(jObj.get("returnCode").toString().equals("0"))
			{
				bReturn = "0";
			}else{
				bReturn = "E0";
			}
		} catch(NullPointerException ex) {
			LOGGER.error("modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]");
		} catch(Exception ex) {
			LOGGER.error("modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]");
		}
		
		params.put("key", key);
		
		cnt = coviMapperOne.update("admin.community.UserAllPwChange", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	public CoviMap getJson(String encodedUrl) throws Exception {
		CoviMap resultList = new CoviMap();
		HttpURLConnection conn = null;
		HttpURLConnectUtil url= new HttpURLConnectUtil();
		
		try {
			resultList = url.httpConnect(encodedUrl,"POST",10000,10000,"xform","Y");
		} catch(NullPointerException ex) {
			throw ex;
		} catch(Exception ex) {
			throw ex;
		} finally {
			url.httpDisConnect();
		}
		
		return resultList;
	}
	
	public String getCommunityName(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("admin.community.getCommunityName", params);
		
		return value;
	}
	
	public void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
		CoviMap notiParam = new CoviMap(pNotifyParam);
		notiParam.put("ObjectType", "CU");
		notiParam.put("ServiceType", "Community");
		notiParam.put("MsgType", pNotifyParam.get("Code")); //커뮤니티 알림 코드
		notiParam.put("PopupURL", pNotifyParam.getString("URL"));
		notiParam.put("GotoURL", pNotifyParam.getString("URL"));
		notiParam.put("MessagingSubject", pNotifyParam.getString("Title"));
		notiParam.put("MessageContext", pNotifyParam.get("Message"));
		notiParam.put("ReceiverText", pNotifyParam.getString("Message"));
		notiParam.put("SenderCode", SessionHelper.getSession("USERID")); //송신자 (세션 값 참조)
		notiParam.put("RegistererCode", SessionHelper.getSession("USERID"));
		notiParam.put("DomainID", SessionHelper.getSession("DN_ID"));
		notiParam.put("ReservedStr4", pNotifyParam.getString("ReservedStr4"));
		MessageHelper.getInstance().createNotificationParam(notiParam);
		messageSvc.insertMessagingData(notiParam);
	}

	@Override
	public CoviMap selectBoardSettingSortKey(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("target", coviMapperOne.select("admin.community.selectBoardSettingSortKey", params));
		return result;
	}

	@Override
	public int updateBoardSettingSortKey(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.community.updateBoardSettingSortKey", params);
	}
	
	@Override
	public void updateProperty(CoviMap params) throws Exception {
		StringUtil func = new StringUtil();
		
		//isSaaS가 아닌 경우 하나 이상의 최상위 분류를 가질 수 없도록 처리
		if("N".equals(params.getString("isSaaS")) && "Root".equals(params.getString("FolderType"))){
			if(selectCommunityRootDuplyCount(params) > 0){
				throw new Exception("Root");
			}
		}
		
		if(selectCommunitySortDuplyCount(params) > 0){
			throw new Exception("Sort");
		}
		
		if(func.f_NullCheck(params.getString("mode")).equals("E")){
			if (!"Root".equals(params.getString("FolderType"))) {	// 루트가 아니면 상위가 사용중인지 확인
				CoviMap parentParam = new CoviMap();
				parentParam.put("CategoryID", params.getString("MemberOf"));
				CoviMap parentObj = coviMapperOne.select("admin.community.selectProperty", parentParam); //this.selectProperty(parentParam);
				String parentIsUse = parentObj.getString("IsUse");
				
				if ("N".equals(parentIsUse) && "Y".equals(params.getString("IsUse"))) {
					throw new Exception("NotUpdateCommunityIsUse");
				}
			}
						
			if(!updateCommunityProperty(params)){
				throw new Exception("NotUpdateCommunityProperty");
			}
				
			if(!updateCommunitySortProperty(params)){
				throw new Exception("NotUpdateCommunitySortProperty");
			}
			
			CoviMap subProperties = selectCommunitySubProperty(params);
			
			if(subProperties.getInt("cnt") > 0){
				params.put("subCnt", subProperties.getString("cnt"));
				params.put("subCategoryID", subProperties.getString("subCategoryID"));
				
				if(!updateCommunitySubProperty(params)){
					throw new Exception("NotUpdateCommunitySubProperty");
				}
			}
		}else if(func.f_NullCheck(params.getString("mode")).equals("C")){
			if(!createCommunityProperty(params)){
				throw new Exception("NotCreateCommunityProperty");
			}
		}else{
			throw new Exception("Error");
		}
		
		if(communityDictionaryCnt(params) > 0){
			if(!updateCommunityDictionary(params)){
				throw new Exception("NotUpdateCommunityDictionary");
			}
		}else{
			if(!createCommunityDictionary(params)){
				throw new Exception("NotCreateCommunityDictionary");
			}
		}
	}
}

