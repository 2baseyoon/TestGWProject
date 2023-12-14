package egovframework.covision.groupware.bizcard.user.web;

import java.io.IOException;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.bizcard.user.service.BizCardUtilService;
import egovframework.covision.groupware.bizcard.user.util.BizCardUtils;

/**
 * @Class Name : BizCardUtilCon.java
 * @Description : 인명관리 Utility 요청 처리
 * @Modification Information @ 2017.07.28 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2017.07.28
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/bizcard")
public class BizCardUtilCon {
	// log4j obj
	private Logger LOGGER = LogManager.getLogger(BizCardUtilCon.class);

	@Autowired
	private BizCardUtilService bizCardUtilService;

	// 엑셀 다운로드
	@RequestMapping(value = "ExportBizCardToFile.do", method = RequestMethod.GET)
	public ModelAndView exportBizCardToFile(HttpServletRequest request,
			HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();

		try {
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String sortColumn = request.getParameter("sortColumn");
			String sortDirection = request.getParameter("sortDirection");
			String fileType = StringUtil.replaceNull(request.getParameter("fileType"), "");
			fileType = fileType.replaceAll("[\\r\\n]", "");
			String targetType = request.getParameter("targetType");
			String shareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
			String sField = request.getParameter("sField");
			String headerName = request.getParameter("headerName");
			headerName = URLDecoder.decode(headerName, "UTF-8") ;
			
			String Type_P = StringUtil.replaceNull(request.getParameter("type_p"), "");
			String Type_D = StringUtil.replaceNull(request.getParameter("type_d"), "");
			String Type_U = StringUtil.replaceNull(request.getParameter("type_u"), "");
			String bizCardID = StringUtil.replaceNull(request.getParameter("bizCardID"), "");
			String bizGroupID = request.getParameter("bizGroupID");
			
			String GroupID = (Type_P + Type_D + Type_U).replace("&apos;&apos;", "&apos;,&apos;");
			GroupID = GroupID.replace("&apos;", "");
			
			String[] headerNames = headerName.split(";");
			String[] shareTypeArr = shareType.replaceAll("\'", "").replaceAll("&apos;", "").split(",");
			String[] GroupIDArr = GroupID.replaceAll("\'", "").split(",");
			String[] bizCardIDArr = bizCardID.equals("") ? null : bizCardID.replaceAll("\'", "").replaceAll("&apos;", "").split(",");
			String[] bizGroupIDArr = bizGroupID.equals("") ? null : bizGroupID.replaceAll("\'", "").replaceAll("&apos;", "").split(",");

			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UR_Code", strUR_Code);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100)); //RegistDate
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100)); //DESC
			params.put("fileType", fileType); //CSV, CSV_EX, EXCEL
			params.put("targetType", targetType); //전체(ALL), 구분(ShareType), 개별(Each)
			//params.put("ShareType", shareType); //개인(P), 부서(D), 회사(U)
			params.put("ShareType", shareType); //개인(P), 부서(D), 회사(U)
			params.put("ShareTypeArr", shareTypeArr); //개인(P), 부서(D), 회사(U)
			params.put("sField", "&quot;" + sField + "&quot;"); //선택된 항목(이름, 전화번호 등) value
			params.put("headerName", headerName); //선택된 항목 text
			//params.put("GroupID", (Type_P + Type_D + Type_U).replace("&apos;&apos;", "&apos;,&apos;")); //그룹 아이디
			params.put("GroupID", GroupID); //그룹 아이디
			params.put("GroupIDArr", GroupIDArr); //그룹 아이디
			params.put("BizCardID", bizCardID); //연락처 아이디
			params.put("BizCardIDArr", bizCardIDArr); //연락처 아이디
			params.put("BizGroupID", bizGroupID); //연락처 아이디
			params.put("BizGroupIDArr", bizGroupIDArr); //연락처 아이디
//			params.put("Type_P", Type_P); //개인 그룹
//			params.put("Type_D", Type_D); //부서 그룹
//			params.put("Type_U", Type_U); //회사 그룹

			if (fileType.equals("EXCEL")) {
				resultList = bizCardUtilService.selectBizCardExcelList(params);
				returnURL = "UtilExcelView";
				
				viewParams.put("list", resultList.get("list"));
				viewParams.put("cnt", resultList.get("cnt"));
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "BizCard");
				mav = new ModelAndView(returnURL, viewParams);
				
			} else if (fileType.contains("CSV")) {
				Date today = new Date();
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
				
				resultList = bizCardUtilService.selectBizCardCSVList(params);
  				byte[] firstString = resultList.get("sb").toString().getBytes("EUC-KR");
 
				response.setContentType("text/csv");
				response.setHeader("Content-Disposition", "attachment; filename=" + dateFormat.format(today)+"_"+ "BizCard" + "_" + fileType.toLowerCase() + ".csv");
				
				try (OutputStream outputStream = response.getOutputStream();){
					outputStream.write(firstString);
				}
				
			} else if (fileType.contains("VCF")) {
				Date today = new Date();
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");

				resultList = bizCardUtilService.selectBizCardVCFList(params);
  				byte[] firstString = resultList.get("sb").toString().getBytes("EUC-KR");

  				response.setContentType("text/vcard");
  				response.setCharacterEncoding("UTF-8");
  				response.setStatus(HttpServletResponse.SC_OK);
				response.setHeader("Content-Disposition", "attachment; filename=" + dateFormat.format(today)+"_"+ "BizCard" + "_" + fileType.toLowerCase() + ".vcf");
				
				try (OutputStream outputStream = response.getOutputStream();){
					outputStream.write(firstString);
				}
			}

		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}
	
	@SuppressWarnings({ "unchecked", "null" })
	@RequestMapping(value="getImportedBizCardList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getImportedBizCardList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		
		String strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
		String arrData[] = strData.split("§");
		String indexArr[] = new String[18]; 
		
		CoviList listData = new CoviList();
		CoviMap mapData;
		
		for(int i = 0; i < arrData.length; i++) {
			String tempArr[] = arrData[i].split("†");
			mapData = new CoviMap();
			for(int j = 0; j < tempArr.length; j++) {
				if(i == 0) {
					if(tempArr[j].equals("전체 이름") || tempArr[j].equals("이름") || tempArr[j].equals(DicHelper.getDic("lbl_name"))) {
						indexArr[j] = "Name";
					} else if (tempArr[j].equals("기념일") || tempArr[j].equals(DicHelper.getDic("lbl_AnniversarySchedule"))) {
						indexArr[j] = "AnniversaryText";
					} else if ((tempArr[j].indexOf("전자 메일") > -1 && tempArr[j].indexOf("주소") > -1) || tempArr[j].equals(DicHelper.getDic("lbl_Email2"))) {
						indexArr[j] = "Email"+j;
					} else if (tempArr[j].equals("메신저") || tempArr[j].equals(DicHelper.getDic("lbl_Messenger"))) {
						indexArr[j] = "MessengerID";
					} else if (tempArr[j].equals("메모") || tempArr[j].equals(DicHelper.getDic("lbl_Memo"))) {
						indexArr[j] = "Memo";
					} else if (tempArr[j].equals("휴대폰") || tempArr[j].equals(DicHelper.getDic("lbl_MobilePhone"))) {
						indexArr[j] = "CellPhone";
					} else if (tempArr[j].equals("전화") || tempArr[j].equals("집 전화 번호") || tempArr[j].equals(DicHelper.getDic("lbl_HomePhone"))) {
						indexArr[j] = "HomePhone";
					} else if (tempArr[j].equals("회사 전화") || tempArr[j].equals("근무처 전화") || tempArr[j].equals(DicHelper.getDic("lbl_Office_Line"))) {
						indexArr[j] = "ComPhone";
					} else if (tempArr[j].equals("회사 팩스") || tempArr[j].equals("근무지 팩스") || tempArr[j].equals(DicHelper.getDic("lbl_Office_Fax"))) {
						indexArr[j] = "FAX";
					} else if (tempArr[j].equals("회사 웹 페이지") || tempArr[j].equals("웹 페이지") || tempArr[j].equals(DicHelper.getDic("lbl_homepage"))) {
						indexArr[j] = "ComWebsite";
					} else if (tempArr[j].equals("회사") || tempArr[j].equals(DicHelper.getDic("lbl_company"))) {
						indexArr[j] = "ComName";
					} else if (tempArr[j].equals("부서") || tempArr[j].equals(DicHelper.getDic("lbl_dept"))) {
						indexArr[j] = "DeptName";
					} else if (tempArr[j].equals("직함") || tempArr[j].equals(DicHelper.getDic("lbl_JobTitle"))) {
						indexArr[j] = "JobTitle";
					} else if (tempArr[j].equals("우편 번호(회사)") || tempArr[j].equals("근무지 우편 번호") || tempArr[j].equals(DicHelper.getDic("lbl_ComZipCode"))) {
						indexArr[j] = "ComZipcode";
					} else if (tempArr[j].equals("주소(회사)") || tempArr[j].equals("근무지 주소 번지") || tempArr[j].equals(DicHelper.getDic("lbl_ComAddress"))) {
						indexArr[j] = "ComAddress";
					} else if (tempArr[j].equals("기타") || tempArr[j].equals(DicHelper.getDic("lbl_EtcPhone"))) {
						indexArr[j] = "EtcPhone";
					} else if (tempArr[j].equals("직접입력") || tempArr[j].equals(DicHelper.getDic("lbl_DirectPhone"))) {
						indexArr[j] = "DirectPhone";
					} else {
						indexArr[j] = "";
					}
				} else {
					mapData.put(indexArr[j], tempArr[j]);
				}
			}
			
			if(i >= 1) { //(pageSize * (pageNo-1) + 1) && i <= (pageSize * pageNo)
				String emailStr = "";
				List<String> emailArr = new ArrayList<String>();
				Iterator<Entry<String, String>> iter = mapData.entrySet().iterator();
				
				for(Object obj : mapData.keySet()){
					String key = obj.toString();
					
					if(key.indexOf("Email") > -1 && !mapData.getString(key).equals("")){
						emailArr.add(mapData.getString(key));
					}
				}
				
				if(emailArr != null && emailArr.size() > 0) {
					emailStr = StringUtils.join(emailArr, " ,");					
				}
				
				while(iter.hasNext()){
					String key = iter.next().getKey();
					
					if(key.indexOf("Email") > -1) {
						iter.remove();
					}
				}
				
				mapData.put("Email", emailStr);
				
				listData.add(mapData);
			}
		}
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData);
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	// 템플릿 파일 다운로드
	@RequestMapping(value = "/excelTemplateDownload.do")
	public ModelAndView excelTemplateDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		CoviList list = new CoviList();
		String fileType = StringUtil.replaceNull(request.getParameter("fileType"), "");
		String sField = "Name,CellPhone,EMAIL,MessengerID,ComName,ComPhone,FAX,DeptName,JobTitle,Memo,EtcPhone,HomePhone,DirectPhone";
		
		CoviMap sampleData = new CoviMap();
		sampleData.put("Name", "이름");
		sampleData.put("CellPhone", "핸드폰");		
		sampleData.put("EMAIL", "이메일");
		sampleData.put("MessengerID", "메신저");
		sampleData.put("ComName", "회사");
		sampleData.put("ComPhone", "사무실전화");
		sampleData.put("FAX", "사무실팩스");
		sampleData.put("DeptName", "부서");
		sampleData.put("JobTitle", "직책");
		sampleData.put("Memo", "메모");
		sampleData.put("EtcPhone", "기타전화");
		sampleData.put("HomePhone", "자택전화");
		sampleData.put("DirectPhone", "(입력)전화번호");		
		list.add(sampleData);
		
		try {
			if (fileType.equals("EXCEL")) {
				String returnURL = "UtilExcelView";
				CoviMap viewParams = new CoviMap();
				String[] headerNames = null;
				
				headerNames = new String [] {"이름","핸드폰","이메일","메신저","회사","사무실전화","사무실팩스","부서","직책","메모","기타전화","자택전화","직접입력전화"};
				
				viewParams.put("list", BizCardUtils.coviSelectJSONForExcel(list, sField));
				viewParams.put("cnt", 0);
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "BizCardTemplate");
				mav = new ModelAndView(returnURL, viewParams);
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}  catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}

	// 템플릿 파일 다운로드
	@RequestMapping(value = "/csvTemplateDownload.do")
	public void csvTemplateDownload(HttpServletRequest request, HttpServletResponse response) {
		String fileType = StringUtil.replaceNull(request.getParameter("fileType"), "");
		fileType = fileType.replaceAll("[\\r\\n]", "");
		try {
			if (fileType.contains("CSV")) {
				Date today = new Date();
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
				String temp = "";
				if(fileType.equals("CSV_EX")) {
					temp = "이름,성,중간 이름,전체 이름,애칭,전자 메일 주소,주소(집),구/군/시(집),우편 번호(집),시/도(집),국가(집),전화,집 팩스,휴대폰,개인 웹 페이지,주소(회사),구/군/시(회사),우편 번호(회사),시/도(회사),국가(회사),회사 웹 페이지,회사 전화,회사 팩스,호출기,회사,직함,부서,사무실,메모,기념일,메신저\r\n,,,전체 이름,,전자 메일 주소,,,,,,전화,,휴대폰,,주소(회사),,우편번호(회사),,,회사 웹 페이지,회사 전화,회사 팩스,,회사,직책,부서,,메모,기념일,메신저,";
				} else if(fileType.equals("CSV")) {
					temp = "호칭(영문),이름,중간 이름,성,호칭(한글),회사,부서,직함,근무지 주소 번지,근무지 번지 2,근무지 번지 3,근무지 구/군/시,근무지 시/도,근무지 우편 번호,근무지 국가,집 번지,집 번지 2,집 번지 3,집 주소 구/군/시,집 주소 시/도,집 주소 우편 번호,집 주소 국가,기타 번지,기타 번지 2,기타 번지 3,기타 구/군/시,기타 시/도,기타 우편 번호,기타 국가,비서 전화 번호,근무지 팩스,근무처 전화,근무처 전화 2,다시 걸 전화,카폰,회사 대표 전화,집 팩스,집 전화 번호,집 전화 2,ISDN,휴대폰,기타 팩스,기타 전화,호출기,기본 전화,무선 전화,TTY/TDD 전화,텔렉스,거리,기념일,메신저,관리자 이름,국가,근무처 주소 사서함,기타 주소 사서함,디렉터리 서버,머리글자,메모,배우자,범주 항목,비서 이름,비용 정보,사무실 위치,사용자 1,사용자 2,사용자 3,사용자 4,생일,성별,숨김,언어,우선 순위,우편물 종류,웹 페이지,인터넷 약속 있음/약속 없음,자녀,전자 메일 주소,전자 메일 유형,전자 메일 표시 이름,전자 메일 2 주소,전자 메일 2 유형,전자 메일 2 표시 이름,전자 메일 3 주소,전자 메일 3 유형,전자 메일 3 표시 이름,주민 등록 번호,중심어,직업,집 주소 사서함,추천인,취미,ID 번호\r\n,이름,,,,회사,부서,직책,근무지 주소 번지,,,,,근무지 우편 번호,,,,,,,,,,,,,,,,,근무지 팩스,근무처 전화,,,,,,집 전화 번호,,,휴대폰,,,,,,,,,기념일,메신저,,,,,,,메모,,,,,,,,,,,,,,,,웹 페이지,,,전자 메일 주소,,,전자 메일 2 주소,,,전자 메일 3 주소,,,,,,,,,,";
				}
  				byte[] firstString = temp.getBytes("EUC-KR");

				response.setContentType("text/csv");
				response.setHeader("Content-Disposition", "attachment; filename=" + dateFormat.format(today)+"_"+ "BizCardTemplate" + "_" + fileType.toLowerCase() + ".csv");
				
				try (OutputStream outputStream = response.getOutputStream();){
					outputStream.write(firstString);
				}
			}
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
	}
	
}
