<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String FormInstID = request.getParameter("FormInstID");
	String ProcessID  = request.getParameter("ProcessID");
%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/approvestatlist.js<%=resourceVersion%>"></script>

<tr class="openApp">
	<td colspan="3">
		<ul class="tabDesign">
			<li class="tabOn"><a id="aGraphicPage" style="cursor: pointer;" onclick="clickTab(this);" value="Graphic"><spring:message code='Cache.lbl_apv_graphic'/></a></li>
			<li class="tab"><a id="aListPage" style="cursor: pointer;" onclick="clickTab(this);" value="List"><spring:message code='Cache.lbl_apv_list'/></a></li>
			<li class="tab"><a id="aTCInfoPage" style="cursor: pointer;" onclick="clickTab(this);" value="TCInfo"><spring:message code='Cache.lbl_TCInfoListBox'/></a></li>
			<li class="tab"><a id="aAttachPage" style="cursor: pointer;" onclick="clickTab(this);" value="Attach"><spring:message code='Cache.lbl_apv_AttachList'/></a></li>
			<li class="tab"><a id="aReceiptPage" style="cursor: pointer;" onclick="clickTab(this);" value="Receipt"><spring:message code='Cache.lbl_apv_receipt_view'/></a></li>
			<li class="tab"><a id="aReadCheckPage" style="cursor: pointer;" onclick="clickTab(this);" value="ReadCheck"><spring:message code='Cache.lbl_apv_ReadCheck'/></a></li>
		</ul>
		<div class="tabCont selected">
			<div class="coviGrid tblList" style="margin-top: 0;"> <!-- FlowerName css 때문에 tblList, margin-top: 0; 추가 -->
				<div id="approvalDetailListGrid" style="height: 30px;"></div>
				<div id="graphicDiv"></div>
				<div id="ListDiv"></div>
			</div>
		</div>
	</td>
</tr>

