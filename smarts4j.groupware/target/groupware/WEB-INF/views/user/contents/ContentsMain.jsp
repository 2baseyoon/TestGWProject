<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
	<script type="text/javascript" src="<%=cssPath%>/contentsApp/resources/js/contentsApp.js"></script>
<c:set var="today" value="<%=new java.util.Date()%>" />
<div id='wrap'>
	<section id='ca_container'>
		<jsp:include page="ContentsLeft.jsp"></jsp:include>
		<div class='commContRight'>
			<div id="content">
			
				<div class="cRConTop titType">
					<h2 class="title"><spring:message code='Cache.lbl_contentApps'/> <spring:message code='Cache.lbl_home'/></h2>
					<div class="searchBox02" style="display:none">
						<span><input type="text" id="searchText">
						<button type="button" class="btnSearchType01" id="icoSearch"><spring:message code='Cache.btn_search' /></button></span>  <!-- 검색 -->
						<a href="#"	class="btnDetails"><spring:message code='Cache.lbl_detail' /></a> <!-- 상세 -->
					</div>
				</div>
				
				<div class="cRContBottom mScrollVH ">
				
					<div class="inPerView type02">
						<div class="selectCalView">
							<span><spring:message code='Cache.lbl_Contents' /></span> <!-- 내용 -->
							<select class="selectType02" name="searchOption" id="searchOption" >
								<option value=""><spring:message code='Cache.lbl_Select' /></option> <!-- 선택 -->
								<option value="1"><spring:message code='Cache.lbl_subject' /></option> <!-- 제목 -->
								<option value="2"><spring:message code='Cache.lbl_Contents' /></option> <!-- 내용 -->
							</select>
							<div class="dateSel type02">
								<input type="text" name="searchWord" id="searchWord">
							</div>
						    <a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearch"><spring:message code='Cache.btn_search' /></a> <!-- 검색 -->
						</div>
					</div>
					
					<div id="contentDiv" class="caContent">
						<div class="caMTopCont">
							<div class="navigation">
								<ul>
									<li class="home"></li>
									<li>${fn:replace(folderPathName,';','</li><li>')}</li>
								</ul>
							</div>
							<div class="buttonStyleBoxRight">
								<a href="#" id="listView" class="btnListView listViewType01 active"><spring:message code='Cache.lbl_list' /><spring:message code='Cache.lbl_view' />1</a>
								<a href="#" id="albumView" class="btnListView listViewType02"><spring:message code='Cache.lbl_list' /><spring:message code='Cache.lbl_view' />2</a>
								<button class="btnRefresh" type="button" href="#"></button>
							</div>
						</div>
						<!-- 컨텐츠앱 리스트보기 -->
						<div class="caListView">
							<div class="folder_wrap"></div>
						</div>
					</div>
				</div>
			</div>
	</section>
</div>
	
