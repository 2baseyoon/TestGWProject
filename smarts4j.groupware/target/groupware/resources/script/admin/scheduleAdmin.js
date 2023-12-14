
var scheduleAdmin = {
	// 일정관리 설정 조직도 열기
	openOrgMapPopup : function(aObj){
		var strType = "D9";
		if($(aObj).attr("id") == "aSpecifier"){
			parent._CallBackMethod2 = this.setOrgMapSpecifierData;
			strType = "B1";
		}
		else if($(aObj).attr("id") == "aTarget"){
			parent._CallBackMethod2 = this.setOrgMapTargetData;
			strType = "D1";
		}
		else if($(aObj).attr("id") == "aOwnerCode"){
			parent._CallBackMethod2 = this.setOwnerData;
			strType = "B1";
		}
		else if($(aObj).attr("id") == "aPersonLinkCode"){
			parent._CallBackMethod2 = this.setPersonLinkData;
			strType = "B1";
		}
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type="+strType,"1060px","580px","iframe",true,null,null,true);
	},
	
	// 공유 등록자 데이터 세팅
	setOrgMapSpecifierData : function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = $$(dataObj).find("item").concat().eq(0).attr("DN");
		
		$("#SpecifierCode").val(userCode);
		$("#SpecifierName").val(userName);
		$("#SpecifierDisplayName").val(CFN_GetDicInfo(userName));
		
		shareId = userCode;
		selectShareData();
	},
	
	// 공유 대상자 데이터 세팅
	setOrgMapTargetData : function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = $$(dataObj).find("item").concat().eq(0).attr("DN");
		var userType = $$(dataObj).find("item").concat().eq(0).attr("itemType");
		
		$("#TargetType").val(userType);
		$("#TargetCode").val(userCode);
		$("#TargetName").val(userName);
		$("#TargetDisplayName").val(CFN_GetDicInfo(userName));
	},
	
	// 운영자 데이터 세팅
	setOwnerData : function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = $$(dataObj).find("item").concat().eq(0).attr("DN");
		
		$("#OwnerCode").val(userCode);
		$("#OwnerName").val(userName);
	},
	
	// 내 일정을 연결할 경우 데이터 세팅
	setPersonLinkData : function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = $$(dataObj).find("item").concat().eq(0).attr("DN");
		
		$("#PersonLinkCode").val(userCode);
		$("#PersonLinkName").val(userName);
	},
	
	// 새로고침
	Refresh : function(){
		location.reload();
	}
}