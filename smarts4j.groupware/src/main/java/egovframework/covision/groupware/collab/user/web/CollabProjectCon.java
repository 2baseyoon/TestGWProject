package egovframework.covision.groupware.collab.user.web;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;



import egovframework.baseframework.util.json.JSONParser;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.collab.user.service.CollabTodoSvc;
import egovframework.covision.groupware.collab.util.CollabUtils;
import egovframework.covision.groupware.util.Ajax;
import egovframework.coviframework.util.StringUtil;

// 협업 스페이스 
@Controller
@RequestMapping("collabProject")
public class CollabProjectCon {
	@Autowired
	private CollabProjectSvc collabProjectSvc;
	
	@Autowired
	private CollabTaskSvc collabTaskSvc;
	
	@Autowired
    private CollabTodoSvc collabTodoSvc;
	
	@Autowired
	private FileUtilService fileSvc;

	private Logger LOGGER = LogManager.getLogger(CollabCommonCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
		
	//프로젝트 추가 화면
	@RequestMapping(value = "/CollabProjectPopup.do")
	public ModelAndView collabProjectPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabProjectPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("")){
			CoviMap data = collabProjectSvc.getProject(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("prjData", data.get("prjData"));
			mav.addObject("memberList", data.get("memberList"));
			mav.addObject("managerList", data.get("managerList"));
			mav.addObject("viewerList", data.get("viewerList"));
			mav.addObject("mileList", data.get("mileList"));
			mav.addObject("sectionList", data.get("sectionList"));
			mav.addObject("userformList", data.get("userformList"));
			mav.addObject("prjAdmin", checkProjectAdmin((List)data.get("managerList"), (CoviMap)data.get("prjData")));
			mav.addObject("prjMember", checkProjectMember((List)data.get("memberList"), (CoviMap)data.get("prjData")));
			mav.addObject("fileList", data.get("fileList"));
		}
		return mav;
	}
	
