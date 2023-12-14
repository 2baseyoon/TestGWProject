/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 협업스페이스 js 파일
 * 함수명 : mobile_collab_...
 * 
 * 
 */

/*!
 * 
 * 페이지별 init 함수
 * 
 */

//협업 스페이스 포탈록 페이지
$(document).on('pageinit', '#collab_portal_page', function () {	
	if($("#collab_portal_page").attr("IsLoad") != "Y"){
		$("#collab_portal_page").attr("IsLoad", "Y");
		setTimeout("mobile_collab_PortalInit()",10);
		setTimeout("mobile_collab_Init()",10);
	}else{
		mobile_comm_go('/groupware/mobile/collab/portal.do');
		//collabMobile.MenuList();
	}
});

$(document).on('pageinit', '#collab_main_page', function () {	
	if($("#collab_main_page").attr("IsLoad") != "Y"){
		$("#collab_main_page").attr("IsLoad", "Y");
		setTimeout("mobile_collab_project.init()",10);
	}
});

$(document).on('pageinit', '#collab_menu_list', function () {	
	if($("#collab_menu_list").attr("IsLoad") != "Y"){
		$("#collab_menu_list").attr("IsLoad", "Y");
		setTimeout("mobile_collab_menuList.init()",10);
	}else{
		mobile_collab_menuList.addEvent();
	}
});

$(document).on('pageinit', '#collab_task_detail', function () {	
	
	if($("#collab_task_detail").attr("IsLoad") != "Y"){
		$("#collab_task_detail").attr("IsLoad", "Y");
		setTimeout("mobile_collab_taskDetail.init()",10);
	}else{
		setTimeout("mobile_collab_taskDetail.getTask()",10);
	}
	
});

$(document).on('pageinit', '#collab_member_page,#collab_subTaskmember_page,#collab_projectmember_page', function () {
	if( this.id == "collab_member_page" && $("#collab_member_page").attr("IsLoad") != "Y"){
		$("#collab_member_page").attr("IsLoad", "Y");
		setTimeout("mobile_collab_projectTask.memberPageInit()",10);
	}else if( this.id == "collab_subTaskmember_page" && $("#collab_subTaskmember_page").attr("IsLoad") != "Y"){
		$("#collab_subTaskmember_page").attr("IsLoad", "Y");
		setTimeout("mobile_collab_projectTask.taskMemberPageInit()",10);
	}else if( this.id == "collab_projectmember_page" && $("#collab_projectmember_page").attr("IsLoad") != "Y"){
		$("#collab_projectmember_page").attr("IsLoad", "Y");
		setTimeout("mobile_collab_projectTask.projectMemberPageInit()",10);
	}
});

$(document).on('pageinit', '#collab_templatePop', function () {	
	if($("#collab_templatePop").attr("IsLoad") != "Y"){
		$("#collab_templatePop").attr("IsLoad", "Y");
		setTimeout("mobile_collab_template.init()",10);
	}
});

$(document).on('pageinit', '#collab_templateToProject', function () {	
	if($("#collab_templateToProject").attr("IsLoad") != "Y"){
		$("#collab_templateToProject").attr("IsLoad", "Y");
		setTimeout("mobile_collab_template.projectAdd()",10);
	}
});

$(document).on('pageinit', '#collab_projectPop', function () {	
	if($("#collab_projectPop").attr("IsLoad") != "Y"){
		$("#collab_projectPop").attr("IsLoad", "Y");
		setTimeout("mobile_collab_projectDetail.init()",10);
	}
});

$(document).on('pageshow', '#collab_projectPop', function () {	
	mobile_collab_projectDetail.addEvent();
});

$(document).on('pageshow', function (e) {
	if($(e.target).prop("id") == "collab_main_page") {
		mobile_collab_project.addEvent();
	}
});

$(document).on('pageinit', '#collab_add_subTask', function () {	
	if($("#collab_add_subTask").attr("IsLoad") != "Y"){
		$("#collab_add_subTask").attr("IsLoad", "Y");
		setTimeout("mobile_collab_projectTask.subTaskRegEvent()",10);
	}
});

var mobile_collab_project_param; 

//task registry
var mobile_collab_projectTask = function(){
	
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var _data = {
		trgMember : []	
	}
	
	var $template = (
			'<li class="staff">'+
				'<a class="con_link ui-link">'+
					'<span class="photo" style="{=photo}"></span>'+
					'<div class="info">'+
						'<p class="name">{=DisplayName}</p>'+
						'<p class="detail"><span>{=DeptName}</span></p>'+
					'</div>'+
				'</a>'+
				'<div class="check">'+
					'<div class="ui-checkbox">'+
						'<div class="ui-checkbox">'+
							'<label for="collabMember{=idx}" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left {=onoff}"></label>'+
							'<input type="checkbox" id="collabMember{=idx}" {=check}>'+
						'</div>'+
					'</div>'+	
				'</div>'+
			'</li>'			
	);
	
	//subtask event
	this.subTaskRegEvent = function(){
		//datepicker
		$(document).on("focusin","#collab_add_subTask .input_date",function(){
    		!$(this).hasClass(".hasDatepicker")&& $("#collab_add_subTask .input_date").datepicker({
    	      dateFormat : 'yy.mm.dd',
    	      dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    	    });
    	});
		//close
		$(document).on('click','#collab_add_subTask #closeTodo', function(){ 
			if(mobile_move_flag())	//중복방지
				mobile_comm_back();
		});
		//save
		$(document).on('click','#collab_add_subTask #saveTodo', function(){
			var spePatt = /[`!#$%^&*|\\\'\";:\/?¢™$®]/gi;
			if(mobile_move_flag()){	//중복방지
				if( $("#collab_add_subTask #taskName").val().length == 0 ){	// 업무명을 입력해주세요
					alert(mobile_comm_getDic("msg_chk_taskName"));
					return false;
				}else if(spePatt.test($("#collab_add_subTask #taskName").val())){
					alert(mobile_comm_getDic("msg_specialNotAllowed"));	// 특수문자는 사용할 수 없습니다.
					return;
				}else if( $("#collab_add_subTask #startDate").val().length == 0 ){	// 시작일자를 입력하세요
					alert(mobile_comm_getDic("msg_EnterStartDate"));
					return false;
				}else if( $("#collab_add_subTask #endDate").val().length == 0 ){	// 종료일자를 입력하세요
					alert(mobile_comm_getDic("msg_EnterEndDate"));
					return false;
				}else if( !$("#collab_add_subTask #member").data("item") ){
					alert(mobile_comm_getDic("msg_task_performer"));	// 수행자를 입력하세요
					return false;
				}			
				var param = {
					topTaskSeq	:	$("#collab_task_selProject").attr("data-toptaskseq")
					,taskSeq 	: 	$("#collab_task_selProject").attr("data-taskseq")
					,taskName 	:	$("#collab_add_subTask #taskName").val()
					,startDate 	:	$("#collab_add_subTask #startDate").val()
					,endDate 	:	$("#collab_add_subTask #endDate").val()
					,trgMember	:	($("#collab_add_subTask #member").data("item") || []).map(function(item,idx){ return { type : "UR", userCode : item.userCode } })				
				}
				
				$.ajax({
	        		type:"POST",
	        		contentType:'application/json; charset=utf-8',
					dataType   : 'json',
	        		data:JSON.stringify(param),
	        		url:"/groupware/collabTask/addSubTaskSimple.do",
	        		success:function (data) {
	        			mobile_collab_taskDetail.getTask();
						mobile_comm_back();        			
						//$('#collab_add_subTask #closeTodo').trigger('click');
	        		},
	        		error:function (request,status,error){
	        			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	        		}
	        	});
			}
		});
		//subtask - 수행자 추가
        $(document).on('click','#addMember',function(){
			if(mobile_move_flag()) {
				if($('#collab_task_selProject option').length == 0){
					collabMobile.orgSelect("SelectUser", "Y", "mobile_collab_projectTask.setTaskMemberArr()");
				}else{
					mobile_comm_go('/groupware/collabProject/mobile/popTaskMember.do?id=collab_subTaskmember_page', 'Y');
				}
			}
		});
		//기간 체크
		$("#collab_subTask_period input").on("change", function(){
			collabMobile.checkDates("collab_subTask_period", this);
		});
	}
	// 서브태스크의 수행자 추가 - 내업무
	 this.setTaskMemberArr = function(){
		var data = $.parseJSON("[" + window.sessionStorage["userinfo"] + "]");
		var arr = new Array();
		
		if (data.length > 0) {
			$.each(data, function (i, v) {
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
				var saveData = { "type":type, "userCode":code, "DisplayName": v.DN };
				arr.push(saveData);
			});
		}
		$("#collab_add_subTask #member")
			.data('item',arr)
			.empty().append(
				arr.map(function(item,idx){
					return $("<div>",{ "class" : "user_img", "code" : item.userCode, "type" : "UR" }).append(
						$("<p>",{ "class" : "bgColor"+Math.floor(mobile_comm_random() * (6 - 1) + 1) }).append( $("<strong>",{ "text" : item.DisplayName.substr(0,1) }) )	
					)
				})
			);
		mobile_collab_projectTask.setTrgMember(arr);
	}
	
	//reg area event
    this.taskRegEvent = function(){    	
	/*	$(document).on('click','#collab_main_todoAdd',function(){
			$("body").append( $("<div>",{ id : "_popup" }) );
    		$( "#_popup" ).load( "/groupware/mobile/collab/popTodoTask.do #addTodo",function(){    			
    			var _formData = new FormData();    			    			
    			$("#taskName,#progRate,#remark",this).on('change',function(){ _formData.append(this.id,this.value); });    			
				$("#taskStatus input:checkbox",this).on('change',function(){
					if( $(this).is(":checked") ){						
						_formData.append("taskStatus",this.value);
						$("#taskStatus input:checkbox").not(this).each(function(){
							$(this).prop("checked",false).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off")
						});
					}
				});
    			$(".input_date",this).datepicker({
    				dateFormat : 'yy.mm.dd',
    				dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	    	    }).on('change',function(){ _formData.append(this.id,this.value); });
    			
    			$("#saveTodo",this).on('click',function(){    				
    				$.ajax({
						type:"POST",
						enctype: 'multipart/form-data',
						data: _formData,
						processData: false,
						contentType: false,
						url:"/groupware/collabTask/addTask.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								$("#_popup #closeTodo").trigger("click");
							}
						},
						error:function (request,status,error){
							mobile_comm_log(request,status,error);
						}
					});
    			});
    			$("#closeTodo",this).on('click',function(){ this.remove(); }.bind($(this)));
    			
    			$("#label",this).on('click',function(){ $("#label .sleOpTitle,#label .selectOpList").toggleClass( "active" ); });
    			$("#label .selectOpList li",this).on('click',function(){ 
    				$(this.parentNode).prev().empty().append(this.innerHTML);
    				_formData.append("label",this.dataset.selvalue);
    				
    			});
    		});
		});*/

    	$(document).on('click','#taskAddBtn',function(){ 
			$("#collab_regist_title").val("");
			$("#collab_start_date").val("");
			$("#collab_end_date").val("");
			
			mobile_collab_projectTask.emptyTrgMember();
			
			$("#taskAddPop").addClass("pos"); 
		});
		
    	$(document).on('click','#taskCloseBtn',function(){ $("#taskAddPop").removeClass("pos"); });
    	
    	$(document).on("focusin","#collab_start_date",function(){
    		!$(this).hasClass(".hasDatepicker")&& $("#collab_start_date").datepicker({
    	      dateFormat : 'yy/mm/dd',
    	      dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    	    });
    	});
    	
    	$(document).on("focusin","#collab_end_date",function(){
    		!$(this).hasClass(".hasDatepicker")&& $("#collab_end_date").datepicker({
    	      dateFormat : 'yy/mm/dd',
    	      dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    	    });
    	});
    	
    	
        //간편작성
        $(document).on('click','#collab_regist',function(){
			if(mobile_move_flag()){		//중복방지
		        _data.prjSeq = (mobile_collab_project_param.get().prjSeq == "undefined")  ?  "" : mobile_collab_project_param.get().prjSeq;
	        	_data.startDate = $("#collab_start_date").val();
	        	_data.endDate = $("#collab_end_date").val();
	        	_data.taskName = $("#collab_regist_title").val();
				
				if(mobile_collab_project_param.get().myTodo != "Y" && $('#sectionSel option:selected').length < 1){
					alert(mobile_comm_getDic("msg_taskAddRegistSection")); // 업무를 저장할 섹션이 없습니다. 섹션을 추가해주세요.
					return;
				}
				
				var spePatt = /[`!#$%^&*|\\\'\";:\/?¢™$®]/gi;
				if( $("#collab_regist_title").val().length == 0 ){
					alert(mobile_comm_getDic("msg_chk_taskName"));	// 업무명을 입력해주세요
					return;
				} else if(spePatt.test($("#collab_regist_title").val())){
					alert(mobile_comm_getDic("msg_specialNotAllowed"));	// 특수문자는 사용할 수 없습니다.
					return;
				}
				
				if(_data.startDate > _data.endDate || _data.startDate == "" || _data.endDate == "") {
					alert(mobile_comm_getDic("msg_checkedDate")); // 기간을 다시 확인해주세요
					return;
				}

	        	$.ajax({
	        		url:"/groupware/collabTask/addTaskSimple.do",
	        		type:"POST",
	        		contentType:'application/json; charset=utf-8',
					dataType   : 'json',
		    		data: JSON.stringify( $.extend({},_data) ),
	        		success:function (data) {
	        			mobile_collab_project.refresh();
	        			$("#taskAddPop").removeClass("pos"); 
	        		},
	        		error:function (request,status,error){
	        			mobile_comm_log(request,status,error)
	        		}
	        	});
			}
        });
        //간편작성 - 수행자 추가
        $(document).on('click','#collab_btn_add',function(){
			if(mobile_move_flag()) {
				if(mobile_collab_project_param.get().myTodo == "Y"){
					collabMobile.orgSelect("SelectUser", "Y", "mobile_collab_projectTask.setMemberArr()");
				}else{
					mobile_comm_go('/groupware/collabProject/mobile/popTaskMember.do?id=collab_member_page', 'Y');	
				}
			}
		});
    }
    this.setMemberArr = function(){
		var data = $.parseJSON("[" + window.sessionStorage["userinfo"] + "]");
		var arr = new Array();
		
		if (data.length > 0) {
			$.each(data, function (i, v) {
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;

				var saveData = { "type":type, "userCode":code};
				arr.push(saveData);
			});
		}
		mobile_collab_projectTask.setTrgMember(arr);
		$("#memberCnt").text(arr.length);
	}
    //reg area section
    this.drawSectionList = function(data){
    	var getParam = mobile_collab_project_param.get();
		if(data.taskFilter.length > 0){
	    	$('#sectionSel')
	    		.append( data.taskFilter.map(function(item,idx){  return $("<option>",{ text : item.SectionName, value : item.SectionSeq }) }) )
	    		.data('item',data.prjData)
	    		.on('change',function(){ 
	    			var prjData = $(this).data('item');
	    			_data.sectionSeq 	= this.value
	    			_data.prjSeq		= getParam.PrjSeq
	    			_data.prjType		= getParam.prjType
	    		}).trigger('change');
		}
    }
    
    this.setTrgMember = function( checkMember ){ _data.trgMember = checkMember; }
    
    this.emptyTrgMember = function() {
		_data.trgMember = [];
		$("#memberCnt").text(0);
	}

    this.projectMemberPageInit = function(){    	
    	var param = { taskSeq : $("#collab_task_selProject").attr("data-toptaskseq") };
    	var checkedList = $("#collab_task_user").data("item");
		if (checkedList == undefined) { checkedList = new Array(); }
		$.ajax({
	   		type:"POST",
	   		url:"/groupware/collabTask/getTaskMemberList.do",
	   		data: param,
	   		success:function (data) {
	   			if(data.status == "SUCCESS"){	   				
	   				//collab_member_list
	   				$("#collab_member_list").append( data.memberList.map(function( item,idx ){
	   					var $temp = $template;	   						   					
	   					var checked = checkedList.some(function(cur,idx){ return cur.UserCode == item.UserCode });	   					
	   					$temp = $temp.replace(/{\=photo}/g,"background-image:url(\'"+mobile_comm_getimg(item.PhotoPath)+"\'), url(\'"+mobile_comm_noperson()+"\')")
				   					 .replace(/{\=DisplayName}/g,item.DisplayName)
				   					 .replace(/{\=DeptName}/g, item.DeptName)
				   					 .replace(/{\=onoff}/g, checked ? "ui-checkbox-on" : "ui-checkbox-off" )	   					
				   					 .replace(/{\=check}/g, checked ? "checked" : "" )
				   					 .replace(/{\=idx}/g,idx);
	   					$temp = $($temp);
	   					$("input[type=checkbox]",$temp).data("item",item);	   					
	   					return $temp;
	   				})).on('change','input[type=checkbox]',function(){
	   					$(this).prev().removeClass();
	   					$(this).is(":checked")  && $(this).prev().addClass("ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-on");
	   					!$(this).is(":checked") && $(this).prev().addClass("ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off");
	   				})	   				
	   			}
	   		},
	   		error:function (request,status,error){
	   			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	   		}
		});
		
		$("#addTaskUser").on('click',function(){
			var addUserList = Array.prototype.slice.call($("#collab_projectmember_page input:checkbox:checked")).reduce(function(acc,cur,idx,arr){ 
				var item = $(cur).data('item');
				!checkedList.some(function(cur,idx){ return cur.UserCode == item.UserCode }) && (acc = acc.concat({ type : "UR", userCode : item.UserCode }));
				return acc;
			},[]);		
			
			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data :JSON.stringify({ "trgMember" : addUserList, "taskSeq" : $("#collab_task_selProject").attr("data-taskseq") }),
				url:"/groupware/collabTask/addTaskInvite.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						alert(mobile_comm_getDic("msg_com_processSuccess"));
						mobile_collab_taskDetail.getTask();
						mobile_comm_back();
					}
					else{
						alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
		});
    }
    
    
    //subTaskMemberPopup
    this.taskMemberPageInit = function(){    	
    	var param = { taskSeq : $("#collab_task_selProject").attr("data-toptaskseq") };
    	var checkedList = _data.trgMember;
		$.ajax({
	   		type:"POST",
	   		url:"/groupware/collabTask/getTaskMemberList.do",
	   		data: param,
	   		success:function (data) {
	   			if(data.status == "SUCCESS"){	   				
	   				//collab_member_list
	   				$("#collab_member_list").append( data.memberList.map(function( item,idx ){
	   					var $temp = $template;	   						   					
	   					var checked = checkedList.some(function(cur,idx){ return cur.UserCode == item.UserCode });
	   					$temp = $temp.replace(/{\=photo}/g,"background-image:url(\'"+mobile_comm_getimg(item.PhotoPath)+"\'), url(\'"+mobile_comm_noperson()+"\')")
				   					 .replace(/{\=DisplayName}/g,item.DisplayName)
				   					 .replace(/{\=DeptName}/g, item.DeptName)
				   					 .replace(/{\=onoff}/g, checked ? "ui-checkbox-on" : "ui-checkbox-off" )
				   					 .replace(/{\=check}/g, checked ? "checked" : "" )
				   					 .replace(/{\=idx}/g,idx);
	   					$temp = $($temp);
	   					$("input[type=checkbox]",$temp).data("item",item);	   					
	   					return $temp;
	   				})).on('change','input[type=checkbox]',function(){
	   					$(this).prev().removeClass();
	   					$(this).is(":checked")  && $(this).prev().addClass("ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-on");
	   					!$(this).is(":checked") && $(this).prev().addClass("ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off");
	   				})	   				
	   			}
	   		},
	   		error:function (request,status,error){
	   			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	   		}
		});
		
		$("#addTaskUser").on('click',function(){			
			var arr = Array.prototype.slice.call($("#collab_subTaskmember_page input[type=checkbox]:checked")).map(function(item,idx){ 
				var item = $(item).data('item');
				item.userCode = item.UserCode;
				return  item; 
			});			
			$("#collab_add_subTask #member")
				.data('item',arr)
				.empty().append(
					arr.map(function(item,idx){
						return $("<div>",{ "class" : "user_img", "code" : item.UserCode, "type" : "UR" }).append(
							$("<p>",{ "class" : "bgColor"+Math.floor(mobile_comm_random() * (6 - 1) + 1) }).append( $("<strong>",{ "text" : item.DisplayName.substr(0,1) }) )	
						)
					})
				);
			mobile_collab_projectTask.setTrgMember(arr);
			mobile_comm_back();
		});
    }
    
    
    //reg init
	this.memberPageInit = function(){	
		var getParam = mobile_collab_project_param.get();
		var prjType 	= getParam.prjType;
		var prjSeq 		= getParam.prjSeq;		
		var checkedList = _data.trgMember;		
				
		$.ajax({
	   		type:"POST",
	   		url:"/groupware/collabProject/getMemberList.do",
	   		data: {
	   			prjSeq : prjSeq,
	   			prjType : prjType,
	   		},
	   		success:function (data) {
	   			if(data.status == "SUCCESS"){	   				
	   				//collab_member_list
	   				$("#collab_member_list").append( data.memberList.map(function( item,idx ){
	   					var $temp = $template;	   						   					
	   					var checked = checkedList.some(function(cur,idx){ return cur.UserCode == item.UserCode });	   					
	   					$temp = $temp.replace(/{\=photo}/g,"background-image:url(\'"+mobile_comm_getimg(item.PhotoPath)+"\'), url(\'"+mobile_comm_noperson()+"\')");
	   					$temp = $temp.replace(/{\=DisplayName}/g,item.DisplayName);
	   					$temp = $temp.replace(/{\=DeptName}/g, item.DeptName);
	   					$temp = $temp.replace(/{\=onoff}/g, checked ? "ui-checkbox-on" : "ui-checkbox-off" );	   					
	   					$temp = $temp.replace(/{\=check}/g, checked ? "checked" : "" );
	   					$temp = $temp.replace(/{\=idx}/g,idx);	   					
	   					$temp = $($temp);	   					
	   					$("input[type=checkbox]",$temp).data("item",item);	   					
	   					return $temp;
	   				})).on('change','input[type=checkbox]',function(){
	   					$(this).prev().removeClass();
	   					$(this).is(":checked")  && $(this).prev().addClass("ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-on");
	   					!$(this).is(":checked") && $(this).prev().addClass("ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-che-off");
	   				})	   				
	   			}
	   		},
	   		error:function (request,status,error){
	   			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	   		}
	   	});
		
		//addEvent		
		$("#addTaskUser").on('click',function(){			
			var arr = Array.prototype.slice.call($("#collab_member_list input[type=checkbox]:checked")).map(function(item,idx){ 
				var item = $(item).data('item');
				item.userCode = item.UserCode;
				return  item; 
			});			
			mobile_collab_projectTask.setTrgMember(arr);			
			$("#memberCnt").text(arr.length);
			mobile_comm_back();
		});
		
	}
	
}();

