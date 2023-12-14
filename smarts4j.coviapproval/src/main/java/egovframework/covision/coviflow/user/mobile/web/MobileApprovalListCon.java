package egovframework.covision.coviflow.user.mobile.web;

import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.user.mobile.service.MobileApprovalListSvc;
import egovframework.covision.coviflow.user.service.CommonApprovalListSvc;

@Controller
public class MobileApprovalListCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(MobileApprovalListCon.class);

	@Autowired
	private MobileApprovalListSvc mobileApprovalListSvc;

	@Autowired
	private CommonApprovalListSvc commonApprovalListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");


	@RequestMapping(value = "mobile/MobileApprovalList.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView mobileApprovalList(Locale locale, Model model, HttpServletRequest request)
	{
		String returnURL = "mobile/approval/MobileApprovalList";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalSubMenuData - 모바일 메뉴 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "mobile/getMobileMenuList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMobileMenuList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();

			params.put("userID", userID);

			CoviMap resultList = mobileApprovalListSvc.selectMobileMenuList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getApprovalListData - 모바일 결재함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "mobile/getMobileApprovalListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMobileApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		boolean bhasAuth = false;

		try	{

			//현재 사용자 ID
			String userID = request.getParameter("userID");
			String sessionUserID = SessionHelper.getSession("USERID").toLowerCase();

			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(userID == null || !userID.equalsIgnoreCase(sessionUserID)){
				//관리자
				String requestURI = request.getHeader("referer").toLowerCase();
				if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_adminuserlist.do") > -1){
					bhasAuth = true;
				//권한부여 확인
				}else if(StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("complete") || StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("tcinfo")){
					CoviMap paramsAuth = new CoviMap();

					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));

					CoviMap resultListAuth = new CoviMap();
					resultListAuth = commonApprovalListSvc.getPersonDirectorOfPerson(paramsAuth);
					
					CoviList directPersonList = (CoviList)resultListAuth.get("list");
                    for(Object obj : directPersonList){
                        CoviMap directPerson = (CoviMap)obj;
                        if(directPerson.optString("UserCode").equalsIgnoreCase(userID)){
            				bhasAuth = true;
            				break;
                        }
                    }
				}
			}else{
				bhasAuth = true;
			}
			
			if(bhasAuth){
				String searchType = request.getParameter("searchType");
				String searchWord = request.getParameter("searchWord");
				String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
				String searchGroupWord = request.getParameter("searchGroupWord");
				String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
				String endDate = request.getParameter("endDate");
				String mode 	= StringUtil.replaceNull(request.getParameter("mode"));
				String titleNm 	= request.getParameter("titleNm");
				String userNm 	= request.getParameter("userNm");
				String deptID 	= request.getParameter("deptID");
				
				String sortKey = "";		//request.getParameter("sortBy")==""?"":request.getParameter("sortBy").split(" ")[0];
				String sortDirec = "";	//request.getParameter("sortBy")==""?"":request.getParameter("sortBy").split(" ")[1];
				String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
				String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
							
				String bstored 	= "false"; //request.getParameter("bstored");
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				if(mode.equalsIgnoreCase("TCINFO") || mode.equalsIgnoreCase("DEPTTCINFO"))
					dbName = "COVI_APPROVAL4J";
				if(bstored.equals("true"))
					dbName = "COVI_APPROVAL4J_STORE";
	
				CoviMap resultList = null;
				CoviMap params = new CoviMap();
	
				if(searchGroupType.equals("Date")){
					if(mode.equalsIgnoreCase("REJECT") || mode.equalsIgnoreCase("COMPLETE") || mode.equalsIgnoreCase("DEPTCOMPLETE") || mode.equalsIgnoreCase("RECEIVECOMPLETE")){
						searchGroupType = "EndDate";
					}else{
						searchGroupType = "Created";
					}
				}
	
				if(mode.equalsIgnoreCase("REJECT") || mode.equalsIgnoreCase("COMPLETE") || mode.equalsIgnoreCase("DEPTCOMPLETE") || mode.equalsIgnoreCase("RECEIVECOMPLETE")){
					sortKey = "EndDate";
				}else if(mode.equalsIgnoreCase("TCINFO")){
					sortKey = "InitiatedDate";
				}else if(mode.equalsIgnoreCase("DEPTTCINFO")){
					sortKey = "ReceiptDate";
				}else{
					sortKey = "Created";
				}
	
				params.put("deptID", deptID);
				params.put("userID", userID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("searchGroupType", searchGroupType);
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
				}
				else {
					params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
				}
				params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
				params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate + " 00:00:00")));
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("pageSize", pageSize);
				params.put("pageNo", pageNo);
				params.put("mode", mode);
				params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
				params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
				params.put("DBName", dbName);
	
				if(mode.equalsIgnoreCase("APPROVAL") || mode.equalsIgnoreCase("PROCESS") || mode.equalsIgnoreCase("COMPLETE") || mode.equalsIgnoreCase("REJECT") || mode.equalsIgnoreCase("TCINFO"))
					resultList = mobileApprovalListSvc.selectMobileApprovalList(params);
				else if(mode.equalsIgnoreCase("DEPTCOMPLETE") || mode.equalsIgnoreCase("RECEIVECOMPLETE") || mode.equalsIgnoreCase("DEPTTCINFO"))
					resultList = mobileApprovalListSvc.selectMobileDeptApprovalList(params);
				if(resultList == null) throw new IllegalArgumentException();
				
				returnList.put("list", resultList.get("list"));
				returnList.put("page", resultList.get("list"));
				returnList.put("cnt", resultList.get("cnt"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_DoNotPermissionViewList"));
			}
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
}
