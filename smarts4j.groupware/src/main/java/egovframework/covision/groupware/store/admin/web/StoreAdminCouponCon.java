package egovframework.covision.groupware.store.admin.web;

import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.store.admin.service.StoreAdminCouponSvc;

@Controller
public class StoreAdminCouponCon {
	private static final Logger LOGGER = LogManager.getLogger(StoreAdminCouponCon.class);
			
	@Autowired
	private StoreAdminCouponSvc storeAdminCouponService;
	
	@RequestMapping(value = "store/getAdminCouponList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminFolderList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[0]; 
			String sortDirection = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  params.getInt("pageNo");
			if (params.get("pageSize") != null && params.optString("pageSize").length() > 0){
				pageSize = params.getInt("pageSize");
			}
		
			CoviMap resultList = null;
			
			String search = params.getString("search");
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100)); // 회사명 검색
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = storeAdminCouponService.getCouponListData(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "store/getAdminCouponEventList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminCouponEventList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[0]; 
			String sortDirection = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  params.getInt("pageNo");
			if (params.get("pageSize") != null && params.optString("pageSize").length() > 0){
				pageSize = params.getInt("pageSize");
			}
		
			CoviMap resultList = null;
			
			String search = params.getString("search");
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100)); // 회사명 검색
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = storeAdminCouponService.getCouponEventData(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "store/getDomainCouponList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDomainCouponList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[0]; 
			String sortDirection = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  params.getInt("pageNo");
			if (params.get("pageSize") != null && params.optString("pageSize").length() > 0){
				pageSize = params.getInt("pageSize");
			}
		
			CoviMap resultList = null;
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("DomainID", SessionHelper.getSession("DN_ID"));
			
			resultList = storeAdminCouponService.getCouponListData(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "store/getDomainCouponEventList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDomainCouponEventList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			
			String sortColumn = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[0]; 
			String sortDirection = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  params.getInt("pageNo");
			if (params.get("pageSize") != null && params.optString("pageSize").length() > 0){
				pageSize = params.getInt("pageSize");
			}
		
			CoviMap resultList = null;
			
			String search = params.getString("search");
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100)); // 회사명 검색
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = storeAdminCouponService.getCouponEventData(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * Coupon 등록(추가) 팝업
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "store/goCouponAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goAdminFormPopup(Locale locale, Model model) {		
		String returnURL = "manage/store/CouponAddPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 회사별 쿠폰 등록/사용 Event 목록조회 팝업
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "store/goCouponEventListPopup.do", method = RequestMethod.GET)
	public ModelAndView goCouponEventListPopup(Locale locale, Model model) {		
		String returnURL = "manage/store/CouponEventListPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 쿠폰추가 - 갯수만큼 쿠폰데이터 추가.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "store/insertAdminCouponData.do", method = RequestMethod.POST)	
	public @ResponseBody CoviMap insertAdminFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			
			storeAdminCouponService.addCouponData(params);

			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * 쿠폰 선택 팝업 (구매시)
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "store/goCouponSelectListPopup.do", method = RequestMethod.GET)
	public ModelAndView goCouponSelectListPopup(Locale locale, Model model) {		
		String returnURL = "manage/store/CouponSelectPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 고객사관리자 Item 구매시 쿠폰사용 선택팝업.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "store/getCouponSelectList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCouponSelectList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			params.put("DomainID", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			String sortColumn = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[0]; 
			String sortDirection = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  params.getInt("pageNo");
			if (params.get("pageSize") != null && params.optString("pageSize").length() > 0){
				pageSize = params.getInt("pageSize");
			}
		
			CoviMap resultList = null;
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = storeAdminCouponService.getCouponDetailListData(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * [API] 회사별 쿠폰조회 , 오류시 Exception
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "store/getCouponCountInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCouponCountInfo(HttpServletRequest request, HttpServletResponse response, @RequestBody Map<String, String> paramMap) throws Exception {
		CoviMap params = new CoviMap(paramMap);
		CoviMap returnList = new CoviMap();
		
		CoviMap result = storeAdminCouponService.getDomainCouponInfo(params);
		
		returnList.put("status", Return.SUCCESS);
		CoviMap info = new CoviMap();
		info.put("totCnt", result.optInt("TotCount", 0));
		info.put("useCnt", result.optInt("UseCount", 0));
		info.put("remainCnt", result.optInt("TotCount", 0) - result.optInt("UseCount", 0));
		returnList.put("info", info);
		
		return returnList;
	}
	
	/**
	 * [API] 쿠폰 사용
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "store/consumeCoupon.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap consumeCoupon(HttpServletRequest request, HttpServletResponse response, @RequestBody Map<String, String> paramMap) throws Exception {
		// System error 발생시 호출한 쪽에서 Rollback 할 수 있도록 예외처리 하지 않는다.
		CoviMap params = new CoviMap(paramMap);
		params.put("EventType", "CONSUME");
		CoviMap returnList = new CoviMap();
		
		CoviMap result = storeAdminCouponService.updateCouponData(params);
		
		returnList.put("status", Return.SUCCESS);
		returnList.put("EventID", result.optString("EventID"));
		return returnList;
	}
	
	/**
	 * [Scheduler][API] 쿠폰 만료 (회사구분 없음, ORGROOT 에 등록)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "store/expireCoupon.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap expireCoupon(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			
			storeAdminCouponService.expireCoupon(params);
			
			returnList.put("status", Return.SUCCESS);
			
			return returnList;
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
}
