package egovframework.covision.coviflow.govdocs.ldap.web;

import java.util.Map;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.coviflow.govdocs.ldap.service.Gov24ReceiveListSvc;


@Controller
public class Gov24ReceiveListCon {
	private Logger LOGGER = LogManager.getLogger(Gov24ReceiveListCon.class);

	@Autowired
	private Gov24ReceiveListSvc gov24ReceiveListSvc;
	
	/**
	 * 문서24 수신처 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "ldap/doReceiveDataSync.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap doReceiveDataSync(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		try {
			gov24ReceiveListSvc.doReciveListData();
			returnList.put("status", Return.SUCCESS);	
		}catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
        	returnList.put("status", Return.FAIL);			
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
        	returnList.put("status", Return.FAIL);			
		}
        return returnList;
	}
}
