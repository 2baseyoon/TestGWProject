<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!-- Content 영역 -->
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.lbl_RuleListTitle'/></span>
</h3>
<div style="width:100%;min-height:800px">
    <div class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/><%--새로고침--%>
		<select name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
		<!-- todo 회사구분없이 전체데이터 삭제 후 insert/update를 하는문제루 임시 제거 -->
 		<input class="AXButton BtnExcel UseRuleManageExcel" onclick="openRuleManageExcelUploadPopup();" type="button" value="<spring:message code='Cache.lbl_ExcelUpload'/>"><%--엑셀업로드--%>
		<input class="AXButton BtnExcel UseRuleManageExcel" onclick="openRuleManageExcelDownload();" type="button" value="<spring:message code='Cache.btn_ExcelDownload'/>"><%--엑셀다운로드--%>
		<input class="AXButton UseRuleManageExcel" onclick="openRuleManageVersionPopup();" type="button" value="<spring:message code='Cache.lbl_versionCont'/>"><%--버전관리--%>
	</div>
    <div style="float: left; width: 100% ;min-height: 800px">
    	<table style="width: 100%">
			<tr>
				<td style="width:38% ;">
					<div>
						<div style="margin-bottom: 10px;">
							<input type="button" value="<spring:message code='Cache.btn_apv_add'/>" onclick="treeItem('add');" class="AXButton BtnAdd" />
							<input type="button" value="<spring:message code='Cache.btn_apv_update'/>" onclick="treeItem('upd');" class="AXButton" />
							<input type="button" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="treeItem('del');" class="AXButton BtnDelete" />
						</div>
						<div id="treeDiv" style="height:650px;overflow:auto;"></div>
					</div>
				</td>
				<td style="width: 2% ;"></td>
				<td style="width: 60% ;vertical-align: top;">
                <div class="pop_btn2" align="left" style="margin-bottom: 10px;">
                    <input type="button" value="<spring:message code='Cache.btn_apv_add'/>" onclick="gridItem('add', '');" class="AXButton BtnAdd" /><%--추가--%>
					<input type="button" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="gridItem('del', '');" class="AXButton BtnDelete" /><%--삭제--%>
                </div>				
				<div id="gridDiv"></div>
	    	</tr>
  		</table>
  	</div>
