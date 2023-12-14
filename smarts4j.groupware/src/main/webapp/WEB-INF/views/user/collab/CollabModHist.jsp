<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
#inputBasic_AX_EndDateHist_AX_dateHandle { right: -7px !important; top: -0px !important; height:28px !important; border:0px solid #d6d6d6; min-width:40px; border-radius: 2px; }
</style>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_chglog'/></h2>	
</div>
<div class="cRContCollabo mScrollVH" id="collabModHist">
	<!-- 컨텐츠 시작 -->
<div class="Collabo_cont">
	<div class="bodysearch_Type01 change_history">
		<div class="inPerView type08">
			<div class="sch_item_half">
				<div class="inPerTitbox">
					<span class="bodysearch_tit"><spring:message code='Cache.lbl_apv_article'/></span>	<!-- 항목 -->
					<select class="selectType02" id="ModItem"></select>
				</div>
				<div class="inPerTitbox sch_item_half_right">
					<span class="bodysearch_tit"><spring:message code='Cache.lbl_ModifyDate'/></span>	<!-- 수정일 -->
					<div  class="dateSel type02">
						<input class="adDate" type="text" id="StartDateHist" date_separator="." readonly> ~
						<input id="EndDateHist" date_separator="." date_startTargetID="StartDateHist" class="adDate" type="text" readonly>
					</div>											
				</div>	
			</div>
			<div class="sch_item">
				<div class="inPerTitbox">
					<span class="bodysearch_tit"><spring:message code='Cache.lbl_TFName'/></span>	<!-- 프로젝트명 -->
					<div class="org_list_box " id="prjList">
					</div>
					
					<a class="btnTypeDefault btnRemove" id="btnDelProject" ></a>
					<a class="btnTypeDefault search" id="btnProject"></a>
				</div>					
			</div>
			<div class="sch_item">
				<div class="inPerTitbox">
					<span class="bodysearch_tit"><spring:message code='Cache.lbl_Modifier'/></span>	<!-- 수정자 -->
					<div class="org_list_box" id="resultViewMember">
					</div>
					<a class="btnTypeDefault btnRemove" id="btnDelOrg"></a>
					<a href="#" id="btnOrg" class="btnTypeDefault search"></a>
					<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue "><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
				</div>	
			</div>	
		</div>
	</div>
	<div class="CollaboMTopCont" style="height:40px;margin-top:-10px;">
		<div class="buttonStyleBoxRight">
			<select class="selectType02 listCount" id="selectSize">
				<option>10</option>
				<option>20</option>
				<option>30</option>
			</select>
			<button href="#" class="btnRefresh" type="button"></button>							
			<button href="#" class="btnMoreStyle01 btnExcel" id="btnExcel" title="<spring:message code='Cache.btn_ExcelDownload'/>"></button>
		</div>
	</div>	
	<div class="tblList">
		<div id="collabModHistGridDiv"></div>
	</div>
</div>
	<!-- 컨텐츠 끝 -->
