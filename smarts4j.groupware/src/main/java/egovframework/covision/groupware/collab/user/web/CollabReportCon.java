package egovframework.covision.groupware.collab.user.web;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.data.CoviList;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.collab.user.service.CollabReportSvc;

import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

// 협업 스페이스
@Controller
@RequestMapping("collabReport")
public class CollabReportCon {

    @Autowired
    private CollabReportSvc collabReportSvc;

    @Autowired
    private CollabTaskSvc collabTaskSvc;

    private Logger LOGGER = LogManager.getLogger(CollabReportCon.class);
    final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

    //일일보고 리스트
    @RequestMapping(value = "/getUserReportDayList.do", method = RequestMethod.POST)
    public @ResponseBody CoviMap getUserCollabReportDayList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap result = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("USERID", SessionHelper.getSession("USERID"));
            params.put("lang", SessionHelper.getSession("lang"));
            params.put("reportDate", request.getParameter("reportDate"));

            CoviMap pageJson = null;
            if (request.getParameter("pageNo") != null && request.getParameter("pageSize") != null) {
                int cnt = 0;
                int pageNo = AttendUtils.nvlInt(request.getParameter("pageNo"),1);
                int pageSize = AttendUtils.nvlInt(request.getParameter("pageSize"),10);
                
                cnt = collabReportSvc.getUserCollabReportDayListCnt(params);

                CoviMap page= AttendUtils.setPagingData( pageNo,pageSize, cnt);
    			params.addAll(page);
    			pageJson = AttendUtils.pagingJson(pageNo, pageSize,10, cnt);
            }

