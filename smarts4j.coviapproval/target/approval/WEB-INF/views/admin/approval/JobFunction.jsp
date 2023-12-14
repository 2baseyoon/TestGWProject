<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">담당업무함 관리</span>	
</h3>
<form id="form1">
	<div id="jobFunctionContainer" style="width:100%;min-height: 800px">
		<div id="topitembar01" class="topbar_grid">			
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(true);"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<label for="selectUseAuthority"><spring:message code="Cache.lbl_Domain"/> : </label>
			<select id="selectUseAuthority" name="selectUseAuthority" class="AXSelect">
			</select>
			&nbsp;
			<label for="JobFunctionType"><spring:message code="Cache.lbl_BizSection" /> : </label>
			<select id="JobFunctionType" name="JobFunctionType" class="AXSelect">
			</select>
			&nbsp;
			<select id="JobFunctionSearchType" name="JobFunctionSearchType" class="AXSelect">
				<option value="JobFunctionName"><spring:message code="Cache.lbl_apv_BizDocName" /></option><!-- 업무함 명칭 -->
				<option value="JobFunctionCode"><spring:message code="Cache.lbl_apv_BizDocCode" /></option><!-- 업무함 코드 -->
				<option value="ChargerName"><spring:message code="Cache.lbl_apv_AdminName" /></option>
				<option value="ChargerCode"><spring:message code="Cache.lbl_apv_AdminID" /></option>				
			</select>
			<input type="text" id="JobFunctionSearch" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick='cmdSearchforJob();' class="AXButton">
		</div>
		<div id="GridView1" class="ztable_list" style="min-height: 300px; padding-top: 1px; overflow-x: hidden;">
		</div>
		<!-- 담당자 추가 시작-->
		<div id="divMember">
			<div>
				<span id="MemberName" style="font-size: 20px; font-weight: bold; display: block; padding-top: 20px; padding-bottom: 5px;"></span>
			</div>
			<div id="topitembar01" class="topbar_grid">			
				<label>
					<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh2();"/>
					<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addMember(true);"/>				
				</label>
			</div>
			<div id="topitembar02" class="topbar_grid" >			
				<label>
					<select class="AXSelect" name="sel_Search" id="sel_Search" >
						<option value="DEPT_NAME"><spring:message code="Cache.lbl_apv_AdminDept"/></option>
						<option value="UR_Name"><spring:message code="Cache.lbl_apv_AdminName"/></option>
						<option value="UserCode"><spring:message code="Cache.lbl_apv_AdminID"/></option>								
					</select>	
					<input name="search" type="text" id="search" class="AXInput" />
					<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="cmdSearchforMember();" class="AXButton"/>							
				</label>
			</div>
			<div id="GridViewMemberList" class="ztable_list" style="min-height: 300px; padding-top: 1px; overflow-x: hidden;">
			</div>
		</div>
	</div>
	<input type="hidden" id="hidden_JobFunctionID" value=""/>
	<input type="hidden" id="hidden_JobFunctionName" value=""/>
</form>