</div>
<script>
var collabModHist = {
		g_curDate : CFN_GetLocalCurrentDate("yyyy.MM.dd"),
		grid:'',
		orgMapDivEl  : $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close', "id":"btn_del"})),
    	MultiAutoInfos : {
    			labelKey : 'DisplayName',
    			valueKey : 'UserCode',
    			minLength : 1,
    			useEnter : false,
    			multiselect : true,
    			select : function(event, ui) {
    				var id = $(document.activeElement).attr('id');
    				var item = ui.item;
    				var type = "UR" ;
    				
    				if ($('#' + id.replace("Input","Div")).find(".date_del[type='"+ type+"'][code='"+ item.UserCode+"']").length > 0) {
    					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
    					ui.item.value = '';
    					return;
    				}
    				
    				var cloned = collabModHist.orgMapDivEl.clone();
    				cloned.attr('type', type).attr('code', item.UserCode);
    				cloned.find('.ui-icon-close').before(item.label);

    				$(this).before(cloned);
    		    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
    			}},		
		objectInit : function(){		
			this.makeGrid();
			this.addEvent();
			this.searchData(1);
		}	,
		makeGrid :function(){
			var configObj = {
					targetID : "collabModHistGridDiv",
					height: "auto",
					page : {pageNo: 1, pageSize: 10},
					paging : true};
			var headerData =  [ 
						{key:'RegisteDate',	label:"<spring:message code='Cache.lbl_EventDate' />", width:'90', align:'center'},		//요청종류
						{key:'RegisterName', label:'<spring:message code="Cache.lbl_apv_modiuser" />', width:'90', align:'center'}, 	//요청자
						{key:'PrjName', label:'<spring:message code="Cache.lbl_project_name" />', width:'150', align:'left', sort:false},
						{key:'TaskName', label:'<spring:message code="Cache.lbl_TaskName" />', width:'150', align:'left'},
						{key:'ModItemName', label:'<spring:message code="Cache.lbl_ItemName" />', width:'70', align:'center'},
						{key:'ModTypeName', label:'<spring:message code="Cache.lbl_eventtype" />', width:'70', align:'center'},
						{key:'BfValName', label:'<spring:message code="Cache.lbl_BeforeChange" />', width:'150', align:'left', sort:false},
						{key:'AfValName', label:'<spring:message code="Cache.lbl_change" />', width:'150', align:'left', sort:false}
				];
			collabModHist.grid = new coviGrid();
			collabModHist.grid.setGridHeader(headerData);
			collabModHist.grid.setGridConfig(configObj);
		},
		addEvent : function(){
			coviCtrl.renderAXSelect('CollabHistory', 'ModItem', lang, '', '','',true); 	
			$("#collabModHist #EndDateHist").bindTwinDate({
				startTargetID : "StartDateHist",
				separator : ".",
				onChange:function(){
					collabModHist.searchData(1);
				},
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
			$("#collabModHist #StartDateHist").val(schedule_SetDateFormat(new Date(this.g_curDate.substring(0,4), (this.g_curDate.substring(5,7) - 1), 1), '.'));
			$("#collabModHist #EndDateHist").val(this.g_curDate);

			$('#collabModHist #selectSize' ).on( 'change', function(e){
				collabModHist.searchData(1);
			});
			
			$('#collabModHist #btnSearch, #collabModHist .btnRefresh' ).on( 'click', function(e){
				collabModHist.searchData(1);
			});
			
			//엑셀다운
			$('#collabModHist #btnExcel' ).on( 'click', function(e){
		        if (confirm(Common.getDic("msg_WantToDownload"))) { //다운로드 하시겠습니까?
		        	var trgMemberArr = new Array();
					var trgPrjArr  = new Array();
				 	$('#resultViewMember').find('.date_del').each(function (i, v) {
						trgMemberArr.push($(v).attr('code'));
					});

				 	$('#prjList').find('p').each(function (i, v)  {
						trgPrjArr.push($(v).data("prjSeq"));
					});
					
				 	var params = "&trgUser="+ trgMemberArr.toString()+
						"&trgProject="+ trgPrjArr.toString()+
						"&modItem="+$("#collabModHist #ModItem").val()+
						"&startDate="+$("#collabModHist #StartDateHist").val()+
						"&endDate="+$("#collabModHist #EndDateHist").val();
		            location.href= '/groupware/collabHist/excelTaskHistLis.do?'+params;
		        }
			});

			
			$('#collabModHist #btnProject').on( 'click', function(e){
				collabModHist.openProjectPopup()
			});	
			$('#collabModHist #btnDelProject').on( 'click', function(e){
				collabModHist.deleteProject()
			});	

			$('#collabModHist #btnOrg').on( 'click', function(e){//LM__B
				/*				var url = "/covicore/control/goOrgChart.do?callBackFunc=orgViewerCallback&type=A1&treeKind=Group&groupDivision=Basic&drawOpt=LM__B";			
				title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
				var w = "520";
				var h = "580";
				CFN_OpenWindow(url,"openGroupLayerPop",w,h,"");*/
				var url = "/covicore/control/goOrgChart.do?callBackFunc=orgViewerCallback&type=B9&treeKind=Group&groupDivision=Basic&drawOpt=LM__B";			
				title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
				var w = "1000";
				var h = "580";
				CFN_OpenWindow(url,"openGroupLayerPop",w,h,"");
			});
			
			$('#collabModHist #btnDelOrg').on( 'click', function(e){//LM__B
				collabModHist.deleteOrg()
			});
			//사용자나 부서/일자 삭제
			$(document).on('click', '#btn_del', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});

		},
		validationChk:function(){
			var listobj = collabModHist.grid.getCheckedList(0);
			var aJsonArray = new Array();
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
				return false;
			}
			return true;
		},
		searchData:function(pageNo){
			var trgMemberArr = new Array();
			var trgPrjArr  = new Array();
		 	$('#resultViewMember').find('.date_del').each(function (i, v) {
				trgMemberArr.push($(v).attr('code'));
			});

				
		 	$('#prjList').find('p').each(function (i, v)  {
				trgPrjArr.push($(v).data("prjSeq"));
			});
		 	
			
			var params = { "reqStatus":$('#collabModHist #ReqStatus' ).is(":checked")?"Y":""
				,"trgUser": trgMemberArr.toString()
				,"trgProject": trgPrjArr.toString()
				,"modItem":$("#collabModHist #ModItem").val()
				,"startDate":$("#collabModHist #StartDateHist").val()
				,"endDate":$("#collabModHist #EndDateHist").val()
			};

			if (pageNo !="-1"){
				collabModHist.grid.page.pageNo =pageNo;
				this.grid.page.pageSize = $('#collabModHist #selectSize').val();
			}	
			// bind
			collabModHist.grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabHist/getTaskHistList.do"
			});

		},
		openProjectPopup : function() {
	 		var popupID	= "CollabProjectAllocPopup";
	 		var openerID	= "";
	 		var popupYN		= "N";
	 		var popupUrl	= "/groupware/collabProject/CollabProjectSelPopup.do?"+
						 		"&callback=callbackProjectSel";
			Common.open("", popupID, Common.getDic("lbl_Project"), popupUrl, "500", "650", "iframe", true, null, null, true);
			return new Promise(resolve => {
				const listener = (e) => {
					if (e.data.functionName == "setProjectSel"){
						var list = e.data.params.list;
						var maxCount = false; // 중복 여부
				    	var duplication = false; // 중복 여부
				    	$.each(list, function (i, v){
				    		if ($('#prjList' ).find("p[data-prjSeq='"+ v.PrjSeq+"']").length > 0) {
								duplication = true;
							}
							if ($('#prjList').find("p").length >=5){
								maxCount = true;
							}

							if (!duplication && !maxCount ){				
						    	$("#prjList").append($("<p>",{"class":"date_del", "data":{"prjSeq":v.PrjSeq}, "data-prjSeq":v.PrjSeq, "text":""+v.PrjName})
										.append($("<a>",{"class":"ui-icon ui-icon-close","id":"btn_del"}))
								);
							}	
				    	});	
						if(duplication){
							Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
						}
				    	if (maxCount){
							Common.Warning("<spring:message code='Cache.CPMail_limitCount'/>".replace("{0}", "5")); //최대 5개 입니다.
						}
						window.removeEventListener('message', listener);
					}	
				}
				
				window.addEventListener('message', listener);
			})
		
		},
		deleteProject:function(){
			$("#prjList").empty();
		},
		deleteOrg:function(){
			$("#resultViewMember").empty();
		},

}

