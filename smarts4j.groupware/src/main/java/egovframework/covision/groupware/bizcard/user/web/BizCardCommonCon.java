package egovframework.covision.groupware.bizcard.user.web;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
/**
 * @Class Name : BizCardCommonCon.java
 * @Description : 인명관리 일반적 요청 처리
 * @Modification Information 
 * @ 2017.07.28 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2017.07.28
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/bizcard")
public class BizCardCommonCon {
	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(BizCardCommonCon.class);
	
	@RequestMapping(value = "/bizcardhome.do", method = RequestMethod.GET)
	public ModelAndView workReportHome() throws Exception {
		
		String returnUrl = "user/bizcard/BizCardFavoriteList.bizcard"; //즐겨찾기 목록
		ModelAndView mav = new ModelAndView(returnUrl);
		
		return mav;
	}
	
	@RequestMapping(value = "/bizcard_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView directBizCardLeftMenu(@PathVariable String strPage) throws Exception{
		
		String returnUrl = "user/bizcard/" + strPage + ".bizcard";
		ModelAndView mav = new ModelAndView(returnUrl);
		
		return mav;
	}
	
	@RequestMapping(value = "/bizcardheader.do", method = RequestMethod.GET)
	public ModelAndView getHeader() throws Exception {
		String returnUrl = "cmmn/menu/bizcardheader";
		
		String userId = SessionHelper.getSession("UR_Code");
		String userName = SessionHelper.getSession("UR_Name");
		String userDeptCode = SessionHelper.getSession("GR_Code");
		String userDeptName = SessionHelper.getSession("GR_Name");
		String userJobPosition = SessionHelper.getSession("UR_JobPositionName");
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("userId", userId);
		mav.addObject("userName", userName);
		mav.addObject("userDeptCode", userDeptCode);
		mav.addObject("userDeptName", userDeptName);
		mav.addObject("userJobPosition", userJobPosition);
		
		return mav;
	}
	
	@RequestMapping(value = "/bizcardleft.do", method = RequestMethod.GET)
	public ModelAndView getLeftMenu(HttpServletRequest request) throws Exception {
		String returnUrl = "cmmn/menu/bizcardleft";
		
		String strMenuPath = request.getParameter("mnp");
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		StringBuilder sbMenuHtml = new StringBuilder();
		sbMenuHtml.append("<ul id='bizCardMenu' class='ulBizCardMenuList' style='display:none;'>");
		
		// 아무값도 넘어오지 않았을때 최초페이지 세팅
		sbMenuHtml.append("	<li data-mnid='0' data-mnurl='bizcard_CreateBizCard.do' onclick='moveMenuUrl(this)'>");
		sbMenuHtml.append("		<input type='button' value='" + DicHelper.getDic("btn_RegistBizCard") + "' />");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<li data-mnid='1' data-mnurl='bizcard_BizCardFavoriteList.do' onclick='moveMenuUrl(this)' class='liBizCardMenuListBorder'>");
	/*	sbMenuHtml.append("		" + DicHelper.getDic("lbl_FavoriteList"));*/  
		sbMenuHtml.append("		" + "즐겨찾는 연락처"); 
		sbMenuHtml.append("	</li>");		
		sbMenuHtml.append("	<li data-mnid='2' data-mntype='A' data-mnurl='bizcard_BizCardPersonList.do' onclick='moveMenuUrl(this)' class='liBizCardMenuListBorder'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ShareType_All"));*/
		sbMenuHtml.append("		" + "전체 연락처");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append(" <li data-mnid='3' data-mntype='P' data-mnurl='bizcard_BizCardPersonList.do' onclick='moveMenuUrl(this)'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ShareType_Personal"));*/
		sbMenuHtml.append("		" + "개인");
		sbMenuHtml.append("		<span id='btnGroup_p' class='closemenu' style='float:right; display:inline-block; width:30px; height:40px;' onclick='viewLowDepthMenu(this)'></span>");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<ul class='ulBizCardGroupList' id='bizCardGroupList_P' style='display: none;'>");
