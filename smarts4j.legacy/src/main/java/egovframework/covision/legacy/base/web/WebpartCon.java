package egovframework.covision.legacy.base.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.covision.legacy.base.service.WebpartSvc;

import net.sf.json.JSONException;



/**
 * @Class Name : WebpartCon.java
 * @Description : 포탈 웹파트 연동을 위한 Legacy Controller
 * @Modification Information 
 * @ 2019.07.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2019.07.03
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class WebpartCon {
	private static final Logger LOGGER = LogManager.getLogger(WebpartCon.class);
	
	@Autowired
	private WebpartSvc webpartSvc;
		
	@RequestMapping(value = "webpart/getSampleData.do", method= {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap getSampleData(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		
		try{
			CoviMap parmas = new CoviMap();
			//파라미터가 있을 경우 Parameter 처리
			
			CoviList resultList = webpartSvc.selectSampleData(parmas);
			
			returnObj.put("list", resultList);
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getMessage());
		}
		return returnObj;
	}
	
}
