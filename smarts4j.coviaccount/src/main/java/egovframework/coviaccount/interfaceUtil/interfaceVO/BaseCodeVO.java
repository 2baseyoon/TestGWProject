package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class BaseCodeVO  {
	
	private String baseCodeID;		//코드 등록 순번
	private String codeGroup;		//코드 그룹
	private String code;			//코드
	private String codeName;		//코드 이름(Base)
	private String isGroup;			//그룹여부
	private String isUse;			//사용 여부 
	private String sortKey;			//순서
	private String description;		//코드 설명
	private String reserved1;		//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
	private String reserved2;		//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
	private String reserved3;		//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
	private String reserved4;		//예비(코드에 추가적인 사항을 설정해야 하는경우에 사용)
	private String reservedInt;		//예비(코드에 추가적인 INT 사항을 설정해야 하는경우에 사용)
	private String reservedFloat;	//예비(코드에 추가적인 FLOAT 사항을 설정해야 하는경우에 사용)
	private String isSync;			//동기화여부
	private String registerID;		//등록자 코드
	private String registDate;		//등록일시
	private String modifierID;		//수정자 코드
	private String modifyDate;		//수정일시
	private String total;
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	public void setAll(CoviMap info) {
		this.baseCodeID		= rtString(info.get("baseCodeID"));			
		this.codeGroup		= rtString(info.get("codeGroup"));			
		this.code			= rtString(info.get("code"));				
		this.codeName		= rtString(info.get("codeName"));			
		this.isGroup		= rtString(info.get("isGroup"));				
		this.isUse			= rtString(info.get("isUse"));				
		this.sortKey		= rtString(info.get("sortKey"));				
		this.description	= rtString(info.get("description"));			
		this.reserved1		= rtString(info.get("reserved1"));			
		this.reserved2		= rtString(info.get("reserved2"));			
		this.reserved3		= rtString(info.get("reserved3"));			
		this.reserved4		= rtString(info.get("reserved4"));			
		this.reservedInt	= rtString(info.get("reservedInt"));			
		this.reservedFloat	= rtString(info.get("reservedFloat"));		
		this.isSync			= rtString(info.get("isSync"));				
		this.registerID		= rtString(info.get("registerID"));			
		this.registDate		= rtString(info.get("registDate"));			
		this.modifierID		= rtString(info.get("modifierID"));			
		this.modifyDate		= rtString(info.get("modifyDate"));
		this.total			= rtString(info.get("totalCount"));
	}

	public String getBaseCodeID() {
		return baseCodeID;
	}

	public void setBaseCodeID(String baseCodeID) {
		this.baseCodeID = baseCodeID;
	}

	public String getCodeGroup() {
		return codeGroup;
	}

	public void setCodeGroup(String codeGroup) {
		this.codeGroup = codeGroup;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getCodeName() {
		return codeName;
	}

	public void setCodeName(String codeName) {
		this.codeName = codeName;
	}

	public String getIsGroup() {
		return isGroup;
	}

	public void setIsGroup(String isGroup) {
		this.isGroup = isGroup;
	}

	public String getIsUse() {
		return isUse;
	}

	public void setIsUse(String isUse) {
		this.isUse = isUse;
	}

	public String getSortKey() {
		return sortKey;
	}

	public void setSortKey(String sortKey) {
		this.sortKey = sortKey;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getReserved1() {
		return reserved1;
	}

	public void setReserved1(String reserved1) {
		this.reserved1 = reserved1;
	}

	public String getReserved2() {
		return reserved2;
	}

	public void setReserved2(String reserved2) {
		this.reserved2 = reserved2;
	}

	public String getReserved3() {
		return reserved3;
	}

	public void setReserved3(String reserved3) {
		this.reserved3 = reserved3;
	}

	public String getReserved4() {
		return reserved4;
	}

	public void setReserved4(String reserved4) {
		this.reserved4 = reserved4;
	}

	public String getReservedInt() {
		return reservedInt;
	}

	public void setReservedInt(String reservedInt) {
		this.reservedInt = reservedInt;
	}

	public String getReservedFloat() {
		return reservedFloat;
	}

	public void setReservedFloat(String reservedFloat) {
		this.reservedFloat = reservedFloat;
	}

	public String getIsSync() {
		return isSync;
	}

	public void setIsSync(String isSync) {
		this.isSync = isSync;
	}

	public String getRegisterID() {
		return registerID;
	}

	public void setRegisterID(String registerID) {
		this.registerID = registerID;
	}

	public String getRegistDate() {
		return registDate;
	}

	public void setRegistDate(String registDate) {
		this.registDate = registDate;
	}

	public String getModifierID() {
		return modifierID;
	}

	public void setModifierID(String modifierID) {
		this.modifierID = modifierID;
	}

	public String getModifyDate() {
		return modifyDate;
	}

	public void setModifyDate(String modifyDate) {
		this.modifyDate = modifyDate;
	}

	public String getTotal() {
		return total;
	}

	public void setTotal(String total) {
		this.total = total;
	}
}
