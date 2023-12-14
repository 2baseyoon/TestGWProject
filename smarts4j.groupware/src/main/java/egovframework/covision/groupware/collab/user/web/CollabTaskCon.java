package egovframework.covision.groupware.collab.user.web;

import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.covision.groupware.collab.util.CollabUtils;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.collab.user.service.impl.CollabTaskSvcImpl;
import egovframework.covision.groupware.collab.user.service.impl.CollabProjectSvcImpl;
import egovframework.covision.groupware.util.Ajax;
import egovframework.baseframework.util.json.JSONSerializer;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.springframework.web.multipart.MultipartFile;

import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.baseframework.util.json.JSONParser;

@Controller
@RequestMapping("collabTask")
public class CollabTaskCon {
	@Autowired
	private CollabTaskSvc collabTaskSvc;
	
	@Autowired
	private CollabProjectSvc collabProjectSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private EditorService editorSvc;

	private Logger LOGGER = LogManager.getLogger(CollabTaskCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private static final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");

	//타스트 상세 화면
	@RequestMapping(value = "/CollabTaskPopup.do")
	public ModelAndView collabTaskPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL		= "user/collab/CollabTaskPopup";
		ModelAndView mav		= new ModelAndView(returnURL);
		String userID			= SessionHelper.getSession("USERID");
		SimpleDateFormat format	= new SimpleDateFormat("yyyyMMdd");
		String todayStr			= format.format(new Date());
		
		String prjType = request.getParameter("prjType");
		String prjSeq = request.getParameter("prjSeq");
		
		if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
			CoviMap reqMap = new CoviMap();
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", userID);
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("prjType", prjType);
			reqMap.put("prjSeq", prjSeq);
			
			CoviMap data = collabTaskSvc.getTask(reqMap, true);
			if(data == null) return mav;
			
			List memberList = (List)data.get("memberList");
			List mapUserList = (List)data.get("mapUserList");
			CoviMap taskData = (CoviMap)data.get("taskData");
			String authSave = taskData.getString("authSave");
			//String authSave = checkAuthSave(memberList, (CoviMap)data.get("taskData"));
			String authTask = checkAuthTask(mapUserList, memberList, (CoviMap)data.get("taskData"));
			
			if (authTask.equals("Y") || SessionHelper.getSession("isCollabAdmin").equals("ADMIN")){
				mav.addObject("prjType", request.getParameter("prjType"));
				mav.addObject("prjSeq", request.getParameter("prjSeq"));
				mav.addObject("taskData", data.get("taskData"));
				mav.addObject("memberList", memberList);
				mav.addObject("subTaskList", data.get("subTaskList"));
				mav.addObject("userformList", data.get("userformList"));
				mav.addObject("mapList", data.get("mapList"));
				mav.addObject("tagList", data.get("tagList"));
				mav.addObject("fileList", data.get("fileList"));
				mav.addObject("linkList", data.get("linkList"));
				mav.addObject("USERID", userID);
				mav.addObject("authSave", authSave);
				mav.addObject("today", todayStr);
				mav.addObject("surveyComplete", data.get("surveyComplete"));
			}
		}

