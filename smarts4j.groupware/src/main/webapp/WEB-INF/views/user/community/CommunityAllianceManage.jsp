<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_PartiMgr'/></h2>						
</div>
<div class="mt20 subContBox">
	<select class="selectType02 " id="selectAllianceType">
	</select>				
</div>

<div class="mt20 ">
	<div class="tblList tblCont">
		<div id="gridDiv">
		</div>								
	</div>						
</div>

<script type="text/javascript">
var communityGrid = new coviGrid();
var communityHeaderData = "";

communityGrid.config.fitToWidthRightMargin=0;

$(function(){
	$("#selectAllianceType").coviCtrl("setSelectOption", 
			"/groupware/layout/userCommunity/selectAlianceType.do", 
			{"codeGroup": "CuPartiStatus"},
			"전체",
			""
	);
	
	$("#selectAllianceType").change(function(){
		selectCommunityList();
	});
	
	setCommunityAllianceGrid();
});

function setCommunityAllianceGrid(){
	communityGrid.setGridHeader(communityGridHeader());
	selectCommunityList();		
	
}

function communityGridHeader(){
	var communityGridHeader = [
	      		         	{key:'CU_ID', label:'CU_ID', hideFilter : 'Y',display:false},
	      		         	{key:'PartiID', label:'PartiID', hideFilter : 'Y',display:false},
	      		         	{key:'CommunityName',  label:"<spring:message code='Cache.lbl_communityName'/>", width:'4', align:'center'}, 
	      		         	{key:'DisplayName',  label:"<spring:message code='Cache.lbl_Operator'/>", width:'3', align:'center', formatter: function(){
	      		              	return coviCtrl.formatUserContext("List", this.item.DisplayName, this.item.OperatorCode, this.item.MailAddress);
	      		         	}},    
	      		         	{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Establishment_Day'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'3', align:'center',
	      		         		formatter:function(){
	      		         			return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
	      		         		}
	      		         	},    
	      		         	{key:'MemberCount',  label:"<spring:message code='Cache.lbl_User_Count'/>", width:'3', align:'center'},    
	      		         	{key:'RequesterName',  label:"<spring:message code='Cache.lbl_Requester'/>", width:'3', align:'center', formatter: function(){
	      		         		if(this.item.RequesterID){
		      		         		return coviCtrl.formatUserContext("List", this.item.RequesterName, this.item.RequesterID, this.item.RequesterMailAddress);
	      		         		}else{
	      		         			return "";
	      		         		}
	      		         	}},      
							{key:'RequestDate',  label:"<spring:message code='Cache.lbl_RequestDay'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'3', align:'center',
	      		         		formatter:function(){
	      		         			return CFN_TransLocalTime(this.item.RequestDate,_ServerDateSimpleFormat);
	      		         		}
	      		         	},    
	      		        	{key:'RecipientName',  label:"<spring:message code='Cache.lbl_Processor'/>", width:'3', align:'center', formatter: function(){
	      		        		if(this.item.RecipientID){
	      		        			if(this.item.Status != 'P') {
	      		        				return coviCtrl.formatUserContext("List", this.item.RecipientName, this.item.RecipientID, this.item.RecipientMailAddress);
	      		        			}
	      		        		}else{
	      		        			return "";
	      		        		}
	      		         	}},  
	      		        	{key:'ProcessingDate',  label:"<spring:message code='Cache.lbl_ProcessingDays'/>", width:'3', align:'center', formatter: function () {
	      		        		var ProcessingDate = "";
	      		        		if(this.item.Status != 'P') {
	      		        			ProcessingDate = this.item.ProcessingDate;
      		        			}	      		        		
	      		        		return ProcessingDate;
	      		        	}},
	      		        	{key:'keyNum', label:'keyNum', hideFilter : 'Y',display:false},
	      		        	{key:'statusNm',  label:"<spring:message code='Cache.lbl_CommunityRegStatus'/>", width:'3', align:'center', sort:'desc', formatter: function () {
	      		        		var html = "";
	      		        		
	      		        		if(this.item.statusNm == ''){
	      		        			html = "<spring:message code='Cache.lbl_DoNotRequest'/>";
	      		        		}else{
	      		        			if(this.item.ProcessingMessage != "") {
	      		        				html = "<a href='javascript:void(0);' title='"+this.item.ProcessingMessage+"'>";
	      		        			}
	      		        			
	      		        			if(this.item.Status == 'A'){
	      		        				html += "<spring:message code='Cache.lbl_CurrentAffiliate'/>";
	      		        			}else if(this.item.Status == 'P' && this.item.keyNum == "2"){
	      		        				html += "<spring:message code='Cache.lbl_AffiliateRequest'/>";
	      		        			}else if(this.item.Status == 'P' && this.item.keyNum == "1"){
	      		        				html += String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'A'"+')" class="btnTypeDefault btnBlueBoder">{2}</a></div>',
      		        					        this.item.CU_ID
      		        					      , this.item.PartiID
      		        					      , "<spring:message code='Cache.lbl_AffiliateApproval'/>");
	      		        			}else{
	      		        				html += this.item.statusNm; 
	      		        			}
	      		        			
									if(this.item.ProcessingMessage != "") {
										html += '</a>';
	      		        			}
	      		        		}
	      		        		
	      		        		return html;
							}},
	      		        	{key:'Status',  label:' ', width:'4', align:'center', hideFilter : 'Y', formatter: function () {
	      		        		var html = "";
	      		        		
	      		        		if(this.item.Status == ''){
	      		        			html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'P'"+')" class="btnTypeDefault btnBlueBoder">{2}</a></div>',
  		        					          this.item.CU_ID
  		        					        , this.item.PartiID
  		        					        , "<spring:message code='Cache.lbl_AffiliateRequest'/>");
	      		        		}else if(this.item.Status == 'A'){
	      		        			html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'E'"+')" class="btnTypeDefault">{2}</a></div>',
	      		        					 this.item.CU_ID
	  		        					   , this.item.PartiID
	  		        					   , "<spring:message code='Cache.lbl_PartnershipResults'/>");
	      		        		}else if(this.item.Status == 'C'){
	      		        			html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'P'"+')" class="btnTypeDefault btnBlueBoder">{2}</a></div>',
  		        					        this.item.CU_ID
  		        					      , this.item.PartiID 
  		        					      , "<spring:message code='Cache.lbl_AffiliateRequest'/>");
	      		        		}else if(this.item.Status == 'E'){
	      		        			html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'P'"+')" class="btnTypeDefault btnBlueBoder">{2}</a></div>',
  		        					        this.item.CU_ID
  		        					      , this.item.PartiID 
										  , "<spring:message code='Cache.lbl_AffiliateRequest'/>");
	      		        		}else if(this.item.Status == 'P'){
	      		        			if(this.item.keyNum == "1"){
	      		        				html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'R'"+')" class="btnTypeDefault">{2}</a></div>',
      		        					        this.item.CU_ID
      		        					      , this.item.PartiID
      		        					      , "<spring:message code='Cache.lbl_AffiliateDeclined'/>");
	      		        			}else{
		      		        			html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'C'"+')" class="btnTypeDefault">{2}</a></div>',
	  		        					        this.item.CU_ID
	  		        					      , this.item.PartiID 
	  		        					      , "<spring:message code='Cache.lbl_CancelRequest'/>");
	      		        			}
	      		        		}else{
	      		        			html = String.format('<div class="btnTblBox"><a onclick="goAlliance('+"'{0}'"+","+"'{1}'"+","+"'P'"+')" class="btnTypeDefault btnBlueBoder">{2}</a></div>',
  		        					        this.item.CU_ID
  		        					      , this.item.PartiID 
										  , "<spring:message code='Cache.lbl_AffiliateRequest'/>");
	      		        		}
	      		        		
	      		        		return html;
							 }},
							 {key:'RecipientID',  label:'RecipientID', align:'center' , display:false,hideFilter : 'Y'},
							 {key:'RequesterID',  label:'RequesterID', align:'center' , display:false,hideFilter : 'Y'},
							 {key:'OperatorCode',  label:'OperatorCode', align:'center' , display:false,hideFilter : 'Y'}
	      		        	
	      		        ];
	communityHeaderData = communityGridHeader;
	return communityGridHeader;
}

