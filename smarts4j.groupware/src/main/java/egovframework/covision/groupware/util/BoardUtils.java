package egovframework.covision.groupware.util;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.LogManager;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.auth.BoardAuth;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.event.user.service.impl.EventSvcImpl;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.vo.ACLMapper;


public class BoardUtils extends BoardAuth {

	private static String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	//엑셀 데이터 다국어 처리시 사용 일반 조회로직에는 사용하지 않음
	/**
	 * @param listType
	 * @param clist
	 * @param str
	 * @return JSONArray
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public static CoviList coviSelectJSONForExcel(CoviList clist, String str) throws Exception {
		String lang = SessionHelper.getSession("lang");		//다국어 처리용 세션 lang
		String[] cols = str.split(",");

		CoviList returnArray = new CoviList();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							if (ar.equals("RequestorName")) {
								newObject.put(cols[j], DicHelper.getDicInfo(clist.getMap(i).getString(cols[j]), lang));
							} else if(ar.equals("CreatorName")){
								newObject.put(cols[j], DicHelper.getDicInfo(clist.getMap(i).getString(cols[j]), lang));
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
	
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static CoviMap getFolderConfig(String bizSection, String folderID) throws Exception{
		CoviMap returnMap = new CoviMap();
		
		if (getFolderAuth(bizSection, folderID, "V")){
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			BoardManageSvc boardManageSvc = StaticContextAccessor.getBean(BoardManageSvc.class);
			
			ACLMapper aclMap = ACLHelper.getACLMapper(SessionHelper.getSession(), "FD", bizSection);
			CoviMap aclObj = new CoviMap();
			String aclList = aclMap.getACLListInfo(folderID);
			aclObj.put("Security", aclList.charAt(0));
			aclObj.put("Create", aclList.charAt(1));
			aclObj.put("Delete", aclList.charAt(2));
			aclObj.put("Modify", aclList.charAt(3));
			aclObj.put("Execute", aclList.charAt(4));
			aclObj.put("View", aclList.charAt(5));
			aclObj.put("Read", aclList.charAt(6));
			
			returnMap.put("configMap", boardManageSvc.selectBoardConfig(params));
			returnMap.put("aclMap",aclObj);
			returnMap.put("isAuth", true);
		}
		else{
			returnMap.put("isAuth", false);
		}
		return returnMap;
	}
	
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static CoviMap getFolderConfig(CoviMap params) throws Exception{
		String bizSection = params.getString("bizSection");
		String folderID = params.getString("folderID");
		
		CoviMap returnMap = getFolderConfig(bizSection, folderID);
		
		if (returnMap.getBoolean("isAuth") == true){
			params.put("userCode", SessionHelper.getSession("USERID"));
			if (getReadAuth(params)){ 
				MessageSvc messageSvc = StaticContextAccessor.getBean(MessageSvc.class);
				CoviMap msgMap = messageSvc.selectMessageDetail(params);	
				
				returnMap.put("msgMap", msgMap);
				
				// 메시지 권한 사용 여부 조회
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (params.getString("bizSection").equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
					
					CoviList aclArray = null;
					
					if("Community".equals(bizSection)) {
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					
					CoviMap messageACLObj = getMessageACLInfo(aclArray);
					returnMap.put("msgACLMap", messageACLObj);
				}
				
				returnMap.put("isRead",  true);
			} else {
				returnMap.put("isRead",  false);
			}
		}else{
			returnMap.put("isRead",  false);
		}
		return returnMap;
	}
	
	public static boolean getAuthMessageUpdate(String bizSection, CoviMap configMap, CoviMap aclMap, CoviMap msgMap, CoviMap msgACLMap, String boardType) throws Exception{
		boolean bFlag = false;
		switch (msgMap.getString("MsgState"))
		{
			case "A"://게시클 승인	
				String userCode = SessionHelper.getSession("USERID");
				if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) { //관리자
					bFlag = true;
				} else if (configMap.getString("OwnerCode").indexOf(userCode + ";") != -1) { //게시판 담당자
					bFlag = true;
				} else if ("TableHistory".equals(configMap.getString("FolderType"))) {
					if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (bizSection.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
						if(msgACLMap != null && msgACLMap.getString("Modify").equals("M")) {
							bFlag = true;
						}
					} else {
						if (aclMap.getString("Modify").equals("M")){
							bFlag = true;
						}
					}
				} else {
					bFlag = false;
				}
				break;
			case "R"://승인요청
				bFlag = false;
				break;
			case "D"://거부반려된 게시물 수정할 수 있도록 처리
				bFlag = true;
				break;
			default:
				if (isManage(bizSection, configMap, msgMap))	{
					bFlag = true;//게시글 관리자
				} else if (configMap.getString("UseScrap").equals("Y") && boardType.equals("Scrap")) {//나의게시 스크랩
					bFlag = false;
				} else if ((bizSection.equals("Doc") && msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID"))) || 
							(!bizSection.equals("Doc") && msgMap.getString("CreatorCode").equals(SessionHelper.getSession("USERID")))) {
					bFlag = true;
				} else {					
					if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (bizSection.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
						if(msgACLMap != null && msgACLMap.getString("Modify").equals("M")) {
							bFlag = true;
						}
					} else {
						if (aclMap.getString("Modify").equals("M")){
							bFlag = true;
						}
					}
				}	
				break;
		}
		
		return bFlag;
	}
	
	public static boolean getAuthMessageDelete(String bizSection, CoviMap configMap, CoviMap aclMap, CoviMap msgMap, CoviMap msgACLMap) throws Exception{
		boolean bFlag = false;
		switch (msgMap.getString("MsgState"))
		{
			case "A"://게시클 승인	
			case "R"://승인요청
			case "D"://거부
				bFlag = false;
				break;
			default:
				if (isManage(bizSection, configMap, msgMap))	{
					bFlag= true;//게시글 관리자
				}else if ((bizSection.equals("Doc") && msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID"))) || 
							(!bizSection.equals("Doc") && msgMap.getString("CreatorCode").equals(SessionHelper.getSession("USERID")))) {
					bFlag= true;
				} else {
					if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (bizSection.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
						if(msgACLMap != null && msgACLMap.getString("Delete").equals("D")) {
							bFlag = true;
						}
					} else {
						if (aclMap.getString("Delete").equals("D")){
							bFlag = true;
						}
					}
				}	
				break;
		}
		
		return bFlag;
	}

	public static boolean getAuthMessageMove(String bizSection, CoviMap configMap, CoviMap aclMap, CoviMap msgMap, CoviMap msgACLMap, String boardType) throws Exception{
		boolean bFlag = false;
		if (!configMap.getString("UseCopy").equals("Y")) return false;
		
		switch (msgMap.getString("MsgState"))
		{
			case "A"://게시클 승인	
			case "R"://승인요청
			case "D"://거부
				bFlag = false;
				break;
			default:
				if (isManage(bizSection, configMap, msgMap))	{
					bFlag= true;//게시글 관리자
				} else if (configMap.getString("UseScrap").equals("Y") && boardType.equals("Scrap")) {
					bFlag = false;
				} else if ((bizSection.equals("Doc") && msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID"))) || 
							(!bizSection.equals("Doc") && msgMap.getString("CreatorCode").equals(SessionHelper.getSession("USERID")))) {
					bFlag= true;
				} else {
					if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (bizSection.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
						if(msgACLMap != null && msgACLMap.getString("Delete").equals("D")) {
							bFlag = true;
						}
					} else {
						if (aclMap.getString("Delete").equals("D")){
							bFlag = true;
						}
					}
				}	
				break;
		}
		
		return bFlag;
	}

	public static boolean getAuthMessageApproval(String bizSection, CoviMap configMap, CoviMap aclMap, CoviMap msgMap) throws Exception{
		boolean bFlag = false;
		if (!configMap.getString("UseCopy").equals("Y")) return false;
		
		switch (msgMap.getString("MsgState"))
		{
			case "A"://게시클 승인	
			case "R"://승인요청
			case "D"://거부
				bFlag = false;
				break;
			default:
				if (isManage(bizSection, configMap, msgMap))	{
					bFlag= true;//게시글 관리자
				}else if ((bizSection.equals("Doc") && msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID")))
						|| (!bizSection.equals("Doc") && msgMap.getString("CreatorCode").equals(SessionHelper.getSession("USERID")))
						) bFlag= true;
				else {
					if (aclMap.getString("Delete").equals("D")){
						bFlag=true;
					}
				}	
				break;
		}
		
		return bFlag;
	}

	
	public static boolean isManage(String bizSection, CoviMap configMap, CoviMap msgMap) {
		String userCode = SessionHelper.getSession("USERID");
		if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) { //관리자
			return true;
		}else if ((bizSection.equals("Doc") && msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID")))
				|| (!bizSection.equals("Doc") && msgMap.getString("CreatorCode").equals(SessionHelper.getSession("USERID")) && msgMap.getString("UseScrap").equals("N"))){
			return true;			
		} else {
			if (configMap.getString("OwnerCode").indexOf(userCode + ";") != -1) { //게시판 담당자
				return true;
			}
		}
		
		return false;
	}
	
	public static boolean isCommentDelAuth(CoviMap configMap) {
		String userCode = SessionHelper.getSession("USERID");
		if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) { //관리자
			return true;
		} else {
			if (configMap.getString("OwnerCode").indexOf(userCode + ";") != -1) { //게시판 담당자
				return true;
			}
		}
		
		return false;
	}
	
	public static CoviMap getMessageACLInfo(CoviList aclArray) {		
		String aclList = "______";
		
		if(aclArray.size() > 0) {
			for(int i = 0; i < aclArray.size(); i++){
				CoviMap aclObj = aclArray.getJSONObject(i);
						
				if("UR".equals(aclObj.getString("TargetType"))){
					aclList = aclObj.getString("AclList");
					break;
				} else if("DN".equals(aclObj.getString("TargetType"))){
					aclList = aclObj.getString("AclList");
				} else if("CM".equals(aclObj.getString("TargetType"))){
					aclList = aclObj.getString("AclList");
				} else {
					aclList = aclObj.getString("AclList");
				}
			}
		}
		
		CoviMap aclObj = new CoviMap();		
		aclObj.put("Security", aclList.charAt(0));
		aclObj.put("Create", aclList.charAt(1));
		aclObj.put("Delete", aclList.charAt(2));
		aclObj.put("Modify", aclList.charAt(3));
		aclObj.put("Execute", aclList.charAt(4));
		aclObj.put("Read", aclList.charAt(5));
		
		return aclObj;
	}
		
	/**
	 * 
	 * @param request
	 * @param map
	 * @description Http Request Parameter 자동 매핑 메소드
	 * 
	 */
	public static void setRequestParam(HttpServletRequest request, CoviMap pMap){
		try{
		    Enumeration names = request.getParameterNames();
		    while (names.hasMoreElements()) {
		    	String name = (String) names.nextElement();
		    	String nameVal = StringUtil.replaceNull(request.getParameter(name),"");
		    	//체크박스 항목의 경우 jsp에서 serializeObject 사용시 체크안된 항목은 Null값으로 전달되므로 이름으로 별도처리
		    	//추후 중복되는 이름의 변수를 사용할 경우  변경 필요
		    	if(name.indexOf("use",0) == 0){
		    		//parameter key가 'use'로 시작될경우 N, Y로 분기처리
		    		pMap.put(name, "".equals(nameVal)?"N":"Y");
		    	} else if("sortBy".equals(name)) {
		    		//sortBy 항목 분기
		    		pMap.put("sortBy", ComUtils.RemoveSQLInjection(nameVal, 100));
		    		pMap.put("sortColumn", (nameVal.isEmpty())?"":ComUtils.RemoveSQLInjection(nameVal.split(" ")[0], 100));
		    		pMap.put("sortDirection", (nameVal.isEmpty())?"":ComUtils.RemoveSQLInjection(nameVal.split(" ")[1], 100));
		    	}else if("searchText".equalsIgnoreCase(name) || "seValue".equalsIgnoreCase(name) || "SearchWord".equalsIgnoreCase(name)){
		    		//검색어 SQL Injection 처리
		    		pMap.put(name, ComUtils.RemoveSQLInjection(nameVal, 100));
		    	} else {
		    		//그외의 parameter는 key:value 형태로 set
		    		pMap.put(name, nameVal);
		    	}
		    }
		    
		    pMap.put("isSaaS", isSaaS);
		    
		    String referer = request.getHeader("Referer");
		    // 게시판 설정에서 넘어오는 파라미터와 MenuID가 겹쳐 설정에서 오는 URL인 경우 파라미터 변조를 회피하도록 referer의 문자열을 확인
			String callByAdmin = (referer != null && (referer.indexOf("/board/manage") > -1 || referer.indexOf("/board/admin") > -1 || referer.indexOf("CLMD=manage") > -1)) ? "Y" : "N";
			String callByPortal = (referer != null && referer.indexOf("/portal") > -1) ? "Y" : "N";
			
			if ("N".equals(callByAdmin) || pMap.getString("domainID") == null) {
				pMap.put("domainID", SessionHelper.getSession("DN_ID"));
			}
			
			// 엔터인 경우, 포탈/관리 기능이 아니고 커뮤니티에서 호출한 것이 아닌 경우 그룹사공용의 정보 셋팅 및 menuID 확인 작업 진행
			if ("N".equals(isSaaS) && "N".equals(callByAdmin) 
					&& ("Board".equals(pMap.getString("bizSection")) || "Doc".equals(pMap.getString("bizSection"))) 
					&& ("".equals(pMap.getString("communityID")) || pMap.getString("communityID") == null)
			) {
				String menuCode = pMap.getString("menuCode");
				// 메뉴코드가 요청파라미터에 없는 경우, bizSection을 보고 통합게시/문서관리 코드를 적용
				if (menuCode == null || "".equals(menuCode)) menuCode = ("Doc".equals(pMap.getString("bizSection"))) ? "DocMain" : "BoardMain"; 
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				pMap.put("orgRootMenuID", orgRootMenuID);
				
				if ("N".equals(callByPortal)) {
					String menuID = RedisDataUtil.getBaseConfig(menuCode, pMap.getString("domainID"));
					if ("".equals(pMap.getString("menuID")) || pMap.getString("menuID") == null || !menuID.equals(pMap.getString("menuID"))) {
						pMap.put("menuID", menuID);
					}
				}
			}
		} catch(NullPointerException e){
			LogManager.getLogger(BoardUtils.class).debug(e);
		} catch(ArrayIndexOutOfBoundsException e){
			LogManager.getLogger(BoardUtils.class).debug(e);
		} catch(Exception e){
			LogManager.getLogger(BoardUtils.class).debug(e);
		}
	}
	public static List<HashMap>  getBoardExcelItem(String boardType){
		return getBoardExcelItem(boardType, null);
	}
	public static List<HashMap>  getBoardExcelItem(String boardType, CoviMap configMap){
		List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
		HashMap msgState = new HashMap<String, String>() {{put("C",DicHelper.getDic("lbl_Registor")); put("A",DicHelper.getDic("lbl_Approval"));put("D",DicHelper.getDic("lbl_Rejected"));put("P",DicHelper.getDic("lbl_Lock"));put("R",DicHelper.getDic("lbl_RegistReq"));put("T",DicHelper.getDic("lbl_TempSave"));put("DEL",DicHelper.getDic("lbl_delete"));}};
		HashMap aclState = new HashMap<String, String>() {{put("R",DicHelper.getDic("lbl_Request")); put("A",DicHelper.getDic("lbl_Approval"));put("D",DicHelper.getDic("lbl_Deny"));}};
		
		switch (boardType){
			case "Normal":
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				if (configMap!= null && configMap.getString("UseCategory").equals("Y")){
					colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","80"); put("colKey","CategoryName");  put("colAlign","CENTER"); }});
				}
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Register")); put("colWith","80"); put("colKey","CreatorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate"); put("colFormat","DATETIME");}});
				if (configMap!= null && configMap.getString("UseReadCnt").equals("Y")){
					colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ReadCount")); put("colWith","50"); put("colKey","ReadCnt"); put("colType","I"); put("colAlign","RIGHT");}});
				}
				break;
			case "MyOwnWrite":	//내가 작성한 게시
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_State2")); put("colWith","80"); put("colKey","MsgState"); put("colFormat","CODE"); put("colCode", msgState);}});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate"); put("colFormat","DATETIME");}});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ReadCount")); put("colWith","50"); put("colKey","ReadCnt"); put("colType","I"); put("colAlign","RIGHT");}});
				break;
			case "MyInterest":	//즐겨찾기(Favorite)
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Register")); put("colWith","80"); put("colKey","CreatorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate");put("colFormat","DATETIME"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ReadCount")); put("colWith","50"); put("colKey","ReadCnt"); put("colType","I"); put("colAlign","RIGHT");}});
				break;
			case "MyBooking":		//예약 게시
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_State2")); put("colWith","80"); put("colKey","MsgState"); put("colFormat","CODE"); put("colCode", msgState);}});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_CreateDates")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","80"); put("colKey","RegistDate");put("colFormat","DATETIME"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Booking_Date")); put("colWith","80"); put("colKey","ReservationDate");put("colFormat","DATETIME"); }});
				break;
			case "RequestModify":  //승인요청
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Requester")); put("colWith","80"); put("colKey","RequestorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RequestContent")); put("colWith","300"); put("colKey","RequestMessage"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ProcessContents")); put("colWith","300"); put("colKey","AnswerContent"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_State")); put("colWith","50"); put("colKey","RequestStatus"); }});
				break;
			case "Scrap":		//스크랩
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ScrapDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate");put("colFormat","DATETIME"); }});
				break;
			case "OnWriting":	//작성중
			case "Approval":	//승인
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID"); put("colAlign","CENTER");}});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Register")); put("colWith","80"); put("colKey","CreatorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate"); put("colFormat","DATETIME");}});
				break;

			case "Doc":
				colInfo.add(new HashMap<String, String>() {{put("colName","Ver"); put("colWith","50"); put("colKey","Version"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_DocNo")); put("colWith","150"); put("colKey","Number"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("btn_CheckIn")); put("colWith","50"); put("colKey","IsCheckOut"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDept")); put("colWith","150"); put("colKey","RegistDeptName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Owner")); put("colWith","150"); put("colKey","OwnerName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RevisionDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate"); put("colFormat","DATETIME");}});
				break;
			case "DocAuth":	//문서권한
				colInfo.add(new HashMap<String, String>() {{put("colName","Ver"); put("colWith","50"); put("colKey","Version"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_DocNo")); put("colWith","150"); put("colKey","Number"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("btn_CheckIn")); put("colWith","50"); put("colKey","IsCheckOut"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RequestSummary")); put("colWith","150"); put("colKey","RequestMessage"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Requester")); put("colWith","100"); put("colKey","RequestorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ApproveDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate"); put("colFormat","DATETIME");}});
				colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_State")); put("colWith","80"); put("colKey","ActType"); put("colFormat","CODE"); put("colCode", aclState);}});
				break;
			case "DistributeDoc":	//문서 배포
				colInfo.add(new HashMap<String, String>() {{put("colName","Ver"); put("colWith","50"); put("colKey","Version"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_DocNo")); put("colWith","150"); put("colKey","Number"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("btn_CheckIn")); put("colWith","50"); put("colKey","IsCheckOut"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Reason")); put("colWith","150"); put("colKey","DistributeMsg"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ReceiveDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","DistributeDate"); put("colFormat","DATETIME");}});
				break;
			case "CheckIn":	
			case "CheckOut":
			case "DocOwner":
			case "DocFavorite":
				colInfo.add(new HashMap<String, String>() {{put("colName","Ver"); put("colWith","50"); put("colKey","Version"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_DocNo")); put("colWith","150"); put("colKey","Number"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("btn_CheckIn")); put("colWith","50"); put("colKey","IsCheckOut"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDept")); put("colWith","150"); put("colKey","RegistDeptName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Owner")); put("colWith","150"); put("colKey","OwnerName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RevisionDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RevisionDate"); put("colFormat","DATETIME");}});
				break;
			case "DocTotal":
				colInfo.add(new HashMap<String, String>() {{put("colName","Ver"); put("colWith","50"); put("colKey","Version"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_DocNo")); put("colWith","150"); put("colKey","Number"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("btn_CheckIn")); put("colWith","50"); put("colKey","IsCheckOut"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDept")); put("colWith","150"); put("colKey","RegistDeptName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Owner")); put("colWith","150"); put("colKey","OwnerName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RevisionDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RevisionDate"); put("colFormat","DATETIME");}});
				break;
			case "Manage":
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","150"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_SummaryInfo")); put("colWith","300"); put("colKey","BodyText"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Register")); put("colWith","80"); put("colKey","CreatorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate"); put("colFormat","DATETIME");}});
				break;
			default:
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_no2")); put("colWith","80"); put("colKey","MessageID");  put("colAlign","CENTER"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BoardCate2")); put("colWith","150"); put("colKey","FolderName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_subject")); put("colWith","300"); put("colKey","Subject"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Register")); put("colWith","80"); put("colKey","CreatorName"); }});
				colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegistDate")+SessionHelper.getSession("UR_TimeZoneDisplay")); put("colWith","100"); put("colKey","RegistDate");put("colAlign","CENTER"); put("colFormat","DATETIME"); }});
				break;
		}
		
		return colInfo;
	}
}
