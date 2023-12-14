<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.pad10 { padding:10px;}
</style>

	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<a class="btnTypeDefault btnTypeChk" 		onclick="BaseCode.addBaseCode();"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault" 					onclick="BaseCode.ckDeleteBaseCode();"><spring:message code="Cache.ACC_lbl_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="BaseCode.Refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀 다운로드 -->
					<a class="btnTypeDefault btnExcel" 			onclick="BaseCode.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀 업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="BaseCode.callUploadPopup();"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
					<!-- 템플릿 다운로드 -->
					<!-- <a class="btnTypeDefault btnExcel" 	onclick="BaseCode.template();"><spring:message code="Cache.btn_TemplateDownload"/></a> -->
					<!-- 동기화 -->
					<!-- <a class="btnTypeDefault"	onclick="BaseCode.basecodeSync();"><spring:message code="Cache.ACC_btn_sync"/></a> -->					
				</div>				
			</div>
			<!-- 상단 버튼 끝 -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:1000px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="companyCode" class="selectType02" onchange="BaseCode.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 코드그룹 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_codeGroup"/></span>
							<span id="searchCodeGroupCombo" class="selectType02">
							</span>
							<input id="searchCodeGroupText" class="sm" type="text" onkeydown="BaseCode.onenter()">	
						</div>
						<div class="inPerTitbox">	
							<!-- 코드명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_code"/></span>
							<input id="inputSearchText" class="sm" type="text" onkeydown="BaseCode.onenter()">							
						</div>
						<a class="btnTypeDefault btnSearchBlue" onclick="BaseCode.searchBaseCode();"><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span class="selectType02 listCount" id="listCount" onchange="BaseCode.searchBaseCode();">
					</span>
					<button class="btnRefresh" type="button" onclick="BaseCode.searchBaseCode();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
			
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>
	if (!window.BaseCode) {
		window.BaseCode = {};
	}
	
	(function(window) {
		var BaseCode = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				/**
				최초 화면초기화
				*/
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchBaseCode('Y');
				},
				
				/**
				탭변경 초기화
				*/
				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchBaseCode();
				},
			
				/**
				콤보 생성
				*/
				setSelectCombo : function(pCompanyCode){
					if(pCompanyCode == undefined) {
						accountCtrl.renderAXSelect('CompanyCode', 'companyCode', 'ko','','','');
						pCompanyCode = accountCtrl.getComboInfo("companyCode").val();
					}
					
					accountCtrl.getInfo("searchCodeGroupCombo").children().remove();
					accountCtrl.getInfo("listCount").children().remove();
					
					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "BaseCode.searchBaseCode()");
					accountCtrl.getInfo("searchCodeGroupCombo").addClass("selectType02");
					
					accountCtrl.renderAXSelect('listCountNum','listCount','ko','','','',null,pCompanyCode);
					accountCtrl.renderAXSelectGrp('searchCodeGroupCombo','ko','','','','<spring:message code="Cache.ACC_lbl_comboAll"/>',pCompanyCode); //전체					
				},
				
				/**
				콤보 새로고침
				*/
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("searchCodeGroupCombo");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				/**
				그리드 헤더 세팅
				*/
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{ key:'chk',			label:'chk',									width:'60',		align:'center',	formatter:'checkbox'},
												{ key:'CompanyName',	label:"<spring:message code='Cache.ACC_lbl_company' />",		width:'70',		align:'center'},	//회사코드
					                        	{ key:'IsGroup',		label:"<spring:message code='Cache.ACC_lbl_isCodeGroup' />",	width:'30',		align:'center'},	//코드그룹여부
						        				{ key:'CodeGroup',		label:"<spring:message code='Cache.ACC_lbl_codeGroup' />",		width:'70',		align:'center'},	//코드그룹
							        			{ key:'CodeGroupName',	label:"<spring:message code='Cache.ACC_lbl_codeGroupName' />",	width:'110',	align:'center'},	//코드그룹명
							        			{ key:'Code',			label:"<spring:message code='Cache.ACC_lbl_code' />",			width:'70',		align:'center',		//코드
											    	formatter:function () {
									            		 return "<a onclick=\"BaseCode.onCodeClick('" + this.item.BaseCodeID + "', '"+this.item.IsGroup+"');\"><font color='blue'><u>"+this.item.Code+"</u></font></a>";
									            	}
							        			},
							        			{ key:'CodeName',		label:"<spring:message code='Cache.ACC_lbl_codeNm' />",			width:'110',	align:'center'},	//코드명
							        			{ key:'IsUse', 			label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'60',		align:'center',		//사용여부
							        				
							        				formatter:function () {
														var col			= 'IsUse'
														var key			= this.item.BaseCodeID;
														var value		= this.item.IsUse;
														var on_value	= 'Y';
														var off_value	= 'N';
														var onchangeFn	= 'BaseCode.updateIsUse(\"'+ this.item.CodeGroup +'\",\"'+ this.item.BaseCodeID +'\",\"'+ this.item.Code +'\",\"'+this.item.IsUse+'\")';
													return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
													}
							        			},
							        			{ key:'ModifierName',	label:"<spring:message code='Cache.ACC_lbl_modifier' />",		width:'80',		align:'center'},	//수정자
							        			{ key:'ModifyDate',		label:"<spring:message code='Cache.ACC_lbl_modifyDate' />"+Common.getSession("UR_TimeZoneDisplay"),		width:'110',	align:'center',
							        				formatter:function(){
							        					return CFN_TransLocalTime(this.item.ModifyDate,_ServerDateSimpleFormat);
							        				}, dataType:'DateTime'
							        			}		//수정일자
						        			];
					
					me.params.headerDataExcel = [
					    							{ key:'CompanyCode',	label:"<spring:message code='Cache.ACC_lbl_companyCode' />",	width:'70',		align:'center'},	//회사코드
													{ key:'CompanyName',	label:"<spring:message code='Cache.ACC_lbl_companyName' />",	width:'70',		align:'center'},	//회사명
						                        	{ key:'IsGroup',		label:"<spring:message code='Cache.ACC_lbl_isCodeGroup' />",	width:'30',		align:'center'},	//코드그룹여부
							        				{ key:'CodeGroup',		label:"<spring:message code='Cache.ACC_lbl_codeGroup' />",		width:'70',		align:'center'},	//코드그룹
								        			{ key:'CodeGroupName',	label:"<spring:message code='Cache.ACC_lbl_codeGroupName' />",	width:'110',	align:'center'},	//코드그룹명
								        			{ key:'Code',			label:"<spring:message code='Cache.ACC_lbl_code' />",			width:'70',		align:'center'},	//코드
								        			{ key:'CodeName',		label:"<spring:message code='Cache.ACC_lbl_codeNm' />",			width:'110',	align:'center'},	//코드명
								        			{ key:'IsUse', 			label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'60',		align:'center'},	//사용여부
								        			{ key:'ModifierName',	label:"<spring:message code='Cache.ACC_lbl_modifier' />",		width:'80',		align:'center'},	//수정자
								        			{ key:'ModifyDate',		label:"<spring:message code='Cache.ACC_lbl_modifyDate' />"+Common.getSession("UR_TimeZoneDisplay"),		width:'110',	align:'center'}//수정일자
							        			];
							        				
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				/**
				목록 조회
				*/
				searchBaseCode : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var pageSize	= accountCtrl.getComboInfo("listCount").val();
					var companyCode	= accountCtrl.getComboInfo("companyCode").val();
					var searchGrp	= accountCtrl.getComboInfo("searchCodeGroupCombo").val();
					var searchGrpText = accountCtrl.getInfo("searchCodeGroupText").val();
					var searchText	= accountCtrl.getInfo("inputSearchText").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseCode/searchBaseCode.do";
					var ajaxPars		= {	"searchText"	: searchText,
											"searchGrp"		: searchGrp,
											"pageSize"		: pageSize,
											"companyCode"	: companyCode,
											"searchGrpText" : searchGrpText
					};
					
					var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
					var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: "N"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
			
				
				/**
				스위칭 처리
				*/
				updateIsUse : function(CodeGroup,BaseCodeID,Code, isUse){
					var isUseValue = isUse;
					var setVal = "";
					if(isUseValue=="Y"){
						setVal = "N"
					}else{
						setVal = "Y"
					}
					$.ajax({
						type:"POST",
			 			url:"/account/baseCode/changeBaseCodeIsUse.do",
						data:{
							"CodeGroup"	: CodeGroup,
							"Code"	: Code,
							"BaseCodeID"	: BaseCodeID,
							"isUseValue"	: setVal,
							"UserId"		: Common.getSession().USERID
						},
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform(data.message);	//저장되었습니다
								BaseCode.reSearchCodeGroupCombo();
								BaseCode.searchBaseCode();
								//accountCtrl.renderAXSelectGrp('searchCodeGroupCombo',	'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />"); //전체
							}else {
								Common.Warning(data.message); //회사코드는 1개 이상 사용중이어야 합니다.
								BaseCode.reSearchCodeGroupCombo();
								BaseCode.searchBaseCode();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				/**
				항목 삭제 유효성
				*/
				ckDeleteBaseCode : function(){
					var me = this;
					var grid		= me.params.gridPanel;
					var deleteobj	= grid.getCheckedList(0);

					var cdList	= "";
					var grpList	= "";
					var isGrp	= false;
					
					if(deleteobj.length==0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다
						return;
					}
					for(var i = 0; i < deleteobj.length; i++){
						var item = deleteobj[i];
						
						cdList += item.BaseCodeID;
						if(i != deleteobj.length - 1){
							cdList += ",";
						}
						if(item.IsGroup=="Y"){
							isGrp = true;
							
							if(grpList != ""){
								grpList += ",";
							}
							grpList += item.BaseCodeID;
						}
					}
					
					if(isGrp){
				        Common.Confirm("<spring:message code='Cache.ACC_002' />", "Confirmation Dialog", function(result){	//그룹코드를 삭제하면 하위의 모든 코드가 삭제됩니다. 정말 삭제하시겠습니까?
				       		if(result){
				       			me.callDeleteBaseCode(cdList, grpList, deleteobj)
				       		}
				        });
					}
					else{
				        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//선택된 항목을 삭제하시겠습니까?
				       		if(result){
				       			me.callDeleteBaseCode(cdList, grpList, deleteobj)
				       		}
				        });
					}
				},
				
				/**
				항목 삭제 호출
				*/
				callDeleteBaseCode : function(cdList, grpList, deleteobj){
					$.ajax({
						type:"POST",
							url:"/account/baseCode/deleteBaseCode.do",
						data:{
							"baseCodeList"	: cdList,
							"grpList"		: grpList,
							"deleteobj"		: JSON.stringify(deleteobj)
						},
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform(data.message);	//삭제를 완료하였습니다.
								BaseCode.reSearchCodeGroupCombo();
								BaseCode.searchBaseCode();
							}else {
								Common.Warning(data.message); //회사코드는 1개 이상 사용중이어야 합니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				/**
				엑셀 다운로드
				*/
				saveExcel : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />",function(result){
			       		if(result){
				       		var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerDataExcel);
								var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerDataExcel);
								var searchGrp	= accountCtrl.getComboInfo("searchCodeGroupCombo").val();
								var searchText	= accountCtrl.getInfo("inputSearchText").val();
								var headerType	= accountCommon.getHeaderTypeForExcel(me.params.headerDataExcel);
								var title 		= accountCtrl.getInfo("headerTitle").text();
								var companyCode	= accountCtrl.getComboInfo("companyCode").val();	//회사코드
								var	locationStr		= "/account/baseCode/excelDownload.do?"
													//+ "headerName="		+ encodeURI(headerName)
													+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
													+ "&headerKey="		+ encodeURI(headerKey)
													+ "&searchGrp="		+ encodeURI(searchGrp)
													+ "&searchText="	+ encodeURI(searchText)
													//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
													+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
													+ "&headerType=" + encodeURI(headerType)
													+ "&companyCode=" + encodeURI(companyCode);
								
								location.href = locationStr;
			       		}
			        });
					
				},
								
				/**
				템플릿 다운로드
				미사용
				*/
				template : function(){
			        Common.Confirm("<spring:message code='Cache.ACC_msg_downloadTemplateFiles' />", "Confirmation Dialog", function(result){
			       		if(result){
						location.href = '/account/baseCode/excelTemplateDownload.do?';
					}
			        });
				},
				
				/**
				신규추가 호출
				*/
				addBaseCode : function(){
					var baseCodeId	= '';
					var isNew		= 'Y';
					
					var popupID		= "callBaseCodeAddPopup";
					var openerID	= "BaseCode";
					var popupTit	= "<spring:message code='Cache.ACC_001'/>";	//기초코드등록
					var popupYN		= "N";
					var callBack	= "callBaseCodeAddPopup_CallBack";
					var changeSize	= "ChangePopupSize"
					var popupUrl	= "/account/baseCode/callBaseCodeAddPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "baseCodeId="		+ baseCodeId+ "&"
									+ "isNew="			+ isNew;
					Common.open("", popupID, popupTit, popupUrl, "463px", "660px", "iframe", true, null, null, true);
							
				},
			
				
				/**
				상세조회 호출
				*/
				onCodeClick : function(inputBaseCodeID, inputIsGrp){
					
					var baseCodeId	= inputBaseCodeID;
					var isGrp	= inputIsGrp;
					var isNew		= 'N';

					var height = "520px"
					if(isGrp=="Y"){
						height = "620px"
					}
					
					
					var popupID		= "callBaseCodeAddPopup";
					var openerID	= "BaseCode";
					var popupTit	= "기초코드관리"//"<spring:message code='Cache.ACC_001'/>";
					var popupYN		= "N";
					var callBack	= "callBaseCodeAddPopup_CallBack";
					var changeSize	= "ChangePopupSize"
					var popupUrl	= "/account/baseCode/callBaseCodeAddPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "baseCodeId="		+ baseCodeId+ "&"
									+ "isGrp="		+ isGrp+ "&"
									+ "isNew="			+ isNew;
					Common.open("", popupID, popupTit, popupUrl, "434px", height, "iframe", true, null, null, true);
				},
				
				/**
				팝업 저장후처리
				*/
				callBaseCodeAddPopup_CallBack : function(){
					var me = this;
					me.reSearchCodeGroupCombo();
					me.searchBaseCode();
				},
				
				/**
				팝업크기 변경
				*/
				ChangePopupSize : function(popupID,popupW,popupH){
					accountCtrl.pChangePopupSize(popupID,popupW,popupH);
				},
				
				/**
				코드그룹콤보 재조회
				*/
				reSearchCodeGroupCombo : function(){
					var comboValue		= accountCtrl.getComboInfo("searchCodeGroupCombo").val();
					/* var comboInfo		= accountCtrl.getInfo("searchCodeGroupCombo");
					var comboChildren	= comboInfo.children();
					
					for(var i=comboChildren.length-1; i > -1; i--){
						if(_ie) {
							comboChildren[i].parentNode.removeChild(comboChildren[i]);
						} else {
							comboChildren[i].remove();
						}
					} */
					accountCtrl.getInfo("searchCodeGroupCombo").children().remove();
					accountCtrl.getInfo("searchCodeGroupCombo").attr("class", "selectType02 lg widSm");
					accountCtrl.renderAXSelectGrp('searchCodeGroupCombo',	'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />");
					accountCtrl.getComboInfo("searchCodeGroupCombo").bindSelectSetValue(comboValue);
				},
				
				/**
				엑셀 업로드
				*/
				callUploadPopup : function(){
					
					var popupID		= "target_pop";
					var openerID	= "BaseCode";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_excelUpload'/>";
					var popupYN		= "N";
					var callBack	= "callUploadPopup_CallBack";
					var popupUrl	= "/account/baseCode/callBaseCodeExcelUploadPoup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					
					Common.open("", popupID, popupTit, popupUrl, "499px", "272px", "iframe", true, null, null, true);
				},
				
				/**
				엑셀업로드 후처리
				*/
				callUploadPopup_CallBack : function(){
					var me = this;
					me.reSearchCodeGroupCombo();
					me.searchBaseCode();
				},
			
				
				/**
				동기화
				*/
				basecodeSync : function(){
					var me = this;
					Common.Inform("<spring:message code='Cache.ACC_msg_syncIF' />");	//인터페이스 이후 동기화 추가 필요
				},

				
				/**
				새로고침
				*/
				Refresh : function(){
					accountCtrl.pageRefresh();
				},
				/**
				엔터시 조회
				*/
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchBaseCode();
					}
				}
		}
		window.BaseCode = BaseCode;
	})(window);
	
</script>