package egovframework.api.admin.web;

import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.api.admin.service.ConfigSvc;
import egovframework.api.admin.service.AuthorizationSvc;
import egovframework.api.admin.util.TokenUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.StringUtil;

@RequestMapping(value = "/api/")
@Controller
public class ConfigCon {
	private static final Logger LOGGER = LogManager.getLogger(ConfigCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	ConfigSvc configSvc;
	
	@Autowired
	AuthorizationSvc authorizationSvc;
	
	@Autowired
	private ApplicationContext context;
	
	@RequestMapping(value = "config/getTokenList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTokenList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[1];
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultList = configSvc.getTokenList(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
		
	/**
	 * 신규토큰 발급
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/generateToken.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap generateToken(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap(paramMap);
			String domainID = param.getString("DomainID");
			
			String token = TokenUtil.generateToken(domainID);
			configSvc.insertToken(domainID, token);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * 토큰 수정(설명 or 사용여부)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/updateToken.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateToken(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.updateToken(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * 토큰삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/deleteToken.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteToken(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			String tokenID = param.getString("TokenID");
			if(tokenID != null && tokenID.indexOf(",") > -1) {
				String [] tokenIDList = StringUtils.split(tokenID, ",");
				for(String val : tokenIDList) {
					param.put("TokenID", val);
					configSvc.deleteToken(param);	
				}
			}else {
				configSvc.deleteToken(param);
			}
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/************************** API 설정관리 ********************************/
	
	/**
	 * API 설정 추가 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/addConfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addConfig(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			configSvc.insertConfig(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		}
		return returnList;
	}
	
	/**
	 * API 설정 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/editConfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editConfig(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.updateConfig(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		}
		return returnList;
	}
	
	/**
	 * 사용여부 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/editConfigIsUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editConfigIsUse(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.updateConfigIsUse(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		}
		return returnList;
	}
	
	/**
	 * API 설정 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/deleteConfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteConfig(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.deleteConfig(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
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
	 * API 설정정보 목록조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getConfigList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConfigList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[1];
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultList = configSvc.getConfigList(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * API 설정정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getConfigDetail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConfigDetail(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			CoviMap result = configSvc.getConfig(param);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("data", result);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * sys_api_config 모든 데이터 동기화
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/synchronizeComponents.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap synchronizeComponents(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.synchronizeConfig(param);

			returnList.put("status", Return.SUCCESS);
		} catch (JSONException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/************************** API IP 허용관리 ********************************/

	/**
	 * IP허용설정 목록조회(WEB)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getIPSecureList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getIPSecureList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[1];
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultList = configSvc.getIPSecureList(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * IP 허용설정 추가 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/addIPSecure.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addIPSecure(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			configSvc.insertIPSecure(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		}
		return returnList;
	}
	
	/**
	 * IP 허용설정 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/editIPSecure.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editIPSecure(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.updateIPSecure(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		}
		return returnList;
	}
	
	/**
	 * IP허용설정 사용여부 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/editIPSecureIsUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editIPSecureIsUse(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.updateIPSecureIsUse(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getLocalizedMessage());
		}
		return returnList;
	}
	
	/**
	 * IP 허용설정 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/deleteIPSecure.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteIPSecure(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			configSvc.deleteIPSecure(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
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
	 * IP허용 설정정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getIPSecureDetail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getIPSecureDetail(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			CoviMap result = configSvc.getIPSecure(param);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("data", result);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * IP허용 테스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/checkIPSecure.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkIPSecure(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			Return result = Return.SUCCESS;
			try {
				authorizationSvc.checkRequestIP(param.getString("TestIP"));
			}catch(NullPointerException e) {
				result = Return.FAIL;
			}catch(Exception e) {
				result = Return.FAIL;
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("data", result);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/************************** API 로그 관리 ********************************/
	/**
	 * 로그 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getRequestLogList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRequestLogList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ")[1];
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultList = configSvc.getRequestLogList(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}	
	
	/**
	 * 로그 단건 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getRequestLogDetail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRequestLogDetail(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			CoviMap result = configSvc.getRequestLog(param);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("data", result);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	/**
	 * 통계데이터 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "config/getRequestStatList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRequestStatList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			
			CoviList result = configSvc.getRequestStatList(param);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("data", result);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	@RequestMapping(value = "config/getConfigListAll.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConfigListAll(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap(paramMap);
			CoviList configListAll = configSvc.getConfigListAll(param);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("data", configListAll);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}
	
	@RequestMapping(value = "config/setMultipartLimit.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setMultipartLimit(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			String fileSize = paramMap.get("fileSize");
			if(fileSize == null || StringUtil.isEmpty(fileSize) || !StringUtil.isNumeric(fileSize)) {
				throw new Exception("[fileSize] parameter is not defined or not a number.");
			}
			
			Object o = context.getBean("multipartResolver");
			if(o instanceof CommonsMultipartResolver) {
				CommonsMultipartResolver multipartResolver = (CommonsMultipartResolver)context.getBean("multipartResolver");
				multipartResolver.setMaxUploadSize(Long.parseLong(fileSize));
			}else {
				throw new Exception("Bean[multipartResolver] is not CommonsMultipartResolver.");
			}
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
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
	
}
