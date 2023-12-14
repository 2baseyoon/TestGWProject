package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.SampleSvc;


/**
 * @Class Name : SampleCon.java
 * @Description : 샘플컨트롤러
 * @Modification Information 
 * @ 2018.03.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018. 03.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SampleCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private SampleSvc sampleSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//layout 처리 시작
	@RequestMapping(value = "sample/getSamplelist.do")
	public @ResponseBody CoviMap getSample(HttpServletRequest request, 
			@RequestParam(value = "Seq", required = false, defaultValue = "") String seq) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			returnList.put("list", "");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	
}
