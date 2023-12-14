<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_comlegacy_list"/></span> <!-- 개별 연동오류 처리 -->
	</h2>
	<div class="searchBox02">
		<span>
			<input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></button>
		</span>
		<a href="#" class="btnDetails" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa04" id="DetailSearch">
		<div style="width:100%;text-align:center;">
			<div class="selectCalView">
				<select class="selectType02 w120p" name="searchState" id="searchState" onchange="searchConfig()">
					<option value=""><spring:message code="Cache.lbl_Whole"/></option><!-- 전체  -->									  
					<option value="FAIL" selected><spring:message code="Cache.lbl_apv_Fail"/></option> <!-- 실패 -->
					<option value="SUCCESS"><spring:message code="Cache.lbl_apv_Success"/></option> <!-- 성공 -->
				</select>
				<select class="selectType02" id="selectSearchType" onChange="fn_searchType();">
					<option value="" selected><spring:message code="Cache.lbl_apv_searchcomment"/></option> <!-- 검색조건 -->
					<option value="IfType"><spring:message code="Cache.lbl_apv_legacyType"/></option> <!-- 연동타입 -->
					<option value="ProgramName"><spring:message code="Cache.lbl_apv_legacyName"/></option> <!-- 연동명 -->
					<option value="FormName"><spring:message code="Cache.lbl_apv_formname"/></option> <!-- 양식명 -->
					<option value="Subject"><spring:message code="Cache.lbl_apv_subject"/></option> <!-- 제목 -->
					<option value="InitiatorName"><spring:message code="Cache.ApvType_initiator"/></option> <!-- 기안자 -->
					<option value="DocNo"><spring:message code="Cache.lbl_apv_DocNo"/></option> <!-- 문서번호 -->
					<option value="FormInstID">FORM_INST_ID</option>
				</select>
				<input type="text" value="" id="searchInput" onKeyPress="if (event.keyCode == 13) {searchConfig(1);}" disabled="disabled">
			</div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_EventDate"/></span> <!-- 발생시간 -->
				<div class="dateSel type02">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" />
					<span>~</span>
					<input class="adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" />
				</div>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig(1);"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="setGridConfig();searchConfig();">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="divGrid"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
	</div>
</div>

