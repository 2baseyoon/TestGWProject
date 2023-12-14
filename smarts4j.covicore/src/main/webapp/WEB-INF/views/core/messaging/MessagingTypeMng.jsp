<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
input:disabled{background-color:#Eaeaea}
.dis_check{background-color:#Eaeaea !important}
input[type="checkbox"] { display:inline-block; }
.tblList .AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr td select { min-width:56px; }
.chkStyle10 { display:inline-block; margin-left:7px; vertical-align:middle; }
.chkStyle10:first-child { margin-left:0; }
.chkStyle10 input[type="checkbox"] { display:none; }
.chkStyle10 input[type="checkbox"] + label { font-size:13px; color:#333; }
.chkStyle10 input[type="checkbox"] + label .s_check { position:relative; display:inline-block; margin:-3px 6px 0 0; width:15px;  height:15px; vertical-align:middle; background-color: #fff; border: 1px solid #ACAEB2; border-radius:3px; box-sizing: border-box; cursor:pointer; }
.chkStyle10 input[type="checkbox"]:checked + label .s_check { background:#566472; border:1px solid #566472; }
.chkStyle10 input[type="checkbox"]:checked + label .s_check:after { position:absolute; left:4px; top:1px; display:block; content:""; width:3px; height:6px; border:1px solid #fff; border-width: 0 2px 2px 0; -webkit-transform: rotate(45deg); -ms-transform: rotate(45deg); transform: rotate(45deg); }
</style>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_359'/></span>
</h3>
<div>
	<div id="topitembar01" class="topbar_grid">
		<input type="button" id="btnRefresh" class="AXButton BtnRefresh" value="<spring:message code="Cache.btn_Refresh"/>" />
		<input type="button" id="btnAdd" class="AXButton BtnAdd" value="<spring:message code="Cache.btn_Add"/>" />
		<input type="button" id="btnDelete" class="AXButton BtnDelete" value="<spring:message code="Cache.btn_delete"/>" />
	</div>	
	<div id="topitembar01" class="topbar_grid">
		
		<spring:message code="Cache.lbl_BizSection"/>&nbsp;
		<select class="AXSelect" id="bizSection" name="bizSection"></select>
		
		<spring:message code="Cache.lbl_IsUse"/>&nbsp; <!-- 사용여부  -->
		<select class="AXSelect" id="add_isused">
			<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체  -->
			<option value="Y"><spring:message code="Cache.lbl_Use"/></option> <!-- 사용  -->
			<option value="N"><spring:message code="Cache.lbl_NotUse"/></option> <!-- 비사용  -->
		</select>		
		
		<spring:message code="Cache.lbl_n_att_vacTypeDisplay"/>&nbsp; <!-- 표시여부  -->
		<select class="AXSelect" id="reservedInt">
			<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체  -->
			<option value="1"><spring:message code="Cache.lbl_Display2"/></option> <!-- 표시함  -->
			<option value="0"><spring:message code="Cache.lbl_noDisplay"/></option> <!-- 표시안함  -->
		</select>
		
		<spring:message code="Cache.lbl_codeNm"/>&nbsp;
		<input type="text" id="codeName"  class="AXInput" onkeypress="if (event.keyCode==13){ msgTypeObj.grid.search(); return false;}"/>&nbsp;
		
		<input type="button" id="btnSearch" class="AXButton" value="<spring:message code="Cache.btn_search"/>" />			
		
		<br />
		<span>사용 : 매체사용가능  / 기본: 회사설정(기본값) / 개인: 사용설정가능 여부</span>		
	</div>
	<div class="boradTopCont">
		<div style="float:left" id=gridTypeDiv>
		</div>
		<div class="tblList tblCont" >
			<div id="gridDiv">
			</div>
		</div>
	</div>
</div>

<script>
	var msgTypeObj = {
		pageStart: function () {
			msgTypeObj.util.searchType();
			
			//검색
			$("#btnSearch").click(function(){
				msgTypeObj.grid.search();
			});
			
			//새로고침
			$("#btnRefresh").click(function(){
				$("#bizSection").bindSelectSetValue('');
				$("#reservedInt").val("");
				$("#codeName").val("");
				
				msgTypeObj.grid.search();
			});
			
			//추가
			$("#btnAdd").click(function(){
				msgTypeObj.util.addConfig(false);
			});
			
			//삭제
			$("#btnDelete").click(function(){
				msgTypeObj.util.deleteMessage();
			});
			
			/*
			$(document).off('click','.check_class').on('click','.check_class',function(){
				var dataMap = $(this).data();
//				dataMap["mode"] = $(this).val();
				dataMap["mediaType"] = $(this).val();
				dataMap["mediaFlag"] = $(this).prop("checked")?"Y":"N";
				msgTypeObj.util.saveMsgType(dataMap);
		    });
			*/
			
			//업무구분 조회
			var lang = Common.getSession("lang");
			$.ajax({
				type:"POST",
				data:{"codeGroup" : "TodoMsgType"},
				url:"/covicore/basecode/searchgroup.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						
						var optionArray = new Array();
						optionArray.push({BizSection:"", BizSectionName:"전체"});
						$.each(data.list, function(index, item) {
							var optionObj = new Object();
							optionObj.BizSection = item.BizSection;
					    	optionObj.BizSectionName = item.BizSectionName;	
					    	
							optionArray.push(optionObj);
						});
						
						$("#bizSection").bindSelect({
							reserveKeys : {
								optionValue : "BizSection",
								optionText : "BizSectionName"
							},
							options : optionArray,
							ajaxAsync:false
						});
						
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
			
			$("#bizSection").change(function(){
				msgTypeObj.grid.search();
			});
			
			//사용여부
			$("#add_isused").change(function(){
				msgTypeObj.grid.search();
			});
			
			//표시여부
			$("#reservedInt").change(function(){
				msgTypeObj.grid.search();
			});
		},
		util:{
			mediaType : '',
			searchType:function(){
				$.ajax({
					type:"POST",
					data:{"codeGroups" : "TodoCategory,NotificationMedia"},
					url:"/covicore/basecode/get.do",
					success:function (data) {
						if(data.result == "ok"){
							$.each(data.list[0]["TodoCategory"], function(index, item) {
//								$("#gridTypeDiv").append($("<a>",{"text":item.Code=="TodoCategory"?"ALL":item.CodeName, "data":item.Code})));
							});
							msgTypeObj.util.mediaType=data.list[1]["NotificationMedia"];
							msgTypeObj.grid.bind();
						}
					},
					error:function (error){
						Common.Error(error.message);
					}
				});
			},
			addConfig:function(pModal){
				var sOpenName = "MessagingTypeMngPopup";
				var sURL = "/covicore/admin/messaging/goMessagingTypeMngPopup.do?mode=add";
				
				parent.Common.open("", sOpenName, "<spring:message code='Cache.lbl_CodeCreation'/>", sURL, "750px", "500px", "iframe", pModal, null, null, true);
			},
			updateConfig:function(pModal, configkey, pCode, pCodeGroup, pDomainID){
				var sOpenName = "MessagingTypeMngPopup";
				var sURL = "/covicore/admin/messaging/goMessagingTypeMngPopup.do?mode=modify";
				sURL += "&codeID="+configkey+"&code="+pCode+"&codeGroup="+pCodeGroup+"&domainID="+pDomainID;
				
				parent.Common.open("", sOpenName, "<spring:message code='Cache.lbl_CodeModify'/>", sURL, "750px", "500px", "iframe", pModal, null, null, true);
			},
			updateIsUse:function(codeid){
				var dataMap = {"codeid":codeid, "mode":"VIEW","isDisplay":$("#"+codeid).val()};
				msgTypeObj.util.saveMsgType(dataMap);
			},
			saveMsgType: function (dataMap) {
				 $.ajax({
					type:"POST",
					data:dataMap,
					url:"/covicore/admin/messaging/setMessagingType.do",
					success:function (data) {
						if(data.status == "FAIL") {
							Common.Warning(data.message);
						} else {
							Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
								if(result) {
									window.location.reload();
								}
							});
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/admin/messaging/setmessagingdata.do", response, status, error);
					}
				});
			},
			deleteMessage: function () {
				var deleteObject = msgTypeObj.grid.myGrid.getCheckedList(0);
				
				if(deleteObject.length == 0 || deleteObject == null){
					Common.Inform("<spring:message code='Cache.msg_selectTargetDelete'/>"); //삭제할 대상을 선택하세요.
					return false;
				}else{
					Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
						if(result) {
							var deleteSeq = "";
							
							for(var i=0; i < deleteObject.length; i++){
								deleteSeq  += (i>0?";":"") +  deleteObject[i].CodeID;
							}
							
							$.ajax({
								type:"POST",
								data:{"CodeID" : deleteSeq	},
								url:"/covicore/admin/messaging/deleteMessagingType.do",
								success:function (data) {
									if(data.status == "FAIL") {
										Common.Warning(data.message);
									} else {
										Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
											if(result) msgTypeObj.grid.search();		
										});
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/covicore/admin/messaging/deleteMessagingType.do", response, status, error);
								}
							});
						}
					});
				}
			},
			inArray:function(findStr, arrayList, col){
				for (var i=0; i < arrayList.length; i++){
					if (col != "")
						if (arrayList[i][col] == findStr)	return true;
					else
						if (arrayList[i] == findStr)	return true;
				}
				return false;
			},
			drawMedia:function(data, filterType){
				var mediaList = data.Reserved1.split(";");//사용가능한 매체
				var useMedia = data.Reserved2.split(";");//사용자가 설정 가능한 매체 
				var defaultMedia = data.Reserved3.split(";");//초기설정값
				var codeId = data.CodeID;
				var objId = filterType+'_'+codeId;
				
				var isUse = msgTypeObj.util.inArray(filterType, mediaList)?true:false;
				var dataMap	 = " data-codeId='"+data.CodeID+"'";				
				// data-map='"+JSON.stringify(dataMap)+"'
				
				return '<div class="chkStyle10">'+
				'			<input type="checkbox" class="check_class" id="chk'+objId+'_1" value="'+filterType+'"' +(isUse ?"checked":"")+'  '+"disabled"+' data-mode="USE" '+dataMap+'">'+
				'			<label for="chk'+objId+'_1"><span class="s_check"></span>사용</label>'+
				'		</div>	'+
				'<div class="chkStyle10">'+
				'			<input type="checkbox" class="check_class" id="chk'+objId+'_2" value="'+filterType+'"' +(isUse?"":"")+'  '+"disabled"+' '+(msgTypeObj.util.inArray(filterType, defaultMedia) ?"checked":"")+'  data-mode="DIV" '+dataMap+'">'+
				'			<label for="chk'+objId+'_2"><span class="s_check"></span>기본</label>'+
				'		</div>	'+
				'<div class="chkStyle10">'+
				'			<input type="checkbox" class="check_class" id="chk'+objId+'_3" value="'+filterType+'"' +(isUse?"":"")+'  '+"disabled"+' '+(msgTypeObj.util.inArray(filterType, useMedia) ?"checked":"")+'  data-mode="DEF" '+dataMap+'">'+
				'			<label for="chk'+objId+'_3"><span class="s_check"></span>개인</label>'+
				'		</div>	'
				;
			},
			findMedia:function(filterType){
				return msgTypeObj.util.inArray(filterType, msgTypeObj.util.mediaType, "Code");
			}
		},
		grid:{
			myGrid: new coviGrid(),
			bind: function () {
				msgTypeObj.grid.myGrid.setGridConfig({
							targetID: "gridDiv",
							height:"auto",			
							page : {pageNo: 1,pageSize: 10},
							//sort: false,
							colGroup: [
					             {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},   
					             {key:'BizSectionName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'70', align:'left'},
			            		 {key:'CodeName', label:'<spring:message code="Cache.lbl_codeNm"/>', width:'100', align:'center',
				            	 	formatter:function () {
				            		 	return "<a href='#' onclick='msgTypeObj.util.updateConfig(false, \""+ this.item.CodeID +"\", \""+ this.item.Code +"\", \""+ this.item.CodeGroup +"\", \""+this.item.DomainID+"\"); return false;'>"+this.item.CodeName+"</a>";
				            		 }},
			            		 {key:'Reserved1',  label:'<spring:message code="Cache.lbl_Mail"/>', width:'200', align:'center', sort: false, display:msgTypeObj.util.findMedia('MAIL'), formatter:function () {
					      				return msgTypeObj.util.drawMedia(this.item, "MAIL");}
			            		 },	
			            		 {key:'Reserved2',  label:'<spring:message code="Cache.lbl_ToDo"/>', width:'200', align:'center', sort: false, display:msgTypeObj.util.findMedia('TODOLIST'), formatter:function () {
					      				return msgTypeObj.util.drawMedia(this.item, "TODOLIST");}
			            		 },
			            		 {key:'Reserved3',  label:'<spring:message code="Cache.CPMail_MDM"/> ', width:'200', align:'center', sort: false, display:msgTypeObj.util.findMedia('MDM'), formatter:function () {
					      				return msgTypeObj.util.drawMedia(this.item, "MDM");}
			            		 },
			            		 {key:'Reserved3',  label:'<spring:message code="Cache.lbl_Messanger"/>', width:'200', align:'center', sort: false, display:msgTypeObj.util.findMedia('MESSENGER'), formatter:function () {
					      				return msgTypeObj.util.drawMedia(this.item, "MESSENGER");}
			            		 },
			            		 {key:'ReservedInt',  label:'<spring:message code="Cache.lbl_n_att_vacTypeDisplay"/>', width:'70', align:'center', formatter:function () {
					      				return "<input type='text' kind='switch' on_value='1' off_value='0' id='"+this.item.CodeID+"' value='"+this.item.ReservedInt+"' style='width:40px;height:21px;border:0px none;' onchange='msgTypeObj.util.updateIsUse(\""+this.item.CodeID+"\");'  />";}
			            		}
							]
					}
				);
				msgTypeObj.grid.search();
			},
			search: function () {
				msgTypeObj.grid.myGrid.page.pageNo = 1;
				
				msgTypeObj.grid.myGrid.bindGrid({
		 			ajaxUrl:"/covicore/basecode/getList.do",
		 			ajaxPars: {
		 				"domain": 0
		 				,"codeGroup":"TodoMsgType"
		 				,"bizSection":$("#bizSection").val()
	 					,"codeName":$("#codeName").val()
	 					,"isUse":$("#add_isused").val()
	 					,"reservedInt":$("#reservedInt").val()
	 					,"sortBy":"BizSectionName ASC"
	 				}
				});
			}
		}
	};
	
jQuery(document.body).ready(function () {
	msgTypeObj.pageStart();
});
</script>
