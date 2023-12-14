package egovframework.covision.groupware.devwithgpt.user.web;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.devwithgpt.user.service.DevWithGPTSvc;

@RestController
@RequestMapping("/devWithGPT")
public class DevWithGPTCon {
	private static final Logger LOGGER = LogManager.getLogger(DevWithGPTCon.class);
			
	@Autowired
	DevWithGPTSvc devWithGPTSvc;
	
	@GetMapping("/getModelOptionAndPrompt.do")
	public CoviMap getModelOptionAndPrompt(@RequestParam String promptType) {
		CoviMap resultMap = new CoviMap();
		CoviMap returnMap = new CoviMap();
		
		String domainID = SessionHelper.getSession("DN_ID");
		
		try {
			returnMap.put("option", devWithGPTSvc.getModelOption(domainID));
			
			if(!"Free".equals(promptType)) {
				returnMap.put("prompt", devWithGPTSvc.getModelPrompt(domainID, promptType));
			}
		
			resultMap.put("status", Return.SUCCESS);
			resultMap.put("data", returnMap);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
			resultMap.put("data", e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
			resultMap.put("data", e);
		}
		
		return resultMap;
	}
	
	@PostMapping("/requestToGPT.do")
	public CoviMap requestGPT(@RequestBody CoviMap params) {
		CoviMap resultMap = new CoviMap();
		
		try {
			String domainID = SessionHelper.getSession("DN_ID");			
			
			CoviMap modelInfo = devWithGPTSvc.getModelInfo(domainID);
			
			CoviList messages = params.getJSONArray("messages");
			String promptType = params.getString("promptType");
			double temperature = params.getDouble("temperature");
			int max_tokens = params.getInt("max_tokens");
			double top_p = params.getDouble("top_p");
			double presence_penalty = params.getDouble("presence_penalty");
			double frequency_penalty = params.getDouble("frequency_penalty");
			
			HttpHeaders headers = new HttpHeaders();
			headers.setContentType(MediaType.APPLICATION_JSON);
			headers.set("Authorization", "Bearer " + modelInfo.get("APIKey"));
			
			Map<String, Object> requestBody = new HashMap<>();
			requestBody.put("model", modelInfo.get("Model"));
			requestBody.put("messages", messages);
			requestBody.put("temperature", temperature);
			requestBody.put("max_tokens", max_tokens);
			requestBody.put("top_p", top_p);
			requestBody.put("presence_penalty", presence_penalty);
			requestBody.put("frequency_penalty", frequency_penalty);
			
			HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);
	
		    RestTemplate restTemplate = new RestTemplate();
		    ResponseEntity<Map> response = restTemplate.postForEntity("https://api.openai.com/v1/chat/completions", requestEntity, Map.class);
		    
		    Map<String, Object> responseBody = response.getBody();

			resultMap.put("data", responseBody);
			
			CoviMap usageMap = new CoviMap();
			usageMap.addAll((Map) responseBody.get("usage"));
			usageMap.put("domainID", domainID);
			usageMap.put("promptType", promptType);
			
			int log_count = devWithGPTSvc.insertUsageLog(usageMap);
			resultMap.put("status", Return.SUCCESS);
			
		    return resultMap;
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
			resultMap.put("error", e);
			return resultMap;
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
			resultMap.put("error", e);
			return resultMap;
		}
	}
	
	@GetMapping("/getModel.do")
	public CoviMap getModel() {
		
		CoviMap resultMap = new CoviMap();
		
		try {
			String domainID = SessionHelper.getSession("DN_ID");
			
			CoviMap modelInfo = devWithGPTSvc.getModelInfo(domainID);
			CoviMap modelOption = devWithGPTSvc.getModelOption(domainID);
			CoviMap modelPrompt = devWithGPTSvc.getModelPrompt(domainID);
			
			resultMap.put("status", Return.SUCCESS);
			
			resultMap.put("info", modelInfo);
			resultMap.put("option", modelOption);
			resultMap.put("prompt", modelPrompt);
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		}
		
		return resultMap;
	}
	
	@PostMapping("/updateModel.do")
	public CoviMap updateModel(@RequestBody CoviMap params) {
		
		CoviMap resultMap = new CoviMap();
		int updateCnt = 0;
		
		try {
			String domainID = SessionHelper.getSession("DN_ID");
			String userCode = SessionHelper.getSession("USERID");
			
			params.put("domainID", domainID);
			params.put("userCode", userCode);
			
			updateCnt += devWithGPTSvc.updateModelInfo(params);
			updateCnt += devWithGPTSvc.updateModelOption(params);
			updateCnt += devWithGPTSvc.updateModelPrompt(params);
			
			resultMap.put("status", Return.SUCCESS);
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		}
		
		return resultMap;
	}
	
	@GetMapping("/getMonthUsage.do")
	public CoviMap getMonthUsage(@RequestParam String domainID, @RequestParam String selectedMonth) {
		
		CoviMap resultMap = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("domainID", domainID);
			params.put("selectedMonth", selectedMonth);
			resultMap.put("MonthUsage", devWithGPTSvc.getMonthUsage(params));
			resultMap.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		}
		
		return resultMap;
	}
	
	@GetMapping("/getPromptUsage.do")
	public CoviMap getPromptUsage(@RequestParam String domainID) {
		
		CoviMap resultMap = new CoviMap();
		CoviMap params = new CoviMap();
	
		try {
			params.put("domainID", domainID);
			resultMap.put("PromptUsage", devWithGPTSvc.getPromptUsage(params));
			resultMap.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		}
		
		return resultMap;
	}
	
	@PostMapping("/getUserUsage.do")
	public @ResponseBody CoviMap getUserUsage(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap resultMap = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("companyCode", request.getParameter("companyCode"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			resultMap = devWithGPTSvc.getUserUsage(params);
			resultMap.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap.put("status", Return.FAIL);
		}
		
		return resultMap;
	}
	
	@GetMapping("/goPopup.do")
	public ModelAndView goPopup() {
		
		String returnURL = "user/devwithgpt/popup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
}