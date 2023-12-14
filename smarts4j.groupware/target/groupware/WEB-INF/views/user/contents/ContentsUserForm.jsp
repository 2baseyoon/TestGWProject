<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
<!-- <script type="text/javascript" src="<%=cssPath%>/contentsApp/resources/js/contentsApp.js"></script> -->	
	<script type="text/javascript" src="/groupware/resources/script/user/contents_app.js"></script>

<style>
	.l_img1{max-width:300px;max-height:100px}
	.caContent .designImgAdd::before {background-color:#333;}
	.caContent .designImgAdd { position: relative; display: flex; background : #F5F5F5; text-align: center; align-items: center; justify-content: center; width:300px; height:100px; }
	.caContent .designImgAdd::before { position: absolute; display: inline-block; width:30px; height:30px; top:50%; left:50%; margin-left:-15px; margin-top:-27px; border-radius: 50%; content: ""; background-image:url('/HtmlSite/smarts4j_n/simpleAdmin/resources/images/ic_sadmin_imgadd.png'); background-repeat: no-repeat; background-position: center;}
	.caContent .designImgAdd a { display: block; padding-top:33px; font-size:13px; color: #999; z-index: 1;}
	.caContent .designImgAdd ~ p { margin-top: 5px;}
	.caContent .designImgAdd.imgY { background:#fff; padding:0; border: 1px solid #ddd;}
	.caContent .designImgAdd.imgY::before { display: none;}
	.caContent .designImgAdd .btn_del { position: absolute; top: -4px;  right: -7px; display: block; width: 14px; height: 14px; background: #566472 url(/HtmlSite/smarts4j_n/eaccounting/resources/images/btn_filedel.png) no-repeat 50% 50%; background-size: 6px; border-radius: 50%; padding:0;}
</style>

<div id='wrap'>
	<section id='ca_container'>
		<div class='commContLeft contentsAppLeft contentsAppForm'>
				<div class="cLnbTop">
					<a href="/groupware/contents/ContentsMain.do" class="btn_cahome">컨텐츠 앱</a>
				</div>
				<div class='cLnbMake mScrollV scrollVType01'>
				<ul class="caMakeMenu">
<!--  					<li>
						<div class="depth1">폼 권한 관리<span class="arrow"></span></div>
						<ul class="caMakeSubMenu">
							<li>
								<a class="depth2">서브메뉴1</a>
							</li>
							<li>
								<a class="depth2">서브메뉴2</a>
							</li>
							<li>
								<a class="depth2">서브메뉴3</a>
							</li>
						</ul>
					</li>-->
					<li class="active">
						<div class="depth1"><spring:message code='Cache.lbl_component'/><span class="arrow"></span></div>
						<ul class="caMakeSubMenu">
							<li class="active">
								<div class="depth2"><spring:message code='Cache.lbl_dataComponents'/><span class="arrow"></span></div>
								<ul class="caMakeComMenu">
									<li data-component-type="Input"><a href="#"><span class="dataIcon01"></span><span><spring:message code='Cache.lbl_text1'/></span></a></li>
									<li data-component-type="TextArea"><a href="#"><span class="dataIcon02"></span><span><spring:message code='Cache.lbl_multiText'/></span></a></li>
									<li data-component-type="Number"><a href="#"><span class="dataIcon03"></span><span><spring:message code='Cache.lbl_number1'/></span></a></li>
									<li data-component-type="DropDown"><a href="#"><span class="dataIcon04"></span><span><spring:message code='Cache.lbl_dropbox'/></span></a></li>
									<li data-component-type="CheckBox"><a href="#"><span class="dataIcon05"></span><span><spring:message code='Cache.lbl_checkbox'/></span></a></li>
									<li data-component-type="Radio"><a href="#"><span class="dataIcon06"></span><span><spring:message code='Cache.lbl_singleSelection'/></span></a></li>
									<li data-component-type="ListBox"><a href="#"><span class="dataIcon07"></span><span><spring:message code='Cache.lbl_listBox'/></span></a></li>
									<li data-component-type="Date"><a href="#"><span class="dataIcon08"></span><span><spring:message code='Cache.lbl_date'/></span></a></li>
									<li data-component-type="DateTime"><a href="#"><span class="dataIcon10"></span><span><spring:message code='Cache.lbl_dateAndTime'/></span></a></li>
								</ul>
							</li>
							<li>
								<div class="depth2"><spring:message code='Cache.lbl_designComponents'/><span class="arrow"></span></div>
								<ul class="caMakeComMenu">
									<li data-component-type="Label"><a href="#"><span class="designIcon01"></span><span><spring:message code='Cache.lbl_labels'/></span></a></li>
									<li data-component-type="Line"><a href="#"><span class="designIcon02"></span><span><spring:message code='Cache.lbl_line'/></span></a></li>
									<li data-component-type="Space"><a href="#"><span class="designIcon03"></span><span><spring:message code='Cache.lbl_blankSpace'/></span></a></li>
								</ul>
							</li>
							<li>
								<div class="depth2"><spring:message code='Cache.lbl_advancedComponents'/><span class="arrow"></span></div>
								<ul class="caMakeComMenu">
									<li data-component-type="Button"><a href="#"><span class="coviIcon02"></span><span><spring:message code='Cache.lbl_customButton'/></span></a></li>
									<li data-component-type="Image"><a href="#"><span class="coviIcon03"></span><span><spring:message code='Cache.lbl_image'/></span></a></li>
									<li data-component-type="Help"><a href="#"><span class="coviIcon04"></span><span><spring:message code='Cache.lbl_help'/></span></a></li>
								</ul>
							</li>
						</ul>
					</li>
				</ul>
			</div>
		</div>
		<div class='commContRight'>
			<div id="content">
				<!-- 속성창, 컴포넌트 클릭시 active -->
				<div class="cRContProperty mScrollV scrollVType01">
					<div class="title">
						<spring:message code='Cache.lbl_Property'/><a class="close" href="#"><spring:message code='Cache.btn_Close'/></a>
					</div>
					<div class="property_inner"></div>
				</div>
				<div class="cRConTop titType">
					<h2 class="title"><spring:message code='Cache.lbl_creatingContentApp'/></h2>
				</div>
				<div class="cRContBottom mScrollVH ">
						<div id="contentDiv" class="caContent">
							<div class="caMakeTitle listBox_app">
							
						<c:if test="${folderData.UseIcon ne null && folderData.UseIcon ne '' }">
							<c:if test="${fn:startsWith(folderData.UseIcon,'app')}">
								<div class="icon ${folderData.UseIcon}">
									<span class="setting" id="btnSetting"></span>
								</div>
							</c:if>
							<c:if test="${not fn:startsWith(folderData.UseIcon,'app')}">
								<div class="icon custom" data-icon="${folderData.UseIcon}">
									<span class="setting" id="btnSetting"></span>
								</div>
								
								<script type="text/javascript">
									var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
									$("#btnSetting").parent().attr("style", "background: url('"+coviCmn.loadImage(BackStorage +"${folderData.UseIcon}")+"') no-repeat center;");
								</script>
							</c:if>
						</c:if>
						<c:if test="${folderData.UseIcon eq null || folderData.UseIcon eq '' }">
							<div class="icon app01">
								<span class="setting" id="btnSetting"></span>
							</div>
						</c:if>
								<input type="file" id="iconFile" style="display:none;">
								<input type="text" id="folderName" name="folderName" placeholder="<spring:message code='Cache.msg_enterAppName'/>" value="${folderData.DisplayName}">
								<input type="hidden" id="hidFolderNameDicInfo" name="hidFolderNameDicInfo" value="${folderData.MultiDisplayName}" />
								<a class="btnTypeDefault btnLang" href="#" id="dicBtn"><spring:message code='Cache.lbl_MultiLang2'/></a>
							</div>
							<div class="caMakeSavePath">
								<strong><spring:message code='Cache.lbl_storageLocation'/></strong>
								<input type="text" id="folderPathName" value="${fn:replace(folderPathName,';','\\')}" disabled="">
								<a class="btnTypeDefault" href="#" id="btnFolderMove"><spring:message code='Cache.lbl_changeFolderLocation'/></a>
								<div class="caContent_chk"><div class="chkStyle01"><input type="checkbox" id="chkUseBody" ${useBody=="Y"?"checked":""}><label for="chkUseBody"><span></span><spring:message code="Cache.lbl_Body"/></label></div></div>
							</div>
						<div class="caMakeComponent">
							<div class="component_wrap">
								
								<!-- 컴포넌트 배치, 클릭시 속성창 노출 -->
								<c:forEach items="${formList}" var="list" varStatus="status">
								<div class="component ${list.FieldSize == 'Half'?"w50":""}" data-type="${list.FieldType}" data-cid="${status.index}">
									<c:set var="optStyle" value=""/>
									<c:if test="${!empty list.FieldWidth}">
										<c:set var="optStyleWidth" value="width:${list.FieldWidth}${list.FieldWidthUnit};" />
									</c:if>
									<c:if test="${list.FieldType eq 'Space' && !empty list.FieldHeight}">
										<c:set var="optStyleHeight" value="height:${list.FieldHeight}${list.FieldHeightUnit};" />
									</c:if>
									<c:if test="${!empty list.FieldWidth || !empty list.FieldHeight}">
										<c:set var="optStyle" value="style='${optStyleWidth }'" />
									</c:if>
									
									<label <c:if test="${list.IsLabel ne 'Y'}">style="visibility:hidden;"</c:if><c:if test="${list.FieldType eq 'Button' }">style="display:none;"</c:if> >
										<c:if test="${list.IsTitle eq 'Y' }">
											<span class="mark_title"><spring:message code='Cache.lbl_Title'/></span>
										</c:if>
										<c:if test="${list.IsList eq 'Y' }">
											<span class="mark_list"><spring:message code='Cache.lbl_list'/></span>
										</c:if>
										<c:if test="${list.IsSearchItem eq 'Y' }">
											<span class="mark_search"></span>
										</c:if>										
										<c:if test="${list.IsCheckVal eq 'Y' }">
											<span class="thstar">*</span>
										</c:if>
										${list.DisplayName}
									</label>
									
								<c:choose>
									<c:when test="${list.FieldType eq 'Label' }">
									</c:when>
									<c:when test="${list.FieldType eq 'Line' }">
										<div class="line"></div>
									</c:when>
									<c:when test="${list.FieldType eq 'Space' }">
										<div class="whitespace" ${optStyle}><spring:message code='Cache.msg_thisIsEmptyArea'/></div>
									</c:when>
									<c:when test="${list.FieldType eq 'Input' }">
										<input id="comp_data01" type="text" value="" readonly="readonly" ${optStyle}>
									</c:when>
									<c:when test="${list.FieldType eq 'Number' }">
										<input type="number" value="" ${optStyle}>
									</c:when>
									<c:when test="${list.FieldType eq 'TextArea' }">
										<textarea rows="${list.FieldRow}" readonly="readonly" ${optStyle}></textarea>
									</c:when>
									<c:when test="${list.FieldType eq 'Date' }">
										<div class="dateSel type02">
											<input class="adDate" type="text" value="2021.06.30" id="comp_data08" readonly="readonly">
											<a class="icnDate"><spring:message code='Cache.lbl_selectDate'/></a>
										</div>
									</c:when>
									<c:when test="${list.FieldType eq 'DateTime' }">
										<div class="dateSel type02">
											<input class="adDate" type="text" value="2021.06.30" id="comp_data10" readonly="readonly">
											<a class="icnDate"><spring:message code='Cache.lbl_selectDate'/></a>
										</div>
									</c:when>
									<c:when test="${list.FieldType eq 'Button' }">
										<div align="center"><a class="btnTypeDefault btnTypeBg">${list.DisplayName}</a></div>
									</c:when>
									<c:when test="${list.FieldType eq 'Image' }">
									
										<div class="imgSelect" align="center"> 
											<div class="designImgAdd<c:if test="${!empty list.GotoLink}"> imgY</c:if>"  >
												<a href="#" class="fileSelect" <c:if test="${!empty list.GotoLink}">style="display:none"</c:if> ><spring:message code="Cache.msg_FileSelect" /></a>
												<img class="l_img1" onerror="coviCtrl.imgError(this);" <c:if test="${!empty list.GotoLink}">src="${list.GotoLink}"</c:if> data-src="<c:if test="${!empty list.GotoLink}">${list.GotoLink}</c:if>">
												<a class="btn_del" href="#" <c:if test="${empty list.GotoLink}">style="display:none"</c:if>></a>
											</div>
											<input type="file" style="display:none" ${optStyle}>
											<input type="hidden" class="inputPath" id="hid_pcLogoPath" value="" />
										</div>
										
									</c:when>
									<c:when test="${list.FieldType eq 'Help' }">
										<div style="text-align: center;"><a class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_help'/></a></div>
									</c:when>
								</c:choose>	 

								<c:if test="${list.FieldType eq 'DropDown' }">
									<select class="selectType02" ${optStyle}>
								</c:if>
								<c:if test="${list.FieldType eq 'ListBox' }">
									<div class="listbox" ${optStyle}>
								</c:if>
								<c:if test="${list.FieldType eq 'CheckBox' }">
									<div class="checkbox_div">
								</c:if>
								<c:if test="${list.FieldType eq 'Radio' or list.FieldType eq 'CheckBox' }">
									<c:if test="${list.FieldAlign eq 'H' }">
										<ul>
									</c:if>
								</c:if>
								
								<c:set var="optList" value="${fn:split(list.OptionList,'|')}" />
								<c:forEach var="opt" items="${optList}" varStatus="optStatus">
									<c:set var="optVar" value="${fn:split(opt,'^')}" />
									<c:set var="optVarLang" value="${fn:split(optVar[1],';')}" />
									<c:choose>
									 <c:when test="${lang eq 'ko' }">
									 	<c:set var="optVarLang" value="${optVarLang[0]}" />
									 </c:when>
									 <c:when test="${lang eq 'en' }">
									 	<c:set var="optVarLang" value="${optVarLang[1]}" />
									 </c:when>
									 <c:when test="${lang eq 'ja' }">
									 	<c:set var="optVarLang" value="${optVarLang[2]}" />
									 </c:when>
									 <c:when test="${lang eq 'zh' }">
									 	<c:set var="optVarLang" value="${optVarLang[3]}" />
									 </c:when>
									 <c:when test="${lang eq 'e1' }">
									 	<c:set var="optVarLang" value="${optVarLang[4]}" />
									 </c:when>
									 <c:when test="${lang eq 'e2' }">
									 	<c:set var="optVarLang" value="${optVarLang[5]}" />
									 </c:when>
									 <c:when test="${lang eq 'e3' }">
									 	<c:set var="optVarLang" value="${optVarLang[6]}" />
									 </c:when>
									 <c:when test="${lang eq 'e4' }">
									 	<c:set var="optVarLang" value="${optVarLang[7]}" />
									 </c:when>
									 <c:when test="${lang eq 'e5' }">
									 	<c:set var="optVarLang" value="${optVarLang[8]}" />
									 </c:when>
									 <c:when test="${lang eq 'e6' }">
									 	<c:set var="optVarLang" value="${optVarLang[9]}" />
									 </c:when>
									</c:choose>
									
									<c:if test="${list.FieldType eq 'Radio' or list.FieldType eq 'CheckBox' }">
										<c:if test="${list.FieldAlign eq 'H' }">
											<li>
										</c:if>
									</c:if>
									
									<c:choose>
									 <c:when test="${list.FieldType eq 'Radio' }">
									 	<div class="radioStyle05">
									 		<input type="radio" name="boxdetail_radio${status.index}" id="boxdetail_radio${status.index}_${optStatus.count}" <c:if test="${optVar[3] eq 'Y'}">checked</c:if> />
									 		<label for="boxdetail_radio${status.index}_${optStatus.count}">${optVarLang}</label>
									 	</div>
									 </c:when>
									 <c:when test="${list.FieldType eq 'CheckBox' or list.FieldType eq 'ListBox' }">
									 	<div class="chkStyle01">
									 		<input type="checkbox" name="boxdetail_checkbox${status.index}" id="boxdetail_checkbox${status.index}_${optStatus.count}" <c:if test="${optVar[3] eq 'Y'}">checked</c:if> />
									 		<label for="boxdetail_checkbox${status.index}_${optStatus.count}"><span></span>${optVarLang}</label>
									 	</div>
									 </c:when>
									 <c:when test="${list.FieldType eq 'DropDown' }">
										<option value="${optVar[2]}" <c:if test="${optVar[3] eq 'Y'}">selected</c:if>>${optVarLang}</option>
									 </c:when>
									 </c:choose>
									 
									 <c:if test="${list.FieldType eq 'Radio' or list.FieldType eq 'CheckBox' }">
										<c:if test="${list.FieldAlign eq 'H' }">
											</li>
										</c:if>
									</c:if>
								</c:forEach>
								
								<c:if test="${list.FieldType eq 'Radio' or list.FieldType eq 'CheckBox' }">
									<c:if test="${list.FieldAlign eq 'H' }">
										</ul>
									</c:if>
								</c:if>
								<c:if test="${list.FieldType eq 'ListBox' or list.FieldType eq 'CheckBox' }">
									</div>
								</c:if>
								<c:if test="${list.FieldType eq 'DropDown' }">
									</select>
								</c:if>
								
								<c:if test="${!empty list.Description || list.Description ne ''}">
									<c:if test="${list.IsTooltip eq 'Y'}">
									<div class="collabo_help02">
										<a class="help_ico"></a>
										<div class="helppopup">
											<div class="help_p">
												<p class="helppopup_tit"><spring:message code='Cache.lbl_Description'/></p>
												${list.Description }
											</div>
										</div>
									</div>
									</c:if>
									
									<c:if test="${list.IsTooltip ne 'Y'}">
										<div class='comp_ptx'>${list.Description }</div>
									</c:if>
								</c:if>
								
									<div class="compbtn"><a class="copy" href="javascript:void(0);"><spring:message code='Cache.btn_Copy'/></a><a class="remove" href="javascript:void(0);"><spring:message code='Cache.btn_remove'/></a></div>
								</div>
								</c:forEach>
								
								<c:if test="${empty formList or formList eq ''}">
									<div class="nolist">
										<div class="img"></div>
										<h2><spring:message code='Cache.msg_noAddedComponents'/></h2>
										<p><spring:message code='Cache.msg_dragComponents'/></p>
										<p><spring:message code='Cache.msg_changeProperties'/></p>
									</div>
								 </c:if>
								</div>	
								
								<div class="caMakeBottom">
									<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.btn_save'/></a>
									<a href="#" class="btnTypeDefault btnBlueBoder" id="btnAddSave"><spring:message code='Cache.btn_saveAs'/></a>
									<a href="#" class="btnTypeDefault btnBlueBoder" id="btnPreview"><spring:message code='Cache.btn_preview'/></a>
									<a href="#" class="btnTypeDefault btnBlueBoder" id="btnRefresh"><spring:message code='Cache.btn_init'/></a>
									<a href="#" class="btnTypeDefault" id="btnCancel"><spring:message code='Cache.btn_Cancel'/></a>
								</div>
							
						</div>
					</div>	
				</div>
			</div>
	</section>
</div>

<div id="mask" valign="center" style="position:absolute; z-index:9000; background-color:#000000; display:none; width:100%; height:100%; text-align:center; padding-top: 300px; opacity:0.3; left:0; top:0;">
	<img src="/covicore/resources/images/covision/loding14.gif" alt="Loading..." />
</div>

<script type="text/javascript">
var cid = $(".component_wrap .component").length;
var form_data = new Array();
var dicType;
var delFileIDs = "";
var memberOf =  "${memberOf}";
var menuID =  "${menuID}";

<c:if test="${!empty formList}">
	form_data = JSON.parse('${formList}');
</c:if>

(function(param){
	
	var setInit = function(){
		coviCtrl.bindmScrollV($('.mScrollV'));
		coviInput.setInputPattern();
	}
	
	var setEvent = function(){
		
		$(".caMakeMenu > li .depth1").click(function() {
			$(this).parent().toggleClass("active");
			//$(this).slideDown()
		});
		
		$(".caMakeMenu > li .depth2").click(function() {
			$(this).parent().toggleClass("active");
			//$(this).slideDown()
		});
		
		$(".component_wrap").sortable({
			items: $(".component"),
			connectWith: ".component_wrap",
			cancel: ".no_move_comp",
			placeholder: "comp_placeholder"
		});
		
		//메뉴드래그
		$( ".caMakeComMenu li" ).draggable({
			scope : "caMakeComMenu",
			connectToSortable: ".component_wrap",
			helper: function( event ) {
				var type = $(this).attr('data-component-type');
				return contentsApp.drawComponent(type);
		    }
		});
		
		//메뉴 드롭
		$( ".component_wrap" ).droppable({
			scope : "caMakeComMenu",
			drop: function( event, ui ) {
				
				$(".nolist").remove();
				
				$(".component_wrap").sortable({
			      items: $(".component"),
			      connectWith: ".component_wrap",
			      cancel: ".no_move_comp",
			      placeholder: "comp_placeholder"
			    });
				
				//메뉴드래그
				$( ".caMakeComMenu li" ).draggable({
					scope : "caMakeComMenu",
					connectToSortable: ".component_wrap",
					helper: function( event ) {
						var type = $(this).attr('data-component-type');
						return contentsApp.drawComponent(type);
				    }
				});
				
				contentsApp.componentClick(form_data);	//컴포넌트 클릭 이벤트
				componentImgEvent();	//컴포넌트 이미지 이벤트
			}
		});
		
		contentsApp.componentClick(form_data);	//컴포넌트 클릭 이벤트
		componentImgEvent();	//컴포넌트 이미지 이벤트
		
		//앱아이콘 설정 팝업
		$("#btnSetting").click(function () {
   			var popupID	= "ContentsIconPopup";
   			var openerID	= "";
   			var popupTit	= "<spring:message code='Cache.lbl_appIconSetting'/>";
   			var popupYN		= "N";
   			var popupUrl	= "/groupware/contents/ContentsIconPopup.do?"
   							+ "&fId="    	+ param.folderID
   							+ "&popupID="		+ popupID	
   							+ "&openerID="		+ openerID	
   							+ "&popupYN="		+ popupYN ;
   			Common.open("", popupID, popupTit, popupUrl, "395px", "480px", "iframe", true, null, null, true);
		});
		
		//폴더 이동 팝업
		$("#btnFolderMove").click(function () {
   			var popupID	= "ContentsFolderChangePopup";
   			var openerID	= "";
   			var popupTit	= Common.getDic("btn_apv_userfoldermove_2");
   			var popupYN		= "N";
   			var popupUrl	= "/groupware/contents/ContentsFolderMovePopup.do?"
   							+ "&fId="    	+ param.folderID
   							+ "&popupID="		+ popupID	
   							+ "&openerID="		+ openerID	
   							+ "&popupYN="		+ popupYN ;
   			Common.open("", popupID, popupTit, popupUrl, "390px", "480px", "iframe", true, null, null, true);
		});
		
		//툴팁
		$( ".component_wrap" ).find(".collabo_help02").mouseover(function() {
			$(this).find(".help_ico").toggleClass("active");
		});
		$( ".component_wrap" ).find(".collabo_help02").mouseout(function() {
			$(this).find(".help_ico").toggleClass("active");
		});
		
		// 다국어
		$("#dicBtn").off("click").on("click", function(){
			dicType = "folderName";
			
			var option = {
				lang : lang,
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : "folderNameDic_CallBack",
				popupTargetID : 'DictionaryPopup',
				init : "folderNameDicInit"
			};
			
			coviCmn.openDicLayerPopup(option,"DictionaryPopup");
		});
		
		$("#folderName").on("change", function(){
			var sDictionaryInfo = '';
			sDictionaryInfo = dictionaryInfo(Common.getSession("lang").toUpperCase(), this.value);
			$("#hidFolderNameDicInfo").val(sDictionaryInfo);
		});
		
		//저장
		$("#btnSave").on( 'click', function(e){
			
			if($("#folderName").val() == ""){
				alert("<spring:message code='Cache.msg_enterAppName'/>");
				return;
			}
			
			//저장할 컴포넌트 정보
			var jsonData = new Array();
			var iTitleCnt = 0 ; 
			$(".component_wrap .component").each(function (i,v){
				var cid = $(v).data("cid");
				var component_data = form_data[cid];
				
				//데이터 재정렬
				var reqMap = {};
				for (var key in component_data){
					if (key == "SortKey") continue;
					reqMap[key] = component_data[key];
					//console.log(component_data[key])
				}
				if (reqMap["IsTitle"] == "Y") iTitleCnt++;
					
				reqMap["SortKey"] = i;
				jsonData.push(reqMap);
			});
			
			if 	(iTitleCnt > 1){
				Common.Error("<spring:message code='Cache.msg_OnlyUseTitle' />"); // 제목으로 사용할 컴포넌트는 1개여야 합니다
				return;
			}

			//삭제할 컴포넌트 정보
			var userFormIDs = '';
			$.each(form_data, function(i, obj){
				if(obj["componentDel"] == "Y" && obj["UserFormID"] > 0)
					userFormIDs += obj["UserFormID"] + ';'
			});
			
			$.ajax({
				type:"POST",
				contentType: 'application/json; charset=utf-8',
				dataType: 'json',
				data: JSON.stringify({"jsonData": jsonData
					, "folderID": param.folderID
					, "memberOf": memberOf
					, "menuID":menuID
					, "displayName": $("#folderName").val()
					, "useBody":$("#chkUseBody").prop("checked")?"Y":"N"
					, "multiDisplayName": $("#hidFolderNameDicInfo").val()
					, "userFormIDs": userFormIDs							//삭제할 컴포넌트 정보
					, "delFileIDs": delFileIDs								//삭제할 파일 정보
				}),
				url:"/groupware/contents/saveUserFrom.do",
				beforeSend:function(){
					$('#mask').show();
			    }, 
			    complete:function(){
			        $('#mask').hide();
			    },
				success:function (data) {
					if(data.status == "SUCCESS"){
						imgFileSave(data.folderID, "");	//아이콘, 컴포넌트 이미지 저장
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
		});
		
		//다른이름으로 저장
		$("#btnAddSave").on( 'click', function(e){
			var popupID	= "ContentsNameChangePopup";
   			var openerID	= "";
   			var popupTit	= Common.getDic("lbl_SaveAs");
   			var popupYN		= "N";
   			var popupUrl	= "/groupware/contents/ContentsUserFormAddSavePopup.do?"
   							+ "&folderID="    	+ param.folderID
   							+ "&popupID="		+ popupID	
   							+ "&openerID="		+ openerID	
   							+ "&popupYN="		+ popupYN ;
   			Common.open("", popupID, popupTit, popupUrl, "530px", "330px", "iframe", true, null, null, true);
		});
		
		//초기화
        $('#btnRefresh').on( 'click', function(e){
			location.reload();
        });
		
		//미리보기
        $('#btnPreview').on( 'click', function(e){
			var popupUrl	= "/groupware/contents/ContentsPreview.do?";
			CFN_OpenWindow(popupUrl, "Preview", 1080, 780,"resize");
        });
		
		//취소
		$("#btnCancel").on('click', function(e){
			if (param.folderID == "")
				location.href="/groupware/contents/ContentsMain.do?memberOf="+memberOf;
			else
				location.href="/groupware/contents/ContentsList.do?folderID="+param.folderID;
		});
		
	}
	
	//컴포넌트 이미지 이벤트
	var componentImgEvent = function() {
		//이미지 파일선택
		$(".fileSelect").on("click", function(){
			$(this).closest(".imgSelect").find("input[type='file']").click();
		});
		$(".imgSelect input[type='file']").on("change",function(){
			var srcObj = $(this).closest(".imgSelect");
			var file = $(this)[0].files[0];
			
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				$(srcObj).find("img").attr("src", "");
				
				// 확장자가 이미지인지 체크
				if (fileType != 'jpg' && fileType != 'gif' && fileType != 'png' && fileType != 'jpeg' && fileType != 'bmp') {
				    Common.Warning("<spring:message code='Cache.msg_OnlyImageFileAttach'/>");/*이미지 파일만 업로드 하실수 있습니다.  */
				    return;
				}
				if(file.size > 1000000){
					Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
					$(this).val("");
					return;
				}	
	
				$(srcObj).find("img").show();//미리보기
				$(srcObj).find(".btn_del").show();//미리보기
				$(srcObj).find(".fileSelect").hide();
				$(srcObj).find(".designImgAdd").addClass("imgY");
	
				readURL($(srcObj).find("img"), this);
			}
		});
		
		//이미지 파일 삭제
		$(".imgSelect .btn_del").on("click",function(){
			var srcObj = $(this).closest(".imgSelect");
			
			srcObj.find(".designImgAdd").removeClass("imgY");
			srcObj.find(".fileSelect").show();
			srcObj.find("img").hide();
			$(this).hide();
			
			//삭제할 파일
			var cid = $(this).closest(".component").data("cid");
			var imgsrc = srcObj.find("img").data("src");
			if(imgsrc != ''){
				imgsrc = imgsrc.replace('/covicore/common/view/','');
				imgsrc = imgsrc.replace('.do','');
				
				delFileIDs += cid + "-" + imgsrc + ";";
			}
			
			srcObj.find("img").attr("src", "");
			srcObj.find("input[type='file']").val("");
			srcObj.find(".inputPath").val("");
		});
	}

	var readURL = function(imgObj, input) {
		if (input.files && input.files[0]) {
			var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
			reader.onload = function (e) {
				//파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
		        imgObj.attr("src", e.target.result);
		        //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
		        //(아래 코드에서 읽어들인 dataURL형식)
		    }                   
		    reader.readAsDataURL(input.files[0]);
		    //File내용을 읽어 dataURL형식의 문자열로 저장
		}
	}
	
	var init = function(){
		setInit();
		setEvent();
	}
	
	$(document).ready(function(){
		init();
	});
	
})({
	folderID: "${folderID}"
});

// 다국어
var folderNameDicInit = function(){
	var value;
	
	if(dicType == "folderName"){	// 폴더명 다국어
		if($('#hidFolderNameDicInfo').val() == '') value = $('#folderName').val();
		else value = $('#hidFolderNameDicInfo').val();
	
	}else if(dicType == "prop_name_txt"){	// 속성 이름 다국어
		if($('#prop_hidNameDicInfo').val() == '') value = $('#prop_name_txt').val();
		else value = $('#prop_hidNameDicInfo').val();
	
	} else if(dicType.indexOf("boxdetail_option-") > -1){	// 속성 옵션 다국어
		var optInfo = dicType.split('-');
		var tarTextObj =  $("."+optInfo[0]).find("input[type=text]").eq(optInfo[1]);
		var tarHidObj =  $("."+optInfo[0]).find("input[type=hidden]").eq(optInfo[1]);
		
		if(tarHidObj.val() == '') value = tarTextObj.val();
		else value = tarHidObj.val();
	}
	
	return value;
}

var folderNameDic_CallBack = function(data){
	
	if(dicType == "folderName"){	// 폴더명 다국어
		$('#folderName').val(data.KoFull);
		$('#hidFolderNameDicInfo').val(coviDic.convertDic(data));
		
	} else if(dicType == "prop_name_txt"){	// 속성 이름 다국어
		var trgObj = $(".component_wrap .selected");
		var tag_cid = trgObj.data("cid");
		var tag_type = trgObj.data("type");
		
		$('#prop_name_txt').val(data.KoFull);
		$('#prop_hidNameDicInfo').val(coviDic.convertDic(data));
		
		contentsApp.changeData(tag_cid, "DisplayName", data.KoFull);
		contentsApp.changeData(tag_cid, "FieldName", coviDic.convertDic(data));
		
		if(tag_type == "Button"){
			trgObj.find(".btnTypeDefault").text(data.KoFull);
		} else {
			var contentsObj = trgObj.find("label:eq(0)").contents();
			contentsObj[contentsObj.length - 1].textContent = data.KoFull;	
		}
	} else if(dicType.indexOf("boxdetail_option-") > -1){	// 속성 옵션 다국어
		
		var optInfo = dicType.split('-');
		var tarTextObj =  $("."+optInfo[0]).find("input[type=text]").eq(optInfo[1]);
		var tarHidObj =  $("."+optInfo[0]).find("input[type=hidden]").eq(optInfo[1]);
		var tarChkObj =  $("."+optInfo[0]).find("input[type=checkbox]").eq(optInfo[1]);
		var trgObj = $(".component_wrap .selected");
		var tag_cid = trgObj.data("cid");
		var tag_type = trgObj.data("type");

		tarTextObj.val(data.KoFull);
		tarHidObj.val(coviDic.convertDic(data));
		
		var newItem = "";
		$("."+optInfo[0]).find("input[type=hidden]").each(function(i, ui) {
			if(i > 0) newItem += "|";
			newItem += i + "^" + this.value + "^" + i + "^";
			newItem += (tarChkObj.is(':checked'))?"Y":"N";
		});
		
		contentsApp.changeData(tag_cid, "OptionList", newItem);
		
		switch(tag_type.toUpperCase()){
			case "DROPDOWN" : 
				trgObj.find("select option").eq(optInfo[1]).text(data.KoFull); 
				break;
			case "RADIO" : 
				trgObj.find("input[type=radio]").eq(optInfo[1]).next("label").text(data.KoFull); 
				break;
			case "CHECKBOX" : 
				var contentsObj = trgObj.find("input[type=checkbox]").eq(optInfo[1]).next("label").contents();
				contentsObj[contentsObj.length - 1].textContent = data.KoFull;
				break;
			case "LISTBOX" : 
				trgObj.find("input[type=checkbox]").eq(optInfo[1]).next("label").contents()[1].textContent = data.KoFull; 
				break;
		}
	}
	
	Common.close("DictionaryPopup");
}

var dictionaryInfo = function(lang, value){
	var sDictionaryInfo = '';
	switch (lang) {
        case "KO": sDictionaryInfo = value + ";;;;;;;;;"; break;
        case "EN": sDictionaryInfo = ";" + value + ";;;;;;;;"; break;
        case "JA": sDictionaryInfo = ";;" + value + ";;;;;;;"; break;
        case "ZH": sDictionaryInfo = ";;;" + value + ";;;;;;"; break;
        case "E1": sDictionaryInfo = ";;;;" + value + ";;;;;"; break;
        case "E2": sDictionaryInfo = ";;;;;" + value + ";;;;"; break;
        case "E3": sDictionaryInfo = ";;;;;;" + value + ";;;"; break;
        case "E4": sDictionaryInfo = ";;;;;;;" + value + ";;"; break;
        case "E5": sDictionaryInfo = ";;;;;;;;" + value + ";"; break;
        case "E6": sDictionaryInfo = ";;;;;;;;;" + value; break;
    }
    return sDictionaryInfo;
}

var dictionaryLang = function(lang, value){
	var optInfo = value.split(';');
	var sDictionaryInfo = '';
	switch (lang) {
        case "KO": sDictionaryInfo = optInfo[0]; break;
        case "EN": sDictionaryInfo = optInfo[1]; break;
        case "JA": sDictionaryInfo = optInfo[2]; break;
        case "ZH": sDictionaryInfo = optInfo[3]; break;
        case "E1": sDictionaryInfo = optInfo[4]; break;
        case "E2": sDictionaryInfo = optInfo[5]; break;
        case "E3": sDictionaryInfo = optInfo[6]; break;
        case "E4": sDictionaryInfo = optInfo[7]; break;
        case "E5": sDictionaryInfo = optInfo[8]; break;
        case "E6": sDictionaryInfo = optInfo[9]; break;
    }
    return sDictionaryInfo;
}
//폴더 이동
function fn_moveFolder(folderId, folderPathName){
	memberOf= folderId;
	$("#folderPathName").val(folderPathName);
	
}

//다른이름으로 저장
var fn_addSave = function(folderName, hidFolderNameDicInfo){
	
	var folderID = "${folderID}";
	var memberOf = "${memberOf}";
	
	if(folderName == ""){
		alert("<spring:message code='Cache.msg_enterAppName'/>");
		return;
	}
	
	//저장할 컴포넌트 정보
	var jsonData = new Array();
	$(".component_wrap .component").each(function (i,v){
		var cid = $(v).data("cid");
		var component_data = form_data[cid];
		
		//데이터 재정렬
		var reqMap = {};
		var imageChk = "";
		for (var key in component_data){
			if (key == "SortKey" || key == "UserFormID") continue;
			reqMap[key] = component_data[key];
			if(component_data[key] == "Image") imageChk = "Image";
		}
		if(imageChk == "Image") reqMap["GotoLink"] = "";
		reqMap["SortKey"] = i;
		reqMap["UserFormID"] = "";
		jsonData.push(reqMap);
	});
	
	$.ajax({
		type:"POST",
		contentType: 'application/json; charset=utf-8',
		dataType: 'json',
		data: JSON.stringify({"jsonData": jsonData
			, "pFolderID": folderID
			, "memberOf": memberOf
			, "displayName": folderName
			, "multiDisplayName": hidFolderNameDicInfo
			//, "userFormIDs": userFormIDs							//삭제할 컴포넌트 정보
			, "delFileIDs": delFileIDs								//삭제할 파일 정보
		}),
		url:"/groupware/contents/addSaveUserFrom.do",
		beforeSend:function(){
			$('#mask').show();
	    }, 
	    complete:function(){
	        $('#mask').hide();
	    },
		success:function (data) {
			if(data.status == "SUCCESS"){
				imgFileSave(data.folderID, folderID);	//아이콘, 컴포넌트 이미지 저장
			}
			else{
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}

//아이콘, 컴포넌트 이미지 저장
var imgFileSave = function(folderID, pFolderID){
	
	var formData = new FormData();
	var iconVal = $("#btnSetting").parent().attr("class");
	var useIcon = iconVal.split(' ')[1];
	var useIconSave = "true";
	
	formData.append('folderID', folderID);
	formData.append('pFolderID', pFolderID);
	
	// 아이콘 파라메터
	if(useIcon == 'custom'){
		formData.append('iconType', 'FILE');
		formData.append('iconFile', $('#iconFile')[0].files[0]);
		
		//직접입력 아이콘 변경없이 종료
		if($('#iconFile')[0].files[0] == undefined)
			useIconSave = "false";
	}else{
		formData.append('iconType', 'TEXT');
		formData.append('iconFile', useIcon);
	}
	
	formData.append('useIconSave', useIconSave);
	
	// 컴포넌트 이미지 파라메터
	var imgFileCnt = $(".imgSelect input[type='file']").length;	//컴포넌트 이미지 카운트

	formData.append('imgFileCnt', imgFileCnt);
	
	if(imgFileCnt > 0){
		var imgCid = "";
		$(".imgSelect input[type='file']").each(function(i, ui) {
			var cid = $(".component").index( $(this).closest(".component") );
			var file = $(this)[0].files[0];
			var GotoLink = form_data[cid]["GotoLink"];
			
			imgCid += cid + "-";
			formData.append('imgFile'+cid, file);
			formData.append('gotoLink'+cid, GotoLink);
		});
		
		formData.append('imgCid', imgCid.slice(0,-1));
	}
	
	//삭제할 컴포넌트 이미지
	formData.append('delFileIDs', delFileIDs);
	
	 $.ajax({
            type : 'post',
            url : '/groupware/contents/insertContentsIcon.do',
            data : formData,
            dataType : 'json',
            processData : false,
	        contentType : false,
	        beforeSend:function(){
				$('#mask').show();
		    }, 
		    complete:function(){
		        $('#mask').hide();
		    },
            success : function(data){	
            	if(data.status=='SUCCESS'){
            		Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
						location.href="/groupware/contents/ContentsList.do?folderID="+folderID;
					});
            	}else{
            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
            	}
            },
            error:function(response, status, error){
                //TODO 추가 오류 처리
                CFN_ErrorAjax(url, response, status, error);
            }
        });
}

</script>