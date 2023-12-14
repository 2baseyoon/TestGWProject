package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class BaseCodeMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getSapMap() {
		map = new CoviMap();

		map.put("",	"companyCode");
		map.put("",	"baseCodeID");				//코드 등록 순번
		map.put("",	"codeGroup");				//코드 그룹
		map.put("",	"code");				//코드
		map.put("",	"codeName");				//코드 이름(Base)
		map.put("",	"isGroup");				//그룹여부
		map.put("",	"isUse");				//사용 여부 
		map.put("",	"sortKey");				//순서
		map.put("",	"description");				//코드 설명
		map.put("",	"reserved1");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reserved2");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reserved3");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reserved4");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reservedInt");				//예비(코드에 추가적인 INT 사항을 설정해야 하는경우에 사용)
		map.put("",	"reservedFloat");				//예비(코드에 추가적인 FLOAT 사항을 설정해야 하는경우에 사용)
		map.put("",	"isSync");					//동기화여부
		map.put("",	"registerID");				//등록자 코드
		map.put("",	"registDate");				//등록일시
		map.put("",	"modifierID");				//수정자 코드
		map.put("",	"modifyDate");				//수정일시
		return map;
	}
	
	public CoviMap getSapODataMap() {
		map = new CoviMap();

		map.put("",	"companyCode");
		map.put("",	"baseCodeID");				//코드 등록 순번
		map.put("",	"codeGroup");				//코드 그룹
		map.put("",	"code");				//코드
		map.put("",	"codeName");				//코드 이름(Base)
		map.put("",	"isGroup");				//그룹여부
		map.put("",	"isUse");				//사용 여부 
		map.put("",	"sortKey");				//순서
		map.put("",	"description");				//코드 설명
		map.put("",	"reserved1");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reserved2");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reserved3");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reserved4");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("",	"reservedInt");				//예비(코드에 추가적인 INT 사항을 설정해야 하는경우에 사용)
		map.put("",	"reservedFloat");				//예비(코드에 추가적인 FLOAT 사항을 설정해야 하는경우에 사용)
		map.put("",	"isSync");					//동기화여부
		map.put("",	"registerID");				//등록자 코드
		map.put("",	"registDate");				//등록일시
		map.put("",	"modifierID");				//수정자 코드
		map.put("",	"modifyDate");				//수정일시
		return map;
	}
	
	public CoviMap getSapODataIOMap() {
		map = new CoviMap();
		
		map.put("",	"baseCodeID");				//코드 등록 순번
		map.put("",	"codeGroup");				//코드 그룹
		map.put("WBSElement",	"code");				//코드
		map.put("WBSDescription",	"codeName");				//코드 이름(Base)
		map.put("",	"isGroup");				//그룹여부
		map.put("",	"isUse");				//사용 여부 
		map.put("",	"sortKey");				//순서
		map.put("",	"description");				//코드 설명
		map.put("FunctionalArea",	"reserved1");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("ProfitCenter",	"reserved2");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("Project",	"reserved3");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("WBSElementObject",	"reserved4");				//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
		map.put("WBSElementInternalID",	"reservedInt");				//예비(코드에 추가적인 INT 사항을 설정해야 하는경우에 사용)
		map.put("",	"reservedFloat");				//예비(코드에 추가적인 FLOAT 사항을 설정해야 하는경우에 사용)
		map.put("",	"isSync");					//동기화여부
		map.put("",	"registerID");				//등록자 코드
		map.put("",	"registDate");				//등록일시
		map.put("",	"modifierID");				//수정자 코드
		map.put("",	"modifyDate");				//수정일시
		
		map.put("",	"wbsElementInternalID");
		map.put("CompanyCode",	"companyCode");
		map.put("ControllingArea",	"controllingArea");
		map.put("",	"functionalArea");
		map.put("",	"profitCenter");
		map.put("ProjectInternalID",	"projectInternalID");
		map.put("",	"Project");
		map.put("WBSElementIsBillingElement",	"wbsElementIsBillingElement");
		map.put("",	"wbsElementObject");
				
		return map;
	}
}
