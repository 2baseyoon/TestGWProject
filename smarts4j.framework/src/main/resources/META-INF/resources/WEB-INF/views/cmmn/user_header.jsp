<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.PropertiesUtil
																							,egovframework.coviframework.util.SessionCommonHelper
																							,egovframework.baseframework.util.RedisDataUtil
																							,egovframework.baseframework.data.CoviList
																							,egovframework.baseframework.data.CoviMap
																							,egovframework.baseframework.util.DicHelper
																							,egovframework.coviframework.util.ComUtils
																							,java.util.Arrays"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"  %>
<%	String resourceVersion = ComUtils.getResourceVer(); 
	String key = "";
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if ("CSJTK".equals(cookies[i].getName())) {
				key = cookies[i].getValue();
			}
		}
	}	
	String portalOption = (SessionCommonHelper.getSession("portalOption") == "") ? "{}" : SessionCommonHelper.getSession("portalOption");
	pageContext.setAttribute("portalOption", portalOption);
	pageContext.setAttribute("DarkMode", SessionCommonHelper.getSession("DarkMode"));
	pageContext.setAttribute("themeCode", SessionCommonHelper.getSession("UR_ThemeCode"));
%>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.tabs.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.layout.js<%=resourceVersion%>"></script>
		<h1 class="global_logo">
			<a  id="anchorLogo" href='/covicore'>
				<span class="blind"><%=PropertiesUtil.getGlobalProperties().getProperty("copyright")%></span>
			</a>
        </h1>
        <div class="global_service">
            <button type="button" class="global_icon" data-icon="menu" id="all_menu_toggle">
                <span>전체메뉴</span>
            </button>
        </div>
        
        <nav class="ui_gnb" role="navigation">
        	<ul>
  				<c:forEach var="list"  items="${myTopMenuConf}" varStatus="status">
     				<li data-menu-id='${list.MenuID}' data-menu-target='${list.Target}' data-menu-alias='${list.Reserved1}' data-menu-url='${list.URL}'>
						<a href="#" onclick='CoviMenu_ClickTop(this);return false;'><span>${list.DisplayName}</span></a>
						<c:if test="${fn:length(list.Sub)>0}">
							<ul>
							<c:forEach items="${list.Sub}" var="subList" varStatus="status">
								<li data-menu-id='${subList.MenuID}' data-menu-target='${subList.Target}' data-menu-alias='${subList.Reserved1}' data-menu-url='${subList.URL}'>
									<a href="#" onclick='CoviMenu_ClickTop(this);return false;'><span>${subList.DisplayName}</span></a>
								</li>
							</c:forEach>
							</ul>
						</c:if>
					</li>
 				</c:forEach>
                <li class="more">
                    <button class="toggle"><span>더보기</span></button>
                    <ul></ul>
                </li>
            </ul>
        </nav>
        <nav class="global_utility">
        	<%if (RedisDataUtil.getBaseConfig("PortalUnifiedSearchUse").equals("Y")){ %>
        	 <div class="global_search" hidden>
                <label class="ui_form_field">
                    <input type="text" class="ui_text_field" placeholder="<%=DicHelper.getDic("CPMail_msgSearchWord")%>" disabled id="txtPortalUnifiedSearch">
                    <button type="button" class="ui_icon_button" data-icon="search" disabled><span>검색</span></button>
                </label>
            </div>
            <button type="button" class="global_icon utility_search" id="global_search_toggle" data-icon="search" data-tooltip-title="<%=DicHelper.getDic("lbl_search")%>"><span>검색</span></button>
            <%} %>
            <%String[] arr = new String[]{"ptype01", "ptype02", "ptype03"};
            if (Arrays.asList(arr).contains(SessionCommonHelper.getSession("UR_PortalCode"))){%>
            <button type="button" class="global_icon" data-icon="notifications" data-tooltip-title="<%=DicHelper.getDic("lbl_Alram")%>"><span>알림</span><em class="ui_badge"></em></button>
            <%} %>
            <button type="button" class="global_icon" data-icon="organization" data-tooltip-title="<%=DicHelper.getDic("lbl_DeptOrgMap")%>"><span>조직도</span></button>
            <button type="button" class="global_icon" data-icon="writing" data-tooltip-title="<%=DicHelper.getDic("lbl_Simple") + DicHelper.getDic("lbl_Write")%>"><span>간편작성</span></button>
            <button type="button" class="global_icon" data-icon="gadget" data-tooltip-title="<%=DicHelper.getDic("lbl_Gadgets")%>"><span>가젯</span></button>
            <button type="button" class="utility_profile" id="setting_toggle">
			    <span class="ui_avatar"><img src="/covicore/common/photo/photo.do?img=${myBaseData.PhotoPath}" alt="아바타" onerror="coviCmn.imgError(this,true)"></span>
			    <span class="info">   
                    <strong>${myBaseData.UR_Name} ${myBaseData.UR_JobPositionName}</strong>
                    <span>${myBaseData.DEPTNAME}</span>
                </span>
			</button>

       </nav>