<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var selectParams;
	var clickedTab = "Graphic";
	var url;
	var dataobj;
	var objGraphicList;
	var objNewDataList;
	var g_DisplayJobType = Common.getBaseConfig("ApprovalLine_DisplayJobType") || "title"; // 직책, 직급, 직위 중 결재선에 표시될 타입 설정 (직책 : title, 직급 : level, 직위 : position)
	var GovDocs = CFN_GetQueryString("GovDocs") == "undefined" ? "" : CFN_GetQueryString("GovDocsGovDocs"); //nykim
	
	initDetailList();
	
	function initDetailList(){
		if(GovDocs == "") {
			setGrid();
			$.ajax({
				url:"/approval/getDomainListData.do",
				type:"post",
				data: selectParams,
				async:false,
				success:function (data) {
					dataobj = Object.toJSON(data.list[0].DomainDataContext);
					getList(dataobj);
					//
					objGraphicList = ApvGraphicView.getGraphicData(dataobj);
					ApvGraphicView.initRender($("#graphicDiv"), objGraphicList);
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/getDomainListData.do", response, status, error);
				}
			});
		} else {
			clickTab("#aReceiptPage");
			$("ul a[value!='"+clickedTab+"']").hide();
		}
	}

	function setGrid(){
		if(clickedTab == "List" ){
			$("#ListDiv").show();
			$("#graphicDiv").hide();
			$("#approvalDetailListGrid").hide();
		}else if(clickedTab == "Graphic" ){
			$("#graphicDiv").show();
			$("#ListDiv").hide();
			$("#approvalDetailListGrid").hide();
		}else{
			$("#approvalDetailListGrid").show();
			$("#graphicDiv").hide();
			$("#ListDiv").hide();
		}
		
		setGridConfig();
		setListData();
	}
	function setGridConfig(){
		var notFixedWidth = 1;
		
		 if(clickedTab == "List"){
			 var headerData =[
						      {key:'Num', label:'<spring:message code="Cache.lbl_Number"/>', width:'12', align:'center'},
			                  {key:'UserName', label:'<spring:message code="Cache.lbl_name"/>',  width:'12', align:'center'},
						      {key:'StatusName', label:'<spring:message code="Cache.lbl_CommunityRegStatus"/>',  width:'18', align:'center'},//밑에 State랑 같이 한 행으로 합쳐져야함
						      {key:'Kind', label:'<spring:message code="Cache.lbl_apv_kind"/>',  width:'12', align:'center'},
						      {key:'Approvdate', label:'<spring:message code="Cache.lbl_apv_approvdate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'15', align:'center'},
						      {key:'RecvDate', label:'<spring:message code="Cache.lbl_apv_RecvDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'15', align:'center'},
						      {key:'EndDate', label:'<spring:message code="Cache.lbl_apv_setschema_scMobile"/>',  width:'15', align:'center'}];
		 }else if(clickedTab == "TCInfo"){
			 var headerData =[
						      {key:'SenderName', label:'<spring:message code="Cache.lbl_approval_circulator"/>', width:'12', align:'center',  //회람지정자
						    	  formatter:function(){
										// 2022-11-11 플라워 네임 적용
										if (typeof (setUserFlowerName) == 'function') {
											return setUserFlowerName(this.item.SenderID, CFN_GetDicInfo(this.item.SenderName), 'AXGrid');
										} else {
											return CFN_GetDicInfo(this.item.SenderName);
										}
					    		  }
						      },
			                  {key:'ReceiptDate', label:'<spring:message code="Cache.lbl_apv_senddate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'12', align:'center',
			                	  formatter:function () {
			                		  if(this.item.ReceiptDate != "" && this.item.ReceiptDate != null && this.item.ReceiptDate != undefined){
		                			  	return CFN_TransLocalTime(this.item.ReceiptDate, "yyyy.MM.dd HH:mm:ss");
			                		  }
		                	  	  }
						      },
						      {key:'UserName', label:'<spring:message code="Cache.lbl_apv_Distributer"/>/<spring:message code="Cache.lbl_apv_DistributeDept"/>',  width:'18', align:'center',  // 회람자/ 회람부서
						    	  formatter:function(){
							    	  if(this.item.DeptName == "") {
							    		// 2022-11-11 플라워 네임 적용
										if (typeof (setUserFlowerName) == 'function' && this.item.ReceiptType == 'P') {
											return setUserFlowerName(this.item.UserCode, CFN_GetDicInfo(this.item.ReceiptName), 'AXGrid');
										} else {
											return CFN_GetDicInfo(this.item.ReceiptName);
										}
							    	  }
							    	  else {
							    		// 2022-11-11 플라워 네임 적용
										if (typeof (setUserFlowerName) == 'function' && this.item.ReceiptType == 'P') {
											return "("+CFN_GetDicInfo(this.item.DeptName)+")"+" "+setUserFlowerName(this.item.UserCode, CFN_GetDicInfo(this.item.UserName), 'AXGrid');
										} else {
											return "("+CFN_GetDicInfo(this.item.DeptName)+")"+" "+CFN_GetDicInfo(this.item.UserName);
										}
							    	  }
							    	} 
						      },
						      {key:'ReadDate', label:'<spring:message code="Cache.lbl_approval_confirmDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'10', align:'center',  //확인일자
			                	  formatter:function () {
			                		  if(this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != undefined){
		                			  	return CFN_TransLocalTime(this.item.ReadDate, "yyyy.MM.dd HH:mm:ss");
			                		  }
		                	  	  }
						      },
						      {key:'Comment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center', sort:false}];
			 
			 notFixedWidth = 2;
		 }else if(clickedTab == "Attach"){
			 var headerData =[
						      {key:'Num', label:'<spring:message code="Cache.lbl_Number"/>', width:'8', align:'center', sort:false,
						    	  formatter:function(){
						    		  return Math.floor(this.item.Num);
						    	  }
						      },
			                  {key:'FileName', label:'<spring:message code="Cache.lbl_apv_FileName"/>',  width:'20', align:'center',
						    	  formatter:function(){
						    		  return "<a onclick='Common.fileDownLoad(\""+this.item.FileID+"\",\""+this.item.FileName+"\",\""+this.item.FileToken+"\"); return false;'>"+this.item.FileName+"</a>";
						    	  }
						      },
						      {key:'UserName', label:'<spring:message code="Cache.lbl_name"/>',  width:'20', align:'center',
						    	  formatter:function(){
						    		// 2022-11-11 플라워 네임 적용
									if (typeof (setUserFlowerName) == 'function') {
										return setUserFlowerName(this.item.UserCode, CFN_GetDicInfo(this.item.UserName), 'AXGrid');
									} else {
										return CFN_GetDicInfo(this.item.UserName);
									}
					    		  }
					      	  }];
		 }else if(clickedTab == "Receipt"){
			 var headerData =[
					      {key:'UserName', label:'<spring:message code="Cache.lbl_apv_RecvDept"/>', width:'12', align:'center',
					    	  formatter:function () {
					    		// 2022-11-11 플라워 네임 적용
								if (typeof (setUserFlowerName) == 'function' && this.item.ActualKind == '0') {
									return setUserFlowerName(this.item.UserCode, CFN_GetDicInfo(this.item.UserName), 'AXGrid');
								} else {
									return CFN_GetDicInfo(this.item.UserName);
								}
					    	  }
					      },
		                  {key:'ChargeName', label:'<spring:message code="Cache.lbl_apv_receiver"/>',  width:'12', align:'center',
					    	  formatter:function(){return CFN_GetDicInfo(this.item.ChargeName);}
					      },
					      {key:'stateName', label:'<spring:message code="Cache.lbl_apv_receiptIs"/>/<spring:message code="Cache.lbl_apv_processState"/>',  width:'18', align:'center'},//접수여부/진행상태: 밑에 State랑 같이 한 행으로 합쳐져야함
					      {key:'BusinessStateName', label:'<spring:message code="Cache.lbl_apv_result"/>',  width:'12', align:'center'},
					      {key:'WorkItemFinished', label:'<spring:message code="Cache.lbl_apv_receipt_time"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'15', align:'center',
		                	  formatter:function () {
		                		  if(this.item.WorkItemFinished != "" && this.item.WorkItemFinished != null && this.item.WorkItemFinished != undefined){
	                			  	return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.WorkItemFinished);
		                		  }
	                	  	  }
					      },
					      {key:'ProcessFinished', label:'<spring:message code="Cache.lbl_apv_complete_time"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'15', align:'center',
		                	  formatter:function () {
		                		  if(this.item.ProcessFinished != "" && this.item.ProcessFinished != null && this.item.ProcessFinished != "undefined"){
	                			  	return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.ProcessFinished);
		                		  }
	                	  	  }
					      }];
			 
			 notFixedWidth = 0;
		 }else if(clickedTab == "ReadCheck"){
			 var headerData =[
						      {key:'UserName', label:'<spring:message code="Cache.lbl_name"/>',  width:'10', align:'center',
							      formatter:function(){
									// 2022-11-11 플라워 네임 적용
									if (typeof (setUserFlowerName) == 'function') {
										return setUserFlowerName(this.item.UserID, CFN_GetDicInfo(this.item.UserName), 'AXGrid') + "(" + CFN_GetDicInfo(this.item.DeptName) + ")";
									} else {
										return CFN_GetDicInfo(this.item.UserName) + "(" + CFN_GetDicInfo(this.item.DeptName) + ")";
									}
			      				}},
						      {key:'ReadDate', label:'<spring:message code="Cache.lbl_apv_ReadCheck"/> ',  width:'15', align:'center',
			                	  formatter:function () {
			                		  if(this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != undefined){
		                			  	return CFN_TransLocalTime(this.item.ReadDate, "yyyy.MM.dd HH:mm:ss");
			                		  }
		                	  	  }
						      }];
			 
			 notFixedWidth = 0;
		 }
		 
		ListGrid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "approvalDetailListGrid",
			height:"auto",
// 			colHead: {
// 				heights: [30],
// 			},
            page: {
            	display: false,
				paging: false
            },
			notFixedWidth : notFixedWidth
		};
		ListGrid.setGridConfig(configObj);
	}

	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		$(".tabDesign .tabOn").attr("class","tab");
		$(pObj).parent().addClass("tabOn");
		clickedTab = $(pObj).attr("value");
		//탭선택에 따른 그리드  변경을 위해 setGrid()호출
		setGrid();
	}

	function setListData(){
		switch (clickedTab){
			case "List" : url=""; selectParams={"ProcessID": <%=ProcessID%>, "FormInstID": <%=FormInstID%>}; break; // 리스트
			case "Graphic" : url=""; selectParams={"ProcessID": <%=ProcessID%>, "FormInstID": <%=FormInstID%>}; break;    // 그래픽
			case "TCInfo" : url="/approval/getCirculationReadListData.do"; selectParams={"FormIstID": <%=FormInstID%>}; break;		// 참조회람
			case "Attach" : url="/approval/getCommFileListData.do"; selectParams={"ProcessID": <%=ProcessID%>, "FormInstID": <%=FormInstID%>}; break;	// 첨부목록
			case "Receipt" : url="/approval/getReceiptReadListData.do"; selectParams={"ProcessID": <%=ProcessID%>, "FormIstID": <%=FormInstID%>}; break;	// 수신현황
			case "ReadCheck" : url="/approval/getDocreadHistoryListData.do"; selectParams={"ProcessID": <%=ProcessID%>, "FormInstID": <%=FormInstID%>}; break;	// 읽음확인
		}
		//
		ListGrid.bindGrid({
			ajaxUrl: url ,
			ajaxPars: selectParams
		});
		//
	}

</script>