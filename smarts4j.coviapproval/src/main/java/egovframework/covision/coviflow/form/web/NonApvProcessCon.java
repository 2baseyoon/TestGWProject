package egovframework.covision.coviflow.form.web;

import java.io.IOException;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.commons.codec.binary.Base64;
import org.htmlcleaner.DomSerializer;
import org.htmlcleaner.HtmlCleaner;
import org.htmlcleaner.TagNode;
import org.joox.JOOX;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.traversal.DocumentTraversal;
import org.w3c.dom.traversal.NodeFilter;
import org.w3c.dom.traversal.NodeIterator;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.common.util.diff_match_patch;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.form.service.NonApvProcessSvc;



@Controller
public class NonApvProcessCon {
	
	private static final Logger LOGGER = LogManager.getLogger(NonApvProcessCon.class);
	
	@Autowired
	private NonApvProcessSvc nonApvProcessSvc;
	@Autowired
	private ApvProcessSvc apvProcessSvc;
	@Autowired
	private FormSvc formSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//참조/회람편황 페이지 오픈
	@RequestMapping(value = "goCirculationReadListPage.do", method = RequestMethod.GET) 
	public ModelAndView goCirculationReadListPage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/CirculationReadList";
		try
		{
			String formInstID = request.getParameter("FormInstID");
			String bStored = request.getParameter("bstored") == null ? "false" : request.getParameter("bstored");
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("FormInstID", formInstID);
			mav.addObject("BStored", bStored); // 20210126 이관문서 기능 추가
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
	
	//참조/회람 리스트
	@RequestMapping(value = "getCirculationReadListData.do")
	public @ResponseBody CoviMap getCirculationReadListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String fiid = request.getParameter("FormIstID");//FormInstanceID
			String bstored = request.getParameter("BStored") == null ? "false" : request.getParameter("BStored"); // 20210126 이관문서 기능 추가
			String sortColumn = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];

			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("fiid", fiid);
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			
			if (bstored.equals("true")) {
				resultList = nonApvProcessSvc.getCirculationReadListDataStore(params);
			}else {
				resultList = nonApvProcessSvc.getCirculationReadListData(params);
			}
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	//참조/회람 리스트 선택 삭제(전체삭제 없음)
	@RequestMapping(value = "deleteCirculationReadListData.do")
	public @ResponseBody CoviMap deleteCirculationReadListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			String circulationBoxID = request.getParameter("CirculationBoxID");
			String modifierID = request.getParameter("ModID");
			String bstored = request.getParameter("BStored") == null ? "false" : request.getParameter("BStored"); // 20210126 이관문서 기능 추가

			if(bstored.equals("true")) {
				returnList.put("data", nonApvProcessSvc.deleteCirculationReadDataStore(circulationBoxID, modifierID));
			}else {
				returnList.put("data", nonApvProcessSvc.deleteCirculationReadData(circulationBoxID, modifierID));
			}
			
			returnList.put("data", nonApvProcessSvc.deleteCirculationReadData(circulationBoxID, modifierID));
			
            
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	//수신현황 페이지
	@RequestMapping(value = "goReceiptReadListPage.do", method = RequestMethod.GET) 
	public ModelAndView goReceiptReadListPage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/ReceiptReadList";
		try
		{
			String formInstID = request.getParameter("FormInstID");
			String processID = request.getParameter("ProcessID");
			String GovDocs = request.getParameter("GovDocs");
			
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("FormInstID", formInstID);
			mav.addObject("ProcessID", processID);
			mav.addObject("GovDocs", GovDocs);
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
	
	//수신현황 리스트
	@RequestMapping(value = "getReceiptReadListData.do")
	public @ResponseBody CoviMap getReceiptReadListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String processID = request.getParameter("ProcessID");
			String sortColumn = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];		
			
			String processID1 = nonApvProcessSvc.getParentProcessID1(processID, processID);
			String processID2 = nonApvProcessSvc.getParentProcessID2(processID, processID);

			if(processID2 == null || processID2.equals("0"))
				processID2 = processID;
			
			if(processID1 == null || processID1.equals("0"))
				processID1 = processID2;
			
