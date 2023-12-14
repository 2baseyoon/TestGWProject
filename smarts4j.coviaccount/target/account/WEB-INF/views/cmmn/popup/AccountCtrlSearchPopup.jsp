<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<style>
	.pad10 { padding:10px;}
</style>

<body>
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:550px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div id="topitembar02" class="bodysearch_Type01">
					<div class="eaccountingTopCont">
					</div>
					<div class="inPerView type07">
						<div style="width:500px;">
							<div class="inPerTitbox">
								<span class="bodysearch_tit">
									<spring:message code='Cache.ACC_codeName'/>
								</span> 
								<input onkeydown="AccountCtrlSearchPopup.onenter()" class="input_p100" id="inputSearchText" type="text" placeholder="">
							</div>
							<a class="btnTypeDefault  btnSearchBlue"	onclick="AccountCtrlSearchPopup.searchList();">
								<spring:message code="Cache.ACC_btn_search"/>
							</a>
						</div>
					</div>
				</div>
				<div id="gridArea" class="pad10">
				</div>
				<div class="popBtnWrap bottom">
					<!-- 확인 -->
					<a onclick="AccountCtrlSearchPopup.selectCodeList();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_confirm'/></a>
					<!-- 닫기 -->
					<a onclick="AccountCtrlSearchPopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>
	</div>
</body>

<script>

	if (!window.AccountCtrlSearchPopup) {
		window.AccountCtrlSearchPopup = {};
	}
	
	(function(window) {
		var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
		
		var AccountCtrlSearchPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: [],
					ctrlCode	: Base64.b64_to_utf8("${param.ctrlCode}").split(",")
				},
				
				pageInit : function(){
					var me = this;
					me.setHeaderData();
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [{ 	key:'chk',		label:'chk',	width:'10',		align:'center',	formatter:'checkbox',
											    checked:function(){
													return me.params.ctrlCode.includes(this.item.Code) ? true : false;
												}
					    					},
					                        {	key:'Code',		label:"<spring:message code='Cache.ACC_lbl_code' />",	width:'30', align:'center',//코드
						        				formatter:function () {
								            		 return "<a onclick='AccountCtrlSearchPopup.selectCode(\"" + this.item.Code + "\", \""+ this.item.CodeName +"\"); return false;'><font color='blue'><u>"+this.item.Code+"</u></font></a>";
								            	}
							          	 	},
							          	   	{	key:'CodeName',	label:"<spring:message code='Cache.ACC_lbl_codeNm' />",		width:'30', align:'center'},//코드명
										]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					
					var searchText		= $("#inputSearchText").val();
					var codeGroup		= "AccountCtrl";
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/CommonPopup/getBaseCodeSearchCommPopupList.do";
					var ajaxPars		= {	"searchText"		: searchText
			 								,"codeGroup"		: codeGroup
			 								,"companyCode"		: CompanyCode
			 							};
					
					var pageSizeInfo	= 200;
					var pageNoInfo		= 1;
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: 'Y'
									, 	"pagingTF"		: false
									,	"height"		: "480px"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
					
					accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
				},
				
				selectCode : function(Code, CodeName){
					var me = this;
					var info;
					if(typeof(Code)==='string')
					{
						info = {	'Code'		: Code
								,	'CodeName'	: CodeName}
					}
					else
						info = Code;
					
					me.closeLayer();
					
					try{
						accountCtrl.popupCallBackStr([info]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
					
				},
				selectCodeList : function(){
					var me = this;
					var Obj = me.params.gridPanel.getCheckedList(0);
					if(Obj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");		//저장할 데이터가 없습니다.
						return;
					}else{
						me.selectCode(Obj);
					}
				},
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}
				}
		}
		window.AccountCtrlSearchPopup = AccountCtrlSearchPopup;
	})(window);
	
	AccountCtrlSearchPopup.pageInit();
	
</script>