/*		sbMenuHtml.append("		<li data-mntype='P' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + DicHelper.getDic("lbl_AddGroup") + " </li>");*/
		sbMenuHtml.append("		<li data-mntype='P' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + "그룹 추가" + " </li>");
		sbMenuHtml.append("	</ul>");
		sbMenuHtml.append("	<li data-mnid='4' data-mntype='D' data-mnurl='bizcard_BizCardPersonList.do' onclick='moveMenuUrl(this)'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ShareType_Dept"));*/
		sbMenuHtml.append("		" + "부서");
		sbMenuHtml.append("		<span id='btnGroup_d' class='closemenu' style='float:right; display:inline-block; width:30px; height:40px;' onclick='viewLowDepthMenu(this)'></span>");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<ul class='ulBizCardGroupList' id='bizCardGroupList_D' style='display: none;'>");
		/*sbMenuHtml.append("		<li data-mntype='D' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + DicHelper.getDic("lbl_AddGroup") + " </li>");*/
		sbMenuHtml.append("		<li data-mntype='D' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + "그룹 추가" + " </li>");
		sbMenuHtml.append("	</ul>");
		sbMenuHtml.append("	<li data-mnid='5' data-mntype='U' data-mnurl='bizcard_BizCardPersonList.do' onclick='moveMenuUrl(this)'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ShareType_Comp"));*/
		sbMenuHtml.append("		" + "회사");
		sbMenuHtml.append("		<span id='btnGroup_u' class='closemenu' style='float:right; display:inline-block; width:30px; height:40px;' onclick='viewLowDepthMenu(this)'></span>");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<ul class='ulBizCardGroupList' id='bizCardGroupList_U' style='display: none;'>");
		/*sbMenuHtml.append("		<li data-mntype='U' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + DicHelper.getDic("lbl_AddGroup") + " </li>");*/
		sbMenuHtml.append("		<li data-mntype='U' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + "그룹 추가" + " </li>");
		sbMenuHtml.append("	</ul>");
		sbMenuHtml.append("	<li data-mnid='6' data-mnurl='bizcard_BizCardCompanyList.do' onclick='moveMenuUrl(this)' class='liBizCardMenuListBorder'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_Company2"));*/
		sbMenuHtml.append("		" + "업체");
		sbMenuHtml.append("		<span id='btnGroup_c' class='closemenu' style='float:right; display:inline-block; width:30px; height:40px;' onclick='viewLowDepthMenu(this)'></span>");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<ul class='ulBizCardGroupList' id='bizCardGroupList_C' style='display: none;'>");
		/*sbMenuHtml.append("		<li data-mntype='C' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + DicHelper.getDic("lbl_AddGroup") + " </li>");*/
		sbMenuHtml.append("		<li data-mntype='C' data-mnurl='CreateBizCardGroup.do' onclick='addGroup(this)'> + " + "그룹 추가" + " </li>");
		sbMenuHtml.append("	</ul>");
		sbMenuHtml.append("	<li data-mnid='7' data-mnurl='bizcard_ExportFileBizCard.do' onclick='moveMenuUrl(this)' class='liBizCardMenuListBorder'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ExportContact"));*/
		sbMenuHtml.append("		" + "연락처 내보내기");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<li data-mnid='8' data-mnurl='bizcard_ImportFileBizCard.do' onclick='moveMenuUrl(this)'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ImportContact"));*/
		sbMenuHtml.append("		" + "연락처 가져오기");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<li data-mnid='9' data-mnurl='bizcard_OrganizeBizCard.do' onclick='moveMenuUrl(this)'>");
		/*sbMenuHtml.append("		" + DicHelper.getDic("lbl_ArrangeContact"));*/
		sbMenuHtml.append("		" + "연락처 정리하기");
		sbMenuHtml.append("	</li>");
		
		sbMenuHtml.append("</ul>");
		
		
		mav.addObject("menuStr", sbMenuHtml.toString());
		mav.addObject("menuPath", strMenuPath);
		return mav;
	}
}