<script type="text/javascript">
	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();

	var objPopup;

	initJobFunction();
	
	function initJobFunction(){	
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do", {"type" : "ID"});
		coviCtrl.renderAXSelect('JobFunctionType', 'JobFunctionType', 'ko', '', '', 'ORGROOT');
		$("#selectUseAuthority,#JobFunctionType").bindSelect({
			onchange: function(){
				$("#divMember").hide();
				setUseAuthority();
			}
		});
		$("#JobFunctionSearchType").bindSelect();
		setGrid();					// 그리드 세팅
		$("#divMember").hide();
		setUseAuthority();		// 사용권한 히든 값 세팅
		
		$("#search,#JobFunctionSearch").keypress(function(e){
			if (e.keyCode==13){
				e.target.id === "JobFunctionSearch" && (cmdSearchforJob());
				e.target.id === "search" && (cmdSearchforMember());
			} 
		});
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정1
		var headerData1 =[					
						  {key:'EntName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'100', align:'center'},
		                  {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'60', align:'center'
		                	  , formatter:function(){
		                		  var IsUse;
		                		  if(this.item.IsUse=='Y'){
		                			  IsUse='<spring:message code="Cache.lbl_apv_formcreate_LCODE13"/>';
		                		  }else if(this.item.IsUse=='N'){
		                			  IsUse='<spring:message code="Cache.lbl_apv_formcreate_LCODE14"/>';
		                		  }
		                		return IsUse;  
		                	  }
		                  },	                 
		                  {key:'JobFunctionName', label:'<spring:message code="Cache.lbl_apv_BizDocName"/>', width:'150', align:'center'
		                	  , formatter:function(){
				                  return CFN_GetDicInfo(this.item.JobFunctionName);
				              }
			              },
		                  {key:'JobFunctionCode',  label:'<spring:message code="Cache.lbl_apv_BizDocCode"/>', width:'150', align:'center'},
		                  {key:'JobFunctionTypeName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'100', align:'center'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_apv_desc"/>', width:'250', align:'left'},
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center'  ,sort:"asc"},
		                  {key:'InsertDate', label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE15"/>', width:'100', align:'left'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InsertDate, "yyyy-MM-dd HH:mm:ss")}},
		                  {key:'', label:'<spring:message code="Cache.btn_apv_update"/>', width:'100', align:'center', sort:false , 
		                	  formatter:function () {
		                		  return "<input class='smButton' type='button' value='<spring:message code='Cache.btn_apv_update'/>'  onclick='updateConfig(true, \""+ this.item.JobFunctionID +"\"); return false;'>";
			      				}}
			      		];
		
		// 헤더 설정2
		var headerData2 =[					
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_AdminName"/>', width:'200', align:'center'},	                 
		                  {key:'UserCode', label:'<spring:message code="Cache.lbl_apv_AdminID"/>', width:'200', align:'center'},
		                  {key:'DEPT_NAME',  label:'<spring:message code="Cache.lbl_apv_AdminDept"/>', width:'500', align:'center'},	                  
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_SortKey"/>',  width:'100', align:'center',sort:"asc"}	                               
			      		];
		
		myGrid1.setGridHeader(headerData1);
		myGrid2.setGridHeader(headerData2);
		setGridConfig1();	
		setGridConfig2();
	}
	// 그리드 Config 설정
	function setGridConfig1(){
		var configObj1 = {
			targetID : "GridView1",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"",			
			page : {
				pageNo: 1,
				pageSize: 10
			},	
			paging : true,
			colHead:{},
			body:{
				 onclick: function(){				    
					    if(!(Object.toJSON(this.c).replaceAll("\"", "")=='6')){
					    	$("#hidden_JobFunctionID").val(Object.toJSON(this.item.JobFunctionID).replaceAll("\"", ""));
					    	$("#hidden_JobFunctionName").val(Object.toJSON(this.item.JobFunctionName).replaceAll("\"", ""));
					    	$("#divMember").show();
					    	searchConfig2();
					    	selSelectbind();//axisj selectbox변환
					    }
					 }			
			}
		};
		
		myGrid1.setGridConfig(configObj1);
	}
	
	// 그리드 Config 설정
	function setGridConfig2(data){
		var configObj2 = {
			targetID : "GridViewMemberList",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{
				onclick: function(){					
					memberDetailPopup(true,Object.toJSON(this.item.JobFunctionMemberID));
				}
			}
		};
		
		myGrid2.setGridConfig(configObj2);		
	}
	
	// 사용권한 히든 값 세팅
	function setUseAuthority(){		
		searchConfig1();
		//searchConfig2();
	}
	
	// baseconfig 검색
	function searchConfig1(){
		myGrid1.bindGrid({
 			ajaxUrl:"/approval/admin/getJobFunctionList.do",
 			ajaxPars: {
 				"EntCode":$("#selectUseAuthority").val(),
 				"JobFunctionType":$("#JobFunctionType").val(),
 				"SearchType":$("#JobFunctionSearchType").val(),
 				"SearchText":$("#JobFunctionSearch").val()
 			},
 			onLoad:function(){
 			}
		});
	}
	
	// baseconfig 검색
	function searchConfig2(){
		var JobFunctionID = $("#hidden_JobFunctionID").val();		
		$("#MemberName").text(CFN_GetDicInfo($("#hidden_JobFunctionName").val()));		
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		
		myGrid2.bindGrid({
 			ajaxUrl:"/approval/admin/getJobFunctionMemberList.do",
 			ajaxPars: {
 				"sel_Search":sel_Search,
				"search":search,
 				"JobFunctionID": JobFunctionID
 			},
 			onLoad:function(){
 			}
		});		
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){			
		objPopup = parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_jfform_title_instruction'/>","/approval/admin/goJobFunctionSetPopup.do?mode=modify&configkey="+configkey,"550px","390px","iframe",pModal,null,null,true);
		//objPopup.close(); 
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){		 
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_jfform_title_instruction'/>","/approval/admin/goJobFunctionSetPopup.do?mode=add","550px","390px","iframe",pModal,null,null,true);
		//objPopup.close(); 
	}
	
	
	// 담당자추가 버튼에 대한 레이어 팝업
	function addMember(pModal){			
		//objPopup.close();
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
	}
	
	//조직도선택후처리관련
	parent._CallBackMethod2 = setJobMemberList;
	function setJobMemberList(peopleValue){
		var JobFunctionID = $("#hidden_JobFunctionID").val();		
		
		var gridMemberData = {};
		
	    $.ajax({
	        url:"/approval/admin/getJobFunctionMemberAllList.do"
	        , method : 'POST'
	        , async:false
	        , data: {"JobFunctionID": JobFunctionID}
	        , success :function(data){
	        	var AllMember = data.list;
	        	gridMemberData = {"members" : AllMember };
	        }
	    });
	    
		var duplicationChk = false;
		var dataObj = JSON.parse(peopleValue);	
		var UR_Data;
		
		var jobFunctionMemberArray = new Array();		
		jQuery.ajaxSettings.traditional = true;
		
		$(dataObj.item).each(function(i){
			duplicationChk = false;
			
			if($$(gridMemberData).find("members[UserCode="+dataObj.item[i].AN+"]").length > 0){
				duplicationChk = true;
			}
			
			if(!duplicationChk){
				if(dataObj.item[i].AN != undefined){
					var jobFunctionMemberObj = new Object();
					jobFunctionMemberObj.JobFunctionID = $("#hidden_JobFunctionID").val();
					jobFunctionMemberObj.Weight = i;
					jobFunctionMemberObj.UserCode = dataObj.item[i].AN;
					jobFunctionMemberObj.SortKey = i;
					jobFunctionMemberArray.push(jobFunctionMemberObj);
				}
			}
		});
		
		//jsavaScript 객체를 JSON 객체로 변환
		jobFunctionMemberArray = JSON.stringify(jobFunctionMemberArray);		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"jobFunctionMember" : jobFunctionMemberArray
			},
			url:"/approval/admin/insertJobFunctionMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_apv_137' />");
				parent.searchConfig2();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/insertJobFunctionMember.do", response, status, error);
			}
		});
	}
	
	// 담당자 수정 레이어 팝업
	function memberDetailPopup(pModal,param){
		var JobFunctionMemberID = param.replaceAll("\"", "");
		objPopup = parent.Common.open("","updatebaseconfig","담당자 관리","/approval/admin/goJobFunctionMemberDetailPopup.do?mode=modify&param="+JobFunctionMemberID,"500","200","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 새로고침 담당자
	function Refresh2(){
		$("#search").val('');
		searchConfig2();
	}
		
	function setFirstPageURL(){
		SaveFirstPageURL("/covicore/systemadmin_dictionarymanage.do");
	}
	
	//검색 - 업무함 검색
	function cmdSearchforJob(){
		$("#divMember").hide();
		searchConfig1();
	}
	
	//검색 - 담당자 검색
	function cmdSearchforMember(){
		searchConfig2();
	}
	
	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
	}
</script>