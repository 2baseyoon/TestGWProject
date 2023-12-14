package egovframework.coviaccount.api.slip.ui;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.nio.charset.StandardCharsets;
import java.util.StringJoiner;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.apache.commons.lang3.StringUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.api.jwt.AuthorizationException;
import egovframework.coviaccount.api.jwt.JwtProvider;
import egovframework.coviaccount.api.jwt.LoginMemberRequest;
import egovframework.coviaccount.api.slip.dto.SlipListReq;
import egovframework.coviaccount.api.slip.service.SlipService;
import egovframework.coviaccount.api.util.ApiLog;
import egovframework.coviaccount.api.util.ApiSaveLog;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;

@RestController
@RequestMapping(value = "/api/slip")
@Api(value = "SlipController_V1")
public class SlipController {
	
	private final ApiSaveLog apiSaveLog;
	private final SlipService slipService;
	private final JwtProvider jwtProvider;

	public SlipController(final SlipService slipService, final JwtProvider jwtProvider, ApiSaveLog apiSaveLog) {
	  this.slipService = slipService;
	  this.jwtProvider = jwtProvider;
	  this.apiSaveLog = apiSaveLog;
	}
	
	@ApiOperation(value = "API 사용을 위한 JWT 발급", notes = "입력한 회원 정보가 올바르면 JWT를 발급합니다.")
	@RequestMapping(value = "/login", method = RequestMethod.POST)
	public ResponseEntity<String> login(@RequestBody LoginMemberRequest loginMemberRequest) {
		try {
			String token = jwtProvider.createToken(loginMemberRequest);
			return ResponseEntity.ok()
		            .header(HttpHeaders.AUTHORIZATION, new StringJoiner(" ")
		            	.add("Bearer ")
		            	.add(token).toString())
		            .body(token);
		} catch (AuthorizationException e) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
		} catch (RuntimeException e) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}
	
	@ApiOperation(value = "연동할 전표 목록", notes = "연동해야 할 전표 목록을 리스트를 보여줍니다.")
	@RequestMapping(value = "/list", method = RequestMethod.POST)
	public ResponseEntity<CoviList> list(HttpServletRequest request, @RequestBody @Valid SlipListReq slipListReq) throws Exception {
		
		HttpHeaders httpHeaders = new HttpHeaders();
		httpHeaders.setContentType(MediaType.valueOf("application/json;charset=UTF-8"));
		ApiLog apiLog = new ApiLog("Slip","R","/api/slip/list", slipListReq.toString()); //API대상, 전송방향(S:전송, R:수신), 요청url, 요청param
		CoviList slipList = new CoviList();
		
		try {
			String token = StringUtils.defaultString(request.getHeader("Authorization"));
			jwtProvider.validateToken(token);
			//pageNo < 1 요청에러
			if(slipListReq.getPageNo() < 1 || slipListReq.getPageSize() < 1) {
				apiLog.setApiStatus(Return.FAIL);
				apiLog.setErrorLog("badRequest");
				return ResponseEntity.badRequest().headers(httpHeaders).body(slipList);
			}
			CoviMap params = slipListReq.getMap();
			int cnt = slipService.listCnt(params);
			CoviMap page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			slipList = slipService.list(params);
			apiLog.setApiStatus(Return.SUCCESS);
			return ResponseEntity.ok().headers(httpHeaders).body(slipList);
		} catch (AuthorizationException e) {
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(slipList);
		} catch (Exception e) {
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(slipList);
		}finally {
			apiSaveLog.saveAccountInterFaceLog(apiLog);
		}
	}
	
	@ApiOperation(value = "연동된 전표 완료 처리", notes = "ERP에서 연동이 완료된 전표를 완료 처리합니다.")
	@RequestMapping(value = "/complete", method = RequestMethod.PATCH)
	public ResponseEntity<Void> complete(HttpServletRequest request, 
			@RequestBody CoviMap params) throws Exception {
		
		ApiLog apiLog = new ApiLog("Slip","R","/api/slip/complete", params); //API대상, 전송방향(S:전송, R:수신), 요청url, 요청param
		
		try {
			String token = StringUtils.defaultString(request.getHeader("Authorization"));
			jwtProvider.validateToken(token);
			//slipNo or expenceApplicationId 없으면 요청에러
			if(!(params.containsKey("slipNo") && params.containsKey("expenceApplicationId"))) {
				apiLog.setApiStatus(Return.FAIL);
				apiLog.setErrorLog("badRequest");
				return ResponseEntity.badRequest().build();
			}
			slipService.complete(params);
			apiLog.setApiStatus(Return.SUCCESS);
			return ResponseEntity.ok().build();
		} catch (AuthorizationException e) {
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		} catch (Exception e) {
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
		}finally {
			apiSaveLog.saveAccountInterFaceLog(apiLog);
		}
	}
	
	@ApiOperation(value = "연동된 전표 취소 처리", notes = "ERP에서 이미 연동이 완료된 전표를 취소 처리합니다.")
	@RequestMapping(value = "/cancel", method = RequestMethod.PATCH)
	public ResponseEntity<Void> cancel(HttpServletRequest request, 
			@RequestBody CoviMap params) throws Exception {
		
		ApiLog apiLog = new ApiLog("Slip","R","/api/slip/cancel", params); //API대상, 전송방향(S:전송, R:수신), 요청url, 요청param
		
		try {
			String token = StringUtils.defaultString(request.getHeader("Authorization"));
			jwtProvider.validateToken(token);
			//slipNo or unSlipNo 없으면 요청에러
			if(!(params.containsKey("slipNo") && params.containsKey("unSlipNo"))) {
				apiLog.setApiStatus(Return.FAIL);
				apiLog.setErrorLog("badRequest");
				return ResponseEntity.badRequest().build();
			}
			slipService.cancel(params);
			apiLog.setApiStatus(Return.SUCCESS);
			return ResponseEntity.ok().build();
		} catch (AuthorizationException e) {
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		} catch (Exception e) {
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
		}finally {
			apiSaveLog.saveAccountInterFaceLog(apiLog);
		}
	}
	
	@ApiOperation(value = "결재 완료 시 연동 전송", notes = "결재 완료 시 ERP에 연동을 하기 위한 외부 API를 호출해서 연동합니다.")
	@RequestMapping(value = "/sendExpenceApplicationID.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendFormInstID(@RequestBody CoviMap params) throws Exception {
		
		CoviMap param = new CoviMap();
		param.put("expenceApplicationID", params.get("ExpenceApplicationID"));
		HttpClientUtil httpClient = new HttpClientUtil();
		String httpCommURL = PropertiesUtil.getExtensionProperties().getProperty("account.api.slip.APIURL"); //http://localhost:8080/account/api/slip/test.do
		ApiLog apiLog = new ApiLog("Slip","S", httpCommURL, param); //API대상, 전송방향(S:전송, R:수신), 요청url, 요청param
		CoviMap resultMap = new CoviMap();
		
		try {
			HttpURLConnection conn = httpClient.createHttpURLConnection(httpCommURL, "POST", "application/json");
			
			try(DataOutputStream dos = new DataOutputStream(conn.getOutputStream());){
				dos.writeBytes(param.toString());
				dos.flush();
			}
			
			StringBuffer sb = new StringBuffer();
			try (BufferedReader bf = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));){
				String inputLine;
				while ((inputLine = bf.readLine()) != null)  {
					sb.append(inputLine);
				}
			}
            String response = sb.toString();
			resultMap.put("status", Return.SUCCESS);
			apiLog.setApiStatus(Return.SUCCESS);
			apiLog.setErrorLog(response);
			apiSaveLog.saveAccountInterFaceLog(apiLog);
			return resultMap;
		} catch (RuntimeException e) {
			resultMap.put("status", Return.FAIL);
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			apiSaveLog.saveAccountInterFaceLog(apiLog);
			return resultMap;
		} catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			apiLog.setApiFail(Return.FAIL, e.getLocalizedMessage());
			apiSaveLog.saveAccountInterFaceLog(apiLog);
			return resultMap;
		}
	}
}