<script type="text/template" id="all_menu_drawer">
    <div class="drawer_header">
        <h2 class="drawer_title"><span><%=DicHelper.getDic("lbl_FullMenu")%></span></h2>
        <div class="drawer_action">
            <button type="button" class="ui_icon_button" data-icon="setting" id="all_menu_setting_toggle"><span>설정</span></button>
        </div>
    </div>
	<!-- 즐겨 찾기-->
    <div class="drawer_toolbar favorites_menu" aria-expanded="true"> 
		<button type="button" class="menu_toggle"><span><%=DicHelper.getDic("lbl_favoriteMenu")%></span></button>
        <ul class="menu_list" id="favoriteSiteMenu">
		</ul>
	</div>
	<!-- 업무시스템-->
    <div class="all_menu_toolbar">
        <!--<label class="ui_switch"><input type="checkbox" checked><i></i><span>메인화면 전체메뉴</span></label>-->
	  	<c:if test="${fn:length(siteLinkList)>0}"> 
        <select class="ui_select_field" id="siteLink">
            <option><%=DicHelper.getDic("lbl_ShortcutBusinessSystem")%></option>
			<c:forEach var="list"  items="${siteLinkList}" varStatus="status">
				<option value"${list.Code}" data-url="${list.Reserved1}" data-target="${list.Reserved3}">${covi:getDicInfo(list.MultiCodeName,myBaseData.lang)}</option>
			</c:forEach>
        </select>
		</c:if>
    </div>
    <div class="drawer_content">
        <div class="all_menu_list">
            <ul>
				<c:forEach var="list"  items="${topMenuData}" varStatus="status">
     				<li data-menu-id='${list.MenuID}' data-menu-target='${list.Target}' data-menu-alias='${list.Reserved1}' data-menu-url='${list.URL}'>
						<a href='#' onclick='CoviMenu_ClickTop(this);return false;'><span>${list.DisplayName}</span></a>
						<c:if test="${fn:length(list.Sub)>0}">
							<ul>
							<c:forEach items="${list.Sub}" var="subList" varStatus="status">
								<li data-menu-id='${subList.MenuID}' data-menu-target='${subList.Target}' data-menu-alias='${subList.Reserved1}' data-menu-url='${subList.URL}'>
									<a href='#' onclick='CoviMenu_ClickTop(this);return false;'><span>${subList.DisplayName}</span></a>
								</li>
							</c:forEach>
							</ul>
						</c:if>
					</li>
				</c:forEach>
            </ul>
        </div>
    </div>
</script>
<script type="text/template" id="all_menu_setting_context_menu">
    <div class="menu_head">
        <h3 class="title">전체메뉴 설정</h3>
        <button type="button" class="ui_button icon close"><span>닫기</span></button>
    </div>
    <div class="menu_content">
        <ul>
			<c:forEach var="list"  items="${topMenuData}" varStatus="status">
   				<li data-menu-id='${list.MenuID}' data-menu-target='${list.Target}' data-menu-alias='${list.Reserved1}' data-menu-url='${list.URL}'>
					<label class="ui_checkbox"><input type="checkbox"><i></i><span>${list.DisplayName}</span></label>
				</li>
			</c:forEach>
        </ul>
    </div>
    <div class="menu_footer">
        <button type="button" class="ui_button normal" data-icon="reset"><span>초기화</span></button>
        <button type="button" class="ui_button"><span>취소</span></button>
        <button type="button" class="ui_button primary"><span>완료</span></button>
    </div>
