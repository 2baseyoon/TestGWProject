package egovframework.api.v1.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.service.MessageService;

@Controller
@RequestMapping(value = "api/v1")
public class MessageApiCon {
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	@Autowired
	private MessageService messageService;
	
	/**
	 * 통합알림 API
	 */
	@RequestMapping(value = "/sendmessaging.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap sendMessage(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		
		// insertMessagingData() 내부에서 exception이 발생하면 리턴값 resultCnt은 음수.
		int messagingID = messageService.insertMessagingData(params);
		if (messagingID > 0) {
			returnMap.put("message", Return.SUCCESS);
		} else {
			// 500 응답
			throw new Exception(params.optString("ErrorMessage"));
		}
		
		return returnMap;
	}
}