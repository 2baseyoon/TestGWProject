package egovframework.covision.coviflow.user.web;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.user.service.SeriesFunctionSvc;

@Controller
public class SeriesFunctionCon {
	private static Logger LOGGER = LogManager.getLogger(SeriesFunctionCon.class);

	@Autowired
	private SeriesFunctionSvc oSeriesFunctionSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getSeriesFunctionAddPopup - 업무구분 생성 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/SeriesFunctionAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getSeriesFunctionAddPopup(Locale locale, Model model) throws Exception
	{
		String returnURL = "user/approval/SeriesFunctionAddPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * insertSeriesFunctionData - 업무구분 추가
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertSeriesFunctionData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertSeriesFunctionData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			String parentFunctionCode = StringUtil.replaceNull(request.getParameter("ParentFunctionCode")); // 상위 업무구분 코드
			String functionCode = request.getParameter("FunctionCode"); // 업무구분 코드
			String functionName = request.getParameter("FunctionName"); // 업무구분명
			String sort = StringUtil.replaceNull(request.getParameter("Sort")); // 업무구분 정렬
			String functionLevel = "1"; // 업무구분 레벨
			
			// 코드 중복 체크
			CoviMap params = new CoviMap();
			params.put("FunctionCode", functionCode);
			int dupCodeCnt = oSeriesFunctionSvc.getDupFunctionCodeCnt(params);
			if (dupCodeCnt > 0) {
				returnList.put("status", "EXISTS");
				returnList.put("message", DicHelper.getDic("Approval_AlreadyExistsClassCode")); // 이미 존재하는 업무구분코드입니다.
				return returnList;
			} else {
				// 하위 업무구분 생성시 레벨을 가져온다.
				if (!parentFunctionCode.equals("")) {
					params = new CoviMap();
					params.put("ParentFunctionCode", parentFunctionCode);
					
					functionLevel = oSeriesFunctionSvc.getFunctionLevel(params);
				}
				
				// 정렬을 입력하지 않은 경우 해당 뎁스에 마지막 정렬값을 찾아온다.
				if (sort.equals("")) {
					params = new CoviMap();
					params.put("ParentFunctionCode", parentFunctionCode);
					
					sort = oSeriesFunctionSvc.getFunctionLastSort(params);
				} else {
					// 정렬을 입력한 경우 다른 업무구분 코드 정렬을 우선 업데이트 시킨다.
					params = new CoviMap();
					params.put("ParentFunctionCode", parentFunctionCode);
					params.put("Sort", sort);
					
					oSeriesFunctionSvc.updateFunctionSort(params);
				}
				
				// 업무구분코드 생성
				params = new CoviMap();
				params.put("ParentFunctionCode", parentFunctionCode);
				params.put("FunctionCode", functionCode);
				params.put("FunctionName", functionName);
				params.put("FunctionLevel", functionLevel);
				params.put("Sort", sort);
				
				int result = oSeriesFunctionSvc.insertSeriesFunction(params);
				if (result > 0) {
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", DicHelper.getDic("msg_37")); // 저장되었습니다.
				} else {
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_apv_030")); // 오류가 발생했습니다.
					return returnList;
				}
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/**
	 * updateSeriesFunctionData - 업무구분 수정
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateSeriesFunctionData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSeriesFunctionData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			String functionCode = request.getParameter("FunctionCode"); // 업무구분 코드
			String functionName = request.getParameter("FunctionName"); // 업무구분명
			String sort = request.getParameter("Sort"); // 업무구분 정렬
			
			CoviMap params = new CoviMap();
			params.put("FunctionCode", functionCode);
			params.put("FunctionName", functionName);
			params.put("Sort", Integer.parseInt(sort));
			
			int result = oSeriesFunctionSvc.updateSeriesFunction(params);
			if (result > 0) {
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_37")); // 저장되었습니다.
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030")); // 오류가 발생했습니다.
				return returnList;
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			}
		return returnList;
	}

	/**
	 * deleteSeriesFunctionData - 업무구분 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteSeriesFunctionData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteSeriesFunctionData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			String functionCode = request.getParameter("FunctionCode"); // 업무구분 코드
			
			// 하위 업무구분코드 여부 확인
			CoviMap params = new CoviMap();
			params.put("FunctionCode", functionCode);
			int subCodeCnt = oSeriesFunctionSvc.getIsSubFunctionCodeCnt(params);
			if (subCodeCnt > 0) {
				returnList.put("status", "EXISTS");
				returnList.put("message", DicHelper.getDic("Approval_SubClassCodeExistsNotDelete")); // 하위 업무구분코드가 존재합니다. 삭제할 수 없습니다.
				return returnList;
			} else {
				int result = oSeriesFunctionSvc.deleteSeriesFunction(params);
				if (result > 0) {
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", DicHelper.getDic("msg_50")); // 삭제되었습니다.
				} else {
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_apv_030")); // 오류가 발생했습니다.
					return returnList;
				}
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}