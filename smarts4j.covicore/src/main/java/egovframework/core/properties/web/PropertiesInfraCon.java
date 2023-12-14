package egovframework.core.properties.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.properties.service.PropertiesInfraSvc;

@Controller
@RequestMapping("/propertiesInfra")
public class PropertiesInfraCon {

	private Logger LOGGER = LogManager.getLogger(PropertiesContextManageCon.class);
	
	@Autowired
	private PropertiesInfraSvc propertiesInfraSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 목록 조회
	 * 
	 * @param request
	 * @param response
	 * @param isSaaS
	 * @param dbType
	 * @param wasType
	 * @param propertiesArray
	 * @param serverArray
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getProperties.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getProperties(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value="isSaaS", required=true) String isSaaS,
			@RequestParam(value="dbType", required=true) String dbType,
			@RequestParam(value="wasType", required=true) String wasType,
			@RequestParam(value="propertiesArray[]", required=false) String[] propertiesArray,
			@RequestParam(value="serverArray[]", required=false) String[] serverArray) throws Exception {

		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();

		try{			
			CoviMap params = new CoviMap();
			params.put("isSaaS", isSaaS);
			params.put("dbType", dbType);
			params.put("wasType", wasType);
			params.put("propertiesArray", propertiesArray);
			params.put("serverArray", serverArray);
			
			returnList = propertiesInfraSvc.selectPropertiesList(params);
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@PostMapping("/list.do")
	public @ResponseBody CoviMap list(
			@RequestParam(value = "dbType",	required = false, defaultValue="")	String dbType,
			@RequestParam(value = "wasType", required = false, defaultValue="")	String wasType,
			@RequestParam(value = "fileType", required = false, defaultValue="")	String fileType,
			@RequestParam(value = "fileName", required = false, defaultValue="")	String fileName,
			@RequestParam(value = "context", required = false, defaultValue="")	String context) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			returnData = propertiesInfraSvc.selectInfraList(new CoviMap() {{
				this.put("dbType", dbType);
				this.put("wasType", wasType);
				this.put("fileType", fileType);
				this.put("fileName", fileName);
				this.put("context", context);
			}});
		} catch(NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
}
