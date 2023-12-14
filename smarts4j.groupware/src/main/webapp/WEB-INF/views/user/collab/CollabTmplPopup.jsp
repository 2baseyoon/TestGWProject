<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.temp_cont{min-width:400px}
#inputBasic_AX_endDate{top:162.073px !important; left:298.594px !important;}
</style>
<div class="mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="temp_cont">
		<div class="main_Titbox main_Titbox02">
			<h2 class="title"><spring:message code='Cache.lbl_mainCategory' /></h2> <!-- 주요카테고리 -->
		</div>
		<div class="temp_cate_list">
			<ul>

			</ul>
		</div>
	
		<div class="main_Titbox">
			<h2 class="title"  id="tmplTitle"><spring:message code='Cache.lbl_Business2' /></h2> <!-- 사업 -->
			<a href="#" class="btnTypeDefault_r middle1 mailico_filter"><spring:message code='Cache.lbl_Filter' /></a> <!-- 필터 -->
		</div>
		<div class="project_manage project_manage_s">
			<ul>
			</ul>
		</div>
		<div class="layer_divpop" style="width:500px; left:170px; top:100px;z-index:104;display:none"  id="divWork">
			<div class="divpop_contents">
				<div class="pop_header"><h4 class="divpop_header"><span class="divpop_header_ico"><spring:message code="Cache.lbl_AddProject"/></span></h4><a onclick='$("#divWork").hide()'  class="divpop_close" style="cursor:pointer;"></a></div>
				<div class="divpop_body" style="overflow:hidden; padding:0;">
					<div class="collabo_popup_wrap">
					
						<div class="collabo_table_wrap mb40">
							<table class="collabo_table" cellpadding="0" cellspacing="0">
								<tbody>
									<tr>
										<th style="width:150px"><spring:message code='Cache.lbl_templateName'/></th>
										<td><span class="w100" id="tmplName"/></td>
									</tr>	
									<tr>
										<th><spring:message code='Cache.ACC_lbl_projectName'/></th>
										<td><input type="text" class="w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" id="prjName" title="<spring:message code='Cache.ACC_lbl_projectName'/>" value=""/></td>
									</tr>	
	 								<tr>
									 	<th><spring:message code='Cache.lbl_Period' /></th>
										<Td>
										    <span class="dateSel type02">
												<input class="adDate" type="text" id="startDate" date_separator="." readonly /> - 
												<input class="adDate" type="text" id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" readonly />
											</span>											
										</Td>
									 </tr>
									<tr>
										<th><spring:message code='Cache.CPMail_Status'/></th>
										<td>
											<div class="chkStyle10">
												<input type="checkbox" class="check_class" id="chk1" value="W">
												<label for="chk1"><span class="s_check"></span><spring:message code='Cache.lbl_Ready' /></label> <!-- 대기 -->
											</div>	
											<div class="chkStyle10">
												<input type="checkbox" class="check_class" id="chk2" value="P" checked>
												<label for="chk2"><span class="s_check"></span><spring:message code='Cache.lbl_Progress' /></label> <!-- 진행 -->
											</div>	
											<div class="chkStyle10">
												<input type="checkbox" class="check_class" id="chk3" value="H">
												<label for="chk3"><span class="s_check"></span><spring:message code='Cache.lbl_Hold' /></label> <!-- 보류 -->
											</div>	
											<div class="chkStyle10">
												<input type="checkbox" class="check_class" id="chk4" value="C" >
												<label for="chk4"><span class="s_check"></span><spring:message code='Cache.lbl_Completed' /></label> <!-- 완료 -->
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_AddProject'/></a>
							<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code="Cache.btn_Close"/></a>
						</div>
					</div>
				</div>	
			</div>
		</div>
	</div>
			<!-- 컨텐츠 끝 -->