var mobile_collab_project = function(){	

	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var project = {};

	var _mobile_collab_project_param = function(data){
		if (!(this instanceof arguments.callee )) return new arguments.callee(data);
		var _data = data;
		
		this.get = function(){
			return _data;
		}
	}
	
	this.get = function(){
		return project;
	}
	
	this.set = function(param){
		$.extend(project, param);
	}
	
	this.init = function(){
		var prjType = mobile_comm_getQueryString("prjType");
		var prjSeq = mobile_comm_getQueryString("prjSeq");
		var myTodo = mobile_comm_getQueryString("myTodo");
		var tagVal = mobile_comm_getQueryString("tagVal");
		if(myTodo == "undefined") myTodo = "N";
		if(prjType == "undefined" && prjSeq == "undefined") myTodo = "Y";

		var data = {prjType : prjType, prjSeq : prjSeq, myTodo : myTodo};
		if(tagVal != "undefined") $.extend(data, {tagval : tagVal , tagtype : "TAG"}); 
		project = {};
		mobile_collab_project_param = _mobile_collab_project_param(data);
		//this.setExMenu();
		this.refresh();
		collabMobile.MenuList();
	}
	
	this.refresh = function(){
		changeDisplayMode(this);
		
		switch (project.dataType){
			case "FILE":
				getMyFile();
				break;
			case "APPROVAL":
				getMyApproval();
				break;
			case "SURVEY":
				getMySurvey();
				break;
			default:				
				if(project.viewMode == "CAL" || project.viewMode == "GANT"){
					this.getMyTask();
				} else {
					if(isNaN(mobile_collab_project_param.get().prjSeq)){
						getTodoMain();
					} else {
						getProjectMain();	
					}
				}
				break;
		}
	}
	
	this.changeFolder = function(data){
		mobile_collab_project_param = _mobile_collab_project_param(data);
		mobile_comm_TopMenuClick('collab_leftmenu_tree',true);
		project = {};
		//this.setExMenu();
		this.refresh();
	}
	
	this.search = function(){
		if(project.viewMode == "CAL" || project.viewMode == "GANT"){
			var startDateObj = new Date($("#collab_main_page .calendar_ctrl .title").text());
			changeCalendar(mobile_comm_getDateTimeString("yyyy-MM-dd",startDateObj), project.viewMode);
		} else {
			this.getMyTask();
		}
	}
	
	this.addEvent = function(){
		var objId = "collab_main_page";
		$('#'+objId).off();
		//프로젝트 진행률
		$(".Project_list .btn_link").click(function(){
			$(this).parents().find(".myProcess_pop").addClass("active");
			$(this).parents().find('body').addClass("ov");
		});
		  
		$(".mobile_popup_btn .btn_close").click(function(){
			$(this).parents().find(".myProcess_pop").removeClass("active");
			$(this).parents().find('body').removeClass("ov");
		});

	    /* task */
	    //상세
	    $('#'+objId).on('click','.coWorkBox, .card_title, .btn_arrow_c.ui-link',function(){
	    	collabMobile.openTaskPopup("Y", $(this).data("prjSeq"), $(this).data("taskSeq"))
	    });	    
	    
	    //task 완료 처리
	    $('#'+objId).on('change','.row .column input[type=checkbox]',function(e){
			if(!$(this).is(':checked') || confirm(mobile_comm_getDic("msg_TaskClose"))){	// 마감 하시겠습니까?
				if(mobile_move_flag()){	//중복방지
					e.stopPropagation();
					var myTodo = mobile_collab_project_param.get().myTodo;
					var	data = {"taskSeq":  $(this).data("taskSeq"), "taskStatus": $(this).is(':checked'),"prjType":  $(this).data("prjType")};
					var cardObj = $(this).closest(".card_cont");
					
					if(cardObj.length == 0){
						cardObj = $(this).closest('.card.listBox');
					}
					
					saveTaskComplete(data, function (res) {
						if (myTodo == "Y"){
							mobile_collab_project.refresh();
				  		}
						else{
							cardObj.removeClass("card_delay").toggleClass("card_complete");
						}
				  	});
				}
			}else{
				if($(this).prev().attr("class") == "checkbox ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-on"){
					$(this).prev().attr("class","checkbox ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-on");
					$(this).data("cacheval") == "true";
					$(this).prop("checked",true);
				}else{
					$(this).prev().attr("class","checkbox ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off");
					$(this).data("cacheval") == "false";
					$(this).prop("checked",false);
				}
			}
		});
		
	    /* 섹션 */
		// 섹션 설정
		$('#'+objId).on('click','#btnSecFunc',function(){
		  	$(this).siblings(".column_menu").toggleClass("active");
		});
		
		//섹션 삭제
	    $('#'+objId).on('click','#btnSecDel',function(){
	    	$(this).closest('.column_menu').removeClass('active');
	    	
	    	if ($(this).closest('.column').find('.card').size()>0){
	    		alert(mobile_comm_getDic("msg_apv_existFolder")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
	    		return;
	    	}	
	    	
	    	$.ajax({
	    		type:"POST",
	    		data:{"sectionSeq":  $(this).data("seq")},
	    		url:"/groupware/collabProject/deleteProjectSection.do",
	    		success:function (data) {
	    			mobile_collab_project.refresh();
	    		},
	    		error:function (request,status,error){
	    			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	    		}
	    	});
	    });
	    
	    //섹션 추가
	    $('#'+objId).on('click','#btnAddSection',function(){
			$("#collab_main_btnExmenu").trigger("click");
	    	$("body").append( $("<div>",{ id : "_popup" }) );
    		$( "#_popup" ).load( "/groupware/mobile/collab/popSection.do #collab_addSectionPop",function(){
    		    //섹션 추가 팝업 - 확인
    		    $(".btn_confirm",this).on('click', function(){
    		    	if($("#collab_sectionName").val()){
    		    		var callbackParam = {};
			    		var aData = mobile_collab_project_param.get();
						$.ajax({
							type:"POST",
							data:{"prjSeq":aData.prjSeq, "prjType":aData.prjType, "sectionName":$("#collab_sectionName").val()},
							url:"/groupware/collabProject/addProjectSection.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									alert(mobile_comm_getDic("msg_apv_136"));	//복사되었습니다.
									mobile_collab_project.refresh();
									/*
									callbackParam["SectionSeq"]= data.SectionSeq;
									callbackParam["SectionName"]= data.SectionName;
									callbackParam["Count"]= "0";
									
									//섹션 추가
									$('#collab_main_content_container .row').append(drawSection(callbackParam));
									*/
									$("#_popup .btn_close").trigger("click");
								}
								else{
									switch (data.code){
										case "DUP":
											alert(mobile_comm_getDic("lbl_Mail_DuplicationWords")); //	중복
											break;
										default:
											alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
									}
								}
							},
							error:function (request,status,error){
								alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error); 
							}
						});
    		    	} else {
    		    		alert(mobile_comm_getDic("msg_chk_sectionName")); // 섹션명을 입력해주세요
    		    	}
    			});
    		    
    		    //섹션 추가 팝업 - 취소
    		    $(".btn_close",this).on('click',function(){ this.remove(); }.bind($(this)));
    		    
    		});
	    });
	    
	    //섹션명 변경
	    $('#'+objId).on('click','#btnSecChg',function(){
	    	$(this).closest('.column_menu').removeClass('active');
	    	var sectionSeq = $(this).data("seq");
	    	var sectionName = $(this).closest(".column_menu").siblings(".column_tit").text();
	    	$("body").append( $("<div>",{ id : "_popup" }) );
    		$( "#_popup" ).load( "/groupware/mobile/collab/popSection.do #collab_addSectionPop",function(){
    	    	$("#collab_sectionSeq").val(sectionSeq);
    	    	$("#collab_sectionName").val(sectionName);

    		    //섹션 추가 팝업 - 확인
    		    $("#collab_addSectionPop .btn_confirm").on('click', function(){
    		    	if($("#collab_sectionName").val()){
    		    		var callbackParam = {};
			    		$.ajax({
							type:"POST",
							data:{"sectionSeq":$("#collab_sectionSeq").val(), "sectionName":  $("#collab_sectionName").val()},
							url:"/groupware/collabProject/saveProjectSection.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									alert(mobile_comm_getDic("msg_com_processSuccess"));	//복사되었습니다.
									
									//섹션명변경
									$('#section_'+data.SectionSeq+' .column_tit').text(data.SectionName);
									$("#_popup .btn_close").trigger("click");
								}
								else{
									switch (data.code){
										case "DUP":
											alert(mobile_comm_getDic("lbl_Mail_DuplicationWords")); //	중복
											break;
										default:
											alert(mobile_comm_getDic("msg_ErrorOccurred"));  //	오류가 발생했습니다. 관리자에게 문의바랍니다
									}
									
								}
							},
							error:function (request,status,error){
								alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error); 
							}
						});
    		    	} else {
    		    		alert(mobile_comm_getDic("msg_chk_sectionName")); // 섹션명을 입력해주세요
    		    	}
    			});
    		    
    		    //섹션 추가 팝업 - 취소
    		    $(".btn_close",this).on('click',function(){ this.remove(); }.bind($(this)));
    		    
    		});
	    });

		//진행중
		$(document).on("click", "#collab_main_procCnt", function (e) {
			if(mobile_move_flag()){	//중복방지
				if(project.viewMode == "CAL"){
					var startDateObj = new Date($("#collab_main_page .calendar_ctrl .title").text());
		    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
		    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
		    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
			
					mobile_collab_project.set({"cal_sdate":sDate,"cal_edate":eDate, "subMode": "month", "tagval":"ProcTask"});
				}else if(project.viewMode == "GANT"){
					$("#collab_main_content_container .row .gannt-container").remove();
				}
				getTagTask(this,"TAG","ProcTask", mobile_collab_project_param.get());
			}
		});
		//전체업무
		$(document).on("click", "#collab_main_proctotCnt", function (e) {
			if(mobile_move_flag()){	//중복방지
				if(project.viewMode == "CAL"){
					var startDateObj = new Date($("#collab_main_page .calendar_ctrl .title").text());
		    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
		    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
		    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
					
					mobile_collab_project.set({"cal_sdate":sDate,"cal_edate":eDate, "subMode": "month", "tagval":""});
				}else if(project.viewMode == "GANT"){
					$("#collab_main_content_container .row .gannt-container").remove();
				}
				getTagTask(this,"","", mobile_collab_project_param.get());
			}
		});
		//지연
		$(document).on("click", "#collab_main_delayCnt", function (e) {
			if(mobile_move_flag()){	//중복방지
				if(project.viewMode == "CAL"){
					var startDateObj = new Date($("#collab_main_page .calendar_ctrl .title").text());
		    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
		    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
		    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
			
					mobile_collab_project.set({"cal_sdate":sDate,"cal_edate":eDate, "subMode": "month", "tagval":"DelayTask"});
				}else if(project.viewMode == "GANT"){
					$("#collab_main_content_container .row .gannt-container").remove();
				}
				getTagTask(this,"TAG","DelayTask", mobile_collab_project_param.get());
			}
		}); 		
		//중요
		$(document).on("click", "#collab_main_impCnt", function (e) {
			if(mobile_move_flag()){	//중복방지
				if(project.viewMode == "CAL"){
					var startDateObj = new Date($("#collab_main_page .calendar_ctrl .title").text());
		    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
		    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
		    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
			
					mobile_collab_project.set({"cal_sdate":sDate,"cal_edate":eDate, "subMode": "month", "tagval":"ImpTask"});
				}else if(project.viewMode == "GANT"){
					$("#collab_main_content_container .row .gannt-container").remove();
				}
				getTagTask(this,"TAG","LvlHTask", mobile_collab_project_param.get());
			}
		}); 		
		//완료
		$(document).on("click", "#collab_main_CompCnt", function (e) {
			if(mobile_move_flag()){	//중복방지
				if(project.viewMode == "CAL"){
					var startDateObj = new Date($("#collab_main_page .calendar_ctrl .title").text());
		    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
		    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
		    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
			
					mobile_collab_project.set({"cal_sdate":sDate,"cal_edate":eDate, "subMode": "month", "tagval":"CompTask"});
				}else if(project.viewMode == "GANT"){
					$("#collab_main_content_container .row .gannt-container").remove();
				}
				getTagTask(this,"TAG","CompTask", mobile_collab_project_param.get());
			}
		});
	    
	  	/* 프로젝트 리스트형 */
		$('#'+objId).on('click','.list_header .column_tit',function(){
			$(this).parent('.list_header').toggleClass('active');
			$(this).parent().parent('.column').toggleClass('active');
		});
		
		$('#'+objId).on('click','.listBox.deps',function(){
			$(this).toggleClass('active');
			$(this).parent().find('.listBox.sub').toggleClass('active');
		});

		/* 캘린더(일정,스케줄) */
		$('#'+objId).on('click','.calSelect li',function(){
		    var tab = $(this).attr('data-tab');
		    $(this).parent().find("li").removeClass('selected');
			$(this).addClass('selected');
			mobile_collab_project.set({"cal_tab": tab});
			var stndDay = new Date($("#"+objId+" .calendar_ctrl .title").text());
			stndDay.setDate(1);
			changeCalendar(mobile_comm_getDateTimeString("yyyy-MM-dd",stndDay), project.viewMode);
		});
				
		//이전
		$('#'+objId).on('click','.calendar_ctrl .pre', function(e){
			var startDateObj = new Date($("#"+objId+" .calendar_ctrl .title").text());
			startDateObj.setMonth(startDateObj.getMonth()-1);
			startDateObj.setDate(1);
			
			changeCalendar(mobile_comm_getDateTimeString("yyyy-MM-dd",startDateObj), project.viewMode);
		});

		//이후
		$('#'+objId).on('click','.calendar_ctrl .next', function(e){
			var startDateObj = new Date($("#"+objId+" .calendar_ctrl .title").text());
			startDateObj.setMonth(startDateObj.getMonth()+1);
			startDateObj.setDate(1);
			
			changeCalendar(mobile_comm_getDateTimeString("yyyy-MM-dd",startDateObj), project.viewMode);
		});
		
		//오늘
		$('#'+objId).on('click','.calendar_ctrl .calendartoday', function(e){
			changeCalendar(CFN_GetLocalCurrentDate("yyyy-MM-dd"), project.viewMode);
		});

		//일정
		$("#" + objId).on("click", 'table.calendar .has_sch a', function(){
			if($(this).attr("schday")){
				var tagval = mobile_collab_project.get().tagval;
				
				$("#" + objId +" .row table.calendar").find("td").removeClass("active");
				$(this).parent().addClass("active");
				
				getMonthEventDataList($(this).attr("schday"), tagval);
			}
		});
		
		/* 파일, 관련결재, 설문 - 리스트 & 칸반형 전환  */
		$('#'+objId).on('click','.Project_btn li',function(){
		    var tab_id = $(this).attr('data-tab');
	
		    $('.Project_btn li').removeClass('selected');
		    $('.ProjectList').removeClass('selected');
	
		    $(this).addClass('selected');
		    $("." + tab_id).addClass('selected');
		});
		
		/* 확장 메뉴 */
		// 프로젝트 복사
		$('#'+objId).on('click', '#btnCopy', function(){
			$("#collab_main_btnExmenu").trigger("click");
			$("body").append( $("<div>",{ id : "_popup" }).append(
					$("<div>", {"class" : "mobile_popup_wrap"}).append(
						$("<div>", {"class" : "card_list_popup collabo_pop"}).css({"height":"150px", "top":"calc(50%-75px)"})
						.append($("<div>", {"class" : "card_list_popup_cont"})
								.append($("<div>", {"class" : "card_list_title"}).append($("<strong>", {"class" : "tit"}).text(mobile_comm_getDic("msg_chk_projectName")))) //"프로젝트 이름을 입력해주세요"
								.append($("<div>", {"class" : "card_list_cont"}).append($("<input>", {"type" : "text", "id" : "collab_pop_prjName"})))
								.append($("<div>", {"class" : "mobile_popup_btn"})
										.append($("<a>", {"class" : "g_btn03 ui-link btn_copy"}).text(mobile_comm_getDic("btn_Copy"))) //"복사"
										.append($("<a>", {"class" : "g_btn04 ui-link btn_close"}).text(mobile_comm_getDic("btn_Cancel")).css("margin-left","5px"))) //"취소"
								))));
			
			$("#_popup").on("click", ".btn_copy", function(){
				if ($.trim($("#collab_pop_prjName").val()) == ""){
					alert(mobile_comm_getDic("ACC_028")); //근무제명 넣기
					return false;
				}
				
				if(confirm(mobile_comm_getDic("msg_RUCopy"))){
					$.ajax({
						type:"POST",
						data:{"orgPrjSeq":mobile_collab_project_param.get().prjSeq, "prjName":  $("#collab_pop_prjName").val(), "prjType":mobile_collab_project_param.get().prjType},
						url:"/groupware/collabProject/copyProject.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								alert(mobile_comm_getDic("msg_apv_510")); //복사되었습니다.
								collabMobile.MenuList();
								$("#_popup .btn_close").trigger("click");
							}
							else{
								alert(mobile_comm_getDic("msg_ErrorOccurred") + data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (request,status,error){
							alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
						}
					});
				}
			});
			$("#_popup").on("click", ".btn_close", function(){
				$("#_popup").remove();
			});
		});
		
		// 프로젝트 삭제
		$('#'+objId).on('click', '#btnDel', function(){
			$("#collab_main_btnExmenu").trigger("click");
			if(confirm(mobile_comm_getDic("msg_RUDelete"))){
				$.ajax({
            		type:"POST",
            		data:{"prjSeq":  mobile_collab_project_param.get().prjSeq},
            		url:"/groupware/collabProject/deleteProject.do",
            		success:function (data) {
            			if(data.status == "SUCCESS"){
            				alert(mobile_comm_getDic("msg_com_processSuccess"));
            				mobile_comm_go('/groupware/mobile/collab/portal.do');
            			}
            			else{
            				alert(mobile_comm_getDic("msg_ErrorOccurred") + data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
            			}
            		},
            		error:function (request,status,error){
            			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            		}
            	});
			}
		});
		
		// 프로젝트 상세
		$('#'+objId).on('click', '#btnDetail', function(){
			$("#collab_main_btnExmenu").trigger("click");
			var sUrl = "/groupware/mobile/collab/popProject.do"
				+ "?mode=mod" + "&prjSeq=" + mobile_collab_project_param.get().prjSeq;
			mobile_comm_go(sUrl, "Y");
		});

		// 템플릿으로 저장
		$('#'+objId).on('click', '#btnSaveTempl', function(){
			$("#collab_main_btnExmenu").trigger("click");

			$("body").append( $("<div>",{ id : "_popup" }) );
    		$( "#_popup" ).load( "/groupware/mobile/collab/popTemplateAdd.do #collab_templateAdd_popup",function(){
    	    	$('#collab_templateAdd_tmplKind').append(mobile_comm_getBaseCode("COLLAB_KIND").CacheData.map(function(item,idx){return $("<option>",{ text : item.CodeName, value : item.Code })}));

    			$("#collab_templateAdd_add",this).on('click',function(){    				
    				$.ajax({
						type:"POST",
						data:{"prjSeq":mobile_collab_project_param.get().prjSeq,"requestTitle":$("#collab_templateAdd_requestTitle").val(),"tmplKind":$("#collab_templateAdd_tmplKind").val(), "requestRemark":  $("#collab_templateAdd_requestRemark").val()},
						url:"/groupware/collabProject/addProjectTmpl.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								alert(mobile_comm_getDic("msg_apv_136")); //성공적으로 생성되었습니다.
								//$("#collab_template_close").trigger("click");
								$( "#_popup" ).remove();
							}

						},
						error:function (request,status,error){
							alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
						}
					});
    			});
    			$("#collab_templateAdd_close",this).on('click',function(){ this.remove(); }.bind($(this)));
    		});
		});
			    
	    mobile_collab_projectTask.taskRegEvent();
	    mobile_collab_taskDetail.addEvent();
	    
	}
	
	this.setExMenu = function(){
		var aData = mobile_collab_project_param.get();
		$("#collab_main_ulBtnArea").find("li[data-only]").hide();
		
		if(project.prjAdmin == "Y" && aData.prjType != undefined && aData.prjType != "undefined" && aData.prjType != ""){
			$("#collab_main_page").find(".dropMenu").show();
			$("#collab_main_ulBtnArea").find("li[data-only='" + aData.prjType + "']").show();
		} else {
			$("#collab_main_page").find(".dropMenu").hide();			
		}
	}
	
	var getProjectMain = function(){
		var aData = mobile_collab_project_param.get();
		$('#sectionSel').empty();
		$.ajax({
    		type:"POST",
    		data:{"prjSeq": aData.prjSeq, "prjType": aData.prjType},
    		url:"/groupware/collabProject/getProjectMain.do",
    		success:function (data) {
    			if(data.status == "SUCCESS") {
	   				mobile_collab_projectTask.drawSectionList(data);
	   				loadProjectMain(aData, data);
    			} else {
    				alert(mobile_comm_getDic("msg_ErrorOccurred"));
    			}
    		},
    		error:function (request,status,error){
    			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    		}
    	});
	}
	
	var getTodoMain = function(){
		var aData = mobile_collab_project_param.get();
        $.ajax({
            type : "POST",
			data:{"prjType": aData.prjType
		    			,"prjSeq": aData.prjSeq
	        			,"tagSeq":aData.SectionSeq
						,"tagVal":aData.tagval
						,"tagType":aData.tagtype},
            url : "/groupware/collab/todo/myTaskList.do",
            success : function(res){
            	loadTodoMain(aData, res);
            },
            error : function(XMLHttpRequest, textStatus, errorThrown){ // 비동기 통신이 실패할경우 error 콜백으로 들어옵니다.
            	alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            }
        });
	}
	
	var loadProjectMain = function(aData, data){
		var procCnt = data.prjStat.ProcCnt || 0;
		var delayCnt = data.prjStat.DelayCnt || 0;
		var impCnt = data.prjStat.LvlHCnt || 0;
		var compCnt = data.prjStat.CompCnt || 0;
		var emgCnt = data.prjStat.EmgCnt || 0;
		var totCnt = data.prjStat.TotCnt || 0;
		var nowCompCnt = data.prjStat.NowCompCnt || 0;
		var nowTotCnt = data.prjStat.NowTotCnt || 0;
		var prjAdmin = data.prjAdmin;
		var procRate = 0;
		var deg = 0;
		
		if(aData.prjType == "P"){
			procRate = Math.round(data.prjData.ProgRate*10)/10 || 0;
		} else {
			procRate = Math.round(nowCompCnt/nowTotCnt*100);
		}
		if(isNaN(procRate)) procRate = 0;
		
		$.extend(project, {prjColor:data.prjData.PrjColor || "",prjAdmin:prjAdmin});
		mobile_collab_project.setExMenu();
		
		if(procRate >= 50){
			deg = 540 - (360 * procRate / 100);
			$("#slice .fill").css("transform",'rotate('+deg+'deg)');
			
		} else {
			deg = 360 - (360 * procRate / 100);
			$("#slice .fill").css({"transform":'rotate('+deg+'deg)', "border-color": "#dfe0e6"});
		}
		
		$("#collab_main_header_name").text(data.prjData.PrjName);
		$("#collab_main_procCnt, #collab_main_popup_procCnt").text(procCnt);
		$("#collab_main_proctotCnt, #collab_main_popup_proctotCnt").text(totCnt);
		$("#collab_main_delayCnt, #collab_main_popup_delayCnt").text(delayCnt);
		$("#collab_main_impCnt, #collab_main_popup_impCnt").text(impCnt);
		$("#collab_main_CompCnt, #collab_main_popup_CompCnt").text(compCnt);
		$("#collab_main_progRate, #collab_main_popup_progRate").text(procRate);
		$("#collab_main_popup_emgCnt").text(emgCnt);
		$("#collab_main_content_container").data({"prjName":data.prjData.PrjName});
		
		if(data.taskFilter.length > 0){
			
			//섹션 추가
			$('#collab_main_content_container .row').append(
				data.taskData.map( function( item,idx ){	
					return drawSection(item);
				})
			);
		}
		
		//타스크 목록
		for (var i = 0; i< data.taskData.length; i++){		
			
			if(data.taskData[i].list.length > 0){
				data.taskData[i].list.map( function( item,idx ){
					
					var parentSelector = "#collab_main_content_container .row #section_"+item.SectionSeq;
					if(project.viewMode == "LIST"){
						parentSelector = parentSelector + " .listBox_area";
					}
					$(parentSelector).append(drawTask(item, "", project.viewMode));
				});
			} else {
				if(data.taskFilter.length == 0){
					$("#collab_main_content_container").removeClass().addClass("nodata_type03")
						.prepend($("<div>").append($("<span>", {"class":"no_icon no_icon03"}))
								.append($("<p>").text(mobile_comm_getDic("msg_noTask")))); //"등록된 업무가 없습니다."
				}
			}
		}
		
		$(data.sectionList).each(function(idx, item) {
    		$("#section_" + item.SectionSeq + " .column_num").text($("#section_" + item.SectionSeq +" .card").length);
    	});
		
	    $("input[type='checkbox']").checkboxradio();
	    
		//칸반보드 드래그
		if(data.prjAdmin == 'Y'){
		$('#collab_main_content_container .row .column').sortable({
		    connectWith: ".column",
		    //items: ".card:not(.card_header)",
			handle: '.handle',
		    cancel: ".no-move",
		    placeholder: "card_placeholder",
	    	start: function(event, ui) {
	            ui.item.data('start_pos', ui.item.index());
	        },
	        stop: function(event, ui) {
	        	var ordTaskArr = new Array();
	        	var idx = ui.item.index();
	        	var workOrder = 0;
	        	var sectionSeq = ui.item.parents(".column").data("SectionSeq");
	        	
	        	for (var i = 0; i< $("#section_"+sectionSeq + " .card_cont").length; i++){
	        		ordTaskArr.push({ "taskSeq":$("#section_"+sectionSeq + " .card_cont").eq(i).data("taskSeq"), "workOrder":workOrder++});
	        	}

	            $.ajax({
	            	type:"POST",
		        	contentType:'application/json; charset=utf-8',
		    		dataType   : 'json',
		    		data:JSON.stringify({"taskSeq": ui.item.find(".card_cont").data("taskSeq")
		    			,"prjType": aData.prjType
		    			,"prjSeq": aData.prjSeq
	        			,"sectionSeq":sectionSeq
	        			,"workOrder":workOrder
	        			,"ordTask":ordTaskArr}),
	        		url:"/groupware/collabTask/changeProjectTaskOrder.do",
	        		success:function (data) {
	        		},
	        		error:function (request,status,error){
	        			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	        		}
	        	});
			}
		});
		}
	}
	
	var getTagTask = function(obj, v, t, aData){
		var objId = $(obj).attr("id");
		var params = $("#"+objId).data();

		params["tagtype"]=v;
		params["tagval"]=t;
		params["myTodo"]=aData.myTodo;
		params["prjType"]=aData.prjType;
		params["prjSeq"]=aData.prjSeq;
		
		var sdate = null;
		var edate = null;
		
		switch (project.viewMode){	
			case "GANT":
				sdate = mobile_collab_project.get().gant_sdate;
				edate = mobile_collab_project.get().gant_edate;
				break;
			case "CAL":
				sdate = mobile_collab_project.get().cal_sdate;
				edate = mobile_collab_project.get().cal_edate;
				break;
			default	:
				sdate = "";
				edate = "";
		}
		
		params["date1"] = sdate;
		params["date2"] = edate;
		
		searchTag(params, function (res) {
			loadMyTask("collab_main_content_container", res, aData.myTodo, sdate, edate);
		});
	}
	
	var searchTag = function(params, callback){
          $.ajax({
              type : "POST",
              url : "/groupware/collabProject/getMyTask.do",
              data : params,
              success : function(res){
                  if(res.result == 'ok'){
                	  return callback(res);
                  }
              },
              error : function(request,status,error){ // 비동기 통신이 실패할경우 error 콜백으로 들어옵니다.
                  alert("통신 실패.")
              }
          });
     }
     	
	var loadTodoMain = function(aData, data) {
		var procCnt = data.taskStat.ProcCnt || 0;
		var delayCnt = data.taskStat.DelayCnt || 0;
		var impCnt = data.taskStat.LvlHCnt || 0;
		var compCnt = data.taskStat.CompCnt || 0;
		var emgCnt = data.taskStat.EmgCnt || 0;
		var totCnt = data.taskStat.TotCnt || 0;
		var nowCompCnt = data.taskStat.NowCompCnt || 0;
		var nowTotCnt = data.taskStat.NowTotCnt || 0;
		var prjAdmin = "N";
		var procRate = 0;
		var deg = 0;
		
		$.extend(project, {prjAdmin:prjAdmin});
		mobile_collab_project.setExMenu();
		
		procRate = Math.round(nowCompCnt/nowTotCnt*100);
		if(isNaN(procRate)) procRate = 0;
		
		if(procRate >= 50){
			deg = 540 - (360 * procRate / 100);
			$("#slice .fill").css("transform",'rotate('+deg+'deg)');
		} else {
			deg = 360 - (360 * procRate / 100);
			$("#slice .fill").css({"transform":'rotate('+deg+'deg)', "border-color": "#dfe0e6"});
		}
		
		$("#collab_main_header_name").text(mobile_comm_getDic("lbl_MyWork"));
		$("#collab_main_procCnt, #collab_main_popup_procCnt").text(procCnt);
		$("#collab_main_proctotCnt, #collab_main_popup_proctotCnt").text(totCnt);
		$("#collab_main_delayCnt, #collab_main_popup_delayCnt").text(delayCnt);
		$("#collab_main_impCnt, #collab_main_popup_impCnt").text(impCnt);
		$("#collab_main_CompCnt, #collab_main_popup_CompCnt").text(compCnt);
		$("#collab_main_progRate, #collab_main_popup_progRate").text(procRate);
		$("#collab_main_popup_emgCnt").text(emgCnt);
		
		// Todo 섹션 추가
		var arrTodoSection = [{SectionSeq : 'W', SectionName : mobile_comm_getDic("lbl_Ready")/*대기*/}, {SectionSeq : 'P', SectionName : mobile_comm_getDic("lbl_Progress")/*"진행"*/}, {SectionSeq : 'H', SectionName : mobile_comm_getDic("lbl_Hold")/*"보류"*/}, {SectionSeq : 'C', SectionName : mobile_comm_getDic("lbl_Completed")/*"완료"*/}];
		$(arrTodoSection).each(function(idx, item) { 
			var sectionObj = $("<div>",{"class" : "column", "id" : "myTask_"+item.SectionSeq , "data-status" : item.SectionSeq})
					.append($("<div>",{"class":(project.viewMode == "LIST") ? "list_header" : "card_header"})	
							.append($("<h3>",{"class" : "column_tit", "text":item.SectionName}))
							.append($("<strong>",{"class" : "column_num"})));
			if(project.viewMode == "LIST")
				sectionObj = sectionObj.append($("<div>", {"class":"listBox_area"}));
			
			$("#collab_main_content_container .row").append(sectionObj);
		});
		
		var viewMode = (project["viewMode"] == undefined) ? data["viewMode"] : project["viewMode"];
		
		//타스크 목록
		for (var i = 0; i< data.taskData.length; i++){
			data.taskData[i].list.map( function( item,idx ){
				if(project.viewMode == "LIST")
					$('#myTask_'+(item.TaskStatus==null?"W":item.TaskStatus)+' .listBox_area').append(drawTask(item,"TODO", viewMode));
				else
					$('#myTask_'+(item.TaskStatus==null?"W":item.TaskStatus)).append(drawTask(item,"TODO", viewMode));
			});
		}
		
    	$(arrTodoSection).each(function(idx, item) {
    		$("#myTask_" + item.SectionSeq + " .column_num").text($("#myTask_" + item.SectionSeq +" .card").length);
    	});

	    $("input[type='checkbox']").checkboxradio();
      	
        //상태변경 
        $("#collab_main_content_container .row .column").sortable({
		    connectWith: ".column",
		    //items: ".card:not(.card_header)",
			handle: '.handle',
		    cancel: ".no-move",
		    placeholder: "card_placeholder",
	    	start: function(event, ui) {
	            ui.item.data('start_pos', ui.item.index());
	        },
	        stop: function(event, ui) {
            	var ordTaskArr = new Array();
	        	var idx = ui.item.index();
	        	var todoOrder = 0;
	        	var taskStatus = ui.item.parents(".column").data("status");
	        	
	        	for (var i = 0; i< $("#myTask_"+taskStatus + " .card_cont").length; i++){
	        		ordTaskArr.push({ "taskSeq":$("#myTask_"+taskStatus + " .card_cont").eq(i).data("taskSeq"), "todoOrder":todoOrder++});
	        	}
	        	
   	            $.ajax({
	            	type:"POST",
		        	contentType:'application/json; charset=utf-8',
		    		dataType   : 'json',
		    		data:JSON.stringify({"taskSeq": ui.item.find(".card_cont").data("taskSeq")
		    			,"prjType": ui.item.find(".card_cont").data("prjType")
		    			,"prjSeq": ui.item.find(".card_cont").data("prjSeq")
	        			,"taskStatus":taskStatus
	        			,"todoOrder":todoOrder
	        			,"ordTask":ordTaskArr}),
	        		url:"/groupware/collabTask/changeProjectTaskTodoOrder.do",
	        		success:function (data) {
	        		},
	        		error:function (request,status,error){
	        			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	        		}
	        	});
            }
        });
	}
	
	// Section
	var drawSection = function(data){
		var returnSectionObj;
		
		switch(project.viewMode){
			case "LIST" : //리스트형
			returnSectionObj = $("<div>",{ "class" : "column", "id":"section_"+data.key.SectionSeq }).data({"SectionSeq":data.key.SectionSeq})
				.append($("<div>", {"class":"list_header"})	
						.append($("<h3>",{ "class" : "column_tit" , "text":data.key.SectionName}))
						.append($("<strong>",{ "class" : "column_num", "text":data.list.length}))
						.append(project.prjAdmin=="Y"?$("<a>",{ "class" : "column_btn", "id":"btnSecFunc"}).data( "seq",data.key.SectionSeq):"")
						.append($("<div>",{ "class" : "column_menu"})
									.append($("<a>",{"text":mobile_comm_getDic("WH_rename"),"id":"btnSecChg"}).data( "seq",data.key.SectionSeq))
									.append($("<a>",{"text":mobile_comm_getDic("lbl_delete"),"id":"btnSecDel"}).data( "seq",data.key.SectionSeq))
						))
				.append($("<div>", {"class":"listBox_area"}));
			break;
			case "CAL" : //캘린더형
				returnSectionObj = "";
				break;
			default:
				returnSectionObj = $("<div>",{ "class" : "column", "id":"section_"+data.key.SectionSeq }).data({"SectionSeq":data.key.SectionSeq})
					.append($("<div>", {"class":"card_header"})	
					.append($("<h3>",{ "class" : "column_tit" , "text":data.key.SectionName}))
					.append($("<strong>",{ "class" : "column_num", "text":data.list.length}))
					.append(project.prjAdmin=="Y"?$("<a>",{ "class" : "column_btn", "id":"btnSecFunc"}).data("seq",data.key.SectionSeq):"")
					.append($("<div>",{ "class" : "column_menu"})
					.append($("<a>",{"text":mobile_comm_getDic("WH_rename"),"id":"btnSecChg"}).data( "seq",data.key.SectionSeq))
					.append($("<a>",{"text":mobile_comm_getDic("lbl_delete"),"id":"btnSecDel"}).data( "seq",data.key.SectionSeq)))
				);
			break;
		}
		return returnSectionObj;
	}
	
	var changeDisplayMode = function(){
		var objId = "collab_main_content_container";
		var bSearchBtnShow = true;
		$("#" + objId).empty().append($("<div>", {"class":"row"})).removeClass();
		$("#collab_main_content").removeClass("file approval survey");
		switch (project.viewMode){
    		case "CAL":
    			var stndDay = CFN_GetLocalCurrentDate("yyyy-MM-dd");
    			changeCalendar(stndDay, "CAL");
    			break;
			case "GANT":
    			var stndDay = CFN_GetLocalCurrentDate("yyyy-MM-dd");
    			changeCalendar(stndDay, "GANT");
    			break;
        	case "LIST"://리스트형
        		$("#" + objId).addClass("list-fluid");
            	break;
        	default:
        		switch(project.dataType){
        		case "FILE":
        		case "APPROVAL":
        		case "SURVEY":
        			bSearchBtnShow = false;
        			$("#collab_main_content").addClass(project.dataType.toLowerCase());
	        		break;
        		default:
            		$("#" + objId).addClass("container-fluid card-fluid");
        			break;
        		}
            	break;
    	}
		if(bSearchBtnShow)
        	$("#collab_main_page .btn_search").show();
		else
			$("#collab_main_page .btn_search").hide();
		
		if(mobile_collab_project_param.get().myTodo == "Y"){
        	$("#taskAddPop #sectionSel").hide();
        	$("#taskAddPop #sectionSelSpan").hide();
        	$("#taskAddPop #sectionSel").val("");
		} else {
			$("#taskAddPop #sectionSel").show();
        	$("#taskAddPop #sectionSelSpan").show();
		}
	}
	
	// Task
	var drawTask = function(item, type, viewMode){
		var obj;
		var cardData ={"taskSeq":item.TaskSeq, "prjSeq":item.PrjSeq, "prjType":item.PrjType};
		item.PrjName =(item.PrjType=="P"?"Project":(item.PrjType!="" && item.PrjType != undefined?"Team":"My"));
		
		if (type == "TODO"){
			if (item.PrjDesc != null){
				var aData = item.PrjDesc.split("^");
				if (aData.length>0){
					item.PrjType  =  aData[0];
					item.PrjName = aData[1];
				}
			}	
		}
		
		var aUsers = [];
		var aUserInfo = [];
		if(item.tmUser) {
			aUsers = item.tmUser.split('|');
			if (aUsers.length>0){
				aUserInfo = aUsers[0].split('^');
			}
		}
		
		switch (viewMode){
			case "CAL":
				obj = $("<a>",{"class":"coWorkBox","id":"cardTitle"}).data(cardData)
					.append(aUsers.length>0?collabMobile.drawProfile({"code":aUserInfo[0],"type":"U","DisplayName":aUserInfo[1], "PhotoPath":aUserInfo[2]}, false):"")
					.append($("<span>",{"class":"tx_title"}).text(item.TaskName+"("+item.StartDate+"~"+item.EndDate+")"))
					.append(item.PCnt>0?$("<span>",{"class":"card_share"}).text(item.PCnt):"")
					;
				break;
			case "LIST":
				obj= $("<div>", {"class" : "listBox_list"})
					.append($("<div>",{ "class" : "card listBox "+(item.PrjType=="P"?"type01":"type02")+(item.IsDelay == 'Y'?' card_delay':'') +(item.TaskStatus=='C'?' card_complete':'')})
					.append($("<div>",{ "class" : "list_l"})
					.append($("<div>",{"class":"list_chk"})
					.append($("<input>",{ "type" : "checkbox", "id":"chk_"+item.TaskSeq, "checked":(item.TaskStatus=="C"?true:false)}).data( cardData))	
					.append($("<label>",{ "class" : "checkbox", "for":"chk_"+item.TaskSeq})	
					.append($("<span>",{ "class" : "s_check"}))))
					.append($("<strong>",{ "class" : "list_type"}).text(item.PrjName))
					.append($("<strong>",{ "class" : "list_tit card_title"}).text(item.TaskName).data(cardData)))
					.append($("<div>",{ "class" : "list_r"})
					.append($("<span>",{ "class" : "user_date"}).text(collabMobile.displayDday(item)))
					).append($("<a>",{"class": "btn_arrow_c ui-link"}).data(cardData))
					);
				break;
			default:
				obj= $("<div>",{ "class" : "card "+(item.PrjType=="P"?"type02":"type01")+(item.FileName != null?" card_pic":"")})
					.append($("<div>",{ "class" : "card_cont"+(item.IsDelay == 'Y'?' card_delay':'') +(item.TaskStatus=='C'?' card_complete':'')}).data(cardData)
					//.append(item.FileName != null?$("<div>",{"class":"card_img"}).append($("<img>",{"src":mobile_comm_getImgFilePath("Collab", item.FilePath, item.SavedName)})):"")	
					.append(item.FileName != null?$("<div>",{"class":"card_img"}).append($("<img>",{"src":mobile_comm_getImgById("", item.FileID)})):"")
					.append($("<div>",{ "class" : "card_top"})
					.append(type=="TODO"||project.prjAdmin=="Y"?$("<span>",{ "class" : "ui-icon ui-icon-arrow-4 handle"}):"")
					.append($("<strong>",{ "class" : "card_type"}).text(item.PrjName))
					.append($("<span>",{ "class" : "card_dday"}).text(collabMobile.displayDday(item)))
					.append($("<div>",{ "class" : "card_chk01"})
					.append($("<input>",{ "type" : "checkbox", "id":"chk_"+item.TaskSeq, "checked":(item.TaskStatus=="C"?true:false)}).data(cardData))	
					.append($("<label>",{ "class" : "checkbox", "for":"chk_"+item.TaskSeq})	
					.append($("<span>",{ "class" : "s_check"})))))
					.append($("<a>",{"id":"cardTitle"}).data(cardData)
					.append($("<strong>",{ "class" : "card_title "+(item.Label=="I"?"card_important":(item.Label=="E"?"card_urgent":""))}).text(item.TaskName).data(cardData))
					.append($("<div>",{"class":"card_info"})
					.append($("<a>",{"class":"card_people"}).text(aUsers.length))
					.append($("<a>",{"class":"card_comment"}).text(item.CommentCnt))
					.append(item.PCnt>0?$("<a>",{"class":"card_share"}).text(item.PCnt):""))			
					.append($("<div>",{"class":"card_progress"})
					.append($("<div>",{"class":"card_pgbox"})
					.append($("<div>",{"class":"card_pgbar", "style":"width:"+(item.ProgRate || 0)+"%"})))
					.append($("<div>",{"class":"card_pgnum"})
					.append($("<span>").text((item.ProgRate || 0)+"%"))))			
					));
				break;
		}
		return obj;
	}
	
	this.getMyTask = function (objectType){
		var aData = mobile_collab_project_param.get();
		var params = {
				"prjSeq": aData.prjSeq
				,"prjType": aData.prjType 
				,"myTodo" : aData.myTodo
				,"searchOption":3
				,"searchWord":$("#collab_main_page #mobile_search_input").val()
				};
		if (objectType != undefined) params["objectType"]=objectType;
		
		if(project.viewMode == 'CAL'){
			params["date1"] = project["cal_sdate"];
			params["date2"] = project["cal_edate"];
		}else if(project.viewMode == 'GANT'){
			params["date1"] = project["gant_sdate"];
			params["date2"] = project["gant_edate"];
		}
		
		if(project.tagval != undefined){
			params["tagtype"] = "TAG";
			params["tagval"] = project["tagval"];
		}
		if (aData.myTodo == "Y"){
			params["mode"] = "STAT";
		}
		
		$.ajax({
    		type:"POST",
    		data:params,
    		url:"/groupware/collabProject/getMyTask.do",
    		success:function (data) {
    			loadMyTask("collab_main_content_container", data, aData.myTodo, params["date1"], params["date2"]);
    		},
    		error:function (request,status,error){
    			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    		}
    	});
	}
	
	var loadMyTask = function(objId, data, myTodo, sdate, edate){

		//타스크 목록
		$('#'+objId+' .row .card').remove();
		var viewMode = (project["viewMode"] == undefined) ? data["viewMode"] : project["viewMode"];
		var searchType = (project["viewMode"] == undefined) ? data["subMode"] : project["subMode"];
		var myTodo = myTodo;
			
		if(viewMode == "GANT"){
			drawGantTask(objId, data.taskData, searchType, myTodo, sdate, edate);
		}else{
			if (viewMode == "CAL"){
				$("#collab_main_content_container div.calendar_detail").empty();
				
				if(mobile_collab_project.get().subMode != "day")
					$("#" + objId).find("table.calendar td").removeClass("has_sch");
			} 
			
			for(var i=0; i<data.taskData.length; i++){
				
				data.taskData[i].list.map(function(item,idx){
					
					if (viewMode == "CAL"){
						drawCalendarTask(objId, item, searchType);
					}else{
						if (myTodo == "Y"){
							var oTasks = drawTask(item, "TODO", viewMode);
							if(viewMode == "LIST"){
								oTasks = $("<div>", {"class" : "listBox_list"}).append(oTasks);
								$('#myTask_'+item.TaskStatus + " .listBox_area").append(oTasks);
							} else {
								$('#myTask_'+item.TaskStatus).append(oTasks);
							}
						}
						else{
							var oTasks = drawTask(item,"",viewMode); 
							
							if(viewMode == "LIST"){
								oTasks = $("<div>", {"class" : "listBox_list"}).append(oTasks);
			    				$('#'+objId+' .row #section_'+item.SectionSeq + " .listBox_area").append(oTasks);
							} else {
			    				$('#'+objId+' .row #section_'+item.SectionSeq).append(oTasks);
			
							}
						}
					}
				});
			}
		}
		
		$("#"+objId + " .column").each(function() {
			$( this ).find(".column_num").text($( this ).find(".card").length);
		});	
		
		$("input[type='checkbox']").checkboxradio();
	}
	
	var saveTaskComplete = function(params, callback){         //완료처리
   		$.ajax({
   			type:"POST",
   			data:params,
   			url:"/groupware/collabTask/changeProjectTaskStatus.do",
   			success:function (res) {
   				return callback(res);
   			},
   			error:function (request,status,error){
   				alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
   			}
   		});
    }
	
	// calendar
	var changeCalendar = function(stndDay, viewMode = "CAL"){
		
		var objId = "collab_main_content_container";
		$('#' + objId + ' .row').empty();
		var aCalData = collabMobile.setCalendar(stndDay, objId, project["cal_tab"], viewMode);

		if(viewMode == "CAL")
			mobile_collab_project.set({"cal_sdate":aCalData["startDate"],"cal_edate":aCalData["endDate"], "subMode": "month"});
		else if(viewMode == "GANT"){
			//$(".gannt-container").attr("style","min-width: 1000px;max-width: 1200px;margin: 1em auto;");
			mobile_collab_project.set({"gant_sdate":aCalData["startDate"],"gant_edate":aCalData["endDate"]});
		}

		mobile_collab_project.getMyTask(project["cal_tab"] == "calSchedule"?"EVENT":"");	
	}
	
	var drawCalendarTask = function(objId, item, searchType){

		var sDate = item.StartDate;
		var eDate = item.EndDate;
		
		var aUsers = [];
		var aUserInfo = [];
		if (item.tmUser){
			aUsers = item.tmUser.split('|');
			if (aUsers.length>0){
				aUserInfo = aUsers[0].split('^');
			}	
		}
		 
		if(searchType == "day"){
			var cardData ={"taskSeq":item.TaskSeq, "prjSeq":item.PrjSeq, "prjType":item.PrjType};
			$("#" + objId).find(".calendar_detail").append(
					$("<div>", {"class": "listBox"})
					.append($("<div>", {"class": "list_l"})
							.append(aUsers.length>0?collabMobile.drawProfile({"code":aUserInfo[0],"type":"U","DisplayName":aUserInfo[1], "PhotoPath":aUserInfo[2]}, false):"")
							.append($("<strong>",{"class":"list_tit"}).text(item.TaskName+"("+item.StartDate+"~"+item.EndDate+")")))
					.append($("<div>", {"class": "list_r"}).append(item.PCnt>0?$("<a>", {"class":"list_share ui-link"}).text(item.PCnt):"")).append($("<a>", {"class": "btn_arrow_c ui-link"}).data(cardData))
			);
		} else {
			var dates = collabMobile.getDates(sDate, eDate);
			$(dates).each(function(idx, date){
				$("#" + objId).find("table.calendar").find("a[schday='"+date+"']").parent().removeClass("has_sch").addClass("has_sch");
			});
		}
	}
	
	var drawGantTask = function(objId, item, searchType, myTodo, sdate, edate){
		
		$("#"+objId+" .row").append($("<div>",{"class": "gannt-container", "style":"min-width: 1000px;max-width: 1200px;margin: 1em auto;"}).append($("<div>",{"id":"gannt_"+objId})));
		
		var startdate = sdate;
		var enddate = edate;
    	var day = 1000 * 60 * 60 * 24;
    	var today   =getUTCTime(startdate);
    	var maxday  =getUTCTime(enddate) ;
    		maxday.setDate(maxday.getDate() + 1);

	    var data = [];
	    var categories = [];
	    var htCat = {}
			
		if(myTodo == "Y"){
			var arrTodoSection = {'W' : mobile_comm_getDic("lbl_Ready")/*대기*/, 'P' : mobile_comm_getDic("lbl_Progress")/*"진행"*/, 'H' : mobile_comm_getDic("lbl_Hold")/*"보류"*/, 'C' : mobile_comm_getDic("lbl_Completed")/*"완료"*/}
			
			var idx = 0;
			for (var key in arrTodoSection) {
				categories.push(arrTodoSection[key]);
				htCat[key]=idx;
				idx++;
			}
			
		}else{
			item.map( function( item, idx ){
				var mapData = item;
				var key = mapData["key"];
				
				categories.push(key["SectionName"]);
				htCat[key["SectionSeq"]]=idx;
			});
				
		}
		$("#"+objId+" .gannt-container").data(htCat);

		var jsonData = item;

	    jsonData.map( function( taskList,idx ){
	    		taskList["list"].map( function( item,idx ){

			    		var startDate = getUTCTime(item.StartDate);
			    		var endDate   = getUTCTime(item.EndDate);
			    		
			    		var startday = startDate < today ? 0:schedule_GetDiffDates (today, startDate,"day");
			    		var endday  = item.StartDate==item.EndDate ? startday+(0.5)
			    					: schedule_GetDiffDates (today, endDate >= maxday ? maxday: endDate,"day")
		  				
						var aUsers = [];
						var aUserInfo = [];
						if (item.tmUser != null){
							aUsers = item.tmUser.split('|');
							if (aUsers.length>0){
								aUserInfo = aUsers[0].split('^');
							}	
						}

						var y = myTodo  == 'Y'?htCat[item.TaskStatus]:htCat[item.SectionSeq];
						y = y ==undefined || y ==""? 0:y;
		
						data.push({"name" : item.TaskName, "id" : "t_"+item.TaskSeq
			    				,"start": today.getTime() + startday * day
			    				,"end": today.getTime() + (endday+1) * day
			    				,"y":y
			    				,"desc":item.StartDate+"~"+item.EndDate
			    				,"dependency": item.LinkTaskSeq!=""?"t_"+item.LinkTaskSeq:""
			    				,"taskSeq": 	item.TaskSeq
			    				,"linkTaskSeq": 	item.LinkTaskSeq
			    				,"objId": 	objId
			    				,"UserCode":aUserInfo[0]
			    				,"UserName":aUserInfo[1]
								,"myTodo":myTodo	
			    				})
			    	});
    		});

    		var chart = new Highcharts.ganttChart("gannt_"+objId, {
         	    chart: {
         	        spacingLeft: 1,
         	        styleMode:true
         	    },
         	    time:{
         	    	timezone:'asia/seoul'
         	    },     
         	    plotOptions: {
         	    	gantt:{
	     	           connectors:{
	     	            	dashStyle:'dash',
	     	            	enabled:true
	     	            }
         	    	},
         	        series: {
         	            animation: true, // Do not animate dependency connectors
         	            dragDrop: {
         	                draggableX: false,
         	                draggableY: false,
         	                dragPrecisionX: day / 3 // Snap to eight hours
         	            },
         	            allowPointSelect: true,
         	            tooltip: {
         	                headerFormat: '<b>{point.name}</b><br>',
         	                pointFormat: '{point.desc}',
         	                clusterFormat: 'Clustered points: {point.clusterPointsAmount}',
         					useHTML:true
         	            },
         	            color:'#9E9E9E',
         	            showCheckbox:true,
         	            point: {
         	                events: {
         	                    select: collabMobile.selectChartPoint,
         	                    drop: false //collabMobile.dropChartPoint,
         	                    
         	                }
         	            }
         	        }
         	    },
         	    xAxis: [{
         	       min: today.getTime() ,
         	       max: maxday.getTime(),
         	       tickInterval:  1000 * 60 * 60 * 24,
         	       labels:{//color: #FF0000;
         	    	   	format:('{value:%w}'=='0' || '{value:%w}'=='6'  )?'<span style="color:red">{value:%w}</span>':'<span>{value:%d}</span>',
         	    	   	showEmpty: true,
         	    	   	useHTML:true
     	    	   },
         	       step:0,
         	       alternateGridColor:'#ebebec',
         	       grid:{
         	    	  borderColor:'#ffffff',
         	    	  borderWidth:0
         	       },
         	       tickPixelInterval: 70
         	    }],
         	    yAxis: {
         	      type: 'category',
         	      categories: categories,
         	      min: 0,
         	      max: categories.length-1,
         	      reversed: true,
         	    },
         	   series: [{type:'gantt',
         		   name: objId,
         		   data:data,
         		   showCheckbox:true,
				   dataLabels: [
						{enabled: true,
					    	useHTML:true,
					    	align:'left',
					    	formatter: function () {
					    		return '<div class="user_img">'
					    			+collabMobile.drawProfile({"code":this.point.UserCode,"type":"","DisplayName":this.point.UserName,"PhotoPath":""}, false, "member").html()+'</div>'
					    			+'<span class="tx_title">' + this.point.name+'</span>';
				
						},
					    	colorByPoint:true},
						{   enabled: true,
							useHTML:true,
							align:'right',
							formatter: function () {
								var project_param = mobile_collab_project_param.get();
								return '<a class="chartTitle"><span style="display:none">'+project_param.prjSeq+','+this.point.taskSeq+'</span>go</a>';
							},
							colorByPoint:true}	
		         	  	]}         	   
         	   	]
         	});

		//간트차트 상세 이벤트
		$('#gannt_collab_main_content_container').on('click','.chartTitle',function(){
			if(mobile_move_flag()){	//중복방지
				var val =  $(this).find("span").text();
				var arrSeq = val.split(',');
		    	collabMobile.openTaskPopup("Y", arrSeq[0], arrSeq[1]);
			}
	    });
	  
	}
	
	var getMonthEventDataList = function(schDay, tagval){
		
		if(tagval != null)
			mobile_collab_project.set({"cal_sdate":schDay,"cal_edate":schDay, "subMode": "day", "tagval":tagval});	//, "tagtype":"TAG"
		else
			mobile_collab_project.set({"cal_sdate":schDay,"cal_edate":schDay, "subMode": "day"});
		
		$("#collab_main_content_container div.calendar_detail").empty()
			.append($("<div>", {"class" : "title clearFloat"}).append($("<h3>").text(schDay)).append($("<span>",{"class":"total"})))
		
		mobile_collab_project.getMyTask(project["cal_tab"] == "calSchedule"?"EVENT":"");
	}
	
	var getMyFile = function (){
		var aData = mobile_collab_project_param.get();
		$.ajax({
    		type:"POST",
    		data:{"prjSeq":  aData.prjSeq, "prjType":  aData.prjType, "myTodo":aData.myTodo
    				, "filterType":"FILE"
    				},
    		url:"/groupware/collabProject/getMyTask.do",
    		success:function (data) {
				loadMyFile(data);
    		},
    		error:function (request,status,error){
    			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    		}
    	});
	}
	
	//file
	var loadMyFile = function(data){
		//header
		$("#collab_main_content_container .row").append($("<div>", {"class":"Project_top"})
				.append($("<h3>", {"class":"title"}).text(mobile_comm_getDic("lbl_File")))//"파일"
				.append((data.taskList.length > 0) ? 
						$("<ul>", {"class":"Project_btn file clearFloat"})
						.append($("<li>", {"class":"btnListView listViewType01 selected", "data-tab":"fileList01"}).text("리스트보기"))
						.append($("<li>", {"class":"btnListView listViewType02", "data-tab":"fileList02"}).text("칸반형보기")) : ""
				));
		if(data.taskList.length > 0){
			$('#collab_main_content_container .row').append($("<div>",{"class":"ProjectList ProjectList01 fileList01 selected"})
					.append($("<table>",{"class": "ProjectListTable"})
					.append($("<tr>")
							.append($("<th>").text(mobile_comm_getDic("lbl_delete"))) // 삭제
							//.append($("<th>").text("중요"))
							.append($("<th>").text(mobile_comm_getDic("lbl_FileName"))) // 파일명
							.append($("<th>").text(mobile_comm_getDic("lbl_Size"))) // 크기
							.append($("<th>").text(mobile_comm_getDic("lbl_RegistDate")))))); // 등록일
	
			$('#collab_main_content_container .row').append($("<div>",{"class":"ProjectList fileList02"})
					.append($("<div>",{"class": "fileList02_div"})));
					
			data.taskList.map( function( item,idx ){
				$('#collab_main_content_container').find(".ProjectListTable")
						.append($("<tr>")
									.append($("<td>",{"class":"file_del"})
											.append((data.authSave == 'Y'  || item.FileRegisterCode == mobile_comm_getSession("USERID"))? $("<a>",{"class":"body_del ui-link"}).data("fileid",item.FileID):""))
									//.append($("<td>",{"class":"file_important"})
									//		.append($("<div>",{"class" : "body_important"}).append($("<a>",{"class":"btn_improtant ui-link"}))))
									.append($("<td>",{"class":"file_title"}).text(item.FileName))
									.append($("<td>",{"class":"file_title"}).text(mobile_comm_convertFileSize(item.Size)))
									.append($("<td>",{"class":"file_title"}).text(item.FileRegistDate))
								);
				
				$('#collab_main_content_container').find(".fileList02_div")
							.append($("<div>",{"class":"WebHardList"})
							//.append($("<div>",{"class":"body_important"})
							//	.append($("<a>",{"class":"btn_improtant ui-link"})))
							.append($("<div>",{"class":"body_category"})
								.append(collabMobile.getFileIcon(item))
								.append($("<a>",{"class":"body_title ui-link"}).text(item.FileName).data({"fileid":item.FileID,"filetoken":item.FileToken}))
								.append($("<p>",{"class":"body_date"}).text(item.FileRegistDate)))
								.append((data.authSave == 'Y'  || item.FileRegisterCode == mobile_comm_getSession("USERID"))?$("<a>",{"class":"body_del ui-link file_del"}).data("fileid",item.FileID):"")
						);
			});
		} else {
			$("#collab_main_content_container .row")
			.append($("<div>", {"class":"nodata_type03"}).append($("<span>", {"class":"no_icon no_icon03"}))
					.append($("<p>").text(mobile_comm_getDic("msg_noTask")))); //"등록된 파일이 없습니다."
		}
	}
	
	//approval
	var getMyApproval = function(){
		loadMyApproval({"list":[]});
	}
	
	var loadMyApproval =  function(data){
		//header
		$("#collab_main_content_container .row").append($("<div>", {"class":"Project_top"})
				.append($("<h3>", {"class":"title"}).text(mobile_comm_getDic("lbl_RelatedApproval"))) // 관련결재
				.append((data.list.length > 0) ? $("<ul>", {"class":"Project_btn approval clearFloat"})
						.append($("<li>", {"class":"btnListView listViewType01 selected", "data-tab":"approvalList01"}).text("리스트보기"))
						.append($("<li>", {"class":"btnListView listViewType02", "data-tab":"approvalList02"}).text("칸반형보기")) : ""
				));
		

		if(data.list.length > 0) {

			$('#collab_main_content_container .row').append($("<div>",{"class":"ProjectList ProjectList01 approvalList01 selected"})
					.append($("<table>",{"class": "ProjectListTable"})
					.append($("<tr>")
							.append($("<th>").text(mobile_comm_getDic("lbl_subject"))) // 제목
							.append($("<th>").text(mobile_comm_getDic("lbl_apv_writer"))) // 기안자
							.append($("<th>").text(mobile_comm_getDic("lbl_apv_reqdate"))) // 기안일
							)));
	
			$('#collab_main_content_container .row').append($("<div>",{"class":"ProjectList approvalList02"})
					.append($("<ul>",{"class": "cards"})));
	
			data.list.map( function( item,idx ){
				
			});
		} else {
			$("#collab_main_content_container .row")
				.append($("<div>", {"class":"nodata_type03"}).append($("<span>", {"class":"no_icon no_icon03"}))
					.append($("<p>").text(mobile_comm_getDic("msg_noApproval")))); //"등록된 결재가 없습니다."
		}
	}
	
	//survey
	var getMySurvey = function(){
		$.ajax({
			type: "POST",
			url: "/groupware/collabProject/getCollabSurveyList.do",
			data:{
				  "prjSeq" : mobile_collab_project_param.get().prjSeq
				, "myTodo" : mobile_collab_project_param.get().myTodo
			},
    		success: function(data){
    			if(data.status == "SUCCESS")
    				loadMySurvey(data);
    			else
    				alert(mobile_comm_getDic("msg_ErrorOccurred"));
    		},
    		error: function(request, status, error){
    			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    		}
    	});
	}
	
	var loadMySurvey =  function(data){
		//header
		$("#collab_main_content_container .row").append($("<div>", {"class":"Project_top"})
				.append($("<h3>", {"class":"title"}).text(mobile_comm_getDic("lbl_Profile_Questions"))) // 설문
				.append((data.list.length > 0) ? $("<ul>", {"class":"Project_btn survey clearFloat"})
						.append($("<li>", {"class":"btnListView listViewType01 selected", "data-tab":"surveyList01"}).text("리스트보기"))
						.append($("<li>", {"class":"btnListView listViewType02", "data-tab":"surveyList02"}).text("칸반형보기")) : ""
				));
		if(data.list.length > 0) {
			$('#collab_main_content_container .row').append($("<div>",{"class":"ProjectList ProjectList01 surveyList01 selected"})
					.append($("<table>",{"class": "ProjectListTable"})
					.append($("<tr>")
							.append($("<th>").text(mobile_comm_getDic("lbl_Category"))) // 분류
							.append($("<th>").text(mobile_comm_getDic("lbl_subject"))) // 제목
							.append($("<th>").text(mobile_comm_getDic("lbl_SurveyClosed")))))); // 조사마감
	
			$('#collab_main_content_container .row').append($("<div>",{"class":"ProjectList surveyList02"})
					.append($("<ul>",{"class": "cards"})));
	
			var stateTxt, className, type;	
			data.list.map( function( item,idx ){
				switch(item.State){
					case "A":
						stateTxt = mobile_comm_getDic("lbl_SurveyWriting"); // 작성중
						break;
					case "F":
						stateTxt = mobile_comm_getDic("lbl_SurveyInProgress"); // 설문 진행중
						break;
					case "G":
						stateTxt = mobile_comm_getDic("lbl_SurveyEnd"); // 설문 종료
						break;
					default:
						stateTxt = "";
						break;	
				};
				switch(item.PrjType){
				case "P":
					className = "survey_type02";
					type = "Project";
					break;
				case "T:":
					className = "survey_type01";
					type = "Team";
					break;
				default : 
					className = "survey_type02";
					type = "Todo";
					break;
				}
				
				$('#collab_main_content_container').find("table.ProjectListTable")
						.append($("<tr>").data({"surveyID" : item.SurveyID})
								.append($("<td>",{"class":className})
										.append($("<strong>", {"class" : "list_type"}).text(type)))
								.append($("<td>",{"class":"survey_title"}).text(item.Subject))
								.append($("<td>",{"class":"survey_deadline"}).text(item.EndDate))
							);
				
				$('#collab_main_content_container').find("ul.cards")
							.append($("<li>").data("surveyInfo", {"surveyID": item.SurveyID, "state": item.State})
									.append($("<div>", {"class":"survey_img"}).append($("<img>", {"src" : (idx % 2 == 0) ? "/HtmlSite/smarts4j_n/mobile/resources/images/collaboration/img_survey1.jpg" : "/HtmlSite/smarts4j_n/mobile/resources/images/collaboration/img_survey2.jpg"})))
							.append($("<div>",{"class":"survey_text " + className})
									.append($("<strong>", {"class" : "list_type"}).text(type))
									.append($("<h3>").text(item.Subject))
									.append($("<p>",{"class":"label"}).text(mobile_comm_getDic("lbl_SurveyPeriod"))) // 조사기간
									.append($("<p>",{"class":"date"}).text(item.StartDate + " ~ " + item.EndDate))
									));
			});
		} else {
			$("#collab_main_content_container .row")
			.append($("<div>", {"class":"nodata_type03"}).append($("<span>", {"class":"no_icon no_icon03"}))
					.append($("<p>").text(mobile_comm_getDic("msg_noSurvey")))); //"등록된 설문이 없습니다."
		}
	}
	
}();