<script type="text/javascript">

	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	setControl();
	
	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
		
		DetailDisplay($(".btnDetails")[0]);
		
		setGrid();			// 그리드 세팅
	}

	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
		coviInput.setDate();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[
						  {key:'LegacyHistoryID', label:'<spring:message code="Cache.lbl_apv_no"/>', width:'80', align:'center', sort:"desc"}, // 순번
						  {key:'Process', label:'<spring:message code="Cache.lbl_process"/>', width:'60', align:'center',  sort: false, // 프로세스 
						   	  formatter:function () {
							   		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessID+"\", "+( (this.item.ProcessState == "528") ? "true" : "false")+", \"" + this.item.DocNo + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval.gif\" class=\"ico_btn\" /></a>";
							   }
			              },
		                  {key:'ApvMode',  label:'<spring:message code="Cache.lbl_apv_comlegacy_apvType"/>', width:'100', align:'center',  // 결재타입
							  formatter : function() {
								  switch(this.item.ApvMode) {
									  case "DRAFT" : return '<spring:message code="Cache.lbl_apv_setschema_94"/>'; // 기안시 연동
									  case "COMPLETE" : return'<spring:message code="Cache.lbl_apv_setschema_95"/>'; // 완료(승인) 후 연동
									  case "OTHERSYSTEM" : return '<spring:message code="Cache.lbl_apv_setschema_121"/>'; // 진행 중 연동
									  case "DISTCOMPLETE" : return '<spring:message code="Cache.lbl_apv_setschema_141"/>'; // 완료(배포처) 후 연동
									  case "CHARGEDEPT" : return '<spring:message code="Cache.lbl_apv_setschema_97"/>'; // 담당부서 처리 전 연동
									  //case "SUBREJECT" : return "부서협조반려";
									  //case "SUBCOMPLETE" : return "부서협조완료";
									  case "WITHDRAW" : return '<spring:message code="Cache.lbl_apv_setschema_121"/>'; // 진행 중 연동
									  case "REJECT" : return '<spring:message code="Cache.lbl_apv_setschema_96"/>'; // 완료(반려) 후 연동
									  default : return this.item.ApvMode;
								  }
						  }},
						  {key:'Seq', label:'<spring:message code="Cache.lbl_apv_legacyNo"/>', width:'60', align:'center'}, // 연동순번
						  {key:'IfType', label:'<spring:message code="Cache.lbl_apv_legacyType"/>', width:'80', align:'center', // 연동타입
								formatter: function () {
									var strIfType = this.item.IfType;
									return "<span title='"+strIfType+"' >" + strIfType + "</span>";
								}
						  }, 
						  {key:'ProgramName', label:'<spring:message code="Cache.lbl_apv_legacyName"/>', width:'100', align:'center', // 연동명
								formatter: function () {
									var strProgramName = this.item.ProgramName;
									return "<span title='"+strProgramName+"' >" + strProgramName + "</span>";
								}
						  }, 
						  {key:'FormInstID', label:'FormInstID', width:'80', align:'center'},
						  //{key:'ProcessID', label:'ProcessID', width:'90', align:'center'},
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'100', align:'center', // 양식명
								formatter: function () {
									var strFormName = CFN_GetDicInfo(this.item.FormName);
									return "<span title='"+strFormName+"' >" + strFormName + "</span>";
								}
						  },
						  {key:'Subject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'200', align:'left', // 제목
							  formatter:function () {
								  var strSubject = this.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
								if (this.item.ProcessID != "" && this.item.ProcessID != undefined){
						   			return "<a class='txt_underline' title='"+strSubject+"' onclick='onClickPopButton(\""+this.item.ProcessID+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); '>"+strSubject+"</a>";
								}else{
									return "<span title='"+strSubject+"' >" + strSubject + "</span>";
								}
							  }
						  },
						  {key:'InitiatorName', label:'<spring:message code="Cache.ApvType_initiator"/>', width:'90', align:'center', // 기안자
							  formatter: function () { return CFN_GetDicInfo(this.item.InitiatorName); }
						  },
		                  {key:'DocNo', label:'<spring:message code="Cache.lbl_apv_DocNo"/>', width:'100', align:'center', // 문서번호
								formatter: function () {
									var strDocNo = this.item.DocNo;
									return "<span title='"+strDocNo+"' >" + strDocNo + "</span>";
								}
		                  }, 
		                  {key:'RegistDate',  label:'<spring:message code="Cache.lbl_EventDate"/>', width:'140', align:'center' // 발생일시
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.RegistDate)}
		                  },
		                  {key:'State',  label:'<spring:message code="Cache.lbl_apv_legacyResult"/>', width:'80', align:'center', // 결과
							  formatter : function() {
								  switch(this.item.State) {
									  case "FAIL" : return '<a style="color:red;font-weight:bold;" class="txt_underline" title="<spring:message code="Cache.lbl_DetailView"/>" onclick="showLogDetail(\'' + this.index + '\')"><spring:message code="Cache.lbl_apv_Fail"/></a>'; // 상세보기 실패
									  case "SUCCESS" : return '<a class="txt_underline" title="<spring:message code="Cache.lbl_DetailView"/>" onclick="showLogDetail(\'' + this.index + '\')"><spring:message code="Cache.lbl_apv_Success"/></a>'; // 상세보기 성공
									  default : return this.item.State;
								  }
						  }},
						  {key:'LastRetryTime',  label:'<spring:message code="Cache.lbl_apv_retryTime"/>', width:'100', align:'center', // 재처리일시
		                	  	formatter:function(){return CFN_TransLocalTime(this.item.LastRetryTime)}
						  },
						  {key:'Detail',  label:'<spring:message code="Cache.btn_apv_process"/>', width:'90', align:'center', sort:false, // 재처리요청
                        	  formatter:function () {
                        		  if(this.item.State != "start"){
							   		  return "<input class=\"smButton\" type=\"button\" value=\"<spring:message code='Cache.lbl_DetailView'/>\" onclick=\"showParamDetail(" + this.index + "); return false;\">"; // 상세보기
                        		  }
						  }},
		                  {key:'Delete',  label:'<spring:message code="Cache.lbl_apv_delete"/>', width:'70', align:'center', sort:false, // 삭제
                        	  formatter:function () {
							   		return "<input class=\"smButton\" type=\"button\" value=\"<spring:message code='Cache.lbl_apv_delete'/>\" onclick=\"deleteLog(" + this.item.LegacyHistoryID + "); return false;\">";
						  }}
		];
		
		myGrid.setGridHeader(headerData);
		//setSelect();
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "divGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			body:{
				 onclick: function(){
				    	//var itemName = myGrid.config.colGroup[this.c].key;
				    	//this.item.LegacyHistoryID
					 }
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// 검색
	function searchConfig(flag){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		myGrid.page.pageNo = 1;
		myGrid.page.pageSize = $("#selectPageSize").val();
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getEachLegacy.do",
				ajaxPars: {
					"searchState":isDetail ? $("#searchState").val() : "",
					"startDate":isDetail ? $("#startdate").val() : "",
					"endDate":isDetail ? $("#enddate").val() : "",
					"EntCode":$("#hidden_domain_val").val(),
					"icoSearch":$("#searchInputSimple").val(),
					"searchType":isDetail ? $("#selectSearchType").val() : "",
					"searchWord":isDetail ? $("#searchInput").val() : ""
				},
				onLoad:function(){
				}
		});
	}	
	
	// 검색조건 text disable
	function fn_searchType(){
		if($("#selectSearchType").val() != ''){
			$("#searchInput").attr("disabled",false);
		}else{
			$("#searchInput").attr("disabled",true);
		}
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 프로세스 팝업
	function ViewProcessListPop(fiid, piid, archived, DocNO){
		CFN_OpenWindow("/approval/manage/monitoring.do?FormInstID=" + fiid+"&ProcessID="+piid+"&archived="+archived+"&DocNO="+encodeURI(DocNO), "", 1360, (window.screen.height - 100), "both");
	}
	
	// 문서오픈
	function onClickPopButton(ProcessID, forminstanceID, BusinessData1, BusinessData2){
		if(BusinessData1 == "ACCOUNT") {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&forminstanceID="+forminstanceID+"&ExpAppID="+BusinessData2, "", 790, (window.screen.height - 100), "resize");
		} else {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
		}
	}
	
	// 결과 상세보기
	function showLogDetail(index) {
		var sID = myGrid.list[index].LegacyHistoryID;
		var sState = myGrid.list[index].State;
		var LayerTitle = '<spring:message code="Cache.lbl_apv_legacyResult"/> / [' + myGrid.list[index].Subject+']'; // 결과
   		Common.open("","LogDetail", LayerTitle, "/approval/manage/OpenLegacyResultPopup.do?ID="+sID+"&State="+sState+"&Index="+index, "1100px","700px","iframe",true,null,null,true);
	}
	
	// 재처리요청 파라미터 상세보기
	function showParamDetail(index) {
		var sID = myGrid.list[index].LegacyHistoryID;
		var sState = myGrid.list[index].State;
		var LayerTitle = '<spring:message code="Cache.lbl_apv_legacyResult"/> / [' + myGrid.list[index].Subject+']'; // 결과
		Common.open("","OpenJsonEditPopup",LayerTitle,"/approval/manage/OpenLegacyParamPopup.do?ID="+sID+"&State="+sState+"&Index="+index, "1024px", "800px", "iframe",true,null,null,true);
	}
	
	// 삭제
	function deleteLog(legacyHistoryID) {
		Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
            if (!result) return; // 삭제하시겠습니까??
		
			$.ajax({
				url:"/approval/manage/deleteEachLegacyErrorLog.do",
				type:"post",
				data: {
					"legacyHistoryID": legacyHistoryID
				},
				async:false,
				success:function (data) {
					if(data.status == 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
							//myGrid.reloadList();
							searchConfig();
						});
	    			} else {
	    				Common.Error(data.message);
	    			}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteEachLegacyErrorLog.do", response, status, error);
				}
			});
		});
	}
	
</script>
