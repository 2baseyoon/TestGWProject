package egovframework.core.web;

import java.util.Map;
import java.util.Map.Entry;

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
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.ExtDatabasePoolSvc;
import egovframework.coviframework.util.ComUtils;

@Controller
public class ExtDatabasePoolCon {
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private Logger LOGGER = LogManager.getLogger();
			
	@Autowired
	private ExtDatabasePoolSvc  extDatabasePoolSvc;
	
	/**
	 * [Datasource 관리] - 목록조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "extdatabase/getDatasourceList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDatasourceList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
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
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[1];
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = extDatabasePoolSvc.selectDatasourceList(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (java.sql.SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "extdatabase/goExtDatasourcePopup.do", method = RequestMethod.GET)
	public ModelAndView goExtDatasourcePopup(HttpServletRequest request) {
		return new ModelAndView("core/system/ExtDatasourceManagePopup");
	}

	@RequestMapping(value = "extdatabase/getDatasourceInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDatasourceInfo(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			CoviMap map = extDatabasePoolSvc.selectDatasource(params);
			returnList.put("info", CoviSelectSet.coviSelectMapJSON(map));
			returnList.put("status", Return.SUCCESS);
		} catch (java.sql.SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "extdatabase/addDatasource.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addDatasource(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.setConvertJSONObject(false);
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			extDatabasePoolSvc.insertDatasource(params);
			
			// add pool.
			String newSeq = params.getString("DatasourceSeq");
			extDatabasePoolSvc.reload(newSeq);
			
			returnList.put("status", Return.SUCCESS);
		} catch (java.sql.SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "extdatabase/editDatasource.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editDatasource(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.setConvertJSONObject(false);
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			extDatabasePoolSvc.updateDatasource(params);
			returnList.put("status", Return.SUCCESS);
		} catch (java.sql.SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "extdatabase/delDatasource.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap delDatasource(@RequestParam Map<String, String> paramMap) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			String [] arrDatasourceSeq = StringUtil.split(params.getString("DeleteData"), ",");
			params.put("arrDatasourceSeq", arrDatasourceSeq);
			extDatabasePoolSvc.deleteDatasource(params);
			
			// release pool
			extDatabasePoolSvc.release(arrDatasourceSeq);
			
			returnList.put("status", Return.SUCCESS);
		} catch (java.sql.SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * [Datasource 관리] Re - register pool
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "extdatabase/refreshDBPool.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap refreshDBPool(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		try {
			String DatasourceSeqStr = paramMap.get("DatasourceSeqStr");
			if(StringUtil.isEmpty(DatasourceSeqStr)) {
				extDatabasePoolSvc.reload(null);
			}else {
				String [] datasourceSeqArr = StringUtil.split(DatasourceSeqStr, ",");
				if(datasourceSeqArr != null) {
					for(String seq : datasourceSeqArr) {
						if(!StringUtil.isEmpty(seq)) {
							extDatabasePoolSvc.reload(seq);
						}
					}
				}
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		} catch (NullPointerException e) {
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