		return mav;
	}
	
	//타스트 수정 화면
	@RequestMapping(value = "/CollabTaskSavePopup.do")
	public ModelAndView collabTaskSavePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTaskSavePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
			CoviMap reqMap = new CoviMap();
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			CoviMap data = collabTaskSvc.getTask(reqMap);
			
			List memberList = (List)data.get("memberList");
			String authSave = checkAuthSave(memberList, (CoviMap)data.get("taskData"));
			mav.addObject("authSave", authSave);
			mav.addObject("tagList", data.get("tagList"));
			mav.addObject("USERID", reqMap.get("USERID"));

			List allFileList = (List)data.get("fileList");

			CoviList approvalList = new CoviList();
			CoviList fileList = new CoviList();
			for (int i = 0; i < allFileList.size(); i++){
				CoviMap file = (CoviMap) allFileList.get(i);
				if(file.getString("ObjectType").equals("APPROVAL")){
					approvalList.add(file);
				} else {
					fileList.add(file);
				}
			}
			mav.addObject("fileList", fileList);
			mav.addObject("approvalList", approvalList);
			mav.addObject("taskData", data.get("taskData"));
			mav.addObject("mapList",data.get("mapList"));
			mav.addObject("memberList", memberList);
			mav.addObject("userformList", data.get("userformList"));
			mav.addObject("linkList", data.get("linkList"));
		}else if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("") && ComUtils.nullToString(request.getParameter("prjType"),"").equals("P")){//프로젝트 인경우
			CoviMap data = collabProjectSvc.getProjectUserForm(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("userformList", data.get("list"));
		}
		
		if(StringUtil.isNotNull(request.getParameter("prjType"))) {
			mav.addObject("prjType", request.getParameter("prjType"));
			mav.addObject("prjSeq", request.getParameter("prjSeq"));
		}
		
		mav.addObject("isUseDescEditor", RedisDataUtil.getBaseConfig("isUseCollabDescEditor")); 	// 설명 에디터 사용 여부.
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));

		mav.addObject("prjName", java.net.URLDecoder.decode(request.getParameter("prjName"), "UTF-8"));
		mav.addObject("sectionName", java.net.URLDecoder.decode(request.getParameter("sectionName"), "UTF-8"));
		mav.addObject("bizSection", request.getParameter("bizSection"));
		mav.addObject("subject", request.getParameter("subject"));

		return mav;
	}
	
	//게시판 업무등록  화면
	@RequestMapping(value = "/CollabTaskSavePopupFromMessage.do")
	public ModelAndView CollabTaskSavePopupFromMessage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTaskSavePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
			CoviMap reqMap = new CoviMap();
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			CoviMap data = collabTaskSvc.getTask(reqMap);
			
			List memberList = (List)data.get("memberList");
			String authSave = checkAuthSave(memberList, (CoviMap)data.get("taskData"));
			mav.addObject("authSave", authSave);
			mav.addObject("tagList", data.get("tagList"));
			mav.addObject("USERID", reqMap.get("USERID"));

			List allFileList = (List)data.get("fileList");

			CoviList approvalList = new CoviList();
			CoviList fileList = new CoviList();
			for (int i = 0; i < allFileList.size(); i++){
				CoviMap file = (CoviMap) allFileList.get(i);
				if(file.getString("ObjectType").equals("APPROVAL")){
					approvalList.add(file);
				} else {
					fileList.add(file);
				}
			}
			mav.addObject("fileList", fileList);
			mav.addObject("approvalList", approvalList);
			mav.addObject("taskData", data.get("taskData"));
			mav.addObject("mapList",data.get("mapList"));
			mav.addObject("memberList", memberList);
			mav.addObject("userformList", data.get("userformList"));
			mav.addObject("linkList", data.get("linkList"));
		}else if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("") && ComUtils.nullToString(request.getParameter("prjType"),"").equals("P")){//프로젝트 인경우
			CoviMap data = collabProjectSvc.getProjectUserForm(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("userformList", data.get("list"));
		}
		
		if(StringUtil.isNotNull(request.getParameter("prjType"))) {
			mav.addObject("prjType", request.getParameter("prjType"));
			mav.addObject("prjSeq", request.getParameter("prjSeq"));
		}
		
		mav.addObject("isUseDescEditor", RedisDataUtil.getBaseConfig("isUseCollabDescEditor")); 	// 설명 에디터 사용 여부.
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));
		mav.addObject("prjName", java.net.URLDecoder.decode(request.getParameter("prjName"), "UTF-8"));
		mav.addObject("sectionName", java.net.URLDecoder.decode(request.getParameter("sectionName"), "UTF-8"));

		mav.addObject("bizSection", request.getParameter("bizSection"));
		mav.addObject("subject", request.getParameter("subject"));
		mav.addObject("fileInfo", request.getParameter("fileInfo"));
		
		String linkURL = new String(Base64.decodeBase64(request.getParameter("linkURL").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
		mav.addObject("linkURL", linkURL);
		
		return mav;
	}
	
	//전자결재 업무등록  화면
	@RequestMapping(value = "/CollabTaskSavePopupFromApproval.do")
	public ModelAndView CollabTaskSavePopupFromApproval(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTaskSavePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
			CoviMap reqMap = new CoviMap();
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			CoviMap data = collabTaskSvc.getTask(reqMap);
			
			List memberList = (List)data.get("memberList");
			String authSave = checkAuthSave(memberList, (CoviMap)data.get("taskData"));
			mav.addObject("authSave", authSave);
			mav.addObject("tagList", data.get("tagList"));
			mav.addObject("USERID", reqMap.get("USERID"));

			List allFileList = (List)data.get("fileList");

			CoviList approvalList = new CoviList();
			CoviList fileList = new CoviList();
			for (int i = 0; i < allFileList.size(); i++){
				CoviMap file = (CoviMap) allFileList.get(i);
				if(file.getString("ObjectType").equals("APPROVAL")){
					approvalList.add(file);
				} else {
					fileList.add(file);
				}
			}
			mav.addObject("fileList", fileList);
			mav.addObject("approvalList", approvalList);
			mav.addObject("taskData", data.get("taskData"));
			mav.addObject("mapList",data.get("mapList"));
			mav.addObject("memberList", memberList);
			mav.addObject("userformList", data.get("userformList"));
			mav.addObject("linkList", data.get("linkList"));
		}else if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("") && ComUtils.nullToString(request.getParameter("prjType"),"").equals("P")){//프로젝트 인경우
			CoviMap data = collabProjectSvc.getProjectUserForm(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("userformList", data.get("list"));
		}
		
		if(StringUtil.isNotNull(request.getParameter("prjType"))) {
			mav.addObject("prjType", request.getParameter("prjType"));
			mav.addObject("prjSeq", request.getParameter("prjSeq"));
		}
		
		mav.addObject("isUseDescEditor", RedisDataUtil.getBaseConfig("isUseCollabDescEditor")); 	// 설명 에디터 사용 여부.
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));
		mav.addObject("prjName", java.net.URLDecoder.decode(request.getParameter("prjName")));
		mav.addObject("sectionName", java.net.URLDecoder.decode(request.getParameter("sectionName")));

		mav.addObject("bizSection", request.getParameter("bizSection"));
		mav.addObject("subject", request.getParameter("subject"));
		mav.addObject("formInstanceID", request.getParameter("formInstanceID"));
		mav.addObject("fileInfo", request.getParameter("fileInfo"));
		
		return mav;
	}
	
	//메일 업무등록  화면
	@RequestMapping(value = "/CollabTaskSavePopupFromMail.do")
	public ModelAndView CollabTaskSavePopupFromMail(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTaskSavePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
			CoviMap reqMap = new CoviMap();
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			CoviMap data = collabTaskSvc.getTask(reqMap);
			
			List memberList = (List)data.get("memberList");
			String authSave = checkAuthSave(memberList, (CoviMap)data.get("taskData"));
			mav.addObject("authSave", authSave);
			mav.addObject("tagList", data.get("tagList"));
			mav.addObject("USERID", reqMap.get("USERID"));

			List allFileList = (List)data.get("fileList");

			CoviList approvalList = new CoviList();
			CoviList fileList = new CoviList();
			for (int i = 0; i < allFileList.size(); i++){
				CoviMap file = (CoviMap) allFileList.get(i);
				if(file.getString("ObjectType").equals("APPROVAL")){
					approvalList.add(file);
				} else {
					fileList.add(file);
				}
			}
			mav.addObject("fileList", fileList);
			mav.addObject("approvalList", approvalList);
			mav.addObject("taskData", data.get("taskData"));
			mav.addObject("mapList",data.get("mapList"));
			mav.addObject("memberList", memberList);
			mav.addObject("userformList", data.get("userformList"));
			mav.addObject("linkList", data.get("linkList"));
		}else if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("") && ComUtils.nullToString(request.getParameter("prjType"),"").equals("P")){//프로젝트 인경우
			CoviMap data = collabProjectSvc.getProjectUserForm(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("userformList", data.get("list"));
		}
		
		if(StringUtil.isNotNull(request.getParameter("prjType"))) {
			mav.addObject("prjType", request.getParameter("prjType"));
			mav.addObject("prjSeq", request.getParameter("prjSeq"));
		}
		
		mav.addObject("isUseDescEditor", RedisDataUtil.getBaseConfig("isUseCollabDescEditor")); 	// 설명 에디터 사용 여부.
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));
		mav.addObject("prjName", java.net.URLDecoder.decode(request.getParameter("prjName")));
		mav.addObject("sectionName", java.net.URLDecoder.decode(request.getParameter("sectionName")));

		mav.addObject("bizSection", request.getParameter("bizSection"));
		
		mav.addObject("uid", request.getParameter("uid"));
		mav.addObject("msgId", request.getParameter("msgId"));
		mav.addObject("boxName", request.getParameter("boxName"));
		mav.addObject("folderTy", request.getParameter("folderTy"));
		mav.addObject("userMail", request.getParameter("userMail"));

		return mav;
	}
	
	//결재파일 조회
	@RequestMapping(value = "/collabFileList.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap collabFileList(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
				CoviMap reqMap = new CoviMap();
				reqMap.put("ServiceType", "Collab");
				reqMap.put("ObjectID", Integer.parseInt(request.getParameter("taskSeq")));
				reqMap.put("MessageID", 0);
				reqMap.put("ObjectType", "APPROVAL");
				
				returnObj.put("fileList", fileSvc.selectAttachAll(reqMap));
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
		
	@RequestMapping(value = "/addTaskSimple.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTaskSimple(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();	
			CoviMap trgMap = new CoviMap();

			List trgMember = (List)params.get("trgMember");
			if (trgMember.size() == 0){
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
			}
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("prjType", params.get("prjType"));
			reqMap.put("sectionSeq", params.get("sectionSeq"));
			reqMap.put("taskName", params.get("taskName"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
			reqMap.put("taskStatus", "W");
			reqMap.put("progRate", "0");
			reqMap.put("parentKey", "0");
			reqMap.put("topParentKey", "0");
			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");
			CoviMap result = collabTaskSvc.addTask(reqMap, trgMember);
			
			returnObj.put("PrjSeq", params.get("prjSeq"));
			returnObj.put("PrjType", params.get("prjType"));
			returnObj.put("SectionSeq", params.get("sectionSeq"));
			returnObj.put("TaskName", params.get("taskName"));
			returnObj.put("TaskSeq", result.get("taskSeq"));
			returnObj.put("tmUser", "");
			returnObj.put("MemberCnt", "1");
			returnObj.put("CommentCnt", "0");
			returnObj.put("ProgRate", "0");
			returnObj.put("TaskStatus", "S");
			returnObj.put("ParenetKey", "0");
//			returnObj.put("taskName", request.getParameter("prjSeq"));
			returnObj.put("status", Return.SUCCESS);			

		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	@RequestMapping(value = "/addSubTaskSimple.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addSubTaskSimple(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();	
			CoviMap trgMap = new CoviMap();

			List trgMember = (List)params.get("trgMember");
			if (trgMember.size() == 0){
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
			}
//			List trgManager = new ArrayList<Object>();
//			List trgMember = new ArrayList<Object>();
//			trgManager.add(trgMap);
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
//			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("taskName", params.get("taskName"));
			reqMap.put("taskStatus", "W");
			reqMap.put("progRate", "0");
			reqMap.put("parentKey", params.get("taskSeq"));
			reqMap.put("topParentKey", params.get("topTaskSeq"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
//			reqMap.put("sortKey", taskSeq);
			
			reqMap.put("isMile", params.get("isMile"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("prjType", params.get("prjType"));
			reqMap.put("sectionSeq", params.get("sectionSeq"));
			
			CoviMap result = collabTaskSvc.addTask(reqMap, trgMember);
			returnObj.put("TaskName", params.get("taskName"));
			returnObj.put("TaskSeq", result.get("TaskSeq"));
			returnObj.put("MemberCnt", "1");
			returnObj.put("CommentCnt", "0");
			returnObj.put("ProgRate", "0");
			returnObj.put("TaskStatus", "S");
			returnObj.put("sectionSeq", params.get("sectionSeq"));
//			returnObj.put("ParentKey", "0");
			returnObj.put("status", Return.SUCCESS);
			
			CollabUtils.sendTaskMessage("TaskAdd", Integer.parseInt(String.valueOf(result.get("TaskSeq"))));
			
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
	

	@RequestMapping(value = "/changeProjectTaskStatus.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap changeProjectTaskStatus(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			String taskStatus = StringUtil.replaceNull(request.getParameter("taskStatus"));
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("prjType", request.getParameter("prjType"));
			if (taskStatus.equals("true")){
				reqMap.put("taskStatus","C");
			}
			else{
				reqMap.put("taskStatus","P");
			}	

			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");

			int cnt = collabTaskSvc.changeProjectTaskStatus(reqMap);
			//알림메세지 넣기
			CollabUtils.sendTaskMessage("TaskMod",  Integer.parseInt(request.getParameter("taskSeq")));
			
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
	@RequestMapping(value = "/changeProjectTaskOrder.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap changeProjectTaskOrder(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode",  params.get("userCode"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("prjType", params.get("prjType"));
			reqMap.put("myTodo", params.get("myTodo"));
			reqMap.put("mode", params.get("mode"));
			
			reqMap.put("sectionSeq", params.get("sectionSeq"));
			reqMap.put("taskSeq", params.get("taskSeq"));
			reqMap.put("workOrder", params.get("workOrder"));

			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");
			
			List ordTask = (List)params.get("ordTask");

			
			int cnt = collabTaskSvc.changeProjectTaskOrder(reqMap, ordTask );
			//알림메세지 넣기
			CollabUtils.sendTaskMessage("TaskMod", (Integer)params.get("taskSeq"));
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
	
	@RequestMapping(value = "/changeProjectTaskTodoOrder.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap changeProjectTaskTodoOrder(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("prjType", params.get("prjType"));
			reqMap.put("taskStatus", params.get("taskStatus"));
			reqMap.put("taskSeq", params.get("taskSeq"));
			reqMap.put("todoOrder", params.get("todoOrder"));

			List ordTask = (List)params.get("ordTask");

			
			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");
			int cnt = collabTaskSvc.changeProjectTaskTodoOrder(reqMap, ordTask );
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
	
	@RequestMapping(value = "/changeProjectTaskDate.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap changeProjectTaskDate(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("startDate", request.getParameter("startDate"));
			reqMap.put("endDate", request.getParameter("endDate"));
			reqMap.put("taskStatus", request.getParameter("taskStatus"));
			reqMap.put("TODO", request.getParameter("TODO"));

			int cnt = collabTaskSvc.changeProjectTaskDate(reqMap);
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
	
	@RequestMapping(value = "/addTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addProjectTask(@RequestParam(value = "file", required = false) List<MultipartFile> uploadfile
			, @RequestParam Map<String, Object> params
			, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("prjType", params.get("prjType"));
			reqMap.put("sectionSeq", params.get("sectionSeq"));
			reqMap.put("taskName", params.get("taskName"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
			reqMap.put("taskStatus", params.get("taskStatus"));
			reqMap.put("progRate", params.get("progRate"));
			reqMap.put("objectType", params.get("objectType"));
			
			reqMap.put("label", params.get("label"));
			reqMap.put("parentKey", "0");
			reqMap.put("topParentKey", "0");
			reqMap.put("workOrder", "0");
			reqMap.put("impLevel", params.get("impLvl")); 	// 22.03.02, 업무추가, 중요도 추가에 따른 파라미터 추가.

			// 업무설명(Remark) 에디터 추가.
			if (RedisDataUtil.getBaseConfig("isUseCollabDescEditor").equalsIgnoreCase("Y")) { 	// 업무설명 에디터로 입력.
				CoviMap editorParam = new CoviMap();
				editorParam.put("bodyHtml", params.get("body"));
				editorParam.put("imgInfo", params.get("bodyInlineImage"));
				editorParam.put("serviceType", "Collab");
				editorParam.put("backgroundImage", params.get("bodyBackgroundImage"));
				editorParam.put("frontStorageURL", params.get("frontStorageURL"));
				
				CoviMap editorInfo = editorSvc.getEscapeContent(editorParam);
				
				if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
					throw new Exception("InlineImage move BackStorage Error");
				}
				reqMap.put("remark", editorInfo.getString("BodyHtml"));
				reqMap.put("remarkText", params.get("bodyText"));
			} else {
				reqMap.put("remark", params.get("remark")); 	// case : textarea.
				reqMap.put("remarkText", params.get("remark"));
			}
			
			CoviMap trgMap = new CoviMap();
			JSONParser parser = new JSONParser();
			List trgMember = (List)parser.parse((String)params.get("trgMember"));
			if (trgMember == null || trgMember.size() == 0){
				trgMember = new ArrayList();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
			}
			
			List trgUserForm = (List)parser.parse((String)params.get("trgUserForm"));
			List tagArr = (List)parser.parse((String)params.get("tags"));
/*			String str = (String)params.get("tags");
			String[] tags = str.split(",");
			for (int i=0; i< tags.length; i++){
				
			}
*/			
			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");
			reqMap.put("fileInfos", params.get("fileInfos"));
			
			CoviMap result = collabTaskSvc.addTask(reqMap, trgMember, trgUserForm, uploadfile, tagArr);
			CollabUtils.sendTaskMessage("TaskAdd",result.getInt("taskSeq"));

			/* 신규 업무등록 시 태그 정보 추가.
			if ( !params.get("tags").equals("") ) {
				String str = (String)params.get("tags");
				String[] tmpStrArr = str.split(",");
				
				if ( tmpStrArr.length > 1 ) {
					int tagCnt = 0;
					for (int i=1;tmpStrArr.length>i; i++) {
						reqMap.put("TaskSeq", result.get("taskSeq"));
						reqMap.put("TagName", tmpStrArr[i]);
						tagCnt += collabTaskSvc.addTaskTag(reqMap);
					}
				}
			}*/

			// 관련업무 정보
			List linkTaskList = (List)parser.parse((String)params.get("linkTaskList"));
			// 관련업무 선행/후행 정리
			Map tmpMap1 = new HashMap();
			CoviMap tmpMap2 = new CoviMap();
			for (int i=0; linkTaskList.size()>i;i++) {
				tmpMap1 = (HashMap) linkTaskList.get(i);
				if (tmpMap1.get("linkF").equals("linkAF")) { 			// 선행업무
					tmpMap2.put("taskSeq", result.get("taskSeq"));
					tmpMap2.put("linkTaskSeq", tmpMap1.get("linkTask"));
					tmpMap2.put("USERID", reqMap.get("USERID"));
				} else if (tmpMap1.get("linkF").equals("linkBF")) { 	// 후행업무
					tmpMap2.put("taskSeq", tmpMap1.get("linkTask"));
					tmpMap2.put("linkTaskSeq", result.get("taskSeq"));
					tmpMap2.put("USERID", reqMap.get("USERID"));
				}
				int cnt = collabTaskSvc.addTaskLink(tmpMap2);
			}
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("taskSeq", result.get("taskSeq"));
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
	
	@RequestMapping(value = "/saveTask.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveTask(@RequestParam(value = "file", required = false)  MultipartFile[] uploadfile
			, @RequestParam Map<String, Object> params
			, HttpServletResponse response
			, HttpServletRequest request) throws Exception{
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			JSONParser parser = new JSONParser();
			List trgMember = null;
			List delFile = null;

			if (params.get("trgMember") != null){
				trgMember =  (List)parser.parse((String)params.get("trgMember"));
			}
			
			if (params.get("delFile") != null){
				delFile =  (List)parser.parse((String)params.get("delFile"));
			}

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", params.get("taskSeq"));
			reqMap.put("taskName", params.get("taskName"));
			reqMap.put("startDate", ComUtils.removeMaskAll(params.get("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(params.get("endDate")));
			reqMap.put("taskStatus", params.get("taskStatus"));
			reqMap.put("progRate", params.get("progRate"));
			reqMap.put("fileInfos", params.get("fileInfos"));
			
			reqMap.put("label", params.get("label"));
			reqMap.put("impLevel", params.get("impLvl")); 	// 22.03.02, 업무 수정. 중요도 추가에 따른 파라미터 추가.
			
			if (RedisDataUtil.getBaseConfig("isUseCollabDescEditor").equalsIgnoreCase("Y") && !ClientInfoHelper.isMobile(request)) { 	// 업무설명 에디터로 입력.
				CoviMap editorParam = new CoviMap();
				editorParam.put("bodyHtml", params.get("body"));
				editorParam.put("imgInfo", params.get("bodyInlineImage"));
				editorParam.put("serviceType", "Collab");
				editorParam.put("backgroundImage", params.get("bodyBackgroundImage"));
				editorParam.put("frontStorageURL", params.get("frontStorageURL"));

				CoviMap editorInfo = editorSvc.getEscapeContent(editorParam);
				
				if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
					throw new Exception("InlineImage move BackStorage Error");
				}
				reqMap.put("remark", editorInfo.getString("BodyHtml"));
				reqMap.put("remarkText", params.get("bodyText"));
			} else {
				reqMap.put("remark", params.get("remark")); 	// case : textarea
				reqMap.put("remarkText", params.get("remark"));
			}
			
			CoviMap trgMap = new CoviMap();
			
			List trgUserForm = (List)parser.parse((String)params.get("trgUserForm"));
			
			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");
			
			// 관련업무
			List linkTaskList = (List)parser.parse((String)params.get("linkTaskList"));
			Map tmpMap1 = new HashMap();
			CoviMap tmpMap2 = new CoviMap();
			for (int i=0; linkTaskList.size()>i;i++) {
				tmpMap1 = (HashMap) linkTaskList.get(i);
				if (tmpMap1.get("linkF").equals("linkAF")) { 	// 선행업무
					tmpMap2.put("taskSeq", params.get("taskSeq"));
					tmpMap2.put("linkTaskSeq", tmpMap1.get("linkTask"));
					tmpMap2.put("USERID", reqMap.get("USERID"));
				} else if (tmpMap1.get("linkF").equals("linkBF")) {   // 후행업무
					tmpMap2.put("taskSeq", tmpMap1.get("linkTask"));
                    tmpMap2.put("linkTaskSeq", params.get("taskSeq"));
                    tmpMap2.put("USERID", reqMap.get("USERID"));
				}
				int cnt = collabTaskSvc.addTaskLink(tmpMap2);
			}
			
			
			List tagArr = (List)parser.parse((String)params.get("tags"));

			CoviMap result = collabTaskSvc.saveTask(reqMap, trgMember, trgUserForm, uploadfile, delFile, tagArr);
			// 팀/프로젝트 삭제데이터
			List delPrjList = (List)parser.parse((String)params.get("delPrjList"));
			CoviMap delPrjAlloc = new CoviMap();
			for (int i=0; i< delPrjList.size(); i++) {
				CoviMap delPrjData = (CoviMap) delPrjList.get(i);
				delPrjAlloc.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				delPrjAlloc.put("USERID", SessionHelper.getSession("USERID"));
				delPrjAlloc.put("taskSeq", delPrjData.get("taskSeq"));
				delPrjAlloc.put("prjSeq", delPrjData.get("prjseq"));
				delPrjAlloc.put("prjType", delPrjData.get("prjtype"));
				delPrjAlloc.put("prjName", delPrjData.get("prjname"));
				int cnt = collabTaskSvc.deleteAllocProject(delPrjAlloc);
			}
			// 팀/프로젝트 추가데이터
			List addPrjList = (List)parser.parse((String)params.get("addPrjList"));
			CoviMap prjAlloc = new CoviMap();
			for (int i=0; i<addPrjList.size(); i++) {
				CoviMap prjData = (CoviMap) addPrjList.get(i);
				prjAlloc.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				prjAlloc.put("USERID", SessionHelper.getSession("USERID"));
				prjAlloc.put("taskSeq", prjData.get("taskSeq"));
				prjAlloc.put("prjSeq", prjData.get("PrjSeq"));
				prjAlloc.put("prjType", prjData.get("PrjType"));
				prjAlloc.put("sectionSeq", prjData.get("SectionSeq"));
				prjAlloc.put("isExport", prjData.get("isExport"));
				prjAlloc.put("prjName", prjData.get("PrjName"));
				int cnt = collabTaskSvc.addAllocProject(prjAlloc);
			}

			returnObj.put("status", Return.SUCCESS);
			returnObj.put("taskData", reqMap);
			returnObj.put("trgMember", trgMember);
			
			/*담당차 추가시
			//추가 담당자만 추리기 위해
			CoviMap data = collabTaskSvc.getTask(reqMap);
			if (trgMember != null && trgMember.size()>0){
				StringBuffer sbTarget = new StringBuffer();
				List<?> bfMemberList =(List)data.get("memberList");
		        for (int i=0; i < trgMember.size(); i++){
		        	boolean bFind = false;
					String newUserId = (String)((HashMap)trgMember.get(i)).get("userCode");
					
					for (int j =0; j < bfMemberList.size(); j++ ){
						if (newUserId.equals((String)((CoviMap)(bfMemberList.get(j))).getString("UserCode")))
						{
							bFind = true;
							break;
						}
					}
					if (bFind == false){
			        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
			        	sbTarget.append(newUserId); 
					}	
		        }    
		        
		        if (!sbTarget.toString().equals("")){
			        CoviMap msgMap = new CoviMap();
			        msgMap.put("taskSeq", params.get("taskSeq"));
			        msgMap.put("taskName",params.get("taskName"));
					msgMap.put("prjName", params.get("prjName"));
					msgMap.put("sectionName", params.get("sectionName"));
			        CollabUtils.sendMessage("TaskAddMember", sbTarget.toString(), msgMap);
		        } 
			}*/

			CollabUtils.sendTaskMessage("TaskMod",Integer.parseInt((String)params.get("taskSeq")));
			//관련업무
			//관련결재
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NumberFormatException e) {
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
	@RequestMapping(value = "/deleteTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTask(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			String parentKey = StringUtil.replaceNull(request.getParameter("parentKey"), "");
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("objectID", request.getParameter("objectID"));
			reqMap.put("objectType", request.getParameter("objectType"));
			
			if (parentKey.equals("0")){
				reqMap.put("isTopTask","Y");
			}
			else{
				reqMap.put("isTopTask","N");
			}	
			int cnt = collabTaskSvc.deleteTask(reqMap);
			
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
	
	@RequestMapping(value = "/addTaskFile.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTaskFile(MultipartHttpServletRequest  mtfRequest	, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
//			reqMap.put("taskSeq", params.get("taskSeq"));
			String taskSeq = mtfRequest.getParameter("taskSeq");
			
//			CoviMap result = collabTaskSvc.addTask(reqMap, trgMember, uploadfile);
			List<MultipartFile> mockedFileList = mtfRequest.getFiles("file");
			CoviMap filesParams = new CoviMap();
			filesParams.put("fileCnt", mockedFileList.size());
			filesParams.put("ServiceType", CollabTaskSvcImpl.fileSvcType);
			
			filesParams.put("MessageID", taskSeq);
			filesParams.put("ObjectID", taskSeq);
			filesParams.put("ObjectType", "Collab");
			CoviList fileInfos = new CoviList();
			/*List<MultipartFile> mockedFileList = new ArrayList<>();
			
			for (MultipartFile mf : fileList) {
				mockedFileList.add(mf);
			}*/	
			CoviList fileObj = fileSvc.uploadToBack(fileInfos, mockedFileList, CollabTaskSvcImpl.fileSvcPath, CollabTaskSvcImpl.fileSvcType, taskSeq, "NONE", "0", false);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		 }catch (IOException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	//타스크 파일 삭제
	@RequestMapping(value = "/deleteTaskFile.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTaskFile(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			fileSvc.deleteFileByID(request.getParameter("fileID"), true);
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

	
	//초대
	@RequestMapping(value = "/addTaskInvite.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTaskInvite(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			//List dataList = (List)params.get("dataList");
			List trgMember = (List)params.get("trgMember");
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", params.get("taskSeq"));
			reqMap.put("memberList", trgMember);

			int result= collabTaskSvc.addTaskInvite(reqMap);
			
			StringBuffer sbTarget = new StringBuffer();
	        for (int i=0; i < trgMember.size(); i++){
	        	if (i>0) sbTarget.append(";");
	        	
	        	sbTarget.append((String)((HashMap)trgMember.get(i)).get("userCode")); 
	        }    
	        
	        CoviMap msgMap = new CoviMap();
			CoviMap data = collabTaskSvc.getTask(reqMap);
			CoviMap taskData =(CoviMap)data.get("taskData");
			List mapList = (List)data.get("mapList");

	        msgMap.put("PopupURL","/groupware/collabTask/CollabTaskPopup.do?taskSeq="+ params.get("taskSeq")+"&topTaskSeq="+  params.get("taskSeq"));
	        msgMap.put("GotoURL","/groupware/collabTask/CollabTaskPopup.do?taskSeq="+  params.get("taskSeq")+"&topTaskSeq="+  params.get("taskSeq"));
	        msgMap.put("taskName",taskData.get("TaskName"));
			if (mapList.size()>0){
				CoviMap mapData = (CoviMap )mapList.get(0);
				msgMap.put("prjName", mapData.get("PrjName"));
				msgMap.put("sectionName", mapData.get("SectionName"));
			}	
			
	        CollabUtils.sendMessage("TaskAddMember", sbTarget.toString(), msgMap);

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
	
	//참가자 삭제
	@RequestMapping(value = "/deleteTaskMemeber.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTaskMemeber(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("userCode", request.getParameter("UserCode"));

			int result = collabTaskSvc.deleteTaskMember(reqMap);
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
	@RequestMapping(value = "/CollabProjectAllocPopup.do", method = RequestMethod.GET)
	public ModelAndView collabProjectAllocPopup(HttpServletRequest request) throws Exception{
		String returnURL = "user/collab/CollabProjectAllocPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	
	//비할당 프로젝트 조회
	@RequestMapping(value = "/getNoAllocProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getNoAllocProject(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("isSaas", isSaaS);
			reqMap.put("callbackFunc", request.getParameter("callbackFunc"));
			
			returnObj.put("list",  collabTaskSvc.getNoAllocProject(reqMap));
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;		
	}//
	
	//프로젝트 할당
	@RequestMapping(value = "/addAllocProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addAllocProject(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("prjSeq", request.getParameter("PrjSeq"));
			reqMap.put("prjType", request.getParameter("PrjType"));
			reqMap.put("sectionSeq", request.getParameter("SectionSeq"));
			reqMap.put("isExport", request.getParameter("isExport"));
			reqMap.put("prjName", request.getParameter("PrjName"));
			
			int cnt = collabTaskSvc.addAllocProject(reqMap);
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
	
	//프로젝트 할당-제거
	@RequestMapping(value = "/deleteAllocProject.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteAllocProject(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("prjSeq", request.getParameter("prjseq"));
			reqMap.put("prjType", request.getParameter("prjtype"));
			reqMap.put("prjName", request.getParameter("prjname"));

			int cnt = collabTaskSvc.deleteAllocProject(reqMap);
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
	
	//업무즐겨찾기
	@RequestMapping(value = "/saveTaskFavorite.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveTaskFavorite(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			int cnt ;
			if ("false".equals(request.getParameter("isFlag"))){
				cnt = collabTaskSvc.addTaskFavorite(reqMap);
			}
			else
				cnt = collabTaskSvc.deleteTaskFavorite(reqMap);

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
	
	//프로젝트 마일스톤
	@RequestMapping(value = "/saveTaskMile.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveTaskMile(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			String isMile = StringUtil.replaceNull(request.getParameter("isMile"), "");
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("isMile", request.getParameter("isMile"));
			
			int cnt = collabTaskSvc.saveTaskMile(reqMap);

			if (isMile.equals("Y")){
				CollabUtils.sendMileMessage("TaskMile", Integer.parseInt((String)request.getParameter("taskSeq")));
			}
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NumberFormatException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}

	
	//태그 추가 화면
	@RequestMapping(value = "/CollabTaskTagPopup.do")
	public ModelAndView collabTaskTagPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTaskTagPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("taskSeq", request.getParameter("taskSeq"));
		mav.addObject("taskName", request.getParameter("taskName"));
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		return mav;
	}
	
	//태그 추가
	@RequestMapping(value = "/addTaskTag.do", method = RequestMethod.POST)
	public @ResponseBody    ModelMap  addTaskTag (HttpServletRequest request)throws Exception  {
		 ModelMap modelMap = new ModelMap();
		try {

        	CoviMap cmap = new CoviMap();
        	cmap.put("taskSeq",request.getParameter("taskSeq"));
        	cmap.put("taskTagList",new String[] {request.getParameter("tagName")});
        	cmap.put("USERID", SessionHelper.getSession("USERID"));
        	int cnt = collabTaskSvc.addTaskTag(cmap);
            modelMap.put("tagData", cmap);

            modelMap.put("result", Ajax.OK.result());
        } catch (NullPointerException e) {
            modelMap.addAttribute("result", Ajax.NO.result());
        } catch (Exception e) {
            modelMap.addAttribute("result", Ajax.NO.result());
        }
		return modelMap;
	}		
	
	//tag-제거
	@RequestMapping(value = "/deleteTaskTag.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTaskTag(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("tagID", request.getParameter("tagID"));

			int cnt = collabTaskSvc.deleteTaskTag(reqMap);
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
	
	//업쿠 복사 화면
	@RequestMapping(value = "/CollabTaskCopyPopup.do")
	public ModelAndView collabTaskCopyPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTaskCopyPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("taskSeq", request.getParameter("taskSeq"));
		mav.addObject("objId", request.getParameter("objId"));
		return mav;
	}
	
	//복사
	@RequestMapping(value = "/copyTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap copyTask(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("orgTaskSeq", request.getParameter("orgTaskSeq"));
			reqMap.put("taskName", request.getParameter("taskName"));
			
			int cnt = collabTaskSvc.copyTask(reqMap);
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
	
	//링크 추가
	@RequestMapping(value = "/addTaskLink.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTaskLink(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("linkTaskSeq", request.getParameter("linkTaskSeq"));
			reqMap.put("linkTaskName", request.getParameter("linkTaskName"));

			int cnt = collabTaskSvc.addTaskLink(reqMap);
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
	
	//링크 삭제
	@RequestMapping(value = "/deleteTaskLink.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTaskLink(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			reqMap.put("linkTaskName", request.getParameter("linkTaskName"));

			int cnt = collabTaskSvc.deleteTaskLink(reqMap);
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

	//task 상세 정보 가져오기
	@RequestMapping(value = "/getCollabTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getCollabTask(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			CoviMap data = collabTaskSvc.getTask(reqMap);
			List memberList = (List)data.get("memberList");
			String authSave = checkAuthSave(memberList, (CoviMap)data.get("taskData"));
			
			returnObj.put("taskData", data.get("taskData"));
			returnObj.put("memberList", memberList);
			returnObj.put("subTaskList", data.get("subTaskList"));
			returnObj.put("userformList", data.get("userformList"));
			returnObj.put("mapList", data.get("mapList"));
			returnObj.put("tagList", data.get("tagList"));
			returnObj.put("fileList", data.get("fileList"));
			returnObj.put("USERID", SessionHelper.getSession("USERID"));
			returnObj.put("authSave", authSave);
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
	
	//task 하위 정보 가져오기
	@RequestMapping(value = "/getSubTaskList.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getSubTaskList(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			
			returnObj.put("taskSubData", collabTaskSvc.getSubTask(reqMap));
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
		
		
	// task map 정보 가져오기
	@RequestMapping(value = "/getCollabTaskMapBySchedule.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCollabTaskMapBySchedule(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("objectID", request.getParameter("objectID"));
			params.put("objectType", "EVENT");
			
			CoviMap taskMap = collabTaskSvc.getTaskMapBySchedule(params);
			
			returnObj.put("taskMap", taskMap);
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
	
	@RequestMapping(value = "/getTaskMemberList.do", method = RequestMethod.POST)
  	public  @ResponseBody CoviMap getSubMemberList(@RequestParam Map<String, Object> params,HttpServletRequest request, HttpServletResponse response) throws Exception {
  		CoviMap returnObj = new CoviMap();
  		try {
  			CoviMap reqMap = new CoviMap();
  			
  			reqMap.put("userCode", SessionHelper.getSession("USERID"));
  			reqMap.put("lang", SessionHelper.getSession("lang"));
  			reqMap.put("taskSeq", params.get("taskSeq").toString() );
  			
  			
  			/*reqMap.put("userCode", SessionHelper.getSession("USERID"));
  			reqMap.put("lang", SessionHelper.getSession("lang"));
  			reqMap.put("USERID", SessionHelper.getSession("USERID"));
  			reqMap.put("prjSeq", Integer.parseInt(request.getParameter("prjSeq")));
  			reqMap.put("prjType", request.getParameter("prjType"));			
  			returnObj.put("memberList", collabProjectSvc.getMemberList(reqMap).get("memberList"));*/
  			returnObj.put("memberList", collabTaskSvc.selectTaskMemberList(reqMap));
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
	
	public void addTaskByApi(CoviMap params, CoviMap reqMap, List<CoviMap> tgtMembers, List<MultipartFile> mockedFileList)throws Exception {
		try {
		// 업무등록
			String objectType=reqMap.get("objectType")==null ?"APPROVAL":reqMap.getString("objectType");

			String taskSeq = ""; 
			// 사용자요청이 아니므로 Session 값이 없음.
			String fileSvcPath = "";
			String fileSvcType = "";
			String refId = "";
			if (params.get("svcType") != null && params.getString("svcType").equals("PROJECT")){		//프로젝트의 연결문서
				fileSvcPath = CollabProjectSvcImpl.fileSvcPath;
				fileSvcType = CollabProjectSvcImpl.fileSvcType;
				refId = params.getString("prjSeq");
			}else{
				if (params.get("taskSeq") != null && !params.getString("taskSeq").equals("") && !params.getString("taskSeq").equals("0")){	//taskseq값이 있으면 첨부파일 등록만 처리
					taskSeq = params.getString("taskSeq");
				}else{	
					if(!"Y".equals(params.getString("allowDup"))) {
						CoviMap delParam = new CoviMap();
						delParam.put("prjSeq", params.getString("prjSeq"));
						delParam.put("prjType", params.get("prjType"));
						delParam.put("objectType", objectType);
						delParam.put("objectID", params.getString("objectID"));
						
						List<CoviMap> taskSeqList = collabTaskSvc.getTaskSeqListByProjectObj(reqMap);
						for(CoviMap taskMap : taskSeqList) {
							CoviMap deleteMap = new CoviMap();
							taskSeq = taskMap.getString("taskSeq");
							deleteMap.put("taskSeq", taskSeq);
							deleteMap.put("isTopTask", ",Y");
							collabTaskSvc.deleteTask(deleteMap);
						}
					}
					
					//외부연동은 완료료 세팅
					reqMap.put("startDate", ComUtils.GetLocalCurrentDate("yyyyMMdd"));
					reqMap.put("endDate", ComUtils.GetLocalCurrentDate("yyyyMMdd"));
					reqMap.put("taskStatus", "C");
					reqMap.put("progRate", "100");
					reqMap.put("taskName", reqMap.getString("taskName").getBytes(StandardCharsets.UTF_8).length>150?ComUtils.substringBytes(reqMap.getString("taskName"), 145)+"...":reqMap.getString("taskName"));
					CoviMap result = collabTaskSvc.addTask(reqMap, tgtMembers);
					
					// File Attach
					taskSeq = result.getString("taskSeq");
				}	
				
				fileSvcPath = CollabTaskSvcImpl.fileSvcPath;
				fileSvcType = CollabTaskSvcImpl.fileSvcType;
				refId = taskSeq; 
			}	
			RequestContextHolder.getRequestAttributes().setAttribute("DN_Code", (String)reqMap.get("DN_Code"), RequestAttributes.SCOPE_REQUEST);
			fileSvc.uploadToBack(null, mockedFileList, fileSvcPath, fileSvcType, refId, objectType, "0", false);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
			throw new NullPointerException();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
			throw new IOException(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
			throw new Exception(e);
		} 			
	}
	
	/**
	 * 외부 등록 (결재 ... ) (호출하는곳 없음)
	 * @param params
	 * @param request
	 * @return
	 * @throws Exception
	 * @author hgsong
	 * @since 6/15/21
	 */
	@RequestMapping(value = "/addTaskApi.do", method = RequestMethod.POST)
	public void addTaskApi(HttpServletRequest request, HttpServletResponse response, @RequestBody CoviMap params) throws Exception {
		try {
			CoviMap reqMap = new CoviMap();
			List<CoviMap> tgtMembers = new ArrayList<CoviMap>();
			CoviList trgMember = params.getJSONArray("trgMember");
			
			for(int i = 0; i < trgMember.size(); i++) {
				CoviMap jo = trgMember.getJSONObject(i);
				CoviMap trgMapTmp = new CoviMap();
				trgMapTmp.put("userCode", jo.get("userCode"));
				tgtMembers.add(trgMapTmp);
			}
			
			Set<Entry<String, Object>> entrySet = params.entrySet();
			for(Entry<String, Object> entry : entrySet) {
				if(!"trgMember".equals(entry.getKey())) {
					reqMap.put(entry.getKey(), entry.getValue());
				}
			}
			
			// File Info Base64 decoding.
			CoviList fileInfoList = null;
			if(!params.getString("DocAttach").equals("")){
				CoviMap docAttach = CoviMap.fromObject(JSONSerializer.toJSON(new String(Base64.decodeBase64(params.getString("DocAttach")), StandardCharsets.UTF_8)));
				Object attObj = docAttach.get("FileInfos");
				if(attObj instanceof CoviMap){
					CoviMap fileInfo = (CoviMap) attObj;
					fileInfoList = new CoviList();
					fileInfoList.add(fileInfo);
					params.put("fileInfoList", fileInfoList);
				}else if(attObj instanceof CoviList){
					fileInfoList = (CoviList) attObj;
				}
			}
			
			
			//////////////////////////// 첨부파일 데이터 가공 처리.
			List<MultipartFile> mockedFileList = new ArrayList<>();
			//String apvAttPath = RedisDataUtil.getBaseConfig("ApprovalAttach_SavePath");
			CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileInfoList); // 기존 파일의 storage정보조회 (fileid 필수)
			
			AwsS3 awsS3 = AwsS3.getInstance();
			if(fileInfoList != null && fileInfoList.size() > 0){
				String companyCode = params.getString("DN_Code");
				for(int i = 0; i < fileInfoList.size(); i++){
					CoviMap fileInfo = fileInfoList.getJSONObject(i);
					String fileID = fileInfo.getString("FileID");
					CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID); // 오류발생을 위해 fileid 유무 체크 안함(필수값이므로 없는시스템은 추가 필요)
					companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? companyCode : fileStorageInfo.optString("CompanyCode");
					//String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + fileInfo.getString("FilePath") + fileInfo.getString("SavedName");
					//if("APPROVAL".equals(reqMap.getString("objectType"))) {
					//	filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + apvAttPath + fileInfo.getString("FilePath") + fileInfo.getString("SavedName");
					//}
					String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
					
					if(awsS3.getS3Active(companyCode)){
						AwsS3Data downFile = awsS3.downData(filePath);
						MultipartFile multipartFile = new MockMultipartFile(downFile.getName(), downFile.getContentStream());// 최종 MultipartFile.transferTo 처리시 close 처리함.
						mockedFileList.add(multipartFile);
					}else {
						File file = new File(filePath);
						DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, fileInfo.getString("FileName"), (int) file.length() , file.getParentFile());
						try (InputStream input = new FileInputStream(file); OutputStream os = fileItem.getOutputStream();){
							IOUtils.copy(input, os);

							MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
							mockedFileList.add(multipartFile);
						}
					}
				}
			}
			File file = new File(params.getString("pdfPath"));
			if(file.exists()) {
				DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, params.getString("taskName") + ".pdf", (int) file.length() , file.getParentFile());
				try (InputStream input = new FileInputStream(file);
						OutputStream os = fileItem.getOutputStream();){
					IOUtils.copy(input, os);
					MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
					mockedFileList.add(0, multipartFile);
				}
			}
			
			if(!FileUtil.isEnableExtention(mockedFileList)){
				throw new SecurityException("Contains not allowd file extension.");
			}

			addTaskByApi(params,  reqMap, tgtMembers,  mockedFileList);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
			throw new NullPointerException();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
			throw new IOException(e);
		}  catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
			throw new Exception(e);
		}		
	}
	
	/**
	 * 외부 등록 (메일 ... )
	 * @param params
	 * @param request
	 * @return
	 * @throws Exception
	 * @author sunnyhwang
	 * @since 9/24/21
	 */
	@RequestMapping(value = "/addMailTaskApi.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addMailTaskApi(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();	
			CoviMap trgMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("taskName", request.getParameter("taskName"));
			reqMap.put("objectType", "MAIL");
			reqMap.put("taskStatus", "C");
			reqMap.put("progRate", "0");
			reqMap.put("parentKey", "0");
			reqMap.put("topParentKey", "0");
			
			List trgMember = new ArrayList<>();
			trgMap.put("userCode", SessionHelper.getSession("USERID"));
			trgMember.add(trgMap);

        	String frontPath = FileUtil.getFrontPath() ;//+ File.separatorChar + SessionHelper.getSession("DN_Code");
        	//230517 filename -> filepath로 경로 설정
        	String fullFrontFilePath = frontPath + File.separatorChar + request.getParameter("filePath");
			File file = new File(FileUtil.checkTraversalCharacter(fullFrontFilePath));
			
			CoviMap params = new CoviMap();
			params.put("allowDup", request.getParameter("allowDup"));
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			try(FileInputStream ins = new FileInputStream(file);){
				MultipartFile multipartFile = new MockMultipartFile(request.getParameter("fileName"), file.getName(), Files.probeContentType(Paths.get(fullFrontFilePath)), IOUtils.toByteArray(ins));
				mf.add(multipartFile);
			}			
			
			addTaskByApi(params,  reqMap, trgMember,  mf);
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch (IOException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		}
		
		return returnObj;
	}	
	
	// 권한 체크
	public String checkAuthSave(List memberList, CoviMap taskData) {
		String userID = SessionHelper.getSession("USERID");
		if (userID.equals(taskData.get("RegisterCode"))) return "Y";
		
		for (int i = 0; i < memberList.size(); i++){
			CoviMap member = (CoviMap) memberList.get(i);
			
			if(member.getString("UserCode").equals(userID)){
				return "Y";
			}
		}
		
		return "N";
	}
		
	// 업무 권한  체크
	public String checkAuthTask(List mapUserList, List memberList, CoviMap taskData) {
		String userID = SessionHelper.getSession("USERID");
		if (checkAuthSave(memberList, taskData).equals("Y")) return "Y";
		else{
			if (mapUserList == null ) return "N";
			else{
				for (int i = 0; i < mapUserList.size(); i++){
					CoviMap mapUser = (CoviMap) mapUserList.get(i);
					
					if(mapUser.getString("UserCode").equals(userID)){
						return "Y";
					}
				}
			}	
		}
		return "N";
	}

	// 섹션 조회(업무추가/수정 > 관련업무 팝업 화면)
	@RequestMapping(value = "/CollabTaskLinkPopup.do")
	public ModelAndView collabTaskLinkPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "user/collab/CollabTaskLinkPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		// 해당 프로젝트의 섹션 조회 
		String strPrjType = StringUtil.replaceNull(request.getParameter("pType"), "");
		String strPrjSeq = StringUtil.replaceNull(request.getParameter("pSeq"), "");
		String strTaskSeq = StringUtil.replaceNull(request.getParameter("pTaskSeq"), "");
		
		CoviMap reqMap = new CoviMap();
		reqMap.put("prjType", strPrjType);
		reqMap.put("prjSeq", strPrjSeq);
		
		java.util.ArrayList<Object> filterList = null;
		
		if (!strPrjType.equals("M")) {
			// 팀/프로젝트 업무일 경우
			List<CoviMap> sectionList  = collabProjectSvc.getSectionList(reqMap);
			mav.addObject("sectionList", sectionList);
			mav.addObject("pType", strPrjType);
			mav.addObject("pSeq", strPrjSeq);
		} else {
			// 내업무 경우.
			mav.addObject("sectionList", "");
			mav.addObject("pType", "M");
			mav.addObject("pSeq", "");
		}
		mav.addObject("pTaskSeq", strTaskSeq);
		
		return mav;
	}
	
	// 관련업무에 연결 필요한 업무 리스트 가져오기
	@RequestMapping(value = "/getTaskLink.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTaskLink(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap reqMap = new CoviMap();
		reqMap.put("prjSeq", request.getParameter("prjSeq"));
		reqMap.put("prjType", request.getParameter("prjType"));
		reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
		reqMap.put("searchText", request.getParameter("searchText"));
		reqMap.put("pageNo", request.getParameter("pageNo"));
		reqMap.put("pageSize", request.getParameter("pageSize"));
		reqMap.put("excludeTaskSeq", request.getParameter("excludeTaskSeq")); 	// 선/후행 업무 조회 시, 자신의 업무를 제외.
		
		try {
			CoviMap resultList = new CoviMap();
			
			if (reqMap.get("prjType").equals("M")) {
				reqMap.put("userCode", SessionHelper.getSession("USERID"));
				reqMap.put("taskStatus", request.getParameter("taskStatus"));
			}
			resultList = collabTaskSvc.getTaskLink(reqMap);
			
			returnObj.put("list", resultList.get("list"));
			returnObj.put("page", resultList.get("page"));
			returnObj.put("result", "ok");
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		}
		return returnObj;
	}
	
	@RequestMapping(value = "/CollabGantTaskLinkPopup.do", method = RequestMethod.GET)
	public ModelAndView CollabGantTaskLinkPopup(HttpServletRequest request) throws Exception{
		String returnURL = "user/collab/CollabGantTaskLinkPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		String myTodo = request.getParameter("myTodo"); // 관련업무 팝업을 띄우기 위해서 필요
		String taskSeq = request.getParameter("taskSeq");
		String taskSeqStr = request.getParameter("taskSeqList");
		String taskNameStr = request.getParameter("taskNameList");
		String linkedTaskSeq = request.getParameter("linkedTaskSeq");
		String linkedTaskName = request.getParameter("linkedTaskName");
		String prjSeq = ""; // 관련업무 팝업을 띄우기 위해서 필요
		String prjType = ""; // 관련업무 팝업을 띄우기 위해서 필요
		
		if("Y".equals(myTodo)) { // 내 업무일 경우,
			prjType = "M";
		} else { // 내 업무가 아닌 경우
			prjSeq = request.getParameter("prjSeq");
			prjType = request.getParameter("prjType");
		}
		
		mav.addObject("prjSeq", prjSeq);
		mav.addObject("prjType", prjType);
		mav.addObject("taskSeq", taskSeq);
		mav.addObject("taskSeqStr", taskSeqStr);
		mav.addObject("taskNameStr", taskNameStr);
		mav.addObject("linkedTaskSeq", linkedTaskSeq);
		mav.addObject("linkedTaskName", linkedTaskName);
		
		return mav;
	}
}
