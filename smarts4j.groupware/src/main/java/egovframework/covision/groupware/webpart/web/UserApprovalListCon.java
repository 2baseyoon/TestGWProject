package egovframework.covision.groupware.webpart.web;

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
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.webpart.service.UserApprovalListSvc;

@Controller
public class UserApprovalListCon {

	private Logger LOGGER = LogManager.getLogger(UserApprovalListCon.class);
	@Autowired
	private UserApprovalListSvc userApprovalListSvc;
	
	@RequestMapping(value="webpart/getUserApprovalList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getUserApprovalList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String userID = SessionHelper.getSession("USERID");
		String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
		int pageSize = Integer.parseInt(StringUtil.replaceNull(request.getParameter("pageSize"), "10"));
		
		CoviMap params = new CoviMap();
		params.put("userID", userID);
		params.put("pageSize", pageSize);
		
		CoviMap resultList = new CoviMap();
		
		if(mode.equals("Approval")) {
			resultList = userApprovalListSvc.getUserApprovalList(params);
		} else if(mode.equals("Process")) {
			resultList = userApprovalListSvc.getUserProcessList(params);
		} else if(mode.equals("PreApproval")) {
			resultList = userApprovalListSvc.getUserPreApprovalList(params);
		} else if(mode.equals("TCInfo")) {
			resultList = userApprovalListSvc.getUserTCInfoList(params);
		}
		
		returnObj.put("list", resultList.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value="webpart/getApprovalListCnt.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getUserApprovalListCnt(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();

		try {
		String userID = SessionHelper.getSession("USERID");
		
		CoviMap params = new CoviMap();
		params.put("userID", userID);
		
		int iApproval = userApprovalListSvc.getApprovalListCnt(params);
		int iProcess = userApprovalListSvc.getProcessListCnt(params);
		int iTCInfo = userApprovalListSvc.getTCInfoListCnt(params);

		returnObj.put("status", Return.SUCCESS);
		returnObj.put("approval", iApproval);
		returnObj.put("process", iProcess);
		returnObj.put("tcinfo", iTCInfo);

		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
}