$(document).ready(function(){
	collabModHist.objectInit();
});

function orgViewerCallback(orgData){
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;
	var reqOrgMapTarDiv = "resultViewMember";

	if (item != '') {
		var duplication = false; // 중복 여부
		var maxCount = false;
		$.each(item, function (i, v) {
			var type = (v.itemType == 'user') ? 'UR' : 'GR';
			var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
			var DeptName = v.ExGroupName.split(';')[0];
			var PhotoPath = v.PhotoPath;
			
			if ($('#' + reqOrgMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"']").length > 0) {
				duplication = true;
				return true;;
			}
			
			if ($('#' + reqOrgMapTarDiv).find(".date_del").length >=49){
				maxCount = true;
				return true;
			}
			
			var cloned = collabModHist.orgMapDivEl.clone();
			cloned.attr('type', type).attr('code', code);
			cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DN));
//			var cloned = collabUtil.drawProfile({"code":code,"type":type,"PhotoPath":PhotoPath,"DisplayName":CFN_GetDicInfo(v.DN),"DeptName":DeptName}, true);
			$('#' + reqOrgMapTarDiv).append(cloned);
		});
		
		if(duplication){
			Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
		}
			
		if (maxCount){
			Common.Warning('<spring:message code="Cache.msg_collab2" />');	//최대 가능수[50인]를 초과하였습니다. 더이상 추가되지 않습니다.
		}
	}
}
</script>					