			CoviMap params = new CoviMap();
			params.put("ProcessID1", processID1);
			params.put("ProcessID2", processID2);
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);	

			CoviMap resultList = nonApvProcessSvc.getReceiptReadListData(params);
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//문서유통 - 배부 수신이력 리스트
	@RequestMapping(value = "getGovDocReceiptReadListData.do")
	public @ResponseBody CoviMap getGovDocReceiptReadListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, Object> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		String GovDocs = (String) paramMap.get("GovDocs");
		
		try
		{
			List<Object> govDocProcessID = nonApvProcessSvc.selectArrayProc((String) paramMap.get("FormIstID"));
			
			String processID1 = "";
			String processID2 ="";
			CoviMap params = new CoviMap();
				
			for(int i=0; i<govDocProcessID.size(); i++) {
				
				String processID = (String) govDocProcessID.get(i);
				String sortColumn = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
				String sortDirection = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];		
					
				processID1 = processID;
				processID2 = processID;

				params.put("ProcessID1", processID1);
				params.put("ProcessID2", processID2);
				params.put("sortColumn", sortColumn);
				params.put("sortDirection", sortDirection);	
					
				CoviMap resultMap = nonApvProcessSvc.getReceiptReadListData(params);
				resultList.add(resultMap.get("list"));
			} 
				returnList.put("list", resultList);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
				
			} catch(NullPointerException npE){
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			} catch(Exception e){
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			}
			
			return returnList;
		}
	
	//히스토리 페이지
	@RequestMapping(value = "goHistoryListPage.do", method = RequestMethod.GET) 
	public ModelAndView goHistoryListPage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/HistoryList";
		try
		{
			String formInstID = request.getParameter("FormInstID");
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("FormInstID", formInstID);
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
	
	@RequestMapping(value = "goOrder.do", method = RequestMethod.GET) 
	public ModelAndView goOrder(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/Order";
		return new ModelAndView(returnURL);
	}

	@RequestMapping(value = "goOutsourcing.do", method = RequestMethod.GET) 
	public ModelAndView goOutsourcing(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/Outsourcing";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "goSoftwareView.do", method = RequestMethod.GET) 
	public ModelAndView goSoftwareView(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/SoftwareView";
		return new ModelAndView(returnURL);
	}
	
	//히스토리 리스트
	@RequestMapping(value = "getHistoryListData.do")
	public @ResponseBody CoviMap getHistoryListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String fiid = request.getParameter("FormIstID");//FormInstanceID
			CoviMap resultList = nonApvProcessSvc.getHistoryListData(fiid);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//히스토리 리스트
	@RequestMapping(value = "getHistoryModifiedData.do")
	public @ResponseBody CoviMap getHistoryModifiedData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String formInstID = request.getParameter("formInstID");//FormInstanceID
			String revision = request.getParameter("revision");//revision
			
			CoviMap params = new CoviMap();		
			params.put("formInstID", formInstID);
			params.put("revision", revision);
			
			CoviMap resultList = nonApvProcessSvc.getHistoryModifiedData(params);
			returnList.put("NewDataSet",resultList.get("list"));
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//수신현황 엑셀 다운로드
	@RequestMapping(value = "receiptReadListExcelDownload.do" )
	public ModelAndView receiptReadListExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();		

		try {
			String selectParams = StringUtil.replaceNull(request.getParameter("selectParams")).replace("&amp;", "&").replace("&quot;", "\"");
			CoviMap selectParamsObj = CoviMap.fromObject(selectParams);
			String title = request.getParameter("title");
			String headerKey = request.getParameter("headerkey");
			String headerName = StringUtil.replaceNull(request.getParameter("headername"));

			CoviMap params = new CoviMap();
			String[] headerNames = headerName.split(";");

			for(Iterator<String> keys=selectParamsObj.keys();keys.hasNext();){
				String key = keys.next();
				params.put(key, selectParamsObj.getString(key));
			}

			String processID = selectParamsObj.getString("ProcessID");
			String formInstID = selectParamsObj.getString("FormIstID");
			
			String processID1 = nonApvProcessSvc.getParentProcessID1(processID, formInstID);
			String processID2 = nonApvProcessSvc.getParentProcessID2(processID, formInstID);

			if(processID2 == null || processID2.equals("0")){
				processID2 = processID;
			}
			
			if(processID1 == null || processID2.equals("0")){
				processID1 = processID2;
			}

			CoviMap resultList = nonApvProcessSvc.getReceiptReadListDataExcel(processID1, processID2, headerKey);
			
			viewParams.put("list", resultList.get("list"));
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", title);

			mav = new ModelAndView(returnURL, viewParams);

		} catch (IOException ioE) {
			LOGGER.error("NonApvProcessCon", ioE);
		} catch (NullPointerException npE) {
			LOGGER.error("NonApvProcessCon", npE);
		} catch (Exception e) {
			LOGGER.error("NonApvProcessCon", e);
		}

		return mav;
	}
	
	//회람현황 페이지(조직도)
	@RequestMapping(value = "goCirculationMgrListpage.do", method = RequestMethod.GET) 
	public ModelAndView goExistingCirculationListpage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/CirculationManager";
		String formInstID = request.getParameter("FormInstID");
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("FormInstID", formInstID);
		return mav;
	}
	
	//회람리스트(조직도)
	@RequestMapping(value = "getExistingCirculationList.do")
	public @ResponseBody CoviMap getExistingCirculationList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String fiid = request.getParameter("FormIstID");//FormInstanceID
			String kind = request.getParameter("Kind");//Kind 값
			String bstored = StringUtil.replaceNull(request.getParameter("bstored"));//20210126 이관함

			CoviMap resultList = null;
			//20210126 이관함
			if (bstored.equals("true")) {
				resultList = nonApvProcessSvc.getExistingCirculationListStored(fiid, kind);
			} else {
				resultList = nonApvProcessSvc.getExistingCirculationList(fiid, kind);
			}
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//회람추가(조직도)
	@RequestMapping(value = "setCirculation.do")
	public @ResponseBody CoviMap setCirculation(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String bstored = StringUtil.replaceNull(request.getParameter("bstored")); // 20210126 이관함 기능 추가
			
			if (bstored.equals("true")) {
				String[] fiid = StringUtil.replaceNull(request.getParameter("FormInstID")).split(";");
				String[] piid = StringUtil.replaceNull(request.getParameter("ProcessID")).split(";");
				CoviMap formInfoList = new CoviMap();
				StringBuilder sb = new StringBuilder();
				boolean ListCirculation = true;
				
				for (int idx = 0; idx < fiid.length; idx++) {
					if (!fiid[idx].equals("")) {
						formInfoList = nonApvProcessSvc.getFormInfoListStore(fiid[idx]);
						if(formInfoList.get("list").toString().replace("[","").replace("]","").length()==0) {
							formInfoList = apvProcessSvc.getFormInfoList(fiid[idx]);
							ListCirculation = false;
						}
						
						CoviList arrayFormInfoList = new CoviList();
						arrayFormInfoList = (CoviList)formInfoList.get("list");
						sb.append(arrayFormInfoList.toString().substring(1, arrayFormInfoList.toString().length() - 1) + ",");
						for(int j = 0; j < arrayFormInfoList.size(); j++){
							params.put("FormInstID"  , fiid[idx]);
							params.put("ProcessID"  , piid[idx]);
							params.put("FormID"  , arrayFormInfoList.getJSONObject(j).getString("FormID"));
							params.put("FormName"  , arrayFormInfoList.getJSONObject(j).getString("FormName"));
							params.put("FormPrefix", arrayFormInfoList.getJSONObject(j).getString("FormPrefix"));
							params.put("FormSubject"  ,ComUtils.RemoveScriptAndStyle(arrayFormInfoList.getJSONObject(j).getString("FormSubject")));
							params.put("IsSecureDoc"  , arrayFormInfoList.getJSONObject(j).getString("IsSecureDoc"));
							params.put("IsFile"  , arrayFormInfoList.getJSONObject(j).getString("IsFile"));
							params.put("FileExt"  , "");
							params.put("IsComment"  , "N");
							params.put("ApproverCode"  , "");
							params.put("ApproverName"  , "");
							params.put("ApprovalStep"  , "");
							params.put("ApproverSIPAddress"  , "");
							params.put("IsReserved"  , "");
							params.put("ReservedGubun"  , "");
							//params.put("ReservedTime"  , request.getParameter("ReservedTime"));
							params.put("Priority"  , "");
							params.put("IsModify"  , "");
							params.put("Reserved1"  , arrayFormInfoList.getJSONObject(j).getString("DocNo"));
							params.put("Reserved2"  , arrayFormInfoList.getJSONObject(j).getString("Reserved2"));
							params.put("SenderID"  , SessionHelper.getSession("USERID"));
							params.put("SenderName"  , SessionHelper.getSession("USERNAME"));
							params.put("Subject"  , ComUtils.RemoveScriptAndStyle(arrayFormInfoList.getJSONObject(j).getString("FormSubject")));
							params.put("RegID"  , SessionHelper.getSession("USERID"));
							params.put("Kind"  , request.getParameter("Kind"));
							params.put("Comment"  , ComUtils.RemoveScriptAndStyle(request.getParameter("Comment")));
							
							String jsonString = request.getParameter("ListData");
							
							String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);
							
							CoviList jarr = CoviList.fromObject(escapedJson);		
							
							if(ListCirculation) {
								for(int i=0; i<jarr.size(); i++){
									nonApvProcessSvc.setCirculationDescriptionStored(params);
									String CirculationBoxDescriptionID = params.optString("CirculationBoxDescriptionID");
									CoviMap obj = jarr.getJSONObject(i);
									
									params.put("ReceiptID"  , obj.getString("ReceiptID"));
									params.put("ReceiptName"  , obj.getString("ReceiptName"));
									params.put("ReceiptType"  , obj.getString("ReceiptType"));
									params.put("CirculationBoxDescriptionID", CirculationBoxDescriptionID);	
										
									nonApvProcessSvc.setCirculationStored(params);
								}
							}else {
								for(int i=0; i<jarr.size(); i++){
									CoviMap obj = jarr.getJSONObject(i);
									
									params.put("ReceiptID"  , obj.getString("ReceiptID"));
									params.put("ReceiptName"  , obj.getString("ReceiptName"));
									params.put("ReceiptType"  , obj.getString("ReceiptType"));
									
									if(nonApvProcessSvc.getExistingCirculationCnt(params) ==  0) {
										nonApvProcessSvc.setCirculationDescription(params);
										nonApvProcessSvc.setCirculation(params);
									} else {
									}

								}
							}
						}
					}
				}
			
				String ret = "[" + sb.substring(0, sb.length() - 1) + "]";
				returnList.put("list",ret);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "등록되었습니다");
				
				return returnList;
			}else {
				
				params.put("FormInstID"  , request.getParameter("FormInstID"));
				params.put("FormID"  , request.getParameter("FormID"));
				params.put("FormName"  , request.getParameter("FormName"));
				params.put("FormPrefix", request.getParameter("FormPrefix"));
				params.put("FormSubject"  ,ComUtils.RemoveScriptAndStyle(request.getParameter("FormSubject")));
				params.put("IsSecureDoc"  , request.getParameter("IsSecureDoc"));
				params.put("IsFile"  , request.getParameter("IsFile"));
				params.put("FileExt"  , request.getParameter("FileExt"));
				params.put("IsComment"  , request.getParameter("IsComment"));
				params.put("ApproverCode"  , request.getParameter("ApproverCode"));
				params.put("ApproverName"  , request.getParameter("ApproverName"));
				params.put("ApprovalStep"  , request.getParameter("ApprovalStep"));
				params.put("ApproverSIPAddress"  , request.getParameter("ApproverSIPAddress"));
				params.put("IsReserved"  , request.getParameter("IsReserved"));
				params.put("ReservedGubun"  , request.getParameter("ReservedGubun"));
				//params.put("ReservedTime"  , request.getParameter("ReservedTime"));
				params.put("Priority"  , request.getParameter("Priority"));
				params.put("IsModify"  , request.getParameter("IsModify"));
				params.put("Reserved1"  , request.getParameter("Reserved1"));
				params.put("Reserved2"  , request.getParameter("Reserved2"));
				params.put("ProcessID"  , request.getParameter("ProcessID"));
				params.put("SenderID"  , request.getParameter("usid"));
				params.put("SenderName"  , request.getParameter("usnm"));
				params.put("Subject"  , ComUtils.RemoveScriptAndStyle(request.getParameter("Subject")));
				params.put("RegID"  , request.getParameter("usid"));
				params.put("Kind"  , request.getParameter("Kind"));
				params.put("Comment"  , ComUtils.RemoveScriptAndStyle(request.getParameter("Comment")));
				params.put("CirculationBoxDescriptionID", 0);		
				
				String jsonString = request.getParameter("ListData");
				
				String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);
				
				CoviList jarr = CoviList.fromObject(escapedJson);		
				
				for(int i=0; i<jarr.size(); i++){
					CoviMap obj = jarr.getJSONObject(i);
					
					params.put("ReceiptID"  , obj.getString("ReceiptID"));
					params.put("ReceiptName"  , obj.getString("ReceiptName"));
					params.put("ReceiptType"  , obj.getString("ReceiptType"));
					
					if(nonApvProcessSvc.getExistingCirculationCnt(params) ==  0) {
						nonApvProcessSvc.setCirculationDescription(params);
						nonApvProcessSvc.setCirculation(params);
					} else {
					}

				}
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "SUCCESS");
			}

		} catch(NullPointerException npE){
			LOGGER.error("", npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error("", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//문서연결 페이지
	@RequestMapping(value = "goDocListSelectPage.do", method = RequestMethod.GET) 
	public ModelAndView goDocListSelectPage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/DocListSelect";
		try
		{
			String userID = request.getParameter("USERID");
			String deptID = request.getParameter("DEPTID");
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("UserID", userID);
			mav.addObject("DeptID", deptID);
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
	
	//양식 인쇄
	@RequestMapping(value = "form/Print.do", method = RequestMethod.GET) 
	public ModelAndView goPrint(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/Print";
		return new ModelAndView(returnURL);
	}
	
	//양식 인쇄
	@RequestMapping(value = "form/PrintForm.do", method = RequestMethod.GET) 
	public ModelAndView goPrintForm(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/PrintForm";
		return new ModelAndView(returnURL);
	}
	
	
	//의견보기
	@RequestMapping(value = "goCommentViewPage.do", method = RequestMethod.GET) 
	public ModelAndView goCommentViewPage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/CommentView";
		try
		{
			String formInstID = request.getParameter("FormInstID");
			String processID = request.getParameter("ProcessID");
			String archived = request.getParameter("archived");
			String bstored = request.getParameter("bstored");
			
			ModelAndView mav = new ModelAndView(returnURL);
			
			mav.addObject("FormInstID", formInstID);
			mav.addObject("ProcessID", processID);
			mav.addObject("archived", archived);
			mav.addObject("bstored", bstored);
			
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
	
	//검토의견보기
	@RequestMapping(value = "goConsultationCommentViewPage.do", method = RequestMethod.GET) 
	public ModelAndView goCirulcationCommentViewPage(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/ConsultationCommentView";
		try
		{
			String FormInstID = request.getParameter("FormInstID");
			String ProcessID = request.getParameter("ProcessID");
			String archived = request.getParameter("archived");
			String workitemID = request.getParameter("WorkItemID");
			String subKind = request.getParameter("Subkind");
			String userCode = request.getParameter("UserCode");
			String parentWorkitemID = "0";
			
			if(StringUtil.replaceNull(subKind, "").equals("T023")) {
				CoviMap param = new CoviMap();
				param.put("WorkitemID", workitemID);
				parentWorkitemID = nonApvProcessSvc.getOriginWorkItemID(param);
			}
			
			ModelAndView mav = new ModelAndView(returnURL);
			
			mav.addObject("FormInstID", FormInstID);
			mav.addObject("ProcessID", ProcessID);
			mav.addObject("archived", archived);
			mav.addObject("WorkItemID", workitemID);
			mav.addObject("ParentWorkItemID", parentWorkitemID);
			mav.addObject("Subkind", subKind);
			mav.addObject("UserCode", userCode);
			
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
		
	//양식 인쇄
	@RequestMapping(value = "form/PrintPdf.do", method = RequestMethod.GET) 
	public ModelAndView goPrintPdf(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/Pdf";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "form/diffForm.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public @ResponseBody String goDiffForm(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		HtmlCleaner cleaner = new HtmlCleaner();
		TagNode node = null;
		DomSerializer ser = new DomSerializer(cleaner.getProperties());
		diff_match_patch dmp = new diff_match_patch();
		dmp.Diff_Timeout = 0;
		
		// HTML 클리닝
		node = cleaner.clean(StringUtil.replaceNull(paramMap.get("orgHtml"),"").replace("&","&amp;"));
		Document orgDoc = ser.createDOM(node);
		
		node = cleaner.clean(StringUtil.replaceNull(paramMap.get("selHtml"),"").replace("&","&amp;"));
		Document selDoc = ser.createDOM(node);
		
		XPath xPath =  XPathFactory.newInstance().newXPath();
		
		// NodeIterator 생성
		DocumentTraversal traversal = (DocumentTraversal) selDoc;
		NodeIterator iterator = traversal.createNodeIterator(selDoc.getDocumentElement(), NodeFilter.SHOW_ELEMENT, null, true);
		
		int index = 0;
		
		for (Node n = iterator.nextNode(); n != null; n = iterator.nextNode()) {           
		    NodeList childList = n.getChildNodes();

	    	index = 1;
		    for (int i=0; i<childList.getLength(); i++) {
		        Node child = childList.item(i);
		        
		        if (child.getNodeName().equals("#text")) {
		        	String parentName = child.getParentNode().getNodeName();
		        	
		        	if (parentName.equals("td") || parentName.equals("span") || parentName.equals("p") || parentName.equals("a")) {
		        		Element el = (Element) n;
		        		// joox를 이용하여 xpath 가져옴
		        		String elXpath = JOOX.$(el).xpath();

		        		String selText = xPath.compile(elXpath+"/text()["+index+"]").evaluate(selDoc).trim();
		        		String orgText = xPath.compile(elXpath+"/text()["+index+"]").evaluate(orgDoc).trim();
			        		
		        		if (!selText.equals(orgText)) {
		        			// diff_match_patch를 이용한 문자 비교
		        			LinkedList ll = dmp.diff_main(orgText, selText, false);
		        			String result = dmp.diff_prettyHtml(ll);
		        			
		        			child.setTextContent(result);
		        		}
		        		index++;
		        	}
		        }
		    }
		}
	    
		// 수정한 html을 string으로 리턴
	    StringWriter writer = new StringWriter();
    	Transformer transformer = TransformerFactory.newInstance().newTransformer();
    	transformer.transform(new DOMSource(selDoc), new StreamResult(writer));
    	return writer.toString().replace("&lt;","<").replace("&gt;",">").replace("&amp;", "&");
	}
	
	//  추가 의견 등록
	@RequestMapping(value = "form/setComment.do")
	public @ResponseBody CoviMap setComment(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap formObj = CoviMap.fromObject(new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			List<MultipartFile> mf_comment = request.getFiles("fileData_comment[]");
			
			String doAttachFileSaveReturn_comment = nonApvProcessSvc.doCommentAttachFileSave(mf_comment);
			
			CoviMap params = new CoviMap();
			params.setConvertJSONObject(false); // Comment_fileinfo 값을 covilist가 아니라 string으로 넘기도록
			params.put("FormInstID", formObj.getString("formInstId"));
			params.put("ProcessID", formObj.getString("processId"));
			params.put("Mode", formObj.getString("mode"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("UserName", SessionHelper.getSession("USERNAME"));
			params.put("Kind", formObj.getString("kind"));
			params.put("Comment", ComUtils.RemoveScriptAndStyle(formObj.getString("comment")));
			params.put("Comment_fileinfo", ComUtils.RemoveScriptAndStyle(doAttachFileSaveReturn_comment));

			nonApvProcessSvc.setCommentMessage(formObj);
			int cnt = nonApvProcessSvc.insertComment(params);
			
			returnList.put("cnt", cnt);
			returnList.put("result", "ok");
			returnList.put("attachFileResult", doAttachFileSaveReturn_comment);

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}	
	
	//양식 도움말
	@RequestMapping(value = "form/goHelpPopup.do", method = RequestMethod.GET) 
	public ModelAndView goHelpPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/HelpPopup";
		return new ModelAndView(returnURL);
	}
	
	// 읽음 확인
	@RequestMapping(value = "setConfirmRead.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap confirmRead(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try{
			String userID = SessionHelper.getSession("USERID");
			String userName = SessionHelper.getSession("USERNAME");
			String jobTitle = SessionHelper.getSession("UR_JobTitleCode");
			String jobLevel = SessionHelper.getSession("UR_JobLevelCode");
			String deptID = SessionHelper.getSession("DEPTID");
			String deptName = SessionHelper.getSession("DEPTNAME");
			
			String userCode = request.getParameter("UserCode");
			String strReadMode = StringUtil.replaceNull(request.getParameter("mode"));
			String loct = StringUtil.replaceNull(request.getParameter("loct"));
			String gloct = StringUtil.replaceNull(request.getParameter("gloct"));
			String subkind = StringUtil.replaceNull(request.getParameter("subkind"));
			String formInstID = request.getParameter("FormInstID");
			String processID = request.getParameter("ProcessID");

			String sAdminYN = "N";
			
			if(strReadMode.equalsIgnoreCase("ADMIN")){
				sAdminYN = "Y";
			}
			
			CoviMap params = new CoviMap();
			params.put("UserID", userID);
			params.put("UserName", userName);
			params.put("JobTitle", jobTitle);
			params.put("JobLevel", jobLevel);
			params.put("ProcessID", processID);
			params.put("FormInstID", formInstID);
			params.put("AdminYN", sAdminYN);

			if(formInstID != null && !formInstID.equals("") && !formInstID.equals("0"))
				formSvc.insertDocReadHistory(params);
			
			// 참조/회람 읽음 처리
			params.clear();
			
			if(loct.equals("COMPLETE") 
				&& (strReadMode.equals("COMPLETE") || strReadMode.equals("PROCESS")) 
				&& (gloct.equals("TCINFO") 
						|| (gloct.equals("DEPART") && subkind.equals("T006")) 
						|| (gloct.equals("DEPART") && (subkind.equals("T014") || subkind.equals("0")  || subkind.equals("1") || subkind.equals("C")))
					)
			){
				params.put("Kind", subkind);
				
				if (gloct.equals("P") || gloct.equals("") || gloct.equals("TCINFO")){
					params.put("FormInstID", formInstID);
					params.put("ReceiptID", userID);
					
					formSvc.updateTCInfoDocReadHistory(params);
				}else if (gloct.equals("DEPART")){
					params.put("FormInstID", formInstID);
					params.put("ReceiptID", userCode);
					params.put("UserCode", userID);
					params.put("UserName", userName);
					params.put("DeptCode", deptID);
					params.put("DeptName", deptName);
					
					if(params.get("UserCode").equals("")){
						params.put("UserCode", deptID);
					}
					
					formSvc.insertTCInfoDocReadHistory(params);
				}
			}

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
//	
//	@RequestMapping(value = "form/getdocTransfer.do", method = {RequestMethod.GET, RequestMethod.POST}) 
//	public @ResponseBody String godocTransfer(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
//		HtmlCleaner cleaner = new HtmlCleaner();
//		TagNode node = null;
//		DomSerializer ser = new DomSerializer(cleaner.getProperties());
//	
//		DocTransfer oDocTransfer = new DocTransfer();
//		String strHtml = paramMap.get("txtHtml");
//		String txtXML = oDocTransfer.convertHtmlToPubDoc(strHtml.replace("\\r\\n\\r\\n","").replace("\\\"","\""));
//		//String sResultHTML = oDocTransfer.ConvertXMLToPubDocHTMLFile(sXslText, sXMLText.ToString());
//
//		// HTML 클리닝
//		node = cleaner.clean(txtXML);
//		Document orgDoc = ser.createDOM(node);
//		
//		// 수정한 html을 string으로 리턴
//	    StringWriter writer = new StringWriter();
//    	Transformer transformer = TransformerFactory.newInstance().newTransformer();
//    	transformer.transform(new DOMSource(orgDoc), new StreamResult(writer));
//    	return writer.toString().replace("\\r\\n\\t","").replace("","");
//	}	
//	
	
	// 비공개 사유 도움말
	@RequestMapping(value = "form/goSecOptionHelpPopup.do", method = RequestMethod.GET) 
	public ModelAndView goSecOptionHelpPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/SecOptionHelpPopup";
		return new ModelAndView(returnURL);
	}
	
	
	//요약전
	@RequestMapping(value = "form/goSummaryPopup.do", method = RequestMethod.GET) 
	public ModelAndView goSummaryPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/SummaryPopup";
		return new ModelAndView(returnURL);
	}
	
	//문서정보
	@RequestMapping(value = "form/goGovDocInfoWritePopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goGovDocInfoWritePopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/GovDocInfoWritePopup";
		
		try {
			ModelAndView mav = new ModelAndView(returnURL);
			String idx = request.getParameter("idx");
			String formInstID = request.getParameter("formInstID");
			String processID = request.getParameter("processID");
			String deptCode = request.getParameter("deptCode");
			
			mav.addObject("idx", idx);
			mav.addObject("formInstID", formInstID);
			mav.addObject("processID", processID);
			mav.addObject("deptCode", deptCode);
			
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}
	
	//기록철 팝업
	@RequestMapping(value = "form/goGovDocRefWritePopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goGovDocRefWritePopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/GovDocRefWritePopup";
		
		try {
			ModelAndView mav = new ModelAndView(returnURL);
			String idx = request.getParameter("idx");
			String formInstID = request.getParameter("formInstID");
			String processID = request.getParameter("processID");
			String deptCode = request.getParameter("deptCode");
			
			mav.addObject("idx", idx);
			mav.addObject("formInstID", formInstID);
			mav.addObject("processID", processID);
			mav.addObject("deptCode", deptCode);
			
			return mav;
		} catch(NullPointerException npE){
			return null;
		} catch(Exception e){
			return null;
		}
	}	

	//기록물철 선택 팝업
	@RequestMapping(value = "form/goRecordSelectPopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goRecordSelectPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/RecordSelectPopup";
		return new ModelAndView(returnURL);
	}
	
	//기록물철 선택 팝업2
	@RequestMapping(value = "form/goRecordRefSelectPopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goRecordRefSelectPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "forms/RecordRefSelectPopup";
		return new ModelAndView(returnURL);
	}	

	//단위업무 목록 조회
	@RequestMapping(value = "getSeriesListData.do")
	public @ResponseBody CoviMap getSeriesListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try
		{
			String functioncode = request.getParameter("functioncode");
			String functionlevel = request.getParameter("functionlevel");
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}
			
			CoviMap params = new CoviMap();
			
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("DeptID", request.getParameter("DeptID"));
			params.put("DeptCode", request.getParameter("DeptCode") == null ? "" : request.getParameter("DeptCode"));
			params.put("baseYear", request.getParameter("baseYear"));
			params.put("existsGFile", request.getParameter("existsGFile"));
			params.put("functioncode", functioncode);
			params.put("functionlevel", functionlevel);
			
			CoviMap resultList = nonApvProcessSvc.getSeriesListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	//기록물철/즐겨찾기 목록 조회
	@RequestMapping(value = "getRecordListData.do")
	public @ResponseBody CoviMap getRecordListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}

			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);			
			params.put("RecordDeptCode", request.getParameter("DeptID"));
			params.put("DeptCode", request.getParameter("DeptCode") == null ? "" : request.getParameter("DeptCode"));
			params.put("searchWord", request.getParameter("searchWord"));
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("baseYear", request.getParameter("baseYear"));
			
			String isFav = StringUtil.replaceNull(request.getParameter("isFav"));
			if(isFav.equals("Y")) {
				resultList = nonApvProcessSvc.getFavRecordListData(params);
			} else {
				resultList = nonApvProcessSvc.getRecordListData(params);
			}
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 기록물철 즐겨찾기 추가/삭제
	@RequestMapping(value = "toggleRecordFav.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteRecordFav(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("action", request.getParameter("action"));
			params.put("RecordClassNum", request.getParameter("RecordClassNum"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			returnList.put("data", nonApvProcessSvc.toggleRecordFav(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다.");
			
		} catch(NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}

	//기록물철 상세조회
	@RequestMapping(value = "user/goRecordDocViewPopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goRecordDocViewPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/approval/RecordDocViewPopup";
		
		try {
			ModelAndView mav = new ModelAndView(returnURL);
			String docId = request.getParameter("doc_id");	
			
			String userCode = SessionHelper.getSession("USERID");
			String userName = SessionHelper.getSession("USERNAME");
			String jobPosition = SessionHelper.getSession("UR_JobPositionCode");
			String jobPositionName = SessionHelper.getSession("UR_JobPositionName");
			String jobTitle = SessionHelper.getSession("UR_JobTitleCode");
			String jobTitleName = SessionHelper.getSession("UR_JobTitleName");
			String jobLevel = SessionHelper.getSession("UR_JobLevelCode");
			String jobLevelName = SessionHelper.getSession("UR_JobLevelName");
			String deptID = SessionHelper.getSession("DEPTID");
			String deptName = SessionHelper.getSession("DEPTNAME");

			CoviMap params = new CoviMap();
			params.put("RecordDocumentID", docId);
			params.put("UserCode", userCode);
			params.put("UserName", userName);
			params.put("JobPosition", jobPosition);
			params.put("JobPositionName", jobPositionName);
			params.put("JobTitle", jobTitle);
			params.put("JobTitleName", jobTitleName);
			params.put("JobLevel", jobLevel);
			params.put("JobLevelName", jobLevelName);
			params.put("DeptID", deptID);
			params.put("DeptName", deptName);
			
			// 열람범위 (보안등급) 체크
			if (nonApvProcessSvc.getRecordDocAuthData(params)) {			
				// 읽음처리
				nonApvProcessSvc.insertRecordDocRead(params);
				
				mav.addObject("isAuth", "Y");
				mav.addObject("doc_id", docId);
			} else {
				mav.addObject("isAuth", "N");
				mav.addObject("doc_id", "");
			}
			
			return mav;
		} catch(NullPointerException npE) {
			return null;
		} catch(Exception e) {
			return null;
		}
	}

	//기록물철 수동등록
	@RequestMapping(value = "user/goRecordDocWritePopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goRecordDocWritePopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/approval/RecordDocWritePopup";
		
		try {			
			String docId = request.getParameter("doc_id");			
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("doc_id", docId);			
			return mav;
		} catch(NullPointerException npE) {
			return null;
		} catch(Exception e) {
			return null;
		}
	}

	//기록물 조회자 목록 조회
	@RequestMapping(value = "user/goRecordDocReadPopup.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goRecordDocReadPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/approval/RecordDocReadPopup";
		try {
			String docId = request.getParameter("doc_id");
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("doc_id", docId);
			return mav;
		} catch(NullPointerException npE) {
			return null;
		} catch(Exception e) {
			return null;
		}
	}
	
	// 기록물 조회자 목록 조회
	@RequestMapping(value = "user/getRecordDocReaderListData.do")
	public @ResponseBody CoviMap getRecordDocReaderListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String sortColumn = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}

			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("recordDocumentID", request.getParameter("doc_id"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchWord", request.getParameter("searchWord"));			
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);	
			
			resultList = nonApvProcessSvc.getRecordDocReaderListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//통합검색 Queue table insert
	@RequestMapping(value = "selectTotalSearch.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectTotalSearch(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();

		try{
			String queTime = RedisDataUtil.getBaseConfig("ApprovalTotalSearchQueTime");
			CoviMap params = new CoviMap();
			params.put("queTime", queTime);
			int cnt = nonApvProcessSvc.selectTotalSearch(params);

			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));

		}catch(IOException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}

		return result;
	}	
	
	
}
