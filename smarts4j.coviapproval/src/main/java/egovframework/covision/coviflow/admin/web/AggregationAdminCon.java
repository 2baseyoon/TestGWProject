package egovframework.covision.coviflow.admin.web;

import java.lang.invoke.MethodHandles;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.google.gson.Gson;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.admin.dto.AddAggregationFieldsRequestDTO;
import egovframework.covision.coviflow.admin.dto.AggregationAuth;
import egovframework.covision.coviflow.admin.dto.AggregationCommonField;
import egovframework.covision.coviflow.admin.dto.AggregationField;
import egovframework.covision.coviflow.admin.dto.AggregationForm;
import egovframework.covision.coviflow.admin.service.AggregationSvc;

/**
 * @Class Name : AggregationCon.java
 * @Description : 관리자 - 집계함 관리 컨트롤러
 * @Modification Information @ 2022.05.11 최초생성
 *
 * @author 코비젼 연구소
 * @since 2022. 05.11
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved. *
 */
@Controller
@RequestMapping("admin/aggregation")
public class AggregationAdminCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

	@Autowired
	private AggregationSvc aggregationSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	// 공통 필드 추가, 수정 팝업
	@RequestMapping(value = "/form/commonFieldManage.do", method = RequestMethod.GET)
	public ModelAndView goCommonFieldManage() {
		String rtnUrl = "admin/approval/AggregationCommonFieldManage";
		return new ModelAndView(rtnUrl);
	}

	// 집계함 양식 추가 팝업
	@RequestMapping(value = "/form/manage.do", method = RequestMethod.GET)
	public ModelAndView goFormManage() {
		String rtnUrl = "admin/approval/AggregationFormManage";
		return new ModelAndView(rtnUrl);
	}

	// 집계함 양식 선택 팝업
	@RequestMapping(value = "/form/formSelect.do", method = RequestMethod.GET)
	public ModelAndView goFormSelect() {
		String rtnUrl = "admin/approval/AggregationFormSelect";
		return new ModelAndView(rtnUrl);
	}

	// 집계함 필드 추가 팝업
	@RequestMapping(value = "/form/fieldAdd.do", method = RequestMethod.GET)
	public ModelAndView goFieldAdd() {
		String rtnUrl = "admin/approval/AggregationFieldAdd";
		return new ModelAndView(rtnUrl);
	}

	// 도메인별 하위테이블 사용 양식 목록 조회
	@RequestMapping(value = "/forms-using-subtable.do", method = { RequestMethod.GET, RequestMethod.POST })
	public ResponseEntity<CoviMap> getApprovalFormsUsingSubTable(
			@RequestParam(value = "entCode", required = true) String entCode) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviList forms = aggregationSvc.getApprovalFormsUsingSubTable(entCode);
			returnObj.put("list", forms);
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

	// 집계함 양식 목록 조회
	@RequestMapping(value = "/forms.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAggregationForms(HttpServletRequest request, @RequestParam HashMap<String, Object> paramMap) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			CoviMap forms = aggregationSvc.getAggregationForms(params);
			returnObj.put("page", forms.get("page"));
			returnObj.put("list", forms.get("list"));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}

	// 집계함 양식 정보 추가
	@RequestMapping(value = "/form.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> addAggrgationForm(@RequestBody AggregationForm aggregationForm) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.addAggregationForm(aggregationForm);
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

	// 집계함 양식 정보 수정
	@RequestMapping(value = "/form/{aggFormId}", method = RequestMethod.PUT)
	public ResponseEntity<CoviMap> modifyAggrgationForm(@RequestBody AggregationForm aggregationForm) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.modifyAggrgationForm(aggregationForm);
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

	// 집계함 양식 정보 삭제
	@RequestMapping(value = "/form/{aggFormId}", method = RequestMethod.DELETE)
	public ResponseEntity<CoviMap> deleteAggrgationFormByAggFormId(@PathVariable String aggFormId) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.deleteAggrgationFormByAggFormId(aggFormId);
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

	// 집계함 양식 권한 목록조회
	@RequestMapping(value = "/form/authList.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> getAggregationAuth(@RequestParam HashMap<String, Object> paramMap) {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try {
			List<AggregationAuth> authList = aggregationSvc.getAggregationFormAuth(params);
			CoviMap page = new CoviMap();
			page.put("listCount", authList.size());	//rowCount: 전체 Row 갯수 
			returnObj.put("page", page);
			returnObj.put("list", authList);
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(),npE);
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
	
	// 집계함 양식 권한 추가
	@RequestMapping(value = "/form/auth.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> addAggregationAuth(@RequestBody List<AggregationAuth> aggregationAuths) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.addAggregationAuths(aggregationAuths);
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

	@RequestMapping(value = "/form/auth.do", method = RequestMethod.DELETE)
	public ResponseEntity<CoviMap> deleteAggregationAuthByAggAuthIds(@RequestBody List<String> authIds) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.deleteAggregationAuthByAggAuthIds(authIds);
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

	// 집계함 양식 설정된 항목 목록조회
	@RequestMapping(value = "/form/fields.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> getAggregationFields(@RequestParam HashMap<String, Object> paramMap) {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try {
			List<AggregationField> fieldList = aggregationSvc.getAggregationFormFields(params);
			returnObj.put("list", fieldList);
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(),npE);
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
	
	// 집계함 양식 공통 필드 및 필드 정보 조회
	@RequestMapping(value = "/form/fieldsForAdd.do", method = RequestMethod.GET)
	public ResponseEntity<CoviMap> selectAggregationFieldsForAdd(@RequestParam String entCode,
			@RequestParam String aggFormId) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap info = aggregationSvc.selectAggregationNotUsingFields(aggFormId, entCode);
			returnObj.put("info", info);
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

	// 집계함 공통 필드 추가
	@RequestMapping(value = "/form/commonfield.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> addCommonField(@RequestBody AggregationCommonField commonField) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.addCommonField(commonField);
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

	// 집계함 공통 필드 조회
	@RequestMapping(value = "/form/commonfields.do", method = { RequestMethod.GET, RequestMethod.POST })
	public ResponseEntity<CoviMap> getCommonFields(@RequestParam String entCode,
			@RequestParam(defaultValue = "sortKey asc") String sortBy) {
		CoviMap returnObj = new CoviMap();
		try {
			String[] sort = sortBy.split(" ");
			CoviMap param = new CoviMap();
			param.put("entCode", entCode);
			param.put("sortColumn", sort[0]);
			param.put("sortDirection", sort[1]);
			List<AggregationCommonField> list = aggregationSvc.getCommonFields(param);
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

	// 집계함 공통 필드 단건 조회
	@RequestMapping(value = "/form/commonfield/{fieldId}", method = { RequestMethod.GET })
	public ResponseEntity<CoviMap> getCommonField(@PathVariable String fieldId) {
		CoviMap returnObj = new CoviMap();
		try {
			AggregationCommonField field = aggregationSvc.getCommonField(fieldId);
			returnObj.put("info", field.toString());
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

	// 집계함 공통 필드 수정
	@RequestMapping(value = "/form/commonfield/{fieldId}", method = RequestMethod.PUT)
	public ResponseEntity<CoviMap> modifyCommonField(@RequestBody AggregationCommonField commonField) {
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.modifyCommonField(commonField);
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

	// 집계함 공통 필드 삭제
	@RequestMapping(value = "/form/commonfield/{fieldId}", method = RequestMethod.DELETE)
	public ResponseEntity<CoviMap> deleteCommonField(@RequestBody AggregationCommonField commonField) { // @PathVariable String fieldId
		CoviMap returnObj = new CoviMap();
		try {
			aggregationSvc.deleteCommonField(commonField);
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
	
	/**
	 * 항목 일괄저장.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "form/saveFormFields.do", method = {RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap saveFormFields(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			String strFieldList = StringUtil.replaceNull(request.getParameter("FieldList"), "[]"); 
			String strOldFieldKey = StringUtil.replaceNull(request.getParameter("OldFieldKey"), "[]");
			
			CoviList fieldList = CoviList.fromObject(StringEscapeUtils.unescapeHtml(strFieldList)); // 입력받은 필드정보
			CoviList oldFieldKey = CoviList.fromObject(StringEscapeUtils.unescapeHtml(strOldFieldKey)); // 기존 필드정보
			
			// aggFormId, entCode
			CoviMap params = new CoviMap(paramMap);
			
			int cnt = aggregationSvc.saveAggregationFields(params, fieldList, oldFieldKey);
			
			returnList.put("object", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
}
