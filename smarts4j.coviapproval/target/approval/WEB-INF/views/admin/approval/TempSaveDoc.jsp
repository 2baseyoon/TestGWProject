<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">임시저장문서보기</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>											
			<select name="" class="AXSelect" id="selectEntinfoListData"></select>
			&nbsp;&nbsp;
			<select class="AXSelect"  name="sel_State" id="sel_State" >
				<option selected="selected" value=""><spring:message code="Cache.lbl_apv_state"/></option>
				<option value="W"><spring:message code="Cache.btn_apv_Withdraw"/></option>
				<option value="T"><spring:message code="Cache.lbl_apv_Temporary"/></option>				
			</select>		
			<select class="AXSelect" name="sel_Search" id="sel_Search" >
				<option value=""><spring:message code="Cache.lbl_apv_searchcomment"/></option>
				<option value="Subject"><spring:message code="Cache.lbl_apv_subject"/></option>
				<option value="DEPT_Name"><spring:message code="Cache.lbl_apv_writedept"/></option>
				<option value="UR_Name"><spring:message code="Cache.lbl_apv_writer"/></option>
				<option value="FormName"><spring:message code="Cache.lbl_apv_formname"/></option>				
			</select>	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />			
			<select name="sel_Date" id="sel_Date" class="AXSelect">
				<option value=""><spring:message code="Cache.lbl_Date_Select"/></option>
				<option value="CREATED"><spring:message code="Cache.lbl_DraftDate"/></option>				
			</select>				
				<input class="AXInput" id="startdate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate">
			   	    ~ 				   	   
				<input class="AXInput" id="enddate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
		</div>	
		<div id="baseconfiggrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">
	var myGrid = new coviGrid();

	initTempSaveDoc();

	function initTempSaveDoc(){
		selSelectbind();
		setGrid();			// 그리드 세팅			
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'100', align:'center',
		                	  formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },
		                  {key:'Subject',  label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'300', align:'left',
		                	  formatter:function () {
		                		  return "<a onclick='onClickPopButton(\""+this.item.FormID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormTempInstBoxID+"\",\""+this.item.FormInstTableName+"\"); return false;'>"+this.item.Subject+"</a>";
			      		  }},	                  
		                  {key:'DEPT_Name',  label:'<spring:message code="Cache.lbl_apv_writedept"/>', width:'100', align:'center',
							formatter:function () {
								if (this.item.DEPT_Name != undefined) {
									return "<div class=\"tableTxt\"<span>" + CFN_GetDicInfo(this.item.DEPT_Name) + "</span></div>";
								}
							}
		                  },
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'100', align:'center',
								formatter:function () {
									if (this.item.UR_Name != undefined) {
										return "<div class=\"tableTxt\"<span>" + CFN_GetDicInfo(this.item.UR_Name) + "</span></div>";
									}
								}
		                  },
		                  {key:'WORKDT',  label:'<spring:message code="Cache.lbl_DraftDate"/>', width:'100', align:'center', sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.WORKDT, "yyyy-MM-dd HH:mm:ss")} },
		                  {key:'Kind', label:'<spring:message code="Cache.lbl_apv_state"/>', width:'100', align:'center'}	                  
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
		$("#sel_State").change(function(){
			searchConfig();
	    });		
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "baseconfiggrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	

	
	// baseconfig 검색
	function searchConfig(flag){		
		/*if(flag=='1'&& $("#sel_Search").val()==''&& $("#sel_Date").val()==''){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_criteria' />");	//검색 조건 또는 날짜검색 조건을 선택하세요.
			return;			
		}*/		
		
		var sel_State = $("#sel_State").val();	
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		var sel_Date = $("#sel_Date").val();
		var startdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getTempSaveDocList.do",
				ajaxPars: {
					"sel_State":sel_State,
					"sel_Search":sel_Search,
					"search":search,
					"sel_Date":sel_Date,
					"startDate":startdate,
					"endDate":enddate,
					"selectEntinfoListData":$("#selectEntinfoListData").val()
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

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
	
	

	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		$("#sel_State").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		 
		//검색조건selectbind
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
		//날짜검색selectbind
		$("#sel_Date").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
		$("#selectEntinfoListData").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",
			ajaxAsync:false,
			setValue : Common.getSession("DN_Code"),
		});
	}
	
	function onClickPopButton(FormID,FormInstID,FormTempInstBoxID,FormInstTableName){		
		CFN_OpenWindow("/approval/approval_Form.do?mode=TEMPSAVE"+"&processID=&workitemID&performerID=&processdescriptionID=&userCode=&gloct=TEMPSAVE&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=ADMIN&archived=false&usisdocmanager=true&subkind=", "", 790, (window.screen.height - 100), "resize");

	}
	
</script>