var mobile_collab_template = function(){
	
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	var kind;
	var selTmpl;
	
	this.init = function(){
		kind = mobile_comm_getBaseCode("COLLAB_KIND").CacheData;
		
		$("#collab_templatePop_kind_container").empty().append(kind.map(function(item, idx){
			return $("<div>", {"class":"icon " + item.Reserved2}).data({"kind" : item.Code});
		}));

		mobile_collab_template.addEvent();
		mobile_collab_template.searchData(kind[0].Code);
	}
	
	this.projectAdd = function(){
		$("#collab_templateToProject_tmplName").text(selTmpl.tmplName).data({"tmplSeq" : selTmpl.tmplSeq});
		this.projectAddEvent();
	}
	
	/*템플릿 선택*/
	this.addEvent = function(){
			
		const temp_slider = $("#collab_templatePop_kind_container");
		temp_slider.slick({
			slide: 'div', //슬라이드 되어야 할 태그 ex) div, li
			infinite: false, //무한 반복 옵션
			slidesToShow: 5, //한 화면에 보여질 컨텐츠 개수
			slidesToScroll: 1, //스크롤 한번에 움직일 컨텐츠 개수
			speed: 500, //다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			arrows: true, //옆으로 이동하는 화살표 표시 여부
			dots: false, //스크롤바 아래 점으로 페이지네이션 여부
			autoplay: false, //자동 스크롤 사용 여부
			autoplaySpeed: 3000, //자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			pauseOnHover: true, //슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
			vertical: false, //세로 방향 슬라이드 옵션
			draggable: true, //드래그 가능 여부
			variableWidth: true,
			centerMode: false
		});
		
		$("#collab_templatePop_btnClose").on("click", function(){
			mobile_comm_back();
		});
				
		//종류 선택
		$("#collab_templatePop_kind_container div").on("click", function(){
			mobile_collab_template.searchData($(this).data("kind"));
		});
		
		//템플릿 선택
		$("#collab_templatePop .tempelete_list").on('click', "li", function(){
			selTmpl = {"tmplName" : $(this).find("h3").text(), "tmplSeq" : $(this).data("tmplSeq")};
			mobile_comm_go("/groupware/mobile/collab/popTemplateToProject.do");
	    });
	}
	
	//템플릿 검색
	this.searchData = function(tmplKind){
		if(mobile_move_flag()){	//중복방지
			$("#collab_templatePop .tempelete_list ul").empty();
			var params = {"tmplKind" : tmplKind	};
			$.ajax({
	    		type:"POST",
	    		data:params,
	    		url:"/groupware/collabTmpl/getTmplList.do",
	    		success:function (data) {
					data.list.map( function( item,idx ){
						$("#collab_templatePop .tempelete_list ul").append( 
								$("<li>").data({"tmplSeq":item.TmplSeq})
							.append($("<div>",{"class": "templete_img icon0" + ((idx + 1) % 4)}))
							.append($("<div>",{"class": "templete_text"})
								.append($("<h3>").text(item.TmplName))
								.append($("<p>").append($("<span>",{"class":"cate"}).text(item.TmplKindName))
								.append($("<span>",{"class":"favo"}).text(item.MyLikeCnt))))
						);
					});
	    		},
	    		error:function (request,status,error){
	    			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	    		}
	    	});
		}
	}
	
	/*프로젝트 추가*/
	this.projectAddEvent = function(){
		//기간 선택
		$(".input_date").datepicker({
			dateFormat : 'yy.mm.dd',
			dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	    });
		
		//기간 체크
		$("#collab_templateToProject_period input").on("change", function(){
			collabMobile.checkDates("collab_templateToProject_period", this);
		});
		
		$("#collab_templateToProject_taskStatus input[type='checkbox']").on("change", function(){
			if($(this).is(":checked")){
				$("#collab_templateToProject_taskStatus input:checkbox").not(this).each(function(){
					$(this).prop("checked",false).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off");
				});
			}
		});
		
		$("#collab_templateToProject_btnSave").on("click", function(){
			if(!mobile_collab_template.validationChk()) return;
			
			if(confirm(mobile_comm_getDic("msg_RUSave"))){
				var prjData = mobile_collab_template.getProjectData();
				$.ajax({
					type:"POST",
					contentType:'application/json; charset=utf-8',
					dataType   : 'json',
					data:JSON.stringify(prjData),
					url:"/groupware/collabProject/addProjectByTmpl.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							alert(mobile_comm_getDic("msg_com_processSuccess"));
							if(location.pathname.indexOf("/main.do") > 0){
								var aData = mobile_collab_project_param.get();
								mobile_comm_go("/groupware/mobile/collab/main.do?prjType="+aData.prjType+"&prjSeq="+aData.prjSeq);
							} else {
								mobile_comm_go("/groupware/mobile/collab/portal.do");
							}
						}
						else{
							alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
						}
					},
					error:function (request,status,error){
						alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			}
			
		});
		
		$("#collab_templateToProject_btnClose").on("click", function(){
			mobile_comm_back();
		});
	}
	
	this.getProjectData = function(){
		var prjData = {
				"prjName":  $("#collab_templateToProject_prjName").val()
				,"tmplSeq":  $("#collab_templateToProject_tmplName").data("tmplSeq")
				,"startDate": $("#collab_templateToProject_period input[name='startDate']").val()
				,"endDate": $("#collab_templateToProject_period input[name='endDate']").val()
				,"prjStatus": $('#collab_templateToProject_taskStatus input:checked').val() || ""
			};
		return prjData;
	}
	
	this.validationChk = function(){
		var returnVal= true;
	 	
		if (returnVal && $("#collab_templateToProject_taskStatus").find("input:checked").length == 0){
			alert(mobile_comm_getDic("msg_task_selectState"));
			returnVal = false;
		}
			
		if (returnVal && $('#collab_templateToProject_prjName').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("ACC_lbl_projectName")));
			returnVal = false;
		}
	
		if (returnVal && $('#collab_templateToProject_period [name="startDate"]').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("lbl_startdate")));
			returnVal = false;
		}
	
		if (returnVal && $('#collab_templateToProject_period [name="endDate"]').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("lbl_EndDate")));
			returnVal = false;
		}

		return returnVal;
	}
}();

