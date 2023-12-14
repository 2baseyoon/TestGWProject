// 검색
var Search = function() {
	var isSaaS = $('input[name=isSaaS]:checked').val();
	var dbType = $('input[name=dbType]:checked').val();
	var wasType = $('input[name=wasType]:checked').val();
	
	var view_isSaaS = $('input[name=isSaaS]:checked').val();
	var view_dbType =  $('label[for=radio_DBType_'+dbType+']').html();
	var view_wasType =  $('label[for=radio_wasType_'+wasType+']').html();
	
	$("#selectIsSaaS").html(view_isSaaS);
	$("#selectDB").html(view_dbType);
	$("#selectWAS").html(view_wasType);
	
	var propertiesArray = new Array();
	var serverArray = new Array();
	
	$("input[name='propertyType']:checked").each(function() {
		propertiesArray.push($(this).val());
    });
	
	$("input[name='serverList']:checked").each(function() {
		serverArray.push($(this).val());
    });
	
	var params = new Object();
	params.isSaaS = isSaaS;
	params.dbType = dbType;
	params.wasType = wasType;
	params.propertiesArray = propertiesArray;
	params.serverArray = serverArray;
	
	$.ajax({
		type:"POST",
		url:"/covicore/propertiesManage/getProperties.do",
		data: params,
		success:function (res) {
			if(res.status == "SUCCESS"){
				renderPropertiesList(res.list);
			} else {
				Common.Warning("조회에 실패하였습니다.");
				return;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/propertiesManage/getProperties.do", response, status, error);
		}
	});
};
	
// Data Rendering
var renderPropertiesList = function(data) {
	// ColGroup Delete  
	$(".propertiesList colgroup").empty();
	
	// HeaderData Setting
	var headerData = "";
	$("input[name='serverList']:checked").each(function() {
		headerData += "<th>" + $(this).val() + "</th>";
    });		
	
	// HeaderData Rendering
	$("#headerList").empty().append("<th style='width:150px' >Properties type</th><th>Key name</th><th style='width:150px'>설정타입(가변/불변)</th><th>Reference Value</th>" + headerData + "<th>Description</th>");
	
	if(data.length > 0) {
		$("#dataList").empty();
		
		// ListData Setting
		$(data).each(function(i, value) {
			var listData = "<tr>";
			
			var referenceValue = "";
			var serverValue = "";
			$.each(value, function(key, value) {
				if(key == "referenceValue") {
					referenceValue = value;
				} else if (key.indexOf("serverIndex") == 0 && serverValue == ""){
					serverValue = value;
				}
			});
			
			$.each(value, function(key, value) {
				if(key.indexOf("serverIndex") == 0 && referenceValue != value && referenceValue != "") {
					listData += "<td style='background: #faebd7;' title='" + value + "'>" + value + "</td>";	// 표준값에는 있지만 서버값이 없는 경우
				} else if (key.indexOf("setkey") == 0 && referenceValue == "" && serverValue != "") {
					listData += "<td style='background: #ff4949;' title='" + value + "'>" + value + "</td>";	// 서버값에는 있지만 표준값이 없는 경우
				} else {
					listData += "<td title='" + value + "'>" + value + "</td>";						
				}
			});
			
			listData += "</tr>";		
			
			// ListData Rendering
			$("#dataList").append(listData);
		});
	} else {
		$("#dataList").empty().append("<tr><td colspan='"+ $("#headerList").find("th").length +"' style='text-align: center;''>조회된 데이터가 없습니다.</th></tr>");	
	}
};

// 엑셀 저장
excelDownload = function(){
	var isSaaS = $('input[name=isSaaS]:checked').val();
	var dbType = $('input[name=dbType]:checked').val();
	var wasType = $('input[name=wasType]:checked').val();
	
	var form = $('<form></form>');
    form.attr('action', "/covicore/propertiesManage/propertiesExcelDown.do");
    form.attr('method', 'post');
    form.appendTo('body');
    form.append($('<input type="hidden" value="' + isSaaS + '" name=isSaaS>'));
    form.append($('<input type="hidden" value="' + dbType + '" name=dbType>'));
    form.append($('<input type="hidden" value="' + wasType + '" name=wasType>'));
    
    $("input[name='propertyType']:checked").each(function() {
    	form.append($('<input type="hidden" value="' + $(this).val() + '" name=propertiesArray[]>'));
    });
    
    $("input[name='serverList']:checked").each(function() {
    	form.append($('<input type="hidden" value="' + $(this).val() + '" name=serverArray[]>'));
    });
    
    form.submit();
};