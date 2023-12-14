var propertiesGrid = new coviGrid();

function context() {
	contextHeader();
	searchContext();
}

function contextHeader() {
	propertiesGrid.setGridHeader([
			{	
				key: "standardtype",
				label: "Properties type",
				width: "150",
				align: "left",
				formatter: function() {
					return "context.xml"
				}
			},
			{	
				key: "name",
				label: "Name",
				width: "150",
				align: "left"
			},
			{	
				key: "setkey",
				label: "Node Name",
				width: "150",
				align: "left",
				addClass: function() {
					if (this.item.referencevalue == null || this.item.referencevalue == "") {
						return "add_non_cell";
					}
				}
			},
			{	
				key: "referenceValueType",
				label: "설정타입(가변/불변)",
				width: "150",
				align: "left"				
			},
			{	
				key: "referencevalue",
				label: "Reference Value	",
				width: "150",
				align: "left",
				addClass: function() {
					if (this.item.referencevalue != this.item.inputvalue) {
						return "add_diff_cell";
					}
				}
			},			
			{	
				key: "inputvalue",
				label: "Input Value",
				width: "150",
				align: "left",
				addClass: function() {
					if (this.item.referencevalue != this.item.inputvalue) {
						return "add_diff_cell";
					}
				}
			},
			{
				key: "Description",
				label: "description",
				width: "250",
				align: "left"
			}
	]);
	propertiesGrid.setGridConfig({
		targetID : "contextGridArea",
		height: "auto",
		paging: false,
		sort: false
	});
}

function searchContext() {
	var view_isSaaS = $('input[name=isSaaS]:checked').val();
	var view_dbType =  $('label[for=radio_DBType_'+$('input[name="dbType"]:checked').val()+']').html();
	var view_wasType =  $('label[for=radio_wasType_'+$('input[name="wasType"]:checked').val()+']').html();
	
	$("#Context_selectIsSaaS").html(view_isSaaS);
	$("#Context_selectDB").html(view_dbType);
	$("#Context_selectWAS").html(view_wasType);
	
	$.ajax({
		url: "/covicore/propertiesContextManage/list.do",
		type:"POST",
		data: {
			isSaaS: $('input[name="radio_isSaaS"]:checked').val(),
			dbType: $('input[name="dbType"]:checked').val(),
			wasType: $('input[name="wasType"]:checked').val(),
			context: $('#context').val()
		},
		success: function(data) {
			propertiesGrid.bindGrid(data);
			setGridClass();
		}
	});
}

function setGridClass() {
	console.log("setGridClass");
	
	var nonSelect = $(".add_non_cell");
	for (var i = 0; i < nonSelect.length; i++) {
		$(nonSelect[i].parentElement).css("background-color", "#ff4949");
	}
	
	var diffSelector = $(".add_diff_cell");
	for (var i = 0; i < diffSelector.length; i++) {
		$(diffSelector[i].parentElement).css("background-color", "#faebd7");
	}
}

function standardSetting() {
	var popupUrl = "/covicore/standardSetting.do";

	var popupWidth = 1500;
	var popupHeight = 800;

	var screenLeft = window.screenLeft || window.screenX;
	var screenTop = window.screenTop || window.screenY;
	var screenWidth = window.innerWidth || document.documentElement.clientWidth || window.screen.width;
	var screenHeight = window.innerHeight || document.documentElement.clientHeight || window.screen.height;
	var left = screenLeft + (screenWidth - popupWidth) / 2;
	var top = screenTop + (screenHeight - popupHeight) / 2;

	var popupWindow = window.open(popupUrl, "standardSetting", "width=" + popupWidth + ",height=" + popupHeight + ",left=" + left + ",top=" + top);

	if (!popupWindow) {
	    alert("팝업 차단 기능이 활성화되어 있습니다.");
	}
}

function contextExcelDown() {
	var dbType = $('input[name=dbType]:checked').val();
	var wasType = $('input[name=wasType]:checked').val();
	var context = $('#context').val();
	
	var form = $('<form></form>');
    form.attr('action', "/covicore/propertiesContextManage/excelDown.do");
    form.attr('method', 'post');
    form.appendTo('body');
    form.append($('<input type="hidden" value="' + dbType + '" name=dbType>'));
    form.append($('<input type="hidden" value="' + wasType + '" name=wasType>'));
 	// form.append($('<input type="hidden" value="' + encodeURIComponent(context) + '" name=context>'));
    form.append($('<textarea name="context" style="display: none;">' + encodeURIComponent(context) + '</textarea>'));
    form.submit();
}