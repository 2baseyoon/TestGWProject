package egovframework.core.web;

import java.util.Map;
import java.util.Map.Entry;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.AsyncExtDatabaseSyncSvc;
import egovframework.core.sevice.DatabaseSyncSvc;
import egovframework.coviframework.service.ExtDatabasePoolSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * 
 * @author hgsong
 */
@Controller
public class SysDatabaseSyncCon {
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private Logger LOGGER = LogManager.getLogger(SysDatabaseSyncCon.class);
	
	@Resource(name = "asyncExtDatabaseSyncService")
	private AsyncExtDatabaseSyncSvc asyncExtDatabaseSyncService;

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private DatabaseSyncSvc databaseSyncSvc;
	
	@Autowired
	private ExtDatabasePoolSvc extDatabasePoolSvc;
	
	/**
	 * 스케쥴러가 호출할 URL
	 * Remote DB 데이터를 가져와 Merge 한다.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @throws Exception
	 */
	@RequestMapping(value = "dbsync/transferExtDatabase.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap execute(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		// 작업시간이 있으므로  스케쥴러에게 응답은 주고 백그라운드로 수행한다.
		try {
			CoviMap params = new CoviMap();
			// 도메인(회사별) executor 병렬 실행!!.
			CoviList list = coviMapperOne.list("sys.dbsync.selectTarget", params);
			
			CoviList targetDomainList = CoviSelectSet.coviSelectJSON(list);
			for(Object o : targetDomainList) {
				CoviMap targetInfo = (CoviMap)o;
				asyncExtDatabaseSyncService.execute(targetInfo);
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		} catch (NullPointerException e) {
			LOGGER.error("", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error("", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * 스케쥴러가 호출할 URL2
	 * Remote DB 데이터를 가져와 Merge 한다.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @throws Exception
	 */
	@RequestMapping(value = "dbsync/transferExtDatabaseOther.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap executeOther(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		// 작업시간이 있으므로  스케쥴러에게 응답은 주고 백그라운드로 수행한다.
		try {
			CoviMap params = new CoviMap();
			
			params.put("ScheduleType", request.getParameter("ScheduleType"));
			// 도메인(회사별) executor 병렬 실행!!.
			CoviList list = coviMapperOne.list("sys.dbsync.selectTargetOther", params);
			
			CoviList targetDomainList = CoviSelectSet.coviSelectJSON(list);
			for(Object o : targetDomainList) {
				CoviMap targetInfo = (CoviMap)o;
				asyncExtDatabaseSyncService.execute(targetInfo);
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		} catch (NullPointerException e) {
			LOGGER.error("", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error("", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * [동기화 대상테이블 관리] - 목록조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "dbsync/getTargetList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTargetList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = databaseSyncSvc.selectTargetList(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NumberFormatException e) {
			LOGGER.error("", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/**
	 * Datasource 신규/수정 팝업
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "dbsync/goExtDbTargetPopup.do", method = RequestMethod.GET)
	public ModelAndView goExtDbTargetPopup(HttpServletRequest request) {
		return new ModelAndView("core/system/ExtDbTargetManagePopup");
	}

	// For selectbox.
	@RequestMapping(value = "dbsync/getDatasourceSelectData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDatasourceSelectData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			CoviList resultList = extDatabasePoolSvc.getDatasourceSelectData(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	@RequestMapping(value = "dbsync/getTargetInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTargetInfo(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			CoviMap map = databaseSyncSvc.selectTarget(params);
			returnList.put("info", CoviSelectSet.coviSelectMapJSON(map));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "dbsync/modifyUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyUse(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			databaseSyncSvc.updateUse(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "dbsync/addTarget.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addTarget(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			databaseSyncSvc.insertTarget(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "dbsync/editTarget.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editTarget(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			databaseSyncSvc.updateTarget(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "dbsync/delTarget.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap delTarget(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			String [] arrTargetSeq = StringUtil.split(params.getString("DeleteData"), ",");
			params.put("arrTargetSeq", arrTargetSeq);
			databaseSyncSvc.deleteTarget(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "dbsync/executeManual.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap executeManual(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			String key = "Sync.Cache.Exe."+params.getString("TargetSeq");
			if(!StringUtil.isEmpty(RedisShardsUtil.getInstance().get(key))){
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Requested target is already started.");
				return returnList;
			}
			
			CoviMap map = databaseSyncSvc.selectTarget(params);
			CoviMap targetInfo = CoviSelectSet.coviSelectMapJSON(map);
			asyncExtDatabaseSyncService.execute(targetInfo);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
}