var mobile_collab_projectDetail = function(){
	
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var prjSeq;
	var mode;
	var objId = "collab_projectPop";
	var project;
	
	this.init = function(){
		prjSeq = mobile_comm_getQueryString("prjSeq",objId);
		mode = mobile_comm_getQueryString("mode",objId);
		project = {};
		if(mode == "mod"){
			loadProject();
			$("#collab_projectPop_title").text(mobile_comm_getDic("lbl_Project")+" "+mobile_comm_getDic("lbl_Edit"));
		}
	}
	
	this.addEvent = function(){
		$("#"+ objId).off();
		
		collabMobile.colorPicker(objId + "_colorPicker", (project.prjColor) ? project.prjColor : "");
		
		if(project.PrjColor != undefined)
			collabMobile.setSelectColor(project.PrjColor);
				
		$(".input_date").datepicker({
			dateFormat : 'yy.mm.dd',
			dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	    });
		
		//담당자 추가
		$("#"+ objId).on("click", "#"+ objId +"_member_container .orgBtn", function(){
			$.extend(project, {prjColor : collabMobile.getSelectColorVal()});
			collabMobile.orgSelect("SelectUser", "Y", "mobile_collab_projectDetail.setMember(\"collab_projectPop_memberInput\", \"member\")");
		});
		
		//관리자 추가
		$("#"+ objId).on("click", "#"+ objId +"_manager_container .orgBtn", function(){
			$.extend(project, {prjColor : collabMobile.getSelectColorVal()});
			collabMobile.orgSelect("SelectUser", "Y", "mobile_collab_projectDetail.setMember(\"collab_projectPop_mangerInput\", \"manager\")");
		});
		
		//기간 체크
		$("#"+ objId).on("change", "#"+ objId +"_period input", function(){
			collabMobile.checkDates(objId +"_period", this);
		});
		
		//진행률
		$("#"+ objId).on("change", "#"+ objId +"_taskStatus input[type='checkbox']", function(){
			if($(this).is(":checked")){
				$("#"+objId+"_taskStatus input:checkbox").not(this).each(function(){
					$(this).prop("checked",false).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off");
				});
			}
		});
		
		//진행률
		$("#"+ objId).on("keydown keyup","#"+ objId +"_progRate", function(){
			var val = $(this).val();
			val = val.replace(/[^0-9^\.^\-]/g, "");
			var arrNumber = val.split('.');
			arrNumber[0] += '.';
			if (arrNumber.length > 1) {
				returnValue = arrNumber.join('');
			}
			else {
				returnValue = arrNumber[0].split('.')[0];
			}
			$(this).val(returnValue);
		});
		
		//확장필드
		$("#"+ objId).on("click", "#"+ objId +"_btnExAdd", function(){
			var len = $("#collab_projectPop_exField tbody tr").length;
			var _tr = $("<tr>");
			_tr.append($("<td>").append($("<label>",{"for":"chk_" + len, "class":"ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"})).append($("<input>",{"type":"checkbox", "id":"chk_" + len})))
				.append($("<td>").append($("<input>",{"type":"text", "class":"txtTitle"}).css("width", "98%")))
				.append($("<td>").append($("<input>",{"type":"text", "class":"txtVal"}).css("width", "98%")))
			$("#collab_projectPop_exField tbody").append(_tr);
			$("#collab_projectPop_exField tbody input[type='checkbox']").last().checkboxradio();
		});
		
		$("#"+ objId).on("click", "#"+ objId +"_btnExDel", function(){
			//$("#collab_projectPop_exField tbody").find("input[type='checkbox']:checked").closest("tr").remove();
			$("#collab_projectPop_exField tbody tr:last-child").remove();
		});
		
		$("#"+ objId).on("click", "#"+ objId + "_btnSave", function(){
			if(!mobile_collab_projectDetail.validationChk()) return;
			else{
				var _msg = "msg_AreYouCreateQ";
				if(mode == "mod") _msg = "msg_RUSave";
				if(confirm(mobile_comm_getDic(_msg))){
					mobile_collab_projectDetail.saveProject(mode);
				}
			}
		});
		
		$("#"+ objId).on("click", "#"+ objId + "_btnClose", function(){
			if(mode == "mod"){
				mobile_collab_project.refresh();
			} else {
				collabMobile.MenuList();
			}
			mobile_comm_back();
		});

		$("#"+ objId).on('click', "#allChk", function(){
			if($(this).prop("checked")){
				$("#collab_projectPop_exField").find("input[type='checkbox']").prop("checked",true).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-on");
			} else {
				$("#collab_projectPop_exField").find("input[type='checkbox']").prop("checked",false).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off");
			}
		});
		

		$("#"+ objId).on('click', ".btn_del.member, .btn_del.manager", function(){
			$(this).closest(".org_list_box").find("input").val($(this).closest(".org_list_box").find("input").val().replace($(this).parent().attr("code") + ";" , ""));			
			$(this).parent().remove();
		});
				
		mobile_comm_TopMenuClick('collab_leftmenu_tree',true);
	}

	this.setMember = function(objId, subClass){
		var data = $.parseJSON("[" + window.sessionStorage["userinfo"] + "]");
		var members = "";
		var bDup = false;
		
		if (data.length > 0) {
			$.each(data, function (i, v) {
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;

				members += code + ";";
				
				//code
				if($("#" + objId).val().indexOf(code + ";") >= 0){
					bDup = true;
				} else {
					var cloned = collabMobile.drawProfile({"code":code,"type":type,"DisplayName":mobile_comm_getDicInfo(v.DN)}, true, subClass);
					$('#' + objId).before(cloned);
				}
				
			});

	        if (bDup) {
                alert(mobile_comm_getDic("msg_DuplicateSelectedUser")); // 선택된 사용자 중에 이미 추가된 사용자가 있습니다.
	        }
			$("#" + objId).val($("#" + objId).val() + members);
		}
	}
	
	var loadProject = function(){
		$.ajax({
	   		type:"POST",
	   		data:{prjSeq : mobile_collab_project_param.get().prjSeq},
	   		url:"/groupware/collabProject/getProject.do",
	   		success:function (data) {
	   			if(data.status == "SUCCESS"){
	   				// 프로젝트 제목
	   				$("#collab_projectPop_prjName").val(data.prjData.PrjName || "");
	   				
	   				// 기간
	   				$("#collab_projectPop_period").find("input[name='startDate']").val(collabMobile.getDateFormat(data.prjData.StartDate));
	   				$("#collab_projectPop_period").find("input[name='endDate']").val(collabMobile.getDateFormat(data.prjData.EndDate));
	   				
	   				// 상태
	   				if(data.prjData.PrjStatus)
	   					$("#collab_projectPop_taskStatus").find("input[value='" + data.prjData.PrjStatus + "']").click();
	   				
	   				// 담당자
	   				var memberList = "";
	   				$(data.memberList).each(function(idx, item){
	   					memberList += item.UserCode + ";";
	   					$("#collab_projectPop_memberInput").before(collabMobile.drawProfile({"type":"UR","code":item.UserCode,"PhotoPath":item.PhotoPath,"DisplayName":item.DisplayName}, true, "member"));
	   				});
	   				$("#collab_projectPop_memberInput").val(memberList);
	   				
	   				// 진행률
	   				$("#collab_projectPop_progRate").val(data.prjData.ProgRate || "0");
	   				
	   				// 설명
	   				$("#collab_projectPop_remark").text(data.prjData.Remark || "");
	   				
	   				// 관리자
	   				var managerList = "";
	   				$(data.managerList).each(function(idx, item){
	   					managerList += item.UserCode + ";";
	   					$("#collab_projectPop_mangerInput").before(collabMobile.drawProfile({"type":"UR","code":item.UserCode,"PhotoPath":item.PhotoPath,"DisplayName":item.DisplayName}, true, "manager"));
	   				});
	   				$("#collab_projectPop_mangerInput").val(managerList);
	   				
	   				//확장필드
	   				$(data.userformList).each(function(idx, item){
	   					if(item.OptionTitle){
	   						var _tr = $("<tr>");
	   						_tr.append($("<td>").append($("<label>",{"for":"chk_" + idx, "class":"ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"})).append($("<input>",{"type":"checkbox", "id":"chk_" + idx})))
	   							.append($("<td>").append($("<input>",{"type":"text", "class":"txtTitle"}).css("width", "98%").val(item.OptionTitle)))
	   							.append($("<td>").append($("<input>",{"type":"text", "class":"txtVal"}).css("width", "98%").val(item.OptionVal)))
	   						$("#collab_projectPop_exField tbody").append(_tr);
	   						$("#collab_projectPop_exField tbody input[type='checkbox']").last().checkboxradio();
	   					}
	   				});
	   				
	   				if(data.prjData.PrjColor) {
	   					$.extend(project, {prjColor : data.prjData.PrjColor});
	   					//collabMobile.setSelectColor(data.prjData.PrjColor);
	   				}
	   			}
	   		},
	   		error:function (request,status,error){
	   			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
	   		}
	   	});
	}
	
	this.validationChk = function(){
		var returnVal= true;
		
		$('#collab_projectPop_exField tbody tr').each(function (i, v) {
			if(!$(v).find('.txtTitle').val() || !$(v).find('.txtVal').val()){
				alert(mobile_comm_getDic("msg_noEnterExField")); // 확장필드 중 입력되지 않은 값이 있습니다.
				returnVal = false;
				return false;
			}
		});

		if (returnVal && $("#collab_projectPop_taskStatus").find("input:checked").length == 0){
			alert(mobile_comm_getDic("msg_task_selectState"));
			returnVal = false;
		}
	 				
		if (returnVal && $('#collab_projectPop_prjName').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("ACC_lbl_projectName")));
			returnVal = false;
		}
	
		if (returnVal && $('#collab_projectPop_period input[name="startDate"]').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("lbl_startdate")));
			returnVal = false;
		}
	
		if (returnVal && $('#collab_projectPop_period input[name="endDate"]').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("lbl_EndDate")));
			returnVal = false;
		}
		
		if (returnVal && $('#collab_projectPop_progRate').val() == ""){
			alert(mobile_comm_getDic("msg_EnterTheRequiredValue").replace("{0}", mobile_comm_getDic("lbl_TFProgressing")));
			returnVal = false;
		}
		
		return returnVal;
	}
	
	this.saveProject = function(mode){
		var prjData = this.getProjectData();
		var sUrl = "";
		if(mode == "mod"){
			prjData.append("prjSeq", prjSeq);
			sUrl = "/groupware/collabProject/saveProject.do";
		} else {
			sUrl = "/groupware/collabProject/addProject.do";
		}
		$.ajax({
			type:"POST",
			enctype: 'multipart/form-data',
			processData: false,
			contentType: false,
			data:prjData,
			url:sUrl,
			success:function (data) {
				if(data.status == "SUCCESS"){
					alert(mobile_comm_getDic("msg_com_processSuccess"));
					$("#collab_projectPop_btnClose").click();
				}
				else{
					alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			}
		});
	}
	
	this.getProjectData = function(){
		var trgUserFormArr = new Array();
	 	$('#collab_projectPop_exField tbody tr').each(function (i, v) {
			var item = $(v);
			var saveData = { "optionTitle":item.find('.txtTitle').val(), "optionVal":item.find('.txtVal').val(), "optionType":"text"};
			trgUserFormArr.push(saveData);
		});

		var formData = new FormData();
			formData.append("prjName", $("#collab_projectPop_prjName").val());
			formData.append("startDate", $("#collab_projectPop_period [name='startDate']").val());
			formData.append("endDate",$("#collab_projectPop_period [name='endDate']").val());
			formData.append("remark", $("#collab_projectPop_remark").val());
			formData.append("prjStatus", $('#collab_projectPop_taskStatus input:checked').val() || "");
			formData.append("progRate", $("#collab_projectPop_progRate").val());
			formData.append("trgMember", JSON.stringify(collabMobile.getUserArray("collab_projectPop_member_container")));
			formData.append("trgManager", JSON.stringify(collabMobile.getUserArray("collab_projectPop_manager_container")));
			formData.append("trgUserForm", JSON.stringify(trgUserFormArr));
			formData.append("delFile", JSON.stringify(new Array()));
			formData.append("prjColor", collabMobile.getSelectColorVal());
			formData.append("file", JSON.stringify(new Array()));
			formData.append("trgViewer", JSON.stringify(new Array()));
			formData.append("trgMileForm", JSON.stringify(new Array()));
			
		
		return formData;
	}
}();