</script>
<script type="text/template" id="setting_drawer">
  	<div class="drawer_header">
      <div class="setting_profile">
          <div class="ui_avatar"><img src="/covicore/common/photo/photo.do?img=${myBaseData.PhotoPath}" alt="아바타" onerror="coviCmn.imgError(this,true)"></div>
          <div class="info">
              <strong><%=SessionCommonHelper.getSession("UR_Name")%> <%=SessionCommonHelper.getSession("UR_JobPositionName")%></strong>
              <em><%=SessionCommonHelper.getSession("DEPTNAME")%></em>
          </div>
      </div>
   	</div>
   	<c:if test="${myBaseData.UR_PortalCode eq 'ptype07'}"> 
        <div class="drawer_tabs" role="tablist">
            <button role="tab" type="button" class="tab" aria-selected="true" id="setting_basic_tab" aria-controls="setting_basic_tab_panel"><span><%=DicHelper.getDic("lbl_SettingDefault")%></span></button>
            <button role="tab" type="button" class="tab" aria-selected="false" id="setting_design_tab" aria-controls="setting_design_tab_panel"><span><%=DicHelper.getDic("lbl_SettingPortal")%></span></button>
        </div>
	</c:if>
    <div role="tabpanel" class="drawer_tab_panel basic_setting_content" id="setting_basic_tab_panel" aria-labelledby="setting_basic_tab">
      <div class="drawer_content">
		<div class="setting_grid">
          <button type="button" class="ui_button setting_reset_button"><span><%=DicHelper.getDic("lbl_CacheInitialization")%></span></button>
		</div>
        <div class="setting_grid setting_link"><a href="#" class="grid_title" data-icon="profile"><span><%=DicHelper.getDic("lbl_MyInfo")%></span></a></div>
	  	<!-- 언어설정-->
		<c:if test="${fn:length(langCode)>1}"> 
			<div class='setting_grid'   aria-expanded='false'>
				<div class='grid_head'>
					<div class='grid_title' data-icon='language'><span><%=DicHelper.getDic("LanguageCode_"+SessionCommonHelper.getSession("lang"))%></span></div>
					<button type='button' class='grid_toggle' ></button>
				</div>
				<div class='grid_content'>
		 			<div class="grid_row" id="lang">
					<c:forEach var="list"  items="${langCode}" varStatus="status">
  		    	    	<label class="ui_checkbox"><input type="radio" name="lang" ${list.Code eq myBaseData.lang?"checked":""} value="${list.Code}"><i></i><span>${covi:getDicInfo(list.MultiCodeName,myBaseData.lang)}</span></label>
					</c:forEach>
             		</div>
				</div>
           </div>
		</c:if>

		 <!-- 겸직-->
		  <c:if test="${fn:length(myAddJobList)>1}">
          <div class="setting_grid"   aria-expanded='false'>
			  <div class='grid_head'>
					<div class='grid_title' data-icon='class'><span><%=DicHelper.getDic("lbl_ChangeOfficeConcurrently")%></span></div>
					<button type='button' class='grid_toggle' ></button>
			  </div>
			  <div class='grid_content'>
	              <div class="grid_row vertical" id="position">
    	              <ul>
						<c:forEach var="list"  items="${myAddJobList}" varStatus="status">
    			        	<li><label class="ui_checkbox"><input type="radio" name="position" ${list.Seq eq myBaseData.URBG_ID?"checked":""} value="${list.Seq}"><i></i><span>${list.DeptName}[${list.CompanyName}]</span></label></li>
						</c:forEach>
	              	</ul>						
              	</div>
		      </div>
          </div>
		  </c:if>

	  	<!--기본 모드-->
		<c:if test="${myBaseData.UR_PortalCode eq 'ptype05' or myBaseData.UR_PortalCode eq 'ptype07'}"> 
      	<div class="setting_grid" style="display:none">
			 <div class='grid_head'>
					<div class='grid_title' data-icon='mode'><span><%=DicHelper.getDic("PT_Style")%></span></div>
					<button type='button' class='grid_toggle' ></button>
			  </div>
			  <div class='grid_content'>
		          <div class="grid_row" id="mode">
        		      <label class="ui_checkbox"><input type="radio" name="mode" value="light" <%=(SessionCommonHelper.getSessionMapKey("PortalOption", "mode").equals("light")?"checked":"")%>><i></i><span><%=DicHelper.getDic("PT_StyleLight")%></span></label>
              		<label class="ui_checkbox"><input type="radio" name="mode" value="dark"  <%=(SessionCommonHelper.getSessionMapKey("PortalOption", "mode").equals("dark")?"checked":"")%>><i></i><span><%=DicHelper.getDic("PT_StyleDark")%></span></label>
          		</div>
			 </div>
      	</div>
		</c:if>
	  	<!--컬러 테마-->
	  	<c:if test="${fn:length(themeColor)>1}"> 
		<div class='setting_grid'   aria-expanded='false'>
			 <div class='grid_head'>
					<div class='grid_title' data-icon='theme'><span><%=DicHelper.getDic("lbl_ChangeTheme")%></span></div>
					<button type='button' class='grid_toggle' ></button>
			  </div>
			  <div class='grid_content'>
				<div class="grid_selector_list theme" id="theme">
				<c:forEach var="list"  items="${themeColor}" varStatus="status">
		        	<label class='selector'  data-color="${list.Code}"><input type="radio" name="theme" ${list.Code eq myPortalOption.theme?"checked":""} value="${list.Code}"><i></i><span>${covi:getDicInfo(list.MultiCodeName,myBaseData.lang)}</span></label>
				</c:forEach>
         		</div>
			</div>
     	 </div>
 	  	</c:if>
	  	<!-- portal 변경-->
	  	<c:if test="${fn:length(myPortalList)>1}">
      	<div class="setting_grid"   aria-expanded='false'>
			 <div class='grid_head'>
					<div class='grid_title' data-icon='type'><span><%=DicHelper.getDic("lbl_ChangePortal")%></span></div>
					<button type='button' class='grid_toggle' ></button>
			  </div>
			  <div class='grid_content'>
          		<div class="grid_row vertical" id="portal">
             		 <ul>
					<c:forEach var="list"  items="${myPortalList}" varStatus="status">
               	   <li><label class="ui_checkbox"><input type="radio" name="portal_type" ${list.PortalID eq myBaseData.UR_InitPortal?"checked":""} value="${list.PortalID}"><i></i><span>${list.DisplayName}</span></label></li>
					</c:forEach>
              	</ul>
          		</div>
			</div>
      	</div>
	  	</c:if>
		<c:if test="${myInfoData.managerSite ne ''}">	
		<!--관리자 사이트-->
          <div class="setting_grid setting_link"><a href="#" class="grid_title" data-icon="admin" data-url="${myInfoData.managerSite}"><span><%=DicHelper.getDic("lbl_AdminDefaultURL")%></span></a></div>
		</c:if>
        <div class="setting_grid setting_link"><a href="#" class="grid_title" data-icon="my"><span><%=DicHelper.getDic("lbl_SetMyInfo")%></span></a></div>

        <div class="setting_grid setting_link" style="display:none"><a href="#" class="grid_title" data-icon="info"><span><%=DicHelper.getDic("lbl_help")%></span></a></div>
      </div>
      <div class="fixed_panel">
          <div class="setting_grid setting_link"><a href="#" class="grid_title" data-icon="logout"><span><%=DicHelper.getDic("btn_Logout")%></span></a></div>
      </div>
  </div>
  <div hidden role="tabpanel" class="drawer_tab_panel design_setting_content" id="setting_design_tab_panel" aria-labelledby="setting_design_tab">
	<div class="drawer_content">
	  <c:if test="${myBaseData.UR_PortalCode eq 'ptype07'}"> 
	  <div class="setting_grid">
      	<button type="button" class="ui_button setting_reset_button"><span><%=DicHelper.getDic("PT_PortalInit")%></span></button>
      </div>
      <div class="setting_grid"  aria-expanded='false'>
		  <div class="grid_head">
          	<div class="grid_title"><span><%=DicHelper.getDic("PT_PortalSelect")%></span></div>
			<button type="button" class="grid_toggle" aria-label="접기"></button>
          </div>
          <div class="grid_content">
          	<div class="grid_switch" id="onlyContents">
              <span class="switch_label"><%=DicHelper.getDic("PT_PortalSelectMy")%></span>
              <label class="ui_switch"><input type="checkbox" ${myPortalOption.onlyContents eq "Y"?"checked":""}><i></i></label>
         	</div>
	   	 </div>
	  </div>	
	  <!--포털 배경-->
      <div class="setting_grid"  aria-expanded='false'>
		 <div class="grid_head">
          	<div class="grid_title"><span><%=DicHelper.getDic("PT_PortalBackground")%></span></div>
		 	<div class="ui_help preview_help" aria-expanded="false">
              <button type="button" class="help_toggle"><span>도움말</span></button>
                        <div class="help_message"><%=DicHelper.getDic("PT_PortalBgHelp")%>
                        </div>
                    </div>
			  <button type="button" class="grid_toggle" aria-label="접기"></button>
          	</div>
          <div class="grid_content">
	        <div class="grid_switch"  id="dim" data-org="${myPortalOption.dim}">
    	        <span class="switch_label"><%=DicHelper.getDic("PT_PortalDim")%></span>
            	<label class="ui_switch"><input type="checkbox" ${myPortalOption.dim eq "Y"?"checked":""}><i></i></label>
        	</div>
          	<div class="grid_sub_head">
                <h4 class="grid_sub_title"><%=DicHelper.getDic("CPMail_Image")%></h4>
				<div class="ui_help">
                      <button type="button" class="help_toggle"><span>도움말</span></button>
                       <div class="help_message"><%=DicHelper.getDic("PT_PortalImgHelp")%>
                        </div>
                </div>
          	</div>
          	<div class="grid_selector_list image" id="portalBg"  data-org="${myPortalOption.portalBg}">
              <label class="image_upload"><input type="file"  accept=".jpg, .jpeg, .png, .gif" ><span><%=DicHelper.getDic("btn_Upload")%></span></label>
			  <c:if test="${!empty myPortalOption.portalBgPath and myPortalOption.portalBgPath ne ''}">
	        	<label class='selector custom-img' style="background-image:url('/covicore/common/photo/photo.do?img=${myPortalOption.portalBgPath}')">
					<input type="radio" name="background"  ${'image-custom' eq myPortalOption.portalBg?"checked":""} value="image-custom"><i></i>
					<button type="button" class="selector_delete"><span>삭제</span></button>	
				</label>
			  </c:if>
			  <c:forEach var="list"  items="${portalBg}" varStatus="status">
        		<label class='selector' data-thumbnail="${list.Reserved1}"><input type="radio" name="background"  ${list.Code eq myPortalOption.portalBg?"checked":""} value="${list.Code}"><i></i></label>
			  </c:forEach>
            </div>
		  <h4 class="grid_sub_title"><%=DicHelper.getDic("PT_PortalColor")%></h4>
          <div class="grid_selector_list color" id="portalBgText">
				<c:forEach var="list"  items="${portalColor}" varStatus="status">
	        		<label class='selector' data-color="${list.Code}"><input type="radio" name="background"  ${list.Code eq myPortalOption.portalBg?"checked":""} value="${list.Code}"><i></i></label>
				</c:forEach>
          </div>
          <div class="grid_switch"  id="contentsBg"  data-org="${myPortalOption.contentsBg}">
              <span class="switch_label"><%=DicHelper.getDic("PT_PortalBackgroundMy")%></span>
              <label class="ui_switch"><input type="checkbox" name="my_content_background" ${myPortalOption.contentsBg eq "Y"?"checked":""}><i></i></label>
          </div>
		 </div>
      </div>        
	<!--포털 텍스트 컬러-->
      <div class="setting_grid" >
		<div class="grid_head">
           <div class="grid_title"><span><%=DicHelper.getDic("PT_PortalText")%></span></div>
           <div class="ui_help preview_help"  aria-expanded="false">
               <button type="button" class="help_toggle"><span>도움말</span></button>
               <div class="help_message">
                 <%=DicHelper.getDic("PT_PortalTextHelp")%>
                </div>
           </div>
           <button type="button" class="grid_toggle" aria-label="접기"></button>
        </div>
        <div class="grid_content">
          <div class="grid_row bg" id="portalText"   data-org="${myPortalOption.portalText}">
              <label class="ui_checkbox"><input type="radio" name="portal_text_color" ${myPortalOption.portalText eq "white"?"checked":""} value="white"><i></i><span>White</span></label>
              <label class="ui_checkbox"><input type="radio" name="portal_text_color" ${myPortalOption.portalText eq "black"?"checked":""} value="black"> <i></i><span>Black</span></label>
          </div>
      	</div>
	 </div>
	 </c:if>
	<!--위젯-->
	<c:if test="${myPortalOption.onlyContents ne 'Y'}">
      <div class="setting_grid">
           <div class="grid_head">
               <div class="grid_title"><span><%=DicHelper.getDic("PT_PortalWidget")%></span></div>
               <div class="ui_help">
                        <button type="button" class="help_toggle"><span>도움말</span></button>
                        <div class="help_message">
                           <%=DicHelper.getDic("PT_PortalWidgetHelp")%>
                        </div>
                    </div>
                    <button type="button" class="grid_toggle" aria-label="접기"></button>
            </div>
          	<div class="grid_content">
          	<div class="grid_check_list">
              <ul class="sortable" id="widgetSorting">
				<c:forEach var="list"  items="${myWidget}" varStatus="status">
                  <li>
					  <label class="ui_checkbox"><input type="checkbox" ${(myWidgetCnt eq '0' and (list.Reserved1 eq 'FIX' or list.Reserved1 eq 'DEF' ) or list.IsMy eq 'Y') ?"checked":""}  ${list.Reserved1 eq 'FIX' ?" disabled":""} value="${list.WebpartID}"><i></i><span>${list.DisplayName}</span></label>
                      <div class="handle"><span>위치이동</span></div>
				  </li>
				</c:forEach>
              </ul>
          	</div>
		</div>	
      </div>
	</c:if>
	<!--컨텐츠-->
      <div class="setting_grid"  aria-expanded='false' >
		 <div class="grid_head">
             <div class="grid_title"><span><%=DicHelper.getDic("lbl_Content")%></span></div>
             <div class="ui_help">
                <button type="button" class="help_toggle"><span>도움말</span></button>
                <div class="help_message"><%=DicHelper.getDic("PT_PortalContentsHelp")%>
                    
                 </div>
             </div>
             <button type="button" class="grid_toggle" aria-label="접기"></button>
        </div>
        <div class="grid_content">
         <div class="grid_check_list">
              <ul class="sortable" id="contentsSorting">
				<c:forEach var="list"  items="${myContents}" varStatus="status">
                    <li>
					  <label class="ui_checkbox"><input type="checkbox" ${list.IsMy eq 'Y' ?"checked":""}  ${list.Reserved1 eq 'FIX' ?"disabled checked":""} value="${list.WebpartID}"><i></i><span>${list.DisplayName}</span></label>
				    </li>
				</c:forEach>
              </ul>
         </div>
     	</div>
   	</div>
  </div>
   <div class="drawer_footer">
       <button class="ui_button" id="portalCancel"><span><%=DicHelper.getDic("btn_Cancel")%></span></button>
       <button class="ui_button primary" id="portalSave"><span><%=DicHelper.getDic("lbl_apply")%></span></button>
   </div>
 </div>

