
var collabMain ={
	pageSize:50,
	objectInit:function(objId, aData){//초기 세팅
		collabMain.loadDatePicker(objId);

		if (parent.collabMenu.myConf["dashThema"] == "MODERN")
			$("#"+objId+" .Project_list_co").addClass("modern");
		
		if(parent.collabMenu == null){
			if (collabMenu.myConf["dashThema"] == "MODERN")
				$("#"+objId+" .Project_list_co").addClass("modern");
		}
		
		if (aData.myTodo != "Y"){
			if (aData.prjType != "P"){
				$("#"+objId+" .coBtn_list #column_menu").find("[data-only='P']").hide();
			}
			$("#"+objId+" .cRConTop .title span").text(aData.prjName);
			
			if(aData.prjPersonalName !="" && aData.prjPersonalName != null){
				var html = $("<h3 class='PersonalName'></h3>");
				$("#"+objId+" .cRConTop .title").append(html);
				$("#"+objId+" .PersonalName").text("("+aData.prjPersonalName+")");
				$("#"+objId+" .PersonalName").css({
					"display":"inline-block",
					"font-size":"16px",
					"vertical-align":"middle",
					"font-weight":"700",
					"color":"#666"
				});
			}
			
			$("#"+objId).data({"prjSeq":aData.prjSeq, "prjType":aData.prjType, "prjName":aData.prjName, "myTodo":"N","dataMode":"SEC", "dataView":"KANB"});
			this.getProjectMain(objId, aData);
		}	
		else{
			$("#"+objId).data({"myTodo":"Y","dataMode":"STAT", "dataView":"KANB","prjType":aData.prjType});
			if (aData.tagType == "TAG"){
				$("#"+objId).data({"tagType":"TAG", "tagVal":aData.tagVal});
			}
			this.getTodoMain(objId, aData);
		}
		this.addEvent(objId, aData);
	},
	loadDatePicker:function(objId){
		var today = new Date();	// 현재 날짜 및 시간
		
		$("#" + objId + " #date1").attr("id", objId+"_date1");
		$("#" + objId + " #date2").attr("id", objId+"_date2");
		$("#"+objId+"_date1").datepicker({
			dateFormat: 'yy-mm-dd',
			constrainInput: false, 
			changeMonth: true,
		    changeYear: true,
			onSelect:function(){
				$('#'+objId+' #btnSearch').trigger('click');
			},
		});
		$("#"+objId+"_date2").datepicker({
			dateFormat: 'yy-mm-dd',
			constrainInput: false, 
			changeMonth: true,
		    changeYear: true,
			minDate:$("#"+objId+"_date1").val(),
			onClose: function (selectedDate) {
				$("#"+objId+"_date1").datepicker("option", "maxDate", selectedDate);
				$('#'+objId+' #btnSearch').trigger('click');
			},
		});
		
		if (objId == "todo"){
			$("#"+objId+"_date2").datepicker('setDate', new Date(today.setMonth(today.getMonth() + 1)));
			$("#"+objId+"_date1").datepicker('setDate', new Date(today.setMonth(today.getMonth() - 2)));	// 한달 전;
			
			$("#" + objId + " #collab_status_date > strong").text($("#" + objId + "_date1").val() + " ~ " + $("#" + objId + "_date2").val());
		}
	},
	getProjectMain:function (objId, aData){
		var params = {"prjSeq":  aData.prjSeq, "prjType":  aData.prjType, "date1":$("#"+objId+"_date1").val(), "date2":$("#"+objId+"_date2").val()
				, "pageNo":1, "pageSize":collabMain.pageSize
				, "mode":$("#"+objId).closest('.cRContBottom').data("dataMode")};

		var gantScroll = -1;
		
		switch ($("#"+objId).closest('.cRContBottom').data("dataView")){	
			case "GANT":
			case "GANTN":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("gant_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("gant_edate");
				gantScroll = $("#dttab-1").scrollTop();
			break;
			case "CAL":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("cal_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("cal_edate");
			break;
		}
				
		$.ajax({
    		type:"POST",
    		data:params,
    		url:"/groupware/collabProject/getProjectMain.do",
    		success:function (data) {
    			collabMain.loadPrjectMain(objId, aData, data, params);
    			if(gantScroll !== null && gantScroll > 0)
    				$("#dttab-1").scrollTop(gantScroll);
    		},
    		error:function (request,status,error){
    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
    		}
    	});
	},
	getTodoMain:function(objId, aData){
		var params = {};
		
//		params["searchText"]=$("#todo #searchText").val();
		params["searchOption"]=$("#todo #searchOption").val();
		params["searchWord"]=$("#todo #searchWord").val();
		params["selWeek"]=$("#todo #selWeek").val();
		params["date1"]=$("#todo_date1").val();
		params["date2"]=$("#todo_date2").val();
		params["pageNo"]=1;
		params["pageSize"]=collabMain.pageSize;
		if (aData.tagType == "TAG"){
			params["tagType"]=aData.tagType;
			params["tagVal"]=aData.tagVal;
		}
		
		if(aData.isPotal == "Y"){	//포탈에서 넘어 왔을때 기간 검색 제외
			params["date1"]="";
			params["date2"]="";
			aData.isPotal = "";	//일회성
		}
		
		var gantScroll = -1;
		
		switch ($("#"+objId).closest('.cRContBottom').data("dataView")){	
			case "GANT":
			case "GANTN":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("gant_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("gant_edate");
				gantScroll = $("#dttab-1").scrollTop();
			break;
			case "CAL":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("cal_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("cal_edate");
			break;
		}
		
        $.ajax({
            type : "POST",
            url : "/groupware/collab/todo/myTaskList.do",
            data : params,
            success : function(res){
            	collabMain.loadTodoMain("todo", aData, res, params);
            	if(gantScroll !== null && gantScroll > 0)
            		$("#dttab-1").scrollTop(gantScroll);
            },
			error:function (request, status, error){
    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            }
        });
	},
	getTagTask: function(obj, v, t, p){
		var objId = $(obj).closest('.cRContBottom').attr("id");
		var params = $("#"+objId).data();
		$(obj).parent().siblings(".slick-current").removeClass("slick-current");
	   	$(obj).parent("li").addClass("slick-current");
	   	
	   	switch ($("#"+objId).closest('.cRContBottom').data("dataView")){	
			case "GANT":
			case "GANTN":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("gant_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("gant_edate");
				break;
			case "CAL":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("cal_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("cal_edate");
				break;
			default	:
				if ($("#" + objId + " #vChk").prop("checked") || (p != undefined && p == "Portal")){
					params["date1"] = "";
					params["date2"] = "";
				}else{
					params["date1"] = $('#'+objId+'_date1').val();;
					params["date2"] = $('#'+objId+'_date2').val();;
				}	
				break;
		}
		params["tagtype"]=v;
		params["tagval"]=t;
		params["pageNo"]=1;
		params["pageSize"]=collabMain.pageSize;
		params["mode"]=params["dataMode"];

		if ($("#" + objId + " #vChk").prop("checked")){
			params["noEndDate"]="Y";
		}else{
			params["noEndDate"]="";
		}
		
		$("#"+objId).data(params);

		switch (v){
			case "SURVEY":
				params["filterType"]="SURVEY";
				collabMain.getMySurvey(objId, params);
				break;
			case "FILE":
				collabUtil.searchTag(params, "/groupware/collabProject/getMyFile.do", function (res) {
	   				collabMain.loadMyFile(objId, res, params.myTodo, params);
		    	})
				break;
			case "APPROVAL":
				collabUtil.searchTag(params, "/groupware/collabProject/getCollabApprovalList.do", function (res) {
	   				collabMain.loadMyApproval(objId, res, params.myTodo);
		    	});
				break;
			default:
			
				//tag 검색 초기화
				$("#"+objId+" .calMonBody .calMonWeekRow .FirstLine tbody tr td").empty();
				$("#"+objId+" .calMonWeekRow .monShcList td").data({"1F":"0","2F":"0","3F":"0"});
				
				collabUtil.searchTag(params, "/groupware/collabProject/getMyTask.do", function (res) {
					if(params.prjType == "M"){
						collabMain.setTaskSummary(objId, res.taskStat);
					}else{
						collabMain.setTaskSummary(objId, res.taskStat.prjStat);
					}
	   				collabMain.loadMyTask(objId, res, params.myTodo, params);
		    	});
		    	
				break;
		}
	},
    loadTodoMain:function(objId, aData, data, params ){
        if(data.result === 'ok'){
    		collabMain.setTaskSummary(objId, data.taskStat);
        	collabMain.loadMyTask(objId, data, "Y", params);
        }    
    },
	loadPrjectMain:function(objId, aData, data, params ){
		if (aData.prjType == "P"){
			$("#"+objId+" .tabList ul").find("li[data-tab='tstab-5']").show();
			if (data.prjData.IsFav!=0) {
				$("#"+objId+" .btn_coStar").addClass("active")
			}
			$("#"+objId+" .btn_coStar").show();
			$("#"+objId+" #prjInfo").show();
			if ((data.prjAdmin == "Y" || data.prjMember == "Y") && Common.getSession("IsUseMessenger") == "Y"){
				$("#"+objId+" #btnChat").show();
			}	
		}	
		else{
			$("#"+objId+" .bg05").hide();
			$("#"+objId+" .btn_coStar").hide();
			$("#"+objId+" .Project_list_03").hide();
		}

		if (data.prjAdmin == "Y"){
			$("#"+objId+" #btnPrjFunc").show();
			$("#"+objId+" #btnSecPlus").show();
			$("#"+objId+" .tabList ul").find("li[data-tab='tstab-5']").show();
		}

		collabMain.setTaskSummary(objId, data.prjStat);
		
		$("#"+objId).data( "prjAdmin", data.prjAdmin );
		$("#"+objId).data( "prjMember", data.prjMember );
		$("#"+objId).data( "prjMemberList", data.memberList );
		$("#"+objId).data( "roomId", data.prjData.RoomId );
		
		$("#"+objId +" #selSection").empty().append($("<option value=''>ALL</option>"));
		data.taskFilter.map( function( item,idx ){
	        var option = $("<option value='"+item["SectionSeq"]+"'>"+item["SectionName"]+"</option>");
	        $("#"+objId +" #selSection").append(option);
		});

		$("#"+objId +" #selMember").empty().append($("<option value=''>ALL</option>"));
		data.memberList.map( function( item,idx ){
	        var option = $("<option value='"+item["UserCode"]+"'>"+item["DisplayName"]+"</option>");
	        $("#"+objId +" #selMember").append(option);
		});
		
		//업무 목록
    	collabMain.loadMyTask(objId, data, aData.myTodo, params);
	},
	getMyTask:function (objId, aData,  objectType){
		var params ={"prjSeq":  aData.prjSeq, "prjType":  aData.prjType, "myTodo":aData.myTodo
				, "date1":$("#"+objId+"_date1").val(), "date2":$("#"+objId+"_date2").val()
				, "searchOption":$("#"+objId+" #searchOption").val()
				, "searchWord":$("#"+objId+" #searchWord").val()
				, "searchText":$("#"+objId+" #searchText").val()
				, "completMonth":$("#"+objId+" #completMonth").val()
				, "mode":$("#"+objId).closest('.cRContBottom').data("dataMode")
				};
		if (objectType != undefined) params["objectType"]=objectType;
		switch ($("#"+objId).closest('.cRContBottom').data("dataView")){	
			case "GANT":
			case "GANTN":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("gant_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("gant_edate");
				params["sectionSeq"] = $("#"+objId +" #selSection").val();
				params["sectionName"] = $("#"+objId +" #selSection option:selected").text()
				params["memberId"] = $("#"+objId +" #selMember").val()
				break;
			case "CAL":
				params["date1"] = $("#"+objId).closest('.cRContBottom').data("cal_sdate");
				params["date2"] = $("#"+objId).closest('.cRContBottom').data("cal_edate");
				params["sectionSeq"] = $("#"+objId +" #selSection").val();
				params["sectionName"] = $("#"+objId +" #selSection option:selected").text()
				break;
		}
		
		var url = "";
		if(objId == "todo") {
			url = "/groupware/collabProject/getMyTask.do";
		} else {
			url = "/groupware/collabProject/getProjectMain.do";
		}
		
		$.ajax({
    		type:"POST",
    		data:params,
    		url:url,
    		success:function (data) {
				if(objId == "todo") collabMain.setTaskSummary(objId, data.taskStat);
				else collabMain.setTaskSummary(objId, data.prjStat);
				
    			collabMain.loadMyTask(objId, data, aData.myTodo, params);
    		},
    		error:function (request,status,error){
    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
    		}
    	});
	},
	setTaskSummary:function(objId, stat) {
		var procRate = 0; 

		$("#" + objId + " #enum").text(collabUtil.convertNull(stat.EmgCnt,0));
		$("#" + objId + " #lvlhnum strong").text(collabUtil.convertNull(stat.LvlHCnt,0));
		$("#" + objId + " #lvlmnum strong").text(collabUtil.convertNull(stat.LvlMCnt,0));
		$("#" + objId + " #lvllnum strong").text(collabUtil.convertNull(stat.LvlLCnt,0));
		$("#" + objId + " #wnum strong").text(collabUtil.convertNull(stat.WaitCnt,0));
		$("#" + objId + " #pnum strong").text(collabUtil.convertNull(stat.ProcCnt,0));
		$("#" + objId + " #hnum strong").text(collabUtil.convertNull(stat.HoldCnt,0));
		$("#" + objId + " #cnum strong").text(collabUtil.convertNull(stat.CompCnt,0));
		$("#" + objId + " #tnum").text(stat.TotCnt+"");
		$("#" + objId + " #dnum span").text(collabUtil.convertNull(stat.DelayCnt,0));
		
		if(stat.ProjRate != undefined) {
			ProcRate = stat.ProjRate;
		} else {
			ProcRate = stat.NowTotCnt == 0 ? 0 : Math.round(stat.NowCompCnt/stat.NowTotCnt*100);
		}
		
		$("#" + objId + " .bg05 .num").text(ProcRate);
		
		$("#" + objId + " .cNum").html(ProcRate+"<span>%</span>");
		$("#" + objId + " #pieDiv").css('transform', 'rotate(' + (3.6 * ProcRate) + 'deg)');	//	1%에 3.6deg, 180deg(50%)가 넘어 갈 경우 slice 에 gt50 클래스, 추가 로테이션 값은 pie에만 입력한다.
		if (ProcRate > 49) $("#" + objId + " #slice").addClass('gt50');
	},
	loadMyTask:function(objId, data, myTodo, params){
		if($("#" + objId + "_date1").val() != "" && $("#" + objId + "_date2").val() != "")
			$("#" + objId + " #collab_status_date > strong").text($("#" + objId + "_date1").val() + " ~ " + $("#" + objId + "_date2").val());
		
		if ($("#"+objId).closest('.cRContBottom').data("dataView") == "GANT"
			|| $("#"+objId).closest('.cRContBottom').data("dataView") == "GANTN"){
			
			var taskCnt = 0;
			data.taskData.map( function( taskList,idx ){
	    		taskList["list"].map( function( item,idx ){
					taskCnt++;
				});
			});
			
			//collabUtil.loadGantt("", $("#"+objId).closest('.cRContBottom').data("gant_dateType"), objId, data.taskData,  $("#"+objId).closest('.cRContBottom').data("gant_sdate"),  $("#"+objId).closest('.cRContBottom').data("gant_edate"), myTodo);
			if(taskCnt > 0)
				collabUtil.loadGantt($("#"+objId).closest('.cRContBottom').data("dataView"),$("#"+objId).closest('.cRContBottom').data("gant_dateType"), objId, data.taskData,  $("#"+objId).closest('.cRContBottom').data("gant_sdate"),  $("#"+objId).closest('.cRContBottom').data("gant_edate"), myTodo, data.taskFilter);
			else
				$("#"+objId+" .gannt-container").empty().append(collabUtil.getNoData("업무"));
			
		}else{	
			
			if (data.taskFilter.length >0){
				$('#'+objId+' .row').empty().append(
					data.taskFilter.map( function( item,idx ){
						var prjData = {"myTodo":myTodo, "prjAdmin":$('#'+objId).data("prjAdmin"),"prjMember":$('#'+objId).data("prjMember")}
						return collabMain.drawSection(item, prjData, $("#"+objId).closest('.cRContBottom').data("dataMode"), $("#"+objId).closest('.cRContBottom').data("dataView"));
					})
				);
			}
			else{
				$('#'+objId+' .row').empty();
			}

			$('#'+objId+' .row .card').remove();
			$('#'+objId+' .nodata_type03').remove();
			var dataView = $("#"+objId).closest('.cRContBottom').data("dataView"); 
			var dataMode = $("#"+objId).closest('.cRContBottom').data("dataMode"); 

			if (dataView== "LIST"){
//				$('#'+objId+' .row .cardBox_area').addClass("listBox_area").removeClass("cardBox_area");
				$('#'+objId+' .row .column01').addClass("active");
			}
			else{
//				$('#'+objId+' .row .listBox_area').addClass("cardBox_area").removeClass("listBox_area");
			}
			
			$('#'+objId+' .row').show();
			//타스크 콕록
			$('#'+objId+' .row .column_num').text(0);
			if (data.taskFilter.length >0){
	        	data.taskData.map( function( taskList,idx ){
	        		var page = taskList["page"];
	        		var key = "";
	        		if (taskList["list"].length>0){
	        			
	        			switch (dataMode){
		        			case "STAT":
			        			key = 'section_'+ taskList["key"];
			        			break;
		        			case "MEM":
					    		key = 'section_'+taskList["key"]["UserCode"];
	        					break;
	        				default:
					    		key = 'section_'+taskList["key"]["SectionSeq"];
	        					break;
	        			}		
			        		
			    		$('#'+objId+' .row #'+key+' .column_num').text(page["listCount"]);
		        		$('#'+objId+' .row #'+key+' .boxArea').data(params);
		        		
		        		taskList["list"].map( function( item,idx ){
		        			if (dataView == "CAL"){
								collabUtil.drawCalendarTask(objId, item, myTodo);
		        			}
		        			else{
		        				var objAddId= "";
			        			switch (dataMode){
				        			case "STAT":	
				        				objAddId = item.TaskStatus;//+' .cardBox_area .card_add').before(collabUtil.drawTask(item, myTodo=="Y"?"TODO":"", dataView,dataMode, item.authSave=="Y"?"Y":"N"));
										break;
				        			case "MEM":
					    				if (item.UserCode == null){
					    					objAddId =  "NONE";
					    				}
					    				else{
					    					objAddId = item.UserCode
					    				}	
					    				break;
				        			default :
					    				if (item.SectionSeq == null){
					    				}
				        				objAddId = item.SectionSeq;
//					    				$('#'+objId+' .row #section_'+item.SectionSeq + " .cardBox_area .card:last").after(collabUtil.drawTask(item,"",dataView, dataMode));
					    				break;
			        			}
			        			var objAddId= '#'+objId+' .row #section_'+objAddId;
			        			var dragMode = $("#"+objId).data( "prjAdmin") != "Y" && dataMode == "STAT" && item.authSave=="N"?"N":"Y";

			        			if ($(objAddId + " .boxArea .card_add").length == 0)
			        				$(objAddId + " .boxArea").append(collabUtil.drawTask(item,myTodo=="Y"?"TODO":"",dataView, dataMode, dragMode));
			        			else
			        				$(objAddId + " .boxArea .card_add").before(collabUtil.drawTask(item,myTodo=="Y"?"TODO":"",dataView, dataMode, dragMode));
		        			}	
						});
	        		}	
				});
			}
			/* 관리자나 
        	if ($("#"+objId).data( "prjAdmin") == "Y" ){
        		$('#'+objId+' .row').sortable({
    			    connectWith: ".row",
    			    handle: ".column",
    			    cancel: ".no-move",
    		    	start: function(event, ui) {
    		            ui.item.data('start_pos', ui.item.index());
    		        },
    		        receive: function(ev, ui) {
    		            if(ui.item.hasClass("number"))
    		               ui.sender.sortable("cancel");
    		        },
    		        stop: function(event, ui) {
    				}
    			});
        	}
        	*/
			//섹션 이동
			var moveCheck = "";
        	if ($("#"+objId).data( "prjAdmin") == "Y" && dataMode == "SEC" ){
			    $('#'+objId+' .card-fluid .row').sortable({
				    connectWith: ".card-fluid .column",
				    handle: ".header_drag",
				    cancel: ".no-move",
				    placeholder: "card_placeholder_big",
					start: function(event, ui) {
						moveCheck = "";
						$('#'+objId+' .card-fluid .row .column').each(function(i, ui) {	
							moveCheck += $(ui).data("sectionseq")+";";
						});
			        },
			        stop: function(event, ui) {
			        	sortParam = new Array();
						var moveCheck2 = "";
						$('#'+objId+' .card-fluid .row .column').each(function(i, ui) {	
							var sectionseq = $(ui).data("sectionseq");
							sortParam[i] = {"sectionorder":i, "sectionseq":sectionseq};
							moveCheck2 += $(ui).data("sectionseq")+";";
						});
						
						if(moveCheck == moveCheck2){
							//Common.Inform(Common.getDic("ACC_msg_noChange"));	//변경사항이 없습니다.
							return;
						}
		
						$.ajax({
							type:"POST",
							contentType: 'application/json; charset=utf-8',
							dataType: 'json',
							data: JSON.stringify({
								"prjSeq":ui.item.find(".card_cont").data("prjSeq")
								, "prjType":ui.item.find(".card_cont").data("prjType")
								, "sortParam":sortParam	
							}),
							url:"/groupware/collabProject/saveSectionMove.do",
							success:function (data) {
								/*if(data.status == "SUCCESS")
									Common.Inform(Common.getDic("msg_Changed"));	//변경되었습니다
								else
									Common.Error(Common.getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다*/
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					} 
			    });
        	}    
			
			//카드 이동
			if ($("#"+objId).data( "prjAdmin") == "Y" || objId == "todo" || dataMode == "STAT" ){
    			$('#'+objId+' .cardBox_area').sortable({
    			    connectWith: ".cardBox_area",
    			    handle: ".card_drag",
    			    cancel: ".no-move",
    			    placeholder: "card_placeholder",
    		    	start: function(event, ui) {
    		            ui.item.data('start_pos', ui.item.index());
    		        },
    		        receive: function(ev, ui) {
    		            if(ui.item.hasClass("number"))
    		               ui.sender.sortable("cancel");
    		        },
    		        stop: function(event, ui) {
    		        	var ordTaskArr = new Array();
    		        	var idx = ui.item.index();
    		        	
    		        	var workOrder = 0;
    		        	var objParent = ui.item.parents(".column");
    		        	var sectionSeq = objParent.data("sectionseq");

    		        	for (var i = 0; i< objParent.find(".card_cont").length; i++){
    		        		ordTaskArr.push({ "taskSeq":objParent.find(".card_cont").eq(i).data("taskSeq"), "workOrder":workOrder++, "todoOrder":workOrder});
    		        	}
    	
    		            $.ajax({
    		            	type:"POST",
    			        	contentType:'application/json; charset=utf-8',
    			    		dataType   : 'json',
    			    		data:JSON.stringify({"taskSeq": ui.item.find(".card_cont").data("taskSeq")
    			    			,"prjType": ui.item.find(".card_cont").data("prjType")
    			    			,"prjSeq": ui.item.find(".card_cont").data("prjSeq")
    			    			,"userCode": ui.item.find(".card_cont").data("userCode")
    		        			,"sectionSeq":sectionSeq
    		        			,"workOrder":workOrder
    		        			,"ordTask":ordTaskArr
    		        			,"myTodo":$("#"+objId).closest('.cRContBottom').data("myTodo")
    		        			,"mode":$("#"+objId).closest('.cRContBottom').data("dataMode")}),
    		        		url:"/groupware/collabTask/changeProjectTaskOrder.do",
    		        		success:function (data) {
    		        			collabMain.reloadMain(objId);
    		        		},
    		        		error:function (request,status,error){
    		        			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
    		        		}
    		        	});
    				}
    			});
        	}
		}
	},
	loadMyFile:function(objId, data, myTodo){
		var listType = $("#" + objId).closest(".cRContBottom").data("dataView");
		if (listType == "LIST")
			collabMain.loadMyFileByLIST(objId, data, myTodo);
		else
			collabMain.loadMyFileByKANB(objId, data, myTodo);
		
	},	
	getMyFile: function(objId, aData){
		var listType = $("#" + objId).closest(".cRContBottom").data("dataView");
		var params = {
  			  "prjSeq": aData.prjSeq
  			, "prjType": aData.prjType
  			, "myTodo": aData.myTodo
			, "filterType": "FILE"
			, "searchFile": $.trim($("#"+objId+" #searchFile").val())
			, "searchOption": $("#fileTag option:selected").data("opt")
		};
		
		$.ajax({
    		type: "POST",
    		url: "/groupware/collabProject/getMyFile.do",
    		data: params,
    		success: function(data){
    			if (listType == "LIST"){
	    			collabMain.loadMyFileByLIST(objId, data, aData.myTodo);
    			}
    			else{
    				collabMain.loadMyFileByKANB(objId, data, aData.myTodo);
    			}	
    		},
    		error: function(request,status,error){
    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
    		}
    	});
	},
	loadMyFileByLIST: function(objId, data, myTodo){
		var $fragment = $(document.createDocumentFragment());
		if (data.list.length >0){
			data.list.map(function(item, idx){
				var aData = $("#"+objId).closest('.cRContBottom').data()
				var prjName = aData.prjName;
				var sectionName = item.SectionName;
				var prjType;
				if (objId == "todo"){
					var objPrjDesc = item.PrjDesc.split("^");
					if (item.PrjDesc != "" && objPrjDesc.length>0){
					    prjType  =  objPrjDesc[0];
					    prjName = objPrjDesc[1] + (prjType=='K'?"[KR]":"");
						sectionName= objPrjDesc[3];
					}
					else{
						prjName = "My";
						sectionName = "";
					}
				}
				
				var cardData ={"taskSeq":item.TaskSeq, "prjSeq":item.PrjSeq, "prjType":item.PrjType, "objectType":item.ObjectType, "objectID":item.ObjectID, "parentKey":item.ParentKey, "taskName":item.TaskName, "serviceType":item.ServiceType};
				$fragment.append($("<tr>")
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center"}).append((item.authSave === 'Y' || item.FileRegisterCode === Common.getSession("USERID")) ?$("<a>", {"class": "body_del file_del"}).data("fileid", item.FileID):""))
							.append($("<td>",{"class":"bodyTdText","text":prjName}))
							.append($("<td>",{"class":"bodyTdText","text":item.ServiceType=="CollabPrj"?Common.getDic("lbl_PrjOverView"):sectionName}))
							.append($("<td>",{"class":"bodyTdText"}).append($("<a>",{"text":item.TaskName, "id":item.ServiceType=="CollabPrj"?"":"cardTitle", "data":cardData})))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center"}).append($("<div>",{"class": "body_category"}).append(collabMain.getFileIcon(item))))
							.append($("<td>",{"class":"bodyTdText"}).append($("<a>",{"class":"file_down","text":item.FileName}).data({"fileid": item.FileID, "filetoken": item.FileToken})))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":collabMain.convertFileSize(item.Size)}))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":item.FileRegistDate}))
						);
			});
		}else{
			$fragment.append(collabUtil.getNoList(8));
		}	

		$('#' + objId + ' .WebHardListType01.fileList01 tbody').empty().append($fragment);
	},
	loadMyFileByKANB: function(objId, data, myTodo){
		var $fragment = $(document.createDocumentFragment());

		if (data.list.length>0){
			data.list.map(function(item, idx){
				var cardData ={"taskSeq":item.TaskSeq, "prjSeq":item.PrjSeq, "prjType":item.PrjType, "objectType":item.ObjectType, "objectID":item.ObjectID, "parentKey":item.ParentKey, "taskName":item.TaskName,  "serviceType":item.ServiceType};
				var $fileWrap = $("<div/>", {"class": "WebHardList"});
				var $fileCategory = $("<a>",{"class": "body_category","id":item.ServiceType=="CollabPrj"?"":"cardTitle", "data":cardData}).append(collabMain.getFileIcon(item, "KANB"));
				var $fileTitle = $("<a/>", {"class": "body_title file_down", "href": "#", "html": (item.ServiceType=="Comment"?'<span class=ic_comment></span>':'')+(item.ServiceType=="CollabPrj"?'[P]':'')+item.FileName}).data({"fileid": item.FileID, "filetoken": item.FileToken});
				var $fileSize  = $("<p/>", {"class": "body_size", "text": item.Size});
				var $fileDate  = $("<p/>", {"class": "body_date", "text": CFN_TransLocalTime(item.FileRegistDate, "yyyy.MM.dd HH:mm")});
				
				$fileWrap.append($fileCategory).append($fileTitle).append($fileSize).append($fileDate);
				if (item.ServiceType=="CollabPrj"){
					$fileWrap.append( $("<a/>", {"class": "body_type", "text": Common.getDic("lbl_PrjOverView")}));
				}
				if(item.authSave === 'Y' || item.FileRegisterCode === Common.getSession("USERID")){
					var $fileDel = $("<a/>", {"class": "body_del file_del", "href": "#"}).data("fileid", item.FileID);
					$fileWrap.append($fileDel);
				}
				
				$fragment.append($fileWrap);
			});
		}else{
			$fragment.append(collabUtil.getNoData("파일"));

		}	
		
		$('#'+objId+' .WebHardListType02_div.kanb').empty().append($fragment);
		
		// 리스트 표시
		if(!$('#'+objId+' #tstab-2 .btnListView[data-tab=ftab-2]').hasClass("active")){
			$('#'+objId+' #tstab-2 .btnListView[data-tab=ftab-2]').addClass("active");
			$('#'+objId+' #tstab-2 #ftab-2').addClass("active");
		}
	},
	convertFileSize: function(pSize){
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (pSize == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
	    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
	},
	getFileIcon: function(item, mode){
		if ((mode && mode === "KANB") && item.SaveType === "IMAGE"){
			return $("<img>", {"class": "prevImg", "style": "width:40px; height:38px"}).attr("src", coviCmn.loadImageId(item.FileID));
		}
		else{
			return $("<span>", {"class": collabUtil.getFileClass(item.Extention)});
		}
	},
	getMySurvey: function(objId, aData){
		var listType = $("#" + objId).closest(".cRContBottom").data("dataView");
		var tab_id = $('#'+objId+' .tabList ul .active').attr('data-tab');
		var tagData = "";
		var thisVal = $('#' + objId + ' #surveyTag').val();
	 	$('#' + objId + ' #surveyTag option').each(function (i, v) {
			var item = $(v);
			if (thisVal== item.text()){
				tagData = item.attr("data");
				return;
			}	
		});

	 	
		var params = {
			  "prjSeq": aData.prjSeq
			, "myTodo": aData.myTodo
			, "searchSurvey": $.trim($("#"+objId+" #searchSurvey").val())		
		};

		if (tagData!=null && tagData!="" && tagData!="undefined" && tagData!="#"){
			params["tagtype"]=  "SURVEY";
			params["tagval"] =  tagData;
		}

		$.ajax({
			type: "POST",
			url: "/groupware/collabProject/getCollabSurveyList.do",
			data: params,
    		success: function(data){
    			if (listType == "LIST"){
	    			collabMain.loadMySurveyByLIST(objId, data, aData.myTodo);
    			}
    			else{
	    			collabMain.loadMySurveyByKANB(objId, data, aData.myTodo);
    			}
    		},
    		error: function(request, status, error){
    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    		}
    	});
	},
	loadMySurveyByLIST: function(objId, data, myTodo){
		var $fragment = $(document.createDocumentFragment());
		if (data.list.length>0){
			data.list.map(function(item, idx){
				var stateTxt = "";
				var stateClass = "";

				switch(item.State){
					case "A":
						stateTxt = coviDic.dicMap["lbl_SurveyWriting"]; // 작성중
						stateClass = "survey_writting";
						break;
					case "F":
					case "C":
						stateTxt = coviDic.dicMap["lbl_Progressing"]; // 설문 진행중
						stateClass = "survey_ing";
						break;
					case "G":
						stateTxt = coviDic.dicMap["lbl_Completed"]; // 설문 종료
						stateClass = "survey_done ";
						break;
				};
				$fragment.append($("<tr>")
							.append($("<td>",{"class":"","style":"text-align:left"}).append($("<span>", {"class": "list_state " + stateClass, "text": stateTxt})).append($("<strong>", {"class": "list_type type02", "text": (item.PrjType === "P" ? "Project" : "Team")})).append(item.Subject))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":item.StartDate + " ~ " + item.EndDate}))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":item.RegisterName}))
							.append($("<td>")
									.append($("<div>",{"class":"participationRateBar"}).append($("<div>",{"style":"width:"+ item.JoinRate+"%;"})))
									.append($("<span>",{"text":Math.floor(item.JoinRate) + "%"})))
							.append($("<td>")
									.append($("<a>",{"class":"btnSurPartiPortTbl btnTypeDefault surveyPopup","text":"결과보기"}).data("surveyInfo", {"SurveyID": item.SurveyID, "State": item.State, "IsResponse":item.IsResponse, "PrjType":item.PrjType, "PrjSeq":item.PrjSeq})))
						);
			});
		}else{
			$fragment.append(collabUtil.getNoList(5));
		}
		$('#' + objId + ' .survey_area.list tbody').empty().append($fragment);
	},
	loadMySurveyByKANB: function(objId, data, myTodo){
		var $fragment = $(document.createDocumentFragment());
		var $cardTemp = $("<div>", {"class": "card card_survey  surveyPopup"})
							.append($("<div>", {"class": "card_cont"})
								.append($("<div>", {"class": "card_state"}))
								.append($("<div>", {"class": "card_img"})
									.append($("<img>", {"src": "/HtmlSite/smarts4j_n/collaboration/resources/images/sample02.jpg", "alt": "", "onerror": "coviCmn.imgError(this);"}))));
		
		Common.getDicList(["lbl_SurveyWriting", "lbl_SurveyInProgress", "lbl_SurveyEnd", "lbl_Survey_period", "lbl_Progressing", "lbl_Completed"]);
		
		if (data.status != "FAIL" && data.list.length > 0){
			data.list.map(function(item, idx){
				var stateTxt = "";
				var stateClass = "";
				switch(item.State){
					case "A":
						stateTxt = coviDic.dicMap["lbl_SurveyWriting"]; // 작성중
						stateClass = "survey_writting";
						break;
					case "F":
					case "C":
						stateTxt = coviDic.dicMap["lbl_Progressing"]; // 설문 진행중
						stateClass = "survey_ing";
						break;
					case "G":
						stateTxt = coviDic.dicMap["lbl_Completed"]; // 설문 종료
						stateClass = "survey_done ";
						break;
				};
				
				var $cardWrap		= $cardTemp.clone().addClass((item.PrjType === "P" ? "type02" : "type01")).data("surveyInfo", {"SurveyID": item.SurveyID, "State": item.State, "IsResponse":item.IsResponse, "PrjSeq":item.PrjSeq, "PrjType":item.PrjType});
				var $cardType		= $("<div>", {"class": "card_top"})
										.append($("<strong>", {"class": "card_type", "text": (item.PrjType === "P" ? "Project" : "Team")}));
				var $cardTitle		= $("<strong>", {"class": "card_title", "text": item.Subject});
				var $cardInfo		= $("<div>", {"class": "card_info"})
										.append($("<a>", {"class": "card_people", "href": "#", "text": item.RespondentCnt}))
										.append($("<a>", {"class": "card_comment", "href": "#", "text": item.CommentCnt}));
				var $cardPeriod		= $("<div>", {"class": "card_period"})
										.append($("<strong>", {"text": coviDic.dicMap["lbl_Survey_period"]})) // 설문기간
										.append($("<span>", {"text": item.StartDate + " ~ " + item.EndDate}));
				var $cardProgress	= $("<div>", {"class": "card_progress"})
										.append($("<div>", {"class": "card_pgbox"})
											.append($("<div>", {"class": "card_pgbar", "style": "width:" + item.JoinRate + "%;"})))
										.append($("<div>", {"class": "card_pgnum"})
												.append($("<span>", {"text": Math.floor(item.JoinRate) + "%"})));
				
				$cardWrap.addClass(stateClass);
				$cardWrap.find(".card_state").append($("<span>", {"text": stateTxt}));	
				
				$cardWrap.find(".card_cont").append($cardType).append($cardTitle).append($cardInfo).append($cardPeriod).append($cardProgress);
				$fragment.append($cardWrap);
			});
		}else{
			$fragment.append(collabUtil.getNoData(Common.getDic("lbl_Profile_Questions"))); //설문
			
		}	
		
		$('#' + objId + ' .survey_area.kanb').empty().append($fragment);
		
		/* 리스트 표시
		if(!$('#'+objId+' #tstab-4 .btnListView[data-tab=stab-2]').hasClass("active")){
			$('#'+objId+' #tstab-4 .btnListView[data-tab=stab-2]').addClass("active");
			$('#'+objId+' #tstab-4 #stab-2').addClass("active");
		}*/
	},
	openSurveyPopup: function(pSurveyInfo){
		var popupID, popupTit, popupUrl;
		var viewType = "resultView";

		popupID		= "CollabSurveyViewPopup";
		popupTit	= Common.getDic("lbl_surveyResultView"); // 설문 결과 조회
		popupUrl	= "/groupware/survey/goSurveyCollabViewPopup.do?CLSYS=survey&CLMD=user&CLBIZ=Survey"
					+ "&viewType=" + viewType
					+ "&isPopup=Y"
					+ "&surveyId=" + pSurveyInfo.SurveyID
					;
		switch(pSurveyInfo.State){
			case "A":
				popupID		= "CollabSurveyWritePopup";
				popupTit	= Common.getDic("lbl_surveyTempSave"); // 설문 임시저장
				popupUrl	= "/groupware/survey/goSurveyCollabWritePopup.do?CLSYS=survey&CLMD=user&CLBIZ=Survey"
							+ "&reqType=tempSave"
							+ "&prjType=" + pSurveyInfo.PrjType
							+ "&prjSeq=" + pSurveyInfo.PrjSeq
							+ "&surveyId=" + pSurveyInfo.SurveyID
							;
				break;
			case "F":
				if (pSurveyInfo.IsResponse == "N" ){
					viewType = "myAnswer";
				}else	if (pSurveyInfo.IsAnswer == "Y"){
					viewType = "resultView";
				}
				else{
					popupID		= "CollabSurveyPopup";
					popupTit	= Common.getDic("lbl_surveyJoin"); // 설문 참여
					popupUrl	= "/groupware/survey/goSurvey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey"
								+ "&reqType=join"
								+ "&isPopup=Y"
								+ "&surveyId=" + pSurveyInfo.SurveyID
								;
				}	
				break;
			case "C":
				viewType = "myAnswer";
				break;
		};

		Common.open("", popupID, popupTit, popupUrl, "1000px", "600px", "iframe", true, null, null, true);
	},
	openSurveyResultPopup: function(pSurveyID){
		Common.open("", "viewReport", Common.getDic("lbl_Survey_Statistics"), "/groupware/surveyAdmin/goSurveyReport.do?isPopup=y&type=user&surveyId="+pSurveyID, "800px", "500px", "iframe", true, null, null, true, "UA"); // 설문통계
	},
	getMyApproval: function(objId, aData){
		var listType = $("#" + objId).closest(".cRContBottom").data("dataView");
		$.ajax({
			type: "POST",
			url: "/groupware/collabProject/getCollabApprovalList.do",
			data:{
				  "prjSeq" : aData.prjSeq
				, "myTodo" : aData.myTodo
				, "tagtype" : aData.tagtype
				, "tagval" : aData.tagval
				, "searchApproval": $.trim($("#"+objId+" #searchApproval").val())		
			},
    		success: function(data){
    			if (listType == "LIST"){
	    			collabMain.loadMyApprovalByLIST(objId, data, aData.myTodo);
    			}
    			else{
	    			collabMain.loadMyApprovalByKANB(objId, data, aData.myTodo);
    			}
    		},
    		error: function(request, status, error){
    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    		}
    	});
	},
	loadMyApproval:function(objId, data, myTodo){
		var listType = $("#" + objId).closest(".cRContBottom").data("dataView");
		if (listType == "LIST")
			collabMain.loadMyApprovalByLIST(objId, data, myTodo);
		else
			collabMain.loadMyApprovalByKANB(objId, data, myTodo);
	},
	loadMyApprovalByLIST: function(objId, data, myTodo){
		var $fragment = $(document.createDocumentFragment());
		if (data.list.length>0){
			data.list.map(function(item, idx){
				$fragment.append($("<tr>")
							.append($("<td>",{"class":"bodyTdText","text":item.PrjName}))
							.append($("<td>",{"class":"bodyTdText","text":item.SectionName}))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":item.DisplayName}))
							.append($("<td>",{"class":"bodyTdText"}).append($("<a>",{"id":"card_approval","text":item.TaskName}).data("approvalInfo", {"taskSeq": item.TaskSeq, "formInstID": item.FormInstID})))
							.append($("<td>",{"class":"bodyTdText","text":item.InitiateDateStr}))
						);
			});
		}else{
			$fragment.append(collabUtil.getNoList(5));
		}
		$('#' + objId + ' .approval_area.list tbody').empty().append($fragment);
	},	
	loadMyApprovalByKANB: function(objId, data, myTodo){
		var $fragment = $(document.createDocumentFragment());
		if (data.list.length>0){
			data.list.map(function(item, idx){
				var $div = $("<div>", {"class":"card_approval","id":"card_approval"}).data("approvalInfo", {"taskSeq": item.TaskSeq, "formInstID": item.FormInstID});

				var appendHtml = new collabUtil.StringBuffer();
				appendHtml.append("<a>");
				appendHtml.append(	"<strong class='ca_tit'>");
				appendHtml.append(	item.TaskName);
				appendHtml.append(	"</strong>");
				appendHtml.append(	"<div class='ca_info'>");

				var userObj = {
						"PhotoPath" : item.PhotoPath
						,"code" : item.UserCode
						,"DisplayName" : item.DisplayName
				};
				appendHtml.append(collabUtil.drawProfile(userObj)[0].outerHTML);

				appendHtml.append(	"	<ul>");
				appendHtml.append(	"		<li><strong>" + Common.getDic("lbl_apv_writer") + "</strong><span class='ca_name'>" + item.DisplayName + "</span></li>"); //기안자
				appendHtml.append(	"		<li><strong>" + Common.getDic("lbl_apv_reqdate") + "</strong><span class='ca_date'>" + item.InitiateDateStr + "</span></li>");	//기안일
				appendHtml.append(	"	</ul>");
				appendHtml.append(	"</div>");

				$div.append(appendHtml.toString());
				$fragment.append($div);
			});
		}else{
			$fragment.append(collabUtil.getNoData(Common.getDic("lbl_apv_app"))); //결재
		}	
		$('#' + objId + ' .approval_area.kanb').empty().append($fragment);
/*
		$target_kanban.show();*/
	},
	getReportDay: function(objId, pageNO) {
		var aData =$("#"+objId).data();
		var currentDateText = $("#"+objId+" #rptab-1 #reportCal .title").text();
		$.ajax({
			type: "POST",
			url: "/groupware/collabReport/getProjectReportDayList.do",
			data: {
				"prjSeq": aData.prjSeq
				, "prjType": aData.prjType
				, "reportDate": schedule_SetDateFormat(currentDateText, '')
			},
			success: function (data) {
				collabMain.loadReportDayList(objId, data);
			},
			error: function (request, status, error) {
				Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
			}
		});
	},
	loadReportDayList: function(objId, data) {
		var obj = $(document.createDocumentFragment());
		
		if (data.reportDayList != null && data.reportDayList.length != 0) {
			var prevUserID="";
			data.reportDayList.map(function(item, idx){	
				obj.append($("<tr>")
						.append(prevUserID != item.UserCode?$("<td>",{"class":"bodyTdText","style":"text-align:center","text":CFN_GetDicInfo(item.UserName, lang),"rowSpan":item.RowCount}):"")
						.append($("<td>",{"class":"bodyTdText","style":"text-left"}).append($("<a>",{"class":"icoReportPop","data": {"daySeq":item.DaySeq},"html":collabUtil.getTaskStatus(item)})))
						.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.ProgRate,"")}))
						.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.TaskTime,"")}))
						.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.Remark,"")}))
					);
				prevUserID = item.UserCode;
			});

		} else {
			obj.append(collabUtil.getNoList());
		}

		$("#" + objId + " #reportDayTableContents  tbody").empty().append(obj);
		
		
	},	
	getReportWeek: function(objId, pageNo) {
		var aData =$("#"+objId).data();

		var startDate =$("#"+objId+" #rptab-2 #reportCal .title").data("sDate");
		var endDate = $("#"+objId+" #rptab-2 #reportCal .title").data("eDate");

		$.ajax({
			type: "POST",
			url: "/groupware/collabReport/getReportWeekData.do",
			data: {
				"prjSeq": aData.prjSeq
				, "prjType": aData.prjType
				, "startDate": schedule_SetDateFormat(startDate, '')
				, "endDate": schedule_SetDateFormat(endDate, '')
			},
			success: function (data) {
				collabMain.loadReportWeekList(objId, data);
			},
			error: function (request, status, error) {
				Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
			}
		});
	},
	loadReportWeekList: function(objId, data) {
		var obj = $(document.createDocumentFragment());
		
		if (data.reportWeekList != null && data.reportWeekList.length != 0) {
			var prevUserID="";
			data.reportWeekList.map(function(item, idx){	
				obj.append($("<tr>")
						.append($("<td>",{"class":"bodyTdText","style":"text-align:center"})
							.append($("<a>",{"class": "dayReportDtl","text":CFN_GetDicInfo(item.UserName, lang),"data": item}))
						)
						//.append($("<td>",{"class":"bodyTdText","style":"text-left"}).append($("<a>",{"class":"icoReportPop","data": {"daySeq":item.DaySeq},"html":collabUtil.getTaskStatus(item)})))
						.append($("<td>",{"class":"bodyTdText"})
							.append($("<pre>", {"text":coviCmn.convertNull(item.WeekRemark,"")}))
						)
						.append($("<td>",{"class":"bodyTdText"})
							.append($("<pre>", {"text":coviCmn.convertNull(item.NextPlan,"")}))
						)
					);
				prevUserID = item.UserCode;
			});

		} else {
			obj.append(collabUtil.getNoList(3));
		}

		$("#" + objId + " #reportWeekTableContents  tbody").empty().append(obj);
		
		
	},	
	addEvent:function(objId, aData){
		$(document).off('click','#'+objId+' #btnPrjFunc').on('click','#'+objId+' #btnPrjFunc',function(){
			$(this).siblings("#column_menu").toggleClass("active");
	    });
	    
		//업무검색시
		$('#'+objId+' #btnSearch, #'+objId+' #icoSearch' ).on( 'click',aData, function(e){
			/*if ($('#'+objId+' #taskTag').val().indexOf("#")!= -1){
				$('#'+objId+' #taskTag option:eq(0)').attr('selected', 'selected');
			}
			
			if ($('#'+objId+' #taskTagInput').val() == "" 	|| $('#'+objId+' #taskTagInput').val().indexOf("#")!= -1
					|| $.trim($('#'+objId+' #searchWord' ).val()) == ""){
				Common.Error(Common.getDic("lbl_apv_searchcomment_Warning"));
		 		return ;
		 	}*/
			
			if ($("#"+objId+"_date1").val() != "" && $("#"+objId+"_date2").val() == ""){
				Common.Inform(Common.getDic("msg_EnterEndDate"));	//종료일자를 입력하세요
		 		return ;
		 	}
			if ($("#"+objId+"_date1").val() == "" && $("#"+objId+"_date2").val() != ""){
				Common.Inform(Common.getDic("msg_EnterStartDate"));	//시작일자를 입력하세요
		 		return ;
		 	}
        	if (aData.myTodo != "Y"){
    			collabMain.getMyTask(objId, aData);
    		}	
    		else{
    			collabMain.getTodoMain(objId, aData);
    		}
		});
		
		//파일검색
		$('#'+objId+' #btnSearchFile').on( 'click',aData, function(e){
			if ($('#'+objId+' #fileTag').val() == ""){
				Common.Error(Common.getDic("lbl_apv_searchcomment_Warning"));
		 		return ;
		 	}
   			collabMain.getMyFile(objId, aData);
		});
		//결재검색
		$('#'+objId+' #btnSearchApproval').on( 'click',aData, function(e){
			if ($('#'+objId+' #approvalTag').val() == "" ){
				Common.Error(Common.getDic("lbl_apv_searchcomment_Warning"));
		 		return ;
		 	}

   			collabMain.getMyApproval(objId, aData);
		});
		//설문검색
		$('#'+objId+' #btnSearchSurvey').on( 'click',aData, function(e){
			if ($('#'+objId+' #surveyTag').val() == ""){
				Common.Error(Common.getDic("lbl_apv_searchcomment_Warning"));
		 		return ;
		 	}
   			collabMain.getMySurvey(objId, aData);
		});
		
		
		/*tag filter
		$('#'+objId+' #taskTag').on( 'change',aData, function(e){
			collabMain.getTagTask(this,"TAG",$(this).val())
		
		});
		*/
		//즐겨찾기
		$("#"+objId+" #btnFav").on( 'click',function(){
			collabUtil.btnFavEvent(objId, aData.prjSeq, this);
		});
		
		//엔터검색(업무)
		$('#'+objId+' #searchWord' ).on('keypress', function(e){ 
			if (e.which == 13) {
				if (aData.myTodo != "Y")
	    			collabMain.getMyTask(objId, aData);
	    		else
	    			collabMain.getTodoMain(objId, aData);
		    }
		});
		
		//엔터검색(파일)
		$('#'+objId+' #searchFile' ).on('keypress', function(e){ 
			if (e.which == 13) {
				$('#'+objId+' #btnSearchFile').trigger( 'click');
		    }
		});
		//엔터검색(결재)
		$('#'+objId+' #searchApproval' ).on('keypress', function(e){ 
			if (e.which == 13) {
				$('#'+objId+' #btnSearchApproval').trigger( 'click');
		    }
		});
		//엔터검색(설문)
		$('#'+objId+' #searchSurvey' ).on('keypress', function(e){ 
			if (e.which == 13) {
				$('#'+objId+' #btnSearchSurvey').trigger( 'click');
		    }
		});
		
		

        //복사화면
        $('#'+objId+' #btnCopy').on( 'click',aData, function(e){
        	$(this).parents("#column_menu").removeClass("active");
			var popupID	= "CollabProjectCopyPopup";
			var openerID	= "";
			var popupTit	= "["+aData.prjName+"] "+ Common.getDic("ACC_btn_copy");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/collabProject/CollabProjectCopyPopup.do?"
							+ "&prjSeq="    + aData.prjSeq
							+ "&prjType="    + aData.prjType
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&popupYN="		+ popupYN	
							+ "&callBackFunc="	+ callBack	;
			Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);
        });
        //프로젝트 개요화면
        $('#'+objId+' #prjInfo').on( 'click',aData, function(e){
        	if (aData.prjType != "P") return;
        	$(this).parents("#column_menu").removeClass("active");
			var popupID	= "CollabProjectPopup";
			var openerID	= "";
			var popupTit	= "["+aData.prjName+"] "+ Common.getDic("lbl_PrjOverView");		//프로젝트 개요
			var popupYN		= "N";
			var popupUrl	= "/groupware/collabProject/CollabProjectPopupView.do?"
							+ "&prjSeq="    + aData.prjSeq
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&objId="+objId
							+ "&popupYN="		+ popupYN	;
			Common.open("", popupID, popupTit, popupUrl, "720px", "825px", "iframe", true, null, null, true);
        });
        //상세
        $('#'+objId+' #btnPrjPop').on( 'click',aData, function(e){
	    	if (aData.prjType != "P") return;
	    	$(this).parents("#column_menu").removeClass("active");
			var popupID	= "CollabProjectPopup";
			var openerID	= "";
			var popupTit	= "["+aData.prjName+"] "+ Common.getDic("lbl_change");		//프로젝트 상세
			var popupYN		= "N";
			var popupUrl	= "/groupware/collabProject/CollabProjectPopup.do?"
							+ "&prjSeq="    + aData.prjSeq
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&objId="+objId
							+ "&popupYN="		+ popupYN	;
			Common.open("", popupID, popupTit, popupUrl, "720px", "825px", "iframe", true, null, null, true);
	    });
        //초대
        $('#'+objId+' #btnInvite').on( 'click',aData, function(e){
        	$(this).parents("#column_menu").removeClass("active");
        	var item =$('#'+objId).data( "prjMemberList") ;// $(jsonData.item).each(function(i){
        	var trgMemberArr = new Array();
 
		 	$(item).each(function (i, v) {
				var saveData = { "itemType":"user", "UserID":v.UserID, "UserCode":v.UserCode, "LV":v.LV, "PO":v.PO, "TL":v.TL, "DN":v.DisplayName, "RGNM":v.DeptName, "ETNM":v.ETNM, "Dis":true};
				trgMemberArr.push(saveData);
			});

        	initData["item"] = trgMemberArr;
			var popupID	= "CollabProjectInvitePopup";
			var openerID	= "";
			var popupTit	= "["+aData.prjName+"] "+ Common.getDic("TodoMsgType_Invited");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";
			var callBack	= "ProjectInvite_CallBack";
			var popupUrl	= "/covicore/control/goOrgChart.do?type=B9&treeKind=Group&groupDivision=Basic&drawOpt=_MARB"
							+ "&userParams="    + objId
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&popupYN="		+ popupYN
							+ "&setParamData=initData"
							+ "&callBackFunc="	+ callBack	;
			Common.open("", popupID, popupTit, popupUrl, "1000px", "600px", "iframe", true, null, null, true);
			
        });
        
        //템플릿으로 저장
        $('#'+objId+' #btnSaveTempl').on( 'click',aData, function(e){
        	$(this).parents("#column_menu").removeClass("active");
			var popupID	= "CollabProjectTmplPopup";
			var openerID	= "";
			var popupTit	= "["+aData.prjName+"] ";//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";
			var callBack    = "";
			var popupUrl	= "/groupware/collabProject/CollabProjectTmplPopup.do?"
				+ "&prjSeq="    + aData.prjSeq
				+ "&prjName="    + encodeURIComponent(aData.prjName)
				+ "&popupID="		+ popupID	
				+ "&openerID="		+ openerID	
				+ "&popupYN="		+ popupYN	
				+ "&callBackParam="	+ callBack	;
			Common.open("", popupID, popupTit, popupUrl, "500px", "350px", "iframe", true, null, null, true);
			
        });
        //삭제
        $('#'+objId+' #btnDel').on( 'click',aData, function(e){
        	$(this).parents("#column_menu").removeClass("active");
        	Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
        		if (confirmResult) { 
                	$.ajax({
                		type:"POST",
                		data:{"prjSeq":  aData.prjSeq},
                		url:"/groupware/collabProject/deleteProject.do",
                		success:function (data) {
                			if(data.status == "SUCCESS"){
                				Common.Inform(Common.getDic("msg_com_processSuccess"));	//
            					$("#content #P_"+aData.prjSeq).remove();
            					$("#tab_P_"+aData.prjSeq).remove();
            					$("#list_P_"+aData.prjSeq).parent().remove();
            					$("#list_F_"+aData.prjSeq).parent().remove();
            					$("#fixTab").click();
                			}
                			else{
                				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
                			}
                		},
                		error:function (request,status,error){
                			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
                		}
                	});
	        	}
        	});
        });
        
        //마감
        $('#'+objId+' #btnClose').on( 'click',aData, function(e){
        	$(this).parents("#column_menu").removeClass("active");
        	Common.Confirm( Common.getDic("msg_CloseTheProject") + " <br><a class='txt_red'>(" + Common.getDic("msg_CancelAfterClosing") + ")</a>", "Confirmation Dialog", function (confirmResult) { //해당 프로젝트(팀)을 마감하시겠습니까? 마감 후 해제불가/ 차년도 OKRA 자동생성
        		if (confirmResult) { 
                	$.ajax({
                		type:"POST",
                		data:{"execYear":aData.prjType.substring(1), "prjSeq":  aData.prjSeq, "prjType":aData.prjType},
                		url:"/groupware/collabProject/closeProjectTeam.do",
                		success:function (data) {
                			if(data.status == "SUCCESS"){
                				Common.Inform(Common.getDic("msg_com_processSuccess"));	//
            					$("#content #P_"+aData.prjSeq).remove();
            					$("#tab_P_"+aData.prjSeq).remove();
            					$("#list_P_"+aData.prjSeq).parent().remove();
            					$("#fixTab").click();
                			}
                			else{
                				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
                			}
                		},
                		error:function (request,status,error){
                			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
                		}
                	});
	        	}
        	});
        });
        
        //새로고침
        $('#'+objId+' .btnRefresh').on( 'click',aData, function(e){
			//달력 초기화
			if($('#' + objId + ' #tstab-1').hasClass("active")){
				$('#' + objId + ' #tstab-1 .btn .btnListView').each(function (i, v) {
					if($(v).hasClass("active") && $(v).attr('data-view') == "CAL"){
						$('#' + objId + ' #calTab li').removeClass("selected").eq(0).addClass("selected");
						collabUtil.changeDisplayMode($(v).attr('data-tab'), $(v).closest('.cRContBottom').attr("id"), $(v).attr('data-view'), $(v));
					}
				});
			}
	
        	$("#"+objId).data("tagval","");
        	$("#"+objId +" #taskTagInput").val("");
        	$("#" + objId + " #vChk").prop("checked", false);
        	
        	if (aData.myTodo != "Y"){
            	collabMain.getProjectMain(objId, aData);
    		}	
    		else{
    			collabMain.getTodoMain(objId, aData);
    		}
        });

        //채팅룸
        $('#'+objId+' #btnChat').on( 'click',aData, function(e){
        	if ($("#"+objId).data( "roomId") == null || $("#"+objId).data( "roomId") == ""){
	        	$.ajax({
	        		type:"POST",
	        		data:{"execYear":aData.prjType.substring(1), "prjSeq":  aData.prjSeq, "prjType":aData.prjType},
	        		url:"/groupware/collabProject/goProjectChat.do",
	        		success:function (data) {
	        			if (data.status == "SUCCESS") {
		        			$("#"+objId).data( "roomId",data.roomId);
		        			window.open("eumtalk://open/channel?roomId=" + data.roomId);
	        			}else{
		        			Common.Error(Common.getDic("msg_ErrorOccurred"));
	        			}	
	        		},
	        		error:function (request,status,error){
	        			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	        		}
	        	});
        	}	
        	else{
				window.open("eumtalk://open/channel?roomId=" + $("#"+objId).data( "roomId"));
        	}
        });

        //엑셀
        $('#'+objId+' .btnExcel').on( 'click',aData, function(e){
        	var params = "";
        	
        	if (aData.myTodo != "Y"){
        		params = "prjSeq="+aData.prjSeq+
        			 "&prjType="+  aData.prjType+
        			 "&prjName="+  encodeURIComponent(aData.prjName)+
        			 "&myTodo="+aData.myTodo;
    		}	
    		else{
            	params = "myTodo=Y";
    		}
	        if (confirm(Common.getDic("msg_WantToDownload"))) { //다운로드 하시겠습니까?
	        	var searchText = $("#"+objId+" #searchText").val() == undefined ? "" : $("#"+objId+" #searchText").val();
	        	var searchOption = $("#"+objId+" #searchOption").val() == undefined ? "" : $("#"+objId+" #searchOption").val();
	        	var searchWord = $("#"+objId+" #searchWord").val() == undefined ? "" : $("#"+objId+" #searchWord").val();
	        	var completMonth = $("#"+objId+" #completMonth").val() == undefined ? "" : $("#"+objId+" #completMonth").val();
				 
				params += "&searchText=" + searchText + "&searchOption=" + searchOption + "&searchWord=" + searchWord 
						+ "&date1=" + $("#"+objId+"_date1").val() + "&date2=" + $("#"+objId+"_date2").val()
						+  "&completMonth=" + completMonth;

	            location.href= '/groupware/collabProject/excelDown.do?'+params;
	        }
        });
        
		//완료 처리
        $(document).off('change','#'+objId+' .row .column .card_chk').on('change','#'+objId+' .row .column input[type=checkbox]',function(e){
        	var sMsg = Common.getDic("msg_TaskClose");
        	var	data={"taskSeq":  $(this).data("taskSeq"), "taskStatus":  $(this).is(':checked'),"prjType":  $(this).data("prjType")};
        	
        	if (!$(this).is(':checked')) sMsg =  Common.getDic("msg_att_cancel");
        	
        	Common.Confirm(sMsg, "Confirmation Dialog", function(result){	// 마감 하시겠습니까?
           		if(result){
    				collabUtil.saveTaskComplete(data, function (res) {
            			collabMain.reloadMain(objId);
    				});
           		} else {
           			if($(this).is(":checked") == true) {
           				$(this).prop("checked",false);
           			} else {
    					$(this).prop("checked",true);
           			}
           		}
    		});
		});
	
		//세션변경
		$(document).off('click','#'+objId+' #btnSecFunc').on('click','#'+objId+' #btnSecFunc',function(){
			$(this).siblings(".column_menu").toggleClass("active");
		});
		
		$(document).off('mouseleave','#'+objId+' #column_menu').on('mouseleave','#'+objId+' #column_menu',function(){
			$(this).removeClass("active");
		});
		$(document).off('mouseleave','#'+objId+' .column_menu').on('mouseleave','#'+objId+' .column_menu',function(){
			$(this).removeClass("active");
		});
		
		//리스트 숨기기 
		$(document).off('click','#'+objId+' .list_header .column_tit').on('click','#'+objId+' .list_header .column_tit',function(e){
		    $(this).parent('.list_header').toggleClass('active');
		    $(this).parent().parent('.column').toggleClass('active');
		});
		  
		/* 업무 탭 */
		$(document).on('click','#'+objId+' .tabList ul li',function(){
			var tab_id = $(this).attr('data-tab');
			var objId = $(this).closest('.cRContBottom').attr("id");

			if(tab_id == "tstab-1"){	//업무 이동시 칸반형으로
				$("#"+objId).data({"dataView":"KANB", "dataMode": objId=="todo"?"STAT":"SEC"});
				
				$("#"+objId+" .btn .btnListView").removeClass('active');
	            $("#"+objId+" .btn .listViewType02").addClass('active');
				//$("#"+objId+"_date1").val("");
        		//$("#"+objId+"_date2").val("");
    			$("#"+objId+" #calTitle").hide();
    			$("#"+objId+" #gantTitle").hide();
    			$("#"+objId+" .tag").show();
    			$("#"+objId+" .info").show();
				$("#"+objId+" #calTab").hide();
				$("#"+objId+" #dttab-1, #dttab-2").removeClass("active");
        		$("#"+objId+" #dttab-3").addClass("active");
        		$("#"+objId+" #dttab-3").removeClass("list-fluid");
				$("#"+objId+" #dttab-3").addClass("card-fluid");
        		//$("#"+objId+" #dttab-3 .list_header").addClass("card_header");
            	//$("#"+objId+" #dttab-3 .list_header").removeClass("list_header");
            	$("#"+objId+" .card_add").show();
			}else{
				$("#"+objId+" .tag").show();
				if($("#"+objId+" #"+tab_id+" .container-fluid").eq(0).hasClass("active")){
					$("#"+objId+" #"+tab_id+" .listViewType01").removeClass("active").addClass("active");
					$("#"+objId+" #"+tab_id+" .listViewType02").removeClass("active");
				}else{
					$("#"+objId+" #"+tab_id+" .listViewType01").removeClass("active");
					$("#"+objId+" #"+tab_id+" .listViewType02").removeClass("active").addClass("active");
				}
			}
			
			var tagName = "";
			$('#'+objId+' .tabList ul li').removeClass('active');
			$('#'+objId+' .tstab_cont').removeClass('active');

			$(this).addClass('active');
			$("#"+objId+" #"+tab_id).addClass('active');
			$("#" + objId).closest(".cRContBottom").data("dataView",$("#"+objId+" #"+tab_id +" .Project_btn a.active").attr('data-view'));
			
			$("#" + objId + " .searchBox02").hide();
			$("#" + objId + " .btn_mySlide").hide();
			
			//프로젝트 탭
			$("#" + objId + " .ProjectArea").addClass('active');
		    $('#' + objId + ' .myTaskArea').addClass('active');
			$("#" + objId + " .Project_list_co").hide();
			$("#" + objId + " .Project_list_co").addClass('pos');
			
			switch ($(this).attr("data-type")){
				case "FILE":
					tagName = "myFile_tag";
					collabMain.getMyFile(objId, aData);
					break;
				case "SURVEY":
					tagName = "mySurvey_tag";
					collabMain.getMySurvey(objId, aData);
					break;
				case "APPROVAL":
					collabMain.getMyApproval(objId, aData);
					break;
				case "ADDREPORT":	//업무보고
					collabTodo.getUserReportDay(1);
					break;
				case "REPORT":
					var html = '<tr><td class="bodyTd bodyTd_0 bodyTdr_0" style="vertical-align:middle;text-align: center;" colspan="6">'+Common.getDic("msg_ComNoData")+'</td></tr>';
					$("#" + objId + " #taskDayTableContents tbody").empty().append(html);

					var today = CFN_GetLocalCurrentDate("yyyy-MM-dd");
					var sunday = AttendUtils.getWeekStart(today, 0)
					var sDate = schedule_SetDateFormat(sunday, '.');
					var eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');
					$("#" + objId + " #rptab-2 #reportCal .title").text(sDate + " ~ " + eDate + " ["+getWeekNo(sDate)+"주차]");
					$("#" + objId + " #rptab-2 #reportCal .title").data({"sDate":sDate,"eDate":eDate});
					collabMain.getReportWeek(objId, 1);
					break;
				default:
					tagName = "myTask_tag";
					$("#" + objId).closest('.cRContBottom').data({"dataView": $(this).attr('data-view'),"dataMode": $(this).attr('data-mode')});
					$("#" + objId + " .searchBox02").show();
					$("#" + objId + " .btn_mySlide").show();
//					$("#" + objId + " .btn_mySlide").trigger("click")
					collabMain.getMyTask(objId, aData);
					break;
			}
			
			if (tagName != ""){
				$("#" + objId+" #"+tab_id).find(".slick-track li").attr("class", "eventTag slick-slide slick-active");
				$("#" + objId+" #"+tab_id).find(".slick-track li").eq(0).addClass("slick-current");
			}
			
		});

		/* 캘린더(일정,스케줄) */
		$('#' + objId + ' #calTab li').click(function () {
			var tab_id = $(this).attr('data-tab');

			$('#' + objId + ' #calTab li').removeClass('selected');
			$(this).addClass('selected');

			var stndDay = new Date(coviCmn.getDateFormat($("#" + objId + " #calTitle .title").text()+"-01","-"));
			var aCalData = collabUtil.setCalendar(schedule_SetDateFormat(new Date(stndDay.setMonth(stndDay.getMonth())).setDate(1), '-'), objId, "#" + objId + " #calTitle .title");
			if ($(this).attr('data-tab') == "calSchedule"){
				$("#" + objId).closest('.cRContBottom').data({"cal_mode": "EVENT"});
			}
			else{
				$("#" + objId).closest('.cRContBottom').data({"cal_mode": ""});
			}

			collabMain.getMyTask(objId, aData, $(this).attr('data-tab') == "calSchedule" ? "EVENT" : "");
		});

		/* 간트(섹션,업무) */
		$('#' + objId + ' #gantTab li').on('click', aData, function (e) {
			$('#' + objId + ' .btn .listViewType05').attr("data-view",$(this).attr('data-tab'));
			$('#' + objId + ' #gantTab li').removeClass('selected');
			$(this).addClass('selected');
			
			$('#' + objId + ' .btn .listViewType05').trigger('click');
			
		});

		//업무탭 밑의 아이콘 탭(list형 /kan형 등등)
		$('#' + objId + ' .btn .btnListView').on('click', aData, function (e) {
			var objId = $(this).closest('.cRContBottom').attr("id");
			var objType = $("li[data-tab=" + $(this).closest(".tstab_cont").attr("id") + "]").attr("data-type");
			var tagName = "";
			
			$("#" + objId).closest('.cRContBottom').data({"dataView": $(this).attr('data-view'),"dataMode": $(this).attr('data-mode')});
			collabUtil.changeDisplayMode($(this).attr('data-tab'), $(this).closest('.cRContBottom').attr("id"), $(this).attr('data-view'), $(this));
			
			switch(objType){
				case "FILE":
					tagName = "myFile_tag";
					collabMain.getMyFile(objId, aData);
					break;
				case "SURVEY":
					tagName = "mySurvey_tag";
					collabMain.getMySurvey(objId, aData);
					break;
				case "REPORT":
					collabMain.getMyReport(objId, 'day');
					break;
				case "APPROVAL":
					collabMain.getMyApproval(objId, aData);
					break;
				default:
					tagName = "myTask_tag";
					collabMain.getMyTask(objId, aData);
					break;
			}
			if (tagName != ""){
				$("#" + objId+" #"+tagName+" .slick-current").removeClass("slick-current");
		   		$("#" + objId+" #"+tagName+" .slick-track li[data-slick-index=0]").addClass("slick-current");
			}	
		});
		
		//간트 타입 변경시 
		$('#' + objId + ' #selType').on('change', aData, function (e) {
			collabMain.changeMyGantDate(objId, aData, '');
		});
		
		//간트용 섹션, 사용자 변경시
		$('#' + objId + ' #selSection, #' + objId + ' #selMember').on('change', aData, function (e) {
			collabMain.getMyTask(objId, aData, $("#" + objId).closest('.cRContBottom').data("cal_mode"));
		});

		//오늘
		$('#' + objId + ' #calTitle .calendartoday').on('click', aData, function (e) {
			collabMain.changeMyCalDate(objId, aData, 'T');
		});	
		//이전
		$('#' + objId + ' #calTitle .pre').on('click', aData, function (e) {
			collabMain.changeMyCalDate(objId, aData, 'P');
		});
		//이후
		$('#' + objId + ' #calTitle .next').on('click', aData, function (e) {
			collabMain.changeMyCalDate(objId, aData, 'N');
		});

		//gant 오늘
		$('#' + objId + ' #gantTitle .calendartoday').on('click', aData, function (e) {
			collabMain.changeMyGantDate(objId, aData, 'T');
		});	
		//gant 이전
		$('#' + objId + ' #gantTitle .pre').on('click', aData, function (e) {
			collabMain.changeMyGantDate(objId, aData, 'P');
		});
		//gant 이후
		$('#' + objId + ' #gantTitle .next').on('click', aData, function (e) {
			collabMain.changeMyGantDate(objId, aData, 'N');
		});

		//검색 상세
		$('#'+objId+' .btnDetails').on( 'click',aData, function(e){
			$(this).toggleClass('active');
			if($(this).hasClass('active')){
				$('#'+objId+' .ProjectArea').addClass('pos');
				$('#'+objId+' .inPerView').addClass('active')
			}else{
				$('#'+objId+' .ProjectArea').removeClass('pos');
				$('#'+objId+' .inPerView').removeClass('active')
			}	
		});

		//대문 닫기
		$('#' + objId + ' .btn_mySlide').on('click', aData, function (e) {
			//프로젝트 탭
		    $('#' + objId + ' .ProjectArea').toggleClass('active');
		    //내업무 탭
		    $('#' + objId + ' .myTaskArea').toggleClass('active');
		
		    //업무 상단 영역
		    $('#' + objId + ' .Project_list_co').slideToggle();
		    $('#' + objId + ' .Project_list_co').toggleClass('pos');
		
		    $('#' + objId + ' .popTask_slide').removeClass('active');
    
		});

		//업투 태그 선택시
		$('#' + objId + ' #taskTagInput, #' + objId + ' #fileTagInput, #' + objId + ' #approvalTagInput, #' + objId + ' #surveyTagInput').on('click', aData, function (e) {
			var objId = $(this).closest('.cRContBottom').attr("id");
			$('#' + objId + ' #'+$(this).attr("id")).val("");
		});
		//업투  태그 선택시
		$('#' + objId + ' #taskTag, #' + objId + ' #fileTag, #' + objId + ' #approvalTag, #' + objId + ' #surveyTag').on('change', aData, function (e) {
			var objId = $(this).closest('.cRContBottom').attr("id");
			var thisVal = $(this).val();
			var thisId = $(this).attr("id");
			var thisTag;
//			var thisSearch = "";
		 	switch ($(this).attr("id"))
		 	{
			 	case "fileTag":
//			 		thisId = "fileTag";
			 		thisTag = "FILE";
			 		break;
			 	case "approvalTag":
//			 		thisId = "approvalTag";
			 		thisTag = "APPROVAL";
			 		break;
			 	case "surveyTag":
//			 		thisId = "surveyTag";
			 		thisTag = "SURVEY";
			 		break;
			 	default:
//			 		thisId = "taskTag";
			 		thisTag = "TAG";
			 		break;
			}
			
			var tagSeq = '';
			var searchOption = '';
		 	$('#' + objId + ' #'+thisId+' option').each(function (i, v) {
				var item = $(v);
				if (thisVal== item.text()){
					tagSeq = item.attr("data");
					searchOption = item.attr("data-opt");
					return;
				}	
			});
		 	
			//taskTag
		 	if (tagSeq != "#"){
				collabMain.getTagTask(this,thisTag,tagSeq)
				switch ($(this).attr("id"))
			 	{
				 	case "fileTag":
				 		$("#"+objId+" #searchFile").val("");
				 		$("#"+objId+" #searchFile").attr("disabled", true);
				 		break;
				 	case "approvalTag":
				 		$("#"+objId+" #searchApproval").val("");
				 		$("#"+objId+" #searchApproval").attr("disabled", true);
				 		break;
				 	case "surveyTag":
				 		$("#"+objId+" #searchSurvey").val("");
				 		$("#"+objId+" #searchSurvey").attr("disabled", true);
				 		break;
				 	default:
				 		$("#"+objId+" #searchOption").val("");
				 		$("#"+objId+" #searchWord").val("");
				 		$("#"+objId+" #searchWord").attr("disabled", true);
				 		break;
				}
		 	}	
		 	else{
		 		switch ($(this).attr("id"))
			 	{
				 	case "fileTag":
				 		$("#"+objId+" #searchFile").attr("disabled", false);
				 		break;
				 	case "approvalTag":
				 		$("#"+objId+" #searchApproval").attr("disabled", false);
				 		break;
				 	case "surveyTag":
				 		$("#"+objId+" #searchSurvey").attr("disabled", false);
				 		break;
				 	default:
				 		$("#"+objId+" #searchOption").val(searchOption);
				 		$("#"+objId+" #searchWord").attr("disabled", false);
				 		break;
				}
		 	}
		});

		//섹션 추가
		$(document).off('click', '#' + objId + ' #btnSecPlus').on('click', '#' + objId + ' #btnSecPlus', function () {
			var aData = [];
			var aData = $(this).closest('.cRContBottom').data()
			var popupID = "CollabSectionPopup";
			var openerID = "CollabMain";
			var popupTit = "[" + aData.prjName + "] " + Common.getDic("btn_AddSection");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN = "N";
			var callBack = encodeURI(JSON.stringify({'prjSeq': aData.prjSeq, 'prjType': aData.prjType}));
			var popupUrl = "/groupware/collabProject/CollabSectionPopup.do?"
				+ "&prjType=" + aData.prjType
				+ "&prjSeq=" + aData.prjSeq
				+ "&prjName=" + encodeURIComponent(aData.prjName)
				+ "&popupID=" + popupID
				+ "&openerID=" + openerID
				+ "&popupYN=" + popupYN
				+ "&callBackParam=" + callBack;
			Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);
			//CFN_OpenWindow(popupUrl, "", 350, 350, sSize);

		});
		
		//섹션순서 변경
		$(document).off('click', '#' + objId + ' #btnSecMove').on('click', '#' + objId + ' #btnSecMove', function () {
			var aData = $(this).closest('.cRContBottom').data()
			$(this).parents(".column_menu").toggleClass("active");

			var popupID = "CollabSectionPopup";
			var popupTit = "[" + aData.prjName + "] " + Common.getDic("lbl_ChangeOrderSection");
			var popupUrl = "/groupware/collabProject/CollabSectionMovePopup.do?"
				+ "&prjType=" + aData.prjType
				+ "&prjSeq=" + aData.prjSeq;
			Common.open("", popupID, popupTit, popupUrl, "350px", "400px", "iframe", true, null, null, true);

		});

		//섹션명 변경
		$(document).off('click', '#' + objId + ' #btnSecChg').on('click', '#' + objId + ' #btnSecChg', function () {
			var objId = $(this).closest('.cRContBottom').attr("id");
			var aData = $(this).closest('.cRContBottom').data()
			$(this).parents(".column_menu").toggleClass("active");

			var popupID = "CollabSectionPopup";
			var openerID = "CollabMain";
			var popupTit = "[" + aData.prjName + "] " + Common.getDic("btn_ModiSection");
			var popupYN = "N";
			var callBack = encodeURI(JSON.stringify({'prjSeq': aData.prjSeq, 'prjType': aData.prjType}));
			var popupUrl = "/groupware/collabProject/CollabSectionPopup.do?"
				+ "&prjType=" + aData.prjType
				+ "&prjSeq=" + aData.prjSeq
				+ "&prjName=" + encodeURIComponent(aData.prjName)
				+ "&sectionSeq=" + $(this).data("seq")
				+ "&sectionName=" + encodeURIComponent($(this).parent().parent().find(".column_tit").text())
				+ "&popupID=" + popupID
				+ "&openerID=" + openerID
				+ "&popupYN=" + popupYN
				+ "&callBackParam=" + callBack;
			Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);

		});

		//섹션명 삭제
		$(document).off('click', '#' + objId + ' #btnSecDel').on('click', '#' + objId + ' #btnSecDel', function () {
			$(this).closest('.addFuncBox').removeClass('active');
			
			if ($(this).closest('.column').find('#cardTitle').size() > 0) {
				Common.Error(Common.getDic("msg_delete_existFolder")); //섹션 하위에 업무가 존재하여 삭제할 수 없습니다.
				return;
			}

			var objId = $(this).closest('.cRContBottom').attr("id");
			var aData = $(this).closest('.cRContBottom').data()

			$.ajax({
				type: "POST",
				data: {"sectionSeq": $(this).data("seq")},
				url: "/groupware/collabProject/deleteProjectSection.do",
				success: function (data) {
					collabMain.getProjectMain(objId, aData);
				},
				error: function (request, status, error) {
					Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
				}
			});
		});
		
		$(document).off('click', '#' + objId + ' .listBox .btn_arrow_b').on('click', '#' + objId + ' .listBox .btn_arrow_b', function () {
			var obj = $(this);
			var trgObj = $(this).closest(".listBox");

			var depthCass = "listBox_depth02";
			if (trgObj.parent("div").hasClass('listBox_depth02'))
				depthCass = "listBox_depth03";
			else if (trgObj.parent("div").hasClass('listBox_depth03'))
				depthCass = "listBox_depth04";
			else if (trgObj.parent("div").hasClass('listBox_depth04'))
				depthCass = "listBox_depth05";
			else if (trgObj.parent("div").hasClass('listBox_depth05'))
				depthCass = "listBox_depth05";
			
		    if ($(trgObj).siblings("."+depthCass).length==0){
		    	
		    	$.ajax({
					type: "POST",
					data: {"taskSeq": $(obj).closest(".listBox").data("taskSeq")},
					url: "/groupware/collabTask/getSubTaskList.do",
					success: function (data) {
						data["taskSubData"].map( function( item,idx ){
							trgObj.after(collabUtil.drawTask(item, "", "LIST","","", depthCass));
						});
				    	$(trgObj).toggleClass('active');
					    $(trgObj).siblings("."+depthCass).addClass('active');
					},
					error: function (request, status, error) {
						Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
					}
				});
		    }else{
		    	$(trgObj).toggleClass('active');
		    	if ($(trgObj).hasClass('active'))
		    		$(trgObj).siblings("."+depthCass).addClass('active');
		    	else
		    		$(trgObj).siblings("."+depthCass).removeClass('active');
		    }    
		});

		//카드 복사
		$(document).off('click', '#' + objId + ' #cardCopy').on('click', '#' + objId + ' #cardCopy', function () {
			var taskData = $(this).closest(".card_control").siblings(".card_cont").data();
			taskData["objId"] = objId;
			
	 		collabUtil.goTaskCopy(taskData, "callbackTaskCopy");
		});

		//카드 수정
		$(document).off('click', '#' + objId + ' #cardModify').on('click', '#' + objId + ' #cardModify', function () {
			var taskData = $(this).closest(".card_control").siblings(".card_cont").data();
			var aData = $(this).closest('.cRContBottom').data();
			taskData["prjName"]= aData.prjName;
			taskData["sectionSeq"]=$(this).closest('.column').data('sectionseq');
			taskData["sectionName"]="";
	 		collabUtil.goTaskModify(taskData, "callbackTaskSave");
	 	});

		//카드 삭제
		$(document).off('click', '#' + objId + ' #cardDelete').on('click', '#' + objId + ' #cardDelete', function () {
			var taskData = $(this).closest(".card_control").siblings(".card_cont").data();
	 		collabUtil.goTaskDelete(taskData, objId);
//			collabUtil.openObjectPopup("CollabTaskPopup", $(this).closest('.cRContBottom').attr("id"), $(this).data())
		});

		//타스트 상세
		$(document).off('click', '#' + objId + ' #cardTitle').on('click', '#' + objId + ' #cardTitle', function (e) {
			if(!$(e.target).hasClass('s_check') && $(e.target).attr('type') != "checkbox"){ // 체크박스, 체크 span 아닐 경우만 호출
				collabUtil.openObjectPopup("CollabTaskPopup", $(this).closest('.cRContBottom').attr("id"), $(this).data());
			}
		});
		$(document).off('click', '#' + objId + ' .card_img').on('click', '#' + objId + ' .card_img', function () {

			var surveyInfo = $(this).closest('.card_survey').data();
			if(surveyInfo != undefined){
	    		collabMain.openSurveyPopup(surveyInfo.surveyInfo);
			}else{
				collabUtil.openObjectPopup("CollabTaskPopup", $(this).closest('.cRContBottom').attr("id"), $(this).siblings("#cardTitle").data())	
			}
		});
		
		
		//설문실행
		$(document).off('click', '#' + objId + ' .card_join').on('click', '#' + objId + ' .card_join', function (e) {
			e.stopPropagation();
			var cardData = $(this).closest("#cardTitle").data();
			$.ajax({
				type: "POST",
				data: {
					"surveyID": cardData["objectID"]},
				url: "/groupware/collabProject/getSurveyInfo.do",
				success: function (json) {
					var data = json.data;
					if (data != null){
						var surveyInfo = {"State":data.State,"IsResponse":data.IsResponse, "IsAnswer":data.IsAnswer,"SurveyID":cardData["objectID"]};
						collabMain.openSurveyPopup(surveyInfo);
					}	else{
						Common.Error(Common.getDic("msg_ErrorOccurred") );
					}
				},
				error: function (request, status, error) {
					Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
				}
			});
			//getSurveyInfo
			
			
		});
		//타스크 추가
		$(document).off('click', '#' + objId + ' #task_add').on('click', '#' + objId + ' #task_add', function () {
			var aData = $(this).closest('.cRContBottom').data();
			if (objId == "todo"){
				collabUtil.openTaskAddPopup("CollabTaskAddPopup", "callbackTaskCopy", "", "M", "", $(this).data("seq"), encodeURIComponent(Common.getDic("lbl_MyWork")), "", "");	//내업무
			}else{
				var secText = $(this).hasClass("column_add")?$(this).siblings(".column_tit").text():$(this).parent().prev().find(".column_tit").text();
				collabUtil.openTaskAddPopup("CollabTaskAddPopup", "callbackTaskSave", "", aData.prjType,aData.prjSeq, $(this).data("seq")
						, encodeURIComponent(aData.prjName), encodeURIComponent(secText));
			}	
			
/*
			var aData = $(this).closest('.cRContBottom').data()
			var objId = $(this).closest('.cRContBottom').attr("id");
			var seq = $(this).data("seq");
			$('#' + objId + ' .add_task').closest(".card").remove();

			$('#' + objId + ' .row #section_' + seq + ' .card_header').after($("<div>", {"class": "card " + (aData.prjType == "P" ? "type01" : "type02")})
				.append($("<div>", {"class": "card_cont1"})
					.append($("<div>", {"class": "card_info"})
						.append(collabUtil.drawAddTask("resultViewMemberInput", "StartDate", "EndDate"))
					)));
			$('#' + objId + ' .row #section_' + seq + ' textarea').data({
				"prjSeq": aData.prjSeq,
				"prjType": aData.prjType,
				"sectionSeq": seq
			});
			collabUtil.attachEventAddTask("resultViewMemberInput", "StartDate", "EndDate");
			$('#' + objId + ' .row #section_' + seq + ' textarea').focus();

			$('#' + objId + ' .row #section_' + seq + ' textarea').on('keydown', function (key) {
				if (key.keyCode == 13) {
					$.ajax({
						type: "POST",
						contentType: 'application/json; charset=utf-8',
						dataType: 'json',
						data: JSON.stringify({
							"prjSeq": $(this).data("prjSeq"),
							"prjType": $(this).data("prjType"),
							"sectionSeq": seq,
							"taskName": $(this).val(),
							"startDate": $("#StartDate").val(),
							"endDate": $("#EndDate").val(),
							"trgMember": collabUtil.getUserArray("resultViewMember")
						}),
						url: "/groupware/collabTask/addTaskSimple.do",
						success: function (data) {
							$('#' + objId + ' .row #section_' + data["SectionSeq"]).append(collabUtil.drawTask(data));
							$('#' + objId + ' .row #section_' + data["SectionSeq"] + ' .add_task').closest(".card").remove();
						},
						error: function (request, status, error) {
							Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
						}
					});

				}
			});
*/
		});
		$(document).off('click', '.file_down').on('click', '.file_down', function (e) {
			Common.fileDownLoad($(this).data("fileid"), $(this).text(), $(this).data("filetoken"));
		});
		//file 삭제
		$(document).off('click', '.file_del').on('click', '.file_del', function (e) {
			var obj = $(this).closest("div .cRContBottom").attr('id');
			$.ajax({
				type: "POST",
				data: {"fileID": $(this).data("fileid")},
				url: "/groupware/collabTask/deleteTaskFile.do",
				success: function (data) {
					if (data.status == "SUCCESS") {
						Common.Inform(Common.getDic("msg_com_processSuccess"));	// 성공적으로 처리되었습니다.
						collabMain.getMyFile(obj, aData);
					} else {
						Common.Error(Common.getDic("msg_ErrorOccurred")); // 오류가 발생하였습니다.
					}
				},
				error: function (request, status, error) {
					Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
				}
			});

		});

		// 설문 작성 팝업
		$(document).off("click", "#btnSvyPlus").on("click", "#btnSvyPlus", function () {
			if($(this).parents(".cRContCollabo_sub").find(".column01").length == 0) {
				Common.Inform(Common.getDic("msg_svyAddRegistSection"));	// 설문 업무를 저장할 섹션이 없습니다. 섹션을 추가해주세요.
				return;
			}
			
			var prjStr = $(this).parents(".cRContCollabo_sub").attr("id");
			
			var prjType = prjStr.split('_')[0];
			var prjSeq = prjStr.split('_')[1];
			
			var popupUrl = "/groupware/survey/goSurveyCollabWritePopup.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=create&surveyId=";
			var popupID = "CollabSurveyWritePopup";
			var popupTit = Common.getDic("lbl_surveyWrite"); // 설문 작성
			
			popupUrl += "&prjSeq=" + prjSeq + "&prjType=" + prjType;

			Common.open("", popupID, popupTit, popupUrl, "1000px", "600px", "iframe", true, null, null, true);
		});
		
		//설문popup
		$(document).off('click', '#' + objId + ' .surveyPopup').on('click', '#' + objId + ' .surveyPopup', function (e) {
			e.stopPropagation(); 
			var surveyInfo = $(this).data();
    		collabMain.openSurveyPopup(surveyInfo.surveyInfo);
		});
		
		
		// 상세보기 팝업. (업무카드? 결재문서?)
		$(document).off('click', '#' + objId + ' #card_approval').on('click', '#' + objId + ' #card_approval', function () {
			var approvalInfo = $(this).data("approvalInfo");
			var popupID, popupTit, popupUrl;
			var viewType = "resultView";
			
			// 업무정보 팝업.
			collabUtil.openTaskPopup("CollabTaskPopup",objId, approvalInfo.taskSeq, approvalInfo.taskSeq);
			
		});

		
		//미정
		$("#" + objId + " #vChk").on('click', aData, function (e) {
			collabMain.getTagTask($("#"+objId),"TAG",$("#"+objId).data("tagval"));
		});

		//대기
		$("#" + objId + " #wnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","WaitTask")
		});
		//진행
		$("#" + objId + " #pnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","ProcTask")
		});
		//보류
		$("#" + objId + " #hnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","HoldTask")
		});
		//완료
		$("#" + objId + " #cnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","CompTask")
		});

		//지연
		$("#" + objId + " #dnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","DelayTask")
		});
		//전체업무
		$("#" + objId + " #tnum").on('click', aData, function (e) {
			$('#'+objId+' .btnRefresh').trigger('click');
		});
		
		//오늘 완료
		$("#" + objId + " #tocnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","TodayCTask")
		});

		//오늘 완료예정
		$("#" + objId + " #totnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","TodayTask")
		});

		//오늘 전체
		$("#" + objId + " #tonum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","TodayTask")
		});

		//긴급
		$("#" + objId + " #enum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","EmgTask")
		});
		//중요(상)
		$("#" + objId + " #lvlhnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","LvlHTask")
		});
		//중요(중)
		$("#" + objId + " #lvlmnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","LvlMTask")
		});

		//중요(하)
		$("#" + objId + " #lvllnum").on('click', aData, function (e) {
			collabMain.getTagTask(this,"TAG","LvlLTask")
		});
		
		$('#' + objId + ' .sleOpTitle').on('click', function(){
	 		if($(this).hasClass('active')){
	 			$(this).removeClass('active');
	 			$(this).siblings('.selectOpList').removeClass('active');
	 		}else {
	 			$(this).addClass('active');
	 			$(this).siblings('.selectOpList').addClass('active');
	 		}
	 	});
		
	 	$('#' + objId + ' .selectOpList>li').on('click', function(){
	 		$(this).parents('.sleOpTitle').html($(this).html());
	 		$(this).parents('.selectValue').val($(this).data( "selvalue" ));
	 		$(this).parents('.sleOpTitle').removeClass('active');
	 		$(this).closest('.selectOpList').removeClass('active');
	 	});
	 	

	 	
		
		//업무보고 이전
		$('#' + objId + ' #reportCal .pre').on('click',function(e){
			var html = '<tr><td class="bodyTd bodyTd_0 bodyTdr_0" style="vertical-align:middle;text-align: center;" colspan="6">'+Common.getDic("msg_ComNoData")+'</td></tr>';
			$("#" + objId + " #taskDayTableContents tbody").empty().append(html);

			var sDate = schedule_SetDateFormat(schedule_AddDays($("#" + objId + " #rptab-2 #reportCal .title").data("sDate"), -7), '.');
			var eDate = schedule_SetDateFormat(schedule_AddDays($("#" + objId + " #rptab-2 #reportCal .title").data("eDate"), -7), '.');

			$("#" + objId + " #rptab-2 #reportCal .title").data({"sDate":sDate,"eDate":eDate});
			$("#" + objId + " #rptab-2 #reportCal .title").text(sDate + " ~ " + eDate + " ["+getWeekNo(sDate) + Common.getDic("lbl_TheWeek") + "]");
			collabMain.getReportWeek(objId,  1);
		
		});
		
		//업무보고 이후
		$('#' + objId + ' #reportCal .next').on('click', function(e){
			var html = '<tr><td class="bodyTd bodyTd_0 bodyTdr_0" style="vertical-align:middle;text-align: center;" colspan="6">'+Common.getDic("msg_ComNoData")+'</td></tr>';
			$("#" + objId + " #taskDayTableContents tbody").empty().append(html);

			var sDate = schedule_SetDateFormat(schedule_AddDays($("#" + objId + " #rptab-2 #reportCal .title").data("sDate"), +7), '.');
			var eDate = schedule_SetDateFormat(schedule_AddDays($("#" + objId + " #rptab-2 #reportCal .title").data("eDate"), +7), '.');
			
			$("#" + objId + " #rptab-2 #reportCal .title").data({"sDate":sDate,"eDate":eDate});
			$("#" + objId + " #rptab-2 #reportCal .title").text(sDate + " ~ " + eDate + " ["+getWeekNo(sDate) + Common.getDic("lbl_TheWeek") +"]");
			collabMain.getReportWeek(objId, 1);
		});
		
		//오늘
		$('#' + objId + ' #reportCal .calendartoday').on('click', function(e){
			var html = '<tr><td class="bodyTd bodyTd_0 bodyTdr_0" style="vertical-align:middle;text-align: center;" colspan="6">'+Common.getDic("msg_ComNoData")+'</td></tr>';
			$("#" + objId + " #taskDayTableContents tbody").empty().append(html);

			var today = CFN_GetLocalCurrentDate("yyyy-MM-dd");
			var sunday = AttendUtils.getWeekStart(today, 0)
			var sDate = schedule_SetDateFormat(sunday, '.');
			var eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');
			$("#" + objId + " #rptab-2 #reportCal .title").data({"sDate":sDate,"eDate":eDate});
			$("#" + objId + " #rptab-2 #reportCal .title").text(sDate + " ~ " + eDate + " ["+getWeekNo(sDate) + Common.getDic("lbl_TheWeek") + "]");
			collabMain.getReportWeek(objId,  1);
		
		});
		
		$(document).off('click', '#' + objId + ' .icoReportDtlPop').on('click', '#' + objId + ' .icoReportDtlPop', aData, function () {
    		collabUtil.openReportWeekPopup('CollabReportSavePopup', '', objId, $(this).data(), aData.prjName);
    	});
		
		//차트에서 팝업
		$(document).off('click', '#' + objId + ' .chartTitle').on('click', '#' + objId + ' .chartTitle', aData, function () {
			//event.stopPropagation();
			collabUtil.openTaskPopup("CollabTaskPopup", objId, event.point.taskSeq,event.point.taskSeq);
		});
		
		/*차트 연결*/
		$(document).off('click', '#' + objId + ' .gant').on('click', '#' + objId + ' .gant', aData, function () {
			if (aData.myTodo  == 'Y' || $("#"+objId).data("prjAdmin") == "Y"){	//관리자만 연결/이동 가능	
				var popupID	= "CollabGantTaskLinkPopup";
	 			var popupUrl = "/groupware/collabTask/CollabGantTaskLinkPopup.do?"
	 			var myTodo = aData.myTodo;
	 			popupUrl += "&myTodo=" + myTodo;
	 			
	 			var taskSeq = event.point.taskSeq;
	 			var taskSeqList = "";
	 			var taskNameList = "";
	 			var linkedTaskSeq = event.point.linkTaskSeq;
	 			var linkedTaskName = event.point.linkTaskName;
	 			
	 			for(var i=0; i<event.point.series.data.length; i++) {
					if(taskSeq != event.point.series.data[i].taskSeq && linkedTaskSeq != event.point.series.data[i].taskSeq) {
						taskSeqList += event.point.series.data[i].taskSeq + ";";
						taskNameList += event.point.series.data[i].name + ";";
					}
				}
				popupUrl += "&taskSeq=" + taskSeq;
				popupUrl += "&taskSeqList=" + taskSeqList;
				popupUrl += "&taskNameList=" + taskNameList;
				popupUrl += "&linkedTaskSeq=" + linkedTaskSeq;
				popupUrl += "&linkedTaskName=" + linkedTaskName;
				
	 			if(myTodo == "N") {
					popupUrl += "&prjSeq=" + aData.prjSeq +
								"&prjType=" + aData.prjType +
								"&prjName=" + aData.prjName;
				}
				
				Common.open("", popupID, Common.getDic("btn_apv_AddTask"), popupUrl, "500px", "150px", "iframe", true, null, null, true);
			}	
		});
		
		
		/*		$("#" + objId + " #date2").datepicker("option", "minDate", $("#" + objId + " #date1").val());
		$("#" + objId + " #date2").datepicker("option", "onClose", function (selectedDate) {
			$("#" + objId + " #date1").datepicker("option", "maxDate", selectedDate);
		});

		axdom("#" + objId + " #date2").bindTwinDate({
			startTargetID : "date1",
		});
*/		
		
