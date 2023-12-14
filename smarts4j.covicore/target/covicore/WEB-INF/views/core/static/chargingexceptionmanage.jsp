<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script type="text/javascript">

	$(document).ready(function (){
		setGrid();
		setCompany();
		setSelect();
	});
	
	var headerData = [{key:'chk', label:'chk', width:'15', align:'center', formatter:'checkbox'},
	                  {key:'DN_NAME',  label:'<spring:message code="Cache.lbl_company"/>', width:'80', align:'center'},
	                  {key:'NAME',  label:'<spring:message code="Cache.lbl_TargetPerson"/>', width:'50', align:'center'},
	                  {key:'DEPTNAME',  label:'<spring:message code="Cache.lbl_DeptName"/>', width:'50', align:'center'},
	                  {key:'JOBLEVNAME', label:'<spring:message code="Cache.lbl_JobLevel"/>',  width:'50', align:'left'},
	                  {key:'STARTDATE', label:'<spring:message code="Cache.lbl_startdate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 
	                	formatter: function(){
	                		return CFN_TransLocalTime(this.item.RegistDate);
	                  	}
	                  },
	                  {key:'ENDDATE', label:'<spring:message code="Cache.lbl_EndDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'80', align:'center', 
	                	formatter: function(){
		                	return CFN_TransLocalTime(this.item.RegistDate);
		                }
		              },
	                  {key:'REGDATE', label:'<spring:message code="Cache.lbl_RegDate"/>' + Common.getSession("UR_TimeZoneDisplay"),   width:'80', align:'center', sort:'desc', 
	                	formatter: function(){
		                	return CFN_TransLocalTime(this.item.RegistDate);
		                }
					  },
	                  {key:'COMMENT', label:'<spring:message code="Cache.lbl_Reason"/>',  width:'100', align:'center'}]; 
	
	var myGrid = new coviGrid();
	
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "AXGridTarget",
 			//listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
 			height : "auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function addChargingexception(){
		if(document.getElementById("addForm") == undefined){
			$.ajax({
	 			url:"/covicore/statistics/getadddatachargingexception.do",
	 			method:"GET",
	 			data:{
	 				"data":"test"
	 				},
	 			success:function (data) {
	 				$("div [id=addLable]").append(data);
	 			}
	 		});
		}else{
			$("form [id=addForm]").remove();
		}
	}
	
	function deleteChargingexception(){
		var deleteobj = myGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); 
			return;
		}else{
			var deleteSeq = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteSeq = deleteobj[i].CE_ID;
				}else{
					deleteSeq = deleteSeq + "," + deleteobj[i].CE_ID;
				}
			}
			
			$.ajax({
				type:"POST",
				data:{
					"DeleteData" : deleteSeq
				},
				url:"static/deletechargingexception.do",
				success:function (data) {
					if(data.result == "ok") {
						Common.Inform("<spring:message code='Cache.msg_DeleteResult'/>", "Information Dialog", function(result) {
							Refresh();	
						});
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
		}
	}
	
	function setCompany(){
		var company = document.getElementById("select_company").value;
		document.getElementById("hidden_company_val").value = company;
		
		searchStatic();
	}
	
	function setSearchType(){
		var searchtype = document.getElementById("select_searchtype").value;
		document.getElementById("hidden_searchtype_val").value = searchtype;
	}
	
	function searchStatic(){
		var company = document.getElementById("select_company").value;
		var searchtype = document.getElementById("hidden_searchtype_val").value;
		var searchinput = document.getElementById("searchinput").value;
		var startdate = document.getElementById("startdate").value;
		var enddate = document.getElementById("enddate").value;
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"static/getstaticchargingexceptionlist.do",
 			ajaxPars: {
 				"company":company,
 				"searchtype":searchtype,
 				"searchtext":searchinput,
 				"startdate":startdate,
 				"enddate":enddate
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
		});
		
	}
	
	function Refresh(){
		location.reload();
	}
	
	function setSelect(){
		$("#select_searchtype").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options:[{"name":"<spring:message code='Cache.lbl_Select'/>", "value":"null"}, {"name":"<spring:message code='Cache.lbl_TargetPerson'/>", "value":"UR_NAME"}, {"name":"<spring:message code='Cache.lbl_Reason'/>", "value":"COMMENT"}, {"name":"<spring:message code='Cache.lbl_DeptName'/>", "value":"DEPT_NAME"}]
        });
		
		$("#select_company").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "static/getchargingexceptionselectdata.do",
			ajaxPars: {"filter": "selectDomain"},
			ajaxAsync:false,
			onchange: function(){
				setCompany();
			}
		});
	}
	
</script>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.tte_ChargingExceptionManage"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%; min-height: 700px">
		<div id="topitembar_1" class="topbar_grid">
			<label>
				<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
				<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="addChargingexception();"class="AXButton BtnAdd"/>
				<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteChargingexception();"class="AXButton BtnDelete"/>
			</label>
		</div>
		<div id="topitembar_2" class="topbar_grid">
			<label>
				<spring:message code="Cache.lbl_BelongingDNcode"/> &nbsp;
				<select id="select_company" onchange="setCompany();"  class="AXSelect"></select>&nbsp;
				<spring:message code="Cache.lbl_SearchCondition"/>
				<select id="select_searchtype" onchange="setSearchType();"  class="AXSelect"></select>
				<input type="text" id="searchinput"  class="AXInput" />
				<spring:message code="Cache.lblSearchScope"/>&nbsp;<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
				<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchStatic();"class="AXButton"/>
			</label>
		</div>
		<div id="addLable"></div>
		<div>
			<div id="AXGridTarget" style="height: 347px;"></div>
		</div>
	</div>
	<input type="hidden" id="hidden_company_val" />
	<input type="hidden" id="hidden_searchtype_val" />
</form>