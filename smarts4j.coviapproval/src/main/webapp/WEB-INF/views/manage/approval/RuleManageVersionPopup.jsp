<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.psTaskExam {
	background-image:url('/HtmlSite/smarts4j_n/covicore/resources/images/common/pstask_excelImg.png');
}

</style>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code='Cache.apv_btn_rule'/> <spring:message code='Cache.lbl_versionCont'/></span> <!-- 전결규정 버전관리 --> <!-- font-size: 17px; -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02 active" id="DetailSearch">
		<div style="width:500px;">
			<div class="selectCalView">
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" >
					<option value=""><spring:message code='Cache.lbl_apv_doc_review_all'/></option>  <!-- 전체 -->
					<option value="VerNum"><spring:message code='Cache.ACC_lbl_version'/></option> <!-- 버전 -->
					<option value="InsertDate"><spring:message code='Cache.lbl_apv_formcreate_LCODE15'/></option>	 <!-- 생성날짜 -->			
				</select>
				<input type="hidden" id="serach_vernum" />
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="" style="display:none;"/>	
				<span id="divDate" class="dateSel type02" style="display:none">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" >
					   	<span id="miidledate" >    ~  </span>				   	   
					<input class="adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" >				
			    </span>
			    <a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="bizRuleGrid"></div>
		</div>
	</div>
</div>


<script type="text/javascript">
	var bizRuleGrid = new coviGrid();

	//ready 
	initRulHistoryList();
	
	function initRulHistoryList(){
		setGrid();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	
			             {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'90', align:'center'
			          	   , formatter:function(){
			          		  var IsUse;
			          		  if(this.item.IsUse=='Y'){
			          			  IsUse='<span style="font-weight:bold; color:red;"><spring:message code="Cache.lbl_Use"/></span>';  //사용
			          		  }else if(this.item.IsUse=='N'){
			          			  IsUse='<spring:message code="Cache.lbl_UseN"/>'; //미사용
			          		  }
			          		return IsUse;  
			          	   }
			              },
		                  {key:'VerNum',  label:'<spring:message code="Cache.lbl_apv_Version"/>', width:'50', align:'center',sort:"asc"},	                  
		                  {key:'EntCode',  label:'<spring:message code="Cache.lbl_apv_entcode"/>', width:'100', align:'center'},
		                  {key:'InsertUser',  label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center'},
		                  {key:'InsertDate',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE15"/>', width:'200', align:'center'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InsertDate, "yyyy-MM-dd HH:mm:ss")}},	
		                  {key:'UpdateUser',  label:'<spring:message code="Cache.lbl_apv_modiuser"/>', width:'100', align:'center'},
		                  {key:'Updatedate',  label:'<spring:message code="Cache.lbl_apv_moddate"/>', width:'200', align:'center'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.Updatedate, "yyyy-MM-dd HH:mm:ss")}},			                	  
		                  {key:'Description', label:'<spring:message code="Cache.lbl_apv_desc"/>', width:'200', align:'left'},
		                  {key:'', label:'<spring:message code="Cache.btn_apv_update"/>', width:'100', align:'center', sort: false, 
		                	  formatter:function () {
		                		  //return "<input class='ooBtn' type='button' value='<spring:message code='Cache.btn_apv_update'/>'  onclick='updateConfig( \""+ this.item.VerNum +"\"); return false;'>";
		                		  return "<a href='#' class='btnTypeDefault' onclick='updateConfig( \""+ this.item.VerNum +"\"); return false;'><spring:message code='Cache.btn_apv_update'/></a>"
			      				}}
		                  
			      		];
		
		bizRuleGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();	
		
		$("#sel_Search").change(function(){
			if( $("#sel_Search").val()=="VerNum"){
				$("#divDate").hide();
				$("#search").show();
				$("#serach_vernum").val("VerNum");
				$("#startdate").val("");
				$("#enddate").val("");
			}
			else if( $("#sel_Search").val()=="InsertDate"){
				$("#divDate").show();
				$("#search").hide();	
				$("#serach_vernum").val("");
				coviInput.setDate();
			}
			else{
				$("#divDate").hide();
				$("#search").hide();
				//$("#search").attr('disabled', 'disabled')
				$("#serach_vernum").val("");
				$("#startdate").val("");
				$("#enddate").val("");				
			}
			
			//searchConfig();
	    });	
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "bizRuleGrid",
			height:"auto",
			body:{
				onclick: function(){
				    }				
			}
		};
		bizRuleGrid.setGridConfig(configObj);
	}
	

	
	// 검색
	function searchConfig(){		
		var sel_State = $("#sel_State").val();	
		var serach_vernum = $("#serach_vernum").val();
		var search = $("#search").val();
		var startdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		bizRuleGrid.page.pageNo = 1;
		bizRuleGrid.bindGrid({
				ajaxUrl:"/approval/manage/getRulHisotryList.do",
				ajaxPars: {
					"serach_vernum":serach_vernum,
					"search":search,
					"startdate":startdate,
					"enddate":enddate
				}
		});
	}	

	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(vernum){
		Common.open("","updatebaseconfig","전결규정 버전관리 상세화면","/approval/manage/goRuleHisotrySetPopup.do?mode=modify&key="+vernum,"550px","350px","iframe",true,null,null,true);
	}
	

	// 새로고침
	function Refresh(){
		//CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		window.parent.location.reload();
	}
	
</script>