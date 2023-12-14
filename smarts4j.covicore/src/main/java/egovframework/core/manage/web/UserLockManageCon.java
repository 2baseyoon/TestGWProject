package egovframework.core.manage.web;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;













import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.core.manage.service.UserLockManageSvc;
import egovframework.core.sevice.OrganizationADSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : MenuCon.java
 * @Description : 관리자 페이지 이동 요청 처리
 * @Modification Information 
 * @ 2017.06.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("manage")
public class UserLockManageCon {

	private Logger LOGGER = LogManager.getLogger(this);
	
	@Autowired
	private UserLockManageSvc userLockManageSvc;
	
	@Autowired
	private OrganizationManageSvc OrganizationManageSvc;
	
	@Autowired
	private OrganizationADSvc orgADSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "user/getUserLock.do")
	public @ResponseBody CoviMap getUserLock(
			HttpServletRequest request,
			@RequestParam(value = "domainID", required = true, defaultValue = "1") String domainID) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			CoviMap params = new CoviMap();
			
			params.put("DomainID", domainID);
			params.put("searchText", request.getParameter("searchText"));
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			CoviMap returnMap = userLockManageSvc.getUserLock(params);
			returnList.put("list", returnMap.get("list"));
			returnList.put("page", returnMap.get("page"));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;

	}
	/**
	 * @Method Name : approvalAttendRequest
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 승인
	 * @Method 설명 : 근무일정삭제
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "user/saveUserLock.do")
	public  @ResponseBody CoviMap saveUserLock(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			StringUtil func = new StringUtil();
			
			List dataList = (List)params.get("dataList");
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("DN_ID", SessionHelper.getSession("DN_ID"));
			reqMap.put("USERIP", func.getRemoteIP(request));
			reqMap.put("ApprovalRemark", params.get("ApprovalRemark"));

			
			CoviMap returnObj = new CoviMap();
			String strModDate = (String)params.get("ModDate");

			for (int i=0; i < dataList.size(); i++){
				String strUserCode = (String)dataList.get(i);
				
				reqMap.put("UserCode", strUserCode);
				
				CoviMap mTargetInfo = (CoviMap) ((CoviList) OrganizationManageSvc.selectUserInfo(reqMap).get("list")).get(0);
				String strMailAddress=mTargetInfo.getString("MailAddress");
				String strIsAD=mTargetInfo.getString("IsAD");
				String strAD_SamAccountName=mTargetInfo.getString("AD_SamAccountName");
				reqMap.put("MailAddress", strMailAddress);
				reqMap.put("ModDate", strModDate);
				
				String strLogonPW = OrganizationManageSvc.resetUserPassword(reqMap);
				
				returnList.put("message", strLogonPW);
				if("FAIL".equalsIgnoreCase(strLogonPW)){
					reqMap.put("Result", "FAIL");
				}else{
					reqMap.put("Result", "SUCCESS");
				}
				userLockManageSvc.insertUserLockHistory(reqMap);
				
				
				if("FAIL".equalsIgnoreCase(strLogonPW)) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "초기화에 실패하였습니다.");
					throw new Exception();
				} else {
					reqMap.put("LogonPW", strLogonPW);
					
					if(OrganizationManageSvc.getIndiSyncTF() && !strMailAddress.equals("") && mTargetInfo.getString("UseMailConnect").equals("Y") ) {
						if(!"0".equals(OrganizationManageSvc.indiModifyPass(reqMap))){
							throw new Exception("[CP메일]초기화에 실패하였습니다.");
						}
					}
				}
				
				if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") &&RedisDataUtil.getBaseConfig("IsUserSync").equals("Y") && strIsAD.equals("Y")){	//비밀번호 변경
	                CoviMap mapTemp = orgADSvc.adInitPassword(strAD_SamAccountName,strLogonPW,"Manage","");
	                
					if(!Boolean.valueOf((String) mapTemp.getString("result"))){ //실패
						throw new Exception("[AD]초기화에 실패하였습니다.");
					} 
				}
			}
			returnList.put("status", Return.SUCCESS);
//			returnList = userLockManageSvc.saveUserLock(reqMap, dataList);
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	//@Override
	 @RequestMapping(value = "user/excelDown.do")
	 public void excelDown(HttpServletResponse response, HttpServletRequest request) {
		 SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
	        String FileName = "userLock"+dateFormat.format(today);
	
			CoviMap params = new CoviMap();
			String domainID = request.getParameter("DomainID");
			String searchtext = request.getParameter("searchtext");

			params.put("DomainID", domainID);
			params.put("searchText", searchtext);
			
			CoviMap list = userLockManageSvc.getUserLock(params);
			CoviList excelList = (CoviList)list.get("list");
	
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ParentDeptName")); put("colWith","200"); put("colKey","UpDeptName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_dept")); put("colWith","200"); put("colKey","DeptName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_User")); put("colWith","200"); put("colKey","DisplayName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_JobTitle")); put("colWith","300"); put("colKey","JobTitle");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_JobPosition")); put("colWith","80"); put("colKey","JobPosition"); put("colAlign","CENTER");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_JobLevel")); put("colWith","100"); put("colKey","JobLevel"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("SecurityType_LoginFailCount")); put("colWith","100"); put("colKey","login_fail_count"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_PasswordChange")); put("colWith","100"); put("colKey","password_change_date"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_LastLogoutTime")); put("colWith","100"); put("colKey","latest_login_date"); put("colAlign","CENTER"); }});
			
			String excelTitle= DicHelper.getDic("lbl_lockUser");
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 

			try {
				resultWorkbook.close();
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (IOException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception ignore) {
				LOGGER.error(ignore.getLocalizedMessage(), ignore);
			}
	    } 
	    catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	    catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    }
	    catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    }
	    finally {
	        if(resultWorkbook != null) { 
				try {
					resultWorkbook.close();
				} catch (NullPointerException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				} catch (Exception ignore) {
					LOGGER.error(ignore.getLocalizedMessage(), ignore);
				}
			}
	    }
	}
	
	@RequestMapping(value = "user/UserLockHistoryPopup.do", method = RequestMethod.GET)
	public ModelAndView userLockHistoryPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "manage/system/UserLockHistoryPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("UserCode", request.getParameter("UserCode"));
		
		return mav;
	}
	
	@RequestMapping(value = "user/getUserLockHistory.do")
	public @ResponseBody CoviMap getUserLockHistory(HttpServletRequest request) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			CoviMap returnMap = userLockManageSvc.getUserLockHistory(params);
			returnList.put("list", returnMap.get("list"));
			returnList.put("page", returnMap.get("page"));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;

	}
}