	@RequestMapping(value = "/CollabProjectPopupView.do")
	public ModelAndView collabProjectPopupView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabProjectPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("")){
			CoviMap data = collabProjectSvc.getProject(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("prjData", data.get("prjData"));
			mav.addObject("memberList", data.get("memberList"));
			mav.addObject("managerList", data.get("managerList"));
			mav.addObject("viewerList", data.get("viewerList"));
			mav.addObject("mileList", data.get("mileList"));
			mav.addObject("sectionList", data.get("sectionList"));
			mav.addObject("userformList", data.get("userformList"));
			mav.addObject("prjAdmin", "N");
			mav.addObject("prjMember", "N");
			mav.addObject("fileList", data.get("fileList"));
		}
		return mav;
	}

	//템플릿 추가 화면
	@RequestMapping(value = "/CollabTmplPopup.do")
	public ModelAndView collabTmplPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTmplPopup";
		return new ModelAndView(returnURL);
	}

	//프로젝트 추가
	@RequestMapping(value = "/getProject.do")
	public @ResponseBody CoviMap getProject(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap data = collabProjectSvc.getProject(Integer.parseInt(request.getParameter("prjSeq")));
			returnObj.put("prjData", data.get("prjData"));
			returnObj.put("memberList", data.get("memberList"));
			returnObj.put("managerList", data.get("managerList"));
			returnObj.put("userformList", data.get("userformList"));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}

	//프로젝트 메인
	@RequestMapping(value = "/getProjectMain.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getProjectMain(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", Integer.parseInt(request.getParameter("prjSeq")));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("mode", request.getParameter("mode"));
			reqMap.put("date1", ComUtils.removeMaskAll(request.getParameter("date1")));
			reqMap.put("date2", ComUtils.removeMaskAll(request.getParameter("date2")));
			//params.put("prjAdmin", "Y");
			reqMap.put("objectType", request.getParameter("objectType"));
			reqMap.put("searchOption", request.getParameter("searchOption"));
			reqMap.put("searchWord", request.getParameter("searchWord"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("memberId", request.getParameter("memberId"));
        	
			CoviMap data = collabProjectSvc.getProjectMain(reqMap);
			
			returnObj.put("prjData", data.get("prjData"));
			returnObj.put("prjStat", data.get("prjStat"));
//			returnObj.put("sectionList", data.get("sectionList"));
			returnObj.put("taskData", data.get("taskData"));
			returnObj.put("taskFilter", data.get("taskFilter"));
			returnObj.put("memberList", data.get("memberList"));
			returnObj.put("managerList", data.get("managerList"));
			returnObj.put("prjAdmin", checkProjectAdmin((List)data.get("managerList"), (CoviMap)data.get("prjData")));
			returnObj.put("prjMember", checkProjectMember((List)data.get("memberList"), (CoviMap)data.get("prjData")));
			
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;		
	}
	
	//프로젝트 추가
	@RequestMapping(value = "/addProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addProject(@RequestParam(value = "file", required = false)  MultipartFile[] uploadfile,
			@RequestParam Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			JSONParser parser = new JSONParser();

			List trgMember =  (List)parser.parse((String)params.get("trgMember"));
			List trgUserForm =  (List)parser.parse((String)params.get("trgUserForm"));
			List trgManager =  (List)parser.parse((String)params.get("trgManager"));
			List trgViewer =  (List)parser.parse((String)params.get("trgViewer"));
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjName", params.get("prjName"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
			reqMap.put("remark", params.get("remark"));
			reqMap.put("prjStatus", params.get("prjStatus"));
			if (params.get("prjStatus") != null && params.get("prjStatus").equals("C"))
				reqMap.put("progRate", "100");
			else
				reqMap.put("progRate", params.get("progRate"));
			reqMap.put("prjColor", params.get("prjColor"));

			if (trgManager.size() == 0){
				CoviMap trgMap = new CoviMap();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgManager.add(trgMap);
			}
			
			if (trgMember.size() == 0){
				CoviMap trgMap = new CoviMap();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
			}
			
			CoviMap result = collabProjectSvc.addProject(reqMap, trgMember, trgManager, trgViewer, trgUserForm, uploadfile);
			
			//마일스톤 관련
			List trgMileForm =  (List)parser.parse((String)params.get("trgMileForm"));
			
			if(trgMileForm.size() > 0) {
				
				//Section 생성
				reqMap.put("prjSeq", result.get("prjSeq"));
				reqMap.put("prjType", ((params.get("PrjType") == null || "".equals(params.get("PrjType")))?"P":params.get("PrjType")));
				reqMap.put("sectionName", "hold");
				
				result = collabProjectSvc.addProjectSection(reqMap);
				
				reqMap.put("SectionSeq", result.get("SectionSeq"));
				
				//마일스톤(업무), 프로젝트 지정(map)
				for (int i = 0; i < trgMileForm.size(); i++) {
					CoviMap milejson = (CoviMap) trgMileForm.get(i);
					
					//map 생성
					CoviMap mileMap = new CoviMap();
					mileMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
					mileMap.put("USERID", SessionHelper.getSession("USERID"));
					mileMap.put("taskSeq", milejson.get("taskSeq"));
					mileMap.put("prjSeq", reqMap.get("prjSeq"));
					mileMap.put("prjType", reqMap.get("prjType"));
					mileMap.put("sectionSeq", reqMap.get("SectionSeq"));
					
					int cnt = collabTaskSvc.addAllocProject(mileMap);
				}
			}
			
			StringBuffer sbTarget = new StringBuffer("");
	        for (int i=0; i < trgMember.size(); i++){
	        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
	        	
	        	sbTarget.append((String)((HashMap)trgMember.get(i)).get("userCode")); 
	        }    
	        for (int i=0; i < trgManager.size(); i++){
	        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
	        	
	        	sbTarget.append((String)((HashMap)trgManager.get(i)).get("userCode")); 
	        }    
	        
	        CoviMap msgMap = new CoviMap();
	        msgMap.put("prjName",params.get("prjName"));
	        CollabUtils.sendMessage("PrjAdd", sbTarget.toString(), msgMap);
	        
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	//프로젝트 추가(템프르릿 사용)
	@RequestMapping(value = "/addProjectByTmpl.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addProjectByTmpl(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			List trgManager = (List)params.get("trgManager");
			List trgMember = (List)params.get("trgMember");
			
			if(trgManager == null) {
				trgManager = new ArrayList<>();
				CoviMap trgMap = new CoviMap();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgManager.add(trgMap);
			}
			if(trgMember == null) {
				trgMember = new ArrayList<>();
				CoviMap trgMap = new CoviMap();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
			}
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("tmplSeq", params.get("tmplSeq"));
			reqMap.put("prjName", params.get("prjName"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
			reqMap.put("prjStatus", params.get("prjStatus"));
			reqMap.put("progRate", "0");

			CoviMap result = collabProjectSvc.addProjectByTmpl(reqMap, trgMember, trgManager);
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
		
	//프로젝트 저장
	@RequestMapping(value = "/saveProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveProject(@RequestParam(value = "file", required = false)  MultipartFile[] uploadfile
				, @RequestParam Map<String, Object> params, HttpServletRequest request
				, HttpServletResponse response) throws Exception{
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			JSONParser parser = new JSONParser();
			//List<MultipartFile> mf = request.getFiles("files");
			
			List trgMember =  (List)parser.parse((String)params.get("trgMember"));
			List trgUserForm =  (List)parser.parse((String)params.get("trgUserForm"));
			List trgManager =  (List)parser.parse((String)params.get("trgManager"));
			List trgViewer =  (List)parser.parse((String)params.get("trgViewer"));
			List delFile =  (List)parser.parse((String)params.get("delFile"));

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("prjName", params.get("prjName"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
			reqMap.put("remark", params.get("remark"));
			reqMap.put("prjColor", params.get("prjColor"));
			reqMap.put("prjStatus", params.get("prjStatus"));
			if (params.get("prjStatus") != null && params.get("prjStatus").equals("C"))
				reqMap.put("progRate", "100");
			else
				reqMap.put("progRate", params.get("progRate"));

			CoviMap data = collabProjectSvc.getProject(Integer.parseInt((String)params.get("prjSeq")));
			CoviMap result = collabProjectSvc.saveProject(reqMap, trgMember, trgManager, trgViewer, trgUserForm, uploadfile, delFile);
			
			//마일스톤 관련
			List trgMileForm =  (List)parser.parse((String)params.get("trgMileForm"));
			
			if(trgMileForm.size() > 0) {
				
				reqMap.put("prjType", (params.get("PrjType") == null || "".equals(params.get("PrjType")))? "P" : params.get("PrjType"));
				
				//Section 체크
				int secCnt = collabProjectSvc.projectSectionCnt(reqMap);
				
				String SectionSeq = "";
				if(secCnt == 0) {
					//Section 생성
					reqMap.put("sectionName", "hold");
					result = collabProjectSvc.addProjectSection(reqMap);
					
					SectionSeq = (String) result.get("SectionSeq");
				}else {
					//첫번째 Section 조회
					SectionSeq = collabProjectSvc.getProjectSectionSeq(reqMap);
				}
				reqMap.put("SectionSeq", SectionSeq);
				
				//마일스톤(업무), 프로젝트 연결(map)
				for (int i = 0; i < trgMileForm.size(); i++) {
					CoviMap milejson = (CoviMap) trgMileForm.get(i);
					
					CoviMap mileMap = new CoviMap();
					mileMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
					mileMap.put("USERID", SessionHelper.getSession("USERID"));
					mileMap.put("taskSeq", milejson.get("taskSeq"));
					mileMap.put("prjSeq", reqMap.get("prjSeq"));
					mileMap.put("prjType", reqMap.get("prjType"));
					mileMap.put("sectionSeq", reqMap.get("SectionSeq"));
					
					int mapcnt = collabTaskSvc.getTaskMapCnt(mileMap);
					
					//map 생성
					if(mapcnt < 1) collabTaskSvc.addAllocProject(mileMap);
				}
			}
			
			CoviMap prjData = (CoviMap)data.get("prjData");
			CookiesUtil cUtil = new CookiesUtil();
			if (!prjData.getString("RoomId").equals("")){
				List bfMemberList = (List)data.get("memberList");

				//삭제 목록 추출
				CoviList eumMember = new CoviList();
				for (int j =0; j < bfMemberList.size(); j++ ){
					boolean bFind = false;
					String bfUserId = ((CoviMap)(bfMemberList.get(j))).getString("UserCode");
					
					for (int i =0; i < trgMember.size(); i++ ){
						if (bfUserId.equals((String)((Map)(trgMember.get(i))).get("userCode")))
						{
							bFind = true;
							break;
						}
					}
					if (bFind == false){
						eumMember.add(bfUserId);
					}	
				}
				
				if (eumMember.size()>0){
					CoviMap eumMap = new CoviMap();
					eumMap.put("members", eumMember);
					
					eumMap.put("CSJTK", cUtil.getCooiesValue(request));
					eumMap.put("USERID", SessionHelper.getSession("USERID"));
					
					CollabUtils.removeChannelMember(prjData.getString("RoomId"),eumMap);
				}
				
				//추가 목록 추출
				eumMember = new CoviList();
				CoviList targetArr = new CoviList();
				for (int j =0; j < trgMember.size(); j++ ){
					boolean bFind = false;
					String newUserId = (String)((Map)(trgMember.get(j))).get("userCode");
					
					for (int i =0; i < bfMemberList.size(); i++ ){
						if (newUserId.equals((String)((CoviMap)(bfMemberList.get(i))).getString("UserCode")))
						{
							bFind = true;
							break;
						}
					}
					if (bFind == false){
						CoviMap eumMap = new CoviMap();
						data.put("targetCode", newUserId);
						data.put("targetType", "UR");
						
						eumMember.add(newUserId);
						targetArr.add(data);
					}	
				}
				
				if (eumMember.size()>0){
					CoviMap eumMap = new CoviMap();

					eumMap.put("targetArr", targetArr);
					eumMap.put("members", eumMember);
					
					eumMap.put("CSJTK", cUtil.getCooiesValue(request));
					eumMap.put("USERID", SessionHelper.getSession("USERID"));
					
					CollabUtils.addChannelMember(prjData.getString("RoomId"),eumMap);
				}
			}
						
			StringBuffer sbTarget = new StringBuffer("");
	        for (int i=0; i < trgMember.size(); i++){
	        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
	        	
	        	sbTarget.append((String)((HashMap)trgMember.get(i)).get("userCode")); 
	        }    
	        for (int i=0; i < trgManager.size(); i++){
	        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
	        	
	        	sbTarget.append((String)((HashMap)trgManager.get(i)).get("userCode")); 
	        }    
	        
	        CoviMap msgMap = new CoviMap();
	        msgMap.put("prjName",params.get("prjName"));
	        
	        //프로젝트 상태가 변경될 경우 발송
	        if (!prjData.getString("PrjStatus").equals(params.get("prjStatus"))){
		        CollabUtils.sendMessage("PrjMod", sbTarget.toString(), msgMap);
	        }    	
	        returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	//삭제
	@RequestMapping(value = "/deleteProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteProjectInvite(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			
			int cnt = collabProjectSvc.deleteProject(reqMap);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	//섹션 변경화면
	@RequestMapping(value = "/CollabSectionChangePopup.do")
	public ModelAndView collabSectionChangePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabSectionChangePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("taskSeq", request.getParameter("taskSeq"));
		
		CoviMap params = new CoviMap();
		params.put("prjSeq", request.getParameter("prjSeq"));
		params.put("prjType", request.getParameter("prjType"));
		params.put("sectionMile", "Y");
		
		List<CoviMap> secList = collabProjectSvc.getSectionList(params);
		mav.addObject("secList", secList);
		
		return mav;
	}
	
	//섹션 변경처리
	@RequestMapping(value = "/saveSectionChange.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveSectionChange(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {		
				
			CoviMap sortParam =  new CoviMap();
			sortParam.put("prjSeq", params.get("prjSeq"));
			sortParam.put("prjType", params.get("prjType"));
			sortParam.put("taskSeq", params.get("taskSeq"));
			sortParam.put("sectionSeq", params.get("sectionseq"));
			
			collabProjectSvc.updateSectionChange(sortParam);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

	}
	
	//섹션 순서변경화면
	@RequestMapping(value = "/CollabSectionMovePopup.do")
	public ModelAndView collabSectionMovePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabSectionMovePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjType", request.getParameter("prjType"));
		
		CoviMap params = new CoviMap();
		params.put("prjSeq", request.getParameter("prjSeq"));
		params.put("prjType", request.getParameter("prjType"));
		
		List<CoviMap> secList = collabProjectSvc.getSectionList(params);
		mav.addObject("secList", secList);
		
		return mav;
	}
	
	//섹션 순서변경처리
	@RequestMapping(value = "/saveSectionMove.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveSectionMove(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			List<HashMap> sortList = (List<HashMap>) params.get("sortParam");
						
			for (int i = 0; i < sortList.size(); i++) {
				HashMap sortMap =  sortList.get(i);
				
				CoviMap sortParam =  new CoviMap();
				sortParam.put("prjSeq", params.get("prjSeq"));
				sortParam.put("prjType", params.get("prjType"));
				sortParam.put("sectionOrder", sortMap.get("sectionorder"));
				sortParam.put("sectionSeq", sortMap.get("sectionseq"));
				
				collabProjectSvc.updateSectionOrder(sortParam);
			}
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

	}
	
	//섹션 추가화면
	@RequestMapping(value = "/CollabSectionPopup.do")
	public ModelAndView collabSectionPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabSectionPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("callBackParam", StringUtil.replaceNull(request.getParameter("callBackParam"), "").replaceAll("&quot;", "\""));
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("taskSeq", request.getParameter("taskSeq"));
		mav.addObject("prjName", request.getParameter("prjName"));
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));
		mav.addObject("sectionName", request.getParameter("sectionName"));
		mav.addObject("isMile", request.getParameter("isMile"));
		return mav;
	}
	
	//섹션 추가
	@RequestMapping(value = "/addProjectSection.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addProjectSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("sectionName", request.getParameter("sectionName"));
			
			result = collabProjectSvc.addProjectSection(reqMap);
			//returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	
	//섹션 수정
	@RequestMapping(value = "/saveProjectSection.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveProjectSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("sectionName", request.getParameter("sectionName"));
			
			result = collabProjectSvc.saveProjectSection(reqMap);
			//returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
		
	//섹션삭제
	@RequestMapping(value = "/deleteProjectSection.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteProjectSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			
			collabProjectSvc.deleteProjectSection(reqMap);
			result.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	//프로젝트 복사 화면
	@RequestMapping(value = "/CollabProjectCopyPopup.do")
	public ModelAndView collabProjectCopyPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabProjectCopyPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("prjName", request.getParameter("prjName"));
		return mav;
	}
	
	//복사
	@RequestMapping(value = "/copyProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap copyProject(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("orgPrjSeq", request.getParameter("orgPrjSeq"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("prjName", request.getParameter("prjName"));
			reqMap.put("progRate", "0");
			int cnt = collabProjectSvc.copyProject(reqMap);
			result.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	
	//초대
	@RequestMapping(value = "/addProjectInvite.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addProjectInvite(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			//List dataList = (List)params.get("dataList");
			List trgMember = (List)params.get("trgMember");
			String roomId = (String)params.get("roomId");
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("memberList", trgMember);

			
			CoviMap result = collabProjectSvc.addProjectInvite(reqMap);
			
			if (roomId != null && !roomId.equals("")){
				CookiesUtil cUtil = new CookiesUtil();
				CoviList eumMember = new CoviList();
				CoviList targetArr = new CoviList();
				for (int i =0; i < trgMember.size(); i++ ){
					CoviMap data = new CoviMap();
					data.put("targetCode", ((Map)trgMember.get(i)).get("userCode"));
					data.put("targetType", "UR");
					
					eumMember.add(data.get("targetCode"));
					targetArr.add(data);
				}
				
				CoviMap eumMap = new CoviMap();
				eumMap.put("targetArr", targetArr);
				eumMap.put("members", eumMember);
				
				eumMap.put("CSJTK", cUtil.getCooiesValue(request));
				eumMap.put("USERID", SessionHelper.getSession("USERID"));
				result = CollabUtils.addChannelMember(roomId,eumMap);
			}	
			
			StringBuffer sbTarget = new StringBuffer();
	        for (int i=0; i < trgMember.size(); i++){
	        	if (i>0) sbTarget.append(";");
	        	
	        	sbTarget.append((String)((HashMap)trgMember.get(i)).get("userCode")); 
	        }    
	        
	        CoviMap msgMap = new CoviMap();
	        msgMap.put("prjName",params.get("prjName"));
	        CollabUtils.sendMessage("PrjAddMember", sbTarget.toString(), msgMap);
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	
	/**
     * @param params 내업무 리스트
     *               작성자 : jycho2
     * @return
     */
    @RequestMapping(value = "/getMyTask.do")
	public  @ResponseBody CoviMap getMyTask(HttpServletRequest request) throws Exception {
//        ModelMap modelMap = new ModelMap();
    	CoviMap returnObj = new CoviMap();
        try {
            //내 할일 목록
        	CoviMap reqMap = new CoviMap();
        	String prjTpye = request.getParameter("prjType");
        	
        	reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("mode", request.getParameter("mode"));
			reqMap.put("myTodo", request.getParameter("myTodo"));
        	reqMap.put("prjType", request.getParameter("prjType"));
        	reqMap.put("prjSeq", request.getParameter("prjSeq"));
        	reqMap.put("tagtype", request.getParameter("tagtype"));
        	reqMap.put("tagval", request.getParameter("tagval"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("date1", ComUtils.removeMaskAll(request.getParameter("date1")));
			reqMap.put("date2", ComUtils.removeMaskAll(request.getParameter("date2")));
			reqMap.put("searchOption", request.getParameter("searchOption"));
			reqMap.put("searchWord", request.getParameter("searchWord"));
			reqMap.put("searchText", request.getParameter("searchText"));
        	reqMap.put("noEndDate", request.getParameter("noEndDate"));
			reqMap.put("filterType", request.getParameter("filterType"));
			reqMap.put("objectType", request.getParameter("objectType"));
			reqMap.put("completMonth", request.getParameter("completMonth"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("sectionName", request.getParameter("sectionName"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("memberId", request.getParameter("memberId"));
			//reqMap.put("pageNo", request.getParameter("pageNo"));
			//reqMap.put("pageSize", request.getParameter("pageSize"));
			CoviMap taskInfo  = collabProjectSvc.getProjectTask(reqMap);
			returnObj.put("taskFilter", taskInfo.get("taskFilter"));
			returnObj.put("taskData", taskInfo.get("taskData"));

			//상단카운트
			if ("M".equals(request.getParameter("prjType"))) {//내 업무 카운트
				returnObj.put("taskStat", collabTodoSvc.myTaskStat(reqMap));
			}else {//프로젝트 카운트
				returnObj.put("taskStat", collabProjectSvc.getProjectStat(reqMap));
			}
			
        	returnObj.put("result", Ajax.OK.result());
        } catch (NullPointerException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        } catch (Exception e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        } 
        return returnObj;
    }
    
	 //@Override
	 @RequestMapping(value = "/excelDown.do")
	 public void todoExcelDownload(@RequestParam Map<String, Object> params, HttpServletResponse response, HttpServletRequest request) {
		 SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
	        String FileName = "CollabTaskList"+dateFormat.format(today);
	
	        HashMap<String,Object> pars = new HashMap<>();
	        CoviMap reqMap = new CoviMap();

	        reqMap.put("mode", "STAT");
			reqMap.put("myTodo", request.getParameter("myTodo"));
        	reqMap.put("prjType", request.getParameter("prjType"));
        	reqMap.put("prjSeq", request.getParameter("prjSeq"));
        	reqMap.put("tagtype", "");
        	reqMap.put("tagval", "");
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("date1", ComUtils.removeMaskAll(request.getParameter("date1")));
			reqMap.put("date2", ComUtils.removeMaskAll(request.getParameter("date2")));
			reqMap.put("searchOption", request.getParameter("searchOption"));
			reqMap.put("searchWord", request.getParameter("searchWord"));
			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("filterType", request.getParameter("filterType"));
			reqMap.put("objectType", request.getParameter("objectType"));
			reqMap.put("completMonth", request.getParameter("completMonth"));
			
			CoviMap taskInfo = collabProjectSvc.getProjectTask(reqMap);
			List<CoviMap> resultList = (List<CoviMap>)taskInfo.get("taskData");
			CoviList excelList = new CoviList();
			
			for (int i=0; i<resultList.size();i++){
				excelList.addAll((List<HashMap>)resultList.get(i).get("list"));
			}    
	
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			HashMap labelCode = new HashMap<String, String>() {{put("I",DicHelper.getDic("lbl_Important")); put("E",DicHelper.getDic("lbl_Urgency"));}};
			HashMap statusCode = new HashMap<String, String>() {{put("W",DicHelper.getDic("lbl_Ready")); put("P",DicHelper.getDic("lbl_Progress")); put("H",DicHelper.getDic("lbl_Hold")); put("C",DicHelper.getDic("lbl_Completed"));}};
			
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_workname")); put("colWith","150"); put("colKey","TaskName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_detailworkname")); put("colWith","200"); put("colKey","RemarkText"); }});
			colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_Categories")); put("colWith","50"); put("colKey","Label"); put("colAlign","CENTER"); put("colFormat","CODE");put("colCode",labelCode);}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_type")); put("colWith","50"); put("colKey","ObjectType"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_startdate")); put("colWith","70"); put("colKey","StartDate"); put("colAlign","CENTER"); put("colFormat","DATE"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_EndDate")); put("colWith","70"); put("colKey","EndDate"); put("colAlign","CENTER"); put("colFormat","DATE"); }});
			colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("CPMail_Status")); put("colWith","50"); put("colKey","TaskStatus"); put("colAlign","CENTER");put("colFormat","CODE");put("colCode",statusCode); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TFProgressing")); put("colWith","50"); put("colKey","ProgRate"); put("colAlign","CENTER"); put("colType","I"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("ACC_lbl_deadlineDate")); put("colWith","70"); put("colKey","CloseDate"); put("colAlign","CENTER");put("colFormat","DATE");  }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Modifier")); put("colWith","50"); put("colKey","ModifierName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ModifyDate")); put("colWith","100"); put("colKey","ModifyDate"); put("colAlign","CENTER"); }});
			String excelTitle;
			
	        if ("Y".equals(request.getParameter("myTodo") ))
	        	excelTitle = "My";
	        else
	        	excelTitle = "["+request.getParameter("prjName")+"] ";
	        
	        excelTitle += DicHelper.getDic("lbl_task_task");
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose();
	    } catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (ParseException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (NullPointerException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	        if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
	    }
	}

    /**
     * @param params 내업무 리스트paging
     *               작성자 : jycho2
     * @return
     */
    @RequestMapping(value = "/getMyTaskPage.do")
	public  @ResponseBody CoviMap getMyTaskPage(HttpServletRequest request) throws Exception {
//        ModelMap modelMap = new ModelMap();
    	CoviMap returnObj = new CoviMap();
        try {
            //내 할일 목록
        	CoviMap reqMap = new CoviMap();

			reqMap.put("myTodo", request.getParameter("myTodo"));
        	reqMap.put("prjType", request.getParameter("prjType"));
        	reqMap.put("prjSeq", request.getParameter("prjSeq"));
        	reqMap.put("tagtype", request.getParameter("tagtype"));
        	reqMap.put("tagval", request.getParameter("tagval"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("date1", ComUtils.removeMaskAll(request.getParameter("date1")));
			reqMap.put("date2", ComUtils.removeMaskAll(request.getParameter("date2")));
			reqMap.put("searchOption", request.getParameter("searchOption"));
			reqMap.put("searchWord", request.getParameter("searchWord"));
			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("filterType", request.getParameter("filterType"));
			reqMap.put("objectType", request.getParameter("objectType"));
			reqMap.put("completMonth", request.getParameter("completMonth"));
			
			CoviMap taskInfo  = collabProjectSvc.getProjectTask(reqMap);
			returnObj.put("taskFilter", taskInfo.get("taskFilter"));
			returnObj.put("taskData", taskInfo.get("taskData"));
        	
            //상단카운트
//            modelMap.put("cnt", collabTodoSvc.myTaskCnt(params));
        	returnObj.put("result", Ajax.OK.result());
        } catch (NullPointerException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        } catch (Exception e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        }
        return returnObj;
    }

	//템플릿으로 저장화면
	@RequestMapping(value = "/CollabProjectTmplPopup.do")
	public ModelAndView collabProjectTmplPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabProjectTmplPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("callBackParam", StringUtil.replaceNull(request.getParameter("callBackParam"), "").replaceAll("&quot;", "\""));
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("prjName", request.getParameter("prjName"));
		return mav;
	}
	
	//템플릿 저장
	@RequestMapping(value = "/addProjectTmpl.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addProjectTmpl(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("tmplKind", request.getParameter("tmplKind"));
			reqMap.put("requestTitle", request.getParameter("requestTitle"));
			reqMap.put("requestRemark", request.getParameter("requestRemark"));
						
			CoviMap result = collabProjectSvc.addProjectTmpl(reqMap);
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	  //섹션삭제
  	@RequestMapping(value = "/getProjectMemberList.do", method = RequestMethod.POST)
  	public @ResponseBody CoviMap getProjectMemberList(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap result = new CoviMap();
  		
  		try {
  			CoviMap params = new CoviMap();
  			
  			String sortBy = request.getParameter("sortBy");
  			String sortKey = (sortBy != null)? sortBy.split(" ")[0] : "";
			String sortDirec = (sortBy != null)? sortBy.split(" ")[1] : "";
			String searchWord = request.getParameter("searchWord");
			
			// 자동 완성 파라미터
			if(request.getParameter("keyword") != null && !request.getParameter("keyword").equals("")){
				searchWord = request.getParameter("keyword");
			}
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
  			params.put("lang", SessionHelper.getSession("lang"));
  			params.put("prjSeq", request.getParameter("prjSeq"));
  			params.put("prjType", request.getParameter("prjType"));
  			params.put("objectType", request.getParameter("objectType"));
  			params.put("taskSeq", request.getParameter("taskSeq"));
  			params.put("thisTaskSeq", request.getParameter("thisTaskSeq"));
  			params.put("searchWord", searchWord);
  			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
			CoviMap resultObj = collabProjectSvc.getProjectMemberList(params);
			result.put("page", resultObj.get("page"));
  			result.put("list", resultObj.get("list"));
  			result.put("status", Return.SUCCESS);
  		} catch (ArrayIndexOutOfBoundsException e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		} catch (NullPointerException e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		} catch (Exception e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		}
  		
  		return result;
  	}
  	
  	//프로젝트 대상 태그로 선택 팝업
  	@RequestMapping(value = "/getProjectMemberTagList.do", method = RequestMethod.POST)
  	public @ResponseBody CoviMap getProjectMemberTagList(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap result = new CoviMap();
  		
  		try {
  			CoviMap params = new CoviMap();
  			
  			String sortBy = request.getParameter("sortBy");
  			String sortKey = (sortBy != null)? sortBy.split(" ")[0] : "";
			String sortDirec = (sortBy != null)? sortBy.split(" ")[1] : "";
			String searchWord = request.getParameter("searchWord");
			
			// 자동 완성 파라미터
			if(request.getParameter("keyword") != null && !request.getParameter("keyword").equals("")){
				searchWord = request.getParameter("keyword");
			}
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
  			params.put("lang", SessionHelper.getSession("lang"));
  			params.put("prjSeq", request.getParameter("prjSeq"));
  			params.put("searchWord", searchWord);
  			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
			if(!"".equals(StringUtil.replaceNull(request.getParameter("userCodes"), ""))) {
                String[] userCodesArray = request.getParameter("userCodes").split(",");
      			params.put("userCodesArray", userCodesArray);
            }
			
			CoviMap resultObj = collabProjectSvc.getProjectMemberTagList(params);
			result.put("page", resultObj.get("page"));
  			result.put("list", resultObj.get("list"));
  			result.put("status", Return.SUCCESS);
  		} catch (NullPointerException e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		} catch (ArrayIndexOutOfBoundsException e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		} catch (Exception e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		}
  		
  		return result;
  	}
  		
  	/**
     * @param params 내업무 리스트
     *               작성자 : jycho2
     * @return
     */
    @RequestMapping(value = "/getMyFile.do")
	public  @ResponseBody CoviMap getMyFile(HttpServletRequest request) throws Exception {
//        ModelMap modelMap = new ModelMap();
    	CoviMap returnObj = new CoviMap();
        try {
            //내 할일 목록
        	CoviMap reqMap = new CoviMap();

        	String searchOption = request.getParameter("searchOption");
        	
			reqMap.put("myTodo", request.getParameter("myTodo"));
        	reqMap.put("prjType", request.getParameter("prjType"));
        	reqMap.put("prjSeq", request.getParameter("prjSeq"));
        	reqMap.put("tagtype", request.getParameter("tagtype"));
        	reqMap.put("tagval", request.getParameter("tagval"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
//			reqMap.put("date1", ComUtils.removeMaskAll(request.getParameter("date1")));
//			reqMap.put("date2", ComUtils.removeMaskAll(request.getParameter("date2")));
//			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("searchOption", searchOption);
			
			if(searchOption != null) {
				reqMap.put("searchWord", request.getParameter("searchFile"));
			} else {
				reqMap.put("searchFile", request.getParameter("searchFile"));
			}
			
			reqMap.put("filterType", request.getParameter("filterType"));
			reqMap.put("objectType", request.getParameter("objectType"));
			reqMap.put("completMonth", request.getParameter("completMonth"));
			
			CoviMap resultMap = collabProjectSvc.getFileList(reqMap);
			
			CoviList fileList = (CoviList) resultMap.get("list");
			
			CoviList list = CoviSelectSet.coviSelectJSON(fileList
					, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,ThumWidth,ThumHeight,Description,FileRegistDate,FileRegisterCode,CompanyCode,authSave,PrjDesc,SectionName,TaskName,TaskSeq");
			
			returnObj.put("list", FileUtil.getFileTokenArray(list));
        	returnObj.put("result", Ajax.OK.result());
        } catch (ArrayIndexOutOfBoundsException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        } catch (NullPointerException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        } catch (Exception e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        	returnObj.put("result", Ajax.NO.result());
        }
        return returnObj;
    }

  	@RequestMapping(value = "/getCollabSurveyList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCollabSurveyList(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap result = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String sortBy = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy");
			String sortColumn = !sortBy.equals("") ? sortBy.split(" ")[0] : "";
			String sortDirection = !sortBy.equals("") ? sortBy.split(" ")[1] : "";
			
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("localCurrentDate", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
			params.put("prjSeq", request.getParameter("prjSeq"));
			params.put("myTodo", request.getParameter("myTodo"));
			params.put("tagtype", request.getParameter("tagtype"));
			params.put("tagval", StringUtil.replaceNull(request.getParameter("tagval"),"ProcSurvey"));
			params.put("searchSurvey", request.getParameter("searchSurvey"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultMap = collabProjectSvc.getCollabSurveyList(params);
			
			result.put("result", "ok");
			result.put("list", resultMap.get("list"));
			result.put("page", resultMap.get("page"));
			result.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}

  	/**
  	 * 결재업무 조회
  	 * @param request
  	 * @param response
  	 * @return
  	 * @throws Exception
  	 */
  	@RequestMapping(value = "/getCollabApprovalList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCollabApprovalList(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap result = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("localCurrentDate", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
			params.put("prjSeq", request.getParameter("prjSeq"));
			params.put("myTodo", request.getParameter("myTodo"));
			params.put("tagtype", request.getParameter("tagtype"));
			params.put("tagval", request.getParameter("tagval"));
			params.put("searchApproval",request.getParameter("searchApproval"));

			result.put("list", collabProjectSvc.getCollabApprovalList(params));
			result.put("status", Return.SUCCESS);
			result.put("result", Ajax.OK.result());
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			result.put("result", Ajax.NO.result());
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			result.put("result", Ajax.NO.result());
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}
  	
	// 일반 페이지 호출 처리 
	// ex> /mobile/board/list.do 
	//       => /mobile/board/list.mobile
	//       => /WEB-INF/views/mobile/board/list.jsp
	@RequestMapping(value = {"/mobile/popTaskMember.do"}, method = RequestMethod.GET)
	public ModelAndView getContent(HttpServletRequest request, HttpServletResponse response	) throws Exception {		
		String isPopup = StringUtil.replaceNull(request.getParameter("IsPopup"), "");
		String returnURL = "mobile/collab/popTaskMember"+ ((StringUtils.isNoneBlank(isPopup) && isPopup.equals("Y")) ? "" : ".mobile");
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("pageID", request.getParameter("id"));
		
		return mav;
	}
  	
  	@RequestMapping(value = "/getMemberList.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getMemberList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", Integer.parseInt(request.getParameter("prjSeq")));
			reqMap.put("prjType", request.getParameter("prjType"));			
			returnObj.put("memberList", collabProjectSvc.getMemberList(reqMap).get("memberList"));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;		
	}
	
	// 권한 체크
	public String checkProjectAdmin(List managerList, CoviMap prjData) {
		String userID = SessionHelper.getSession("USERID");
		if (prjData.getString("PrjType").equals("P")){
			if (managerList == null || managerList.size() == 0){
				if (userID.equals(prjData.get("RegisterCode"))) return "Y";
			}
			else{
				for (int i = 0; i < managerList.size(); i++){
					CoviMap member = (CoviMap) managerList.get(i);
					
					if(member.getString("UserCode").equals(userID)){
						return "Y";
					}
				}
			}	
		}
		else{
			if (userID.equals(prjData.get("ManagerCode"))) return "Y";
			
			java.util.StringTokenizer tmJob = new java.util.StringTokenizer(RedisDataUtil.getBaseConfig("CollabTeamLeader", SessionHelper.getSession("DN_ID")), "|");
			// 팀장 권한 확인
			while(tmJob.hasMoreTokens()) {
				String strJobTitle = tmJob.nextToken();
				if( SessionHelper.getSession("UR_JobTitleCode").equalsIgnoreCase(strJobTitle)) {
					return "Y";
				}
			}
		}
		return "N";
	}
  	
	// 프로젝트 멤업인지
	public String checkProjectMember(List mamberList, CoviMap prjData) {
		String userID = SessionHelper.getSession("USERID");
		
		if(mamberList != null) {
			for (int i = 0; i < mamberList.size(); i++){
				CoviMap member = (CoviMap) mamberList.get(i);
				
				if(member.getString("UserCode").equals(userID)){
					return "Y";
				}
			}
		}
		return "N";
	}
	
	//팀 마감
	@RequestMapping(value = "/closeProjectTeam.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap closeProjectTeam(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			String prjType = StringUtil.replaceNull(request.getParameter("prjType"), "");
			
			int cnt =0;
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			if (prjType.equals("P")){
				reqMap.put("prjSeq", request.getParameter("prjSeq"));
				cnt = collabProjectSvc.closeProject(reqMap);
			}else{
				reqMap.put("execYear", request.getParameter("execYear"));
				reqMap.put("groupID", request.getParameter("prjSeq"));
				cnt = collabProjectSvc.closeTeamExec(reqMap);
			}	
			result.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	
	
	//채팅방 go
	@RequestMapping(value = "/goProjectChat.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap goProjectChat(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			CoviMap data = collabProjectSvc.getProject(Integer.parseInt(request.getParameter("prjSeq")));
			CoviMap prjData = (CoviMap)data.get("prjData");

			CookiesUtil cUtil = new CookiesUtil();
			reqMap.put("name", prjData.get("PrjName"));
			List memberList = (List)data.get("memberList");
			List managerList = (List)data.get("managerList");
			CoviList eumMember = new CoviList();
			CoviList authMembers = new CoviList();
			for (int i =0; i < memberList.size(); i++ ){
				eumMember.add(((CoviMap)(memberList.get(i))).get("UserCode"));
			}
			for (int i =0; i < managerList.size(); i++ ){
				eumMember.add(((CoviMap)(managerList.get(i))).get("UserCode"));
				authMembers.add(((CoviMap)(managerList.get(i))).get("UserCode"));
			}
				
			reqMap.put("members", eumMember);//prjData.get("memberList"));
			reqMap.put("authMembers", authMembers);//prjData.get("memberList"));
			
			reqMap.put("CSJTK", cUtil.getCooiesValue(request));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			result = CollabUtils.createChannel(reqMap);

			if(result.get("status").equals( Return.SUCCESS)){
				reqMap.put("roomId", result.get("roomId"));
				reqMap.put("prjSeq", request.getParameter("prjSeq"));
			
				int cnt = collabProjectSvc.saveProjectChannel(reqMap);
				result.put("status", Return.SUCCESS);
				result.put("roomId", result.get("roomId"));
			}else{
				result.put("status", Return.FAIL);
				result.put("message", result.get("message"));
			}
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

	}
	
	//예시 화면
	@RequestMapping(value = "/CollabSamplePopup.do")
	public ModelAndView collabSamplePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabSamplePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("infoType", request.getParameter("infoType"));
		
		return mav;
	}
	
	//프로젝트 즐겨찾기
	@RequestMapping(value = "/saveProjectFavorite.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveProjectFavorite(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			
			int cnt ;
			if ("false".equals(request.getParameter("isFlag")))
				cnt = collabProjectSvc.addProjectFavorite(reqMap);
			else
				cnt = collabProjectSvc.deleteProjectFavorite(reqMap);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	//프로젝트별 알림설정 화면
	@RequestMapping(value = "/CollabProjectAlarmPopup.do")
	public ModelAndView collabProjectAlarmPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabProjectAlarmPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}
	
	//프로젝트별 알림설정 조회
	@RequestMapping(value = "/getGoingProject.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getGoingProject(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("USERID",SessionHelper.getSession("USERID"));
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("prjStatus", "P");	//진행중 프로젝트만 조회
			params.put("seColumn", request.getParameter("seColumn"));
			params.put("seValue", request.getParameter("seValue"));
			
			resultList= collabProjectSvc.getGoingProject(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
			
		return returnList;
	}
	
	//프로젝트별 알림설정 처리
	@RequestMapping(value = "/saveProjectAlarm.do")
	public  @ResponseBody CoviMap saveProjectAlarm(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			String[] prjSeqArr  = StringUtil.replaceNull(request.getParameter("prjSeqArr"), "").split(",");
			
			for (int i =0; i < prjSeqArr.length; i++ ){
				CoviMap reqMap = new CoviMap();
				reqMap.put("userCode", SessionHelper.getSession("USERID"));
				reqMap.put("USERID", SessionHelper.getSession("USERID"));
				reqMap.put("prjSeq", prjSeqArr[i]);
				
				int cnt = collabProjectSvc.saveProjectAlarm(reqMap);
			}
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

	}
	
	//프로젝트별 알림해제 처리
	@RequestMapping(value = "/cencelProjectAlarm.do")
	public  @ResponseBody CoviMap cencelProjectAlarm(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			String[] prjSeqArr  = StringUtil.replaceNull(request.getParameter("prjSeqArr"), "").split(",");
			
			for (int i =0; i < prjSeqArr.length; i++ ){
				CoviMap reqMap = new CoviMap();
				reqMap.put("userCode", SessionHelper.getSession("USERID"));
				reqMap.put("prjSeq", prjSeqArr[i]);
				
				int cnt = collabProjectSvc.cencelProjectAlarm(reqMap);
			}
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

	}
	
	//마감일 알림 상세 설정 화면
	@RequestMapping(value = "/CollabClosingAlarmPopup.do")
	public ModelAndView collabClosingAlarmPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabClosingAlarmPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}
	
	//마감일 알림 상세 설정 조회
	@RequestMapping(value = "/getClosingAlarm.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getClosingAlarm(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("USERID",SessionHelper.getSession("USERID"));
			
			resultList= collabProjectSvc.getClosingAlarm(params);
			
			returnList.put("data", resultList.get("confData"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			//returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
			
		return returnList;
	}
	
	//마감일 알림 상세 설정 처리
	@RequestMapping(value = "/saveClosingAlarm.do")
	public  @ResponseBody CoviMap saveClosingAlarm(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("UserCode", SessionHelper.getSession("USERID"));
			reqMap.put("deadlineAlarm", request.getParameter("deadlineAlarm"));
			reqMap.put("deadlineAlarmUse", request.getParameter("deadlineAlarmUse"));
			reqMap.put("repeatAlarm", request.getParameter("repeatAlarm"));
			reqMap.put("repeatAlarmUse", request.getParameter("repeatAlarmUse"));
			
			int cnt = collabProjectSvc.saveClosingAlarm(reqMap);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

	}
	
	/**
	 * 조회용 프로젝트 트리 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/CollabProjectSelPopup.do", method = RequestMethod.GET)
	public ModelAndView collabProjectSelPopup(HttpServletRequest request) throws Exception{
		String returnURL = "user/collab/CollabProjectSelPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	//관련결재 찾기 팝업 화면
	@RequestMapping(value = "/CollabApprovalListPopup.do")
	public ModelAndView collabApprovalListPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabApprovalListPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}


  	@RequestMapping(value = "/getSurveyInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap result = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("surveyID", request.getParameter("surveyID"));
			
			CoviMap resultMap = collabProjectSvc.getSurveyInfo(params);
			
			result.put("result", "ok");
			result.put("data", resultMap);
			result.put("status", Return.SUCCESS);
		}  catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}

  	/**
	 * 프로젝트의 섹션 조회
	 */
  	@RequestMapping(value = "/getProjectSection.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getProjectSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap result = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("prjSeq", request.getParameter("prjSeq"));
			params.put("prjType", request.getParameter("prjType"));
			
			List<CoviMap> sectionList = collabProjectSvc.getSectionList(params);
			
			result.put("status", Return.SUCCESS);
			result.put("sectionList", sectionList);
		}  catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}
  	
  //프로젝트 명 개인화 명칭 설정 화면
  	@RequestMapping(value = "/CollabProjectPersonalNamePopup.do")
  	public ModelAndView CollabProjectPersonalNamePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		String returnURL	= "user/collab/CollabProjectPersonalNamePopup";
  		ModelAndView mav	= new ModelAndView(returnURL);
  		String prjPersonalName  = StringUtil.replaceNull(request.getParameter("prjPersonalName"), "");
  		mav.addObject("callBackParam", StringUtil.replaceNull(request.getParameter("callBackParam"), "").replaceAll("&quot;", "\""));
  		mav.addObject("prjSeq", request.getParameter("prjSeq"));
  		mav.addObject("prjType", request.getParameter("prjType"));
  		mav.addObject("prjName", request.getParameter("prjName"));
  		mav.addObject("prjPersonalName", prjPersonalName);
  		mav.addObject("popupID", request.getParameter("popupID"));
  		return mav;
  	}
  	
  	//프로젝트명 개인화 명칭 추가
  	@RequestMapping(value = "/addPrjPersonalName.do", method = RequestMethod.POST)
  	public  @ResponseBody CoviMap addPrjPersonalName(HttpServletRequest request, HttpServletResponse response) throws Exception {
  		
  		CoviMap result = new CoviMap();
  		try {
  			CoviMap reqMap = new CoviMap();

  			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
  			reqMap.put("RegisterCode", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
  			reqMap.put("prjSeq", request.getParameter("prjSeq"));
  			reqMap.put("prjType", request.getParameter("prjType"));
  			reqMap.put("prjName", request.getParameter("prjName"));
  			reqMap.put("PrjPersonalName", request.getParameter("PrjPersonalName"));
  			
  			result = collabProjectSvc.addPrjPersonalName(reqMap);
  			
  		} catch (NullPointerException e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		} catch (Exception e) {
  			result.put("status", Return.FAIL);
  			LOGGER.error(e.getLocalizedMessage(), e);
  		}
  		return result;

  		
  	}
}