var mobile_collab_PortalInit = function(){
	$.ajax({
   		type:"POST",
   		url:"/groupware/collabPortal/getPortalMain.do",
   		success:function (data) {
   			collabMobile.displayStat(data.myTaskCnt);
   			collabMobile.drawTodo(data.myTaskList);
   			collabMobile.drawFavorite(data.myFavorite);
   			collabMobile.drawProject(data.prjList, data.deptList);
    		
   		},
   		error:function (request,status,error){
   			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
   		}
   	});
	
	collabMobile.MenuList();
	collabMobile.clickstat();
}

var mobile_collab_menuList = function(){	
	
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var _data;
	var objId = "collab_menu_list";
	
	this.init = function(){
		_data = mobile_collab_project_param.get();
		//$.extend(_data, mobile_collab_project.get());
		//_data.prjType = _data.prjType || "Todo"; 
		_data.prjType = (_data.myTodo == "Y") ? "Todo" : _data.prjType;
		
		var _className = "";
		var _type = "";
		var bInvite = false;
		
		switch(_data.prjType){
		case "P":
			_className = "menu_list_project";
			_type = "Project";
			bInvite = true;
			break;
		case "T":
			_className = "menu_list_team"
			_type = "Team";
			break;
		default:
			_className = "menu_list_project";
			_type = _data.prjType;
			break;
		}
		
		$("#"+objId).find(".menu_list_area").addClass( _className);
		if(_data.prjColor){
			$("#collab_menu_list").find(".menu_list_top").css("background-color", "#"+_data.prjColor);
		}
		$("#" + objId).find(".type").text( _type);
		$("#" + objId).find(".title").text($("#collab_main_header_name").text());
		$("#" + objId + " ul.collabo_menu_list").find("li").removeClass("active");
		
		var project = mobile_collab_project.get();
		
		if(!bInvite || project.prjAdmin !='Y')
			$("a.btn_invite").parent().hide();
			
		if(project.viewMode){
			$("#" + objId + " ul.collabo_menu_list").find("li > a[data-view='" + project.viewMode + "']").parent().addClass("active");
		} else if(_data.dataType) {
			$("#" + objId + " ul.collabo_menu_list").find("li> a[data-type='" + _data.dataType + "']").parent().addClass("active");
		} else{
			$("#" + objId + " ul.collabo_menu_list").find("li").eq(0).addClass("active");
		}
		mobile_collab_menuList.addEvent();
	}
	
	this.addEvent = function(){
		//메뉴 event
		$("#" + objId + " ul.collabo_menu_list").find("li > a").on("click", function(){
			if(mobile_move_flag()){	//중복방지
				var _dataView = $(this).attr('data-view') || "";
				var _dataType = $(this).attr("data-type") || "";
				mobile_collab_project.set({"viewMode" : _dataView, "dataType" : _dataType, "cal_tab": ""});
				mobile_collab_project.refresh();		
				mobile_comm_back();
			}
		});
		
		//팀원 초대
		$("#" + objId + " .btn_invite").click(function(){
			collabMobile.orgSelect("SelectUser", "Y", "mobile_collab_menuList.setMember()");
		});
	}
	
	this.setMember = function(){
		var data = $.parseJSON("[" + window.sessionStorage["userinfo"] + "]");
		var trgMemberArr = new Array();
		
		if (data.length > 0) {
			$.each(data, function (i, v) {
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
				var deptCode = (v.itemType == 'user') ? v.RG : "";

				var saveData = { "type":type, "userCode":code, "deptCode":deptCode};
				trgMemberArr.push(saveData);
			});
		}
		
		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"trgMember":trgMemberArr,"prjSeq":  _data.prjSeq, "prjName": $("#collab_main_header_name").text()}),
			url:"/groupware/collabProject/addProjectInvite.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					alert(mobile_comm_getDic("msg_com_processSuccess"));
				}
				else{
					alert(mobile_comm_getDic("msg_ErrorOccurred")+data);//	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			}
		});
	}
}();

