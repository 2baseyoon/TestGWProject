<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">문서 읽음확인</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>						
			&nbsp;&nbsp;
			<spring:message code="Cache.lbl_apv_readType"/>:
			<select class="AXSelect"  name="sel_State" id="sel_State" >
				<option selected="selected" value=""><spring:message code="Cache.lbl_apv_total"/></option>
				<option value="Y"><spring:message code="Cache.lbl_apv_admin"/></option>
				<option value="N"><spring:message code="Cache.lbl_apv_normal"/></option>
				<option value="A"><spring:message code="Cache.lbl_apv_audit"/></option>				
			</select>			
			<select class="AXSelect" name="sel_Search" id="sel_Search" >
				<option value=""><spring:message code="Cache.lbl_apv_searchcomment"/></option>
				<option value="Subject"><spring:message code="Cache.lbl_apv_subject"/></option>
				<option value="InitiatorName"><spring:message code="Cache.lbl_apv_writer"/></option>					
				<option value="FormName"><spring:message code="Cache.lbl_apv_formname"/></option>	
				<option value="UserName"><spring:message code="Cache.lbl_apv_reader"/></option>			
			</select>	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" disabled="disabled"/>			
			<select name="sel_Date" id="sel_Date" class="AXSelect">
				<option value=""><spring:message code="Cache.lbl_Date_Select"/></option>
				<option value="InitiatedDate"><spring:message code="Cache.lbl_DraftDate"/></option>
				<option value="ReadDate"><spring:message code="Cache.lbl_apv_ReadDate"/></option>				
			</select>				
				<input class="AXInput" id="startdate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" disabled="disabled">
			   	    ~ 				   	   
				<input class="AXInput" id="enddate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" disabled="disabled">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
		</div>	
		<div id="baseconfiggrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">

	var myGrid = new coviGrid();

	initDocReadConfirm();
	
	function initDocReadConfirm(){
		selSelectbind();
		setSelect();
		setGrid();			// 그리드 세팅			
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'100', align:'center'
		                	  , formatter:function(){return CFN_GetDicInfo(this.item.FormName)} },
		                  {key:'Subject',  label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'300', align:'left'},
		                  {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'100', align:'center',
		                	  formatter:function () {
									if (this.item.InitiatorName != undefined) {
										return "<div class=\"tableTxt\"<span>" + CFN_GetDicInfo(this.item.InitiatorName) + "</span></div>";
									}
								}
						  },
		                  {key:'InitiatedDate',  label:'<spring:message code="Cache.lbl_DraftDate"/>', width:'120', align:'center'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InitiatedDate, "yyyy-MM-dd HH:mm:ss")} },
		                  {key:'UserName',  label:'<spring:message code="Cache.lbl_apv_reader"/>', width:'100', align:'center'},
		                  {key:'ReadDate',  label:'<spring:message code="Cache.lbl_apv_ReadDate"/>', width:'120', align:'center' , sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.ReadDate, "yyyy-MM-dd HH:mm:ss")} },
		                  {key:'AdminYN', label:'<spring:message code="Cache.lbl_apv_readType"/>', width:'100', align:'center'
		                	  , formatter:function(){
		                		  var AdminYN;
		                		  if(this.item.AdminYN=='Y'){
		                			  AdminYN='<spring:message code="Cache.lbl_apv_admin"/>(Y)';
		                		  }else if(this.item.AdminYN=='N'){
		                			  AdminYN='<spring:message code="Cache.lbl_apv_normal"/>(N)';
		                		  }else if(this.item.AdminYN=='A'){
		                			  AdminYN='<spring:message code="Cache.lbl_apv_audit"/>(A)';
		                		  }
		                		return AdminYN;
		                	  }
		                  }	                  
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
		if(flag=='1'&& $("#sel_Search").val()==''&& $("#sel_Date").val()==''){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_criteria' />"); //검색 조건 또는 날짜검색 조건을 선택하세요.
			return;			
		}
		var EntCode = $("#selectUseAuthority").val(); 
		var sel_State = $("#sel_State").val();	
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		var sel_Date = $("#sel_Date").val();
		var startdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getDocReadConfirmList.do",
				ajaxPars: {
					"EntCode":EntCode,
					"sel_State":sel_State,
					"sel_Search":sel_Search,
					"search":search,
					"sel_Date":sel_Date,
					"startDate":startdate,
					"endDate":enddate
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
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	// Select box 바인드
	function setSelect(){
		$("#selectUseAuthority").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",			
			ajaxAsync:false,
			onchange: function(){
				searchConfig();
			}
		});
		
	}

	//axisj selectbox변환
	function selSelectbind(){
		//읽기타입selectbind
		$("#sel_State").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		//검색조건selectbind
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		if($("#sel_Search").val() != ''){
					$("#search").attr("disabled",false);
				}else{
					$("#search").attr("disabled",true);
				}
        	}
        });
		//날짜검색selectbind
		$("#sel_Date").bindSelect({
        	onChange: function(){
        		if($("#sel_Date").val() != ''){
					$("#startdate").attr("disabled",false);
					$("#enddate").attr("disabled",false);
				}else{
					$("#startdate").attr("disabled",true);
					$("#enddate").attr("disabled",true);
				}
        	}
        });
		
		
	}
	
</script>