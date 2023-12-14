package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class CorpcardMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		map = new CoviMap();
		map.put("",				"companyCode");			//회사코드
		map.put("card_numb",		"cardNo");				//카드번호			card_corp
		map.put("card_brand",		"cardCompany");			//카드회사			card_corp
		map.put("card_class",		"cardClass");			//카드유형#공통코드	card_corp
		map.put("card_status",		"cardStatus");			//카드상태#공통코드	card_corp
		map.put("search_empl",		"ownerUserCode");		//소유자코드		card_owner
		map.put("vendor_code",		"vendorNo");			//지급처등록번호	card_owner
		map.put("withdraw_date",	"issueDate");			//발급일자			card_corp
		map.put("pay_date",			"payDate");				//결제일자			card_corp
		map.put("valid_date",		"expirationDate");		//만료년월			card_corp
		//map.put("",				"limitAmountType");		//한도금액타입
		map.put("card_limt",		"limitAmount");			//한도금액			card_corp
		map.put("memo_text",		"note");				//비고			card_corp
		map.put("search_krnm",		"searchUserUserCode");	//조회자코드		card_owner
		return map;
	}
}