</script>
<script type="text/template" id="my_content_setting_drawer">
    <div class="drawer_header">
        <h2 class="drawer_title">마이컨텐츠 설정</h2>
    </div>
    <div class="drawer_content">
        <div class="setting_list">
            <ul id="myContentSorting" >
				<c:forEach var="list"  items="${myContents}" varStatus="status">
					<c:if test="${list.IsMy ne 'Y' and list.Reserved1 ne 'FIX'}">
                  	<li><label class="ui_checkbox"><input type="checkbox" ${list.IsMy eq 'Y' ?"checked":""} ${list.Reserved1 eq 'FIX' ?"disabled checked":""} value="${list.WebpartID}"><i></i><span>${list.DisplayName}</span></label></li>
					</c:if>
				</c:forEach>
            </ul>
        </div>
    </div>
</script>

<script type="text/template" id="my_content_favorite">
	<c:forEach var="list"  items="${myFavorite}" varStatus="status">
		<li>
    	    <div class="ui_chip">
        		<a class="chip_label" id="${list.FavoriteID}" href="${list.TargetURL}">${list.DisplayName}</a>
				<button type="button" class="chip_action" onclick="javascript:coviCtrl.deleteFavoriteMenu(this);return false;"><span>삭제</span></button>
            </div>
		</li>
	</c:forEach>
</script>
<script>
	<%if (SessionCommonHelper.getSession("USERID") == null)	out.println("location.href = \"/\";"); %>
	
	var headerdata = ${topMenuData};
	var resourceVersion = "<%=ComUtils.getResourceVer()%>";
	const serverConfigSyncKey = "<%=ComUtils.getBaseConfigSyncKey()%>";
	const serverDicSyncKey = "<%=ComUtils.getDictionarySyncKey()%>";

	//View
	<c:if test="${myInfoData.managerSite ne ''}">	
		$(document).on('click', '.setting_grid a[data-icon="admin"]', function () {
			<c:if test="${myInfoData.managerType eq 'T'}">	
				Common.open('','OTP','TWO FACTOR 인증',$(this).attr("data-url"),'520px','310px','iframe',true,null,null,true);
			</c:if>
			<c:if test="${myInfoData.managerType ne 'T'}">	
				window.open($(this).attr("data-url"));//
			</c:if>
		})
	</c:if>
	
	
</script>