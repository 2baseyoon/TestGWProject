package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class CostCenterVO  {
	
	private String companyCode;		//회사코드
	private String costCenterType;	//CostCenter타입#공통코드
	private String costCenterCode;	//CostCenter코드
	private String costCenterName;	//CostCenter명
	private String nameCode;		//명칭코드
	private String usePeriodStart;	//사용기간시작일
	private String usePeriodFinish;	//사용기간종료일
	private String isPermanent;		//영구여부
	private String isUse;			//사용여부
	private String description;		//비고
	
	private String registerID;
	private String registDate;
	private String modifierID;
	private String modifyDate;
	private String total;
	
	public void setAll(CoviMap info) {
		this.companyCode		= rtString(info.get("companyCode"));
		this.costCenterType 	= rtString(info.get("costCenterType"));
		this.costCenterCode 	= rtString(info.get("costCenterCode"));
		this.costCenterName		= rtString(info.get("costCenterName"));
		this.nameCode			= rtString(info.get("nameCode"));
		this.usePeriodStart		= rtString(info.get("usePeriodStart"));
		this.usePeriodFinish	= rtString(info.get("usePeriodFinish"));
		this.isPermanent		= rtString(info.get("isPermanent"));
		this.isUse				= rtString(info.get("isUse"));
		this.description		= rtString(info.get("description"));
		this.registerID			= rtString(info.get("registerID"));
		this.registDate			= rtString(info.get("registDate"));
		this.modifierID			= rtString(info.get("modifierID"));
		this.modifyDate			= rtString(info.get("modifyDate"));
		this.total				= rtString(info.get("total"));
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	public String getCompanyCode() {
		return companyCode;
	}
	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}
	public String getCostCenterType() {
		return costCenterType;
	}
	public void setCostCenterType(String costCenterType) {
		this.costCenterType = costCenterType;
	}
	public String getCostCenterCode() {
		return costCenterCode;
	}
	public void setCostCenterCode(String costCenterCode) {
		this.costCenterCode = costCenterCode;
	}
	public String getCostCenterName() {
		return costCenterName;
	}
	public void setCostCenterName(String costCenterName) {
		this.costCenterName = costCenterName;
	}
	public String getNameCode() {
		return nameCode;
	}
	public void setNameCode(String nameCode) {
		this.nameCode = nameCode;
	}
	public String getUsePeriodStart() {
		return usePeriodStart;
	}
	public void setUsePeriodStart(String usePeriodStart) {
		this.usePeriodStart = usePeriodStart;
	}
	public String getUsePeriodFinish() {
		return usePeriodFinish;
	}
	public void setUsePeriodFinish(String usePeriodFinish) {
		this.usePeriodFinish = usePeriodFinish;
	}
	public String getIsPermanent() {
		return isPermanent;
	}
	public void setIsPermanent(String isPermanent) {
		this.isPermanent = isPermanent;
	}
	public String getIsUse() {
		return isUse;
	}
	public void setIsUse(String isUse) {
		this.isUse = isUse;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getTotal() {
		return total;
	}

	public void setTotal(String total) {
		this.total = total;
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
}
