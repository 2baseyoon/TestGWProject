<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<style>
.pr_chk{width:70%}
</style>
<div class="cRContBottom cRContCollabo_main mScrollVH">
<!-- 협업스페이스 포탈일 경우에만 collaboMain 클래스 추가 -->
			<!-- 컨텐츠 시작 -->
			<section>
				<article>
					<div class="main_Titbox1">
						<h2 class="title">My Work</h2>
					</div>
					<div class="Twork_area">
						<div class="Twork_box Twork_box01">
							<div class="Twork_tit"><strong>Today's Work</strong></div>
							<div class="Twork_cont">
								<ul class="Twork_today">
									<li><a href="#" data-tag="ProcTask"><span class="T_num"></span><span class="T_text"><spring:message code='Cache.lbl_Progressing' /> <spring:message code='Cache.lbl_task_task' /></span></a></li> <!-- 진행중 업무 -->
									<li><a href="#" data-tag="TodayCTask"><span class="T_num"></span><span class="T_text"><spring:message code='Cache.lbl_ClosingToday' /></span></a></li> <!-- 오늘마감 -->
									<li><a href="#" data-tag="DelayTask"><span class="T_num"></span><span class="T_text"><spring:message code='Cache.lbl_delaywork' /></span></a></li> <!-- 지연업무 -->
									<li><a href="#" data-tag="EmgTask"><span class="T_num"></span><span class="T_text"><spring:message code='Cache.lbl_EmergencyWork' /></span></a></li> <!-- 긴급업무 -->
								</ul>
							</div>
						</div>
						<div class="Twork_box Twork_box02">
							<div class="Twork_tit"><strong>To do List</strong> <a href="#" class="btn_add" id="btnGoTodo"></a></div>
							<div class="Twork_cont">
								<ul class="Twork_todo">
								</ul>
							</div>
						</div>
						<div class="Twork_box Twork_box03">
							<div class="Twork_tit"><strong>My BookMark</strong></div>
							<div class="Twork_cont">
								<ul class="Twork_bookmark">
								</ul>
							</div>
						</div>
				  </div>
				</article>
				<article>
					<div class="main_Titbox">
						<h2 class="title">Team / Project</h2>
					</div>
					<div class="Pwork_list" style="display: none;">
            
				 </div>
				</article>
				<article>
					<div class="main_Titbox">
						<h2 class="title">Template</h2>
						<a href="#" class="btn_more" id="btnGoTmpl">more</a>
					</div>
					<div class="Template_area">
						<ul>
						</ul>
					</div>
				</article>
			</section>
			<!-- 컨텐츠 끝 -->
		</div>	

<!-- 업무보기 상세팝업 시작 -->
<div id="rightmenu" class="popCont popTask popTask_slide" style="min-width:660px;z-index : 200;"></div>

