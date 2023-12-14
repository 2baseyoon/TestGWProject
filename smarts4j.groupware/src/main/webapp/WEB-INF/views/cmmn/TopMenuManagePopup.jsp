<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable commonLayerPop" id="testpopup_p" style="width:100%; height:100%; overflow:hidden;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
<!-- 			<div class="pop_header" id="testpopup_ph"> -->
<!-- 				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">메인메뉴 설정</span></h4><a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a> -->
<!-- 			</div> -->
		<div class="popContent">
			<div class="mainMenuLayerPopContent">
				<div class="top" style="position:relative;"><ul id="topMenuSorting"></ul>
<!-- 					<div class="chkStyle04 chkType01"> -->
<!-- 						<input type="checkbox" id="mmm01" name="allSV"><label for="mmm01"><span></span>메일</label> -->
<!-- 					</div> -->
				</div>								
				<div class="bottom mt20">
					<a id="btnMenuSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_save'/></a>
					<a id="btnMenuReset" class="btnTypeDefault" ><spring:message code='Cache.btn_init'/></a>
					<a class="btnTypeDefault" onclick="javascript:Common.Close();"><spring:message code='Cache.btn_Close'/></a>
				</div>
			</div>
		</div>
	</div>	
</div>

<script type="text/javascript">
var headerData = ${topMenuData};
var currentMenuConf = Common.getSession("TopMenuConf");

var topMenuCount = 10;//Common.getBaseConfig("TopMenuCount");

$(document).ready(function (){
	
		if(currentMenuConf != '') {
			var myTopMenuList = currentMenuConf.split("@@"+Common.getSession("DN_ID")+"@@")[1];
			myTopMenuList = myTopMenuList.replace("@@"+Common.getSession("DN_ID")+"@@", "").split(";");
			
			headerData.sort((x, y) => {
				var a = myTopMenuList.indexOf(x.MenuID);
				var b = myTopMenuList.indexOf(y.MenuID);
				
				if(a == -1) return 0;
				
				if(b == -1) return -1;
				else if(b > a) return -1;
			});
		 }
		
		$(headerData).each(function(){
			if(this.IsUse!="N"){//사용하기 유무 Y일때만
				var divWrap = $('<li class="chkStyle04 chkType01"/>');
				var checkboxMenu = $('<input type="checkbox"/>').attr({'id':"menu_" +this.MenuID, 'name': "menu_" + this.MenuID});
				divWrap.append(checkboxMenu, $('<label for= "menu_'+ this.MenuID +'"/>').append($('<span/>'), this.DisplayName));
				$('#topMenuSorting').append(divWrap);
			}
		});
	
	//현재 설정된 사용자별 메뉴 정보
	if(currentMenuConf !== undefined && currentMenuConf != ''){
		//도메인별 분리작업 확인
		if(currentMenuConf.indexOf("@@")>-1){
			var arrTopMenu = currentMenuConf.split("@@");
			var ptopMenuConf = "";
			for(var i=0;i<arrTopMenu.length;i++){
				if(arrTopMenu[i] == Common.getSession("DN_ID")){//해당 domain
					ptopMenuConf = arrTopMenu[i+1];
					break;
				}
			}
			currentMenuConf = ptopMenuConf;
		}		
		var menuList = currentMenuConf.split(";");
		$.each(menuList, function(i, item){
			if(item == "")
				return true;
			$("#menu_"+item).prop("checked", true);
		});
	}else{
		$('input:checkbox:lt('+topMenuCount+')').prop('checked', true);
	}
	
	$('#btnMenuSave').on('click', function(){
		if ($('input:checked').length < 1){
			Common.Warning(Common.getDic("msg_apv_003")); //"메뉴를 선택해주세요."
			return;
		}

		var topMenuConf = '';
		$('input:checked').each(function(i, item){
			topMenuConf += $(item).attr('id').split("_")[1]+";";
		});

		//기존사항 고려,도메인별 topmenue등록처리
		var asisTopMenu = Common.getSession("TopMenuConf");
		if(asisTopMenu.indexOf("@@")>-1){
			var arrTopMenu = asisTopMenu.split("@@");
			var ptopMenuConf = "";
			for(var i=0;i<arrTopMenu.length;i++){
				if(arrTopMenu[i] == Common.getSession("DN_ID")){//해당 domain
					ptopMenuConf += "@@"+Common.getSession("DN_ID")+"@@" + topMenuConf;					
				}else if(arrTopMenu[i].indexOf(";")>-1 && i > 0 && arrTopMenu[i-1] != Common.getSession("DN_ID") ){ //메뉴임
					ptopMenuConf += "@@"+arrTopMenu[i-1]+"@@" + arrTopMenu[i];					
				}
			}
			if(ptopMenuConf.indexOf("@@"+Common.getSession("DN_ID")+"@@") ==-1) ptopMenuConf += "@@"+Common.getSession("DN_ID")+"@@" + topMenuConf;	
			topMenuConf = ptopMenuConf;
		} else {
			topMenuConf = "@@"+Common.getSession("DN_ID")+"@@" + topMenuConf;	
		}

		$.ajax({
			url:"/groupware/privacy/updateTopMenuManage.do",
			type:"POST",
			data:{
				"topMenuConf": topMenuConf
			},
			async:false,
			success:function (data) {
				Common.Inform(Common.getDic("msg_ProcessOk"), "", function(){
					localCache.remove('SESSION_TopMenuConf');
					parent.location.reload();
					Common.Close(); 
				});
				
			},
		});
		
	});

	$('#btnMenuReset').on('click', function(){
		//sortkey기준으로 화면에 표시되므로 상위 topMenuCount 개 선택	
		$('input:checkbox').prop('checked', false);
		$('input:checkbox:lt('+topMenuCount+')').prop('checked', true);
	});
	
	$("#topMenuSorting").sortable();
});
</script>