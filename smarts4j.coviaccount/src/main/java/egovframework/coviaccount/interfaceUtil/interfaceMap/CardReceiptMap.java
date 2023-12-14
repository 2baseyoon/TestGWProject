package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class CardReceiptMap {
	private CoviMap map = new CoviMap();
	
	public CoviMap getSoapMap(){
		map = new CoviMap();

		map.put("total_count",			"totalCount");
		map.put("RECEIPT_ID",			"receiptID");
		map.put("",						"approveStatus");
		map.put("DATA_INDEX",			"dataIndex");
		map.put("",						"sendData");
		map.put("",						"itemNo");
		map.put("CARD_NO",				"cardNo");
		map.put("",						"infoIndex");
		map.put("",						"infoType");
		map.put("CARD_COMP_INDEX",		"cardCompIndex");
		map.put("",						"cardRegType");
		map.put("",						"cardType");
		map.put("CORP_BIZNO",			"bizPlaceNo");
		map.put("",						"dept");
		map.put("CARD_EMPL",			"cardUserCode");
		map.put("",						"useDate");
		map.put("APPROVE_DATE",			"approveDate");
		map.put("APPROVE_TIME",			"approveTime");
		map.put("APPROVE_NO",			"approveNo");
		map.put("",						"withdrawDate");
		map.put("",						"countryIndex");
		map.put("ApprAmt1",				"amountSign");
		map.put("AMOUNT_WON",			"amountWon");
		map.put("FOREIGN_CURRENCY",		"foreignCurrency");
		map.put("AMOUNT_FOREIGN",		"amountForeign");
		map.put("STORE_REG_NO",			"storeRegNo");
		map.put("STORE_NAME",			"storeName");
		map.put("",						"storeNo");
		map.put("STORE_REPRESENTATIVE",	"storeRepresentative");
		map.put("",						"storeCondition");
		map.put("STORE_CATEGORY",		"storeCategory");
		map.put("",						"storeZipCode");
		map.put("STORE_ADDRESS_1",		"storeAddress1");
		map.put("STORE_ADDRESS_2",		"storeAddress2");
		map.put("",						"storeTel");
		map.put("REP_AMOUNT",			"repAmount");
		map.put("TAX_AMOUNT",			"taxAmount");
		map.put("SERVICE_AMOUNT",		"serviceAmount");
		map.put("",						"active");
		map.put("",						"intDate");
		map.put("",						"collNo");
		map.put("TaxType",				"taxType");
		map.put("TaxTypeDate",			"taxTypeDate");
		map.put("",						"merchCessDate");
		map.put("",						"class1");
		map.put("",						"tossUserCode");
		map.put("",						"tossSenderUserCode");
		map.put("",						"tossDate");
		map.put("",						"tossComment");
		map.put("",						"isPersonalUse");
		
		return map;
	}
	
	public CoviMap getDBMap(){
		map = new CoviMap();
		
		map.put("total_count",			"totalCount");
		map.put("receipt_id",			"receiptID");
		map.put("approve_status",		"approveStatus");
		map.put("data_index",			"dataIndex");
		map.put("send_data",			"sendData");
		map.put("item_no",				"itemNo");
		map.put("card_no",				"cardNo");
		map.put("info_index",			"infoIndex");
		map.put("info_type",			"infoType");
		map.put("card_comp_index",		"cardCompIndex");
		map.put("card_reg_type",		"cardRegType");
		map.put("card_type",			"cardType");
		map.put("biz_place_no",			"bizPlaceNo");
		map.put("dept",					"dept");
		map.put("card_user",			"cardUserCode");
		map.put("use_date",				"useDate");
		map.put("approve_date",			"approveDate");
		map.put("approve_time",			"approveTime");
		map.put("approve_no",			"approveNo");
		map.put("withdraw_date",		"withdrawDate");
		map.put("country_index",		"countryIndex");
		map.put("amount_sign",			"amountSign");
		map.put("amount_won",			"amountWon");
		map.put("foreign_currency",		"foreignCurrency");
		map.put("amount_foreign",		"amountForeign");
		map.put("store_reg_no",			"storeRegNo");
		map.put("store_name",			"storeName");
		map.put("store_no",				"storeNo");
		map.put("store_representative",	"storeRepresentative");
		map.put("store_condition",		"storeCondition");
		map.put("store_category",		"storeCategory");
		map.put("store_zip_code",		"storeZipCode");
		map.put("store_address_1",		"storeAddress1");
		map.put("store_address_2",		"storeAddress2");
		map.put("store_tel",			"storeTel");
		map.put("rep_amount",			"repAmount");
		map.put("tax_amount",			"taxAmount");
		map.put("service_amount",		"serviceAmount");
		map.put("active",				"active");
		map.put("int_datetime",			"intDate");
		map.put("collno",				"collNo");
		map.put("taxtype",				"taxType");
		map.put("taxtypedate",			"taxTypeDate");
		map.put("merchcessdate",		"merchCessDate");
		map.put("class",				"class1");
		map.put("toss_employee_code",	"tossUserCode");
		map.put("toss_sender",			"tossSenderUserCode");
		map.put("toss_datetime",		"tossDate");
		map.put("toss_comment",			"tossComment");
		//map.put("",					"isPersonalUse");
		
		return map;
	}
	
	public CoviMap getInfoTechDBMap(){
		map = new CoviMap();
		
		map.put("RECEIPT_ID",	"receiptID");
		map.put("",				"approveStatus");
		map.put("",				"dataIndex");
		map.put("",				"sendData");
		map.put("",				"itemNo");
		map.put("카드번호",		"cardNo");
		map.put("INFO_INDEX",	"infoIndex");
		map.put("",				"infoType");
		map.put("카드사코드",		"cardCompIndex");
		map.put("",				"cardRegType");
		map.put("",				"cardType");
		map.put("사업자번호",		"bizPlaceNo");
		map.put("",				"dept");
		map.put("",				"cardUserCode");
		map.put("",				"useDate");
		map.put("승인일자",		"approveDate");
		map.put("승인시간",		"approveTime");
		map.put("승인번호",		"approveNo");
		map.put("",				"withdrawDate");
		map.put("",				"countryIndex");
		map.put("",				"amountSign");
		map.put("승인금액",		"amountWon");
		map.put("",				"foreignCurrency");
		map.put("",				"amountForeign");
		map.put("가맹점사업자번호",	"storeRegNo");
		map.put("가맹점명",		"storeName");
		map.put("",				"storeNo");
		map.put("가맹점대표자명",	"storeRepresentative");
		map.put("",				"storeCondition");
		map.put("",				"storeCategory");
		map.put("",				"storeZipCode");
		map.put("가맹점주소",		"storeAddress1");
		map.put("",				"storeAddress2");
		map.put("가맹점전화번호",	"storeTel");
		map.put("공급가액",		"repAmount");
		map.put("부가세",			"taxAmount");
		map.put("봉사료",			"serviceAmount");
		map.put("",				"active");
		map.put("",				"intDate");
		map.put("",				"collNo");
		map.put("",				"taxType");
		map.put("",				"taxTypeDate");
		map.put("",				"merchCessDate");
		map.put("CLASS",		"class1");
		map.put("",				"tossUserCode");
		map.put("",				"tossSenderUserCode");
		map.put("",				"tossDate");
		map.put("",				"tossComment");
		map.put("",				"isPersonalUse");
		
		return map;
	}
	
	public CoviMap getSapMap(){
		map = new CoviMap();
		
		map.put("ZUONR",		"receiptID");			//내부승인관리번호
		map.put("",				"approveStatus");		//결재구분
		map.put("FINISH",		"dataIndex");			//구분자#BUY:매입,BIL:청구,AUT:승인
		map.put("",				"sendDate");			//연계일자
		map.put("",				"itemNo");				//거래번호
		map.put("CARDNO",		"cardNo");				//카드번호
		map.put("",				"infoIndex");			//정보구분#A:승인,B:매입,C:승인취소
		map.put("",				"infoType");			//수신정보분류코드#Y:신규,N:취소
		map.put("",				"cardCompIndex");		//카드사구분
		map.put("",				"cardRegType");			//카드등록형식
		map.put("",				"cardType");			//카드종류
		map.put("",				"bizPlaceNo");			//사업장번호
		map.put("KOSTL",		"dept");				//카드소유자의부서코드
		map.put("PERNR_CARD",	"cardUserCode");		//카드소유자코드
		map.put("",				"useDate");				//카드사용일자
		map.put("TRANSDATE",	"approveDate");			//카드승인일자
		map.put("",				"approveTime");			//카드승인시각
		map.put("APPRNO",		"approveNo");			//카드승인번호
		map.put("",				"withdrawDate");		//출금일자
		map.put("",				"countryIndex");		//국내/해외구분#L:국내,E:해외
		map.put("",				"amountSign");			//금액부호
		map.put("APPRTOT",		"amountWon");			//총금액
		map.put("CURRCODE",		"foreignCurrency");		//통화구분코드
		map.put("",				"amountForeign");		//총외화금액
		map.put("MERCHBIZNO",	"storeRegNo");			//가맹점사업자번호
		map.put("MERCHNAME",	"storeName");			//가맹점명
		map.put("",				"storeNo");				//가맹점번호
		map.put("",				"storeRepresentative");	//가맹점대표자
		map.put("",				"storeCondition");		//가맹점업태
		map.put("",				"storeCategory");		//가맹점종목
		map.put("",				"storeZipCode");		//가맹점우편번호
		map.put("",				"storeAddress1");		//가맹점주소
		map.put("",				"storeAddress2");		//가맹점상세주소
		map.put("",				"storeTel");			//가맹점전화번호
		map.put("APPRAMT",		"repAmount");			//공급가액
		map.put("VAT",			"taxAmount");			//부가세
		map.put("TIPS",			"serviceAmount");		//봉사료
		map.put("",				"active");				//정산처리여부#N:미정산,Y:정산서작성중,I:정산서상신완료
		map.put("",				"intDate");				//인터페이스시각
		map.put("",				"collNo");				//매입추심번호
		map.put("TAXTYPE",		"taxType");				//과세유형
		map.put("",				"taxTypeDate");			//과세유형조회일
		map.put("",				"merchCessDate");		//폐업일
		map.put("",				"class");				//구분#A:정상,B:승인취소
		map.put("",				"tossUserCode");		//전달받은사용자코드
		map.put("",				"tossSenderUserCode");	//전달자사용자코드
		map.put("",				"tossDate");			//전달일시
		map.put("",				"tossCOMMENT");			//전달시코멘트
		map.put("ZPKIND",		"isPersonalUse");		//개인사용여부
		
		return map;
	}
	
	public CoviMap getSapODataMap(){
		map = new CoviMap();
		
		map.put("ZUONR",		"receiptID");			//내부승인관리번호
		map.put("",				"approveStatus");		//결재구분
		map.put("FINISH",		"dataIndex");			//구분자#BUY:매입,BIL:청구,AUT:승인
		map.put("",				"sendDate");			//연계일자
		map.put("",				"itemNo");				//거래번호
		map.put("CARDNO",		"cardNo");				//카드번호
		map.put("",				"infoIndex");			//정보구분#A:승인,B:매입,C:승인취소
		map.put("",				"infoType");			//수신정보분류코드#Y:신규,N:취소
		map.put("",				"cardCompIndex");		//카드사구분
		map.put("",				"cardRegType");			//카드등록형식
		map.put("",				"cardType");			//카드종류
		map.put("",				"bizPlaceNo");			//사업장번호
		map.put("KOSTL",		"dept");				//카드소유자의부서코드
		map.put("PERNR_CARD",	"cardUserCode");		//카드소유자코드
		map.put("",				"useDate");				//카드사용일자
		map.put("TRANSDATE",	"approveDate");			//카드승인일자
		map.put("",				"approveTime");			//카드승인시각
		map.put("APPRNO",		"approveNo");			//카드승인번호
		map.put("",				"withdrawDate");		//출금일자
		map.put("",				"countryIndex");		//국내/해외구분#L:국내,E:해외
		map.put("",				"amountSign");			//금액부호
		map.put("APPRTOT",		"amountWon");			//총금액
		map.put("CURRCODE",		"foreignCurrency");		//통화구분코드
		map.put("",				"amountForeign");		//총외화금액
		map.put("MERCHBIZNO",	"storeRegNo");			//가맹점사업자번호
		map.put("MERCHNAME",	"storeName");			//가맹점명
		map.put("",				"storeNo");				//가맹점번호
		map.put("",				"storeRepresentative");	//가맹점대표자
		map.put("",				"storeCondition");		//가맹점업태
		map.put("",				"storeCategory");		//가맹점종목
		map.put("",				"storeZipCode");		//가맹점우편번호
		map.put("",				"storeAddress1");		//가맹점주소
		map.put("",				"storeAddress2");		//가맹점상세주소
		map.put("",				"storeTel");			//가맹점전화번호
		map.put("APPRAMT",		"repAmount");			//공급가액
		map.put("VAT",			"taxAmount");			//부가세
		map.put("TIPS",			"serviceAmount");		//봉사료
		map.put("",				"active");				//정산처리여부#N:미정산,Y:정산서작성중,I:정산서상신완료
		map.put("",				"intDate");				//인터페이스시각
		map.put("",				"collNo");				//매입추심번호
		map.put("TAXTYPE",		"taxType");				//과세유형
		map.put("",				"taxTypeDate");			//과세유형조회일
		map.put("",				"merchCessDate");		//폐업일
		map.put("",				"class");				//구분#A:정상,B:승인취소
		map.put("",				"tossUserCode");		//전달받은사용자코드
		map.put("",				"tossSenderUserCode");	//전달자사용자코드
		map.put("",				"tossDate");			//전달일시
		map.put("",				"tossCOMMENT");			//전달시코멘트
		map.put("ZPKIND",		"isPersonalUse");		//개인사용여부
		
		return map;
	}
	
	public CoviMap getKwicDBMap(){
		map = new CoviMap();
		
		map.put("RECEIPT_ID",	"receiptID");
		map.put("",				"approveStatus");
		map.put("",				"dataIndex");
		map.put("",				"sendData");
		map.put("",				"itemNo");
		map.put("카드번호",		"cardNo");
		map.put("INFO_INDEX",	"infoIndex");
		map.put("",				"infoType");
		map.put("카드사코드",		"cardCompIndex");
		map.put("",				"cardRegType");
		map.put("",				"cardType");
		map.put("사업자번호",		"bizPlaceNo");
		map.put("",				"dept");
		map.put("",				"cardUserCode");
		map.put("",				"useDate");
		map.put("승인일자",		"approveDate");
		map.put("승인시간",		"approveTime");
		map.put("승인번호",		"approveNo");
		map.put("",				"withdrawDate");
		map.put("",				"countryIndex");
		map.put("",				"amountSign");
		map.put("승인금액",		"amountWon");
		map.put("",				"foreignCurrency");
		map.put("",				"amountForeign");
		map.put("가맹점사업자번호",	"storeRegNo");
		map.put("가맹점명",		"storeName");
		map.put("",				"storeNo");
		map.put("가맹점대표자명",	"storeRepresentative");
		map.put("",				"storeCondition");
		map.put("",				"storeCategory");
		map.put("",				"storeZipCode");
		map.put("가맹점주소",		"storeAddress1");
		map.put("",				"storeAddress2");
		map.put("가맹점전화번호",	"storeTel");
		map.put("공급가액",		"repAmount");
		map.put("부가세",			"taxAmount");
		map.put("봉사료",			"serviceAmount");
		map.put("",				"active");
		map.put("",				"intDate");
		map.put("",				"collNo");
		map.put("",				"taxType");
		map.put("",				"taxTypeDate");
		map.put("",				"merchCessDate");
		map.put("CLASS",		"class1");
		map.put("",				"tossUserCode");
		map.put("",				"tossSenderUserCode");
		map.put("",				"tossDate");
		map.put("",				"tossComment");
		map.put("",				"isPersonalUse");
		
		return map;
	}

	public CoviMap getKwicPurchaseMap(){
        map = new CoviMap();
        
        map.put("RECEIPT_ID",	"receiptID");
        map.put("",				"approveStatus");
        map.put("",				"dataIndex");
        map.put("",				"sendData");
        map.put("",				"itemNo");
        map.put("카드번호",		"cardNo");
        map.put("INFO_INDEX",	"infoIndex");
        map.put("",				"infoType");
        map.put("카드사코드",		"cardCompIndex");
        map.put("",				"cardRegType");
        map.put("",				"cardType");
        map.put("사업자번호",		"bizPlaceNo");
        map.put("",				"dept");
        map.put("",				"cardUserCode");
        map.put("",				"useDate");
        map.put("이용일",			"approveDate");
        map.put("이용시간",		"approveTime");
        map.put("승인번호",		"approveNo");
        map.put("",				"withdrawDate");
        map.put("",				"countryIndex");
        map.put("",				"amountSign");
        map.put("이용금액",		"amountWon");
        map.put("",				"foreignCurrency");
        map.put("",				"amountForeign");
        map.put("가맹점사업자번호",	"storeRegNo");
        map.put("이용가맹점명",		"storeName");
        map.put("",				"storeNo");
        map.put("가맹점대표자명",	"storeRepresentative");
        map.put("",				"storeCondition");
        map.put("",				"storeCategory");
        map.put("",				"storeZipCode");
        map.put("가맹점주소",		"storeAddress1");
        map.put("",				"storeAddress2");
        map.put("가맹점전화번호",	"storeTel");
        map.put("가맹점상태",		"storeStatus");
        map.put("공급가액",		"repAmount");
        map.put("부가세",			"taxAmount");
        map.put("",				"serviceAmount");
        map.put("",				"active");
        map.put("",				"intDate");
        map.put("",				"collNo");
        map.put("",				"taxType");
        map.put("",				"taxTypeDate");
        map.put("",				"merchCessDate");
        map.put("CLASS",		"class1");
        map.put("",				"tossUserCode");
        map.put("",				"tossSenderUserCode");
        map.put("",				"tossDate");
        map.put("",				"tossComment");
        map.put("",				"isPersonalUse");
        
        return map;
	}

	
}