var mobile_collab_taskDetail = function(){

	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var taskSeq;
	var prjSeq;
	var _taskData;
	var detailKey = {};

	this.get = function(){
		return detailKey;
	}
	
	this.set = function(param){
		taskSeq = param.taskSeq;
		prjSeq = param.prjSeq;
		
		$.extend(detailKey, param);
	}
	
	this.init = function(){
		prjSeq = mobile_comm_getQueryString("prjSeq","collab_task_detail");
		taskSeq = mobile_comm_getQueryString("taskSeq","collab_task_detail");		
		this.getTask();
	}
	
	this.getTask = function(){

		// 업무 상세 페이지
		$.ajax({
			type:"POST",
			data:{"taskSeq":taskSeq},
			url:"/groupware/collabTask/getCollabTask.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					_taskData = data;					
					loadTask(_taskData);
				} else alert(mobile_comm_getDic("msg_ErrorOccurred"));
			},
			error:function (request,status,error){
				alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			}
		});
	}
	
	var loadTask = function(data){
		$("#collab_task_tit").text(data.taskData.TaskName);
		$("#collab_task_start_date").val(collabMobile.getDateFormat(data.taskData.StartDate));
		$("#collab_task_end_date").val(collabMobile.getDateFormat(data.taskData.EndDate));

	
		if (data.authSave != 'Y'){
			$(".exmenu_list").find("#btnTag").hide();	
			$(".exmenu_list").find("#btnInvite").hide();	
			$(".exmenu_list").find("#btnDel").hide();
			$(".exmenu_list").find("#btnDetail").hide();
		}
		
		//담당자
		$("#collab_task_user").empty();
		if(data.memberList.length > 0){
			$(data.memberList).each(function(idx, item){
				$("#collab_task_user").append(collabMobile.drawProfile({"code":item.UserCode,"type":"UR", "PhotoPath":item.PhotoPath,"DisplayName":item.DisplayName}, false))
			});
			$("#collab_task_user").data("item",data.memberList);
		} else {
			$("#collab_task_user").append($("<div>", {"class" : "user_img noimg"})).append($("<span>", {"class" : "user_name"}).text("배정되지 않음"));
		}
		
		//프로젝트
		$("#collab_task_selProject").attr("data-taskseq",data.taskData.TaskSeq).attr("data-toptaskseq",data.taskData.TopParentKey || data.taskData.TaskSeq).empty();
		
		if(Object.keys(data.mapList).length === 0) $("#collab_task_post_location").hide();	
		
		$(data.mapList).each(function(idx, item){
			var option = $("<option>");
			option.text(item.PrjName).val(item.PrjSeq);
			
			var task_post_location = "";
			if(item.PrjName != null) 
				task_post_location = item.PrjName + ((item.SectionName != null) ? " > " +item.SectionName : "");

			$("#collab_task_post_location").show();
			$("#collab_task_post_location").text(task_post_location);

			if(item.PrjSeq == prjSeq){	
				//$("#collab_task_post_location").text(item.PrjName + " > " +item.SectionName);
				option.attr("selected", true);
			}
			$("#collab_task_selProject").data('item',data.mapList).append(option);
		});

		$("#collab_task_remark").html(collabMobile.XSSBoard(unescape(data.taskData.Remark)));
		
		$("#collab_task_subTask").find(".pop_listBox").remove();
		
		//하위 Task
		$(data.subTaskList).each(function(idx, item){
			$("#collab_task_subTask")
			.append($("<div>",{"class":"pop_listBox"})
					.append($("<div>", {"class":"pop_l"}).append($("<div>", {"class":"chkStyle10"})
							.append($("<input>",{"type":"checkbox", "id":"chk" + item.TaskSeq, "data-taskSeq": item.TaskSeq}).attr("checked",item.TaskStatus=="C"?true:false))
							.append($("<label>",{"for" : "chk" + item.TaskSeq}).append($("<span>", {"class":"s_check"})).text(item.TaskName)))
					)
					.append($("<div>", {"class":"pop_r", "id" : "sub_"+item.TaskSeq})
							.append($("<span>", {"class":"user_date"}).text(collabMobile.getDateFormat(item.EndDate))))
					.append($("<a>",{"class":"btn_arrow_c btnSubDetail", "data-taskSeq":item.TaskSeq, "onClick" : "collabMobile.openSubTaskPopup("+prjSeq+","+item.TaskSeq+") "  })));
			
			if (item.tmUser){
				var aUsers = item.tmUser.split('|');
				if(aUsers.length > 0){
					var aUserslength = (aUsers.length > 2) ? 2 : aUsers.length;
					for(var i=0; i<aUserslength; i++){
						aUserInfo = aUsers[i].split('^');
						$("#sub_"+item.TaskSeq).append(collabMobile.drawProfile({"code":aUserInfo[0],"DisplayName":aUserInfo[1],"PhotoPath":aUserInfo[2]}, false));
					}
				}
			}
			
			//하위업무 완료처리
			$(document).off('change','#collab_task_subTask .pop_listBox #chk'+ item.TaskSeq).on('change','#collab_task_subTask .pop_listBox #chk'+ item.TaskSeq,function(e){
				$.ajax({
	    			type:"POST",
	    			data:{
						"taskSeq": item.TaskSeq,
						"taskStatus":$(this).is(':checked')
					},
	    			url:"/groupware/collabTask/changeProjectTaskStatus.do",
	    			success:function () {
	    				mobile_collab_taskDetail.getTask();
	    			},
	    			error:function (response, status, error){
	    				mobile_comm_ajaxerror("/groupware/collabTask/changeProjectTaskStatus.do", response, status, error);
	    			}
	    		});
	        });

		});
		
		$("input[type='checkbox']").checkboxradio();
		$("#collab_task_selAttachFile").empty();
		if(data.fileList.length > 0){
			$(data.fileList).each(function(idx, item){
				$("#collab_task_selAttachFile").append($("<option>").text(item.FileName));					
			});
		} else {
			$("#collab_task_selAttachFile").parents("li").eq(0).hide();
		}
		
		//태그
		$("#tagList").find("li").remove();	
		$(data.tagList).each(function(idx, item){
			$("#tagList")
					.append($("<li>", {"class":"tagview"}).append($("<div>").data({"tagid":item.TagID})
					.append($("<span>",{"class":"btn_dtag bg0"+(Math.floor(mobile_comm_random() * 4)+1),"text":item.TagName}))
					));
					
			if(data.authSave == 'Y'  || item.RegisterCode == mobile_comm_getSession("USERID"))
					$("#tagList").find("li").eq(idx).find("div").append($("<a>",{"class":"ui-link tag_del", "href": "#" }).text("삭제"));
		});
		
		//tag 삭제
		$(document).on('click', '.tag_del', function(e) {
			
			var obj = this;
			$.ajax({
				type:"POST",
				data: {"taskSeq": mobile_comm_getQueryString("taskSeq","collab_task_detail"),"tagID":$(this).parent().data("tagid")},
				url:"/groupware/collabTask/deleteTaskTag.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						$(obj).closest("li").remove();
					}
					else{
						alert(mobile_comm_getDic("ACC_msg_error")); 	// 오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (response , status, error){
					mobile_comm_ajaxerror("/groupware/collabTask/deleteTaskTag.do", response, status, error);
				}
			});
			
		});
		
		//file
		$("#fileList").find("li").remove();
		$('#fileList').html(mobile_comm_downloadhtml(data.fileList));

		if (data.taskData.Label == "E")			$("#collab_task_selCategory").val(mobile_comm_getDic("lbl_Urgency"));
		else 			$("#collab_task_selCategory").val("");