<script>
(function(param){
	
	var setEvent = function(){
		
		//검색 상세 토글
		$(".btnDetails").on('click', function(e){
			if(mobile_move_flag())		//중복방지
			
			$(this).toggleClass('active');
			if($(this).hasClass('active'))
				$('.inPerView').addClass('active');
			else
				$('.inPerView').removeClass('active');
		});
		
		//검색
		$('#icoSearch').on('click', function(){
			var searchParam = {
				"memberOf": param.memberOf,
				"searchType": "1",
				"searchText": $('#searchText').val()
			};
			
			getContentsData(searchParam);
	    });
		
		//검색 엔터
		$('#searchText').on('keydown', function (key) {
			if (key.keyCode == 13) {
				var searchParam = {
					"memberOf": param.memberOf,
					"searchType": "1",
					"searchText": $('#searchText').val()
				};
				
				getContentsData(searchParam);
			}
		});
				
		//상세검색
		$('#btnSearch').on('click', function(){
			var searchParam = {
				"memberOf": param.memberOf,
				"searchType": $('#searchOption').val(),
				"searchText": $('#searchWord').val()
			};
			
			getContentsData(searchParam);
	    });
		
		//리스트/썸네일
		$('.buttonStyleBoxRight a').on('click', function(){
			$(".buttonStyleBoxRight a").removeClass('active');
            $(this).addClass('active');
            
			getContentsData(param);
		});
		
		//새로고침
        $('.btnRefresh').on( 'click', function(e){
   			getContentsData(param);
        });
		
		//폴더메뉴 토글
        $(".folder_wrap").find(".more").on( 'click', function(e){
        	$(this).next().toggleClass("active");
        });
		
		//폴더메뉴
        $(".folder_wrap .column_menu").find("a").on( 'click', function(e){
        	var btnType = $(this).attr('data-btn');
        	var fid = $(this).closest('.listBox_folder').attr('data-fid');

        	$(this).parents(".column_menu").removeClass("active");
        	if(btnType == "namechange"){	//이름 변경
       			var popupID	= "ContentsNameChangePopup";
       			var openerID	= "";
       			var popupTit	= Common.getDic("WH_changeFolderName");
       			var popupYN		= "N";
       			var popupUrl	= "/groupware/contents/ContentsNameChangePopup.do?"
       							+ "&fId="    	+ fid
       							+ "&popupID="		+ popupID	
       							+ "&openerID="		+ openerID	
       							+ "&popupYN="		+ popupYN ;
       			Common.open("", popupID, popupTit, popupUrl, "530px", "330px", "iframe", true, null, null, true);
        	}else if (btnType == "confchange"){	//기본설정
    			var title = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>";
    			var url =  "/groupware/board/manage/goFolderManagePopup.do";
    				url += "?folderID="+fid;
    				url += "&mode=edit";
    				url += "&bizSection=Board";
    				url += "&domainID=" + Common.getSession("DN_ID");
    			
    			Common.open("", "setBoard", title, url, "700px", "540px", "iframe", false, null, null, true);
        	}else if(btnType == "folderdel"){	//삭제
        		//폴더메뉴 삭제
       			Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
       				if (result) {
       					$.ajax({
       						type: "POST",
       						url: "/groupware/board/manage/deleteBoard.do",
       						data: {
       							"folderID": fid
       						},
       						success: function(data){
       							if(data.status === 'SUCCESS'){
       								Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
       								window.location.reload(); // 새로고침
       							}else{
       								Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
       							}
       						},
       						error: function(response, status, error){
       							CFN_ErrorAjax("/groupware/board/manage/deleteBoard.do", response, status, error);
       						}
       					});
       				}
       			});
        	
        	}
        });
		
		//컨텐츠 앱 즐겨찾기 (폴더 핀)
		$(".folder_wrap .pin").on( 'click', function(e){
			var fid = $(this).parent().attr('data-fid');
			btnFavEvent(fid, "FD", this);
		});
		      
		//컨텐츠 앱 즐겨찾기 (앱)
		$(".favorite").on( 'click',function(){
			var fid = $(this).parent().parent().attr('data-fid');
			btnFavEvent(fid, "MN", this);
		});
        
	}
	
	//목록데이터 조회
	var getContentsData = function(param){
		
		if(mobile_move_flag())		//중복방지
		$.ajax({
			url:"/groupware/contents/selectContentsList.do",
			type:"POST",
			data: param,
			async:false,
			success:function (data) {
				var treeList = data.list;
				
				$(".folder_wrap").children().remove();
				$(".folder_wrap").nextAll().remove();
				
				if($(".buttonStyleBoxRight a").eq(0).hasClass("active")){
					$(".folder_wrap").parent().removeClass("caAlbumView").addClass("caListView");
					getContentsLIST(treeList);
				}else{
					$(".folder_wrap").parent().removeClass("caListView").addClass("caAlbumView");
					getContentsAlbum(treeList);
				}
				
				//컨텐츠없음
				if(treeList.length == 0)
					$(".folder_wrap").append($("<div>",{"class":"listBox_nodata"})
							.append($("<span>",{"class":"icon"}))
							.append($("<p>",{"text":"<spring:message code='Cache.msg_noContent'/>"})));
				
				setEvent();
			},
			error:function (error){
				alert(error);
			}
		});
	}
	
	//리스트형
	var getContentsLIST = function(treeList){
		//폴더 핀(즐겨찾기)
		for(var i=0; i< treeList.length; i++){
			var list = treeList[i];
			
			if((list.FolderType == 'Root' || list.FolderType == 'Folder') && list.IsFav > 0){
				$(".folder_wrap").append($("<div>",{"class":"listBox_folder","data-fid":list.FolderID})
						.append($("<a>",{"href":"/groupware/contents/ContentsMain.do?memberOf="+list.FolderID})
								.append($("<span>",{"class":"icon"}))
								.append($("<span>",{"class":"folder_name"})
										.append(list.FolderName)
										)
								)
								.append($("<span>",{"class":"pin active"}))
								.append($("<span>",{"class":"more"}))
								.append($("<div>",{"class":"column_menu"})
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_name'/><spring:message code='Cache.lbl_change'/>","data-btn":"namechange"}))
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_delete'/>","data-btn":"folderdel"}))
										)
				);
			}
		}
		
		//폴더
		for(var i=0; i< treeList.length; i++){
			var list = treeList[i];
			
			if((list.FolderType == 'Root' || list.FolderType == 'Folder') && list.IsFav == 0){
				$(".folder_wrap").append($("<div>",{"class":"listBox_folder","data-fid":list.FolderID})
						.append($("<a>",{"href":"/groupware/contents/ContentsMain.do?memberOf="+list.FolderID})
								.append($("<span>",{"class":"icon"}))
								.append($("<span>",{"class":"folder_name"})
										.append(list.FolderName)
										)
								)
								.append($("<span>",{"class":"pin"}))
								.append($("<span>",{"class":"more"}))
								.append($("<div>",{"class":"column_menu"})
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_name'/><spring:message code='Cache.lbl_change'/>","data-btn":"namechange"}))
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_SettingDefault'/>","data-btn":"confchange"}))
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_delete'/>","data-btn":"folderdel"}))
										)
				);
			}
		}
		
		//콘텐츠
		for(var i=0; i< treeList.length; i++){
			var list = treeList[i];
			
			if(list.FolderType != 'Root' && list.FolderType != 'Folder'){
				//표시 아이콘
				var UseIconClass = "";
				var UseIconStyle = "";
				if(list.UseIcon != null && list.UseIcon != ''){
					if(list.UseIcon.startsWith("app")){
						UseIconClass = list.UseIcon;
					}else{
						UseIconClass = "custom";
						
						var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
						UseIconStyle = "background: url('" + coviCmn.loadImage(BackStorage + list.UseIcon) + "') no-repeat center;";
					}
				}else{
					UseIconClass = "app01";
				}
				
				$(".folder_wrap").parent().append($("<div>",{"class":"listBox_app","data-fid":list.FolderID})
						.append($("<a>",{"href":"/groupware/contents/ContentsList.do?folderID="+list.FolderID})
								.append($("<span>",{"class":"icon "+UseIconClass,"style":UseIconStyle}))
								.append($("<div>",{"class":"app_name"})
										.append($("<p>",{"class":"app_title"})
											.append(list.DisplayName)
											)
										.append($("<p>",{"class":"app_dec"})
											.append(list.Description)
											)
									)
								)
						.append($("<div>",{"class":"listBox_app_right"})
								.append($("<span>",{"class":"date"})
										.append(list.RegistDate)
										)
								.append($("<div>",{"class":"user_img","title":list.RegisterName + "연구2팀"})
										.append($("<p>",{"class":"bgColor"+(Math.floor(coviCmn.random() * 5)+1)})
												.append($("<strong>")
														.append(list.RegisterName.substr(0,1)))
												)
										)
								.append($("<a>",{"class":(list.IsFav > 0)?"favorite active":"favorite"}))
								.append($("<a>",{"class":"setting","href":"/groupware/contents/ContentsUserForm.do?folderID="+list.FolderID}))
						)
				);
			}
		}
	}
	
	//엘범형
	var getContentsAlbum = function(treeList){
		//폴더 핀(즐겨찾기)
		for(var i=0; i< treeList.length; i++){
			var list = treeList[i];
			
			if((list.FolderType == 'Root' || list.FolderType == 'Folder') && list.IsFav > 0){
				$(".folder_wrap").append($("<div>",{"class":"listBox_folder","data-fid":list.FolderID})
						.append($("<a>",{"href":"/groupware/contents/ContentsMain.do?memberOf="+list.FolderID})
								.append($("<span>",{"class":"icon"}))
								.append($("<span>",{"class":"folder_name"})
										.append(list.FolderName)
										)
								)
								.append($("<span>",{"class":"pin active","style":"cursor:pointer"}))
								.append($("<span>",{"class":"more"}))
								.append($("<div>",{"class":"column_menu"})
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_name'/> <spring:message code='Cache.lbl_change'/>","data-btn":"namechange"}))
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_delete'/>","data-btn":"folderdel"}))
										)
				);
			}
		}
		
		//폴더
		for(var i=0; i< treeList.length; i++){
			var list = treeList[i];
			
			if((list.FolderType == 'Root' || list.FolderType == 'Folder') && list.IsFav == 0){
				$(".folder_wrap").append($("<div>",{"class":"listBox_folder","data-fid":list.FolderID})
						.append($("<a>",{"href":"/groupware/contents/ContentsMain.do?memberOf="+list.FolderID})
								.append($("<span>",{"class":"icon"}))
								.append($("<span>",{"class":"folder_name"})
										.append(list.FolderName)
										)
								)
								.append($("<span>",{"class":"pin","style":"cursor:pointer"}))
								.append($("<span>",{"class":"more"}))
								.append($("<div>",{"class":"column_menu"})
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_name'/> <spring:message code='Cache.lbl_change'/>","data-btn":"namechange"}))
										.append($("<a>",{"text":"<spring:message code='Cache.lbl_delete'/>","data-btn":"folderdel"}))
										)
				);
			}
		}
		
		//콘텐츠
		for(var i=0; i< treeList.length; i++){
			var list = treeList[i];
			
			if(list.FolderType != 'Root' && list.FolderType != 'Folder'){
				//표시 아이콘
				var UseIconClass = "";
				var UseIconStyle = "";
				if(list.UseIcon != null && list.UseIcon != ''){
					if(list.UseIcon.startsWith("app")){
						UseIconClass = list.UseIcon;
					}else{
						UseIconClass = "custom";
						
						var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
						UseIconStyle = "background: url('" + coviCmn.loadImage(BackStorage + list.UseIcon) + "') no-repeat center;";
					}
				}else{
					UseIconClass = "app01";
				}
				
				$(".folder_wrap").parent().append($("<div>",{"class":"listBox_app","data-fid":list.FolderID})
						.append($("<a>",{"href":"/groupware/contents/ContentsList.do?folderID="+list.FolderID})
								.append($("<span>",{"class":"icon "+UseIconClass, "style":UseIconStyle}))
								.append($("<div>",{"class":"app_name"})
										.append($("<p>",{"class":"app_title"})
											.append(list.DisplayName)
											)
										.append($("<p>",{"class":"app_dec"})
											.append(list.Description)
											)
									)
								)
						.append($("<div>",{"class":"listBox_app_top"})
								.append($("<a>",{"class":(list.IsFav > 0)?"favorite active":"favorite"}))
								.append($("<a>",{"class":"setting","href":"/groupware/contents/ContentsUserForm.do?folderID="+list.FolderID}))
						)
				);
			}
		}
		
	}
	
	//컨텐츠 앱 즐겨찾기
	var btnFavEvent = function(fid, ftype, obj){
		$.ajax({
	    		type:"POST",
	    		data:{"fid":  fid, "ftype":  ftype, "isFlag":$(obj).hasClass("active")},
	    		url:"/groupware/contents/saveContentsFavorite.do",
	    		success:function (data) {
	    			if(data.status == "SUCCESS")
	    				$(obj).toggleClass("active");
	    			else
	    				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
	    			
	    			$(".btnRefresh").trigger('click');	//새로고침
	    			$(".btnRefresh").focus();
	    		},
	    		error:function (request,status,error){
	    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	    		}
	    	});
	}
	
	//중복차단
	var move_flag_param = true; 
	var mobile_move_flag = function(){
		if(move_flag_param){
			move_flag_param =  false; 
			setTimeout(function(){move_flag_param = true;}, 500);
			return true;
		} else {
			return false;
		} 
	}
	
	var init = function(){
		getContentsData(param);
	}
	
	init();
	
})({
	memberOf: "${memberOf}"
	, isFav: "${isFav}"
});
</script>