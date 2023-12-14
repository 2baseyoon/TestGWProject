<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_115"/></span> <!-- 엔진 오류 로그 -->
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ searchConfig(1); return false;}" > <!-- cmdSearch() -->
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="searchConfig(1);" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
		
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02" id="DetailSearch">
		<div>
			<!-- <spring:message code='Cache.lbl_UseAuthority'/> :&nbsp;				
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select> -->
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_apv_error_date"/></span>
				<div class="dateSel type02">
					<input class="adDate" id="txtSDate" kind="date" type="text" data-axbind="date" />
				</div>
				<span style="margin-left:6px;"><spring:message code="Cache.lbl_apv_error_message"/></span>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" />
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
			<div id="CoviGridView"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hidden_worktype_val" value=""/>
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
		// 상세버튼 열고닫기
		$('.btnDetails').off('click').on('click', function(){
			var mParent = $('#DetailSearch');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			coviInput.setDate();
		});
		
		setGrid();			// 그리드 세팅
		//setSelect();		// Select Box 세팅 (회사)
		//searchConfig();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
                          {key:'Icon', label:' ', width:'30', align:'center', sort:false,
                        	  formatter:function () {
							   		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessInsID+"\", "+"false"+", \"" + "" + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval.gif\" class=\"ico_btn\" /></a>";
							   }},
		                  {key:'ErrorTime', label:'<spring:message code="Cache.lbl_apv_error_time"/>', width:'100', align:'center', sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.ErrorTime, "yyyy-MM-dd HH:mm:ss")} },	                	                  
		                  {key:'ServerIP',  label:'<spring:message code="Cache.lbl_apv_server_id"/>', width:'70', align:'center'},
		                  {key:'ProcessInsID', label:'ProcessID', width:'50', align:'center'},
		                  {key:'ErrorMessage',  label:'<spring:message code="Cache.lbl_apv_error_message"/>', width:'500', align:'center', sort:false,
		                	  formatter:function() {
		                		return '<a style="color:blue;font-weight:bold;" class="txt_underline" title="<spring:message code="Cache.lbl_DetailView"/>" onclick="showErrorDetail(\'' + this.index + '\')">'+ this.item.ErrorMessage +'</a>';  
		                	  }} ,
		                  {key:'Delete',  label:'<spring:message code="Cache.lbl_apv_delete"/>', width:'70', align:'center', sort:false,
                        	  formatter:function () {
							   		return "<input class=\"smButton\" type=\"button\" value=\"<spring:message code='Cache.lbl_apv_delete'/>\" onclick=\"deleteErrorLog(" + this.item.ErrorID + "); return false;\">";
							   }}
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
	}
		
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "CoviGridView",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			body:{
            	onclick:function(){
            		var colIndex = Number(this.c);
            		if(myGrid.config.colGroup[colIndex].key == "Icon"){ // ProcessInsID
            			// 양식 모니터링 툴 띄우기
            			CFN_OpenWindow("/approval/manage/monitoring.do?FormInstID="+this.item.FormInstID+"&ProcessID="+this.item.ProcessInsID, "", 1360, (window.screen.height - 100), "both");
            		}
            	}
            }
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function showErrorDetail(index) {
		var ErrorMessage = myGrid.list[index].ErrorStackTrace;
   		Common.open("","ErrorStackTrace", "ErrorStackTrace", "<textarea style='font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%;padding:20px; text-align:left' readonly>"+ErrorMessage+"</textarea>", "900px","530px","html",true,null,null,true);
	}
	
	// baseconfig 검색
	function searchConfig(flag){		
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		
		var txtSDate = isDetail ? $("#txtSDate").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var icoSearch = $("#searchText").val();
		
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getMonitorErrorLog.do",
				ajaxPars: {
					"txtSDate":txtSDate,
					"search":search,
					"EntCode":$("#hidden_domain_val").val(),
					"icoSearch":icoSearch
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
				}
		});
	}	
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	function deleteErrorLog(errorID) {
		Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
            if (!result) return; // 삭제하시겠습니까??
		
			$.ajax({
				url:"/approval/manage/deleteErrorLog.do",
				type:"post",
				data: {
					"errorID": errorID
				},
				async:false,
				success:function (data) {
					if(data.status == 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
							//location.reload();
							searchConfig();
						});
	    			} else {
	    				Common.Error(data.message);
	    			}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteErrorLog.do", response, status, error);
				}
			});
		});
	}
	
</script>