/*		$("#" + objId + " #date2").bindTwinDate({
						startTargetID : $(this).attr("date_startTargetID"),
			align : $(this).attr("date_align"),
			valign : $(this).attr("date_valign"),
			separator : $(this).attr("date_separator"),
			selectType : $(this).attr("date_selectType"),
			defaultSelectType: $(this).attr("date_defaultSelectType"),
			defaultDate : $(this).attr("defaultDate"),
			minDate : $(this).attr("minDate"),
			maxDate : $(this).attr("maxDate"),
			buttonText : $(this).attr("date_buttonText"),
			onBeforeShowDay : function(val){
				var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
				if(fnStr != null && fnStr != ""){
					return coviCmn.callFnBasedNamespace(fnStr, [date]);
				}
			}
		})*/
		
		document.addEventListener('scroll', function (event) {
	        if ($(event.target).hasClass("cardBox_area")){
	        	var totalCount = parseInt($(event.target).siblings(".card_header").find(".column_num").text());
	        	if (totalCount>$(event.target).find(".card").length){
	        	}
	        }
		}, true /*Capture event*/);
		
		//업무보고조회-주간업무보고-이름클릭
		$(document).off('click', '#' + objId + ' .dayReportDtl').on('click', '#' + objId + ' .dayReportDtl', aData, function () {
		
			var startDate =$("#"+objId+" #rptab-2 #reportCal .title").data("sDate");
			var endDate = $("#"+objId+" #rptab-2 #reportCal .title").data("eDate");
			
			var html = '<tr>';
			
			$.ajax({
				type: "POST",
				url: "/groupware/collabReport/collabReportDayDtl.do",
				data: {
					"prjType": aData.prjType
					, "prjSeq": aData.prjSeq
					, "startDate": schedule_SetDateFormat(startDate, '')
					, "endDate": schedule_SetDateFormat(endDate, '')
					, "reporterCode": $(this).data().UserCode
				},
				success: function(data) {
					var list = data.dayList;
					
					if (list == null || list.length == 0 ) {
						//등록된 업무 없음
						html += '<td class="bodyTd bodyTd_0 bodyTdr_0" style="vertical-align:middle;text-align: center;" colspan="6">'+Common.getDic("msg_ComNoData")+'</td></tr>';
						$("#" + objId + " #taskDayTableContents tbody").empty().append(html);
					} else {
						//등록 업무 존재
						for (var i = 0; i < list.length; i++) {
							var remark = list[i].Remark == null ? '' : list[i].Remark;
							var taskTime = list[i].TaskTime == null ? '' : list[i].TaskTime;
							var url = 'collabUtil.openTaskPopup(\'CollabReportSavePopup\',\''+aData.prjType+'_'+aData.prjSeq+'\','+list[i].TaskSeq+','+list[i].TaskSeq+');';
							html += '<td class = "bodyTdText" style="text-align: center;">' + schedule_SetDateFormat(list[i].ReportDate,'.') + '</td>'; //기간
							html += '<td class = "bodyTdText" style="text-align: center;">' + list[i].SectionName + '</td>'; //섹션명
							html += '<td class = "bodyTdText" style="text-align: center;"><a onclick="'+ url +'"data-taskSeq="' + list[i].DaySeq + '">' + list[i].TaskName + '</a></td>'; //업무명
							html += '<td class = "bodyTdText" style="text-align: center;">' + list[i].ProgRate + '</td>'; //진도율
							html += '<td class = "bodyTdText" style="text-align: center;">' + taskTime + '</td>'; //처리시간
							html += '<td class = "bodyTdText" style="text-align: center;">' + remark + '</td>'; //비고
							html += '</tr>';
						}
						//그리기
						$("#" + objId + " #taskDayTableContents tbody").empty().append(html);
					}
				},
				error: function(request, status, error) {
					Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
				}
			});
		});
		
	},
	loadSection:function(retData){
		//섹션 추가
		var objId = retData.prjType+"_"+retData.prjSeq;
		$('#'+objId+' .row').append(collabMain.drawSection(retData,{"prjAdmin":"Y"}));
	},
	changeSection:function(retData){
		//섹션명변경
		$('#section_'+retData.SectionSeq+' .column_tit').text(retData.SectionName);
	},
	drawSection:function(data, prjData, mode, view){
		var seq="";
		var name="";
		var isAdmin;
		var isAdd;

		switch (mode){
			case "STAT":
				seq = data;
				name = data=="W"? Common.getDic("lbl_Ready"):(data=="H"? Common.getDic("lbl_apv_hold"):(data=="C"? Common.getDic("lbl_apv_completed"):Common.getDic("lbl_goProcess")));
				isAdmin="N";
				isAdd=prjData.myTodo == "Y" ?(view=="LIST"?"N":"Y"):"N";
				break;
			case "MEM":
				seq = data.UserCode;
				name =data.DisplayName;
				isAdmin = "N";
				isAdd="N";
				break;
			default:
				seq = data.SectionSeq;
				name =data.SectionName;
				isAdmin =prjData.prjAdmin == "Y" ?"Y":"N";
				isAdd= view=="LIST"?"N":(prjData.prjAdmin == "Y"|| prjData.prjMember == "Y"?"Y":"N");
				break;
		}
		
		return $("<div>",{ "class" : "column column01", "id":"section_"+seq, "data-SectionSeq":seq })
			.append($("<div>", {"class":view=="LIST"?"list_header":"card_header"+(mode=="SEC"?" header_drag":"")})
					.append($("<h3>",{ "class" : "column_tit" , "text":name}))
					.append($("<strong>",{ "class" : "column_num", "text":0}))
					.append(isAdd=="Y"?$("<a>",{ "class" : "column_add", "id":"task_add"}).data( "seq",seq):"")
					.append(isAdmin=="Y"?$("<a>",{ "class" : "column_btn", "id":"btnSecFunc"}).data( "seq",seq):"")
					.append($("<div>",{ "class" : "column_menu"})
							.append($("<a>",{"text":Common.getDic("lbl_ChangeOrderSection"),"id":"btnSecMove"}).data( "seq",seq))		//섹션순서변경
							.append($("<a>",{"text":Common.getDic("WH_rename"),"id":"btnSecChg"}).data( "seq",seq))
							.append($("<a>",{"text":Common.getDic("lbl_delete"),"id":"btnSecDel"}).data( "seq",seq))))
			.append($("<div>",{"class":"boxArea "+(view=="LIST"?"listBox_area":"cardBox_area")})
			.append(isAdd=="Y"?$("<a>",{"class":"card_add","id":"task_add"}).data("seq",seq).append($("<strong>",{"text":"Add task"})):"")
			);
			
	},
	changeMyCalDate:function(objId, aData, calType){
		var stndDateObj = new Date(coviCmn.getDateFormat($("#" + objId + " #calTitle .title").text()+"-01","-"));

		var queryData;
		switch (calType)
		{
			case "P"://이전
				queryData= schedule_SetDateFormat(new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()-1, 1), '-');
				break;
			case "N"://이후	
				queryData= schedule_SetDateFormat(new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()+1, 1), '-');
				break;
			default://오늘
				queryData = CFN_GetLocalCurrentDate("yyyy-MM-dd");
				
				break;
		}	
		$("#" + objId + " #calTitle .title").text(schedule_SetDateFormat(queryData, '-').substring(0, 7));
		
		var aCalData = collabUtil.setCalendar(queryData, objId, "#" + objId + " .cal .title");

		$("#" + objId).closest('.cRContBottom').data({
			"cal_sdate": aCalData["startDate"]
			, "cal_edate": aCalData["endDate"]
		});
		collabMain.getMyTask(objId, aData, $("#" + objId).closest('.cRContBottom').data("cal_mode"));
	},
	changeMyGantDate:function(objId, aData, calType){
		var todayDateObj = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
		$("#" + objId).closest('.cRContBottom').data({"dataView": $(this).attr('data-view'),"dataMode": $(this).attr('data-mode')});

		var paramData =$("#" + objId).closest('.cRContBottom').data();
		paramData["gant_dateType"]=$("#"+objId+" #selType").val();
		var stndDate = $("#" + objId).closest('.cRContBottom').data("gant_sdate");
		//var startDate =coviCmn.getDateFormat(stndDate+"-01","-");
		var stndDateObj = new Date(schedule_SetDateFormat(stndDate,"-"));
		var startObj;
		var endObj;
		var selType = $("#"+objId+" #selType").val();
		switch (selType)
		{
			case "D":
				switch (calType)
				{
					case "P"://이전
						if (stndDateObj.getDate() == 1){
							stndDateObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()-1,16 )
						}else{
							stndDateObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth(), 1)
						}	
						break;
					case "N"://이후	
						if (stndDateObj.getDate() == 1){
							stndDateObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth(),16 )
						}else{
							stndDateObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()+1, 1)
						}	
						break;
					default://오늘
						stndDateObj=todayDateObj;
				}
				
				if (stndDateObj.getDate() < 16){
					startObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth(), 1);
					endObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth(), 15);
				}else{
					startObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth(), 16);
					endObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()+1, 1);
					endObj = endObj.setDate(endObj.getDate()-1);
				}
				$("#" + objId + " .gantt .title").text(schedule_SetDateFormat(startObj,"-"))
				break;
			case "W"://해당 월의 시작 일요일 부터 마지막 토툐일
				stndDateObj = new Date(schedule_SetDateFormat( $("#" + objId + " .gantt .title").text()+"-01","-"));
				switch (calType)
				{
					case "P"://이전
						stndDateObj=  new Date(stndDateObj.setMonth(stndDateObj.getMonth()-1));
						break;
					case "N"://이후	
						stndDateObj=  new Date(stndDateObj.setMonth(stndDateObj.getMonth()+1));
						break;
					default://오늘
						stndDateObj=todayDateObj;
						break;
				}	
				stndDate =schedule_SetDateFormat(stndDateObj, '-');
				var aCalData = collabUtil.setCalendar(stndDate, objId, "#" + objId + " .gantt .title");
				startObj= new Date(schedule_SetDateFormat(aCalData["startDate"],"-"));
				endObj  = new Date(schedule_SetDateFormat(aCalData["endDate"],"-"));
				startObj = startObj.setDate(startObj.getDate()+1);
				endObj = endObj.setDate(endObj.getDate());
				break;
			case "M":
			case "Q":		
			case "H":		
			case "Y":	
				var monthTerm = 3;
				if (selType  == "M") monthTerm = 1;
				else if (selType  == "Q") monthTerm = 3;
				else if (selType  == "H") monthTerm = 6;
				else if (selType  == "Y") monthTerm = 12;
				switch (calType)
				{
					case "P"://이전
						startObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()-monthTerm, 1)
						break;
					case "N"://이후	
						startObj= new Date(stndDateObj.getFullYear(), stndDateObj.getMonth()+monthTerm, 1)
						break;
					default://오늘
						todayDateObj = new Date(CFN_GetLocalCurrentDate("yyyy-MM")+"-01");
						startObj= new Date(todayDateObj.getFullYear(), Math.floor(todayDateObj.getMonth()/monthTerm)*monthTerm, 1)
						break;
				}

				if (selType == "M")
					endObj   = new Date(startObj.getFullYear(), startObj.getMonth()+2, 1);
				else
					endObj   = new Date(startObj.getFullYear(), startObj.getMonth()+monthTerm, 1);
				endObj = endObj.setDate(endObj.getDate()-1);
				$("#" + objId + " .gantt .title").text(schedule_SetDateFormat(startObj,"-").substring(0,7))
				break;
		}

		paramData["gant_sdate"] =schedule_SetDateFormat(startObj, '-');
		paramData["gant_edate"] =schedule_SetDateFormat(endObj, '-');
		$("#" + objId).closest('.cRContBottom').data(paramData);

		collabMain.getMyTask(objId, aData, $("#" + objId).closest('.cRContBottom').data("cal_mode"));
	},
	reloadMain:function(objId){
		if ($("#"+objId).data("tagval") != undefined && $("#"+objId).data("tagval") != "")
			collabMain.getTagTask($("#"+objId),"TAG",$("#"+objId).data("tagval"));
		else
			$('#'+objId+' .btnRefresh').trigger('click');
	},
}

var initData = '';


	