function selectCommunityList(){
	//폴더 변경시 검색항목 초기화
	setCommunityGridConfig();
	communityGrid.bindGrid({
		ajaxUrl:"/groupware/layout/userCommunity/selectCommunityAllianceGridList.do",
		ajaxPars: {
			CU_ID : cID,
			Status : $("#selectAllianceType").val()
		},
		onLoad : function(){
			$(".btnFlowerName").each(function(idx, item){
				var $bodyTdText = $(item).closest("div.bodyTdText");
				
				if($bodyTdText.find(".fcStyle").text() != "" && !$bodyTdText.hasClass("bodyTdFile")){
					$bodyTdText.addClass("bodyTdFile");
				}
			});
		}
	}); 
}

function setCommunityGridConfig(){
	var configCallObj = {
		targetID : "gridDiv",
		height:"auto",
		overflowCell: [3]
	};
	
	communityGrid.setGridConfig(configCallObj);
}

function goAlliance(RecipientID, PartiID, status){
	Common.open("","alliance","<spring:message code='Cache.lbl_PartiMgr'/>","/groupware/layout/userCommunity/communityAlliancePopup.do?CommunityID="+cID+"&RecipientID="+RecipientID+"&status="+status+"&PartiID="+PartiID,"300px","200px","iframe","false",null,null,true);
}

//Common.open("","detail","<spring:message code='Cache.lbl_AttendanceModify' />","manageDetail.do?id="+index+"&mode=E","600px","330px","iframe","false",null,null,true);
</script>