<script type="text/javascript">
	var collabPortal = {
		slider : $(".Pwork_list"),
		colorList: Common.getBaseCode("ScheduleColor").CacheData,
    	objectInit : function (){
			this.getPortalMain();
	   		this.addEvent();
        },
        addEvent:function(){
		    //완료 처리
	      	$(document).on('change','.Twork_cont input[type=checkbox]',function(e){
		      	e.stopPropagation();
		      	var	data={"taskSeq":  $(this).data("taskSeq"), "taskStatus":  $(this).is(':checked')};
		      	collabUtil.saveTaskComplete(data, function (res) {
	      			//collabTodo.myTaskList.init();
		      	});
		    });
		      
		    //업무 상세
	      	$(document).on('click','.Twork_cont li .link, .Twork_bookmark li',function(e){
	      		collabUtil.openTaskPopup("CollabTaskPopup", "home",  $(this).data("taskSeq"), $(this).data("taskSeq"))
	      	});	
		    
		    //프로젝트 이동
		    $(document).on('click','.prj_link',function(e){
				var objId = "list_"+$(this).data("prjType")+"_"+$(this).data("prjSeq");
				$("#"+objId).trigger("click");
		    });
		    
		    //템플릿 좋아요 체크
			$(document).on('click','.pr_like',function(){
				coviComment.addLikeCount(this, 'CollabTmpl', $(this).data("tmplSeq"));
				$(this).toggleClass("active");
		    });
			
		    //todo go
		    $("#btnGoTodo").on('click', function (e) {
				collabMenu.goTab($('#list_todo'), "todo", "TODO", "TODO", "/groupware/collab/CollabTodo.do", {"myTodo":"Y"});
		    });
		    
		    //todaywork 
		    $(".Twork_today a").on('click', function (e) {
				collabMenu.goTab($('#list_todo'), "todo", "TODO", "TODO", "/groupware/collab/CollabTodo.do", {"myTodo":"Y","tagType":"TAG","tagVal":$(this).data("tag"),"isPotal":"Y"});
		    });

		    
		    //템플릿 상세
		    $(document).on('click','.Template_area .pr_tit',function(e){
		    	var popupID	= "CollabTmplViewPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabTmpl/CollabTmplViewPopup.do?"
		 						+ "&tmplSeq="+$(this).data("tmplSeq")
		 						+ "&tmplName="+encodeURI($(this).text())
		 						+ "&popupID="	 + popupID;
				Common.open("", popupID, $(this).text(), popupUrl, "1600", "800", "iframe", true, null, null, true);
			});
		    
		    
		    //템플릿 more
		    $("#btnGoTmpl").on('click', function (e) {

		    	var popupID	= "CollabTmplPopup";
				var openerID = "AttendReq";
				var popupTit	= "Template";//"<spring:message code='Cache.lbl_app_approval_extention' />";
				var popupYN		= "N";
				var callBack	= "";
				var popupUrl	= "/groupware/collabProject/CollabTmplPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="		;

				
				Common.open("", popupID, popupTit, popupUrl, "720px", "815px", "iframe", true, null, null, true); 
		    });
		    
        },
        reloadPortal:function(){
        	collabPortal.slider.hide();
        	if(collabPortal.slider.hasClass('slick-initialized')) {
        		collabPortal.slider.slick("unslick");
            }
			this.getPortalMain();
        },
        loadSlide:function(){
        	collabPortal.slider.show();
        	collabPortal.slider.slick({
			     slide: 'div',		
			     infinite : false, 	
			     slidesToShow : 3,	
			     slidesToScroll : 1,
			     speed : 500,	  
			     arrows : true, 	
			     dots : false, 		
			     autoplay : false,	
			     autoplaySpeed : 3000,
			     pauseOnHover : true,
			     vertical : false,	
			     draggable : false, 
			     variableWidth: false,
			     centerMode: false
			   });
        	
       },
       getPortalMain:function (){
	   		$.ajax({
	       		type:"POST",
	       		url:"/groupware/collabPortal/getPortalMain.do",
	       		success:function (data) {
	       			collabPortal.displayStat(data.myTaskCnt);
	       			collabPortal.drawTodo(data.myTaskList);
	       			collabPortal.drawFavorite(data.myFavorite);
	       			collabPortal.drawProject(data.prjList, data.deptList);
	       			collabPortal.drawTmpl(data.tmplList);

	       			if (data.myConf != null){
		       			collabMenu.myConf = {"dashThema":data.myConf.DashThema,"taskShowCode":data.myConf.TaskShowCode};
	       			}	
	       		},
	       		error:function (request,status,error){
	       			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	       		}
	       	});
   
	  },
	  displayStat:function(data){
		$(".Twork_today li:eq(0) .T_num").text(data.ProcCnt==undefined?"0":data.ProcCnt);
  		$(".Twork_today li:eq(1) .T_num").text(data.NowForCnt==undefined?"0":data.NowForCnt);
  		$(".Twork_today li:eq(2) .T_num").text(data.DelayCnt==undefined?"0":data.DelayCnt);
  		$(".Twork_today li:eq(3) .T_num").text(data.EmgCnt==undefined?"0":data.EmgCnt);
	  },
	  drawTodo:function(json){
		  $(".Twork_todo").empty();
		  json.map( function( item,idx ){
			  $(".Twork_todo").append(
					  $("<li>").append($("<div>",{"class":"pr_chk"})
							  	.append($("<input>",{"type":"checkbox", "id":"prt_"+item.TaskSeq}).attr("checked",item.TaskStatus=="C"?true:false).data({"taskSeq":item.TaskSeq}))
							  	.append($("<label>",{"for":"prt_"+item.TaskSeq}).append($("<span>",{"class":"s_check"})))
							  	.append($("<a>",{"class":"link","text":"[D+"+(item.RemainDay!=null && parseInt(item.RemainDay) <= 0 ? (parseInt(item.RemainDay) == 0 ? "0" : (item.RemainDay+"").substring(1)) : "")+"] "+item.TaskName}).data({"taskSeq":item.TaskSeq})))
							 );
			  });
      },
	  drawFavorite:function(json){
		  $(".Twork_bookmark").empty();
		  json.map( function( item,idx ){
			  $(".Twork_bookmark").append( $("<li>").append($("<a>",{"href":"#"}).text(item.TaskName)).data({"taskSeq":item.TaskSeq}));
		});
      },
      drawProject:function(prjData, deptData){
		  $(".Pwork_list").empty();
		  
		  deptData.map( function( item,idx ){
			  $(".Pwork_list").append( collabPortal.drawTeamProject(item, "T"));
			});
		  prjData.map( function( item,idx ){
			  if (item.PrjStatus!='C'){
				  $(".Pwork_list").append( collabPortal.drawTeamProject(item, "P"));
			  }		  
			});
	  	collabPortal.loadSlide();
      },
      drawTeamProject:function(item, prjType){
			return $("<div>",{"class": (prjType=="T" ? "bg01" : ""), "style": (prjType=="P" && item.PrjColor != null && item.PrjColor != "" ? "background-color:"+item.PrjColor : ("background-color:#"+collabPortal.colorList[0].Code))})
    			.append($("<a>",{"href":"#","class":"prj_link"}).data({"prjType":prjType+(prjType!="P"?item.ExecYear:""),"prjSeq":(prjType!="P"?item.GroupID:item.PrjSeq)})
				.append($("<span>",{"class":"pr_type","style":(prjType=="P"&&item.PrjColor!=null&&item.PrjColor!=""?"color:"+item.PrjColor:"")}).text(prjType=="P"?"Project":"Team"))
				.append($("<strong>",{"class":"pr_title"}).text(prjType=="P"?item.PrjName:item.DeptName))
				.append($("<div>",{"class":"pr_info"}).append(prjType=="P"?$("<span>",{"class":"pr_dday","text":"~"+coviCmn.getDateFormat(item.EndDate)}):"")
				.append($("<span>",{"class":"pr_people","text":collabPortal.getMemberFormat(item.TmUser, item.TmUserCnt)})))
				.append($("<div>",{"class":"pr_progress"}).append($("<div>",{"class":"pr_pgbox"}).append($("<div>",{"class":"pr_pgbar","style":"width:"+(prjType=="P"?item.ProgRate+"%":"")})))		
				.append($("<div>",{"class":"pr_pgnum"}).append($("<span>").text((prjType=="P"?Math.round(item.ProgRate)+"%":"")))))
			)  
      },
      drawTmpl:function(json){
		  $(".Template_area ul").empty();
		  json.map( function( item,idx ){
			  $(".Template_area ul").append($("<li>",{"class":"icon01", "data-seq":item.TmplSeq})
					  .append($("<a>",{"class":"pr_tit"}).append($("<strong>").text(item.TmplName)).data({"tmplSeq":item.TmplSeq}))
					  .append($("<a>",{"class":"pr_like" + (item.MyLikeCnt>0?" active":"")}).data({"tmplSeq":item.TmplSeq}).append($("<span>",{"name":"likeCnt"}).text(item.LikeCnt)))
				);
		});
      },
      getMemberFormat:function(sName, sCount){
    	  var str = "<spring:message code='Cache.msg_apv_181'/>"; // 담당자를 지정하십시요.
    	  if (parseInt(sCount)>1){
    		  str ="<spring:message code='Cache.lbl_Mail_AndOthers'/>".replace("{0}",sName ).replace("{1}", sCount-1);
    	  }
    	  else if(sName !== null){
    		  str = sName;
    	  }

    	  return str;
      }
    }
    //시작
    $(document).ready(function (){
    	collabPortal.objectInit();
    });
	
	window.addEventListener('message', function(e){
		switch (e.data.functionName){
	    case "changeTemplateStatus": // 템플릿 팝업에서 좋아요 클릭 시, 페이지를 리로드 하지 않고 부분만 반영
	    	var $change = $(".Template_area").find("[data-seq=" + e.data.params["tmplSeq"] +"] .pr_like");
	    	
	    	if(e.data.params.isActive) $change.addClass("active");
	    	else $change.removeClass("active");
	    	
	    	$($change).children("span").text(e.data.params["count"]);
	    	break;
	    }
	});

</script>