            result.put("reportDayList", collabReportSvc.getUserCollabReportDayList(params));
            result.put("reportDayPage", pageJson);
            result.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
            result.put("result", Return.FAIL);
        } catch (Exception e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
            result.put("result", Return.FAIL);
        }
        return result;
    }

    //일일보고 리스트
    @RequestMapping(value = "/getUserTaskDayList.do", method = RequestMethod.POST)
    public @ResponseBody CoviMap getUserTaskDayList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap result = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("USERID", SessionHelper.getSession("USERID"));
            params.put("lang", SessionHelper.getSession("lang"));
            params.put("reportDate", request.getParameter("reportDate"));

            CoviMap pageJson = null;
            if (request.getParameter("pageNo") != null && request.getParameter("pageSize") != null) {
                int cnt = 0;
                int pageNo = AttendUtils.nvlInt(request.getParameter("pageNo"),1);
                int pageSize = AttendUtils.nvlInt(request.getParameter("pageSize"),10);
                
                cnt = collabReportSvc.getUserTaskDayListCnt(params);

                CoviMap page= AttendUtils.setPagingData( pageNo,pageSize, cnt);
    			params.addAll(page);
    			pageJson = AttendUtils.pagingJson(pageNo, pageSize,10, cnt);
            }

            result.put("taskDayList", collabReportSvc.getUserTaskDayList(params));
            result.put("taskDayPage", pageJson);
            result.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return result;
    }

    //일일보고 저장
    @RequestMapping(value = "/addReportDay.do", method = RequestMethod.POST)
    public  @ResponseBody CoviMap addReportDay(HttpServletRequest request) throws Exception {
        CoviMap returnObj = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            String tmpTaskSeqList = StringUtil.replaceNull(request.getParameter("taskSeqList"), "");
            String[] taskSeqList = tmpTaskSeqList.split(";");

            params.put("USERID", SessionHelper.getSession("USERID"));
            params.put("reportDate", request.getParameter("reportDate"));
            params.put("taskSeqList", taskSeqList);

            collabReportSvc.insertUserCollabReportDay(params);

            returnObj.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return returnObj;
    }

    //일일보고 삭제
    @RequestMapping(value = "/deleteReportDay.do", method = RequestMethod.POST)
    public  @ResponseBody CoviMap deleteReportDay(HttpServletRequest request) throws Exception {
        CoviMap returnObj = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            String tmpDaySeqList = StringUtil.replaceNull(request.getParameter("daySeqList"), "");
            String[] daySeqList = tmpDaySeqList.split(";");

            if(daySeqList.length != 0) {
                params.put("daySeqList", daySeqList);

                collabReportSvc.deleteUserCollabReportDay(params);
            }

            returnObj.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return returnObj;
    }

    //일일보고 상세 화면
    @RequestMapping(value = "/CollabReportSavePopup.do")
    public ModelAndView collabReportSavePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String returnURL	= "user/collab/CollabReportSavePopup";
        ModelAndView mav	= new ModelAndView(returnURL);
        if (!ComUtils.nullToString(request.getParameter("daySeq"),"").equals("")){
            CoviMap reqMap = new CoviMap();
            reqMap.put("lang", SessionHelper.getSession("lang"));
            reqMap.put("daySeq", Integer.parseInt(request.getParameter("daySeq")));
            CoviMap data = collabReportSvc.getUserCollabReportDay(reqMap);
            String PrjDesc=  data.getString("PrjDesc");
            java.util.StringTokenizer  st = new java.util.StringTokenizer(PrjDesc, "^");
            if (st.hasMoreTokens()){
	            st.nextToken();
	            if (st.hasMoreTokens()) data.put("PrjName",st.nextToken() );
	            if (st.hasMoreTokens()) st.nextToken();
	            if (st.hasMoreTokens()) data.put("PrjName",data.get("PrjName")+">"+st.nextToken() );;
            }    
            else{
            	data.put("PrjName", "My");
            }

            mav.addObject("reportData", data);
            mav.addObject("objId", ComUtils.nullToString(request.getParameter("objId"),""));
        }
        return mav;
    }

    //일일보고 수정
    @RequestMapping(value = "/updateReportDay.do", method = RequestMethod.POST)
    public  @ResponseBody CoviMap updateReportDay(@RequestParam Map<String, Object> params) throws Exception {
        CoviMap returnObj = new CoviMap();
        try {
            CoviMap reqMap = new CoviMap();
            reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
            reqMap.put("USERID", SessionHelper.getSession("USERID"));
            reqMap.put("daySeq", params.get("daySeq"));
            reqMap.put("taskSeq", params.get("taskSeq"));
            reqMap.put("taskStatus", params.get("taskStatus"));
            reqMap.put("progRate", params.get("progRate"));
            reqMap.put("taskTime", Integer.parseInt((String) params.get("taskTime")));
            reqMap.put("remark", params.get("remark"));
            
            collabReportSvc.updateUserCollabReportDay(reqMap); //일일보고 정보 수정
            collabTaskSvc.updateTaskStatus(reqMap); //일일보고 정보 수정시 타스크 상태, 진행률도 같이 수정

            returnObj.put("status", Return.SUCCESS);
        } catch (NumberFormatException e) {
        	returnObj.put("result", Return.FAIL);
        	returnObj.put("message", DicHelper.getDic("msg_apv_249"));
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (NullPointerException e) {
            returnObj.put("result", Return.FAIL);
            returnObj.put("message", DicHelper.getDic("msg_apv_030"));
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnObj.put("result", Return.FAIL);
            returnObj.put("message", DicHelper.getDic("msg_apv_030"));
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return returnObj;
    }

    //주간보고 프로젝트 리스트
    @RequestMapping(value = "/getUserReportWeekProjectList.do", method = RequestMethod.POST)
    public @ResponseBody CoviMap getUserCollabReportWeekProjectList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap result = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("USERID", SessionHelper.getSession("USERID"));
            params.put("lang", SessionHelper.getSession("lang"));
            params.put("startDate", request.getParameter("startDate"));
            params.put("endDate", request.getParameter("endDate"));

            result.put("reportWeekProjectList", collabReportSvc.getUserCollabReportWeekProjectList(params));
            result.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return result;
    }

    //주간보고 정보
    @RequestMapping(value = "/getUserReportWeekData.do", method = RequestMethod.POST)
    public @ResponseBody CoviMap getUserCollabReportWeekData(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap result = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            
            String prjType = StringUtil.replaceNull(request.getParameter("prjType"), "");
            
            params.put("USERID", SessionHelper.getSession("USERID"));
            params.put("lang", SessionHelper.getSession("lang"));
            params.put("startDate", request.getParameter("startDate"));
            params.put("endDate", request.getParameter("endDate"));
            params.put("prjType", prjType);
            params.put("prjSeq", request.getParameter("prjSeq"));
            if (!prjType.equals("P")){
                params.put("execYear", prjType.substring(1));
            }

            CoviMap pageJson = null;
            if (request.getParameter("pageNo") != null && request.getParameter("pageSize") != null) {
                int cnt = 0;
                int pageNo = AttendUtils.nvlInt(request.getParameter("pageNo"),1);
                int pageSize = AttendUtils.nvlInt(request.getParameter("pageSize"),10);
                cnt = collabReportSvc.getUserCollabReportWeekListCnt(params);

                CoviMap page= AttendUtils.setPagingData( pageNo,pageSize, cnt);
    			params.addAll(page);
    			pageJson = AttendUtils.pagingJson(pageNo, pageSize,10, cnt);
            }

            result.put("reportWeekList", collabReportSvc.getUserCollabReportWeekList(params));
            result.put("reportWeekListPage", pageJson);
            result.put("reportWeekData", collabReportSvc.getUserCollabReportWeek(params));
            result.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return result;
    }

    //주간보고 저장
    @RequestMapping(value = "/addReportWeek.do", method = RequestMethod.POST)
    public  @ResponseBody CoviMap addReportWeek(HttpServletRequest request) throws Exception {
        CoviMap returnObj = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("USERID", SessionHelper.getSession("USERID"));

            params.put("startDate", request.getParameter("startDate"));
            params.put("endDate", request.getParameter("endDate"));

            if("".equals(request.getParameter("prjSeq")) || "-1".equals(request.getParameter("prjSeq"))) {
                params.put("prjSeq", "");
                params.put("prjType", "");
            } else {
                params.put("prjSeq", request.getParameter("prjSeq"));
                params.put("prjType", request.getParameter("prjType"));
            }

            params.put("weekRemark", request.getParameter("weekRemark"));
            params.put("nextPlan", request.getParameter("nextPlan"));

            collabReportSvc.insertUserCollabReportWeek(params);

            returnObj.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return returnObj;
    }

    //주간보고 삭제
    @RequestMapping(value = "/deleteReportWeek.do", method = RequestMethod.POST)
    public  @ResponseBody CoviMap deleteReportWeek(HttpServletRequest request) throws Exception {
        CoviMap returnObj = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("reportSeq", request.getParameter("reportSeq"));

            collabReportSvc.deleteUserCollabReportWeek(params);

            returnObj.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return returnObj;
    }

    //주간보고 수정
    @RequestMapping(value = "/updateReportWeek.do", method = RequestMethod.POST)
    public  @ResponseBody CoviMap updateReportWeek(HttpServletRequest request) throws Exception {
        CoviMap returnObj = new CoviMap();
        try {
            CoviMap params = new CoviMap();

            params.put("USERID", SessionHelper.getSession("USERID"));

            params.put("reportSeq", request.getParameter("reportSeq"));

            params.put("weekRemark", request.getParameter("weekRemark"));
            params.put("nextPlan", request.getParameter("nextPlan"));

            collabReportSvc.updateUserCollabReportWeek(params); //일일보고 정보 수정

            returnObj.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnObj.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return returnObj;
    }

    /*일일보고 리스트
    @RequestMapping(value = "/getProjectReportDayList.do", method = RequestMethod.POST)
    public @ResponseBody CoviMap getProjectReportDayList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap result = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("prjSeq", request.getParameter("prjSeq"));
            params.put("prjType", request.getParameter("prjType"));
            params.put("reportDate", request.getParameter("reportDate"));

            int cnt = collabReportSvc.getProjectReportDayListCnt(params);
            result.put("reportDayListCnt", cnt);

            List<CoviMap> reportDayList = null;
            if(cnt != 0) {
                reportDayList = collabReportSvc.getProjectReportDayList(params);
            }
            result.put("reportDayList", reportDayList);
            result.put("status", Return.SUCCESS);
        } catch (Exception e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return result;
    }*/
    
    //주간보고 정보
    @RequestMapping(value = "/getReportWeekData.do", method = RequestMethod.POST)
    public @ResponseBody CoviMap getReportWeekData(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap result = new CoviMap();
        
        try {
            String strPageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
    		String strPageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
    		
    		CoviMap params = new CoviMap();
            params.put("USERID", SessionHelper.getSession("USERID"));
            params.put("lang", SessionHelper.getSession("lang"));
            params.put("startDate", StringUtil.replaceNull(request.getParameter("startDate"), ""));
            params.put("endDate", StringUtil.replaceNull(request.getParameter("endDate"), ""));
            params.put("prjSeq", StringUtil.replaceNull(request.getParameter("prjSeq"), ""));
            params.put("prjType", StringUtil.replaceNull(request.getParameter("prjType"), ""));
            params.put("pageNo", strPageNo);
            params.put("pageSize", strPageSize);
            
            CoviMap resultList = collabReportSvc.getProjectReportWeekList(params);
            
            result.put("reportWeekListPage", resultList.get("page"));
            result.put("reportWeekList", resultList.get("list"));
            result.put("status", Return.SUCCESS);
        } catch (NullPointerException e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            result.put("result", Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }
        return result;
    }

    //주간보고 상세 화면
    @RequestMapping(value = "/CollabReportWeekPopup.do")
    public ModelAndView collabReportWeekPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String returnURL	= "user/collab/CollabReportWeekPopup";
        ModelAndView mav	= new ModelAndView(returnURL);
        if (!ComUtils.nullToString(request.getParameter("reporterCode"),"").equals("")){
            CoviMap reqMap = new CoviMap();
            reqMap.put("lang", SessionHelper.getSession("lang"));
            reqMap.put("USERID", SessionHelper.getSession("USERID"));
            reqMap.put("lang", SessionHelper.getSession("lang"));
            reqMap.put("prjType", request.getParameter("prjType"));
            reqMap.put("prjSeq", request.getParameter("prjSeq"));
            reqMap.put("reporterCode", request.getParameter("reporterCode"));
            reqMap.put("startDate", request.getParameter("startDate"));
            reqMap.put("endDate", request.getParameter("endDate"));
            List<CoviMap>  data = collabReportSvc.getProjectReportDayList(reqMap);
            mav.addObject("dayList", data);
            mav.addObject("prjName", request.getParameter("prjName"));
            mav.addObject("reporterName", request.getParameter("reporterName"));
            mav.addObject("startDate", request.getParameter("startDate"));
            mav.addObject("endDate", request.getParameter("endDate"));
            mav.addObject("objId", ComUtils.nullToString(request.getParameter("objId"),""));
        }
        return mav;
    }
    // 일간보고 조회
    @RequestMapping(value = "/collabReportDayDtl.do")
    public @ResponseBody CoviMap collabReportDayDtl(HttpServletRequest request, HttpServletResponse response) throws Exception {
    	CoviMap result = new CoviMap();
        if (!ComUtils.nullToString(request.getParameter("reporterCode"),"").equals("")){
            CoviMap reqMap = new CoviMap();
            reqMap.put("prjType", request.getParameter("prjType"));
            reqMap.put("prjSeq", request.getParameter("prjSeq"));
            reqMap.put("reporterCode", request.getParameter("reporterCode"));
            reqMap.put("startDate", request.getParameter("startDate"));
            reqMap.put("endDate", request.getParameter("endDate"));
            List<CoviMap> data = collabReportSvc.getProjectReportDayList(reqMap);
            result.put("dayList", data);
        }
        return result;
    }
}