</div>
<script>
	var grid = new coviGrid();
	var tree = new coviTree();
	
	initRuleMgnList();
	
	if(Common.getBaseConfig("UseRuleManageExcel") == "N"){
		$(".UseRuleManageExcel").css("display", "none");
	}
	
	function initRuleMgnList() {
		setSelect();		// 사용권한 selectbox
		setTree();
		setGrid();			// 그리드 세팅
		search();			// 검색
	}

	// selectbox
	function setSelect() {
		
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListAssignData.do");
		$("#selectUseAuthority").bindSelect({
			onchange: function(){
				setTree();		// 트리 세팅
				grid = new coviGrid();
			}
		});
	}
		
	// 트리 세팅
    function setTree() {
    	var treeBody = {
    			onclick:function(){
    		 		var obj = tree.getSelectedList();
    				setGrid();				// 그리드 세팅
    				search(obj.item.no);	// 검색
    			},
    			ondblclick:function(){
    				//Common.Inform(Object.toJSON(this.item))
    			}
    	};
    	
		$.ajax({
			type:"POST",
			data:{
				"entCode" : $("#selectUseAuthority").val()
			},
			async:false,
			url:"/approval/admin/getRuleTreeList.do",
			success:function (data) {
				if(data.result == "ok") {					
					tree.setTreeList("treeDiv", data.list, "no", "220", "left", false, false, treeBody);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/getRuleTreeList.do", response, status, error);
			}
		});
    }
    
 	// 트리 버튼
	function treeItem(mode) {
		var obj = tree.getSelectedList();
	    var entCode = $("#selectUseAuthority").val();
        var len = $("#treeDiv_AX_tbody tr").length;
        
        if (mode == "add" || mode == "upd") {
        	var data = {
  				itemId 			: "",
  				itemName 		: "",
  				upperItemId 	: "",
  				docKind 		: "",
  				itemDesc 		: "",
  				itemType 		: "",
  				itemCode 		: "",
  				upperItemCode 	: "",
  				sortnum 		: ""
            };
        	
	        // 최상위 폴더 없을때
	        if (len == 0) {
	        	Common.Inform('<spring:message code="Cache.apv_msg_rule01"/>'.replace(/&quot;/g, '"'));
	        	data.upperItemCode = "0";
	        	parent.Common.open("","manageTreeItem","<spring:message code='Cache.lbl_apv_itemManagement'/>","/approval/admin/getRuleManagementTreePopup.do?mode="+mode+"&entCode="+entCode+"&data="+Base64.utf8_to_b64(JSON.stringify(data)),"550px","250px","iframe",true,null,null,true);
	        } else if (axf.isEmpty(obj.item)) {
	        	Common.Warning("<spring:message code='Cache.msg_apv_rule01'/>");
	        	return;
	        } else {
	        	var type = obj.item.type;
	        	var height = "270px";
	        	if(type == "ACCOUNT") {
	        		height = "600px";
	        	}
	        	
	        	if (mode == "add") {
	        		data.upperItemId = obj.item.id;
	        		data.upperItemCode = obj.item.code;
	        	} else {
       				data.itemType = type;
       				data.itemId = obj.item.id;
       				data.itemCode = obj.item.code;
       				data.docKind = obj.item.DocKind;
       				data.sortnum = obj.item.SortNum;
       				data.upperItemId = obj.item.pid;
       				data.itemName = obj.item.nodeName;
       				data.itemDesc = obj.item.ItemDesc;
       				data.upperItemCode = obj.item.pcode;
	        		
		        	if(type == "ACCOUNT") {
		        		height = "500px";
		        	}
	        	}
	        	parent.Common.open("","manageTreeItem","<spring:message code='Cache.lbl_apv_itemManagement'/>","/approval/admin/getRuleManagementTreePopup.do?mode="+mode+"&entCode="+entCode+"&data="+Base64.utf8_to_b64(JSON.stringify(data))+"&type="+type,"550px",height,"iframe",true,null,null,true);
	        }
        } else {
        	if (axf.isEmpty(obj.item)) {
        		Common.Warning("<spring:message code='Cache.msg_apv_rule01'/>");
	        	return;
        	} else {
        		Common.Confirm("<spring:message code='Cache.apv_msg_rule02'/>", "Confirmation Dialog", function (confirmResult) {
        			if (confirmResult) {
		         		$.ajax({
		        			type : "POST",
		        			data : {
		        				"itemId" : obj.item.no
		        			},
		        			url : "/approval/admin/deleteRuleTree.do",
		        			success:function (data) {
		        				if (data.result == "ok") {
		        					setTree();
		        				}
		        			},
		        			error:function(response, status, error){
		        				CFN_ErrorAjax("/approval/admin/deleteRuleTree.do", response, status, error);
		        			}
		        		});
        			} else {
        				return false;
        			}
        		});
        	}
        }
	}
 	
	// 그리드 세팅
 	function setGrid() {
		// header
		var headerData = [
		              	  {key:'ApvID', label:'ApvID', width:'25', align:'center', formatter:'checkbox',sort:false},		                  	                 
		                  {key:'ApvID', label:'<spring:message code="Cache.lbl_apv_Name"/>', width:'50', align:'center', //명칭
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				html += "<a class=\"taTit\" onclick='gridItem(\"upd\",\"" + this.item.ApvID + "\"); return false;'>" + (typeof(this.item.ApvName) == "undefined" ? "" : this.item.ApvName) + "</a>";
						   				html += "</div>";
						   			return html;
								}
		                  },
		                  {key:'RuleID',  label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'50', align:'center', //구분
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				html += "<a class=\"taTit\" onclick='gridItem(\"upd\",\"" + this.item.ApvID + "\"); return false;'>" + (typeof(this.item.RuleName) == "undefined" ? "" : this.item.RuleName) + "</a>";
						   				html += "</div>";
						   			return html;
								}
		                  },	              
		                  {key:'ApvType', label:'<spring:message code="Cache.lbl_apv_type"/>', width:'60', align:'center',
			                  formatter:function(){
				                  var returnStr = "";
				                  switch(this.item.ApvType){
				                  case "initiator":
					                  returnStr = "<spring:message code='Cache.ApvType_initiator'/>";
					                  break;
				                  case "approve":
				                	  returnStr = "<spring:message code='Cache.ApvType_approve'/>";
					                  break;
				                  case "assist":
				                	  returnStr = "<spring:message code='Cache.ApvType_assist'/>";
					                  break;
				                  case "assist-parallel":
				                	  returnStr = "<spring:message code='Cache.ApvType_assist-parallel'/>";
					                  break;
				                  case "consult":
				                	  returnStr = "<spring:message code='Cache.ApvType_consult'/>";
					                  break;
				                  case "consult-parallel":
				                	  returnStr = "<spring:message code='Cache.ApvType_consult-parallel'/>";
					                  break;
				                  case "ccinfo-before":
				                	  returnStr = "<spring:message code='Cache.ApvType_ccinfo-before'/>";
					                  break;
				                  case "ccinfo":
				                	  returnStr = "<spring:message code='Cache.ApvType_ccinfo'/>";
					                  break;
				                  case "receive":
				                	  returnStr = "<spring:message code='Cache.ApvType_receive'/>";
					                  break;
				                  }
				                  return returnStr;
			                  }
		                  }, //타입
		                  {key:'ApvDesc', label:'<spring:message code="Cache.lbl_explanation"/>', width:'100', align:'center',sort:false}, //설명
		                  {key:'Sort', label:'<spring:message code="Cache.lbl_apv_Sort1"/>', width:'30', align:'center', sort:"asc"}		//정렬                  
			      		 ];
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			paging : true,
			page : {
				pageNo:1,
				pageSize:10
			},
		};
		grid.setGridConfig(configObj);
	}

	// 검색
 	function search(no) {
		if (typeof(no) != "undefined") {
			// bind
			grid.bindGrid({
				ajaxUrl : "/approval/admin/getRuleGridList.do",
				ajaxPars : {
					"itemId" : no
				},
				onLoad : function() {
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
					grid.fnMakeNavi("grid");
				}
			});
		}
	}
	
 	// 그리드 버튼
	function gridItem(mode, pStrApvID) {
		var obj = tree.getSelectedList();
		
		if (mode == "add" || mode == "upd") {
	    	if (axf.isEmpty(obj.item)) {
	    		Common.Warning("<spring:message code='Cache.msg_apv_rule01'/>"); // 상세 분류를 선택하여 주십시오.
	    		return;
	    	}

    		if (mode == "add") {
    			pStrApvID = "";
    		}

    		var sTitle = "<spring:message code='Cache.lbl_apv_itemManagement'/>"; // 아이템 관리
    		var sURL = "/approval/admin/getRuleManagementPopup.do";
    		sURL += "?mode=" + mode;
    		sURL += "&entcode=" + $("#selectUseAuthority").val();
    		sURL += "&apvid=" + pStrApvID;
    		sURL += "&itemid=" + obj.item.id;
    		sURL += "&itemcode=" + Base64.utf8_to_b64(obj.item.code);
			Common.open("","manageGridItem", sTitle, sURL, "550px", "300px", "iframe" , true, null, null, true);
		} else {
			var paramArr = new Array();
			if (pStrApvID == "") {
			    $('#gridDiv_AX_gridBodyTable tr').find('input[type="checkbox"]:checked').each(function () {
			    	paramArr.push(this.value);
			    });
			} else {
				paramArr.push(pStrApvID);
			}
		    
			if (paramArr.length > 0) {
				var url = "/approval/admin/deleteRuleManagement.do";
				var params = new Object();
				params.paramArr = paramArr;
				
				Common.Confirm("<spring:message code='Cache.msg_RUDelete'/>", "Confirmation Dialog", function (confirmResult) { // 삭제 하시겠습니까?
					if (confirmResult) {
		 		 		$.ajax({
							type : "POST",
							data : params,
							url : url,
							success:function (data) {
			    		 		var obj = tree.getSelectedList();
								if (data.result == "ok" && !axf.isEmpty(obj.item)) {
		 							if ($("#manageGridItem_if").length > 0) {
										$("#manageGridItem_if")[0].contentWindow.closeLayer();
								    }
		 							
				    				setGrid();				// 그리드 세팅
				    				search(obj.item.no);	// 검색
								}
							},
							error:function(response, status, error){
								CFN_ErrorAjax(url, response, status, error);
							}
						});
					} else {
						return false;
					}
				});
			} else {
				Common.Warning("<spring:message code='Cache.Personnel_TargetGroupMsgDel'/>"); // 삭제할 항목을 선택하세요.
				return;
			}
		}
	}
	
	// 새로고침
	function Refresh() {
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	//전결규정 엑셀팝업 창, ysyi
	function openRuleManageExcelUploadPopup(){
	    var sUrl = "/approval/admin/goRuleManageExcelPopup.do";
	    var iHeight = 600; var iWidth = 1010;
	    var nLeft = (screen.width - iWidth) / 2;
	    var nTop = (screen.height - iHeight) / 2;
	    var sWidth = iWidth.toString() + "px";
	    var sHeight = iHeight.toString() + "px";
	    var sLeft = nLeft.toString() + "px";
	    var sTop = nTop.toString() + "px";

	    CFN_OpenWindow(sUrl, "", iWidth, iHeight, "resize");
	}
	
	//전결규정 엑셀 다운로드, ysyi
	function openRuleManageExcelDownload(){
		location.href = "/approval/admin/excelRulManageDownload.do?entcode="+$("#selectUseAuthority").val();
	}
	
	//버전관리
	function openRuleManageVersionPopup(){
	    var sUrl = "/approval/admin/goRuleManageVersionPopup.do";
	    var iHeight = 600; var iWidth = 1300;
	    var nLeft = (screen.width - iWidth) / 2;
	    var nTop = (screen.height - iHeight) / 2;
	    var sWidth = iWidth.toString() + "px";
	    var sHeight = iHeight.toString() + "px";
	    var sLeft = nLeft.toString() + "px";
	    var sTop = nTop.toString() + "px";

	    CFN_OpenWindow(sUrl, "", iWidth, iHeight, "resize");
	}	
</script>