</div>
<script>
var collabTmplPopup = {
		objectInit : function(){
			
			$.each(Common.getBaseCode("COLLAB_KIND").CacheData, function(idx, item) {
				$(".temp_cate_list ul")
				.append($("<li>", {"class" : item.Reserved1})
					.append($("<a>", {"href" : "#", "data-kind" : item.Code})
						.append($("<strong>", {"text" : CFN_GetDicInfo(item.MultiCodeName)}))
					)
				);
			});
			
			this.addEvent();
			this.searchData('BUSINESS');
		}	,
		addEvent : function(){
			const slider = $(".temp_cate_list ul");
			  slider.slick({
			    slide: 'li',		//슬라이드 되어야 할 태그 ex) div, li
			    infinite : false, 	//무한 반복 옵션
			    slidesToShow : 7,		 //한 화면에 보여질 컨텐츠 개수
			    slidesToScroll : 1,		//스크롤 한번에 움직일 컨텐츠 개수
			    speed : 500,	  //다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			    arrows : true, 		 //옆으로 이동하는 화살표 표시 여부
			    dots : false, 		 //스크롤바 아래 점으로 페이지네이션 여부
			    autoplay : false,			 //자동 스크롤 사용 여부
			    autoplaySpeed : 3000, 		 //자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			    pauseOnHover : true,		 //슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
			    vertical : false,		 //세로 방향 슬라이드 옵션
			    draggable : false, 	//드래그 가능 여부
			    variableWidth: false,
			    centerMode: false,
			    responsive: [ // 반응형 웹 구현 옵션
						{
							breakpoint: 1600, //화면 사이즈 1600px
							settings: {
								//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
								slidesToShow:6
							}
						},
						{
							breakpoint: 1400, //화면 사이즈 1400px
							settings: {
								//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
								slidesToShow:5
							}
						}
					]
			  });
			  
			$(document).on('click','.pr_like',function(e){
				e.stopPropagation();
				coviComment.addLikeCount(this, 'CollabTmpl', $(this).data("tmplSeq"));
				$(this).toggleClass("active");
				
				if(parent) {
					window.parent.postMessage(
					    { functionName : "changeTemplateStatus", // 팝업으로 열린 경우 좋아요를 반영하기 위한 postMessage
					      params : {"tmplSeq" : $(this).data("tmplSeq"), "isActive" : $(this).hasClass("active"),
					    	  "count" : $(this).children("span").text()}
					    }, '*' 
					);
				}
		    });
			$(document).on('click','.temp_cate_list a',function(){
				$("#tmplTitle").text($(this).find("strong").text());
				collabTmplPopup.searchData( $(this).data("kind"));
		    });
			//템플릿 선택
			$(document).on('click','.tmpl_icon',function(){
				$('html').scrollTop(0);
				$("#divWork").css("top","100px").css("left", "170px");
				$("#divWork").show();
				$("#tmplName").text($(this).find("strong").text());
				$("#tmplName").data("tmplSeq", $(this).data("tmplSeq") );
		    });

			$(".check_class").click(function() {
				 $('.check_class').not(this).prop("checked", false);
			});
			
			//프로젝트 추가
			$(document).on('click','#btnAdd',function(){
				$("#divWork").css("top","100px").css("left", "170px");
				if(!collabTmplPopup.validationChk())     	return ;
				Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var prjData = collabTmplPopup.getProjectData();
						$.ajax({
							type:"POST",
							contentType:'application/json; charset=utf-8',
							dataType   : 'json',
							data:JSON.stringify(prjData),
							url:"/groupware/collabProject/addProjectByTmpl.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
										parent.collabMenu.getUserMenu();
										Common.Close();
									});	
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}
				});	
		    });
		},
		searchData:function(tmplKind){
			var params = {"tmplKind" : tmplKind	};
			$.ajax({
	    		type:"POST",
	    		data:params,
	    		url:"/groupware/collabTmpl/getTmplList.do",
	    		success:function (data) {
	    			  $(".project_manage ul").empty();
	    			  data.list.map( function( item,idx ){
	    				  $(".project_manage  ul").append( $("<li>",{"class":"icon03 tmpl_icon"}).data({"tmplSeq":item.TmplSeq})
	    						  .append($("<strong>",{"class":"pr_tit"}).text(item.TmplName)).data({"tmplSeq":item.TmplSeq})
	    						  .append($("<span>",{"class":"pr_txt"}).text(item.Remark))
	    						  .append($("<div>",{"class":"pr_info02"})
	    								  .append($("<span>",{"class":"pr_manage"}).text(item.TmplKindName))
	    								  .append($("<a>",{"class":"pr_like" + (item.MyLikeCnt>0?" active":"")}).data({"tmplSeq":item.TmplSeq}).append($("<span>",{"name":"likeCnt"}).text(item.LikeCnt)))
	    							)) ;
	    			});
	    		},
	    		error:function (request,status,error){
	    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	    		}
	    	});
		},
		getProjectData:function(){
			var prjData = {
					"prjName":  $("#prjName").val().replace(/\'/gi, "′").replace(/\"/gi, "″")
					,"tmplSeq":  $("#tmplName").data("tmplSeq")
					,"startDate": $("#startDate").val()
					,"endDate": $("#endDate").val()
					,"prjStatus": $('.check_class:checked').val()
				};
			return prjData;
		},
		validationChk:function(){
			var returnVal= true;
			if ($('.check_class:checked').length == 0){
				Common.Warning("<spring:message code='Cache.msg_task_selectState'/>");
			    return false;
			}
		
			if ($('#startDate').val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_startdate' />"));
				return false;
			}
		
			if ($('#endDate').val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_EndDate' />"));
			    return false;
			}
			return returnVal;
	 }	
}
$(function() {
	$("#divWork").draggable({
		scroll : false,
		containment : 'parent'
	});
});
$(document).ready(function(){
	collabTmplPopup.objectInit();
});

</script>					