/* 레이어 열고 시작  */
function fnShow(obj) {
	if (document.getElementById(obj).style.display == "none") {
		document.getElementById(obj).style.display = ""
	} else {
		document.getElementById(obj).style.display = "none"
	}
}

function hidden_layer(layer_name)
{
	if (layer_name == '') return;
	$("#"+layer_name).hide();
}

function show_layer(layer_name)
{
	if (layer_name == '') return;
	$("#"+layer_name).show();
}
/* 레이어 열고 닫기 끝 */
