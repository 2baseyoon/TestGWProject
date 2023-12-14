/**
 * myContents - 마이 컨텐츠
 */
var myContents ={
	scrollIndex: 0,
	scrollInfo: {},
	webpartType: '', 
	seesionObj: {},
	init: function (data,ext){
		var _ext = (typeof ext == 'object') ? ext : {};
		myContents.scrollInfo = $.extend(myContents.scrollInfo, _ext.scrollInfo);
		
		this.sessionObj = Common.getSession();
		this.getWebpartList();
	},
	goMyContentsSetPopup: function(){
		var webpartArr = new Array();
		
		$("div[name='mycontents_webpart']").each(function(idx, obj){
			webpartArr.push($(obj).attr("value"));
		})
		
		Common.open("","setMyContents",Common.getDic("lbl_ContentSet"),"/groupware/mycontents/goMyContentsSetPopup.do?webpartArr="+webpartArr.join("-")+"&contentsMode=MyContents","720px","380px","iframe",true,null,null,true);
	},
	getWebpartList: function(){
		$(".myContentView > div").attr("style", "").css("height", "100%");

		$.ajax({
			url: "/groupware/mycontents/getMyContentSetWebpartList.do",
			type: "post",
			data: {
				contentsMode: "MyContents"
			},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
		    		var oScript = document.createElement("script");
		    		var oScriptText = document.createTextNode(data.myContentsJavaScript);
		    		oScript.appendChild(oScriptText);
		    		document.body.appendChild(oScript);
		    		
		    		myContents.loadWebpart(data.webpartList);
		    		
		    		// 이벤트 바인딩
		    		myContents.setSortTable();
		    		myContents.deleteMycontents();
	    		}
	    	}, 
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/mycontents/getMyContentSetWebpartList.do", response, status, error);
	    	}
			
		});
	},
	loadWebpart: function(webpartList){
		$("#myContents_ItemList").html('');
		$.each(webpartList, function(idx, value){
			try{
				var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);
				
				if (html == '') html = Base64.b64_to_utf8( value.preview ? value.preview : "");
				
				html = "<div name='mycontents_webpart' value='"+value.WebpartID+"'>"+html+"</div>";
				
				$("#myContents_ItemList").append(html);
				
				if ($("div[name=mycontents_webpart][value="+value.WebpartID+"] .pieceBtnCont").length == 0){
					myContents.setControl(value.WebpartID);
				}
				
				if(value.initMethod != '' && typeof(value.initMethod) != 'undefined'){
					if(typeof(value.ExtentionJSON) == 'undefined'){
						value.ExtentionJSON = $.parseJSON("{}");
					}
					
					//보안취약 조치(eval, Function)
					//let ptFunc = new Function('a', 'b', 'c', Base64.b64_to_utf8(value.initMethod)+'(a, b, c)');
					//ptFunc([], value.ExtentionJSON, 'myContents') ;
					let fnName = Base64.b64_to_utf8(value.initMethod); // NS.fn
					coviCmn.callFnBasedNamespace(fnName, [], value.ExtentionJSON, 'myContents');
				}
			}catch(e){
				coviCmn.traceLog("myContent > webpart"+value.webpartID+"<br>"+e); 
			}
		});		
		coviCtrl.bindmScrollV($('.mainMyContentScroll'), myContents.scrollInfo);
	},
	setSortTable : function(){
		$( function() {
		    $( ".myContenLIneView" ).sortable({
		      connectWith: ".myContenLIneView",
		      handle: ".btnPieceMove",
		      cancel: ".pieceCont",	  
		      placeholder: "portlet-placeholder ui-corner-all",
		      stop: function() {
		    	  myContents.saveMyContentsSetting();
		    	  /* 오류 발생 시 원상 복귀 코드 
		    	  if(!myContents.saveMyContentsSetting()){
		    		  $('.myContenLIneView').sortable("cancel")                        
		    	  }*/
              }
		    });	 	 
		});	
	},
	deleteMycontents : function(){
		$('.btnPieceRemove').click( function(){
			$(this).parents("div[name='mycontents_webpart']").remove();

			myContents.saveMyContentsSetting();
			
			//오류 발생 시 원상 복귀 코드 
			/*$(this).parents("div[name='mycontents_webpart']").addClass("removeTarget");
			
			if(!myContents.saveMyContentsSetting()){
				$(this).parents("div[name='mycontents_webpart']").removeClass("removeTarget");
			}else{
				$(this).parents("div[name='mycontents_webpart']").remove();
			}*/
			
		});
	},
	remove: function(target){
		$(target).closest('div[name=mycontents_webpart]').remove();
	},
	setControl: function(target){
		$("div[name=mycontents_webpart][value="+target+"] .webpart-top a").remove();
		$("div[name=mycontents_webpart][value="+target+"] .webpart-top").append(
			'<div class="pieceBtnCont">'+
			'<a class="btnPieceMove"></a>'+
			'<a class="btnPieceRemove" onclick="javascript:myContents.remove(this);"></a>'+
			'</div>'
		);
		$("div[name=mycontents_webpart][value="+target+"] div:first").removeAttr("style").addClass("myContPiece");
		$("div[name=mycontents_webpart][value="+target+"] div:first div:first").addClass("pieceTop");
		$("div[name=mycontents_webpart][value="+target+"] div:first .webpart-content").addClass("pieceCont");
	},
	saveMyContentsSetting : function(){
		//var retVal = false;
		var webpartArr = new Array();
		
		$("div[name='mycontents_webpart']:not(.removeTarget)").each(function(idx, obj){
			webpartArr.push($(obj).attr("value"));
		})
		
		$.ajax({
			url: "/groupware/mycontents/saveMyContentsSetting.do",
			type: "post",
			//async: false, 
			data: {
				webparts: 	webpartArr.join("-"),
				contentsMode: "MyContents"
			},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			//retVal =  true;
	    		}else{
	    			Common.Error("<spring:message code='Cache.msg_MyP_ErrorMsg'/>");  //에러가 발생하였습니다. 새로고침 후  다시 시도하여주세요.<br />지속적으로 문제가 발생하면 관리자에게 문의 바랍니다.
	    		}
	    	}, 
	    	error:function(response, status, error){
	    		CFN_ErrorAjax("/groupware/mycontents/saveMyContentsSetting.do", response, status, error);
	    	}
		});
		
		//return retVal;
	},
	emptyList : function(target){
		var emptyHtml = '';
		if($(target).prop("tagName") == "UL"){
			emptyHtml += '<li style="text-align: center;border-width: 0px;margin-top: calc(40%);">';
			emptyHtml +='<span style="color: rgb(153, 153, 153);"><spring:message code="Cache.msg_NoDataList"/></span>';
			emptyHtml +='</li>';
		}else{
			emptyHtml += '<div style="text-align: center;border-width: 0px;margin-top: calc(40%);">';
			emptyHtml +='<span style="color: rgb(153, 153, 153);"><spring:message code="Cache.msg_NoDataList"/></span>';
			emptyHtml +='</div>';
		}
		
		$(target).empty().append(emptyHtml);
	}
}
