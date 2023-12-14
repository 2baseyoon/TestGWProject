package egovframework.covision.coviflow.user.web;

import java.lang.invoke.MethodHandles;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.AggregationSvc;

/**
 * @Class Name : AggregationCon.java
 * @Description : 사용자 - 집계함 관리 컨트롤러
 * @Modification Information @ 2022.05.11 최초생성
 *
 * @author 코비젼 연구소
 * @since 2022. 05.11
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved. *
 */
@Controller
@RequestMapping("user/aggregation")
public class AggregationCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

	@Autowired
	AggregationSvc aggregationSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	// 사용자에게 권한이 부여된 양식 개수 확인
	@RequestMapping(value = "/counts.do", method = RequestMethod.GET)
	public ResponseEntity<CoviMap> getAggregationFormsCnt() {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap map = new CoviMap();
			// 결재 사용자정보와 같은값으로 통일(initUserInfo , hasReadAuthDefault)
			map.put("UserID", SessionHelper.getSession("USERID"));
			map.put("DeptID", SessionHelper.getSession("DEPTID"));
			map.put("entCode", SessionHelper.getSession("DN_Code"));

			int count = aggregationSvc.getAggregationFormsCnt(map);
			returnObj.put("count", count);
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		}
		return ResponseEntity.ok(returnObj);
	}

	// 사용자에게 권한이 부여된 양식 목록 조회
	@RequestMapping(value = "/forms.do", method = RequestMethod.GET)
	public ResponseEntity<CoviMap> getAggregationForms(@RequestParam String aggFormId) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap map = new CoviMap();
			map.put("userCode", SessionHelper.getSession("UR_Code"));
			map.put("groupCode", SessionHelper.getSession("GR_Code"));
			map.put("companyCode", SessionHelper.getSession("DN_Code"));
			if(!aggFormId.isEmpty()) map.put("aggFormId", aggFormId);
			
			CoviList list = aggregationSvc.getAggregationFormsSimple(map);
			returnObj.put("list", list.toString());
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		}
		return ResponseEntity.ok(returnObj);
	}

	// 양식별 집계함 목록 조회
	@RequestMapping(value = "/forms/list/{aggFormId}.do", method = { RequestMethod.GET, RequestMethod.POST })
	public ResponseEntity<CoviMap> getAggregationFormListByAggFormId(@PathVariable String aggFormId,
			@RequestParam(defaultValue = "") String sortBy, @RequestParam(defaultValue = "10") int pageSize,
			@RequestParam(defaultValue = "1") int pageNo, @RequestParam(defaultValue = "") String searchType,
			@RequestParam(defaultValue = "") String searchWord,
			@RequestParam(defaultValue = "All") String searchGroupType) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap map = new CoviMap();
			map.put("userCode", SessionHelper.getSession("UR_Code"));
			map.put("groupCode", SessionHelper.getSession("GR_Code"));
			map.put("companyCode", SessionHelper.getSession("DN_Code"));
			map.put("aggFormId", aggFormId);
			map.put("sortBy", sortBy);
			map.put("pageSize", pageSize);
			map.put("pageNo", pageNo);
			map.put("searchType", searchType);
			map.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			map.put("searchGroupType", searchGroupType);

			CoviMap listObj = aggregationSvc.getAggregationFormListByAggFormId(map);
			returnObj.put("list", listObj.get("list"));
			returnObj.put("page", listObj.get("page"));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		}
		return ResponseEntity.ok(returnObj);
	}

	// 양식별 집계함 헤더 조회
	@RequestMapping(value = "/forms/header/{aggFormId}.do", method = RequestMethod.GET)
	public ResponseEntity<CoviMap> getAggregationFormHeaderByAggFormId(@PathVariable String aggFormId) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap map = new CoviMap();
			map.put("userCode", SessionHelper.getSession("UR_Code"));
			map.put("groupCode", SessionHelper.getSession("GR_Code"));
			map.put("companyCode", SessionHelper.getSession("DN_Code"));
			map.put("aggFormId", aggFormId);

			CoviList list = aggregationSvc.getAggregationFormHeaderByAggFormId(map);
			returnObj.put("list", list);
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		}
		return ResponseEntity.ok(returnObj);
	}
}
