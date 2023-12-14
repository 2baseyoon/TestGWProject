package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class CardBillMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		map = new CoviMap();
		map.put("data_index",			"sendDate");			//연계일자                                      
		map.put("item_no",				"itemNo");				//거래번호                                      
		map.put("card_no",				"cardNo");				//청구번호                                      
		map.put("info_index",			"infoIndex");			//정보구분#A;	//승인B;	//매입C;	//승인취소          
		map.put("info_type",			"infoType");			//수신정보분류코드#Y;	//신규N;	//취소                
		map.put("card_comp_index",		"cardCompIndex");		//카드사구분                                     
		map.put("card_reg_type",		"cardRegType");			//카드등록형식                                    
		map.put("card_type",			"cardType");			//카드종류                                      
		map.put("biz_place_no",			"bizPlaceNo");			//사업장번호                                     
		map.put("dept",					"dept");				//카드소유자의부서코드                                
		map.put("card_user",			"cardUserCode");		//카드소유자코드                                   
		map.put("use_date",				"useDate");				//카드사용일자                                    
		map.put("approve_date",			"approveDate");			//카드승인일자                                    
		map.put("approve_time",			"approveTime");			//카드승인시각                                    
		map.put("approve_no",			"approveNo");			//카드승인번호                                    
		map.put("withdraw_date",		"withdrawDate");		//출금일자                                      
		map.put("country_index",		"countryIndex");		//국내/해외구분#L;	//국내E;	//해외                
		map.put("amount_sign",			"amountSign");			//청구원금                                      
		map.put("amount_charge",		"amountCharge");		//수수료                                       
		map.put("amount_won",			"amountWon");			//총금액                                       
		map.put("foreign_currency",		"foreignCurrency");		//통화구분코드                                    
		map.put("amount_foreign",		"amountForeign");		//총외화금액                                     
		map.put("store_reg_no",			"storeRegNo");			//가맹점사업자번호                                  
		map.put("store_name",			"storeName");			//가맹점명                                      
		map.put("store_no",				"storeNo");				//가맹점번호                                     
		map.put("store_representative",	"storeRepresentative");	//가맹점대표자                                    
		map.put("store_condition",		"storeCondition");		//가맹점업태                                     
		map.put("store_category",		"storeCategory");		//가맹점종목                                     
		map.put("store_zip_code",		"storeZipCode");		//가맹점우편번호                                   
		map.put("store_address_1",		"storeAddress1");		//가맹점주소                                     
		map.put("store_address_2",		"storeAddress2");		//가맹점상세주소                                   
		map.put("store_tel",			"storeTel");			//가맹점전화번호                                   
		map.put("rep_amount",			"repAmount");			//공급가액                                      
		map.put("tax_amount",			"taxAmount");			//부가세                                       
		map.put("service_amount",		"serviceAmount");		//봉사료                                       
		map.put("payment_flag",			"paymentFlag");			//지급여부                                      
		map.put("payment_date",			"paymentDate");			//지급일자                                      
		map.put("collno",				"collNo");				//매입추심번호                                    
		map.put("class",				"classCode");			//구분#A;	//정상B;	//취소                        
		return map;
	}
}