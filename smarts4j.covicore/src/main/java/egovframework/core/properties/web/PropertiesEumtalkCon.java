package egovframework.core.properties.web;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.properties.service.PropertiesEumtalkSvc;

@Controller
@RequestMapping("/propertiesEumtalk")
public class PropertiesEumtalkCon {

	private Logger LOGGER = LogManager.getLogger(PropertiesContextManageCon.class);
	
	@Autowired
	private PropertiesEumtalkSvc propertiesEumtalkSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@PostMapping("/list.do")
	public @ResponseBody CoviMap list(
			@RequestParam(value = "dbType",	required = false, defaultValue="")	String dbType,
			@RequestParam(value = "wasType", required = false, defaultValue="")	String wasType,
			@RequestParam(value = "fileType", required = false, defaultValue="")	String fileType,
			@RequestParam(value = "fileName", required = false, defaultValue="")	String fileName,
			@RequestParam(value = "context", required = false, defaultValue="")	String context) throws Exception {
		
		CoviMap returnData = new CoviMap();
		
		try {
			returnData = propertiesEumtalkSvc.selectEumtalkList(new CoviMap() {{
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
