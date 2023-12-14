package egovframework.core.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.core.Response;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SsoSamlSvc;
import egovframework.coviframework.util.HttpsUtil;

/**
 * @Class Name : SsoSamlCon.java
 * @Description : SAML 내부 /외부 API 통신 처리.
 * @Description : SSO연동용.
 * @Modification  
 * @ 2017.07.24 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.24
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SsoSamlCon {
	@Autowired
	private SsoSamlSvc ssoSamlSvc;
	
	private Logger LOGGER = LogManager.getLogger(SsoSamlCon.class);
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 :  
	 * [ 구분 값  ] AI : 전자결재 내부 통신(Login), AO : 전자결재 내부 통신(Logout), GI : 외부 통신(Login), GO : 외부 통신 (Logout)
	 * </pre>
	 * @Method Name : setSamlIDPData
	 * @date : 2017. 7. 24.
	 * @param formObj
	 * @return 
	 * @throws Exception
	 */ 	
	@RequestMapping(value="ssoSamlApi.do" ,method = RequestMethod.POST)
	public @ResponseBody Response setSamlAPI(@RequestBody CoviMap formObj) throws Exception {
		CoviMap responseObj = new CoviMap();
		StringUtil func = new StringUtil();
		int returnStatusCode = 200;
		//AI : 전자결재 내부 통신(Login), AO : 전자결재 내부 통신(Logout), GI : 외부 통신(Login), GO : 외부 통신 (Logout)
		String gubun = "";
		String code = "";
		String id = "";
		String name = "";
		String empno = "";
		String key = "";
		try{
			
			if ("1".equals(PropertiesUtil.getSecurityProperties().getProperty("sso.type"))) {
				name = formObj.has("Name") ? formObj.getString("Name") : "";
				code = formObj.has("Code") ? formObj.getString("Code") : "";
				gubun = formObj.has("Type") ? formObj.getString("Type") : "";
				id = formObj.has("ID") ? formObj.getString("ID") : "";
				empno = formObj.has("EMP") ? formObj.getString("EMP") : "";
				
				//데이터 확인.
				if(func.f_NullCheck(code).equals("")
						|| func.f_NullCheck(id).equals("") 
								|| func.f_NullCheck(name).equals("")
										|| func.f_NullCheck(empno).equals(""))
				{
					responseObj.put("ReturnHeader","fail");
				}else{
					if("GO".equals(gubun)){
						//내부 처리
						
						key = ssoSamlSvc.checkTokenKey(empno);
						SessionHelper.setSSoSession(key, "DELETE",  "Y" );
					}else if("AI".equals(gubun)){
						//내부 처리 (TEST)
						responseObj.put("ReturnHeader","success");
						
					}else if("AO".equals(gubun)){
						//내부 처리 (TEST)
						responseObj.put("ReturnHeader","success");
					}else{
						//ERROR
						responseObj.put("ReturnHeader","fail");
					}
					
				}
			}
			
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch(Exception e){
			LOGGER.debug(e);
		}
		
		LOGGER.info( String.format(" - Response Status [%s] / Response Body [%s]", returnStatusCode, responseObj), this ); 
		
		return Response.status(returnStatusCode).header("status",returnStatusCode ).entity(responseObj).type("text/plain").build();
	}
	
	public @ResponseBody boolean setSamlInsideResponse(@RequestBody CoviMap formObj, HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		CoviMap responseObj = new CoviMap();
		boolean returnResponse = false;
		//DB로 처리할 지 ? 고정 URL ? 몇군데 ? 
		String url = "";
		CoviMap account = new CoviMap();
		
		HttpsUtil httpsUtil = new HttpsUtil();
		
		//AI : 전자결재 내부 통신(Login), AO : 전자결재 내부 통신(Logout), GI : 외부 통신(Login), GO : 외부 통신 (Logout)
		String gubun = "";
		String code = "";
		String id = "";
		String name = "";
		String empno = "";
		String urlReturnStatus = "";
		
		try{
					
			name = formObj.has("Name") ? formObj.getString("Name") : "";
			code = formObj.has("Code") ? formObj.getString("Code") : "";
			gubun = formObj.has("Type") ? formObj.getString("Type") : "";
			id = formObj.has("ID") ? formObj.getString("ID") : "";
			empno = formObj.has("EMP") ? formObj.getString("EMP") : "";
			
			//데이터 확인.
			if(func.f_NullCheck(code).equals("")){
				return returnResponse;
			}else if(func.f_NullCheck(id).equals("")){
				return returnResponse;
			}else if(func.f_NullCheck(name).equals("")){
				return returnResponse;
			}else if(func.f_NullCheck(empno).equals("")){
				return returnResponse;
			}else{
				account.put("Code", code);
				account.put("UserId", id);
				account.put("Name", name);
				account.put("EMP", empno);
				account.put("Type",gubun );
			}
			
			//분기처리
			if("AI".equals(gubun)){
				//외부로 전달 
				url = "http://localhost:8080/covicore/ssoSamlApi.do";
			}else if("AO".equals(gubun)){
				//외부로 전달
				url = "http://localhost:8080/covicore/ssoSamlApi.do";
			}else{
				//ERROR
				return returnResponse;
			}
			
			urlReturnStatus = httpsUtil.httpsClientWithRequest(url, "POST", account, "UTF-8", null, request, response);
		
		} catch (NullPointerException e) {
			return returnResponse;
		} catch(Exception e){
			return returnResponse;
		}
		
		return returnResponse;
	
	}
}