/*		switch(data.taskData.Label){
		case "E":
			$(".sleOpTitle1").empty().append($('<span>', {"class" : "urgent"})).append(mobile_comm_getDic("lbl_Urgency")); // "긴급"
			break;
		case "I":
			$(".sleOpTitle1").empty().append($('<span>', {"class" : "important"})).append(mobile_comm_getDic("lbl_Important")); //"중요"
			break;
		}
*/		
		//북마크
		if(data.taskData.IsFav != "0"){
			$("#collab_task_btnFav").removeClass("active").addClass("active");
		} else {
			$("#collab_task_btnFav").removeClass("active");
		}
		// 댓글 영역
		mobile_comment_getCommentLike('Collab',data.taskData.TaskSeq, 'N');
		
		mobile_collab_taskDetail.addEvent();
	}
	
	this.addEvent = function(){
		$(document).on('click',"#collab_task_detail",function(){
			var $obj = $(event.target);			
			if( event.target.id == "mobile_collab_HdropMenu" || $obj.parents("#mobile_collab_HdropMenu").length > 0 ){
				$("#collab_task_detail .dropMenu").addClass("show");				
				$("#collab_task_detail .dropMenu ul.exmenu_list").off("click").on("click",function(){
					var func = {
						btnTag : function(){							
							$( "#_popup" ).remove();
							$("body").append( $("<div>",{ id : "_popup" }) ).find("#_popup")
								.append( $("#template-popup-addTag").text() )
								.on("click","#closeTodo",function(){									
									$( "#_popup" ).remove();
								})
								.on("click","#saveTodo",function(){
									var data = { taskSeq : _taskData.taskData.TaskSeq, tagName :$("#_popup #tagName").val()};
									$.ajax({
										type:"POST",
										data: data,
										url:"/groupware/collabTask/addTaskTag.do",
										success: function(data) {
											mobile_collab_taskDetail.getTask();
											$( "#_popup" ).remove();
										},
										error:function (response, status, error){
							    			mobile_comm_ajaxerror("/groupware/collabTask/addTaskTag.do", response, status, error);
							    		}
									});
								});
						}
						,btnInvite : function(){							
							if($("#collab_task_selProject").data('item')== undefined){
								collabMobile.orgSelect("SelectUser", "Y", "mobile_collab_taskDetail.setInviteArr()");
							}else{
								mobile_comm_go('/groupware/collabProject/mobile/popTaskMember.do?id=collab_projectmember_page', 'Y');
							}
						}
						,btnDel : function(){		
							if( confirm(mobile_comm_getDic("msg_RUDelete")) ){
								$.ajax({
			                		type:"POST",
			                		data:{"taskSeq":  _taskData.taskData.TaskSeq , "parentKey": _taskData.taskData.ParentKey },
			                		url:"/groupware/collabTask/deleteTask.do",
			                		success:function (data) {
			                			if(data.status == "SUCCESS"){			                				
			                				mobile_collab_project.refresh();
			                				mobile_comm_back();
			                			}else{
			                				alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			                			}
			                		},
			                		error:function (request,status,error){
			                			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			                		}
			                	});
							}
						}
						,btnDetail : function(){							
							var _formData = new FormData();
							var $template = $("#template-popup-addDetail").text();
							
							var progRateSelect = "";
							$.ajax({
								type:"POST",
								data:{"codeGroups" : 'TaskProgress'},
								url:"/covicore/basecode/get.do",
								async:false,
								success:function (data) {
									$.each(data.list, function(idx, obj){
										for(var i = 0; i < obj["TaskProgress"].length; i++) {
										    var objdata = obj["TaskProgress"][i];
											progRateSelect += "<option value=\""+objdata.Code+"\">"+objdata.CodeName+"</option>";
										}
									});
								},
								error:function (error){
									alert(error.message);
								}
							});
							
							//set Init Data
							var taskData = _taskData.taskData;
							$template = $template.replace(/{\=taskName}/g	, taskData.TaskName )
												 .replace(/{\=startDate}/g	, (taskData.StartDate != null) ? taskData.StartDate.replace(/(\d{4})(\d{2})(\d{2})/,"$1.$2.$3") : "" )
												 .replace(/{\=endDate}/g	, (taskData.EndDate != null) ? taskData.EndDate.replace(/(\d{4})(\d{2})(\d{2})/,"$1.$2.$3") : "" )
												 .replace(/{\=progRate}/g	,  progRateSelect)
												 .replace(/{\=remark}/g		, taskData.RemarkText || "" );
							$( "#_popup" ).remove();
							
							$("body").append( $("<div>",{ id : "_popup" }) ).find("#_popup")
							.append( $template )
								.on("change","#taskName,#progRate,#remark",function(){
									
									if ((this.id === "progRate")&&(this.value === "100")) {		// 진행률을 100%로 설정하면, 상태가 자동으로 '완료'로 변경.
										$("#taskStatus input:checkbox").trigger("click"); 		// 상태값 변경 클릭 이벤트.
									}
									
									_formData.delete(this.id);
									_formData.append(this.id,this.value);
								})
								.on('change',"#taskStatus input:checkbox",function(){
									if( $(this).is(":checked") ){
										
										if(this.value == "P") $("#progRate").attr("disabled", false); 	// 상태가 진행일 때만 진행률을 수정할 수 있음.
										else $("#progRate").attr("disabled", true);
										
										if (this.value == "C") {
											$("#progRate").val("100"); 				// 상태를 완료로 변경했을 시, 진행율을 100%로 자동 변경.
											_formData.delete("progRate");
											_formData.append("progRate","100");
										}
										
										_formData.delete("taskStatus");
										_formData.append("taskStatus",this.value);
										$("#taskStatus input:checkbox").not(this).each(function(){
											$(this).prop("checked",false).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off")
										});
									}
								})
								.on("click","#label",function(){
									$(".sleOpTitle,.selectOpList",this).toggleClass( "active" );
								})
								.on("click",".selectOpList li",function(){
									$(this.parentNode).prev().empty().append(this.innerHTML);
									_formData.delete("label");
									_formData.append("label",this.dataset.selvalue);
								})
								.on("focusin",".input_date",function(){									
						    		!$(this).hasClass(".hasDatepicker")&& $(this).datepicker({
						    	      dateFormat : 'yy.mm.dd',
						    	      dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
						    	    }).on('change',function(){
						    	    	_formData.delete(this.id);
						    	    	_formData.append(this.id,this.value); 
						    	    });
						    	})
								.on("change", "#collab_task_period input", function(){
									collabMobile.checkDates("collab_task_period", this);
								})							
								.on("click","#closeTodo",function(){									
									$( "#_popup" ).remove();
								})
								.on("click","#saveTodo",function(){
									if(mobile_move_flag()){	//중복방지
										//validation
										var spePatt = /[`!#$%^&*|\\\'\";:\/?¢™$®]/gi;
										if( $("#_popup #taskName").val().length == 0 ){
											alert(mobile_comm_getDic("msg_chk_taskName"));	// 업무명을 입력해주세요
											return false;
										}else if(spePatt.test($("#_popup #taskName").val())){
											alert(mobile_comm_getDic("msg_specialNotAllowed"));	// 특수문자는 사용할 수 없습니다.
											return;
										}else if( $("#_popup #startDate").val().length == 0 ){
											alert(mobile_comm_getDic("msg_EnterStartDate"));	// 시작일자를 입력하세요
											return false;
										}else if( $("#_popup #endDate").val().length == 0 ){
											alert(mobile_comm_getDic("msg_EnterEndDate"));	// 종료일자를 입력하세요
											return false;
										}			
										
										_formData.append("taskSeq",$("#collab_task_selProject").attr("data-taskseq"));	
										_formData.append("trgUserForm", JSON.stringify(new Array()));
										_formData.append("linkTaskList", JSON.stringify(new Array()));
										
										var tagArray = new Array();
									 	$('#tagList span').each(function (i, v) {
											tagArray.push( $(v).text());
										});
										_formData.append("tags", JSON.stringify(tagArray));	
										
										if ( _formData.get ("progRate") == "TaskProgress" ){ 
											_formData.delete("progRate");
											_formData.append("progRate", "0");
										}	
										_formData.append("addPrjList",JSON.stringify(new Array()));
										_formData.append("delPrjList",JSON.stringify(new Array()));
										
										$.ajax({
											type:"POST",
											enctype: 'multipart/form-data',
											data: _formData,
											processData: false,
											contentType: false,
											url:"/groupware/collabTask/saveTask.do",
											success:function (data) {
												if(data.status == "SUCCESS"){
													alert(mobile_comm_getDic("msg_com_processSuccess"));
													mobile_collab_taskDetail.getTask();
													$( "#_popup" ).remove();
												}else{
													alert(mobile_comm_getDic("msg_changeFail"));
												}
											},
											error:function (request,status,error){}
										});
									}									
								})
								.find("#taskStatus input[type='checkbox']").checkboxradio();								
								//initData
								taskData.Label = taskData.Label || "";
								$("#taskName,#progRate,#remark","#_popup").trigger("change");
								$(".input_date","#_popup").trigger("focusin").trigger("change");
								$("#taskStatus input:checkbox","#_popup").each(function(){
									this.value == taskData.TaskStatus && $(this).trigger("click");
									if(this.value == "W") $("#progRate").attr("disabled", true);
								});
								$("#progRate").val(taskData.ProgRate || 0);
								$("#label .selectOpList > li","#_popup").each(function(){ this.dataset.selvalue == taskData.Label && $(this).trigger("click") &&  $("#label","#_popup").trigger("click"); });
						} 
						,btnExport : function(){
							mobile_comm_log('btnExport')
						}
						,btnReload : function(){
							mobile_collab_taskDetail.getTask();
						}
					}
					func[event.target.id] && func[event.target.id](); 
					
					/*$("body").append( $("<div>",{ id : "_popup" }) );					
					$( "#_popup" ).load( "/groupware/mobile/collab/popTodoTask.do #addTodo",function(){    			
		    			var _formData = new FormData();    			    			
		    			$("#taskName,#progRate,#remark",this).on('change',function(){ _formData.append(this.id,this.value); });    			
						$("#taskStatus input:checkbox",this).on('change',function(){
							if( $(this).is(":checked") ){						
								_formData.append("taskStatus",this.value);
								$("#taskStatus input:checkbox").not(this).each(function(){
									$(this).prop("checked",false).prev().prop("class","ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off")
								});
							}
						});
		    			$(".input_date",this).datepicker({
		    				dateFormat : 'yy.mm.dd',
		    				dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
			    	    }).on('change',function(){ _formData.append(this.id,this.value); });
		    			
		    			$("#saveTodo",this).on('click',function(){    				
		    				$.ajax({
								type:"POST",
								enctype: 'multipart/form-data',
								data: _formData,
								processData: false,
								contentType: false,
								url:"/groupware/collabTask/addTask.do",
								success:function (data) {
									if(data.status == "SUCCESS"){
										$("#_popup #closeTodo").trigger("click");
									}
								},
								error:function (request,status,error){
									mobile_comm_log(request,status,error);
								}
							});
		    			});
		    			$("#closeTodo",this).on('click',function(){ this.remove(); }.bind($(this)));
		    			
		    			$("#label",this).on('click',function(){ $("#label .sleOpTitle,#label .selectOpList").toggleClass( "active" ); });
		    			$("#label .selectOpList li",this).on('click',function(){ 
		    				$(this.parentNode).prev().empty().append(this.innerHTML);
		    				_formData.append("label",this.dataset.selvalue);
		    				
		    			});
		    		});*/
				})
				
			}else if( event.target.id == "addSubTask"){	//하위업무 추가
			
				if(mobile_move_flag())	//중복방지
					mobile_comm_go('/groupware/mobile/collab/popSubTodoTask.do', 'Y');
					
			}else if( event.target.id == "delSubTask"){	//하위업무 삭제
				if(mobile_move_flag()){	//중복방지
					if(_taskData.subTaskList.length > 0){
						var arrNum = _taskData.subTaskList.length - 1;
						var delSubTask = _taskData.subTaskList[arrNum];
						
						if( confirm(mobile_comm_getDic("msg_RUDelete")) ){
							$.ajax({
		                		type:"POST",
		                		data:{"taskSeq":  delSubTask.TaskSeq , "parentKey": delSubTask.ParentKey },
		                		url:"/groupware/collabTask/deleteTask.do",
		                		success:function (data) {
		                			if(data.status == "SUCCESS")
										mobile_collab_taskDetail.getTask();
									else
		                				alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		                		},
		                		error:function (request,status,error){
		                			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		                		}
		                	});
						}
					}else{
						alert(mobile_comm_getDic("msg_noSubTask"));	//"등록된 하위업무가 없습니다."
					}
				}
			}else if(event.target.id == "btnClose"){	// 닫기
				if(mobile_move_flag())	//중복방지
					mobile_comm_back();
			}else{
				$("#collab_task_detail .dropMenu").removeClass("show");
			}
		});
		
		//북마크
		$(document).on('click','#collab_task_btnFav', function(){
				if(mobile_move_flag()){	//중복방지
					$.ajax({
		        		type:"POST",
		        		data:{"taskSeq":  $("#collab_task_selProject").attr("data-taskseq"), "isFlag":$(this).hasClass("active")},
		        		url:"/groupware/collabTask/saveTaskFavorite.do",
		        		success:function (data){ 
		        			if(data.status == "SUCCESS")
		        				$("#collab_task_btnFav").toggleClass("active");
		        			else
		        				alert(mobile_comm_getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		        		},
		        		error:function (request,status,error){
		        			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
		        		}
		        	});
				}
		});
		
		//프로젝트 삭제
/*		$("#btnDelProject").on('click', function(){
			var data = ($("#prjMap").find("option:selected").data());
			data["taskSeq"] = CFN_GetQueryString("taskSeq");
			 $.ajax({
            		type:"POST",
            		data:data,
            		url:"/groupware/collabTask/deleteAllocProject.do",
            		success:function (data) {
            			$("#btnReload").trigger("click");
            		},
            		error:function (request,status,error){
            			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            		}
            	});
		});*/
	}
	this.setInviteArr = function(){
		var data = $.parseJSON("[" + window.sessionStorage["userinfo"] + "]");
		var addUserList = new Array();
		
		if (data.length > 0) {
			$.each(data, function (i, v) {
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;

				var saveData = { "type":type, "userCode":code};
				addUserList.push(saveData);
			});
		}
		$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data :JSON.stringify({ "trgMember" : addUserList, "taskSeq" : $("#collab_task_selProject").attr("data-taskseq") }),
				url:"/groupware/collabTask/addTaskInvite.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						alert(mobile_comm_getDic("msg_com_processSuccess"));
						mobile_collab_taskDetail.getTask();
					}
					else{
						alert(mobile_comm_getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
		});
	}
}();

var collabMobile ={
		clickstat:function(){
			//진행중 배정된업무
			$(document).on("click", "#collab_portal_page .Twork_today li:eq(0) .T_num", function () {
				if(mobile_move_flag()){	//중복방지
					var _data = $(this).data();
					mobile_comm_go('/groupware/mobile/collab/main.do?prjType='+_data.prjType+'&prjSeq='+_data.prjSeq+'&tagVal=ProcTask');
				}
			});
			//오늘마감
			$(document).on("click", "#collab_portal_page .Twork_today li:eq(1) .T_num", function () {
				if(mobile_move_flag()){	//중복방지
					var _data = $(this).data();
					mobile_comm_go('/groupware/mobile/collab/main.do?prjType='+_data.prjType+'&prjSeq='+_data.prjSeq+'&tagVal=TodayCTask');
				}
			});
			//지연
			$(document).on("click", "#collab_portal_page .Twork_today li:eq(2) .T_num", function () {
				if(mobile_move_flag()){	//중복방지
					var _data = $(this).data();
					mobile_comm_go('/groupware/mobile/collab/main.do?prjType='+_data.prjType+'&prjSeq='+_data.prjSeq+'&tagVal=DelayTask');
				}
			});
			//긴급업무
			$(document).on("click", "#collab_portal_page .Twork_today li:eq(3) .T_num", function () {
				if(mobile_move_flag()){	//중복방지
					var _data = $(this).data();
					mobile_comm_go('/groupware/mobile/collab/main.do?prjType='+_data.prjType+'&prjSeq='+_data.prjSeq+'&tagVal=EmgTask');
				}
			});
		} ,
		makePrjectLink:function(prjType, prjSeq){
			return "javascript: mobile_comm_go('/groupware/mobile/collab/main.do?prjType="+prjType+"&prjSeq="+prjSeq+"')"; 
		} ,
		makeTaskLink:function(taskSeq, topTaskSeq){
			return "javascript: mobile_comm_go('/groupware/mobile/collab/taskdetail.do?taskSeq="+taskSeq+"&topTaskSeq="+topTaskSeq+"','Y')"; 
		} ,
		MenuList:function(){
			$.ajax({
				url:"/groupware/collab/getUserMenu.do",
				type:"POST",
				async:false,
				success:function (data) {
					
					$("#collab_deptList").html("");
					$("#collab_prjListP").html("");
					$("#collab_prjListW").html("");
					$("#collab_prjListH").html("");
					$("#collab_prjListC").html("");
					
					if(data.deptList.length > 0){
						$(data.deptList).each(function(i,v){
							$("#collab_deptList").append($("<li>").append($("<a>",{"class":"t_link ui-link"}).data({prjType : "T"+v["ExecYear"], prjSeq : v["GroupID"]}).append($("<span>",{"class":"t_ico_board"})).append(v.DeptName)));
						});
					}
					if(data.prjList.length > 0){
						$(data.prjList).each(function(i,v){
							$("#collab_prjList"+v.PrjStatus).append($("<li>").append($("<a>",{"class":"t_link ui-link"}).data({prjType : "P", prjSeq : v["PrjSeq"]}).append($("<span>",{"class":"t_ico_board"})).append(v.PrjName)));
						});
					}
					
					$("#collab_leftmenu_tree #collab_myTodo, #collab_deptList a, #collab_prjListP a, #collab_prjListW a, #collab_prjListH a, #collab_prjListC a").click(function(){
						if($(this).data()){
							var _data = $(this).data();
							var myTodo = "N";
							if(this.id == "collab_myTodo") myTodo = "Y"; 
							if(location.pathname.indexOf("/main.do") > 0){
								mobile_collab_project.changeFolder({prjType : _data.prjType, prjSeq : _data.prjSeq, myTodo: myTodo});
							} else {
								mobile_comm_go('/groupware/mobile/collab/main.do?prjType='+_data.prjType+'&prjSeq='+_data.prjSeq);
							}
						}
					});
					
					//서브메뉴 토글
					$('.sub_list').prev('a').on('click', function(){
						if(mobile_move_flag()){	//중복방지
							var cName = $(this).find("span:eq(0)").attr("class");
							if(cName == "t_ico_close")
								$(this).find("span:eq(0)").removeClass("t_ico_close").attr("class","t_ico_open");
							else
								$(this).find("span:eq(0)").removeClass("t_ico_open").attr("class","t_ico_close");
							
							//$(this).next('.sub_list').slideToggle();
							$(this).next('.sub_list').toggle();
						}
					});
					$('#collab_prjListW, #collab_prjListH, #collab_prjListC').slideToggle();
					
					//메뉴선택 버튼
					$("#collab_menu_btnPrjAdd").off().on("click", function(){
						$(this).siblings(".column_menu").toggleClass("active");
					});
					
					$("#collab_menu_Usingtemplate").off().on("click", function(){
						$(this).closest('.column_menu').removeClass('active');
						//템플릿사용
						mobile_comm_go("/groupware/mobile/collab/popTemplate.do?mode=add", "Y");
					});
					
					$("#collab_menu_PrjAdd").off().on("click", function(){
						$(this).closest('.column_menu').removeClass('active');
						//빈프로젝트
						mobile_comm_go("/groupware/mobile/collab/popProject.do?mode=add", "Y");
					});
				},
				error:function (error){
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		},
		displayStat:function(data){
			$("#collab_portal_page .Twork_today li:eq(0) .T_num").text(data.ProcCnt);
	  		$("#collab_portal_page .Twork_today li:eq(1) .T_num").text(data.NowTotCnt-data.NowCompCnt);
	  		$("#collab_portal_page .Twork_today li:eq(2) .T_num").text(data.DelayCnt);
	  		$("#collab_portal_page .Twork_today li:eq(3) .T_num").text(data.EmgCnt);
		},
		drawTodo:function(json){
			  $("#collab_portal_page .Twork_todo").empty();
			  json.map( function( item,idx ){
				  $("#collab_portal_page .Twork_todo").append(
						  $("<li>").append($("<div>",{"class":"pr_chk"})
								  	.append($("<div>",{"class":"ui-checkbox"})
									  	.append($("<label>",{"for":"prt_"+item.TaskSeq,"class":"ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left"}).append($("<span>",{"class":"s_check"})))
								  	.append($("<input>",{"type":"checkbox", "id":"prt_"+item.TaskSeq}).attr("checked",item.TaskStatus=="C"?true:false).data({"taskSeq":item.TaskSeq})))
								  	.append($("<a>",{"class":"ui-link", "href":collabMobile.makeTaskLink(item.TaskSeq,item.TaskSeq)}).text(item.TaskName)))
								 );
				  });
		  },
		  drawFavorite:function(json){
			  $("#collab_portal_page .Twork_bookmark").empty();
			  json.map( function( item,idx ){
				  $("#collab_portal_page .Twork_bookmark").append( $("<li>").append($("<a>",{"href":collabMobile.makeTaskLink(item.TaskSeq,item.TaskSeq)}).text(item.TaskName)).data({"taskSeq":item.TaskSeq}));
				});
		  },
		 drawProject:function(prjData, deptData){
				  $("#collab_portal_page .Pwork_list").empty();
				  deptData.map( function( item,idx ){
					  $("#collab_portal_page .Pwork_list").append( collabMobile.drawTeamProject(item, "T"));
					});
				  prjData.map( function( item,idx ){
				  if (item.PrjStatus!='C'){
					  $("#collab_portal_page .Pwork_list").append( collabMobile.drawTeamProject(item, "P"));
				  }		  
			});
			collabMobile.loadSlide();
		  },
	      drawTeamProject:function(item, prjType){
	    	return $("<div>",{"class":(prjType=="T"?"bg01":(item.PrjColor==null||item.PrjColor==""?"bg02":"")),"style":(prjType=="P"&&item.PrjColor!=null&&item.PrjColor!=""?"background-color:"+item.PrjColor:"")})
	    			.append($("<a>",{"href":collabMobile.makePrjectLink((prjType=="T"?"T"+item.ExecYear:prjType),(prjType=="T"?item.GroupID:item.PrjSeq)),"class":"prj_link"}).data({"prjType":prjType,"prjSeq":(prjType=="T"?item.GroupID:item.PrjSeq)})
					  .append($("<span>",{"class":"pr_type","style":(prjType=="P"&&item.PrjColor!=null&&item.PrjColor!=undefined&&item.PrjColor!=""?"color:"+item.PrjColor:"")}).text(prjType=="P"?"Project":"Team"))
					  .append($("<strong>",{"class":"pr_title"}).text(prjType=="P"?item.PrjName:item.DeptName))
					  .append($("<div>",{"class":"pr_info"}).append(prjType=="P"?$("<span>",{"class":"pr_dday"}).text("~"+collabMobile.getDateFormat(item.EndDate)):"")
															.append($("<span>",{"class":"pr_people"}).text(collabMobile.getMemberFormat(item.TmUser, item.TmUserCnt))))
					  .append($("<div>",{"class":"pr_progress"}).append($("<div>",{"class":"pr_pgbox"}).append($("<div>",{"class":"pr_pgbar","style":"width:"+(prjType=="P"?item.ProgRate+"%":"")})))		
															  .append($("<div>",{"class":"pr_pgnum"}).append($("<span>").text((prjType=="P"?Math.round(item.ProgRate)+"%":"")))))
					  )  
	      },
	      getMemberFormat:function(sName, sCount){
	    	  var str = mobile_comm_getDic("msg_apv_181"); // 담당자를 지정하십시요.
	    	  if (parseInt(sCount)>1){
	    		  str = mobile_comm_getDic("lbl_Mail_AndOthers").replace("{0}",sName ).replace("{1}", sCount-1);
	    	  }
	    	  else if(sName !== null){
	    		  str = sName;
	    	  }
	    	  return str;
	      },
		  getDateFormat:function(time, fmt){
				if (time == null) return "";
				if (fmt == null) fmt = ".";
				var str =  time.split(/[~@!#$^%&*=+|:;?"<,.>'`(){}-]/).join("")

				if (str.length < 4) return str;

				if (str.length == 4)
				{
					return str.substring(0, 2) + fmt + str.substring(2, 4);
				}
				else if (str.length == 6)
				{
					return str.substring(0, 4) + fmt + str.substring(4, 6);
				}
				else if (str.length == 8)
				{
					return str.substring(0, 4) + fmt + str.substring(4, 6) + fmt + str.substring(6, 8);
				}
		},
		loadSlide:function(){
	    	  const slider2 = $("#collab_portal_page .Pwork_list");
	    	  slider2.slick({
	    	    slide: 'div',		//슬라이드 되어야 할 태그 ex) div, li
	    	    infinite : false, 	//무한 반복 옵션
	    	    slidesToShow : 2,		 //한 화면에 보여질 컨텐츠 개수
	    	    slidesToScroll : 1,		//스크롤 한번에 움직일 컨텐츠 개수
	    	    speed : 500,	  //다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
	    	    arrows : false, 		 //옆으로 이동하는 화살표 표시 여부
	    	    dots : true, 		 //스크롤바 아래 점으로 페이지네이션 여부
	    	    autoplay : false,			 //자동 스크롤 사용 여부
	    	    autoplaySpeed : 3000, 		 //자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
	    	    pauseOnHover : true,		 //슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
	    	    vertical : false,		 //세로 방향 슬라이드 옵션
	    	    draggable : true, 	//드래그 가능 여부
	    	    variableWidth: false,
	    	    centerMode: false
	    	  });
		},
		displayDday:function(item){
			if (item.EndDate == null || item.EndDate == "") return "";
			if (item.TaskStatus == "C") return collabMobile.getDateFormat(item.EndDate,'.');
			if (item.RemainDay<0){
				//return item.RemainDay;
				return 'D+'+(item.RemainDay+"").replace("-","");
			}else if (item.RemainDay==0){
				return 'D-Day';
			}else if (item.RemainDay<30){
				return 'D-'+item.RemainDay;
			}else{
				return collabMobile.getDateFormat(item.EndDate,'.');
			}	
		},
		getUserArray:function(objId){
			var trgMemberArr = new Array();
		 	$('#'+objId).find('.user_img').each(function (i, v) {
				var item = $(v);
				var saveData = { "type":item.attr('type'), "userCode":item.attr('code')};
				trgMemberArr.push(saveData);
			});
		 	return trgMemberArr;
		},
        drawProfile:function(obj, isDel, subClass){
        	var returnObj = $("<div>",{ "class" : "user_img", code:obj["code"], type:obj["type"]});
        	if (subClass == undefined ) subClass ="";
        	
        	if (obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")
        		 returnObj.append($("<p>",{"class" : "bImg"}).append($("<img>",{ "src" : mobile_comm_getimg(obj["PhotoPath"])})));
	 		else
				returnObj.append($("<p>",{ "class" : "bgColor"+(Math.floor(mobile_comm_random() * 5)+1)}).append($("<strong>").text((obj["DisplayName"] == undefined ) ? " " : obj["DisplayName"].substring(0,1))));
	 		
			if (isDel){
				returnObj.append($("<a>",{"class":"btn_del "+subClass}).data(obj));
			}	
        	return  returnObj.data(obj);
         },
		getFileIcon:function(item){
			if (item.SaveType == "IMAGE"){
				//return $("<img>",{"class":"prevImg", "style":"width:76px;height:76px"}).attr("src",mobile_comm_getImgFilePath("Collab",item.FilePath, item.SavedName));
				return $("<img>",{"class":"prevImg", "style":"width:76px;height:76px"}).attr("src",mobile_comm_getImgById("",item.FileID));
			}
			else{
				var icon_class="";
				switch (item.Extention)
				{
					case "ppt":
					case "pptx":
						icon_class = "ic_ppt";
						break;
					case "ppdf":
					case "pdf":
						icon_class = "ic_pdf";
						break;
					case "xls":
					case "xlsx":
					case "excel":
						icon_class = "ic_xls";
						break;
					case "zip" :
					case "rar" :
					case "7z" :
						icon_class = "ic_zip";
						break;
					case "doc":
					case "docx":
						icon_class = "ic_word";
						break;
					case "doc":
					case "docx":
						icon_class = "ic_word";
						break;
					default:
						icon_class ="ic_etc";
						break;
				}
				return $("<span>",{"class":icon_class});
			}
		},
        openTaskPopup:function(popupYN, prjSeq, taskSeq){//업무 상세화면
	   		var popupUrl	= "/groupware/mobile/collab/taskdetail.do?"
	   						+ "prjSeq="			+ prjSeq
	   						+ "&taskSeq="    	+ taskSeq;
	   		mobile_comm_go(popupUrl, popupYN); 
        },
        openSubTaskPopup:function(prjSeq, taskSeq){//하위업무 상세화면
				
				mobile_collab_taskDetail.set({"prjSeq":prjSeq,"taskSeq":taskSeq});
				mobile_collab_taskDetail.getTask();
			
        },
    	setCalendar:function(standDate, objId, tabMode, viewMode){

			var calData = {};

			if(viewMode == "GANT"){
				
				var startDateObj = new Date(standDate);
	    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
	    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
	    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
	    		
	    		$('#' + objId + ' .row').addClass("calendar_wrap month");
	    		$('#' + objId + ' .row').append(
	    				$("<div>", {"class":"calendar_ctrl clearFloat"})
	    					.append($("<div>", {"class":"calBtn"})
	    						.append($("<strong>", {"class":"title"}).text(sDate.substring(0,7)))
	    						.append($("<div>", {"class":"pagingType02"})
	    								.append($("<a>",{"class":"pre dayChg", "data-paging":"-"}))
	    								.append($("<a>",{"class":"next dayChg", "data-paging":"+"}))
	    								.append($("<a>",{"class":"btnTypeDefault calendartoday"}).text("오늘"))
	    							)	
	    						)
	    		);
				
	    		calData["startDate"] = sDate;
	    		calData["endDate"] = eDate;

			} else {
				
	    		tabMode = tabMode || "calPlan";
	    		var startDateObj = new Date(standDate);
	    		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
	    		var sDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)));
	    		var eDate = mobile_comm_getDateTimeString('yyyy-MM-dd',new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)));
	    		
	    		$('#' + objId + ' .row').addClass("calendar_wrap month");
	    		$('#' + objId + ' .row').append(
	    				$("<div>", {"class":"calendar_ctrl clearFloat"})
	    					.append($("<div>", {"class":"calBtn"})
	    						.append($("<strong>", {"class":"title"}).text(sDate.substring(0,7)))
	    						.append($("<div>", {"class":"pagingType02"})
	    								.append($("<a>",{"class":"pre dayChg", "data-paging":"-"}))
	    								.append($("<a>",{"class":"next dayChg", "data-paging":"+"}))
	    								.append($("<a>",{"class":"btnTypeDefault calendartoday"}).text("오늘"))
	    							)	
	    						)
	    					.append($("<ul>", {"class":"calSelect clearFloat"})
	    							.append($("<li>",{"data-tab":"calPlan", "class":((tabMode == "calPlan") ? "selected" : "")}).append($("<a>").text("일정")))
	    							.append($("<li>",{"data-tab":"calSchedule", "class":((tabMode == "calSchedule") ? "selected" : "")}).append($("<a>").text("스케줄")))
	    							)
	    		);
				
	    		calData["startDate"] = sDate;
	    		calData["endDate"] = eDate;
	    		
	    		startDateObj = new Date(standDate);
	    		var currentYear = startDateObj.getFullYear();
	    		var currentMonth = startDateObj.getMonth();
	    		var currentDate = startDateObj.getDate();
	    		var currentMonthFirstDay = new Date(currentYear, currentMonth, 1).getDay();
	    		var lastDay = new Date(currentYear, currentMonth + 1, 0).getDate();
	    		var currentMonthWeek = Math.ceil((currentMonthFirstDay + lastDay) / 7);
	    		var day = 1;
	    		
	    		$('#' + objId + ' .row').append(
	    				$("<div>", {"class":"calMonthWrap selected"})
	    					.append($("<div>",{"class": "tb_calendar"})
	    							.append($("<table>",{"class":"calendar"})
	    							.append($("<thead>").append(
	    									$("<tr>").append($("<th>").text("SUN"))
	    									.append($("<th>").text("MON")).append($("<th>").text("TUE"))
	    									.append($("<th>").text("WED")).append($("<th>").text("THU"))
	    									.append($("<th>").text("FRI")).append($("<th>").text("SAT"))
	    									))))
	    					.append($("<div>",{"class": "calendar_detail"})));
	
	    		var calendar = $('#' + objId + ' .row').find("table.calendar");
	    		
	    		for (var j = 0; j < currentMonthWeek; j++) {
	    			var row = $("<tr>");
	    			for (var i = 0; i < 7; i++) {
	    				var cell = $("<td>");
	    				if (i == 0)
	    					cell.addClass("sun");
	    				if ((j == 0 && i < currentMonthFirstDay)|| (j == (currentMonthWeek - 1) && day > lastDay)) {
	    					var d;
	    					cell.addClass("dim");
	    					if(j == 0 && i < currentMonthFirstDay){
		    					d = new Date(currentYear, currentMonth, 1);
		    					d.setDate(d.getDate() - (d.getDay() - i));
	    					} else {
		    					d = new Date(currentYear, currentMonth + 1, 0);
		    					d.setDate(d.getDate() + (i - d.getDay()));
	    					}
	    					cell.append($("<a>",{"class": "ui-link"}).append($("<span>").text(d.getDate())));
	    				} else {
	    					if (day == today.getDate() && currentMonth == today.getMonth() && currentYear == today.getFullYear())
	    						cell.addClass("today");
	    					cell.append($("<a>",{"class": "ui-link", "schday" : (currentYear + "." + ((currentMonth + 1) < 10 ? "0" + (currentMonth + 1) : (currentMonth + 1)) + "." + (day < 10 ? "0" + day : day))}).append($("<span>").text(day)));
	    					day++;
	    				}
	    				row.append(cell);
	    			}
	    			calendar.append(row);
	    		}
			}
	
    		return calData;
    	},
        getWeekStart:function(d, week) {	//기준일자의 조건 요일에 해당하는  날짜 보내기
    		var date = new Date(d);

    	    var day = date.getDay();
    	    var diff = date.getDate() - day+week;
    	    return new Date(collabMobile.replaceDate(date.setDate(diff)));
    	},
    	replaceDate:function(dateStr){
    		var replaceStr;
    		
    		if(typeof dateStr == "string"){
    			if(dateStr.indexOf("-") > -1){
    				replaceStr = "-";
    			}else if(dateStr.indexOf(".") > -1){
    				replaceStr = ".";
    			}else if(dateStr.indexOf("/") > -1){
    				replaceStr = "/";
    			}
    			
    			return dateStr.replaceAll(replaceStr, "/");
    		}else{
    			var tempDate = new Date(dateStr);
    			
    			dateStr = tempDate.getFullYear() + "/" + (tempDate.getMonth()+1) + "/" + tempDate.getDate() + " " + mobile_comm_AddFrontZero(tempDate.getHours(), 2) + ":" + mobile_comm_AddFrontZero(tempDate.getMinutes(), 2);
    			
    			return dateStr;
    		}
    	},
    	getDates:function(startDate, lastDate) {
    		var regex = RegExp(/^\d{4}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$/);
    		if(!(regex.test(startDate) && regex.test(lastDate))) return "Not Date Format";
    		var result = [];
    		var curDate = new Date(startDate.substr(0, 4), parseInt(startDate.substr(4, 2) - 1), startDate.substr(6, 2));
    		while(curDate <= new Date(lastDate.substr(0, 4), parseInt(lastDate.substr(4, 2) - 1), lastDate.substr(6, 2))) {
    			result.push(mobile_comm_getDateTimeString("yyyy.MM.dd",curDate));
    			curDate.setDate(curDate.getDate() + 1);
    		}
    		return result;
    	},
    	orgSelect:function(mode, multi, callback){
    		var sUrl = "/covicore/mobile/org/list.do";
			window.sessionStorage["mode"] = mode;
			window.sessionStorage["multi"] = multi;
			window.sessionStorage["callback"] = callback;
			window.sessionStorage["userinfo"] = null;
			mobile_comm_go(sUrl, 'Y');
    	},
    	colorPicker:function(targetId, prjColor){
    		var colorList = mobile_comm_getBaseCode("ScheduleColor");
			var dataPalette = new Array();
			//var defaultColor = prjColor || "";
			var defaultColor = (prjColor == "default" || prjColor == "") ? "#5c7bf5" : prjColor;
			
			dataPalette.push({"default" : defaultColor});
			$(colorList.CacheData).each(function(){
				var obj = {};
				$$(obj).append(this.Code, "#"+this.Code);
				
				dataPalette.push(obj);
			});
			collabMobile.renderColorPicker(targetId, dataPalette);
			
    	},    	
    	/*
		 * 색상 picker를 만드는 함수
		 */
		renderColorPicker : function (target, colorInfos){
			var html='<input type="text" style="display:none" name="colorPicker" data-palette=[';
			for(var i=0;i<colorInfos.length;i++)
				html+='{"'+Object.keys(colorInfos[i])+'":"'+Object.values(colorInfos[i])+'"},';
			html = html.substr(0, html.length-1);
			
			html+='] value="'+Object.keys(colorInfos[0])+':'+Object.values(colorInfos[0])+'">';
			$('#'+target).html(html);
			
			$('[name="colorPicker"]').paletteColorPicker();
			$('.palette-color-picker-bubble').attr("style","z-index:999");
		},
		/*
		 * 선택된 색상의 이름 : 16진수 색상값
		 */
		getSelectColor : function(){
			return $('[name="colorPicker"]')[0].value;
		},
		getSelectColorKey : function(){
			return $('[name="colorPicker"]')[0].value.split(':')[0];
		},
		getSelectColorVal : function(){
			return $('[name="colorPicker"]')[0].value.split(':')[1];
		},
		/*
		 * 색상의 초기값 선택 (색상 picker 초기화 시, 넘겼던 색상의 이름/ 없는 색상일 경우 처음 값으로 초기값 세팅됨)
		 */
		setSelectColor : function(colorName){
			colorName = colorName.replace("#", "");
			//colorName = colorName || "";
			colorName = (colorName == "default" || colorName == "") ? "5c7bf5" : colorName;
			$('[name="colorPicker"]').setColorPicker("#"+colorName);
			
			var dataPalette = $.parseJSON($('[name="colorPicker"]').attr("data-palette"));
			var colorVal = "";
			$(dataPalette).each(function(i){
				if($$(this).attr("default") != undefined){
					colorVal = $$(this).attr("default");
				} 
				
				if($$(this).attr(colorName) != undefined){
					colorVal = colorName + ":" + $$(this).attr(colorName);
					return false;
				}
			});
			
			$('[name="colorPicker"]').val(colorVal);
		},
		checkDates: function(parentId, obj){
			if ($("#" + parentId).find('input').eq(0).val() && $("#" + parentId).find('input').eq(1).val()) {
				var strSdate = $("#" + parentId).find('input').eq(0).val().replace(/[^0-9]/g, "");
				var strEdate = $("#" + parentId).find('input').eq(1).val().replace(/[^0-9]/g, "");
				if (strSdate > strEdate) {
				    alert(mobile_comm_getDic("msg_StartDateCannotAfterEndDate"));
				    $(obj).val("");
			    }
			}
		},
		selectChartPoint:function() {
			
			//간트차트 상세 이벤트
			if(mobile_move_flag()){	//중복방지
				var project_param = mobile_collab_project_param.get();
				var taskSeq = event.point.taskSeq;
		    	collabMobile.openTaskPopup("Y", project_param.prjSeq, taskSeq);
			}
		    
/*	
			//업무연결
	   	    var chart = this.series.chart;
	   	    var taskSeq = event.point.taskSeq;
	   	    var linkTaskSeq = event.point.linkTaskSeq;
	   	    
	   	    var objId=chart.series[0].name;
	   	    var prjType = objId.split("_")[0];
	   	    var prjSeq= objId.split("_")[1];

	   	    var x = event.chartX;
	   	    var y = event.chartY;

			if ($(event.srcElement).attr("class") == "chartTitle") return;
//	   	    $(".popup").css("left",x);
	   	    $(".popup").css("top",y);
		
		$( "#_popup" ).remove();
		$("body").append( $("<div>",{ id : "_popup" }) ).find("#_popup")
			.append( $("#gantLink-popup").text() )
			.on("click","#closeTodo",function(){									
				$( "#_popup" ).remove();
			})
			.on("change","#linkTaskSeq",function(){
				
				var data ={"taskSeq": $("#linkTaskSeq").data("taskSeq"),
							"linkTaskSeq":$("#linkTaskSeq  option:selected").val()};
				var aData = {"prjType":  $("#linkTaskSeq").data("prjType"), "prjSeq":  $("#linkTaskSeq").data("prjSeq")};	
				var objId = $("#linkTaskSeq").data("prjType")+'_'+$("#linkTaskSeq").data("prjSeq");

				if (aData["prjType"] == "todo"){
					aData["myTodo"]="Y";
					objId = "todo";
				}

				if ($("#linkTaskSeq").data("linkTaskSeq") == $("#linkTaskSeq  option:selected").val()){
					$.ajax({
						type:"POST",
						data: data,
						url:"/groupware/collabTask/deleteTaskLink.do",
						success: function(data) {
							$( "#_popup" ).remove();
							mobile_collab_project.getMyTask();
						},
						error:function (jqXHR, textStatus, errorThrown) {
							mobile_comm_ajaxerror("/groupware/collabTask/deleteTaskLink.do", jqXHR, textStatus, errorThrown);
						}
					});
				}
				else{
					$.ajax({
						type:"POST",
						data: data,
						url:"/groupware/collabTask/addTaskLink.do",
						success: function(data) {
							$( "#_popup" ).remove();
							mobile_collab_project.getMyTask();
						},
						error:function (jqXHR, textStatus, errorThrown) {
							mobile_comm_ajaxerror("/groupware/collabTask/addTaskLink.do", jqXHR, textStatus, errorThrown);
						}
					});
				}	
				
			});

	   	    setTimeout(function () {
		   	    $("#linkTaskSeq").data({"prjType":prjType, "prjSeq":prjSeq, "taskSeq": taskSeq, "linkTaskSeq":linkTaskSeq});
		   	    $("#linkTaskSeq").html($('<option>'));
		   	    Highcharts.each(chart.series[0].points, function (point) {
		   	    	if (taskSeq != point.taskSeq) {
		   	    		if (linkTaskSeq != point.taskSeq)
		   	    			$("#linkTaskSeq").append($('<option>',{"value":point.taskSeq}).text(point.name));
		   	    		else
		   	    			$("#linkTaskSeq").append($('<option style="color:red">',{"value":point.taskSeq}).text("[제거] "+point.name));
		   	    	}	
		   	    });

	   	    }, 10);
*/
	   	},
	   	dropChartPoint:function(data){
	   	    //event.preventDefault();

	   	    var chart = this.series.chart;
			var start = data.target.start 
			var end = 	data.target.end;
			var difference = end - start;
			var myTodo = data.target.myTodo;
			var objId =chart.series[0].name;
			var htCat = $("#"+objId+" .gannt-container").data();

			var sectionSeq = "";
			for(var index in htCat){
				if (htCat[index] == data.target.y){
					sectionSeq =  index;
					break;
				}
			};

	   	    var prjType = objId.split("_")[0];
	   	    var prjSeq= objId.split("_")[1];

	   		var taskData = {"prjType":prjType
	   			,"prjSeq":prjSeq
	   			,"taskSeq":data.target.taskSeq
				,"startDate": new Date(start).toISOString().substring(0,10).replace(/-/g,'')
				,"endDate": new Date(end).toISOString().substring(0,10).replace(/-/g,'')
			}
			
	   		if (myTodo != "Y"){
	   			taskData["sectionSeq"]=sectionSeq;
	   			taskData["TODO"]="N";
	   		} else {
	   			taskData["taskStatus"]=sectionSeq;
	   			taskData["TODO"]="Y";
	   		}
	   		
			$.ajax({
				type:"POST",
				data: taskData,
				url:"/groupware/collabTask/changeProjectTaskDate.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
				        //collabMain.getMyTask(objId, aData);
//						$('#'+objId+' .btnRefresh').trigger("click");
					}
					else{
						alert(mobile_comm_getDic("ACC_msg_error"));      // 오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (response, status, error){
					mobile_comm_ajaxerror("/groupware/collabTask/changeProjectTaskDate.do", response, status, error);
				}
			});
			
	   	},

		XSSBoard:function(body){
			var defaultFilterKey = "oncontextmenu,onmousemovexx,innerHTML,onmousewheel,onactive,onfocusxxout,expression,charset,ondataavailable,oncut,onkeyup,applet,onafteripudate,onclickxx,onkeypress,meta,string,onmousedownxx,onchange,onloadxx,xml,create,onbeforeactivate,onbeforecut,onbounce,blink,append,onbeforecopy,ondbclick,onmouseenter,link,binding,onbeforedeactivate,ondeactivate,onmouseout,ondatasetchaged,ondrag,onmouseoverxx,script,msgbox,cnbeforeprint,ondragendxx,onsubmit,embed,refresh,cnbeforepaste,ondragenter,onmouseend,object,void,onbeforeeditfocus,ondragleave,onresizexxstart,iframe,cookie,onbeforeuload,ondragover,onuload,frame,onbeforeupdate,ondragstart,onselectstart,frameset,onpaste,onpropertychange,ondrop,onreset,ilayer,onresize,ondatasetcomplete,onerrorxx,onmove,layer,onselect,oncellchange,onfinish,onstop,bgsound,base,onlayoutcomplete,onfocus,onrowexit,onblurxx,onselectionchange,vbscript,onerrorupdate,onbefore,onstart,onrowsinserted,onkeydownxx,onfilterchage,onmouseupxx,onfocusin,oncontrolselected,onrowsdelete,onlosecapture,onrowenter,onhelp,onreadystatechange,onmouseleave,onmousemove";
			var XSSFilterKey = mobile_comm_getBaseConfig("XSSFilterKey") ? mobile_comm_getBaseConfig("XSSFilterKey") : defaultFilterKey; // 기초설정 값 추가
			XSSFilterKey = XSSFilterKey + "," + "script,eval";
			XSSFilterKey = XSSFilterKey.replace(/\s/g, ""); // 공백 제거
			var XSSText = XSSFilterKey.split(",");				
		
			$.each(XSSText, function(idx, item){
				if(item){
					var regexAllCase = new RegExp("(</?[^>]*)"+ item +"([^>]*?>)", "gi");
					body = body.replace(regexAllCase, "$1x$2");
				}
			});
			
			return body;
	}
}



var mobile_collab_Init = function(){
	 const slider = $(".Twork_slider");
	  slider.slick({
	    slide:'div',		//슬라이드 되어야 할 태그 ex) div, li
	    infinite : false, 	//무한 반복 옵션
	    slidesToShow : 1,		// 한 화면에 보여질 컨텐츠 개수
	    slidesToScroll : 1,		//스크롤 한번에 움직일 컨텐츠 개수
	    speed : 1000,	 // 다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
	    arrows : false, 		// 옆으로 이동하는 화살표 표시 여부
	    dots : true, 		// 스크롤바 아래 점으로 페이지네이션 여부
	    autoplay : false,			// 자동 스크롤 사용 여부
	    autoplaySpeed : 4000, 		// 자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
	    pauseOnHover : false,		// 슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
	    vertical : false,		// 세로 방향 슬라이드 옵션
	    draggable : true, 	//드래그 가능 여부
	    centerMode : true,
	    centerPadding: '15px'
	  });

	  //Team, Project
	 
	  //메뉴선택 버튼
	  $(".column_btn").click(function(){
	    $(this).siblings(".column_menu").toggleClass("active");
	  });
	  
	  //To do List
	  $('#collab_portal_page').on('change','.Twork_todo input[type=checkbox]',function(e){
		if(mobile_move_flag()){
			var	params = {"taskSeq":$(this).data("taskSeq"),"taskStatus":$(this).is(':checked')};
			var obj = $(this);
			$.ajax({
		   		type:"POST",
		   		data:params,
		   		url:"/groupware/collabTask/changeProjectTaskStatus.do",
		   		success:function (res) {
					obj.prev().toggleClass("ui-checkbox-on");
					obj.parent().toggleClass('active');
		   		},
		   		error:function (request,status,error){
		   			alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
		   		}
			});
		}
	  });

	  //간편버튼
	  $(".btn_simple_write").click(function(){
	    $(this).parents().find(".simtask_box").toggleClass("pos");
	  });
	  $(".simbtn").click(function(){
	    if($(this).parents().find(".simtask_box").is(":hidden")==false){
	      $(this).toggleClass("active");
	      $(this).parents().find(".simtask_box").toggleClass("active");
	    }
	  });

	  /* 내업무 칸반 */
	  $(function() {
	    $(".card-fluid .column").sortable({
	    // 드래그 앤 드롭 단위 css 선택자
	    connectWith: ".column",
	    // 움직이는 css 선택자
	    //handle: ".card_cont",
		handle: '.handle',
	    // 움직이지 못하는 css 선택자
	    cancel: ".no-move",
	    // 이동하려는 location에 추가 되는 클래스
	    placeholder: "card_placeholder"
	    });
	    // 해당 클래스 하위의 텍스트 드래그를 막는다.
	    $( ".column .card" ).disableSelection();
	  });
}

//새로고침 클릭
var mobile_collab_clickrefresh = function() {
	 mobile_comm_showload(); 
	$('#mobile_search_input').val('');
	mobile_comm_hideload();
}

//확장메뉴 show or hide
var mobile_collab_showORhide = function(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

//검색 클릭
var mobile_collab_clicksearch = function() {
	mobile_collab_project.search();
}

//검색 닫기
var mobile_collab_closesearch = function() {
	mobile_comm_showload(); 
	$('#mobile_search_input').val('');	
	mobile_collab_project.search();
	mobile_comm_hideload();
}

//중복차단
var mobile_move_flag_param =  true; 
var mobile_move_flag = function(){
	if(mobile_move_flag_param){
		mobile_move_flag_param =  false; 
		setTimeout(function(){mobile_move_flag_param = true;}, 500);
		return true;
	} else {
		return false;
	} 
}

var getUTCTime = function(stndDate){
    		var today   =new Date(collabMobile.getDateFormat(stndDate));
	    	/*today.setUTCHours(0);
	    	today.setUTCMinutes(0);
	    	today.setUTCSeconds(0);
	    	today.setUTCMilliseconds(0);*/
    	    return new Date(collabMobile.getDateFormat(stndDate,"-"));//+"T09:00:00.000Z");
//    		return today;
}

//날짜 비교
var schedule_GetDiffDates = function(date1, date2, type) {
    //날짜 비교
    var ret = '';
    //소수점 발생
    var num_days = ((((date2 - date1) / 1000) / 60) / 60) / 24;
    var num_hours = ((((date2 - date1) / 1000) / 60) / 60);
    var num_minutes = (((date2 - date1) / 1000) / 60);

    switch (type) {
        case 'day': ret = num_days;
            break;
        case 'hour': ret = num_hours;
            break;
        case 'min': ret = num_minutes;
            break;
    }

    return ret;
}

//collab_start_date , collab_end_date 클릭시 창에 가려지는 문제 수정을 위해 처리
$(document).on("click", "#collab_start_date,#collab_end_date", function(){
	setTimeout(function(){
		var dateTop = $("#collab_start_date").offset().top;
		var datepickerTop = $("#ui-datepicker-div").offset().top;
		var clientHeight = $("#ui-datepicker-div")[0].clientHeight;
		var datepickerTopGap =  dateTop - datepickerTop - clientHeight;
	
		if(datepickerTopGap < 0){
			var datepickerCssTop = Number($("#ui-datepicker-div").css("top").replace("px",""));
	
			$("#ui-datepicker-div").css("top", (datepickerCssTop + datepickerTopGap) + "px" );
		}
	 }, 250);
});
