package egovframework.coviframework.vo;

import java.io.Serializable;

public class AdminMenuAuth implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -497053257803489101L;

	private Integer CN_ID;
	private String ContainerType;
	private String Alias;
	private String DisplayName;
	private String LinkMN;
	private String LinkSystem;
	private long MemberOf;
	private Integer SortKey;
	private String IsURL;
	private String URL;
	private String IsUse;
	private String Description;
	private String RegID;
	private String RegDate;
	private String ModID;
	private String ModDate;
	private long ChildCount;
	private Integer PG_ID;
	private String ProgramURL;
	private String ProgramName;
	private String ProgramAlias;
	private String ProgramType;
	private String ProgramDescription;
	private String ProgramBizSection;
	private String Ko;
	private String En;
	private String Ja;
	private String Zh;
	private String Reserved1;
	private String Reserved2;
	
	public AdminMenuAuth(){}
	
	public AdminMenuAuth(Integer cnID,String containerType,String alias,String displayName,String linkMN,String linkSystem,long memberOf,
			Integer sortKey,String isURL,String url,String isUse,String description,String regID,String regDate,String modID,String modDate, long childCount,
			String programURL,Integer pgID,String programName,String programAlias,String programType,String programDescription,String programBizSection,
			String ko,String en,String ja,String zh,String reserved1,String reserved2){
		 
		this.CN_ID = cnID;
		this.ContainerType = containerType;
		this.Alias = alias;
		this.DisplayName = displayName;
		this.LinkMN = linkMN;
		this.LinkSystem = linkSystem;
		this.MemberOf = memberOf;
		this.SortKey = sortKey;
		this.IsURL = isURL;
		this.URL = url;
		this.IsUse = isUse;
		this.Description = description;
		this.RegID = regID;
		this.RegDate = regDate;
		this.ModID = modID;
		this.ModDate = modDate;
		this.ChildCount = childCount;
		this.PG_ID = pgID;
		this.ProgramURL = programURL;
		this.ProgramName = programName;
		this.ProgramAlias = programAlias;
		this.ProgramType = programType;
		this.ProgramDescription = programDescription;
		this.ProgramBizSection = programBizSection;
		this.Ko = ko;
		this.En = en;
		this.Ja = ja;
		this.Zh = zh;
		this.Reserved1 = reserved1;
		this.Reserved2 = reserved2;
		
	}
	

	public Integer getCN_ID() {
		return CN_ID;
	}

	public void setCN_ID(Integer cN_ID) {
		CN_ID = cN_ID;
	}

	public String getContainerType() {
		return ContainerType;
	}

	public void setContainerType(String containerType) {
		ContainerType = containerType;
	}

	public String getAlias() {
		return Alias;
	}

	public void setAlias(String alias) {
		Alias = alias;
	}

	public String getDisplayName() {
		return DisplayName;
	}

	public void setDisplayName(String displayName) {
		DisplayName = displayName;
	}

	public String getLinkMN() {
		return LinkMN;
	}

	public void setLinkMN(String linkMN) {
		LinkMN = linkMN;
	}

	public String getLinkSystem() {
		return LinkSystem;
	}

	public void setLinkSystem(String linkSystem) {
		LinkSystem = linkSystem;
	}

	public long getMemberOf() {
		return MemberOf;
	}

	public void setMemberOf(long memberOf) {
		MemberOf = memberOf;
	}

	public Integer getSortKey() {
		return SortKey;
	}

	public void setSortKey(Integer sortKey) {
		SortKey = sortKey;
	}

	public String getIsURL() {
		return IsURL;
	}

	public void setIsURL(String isURL) {
		IsURL = isURL;
	}

	public String getURL() {
		return URL;
	}

	public void setURL(String uRL) {
		URL = uRL;
	}

	public String getIsUse() {
		return IsUse;
	}

	public void setIsUse(String isUse) {
		IsUse = isUse;
	}

	public String getDescription() {
		return Description;
	}

	public void setDescription(String description) {
		Description = description;
	}

	public String getRegID() {
		return RegID;
	}

	public void setRegID(String regID) {
		RegID = regID;
	}

	public String getRegDate() {
		return RegDate;
	}

	public void setRegDate(String regDate) {
		RegDate = regDate;
	}

	public String getModID() {
		return ModID;
	}

	public void setModID(String modID) {
		ModID = modID;
	}

	public String getModDate() {
		return ModDate;
	}

	public void setModDate(String modDate) {
		ModDate = modDate;
	}

	public long getChildCount() {
		return ChildCount;
	}

	public void setChildCount(long childCount) {
		ChildCount = childCount;
	}

	public Integer getPG_ID() {
		return PG_ID;
	}

	public void setPG_ID(Integer pG_ID) {
		PG_ID = pG_ID;
	}

	public String getProgramURL() {
		return ProgramURL;
	}

	public void setProgramURL(String programURL) {
		ProgramURL = programURL;
	}

	public String getProgramName() {
		return ProgramName;
	}

	public void setProgramName(String programName) {
		ProgramName = programName;
	}

	public String getProgramAlias() {
		return ProgramAlias;
	}

	public void setProgramAlias(String programAlias) {
		ProgramAlias = programAlias;
	}

	public String getProgramType() {
		return ProgramType;
	}

	public void setProgramType(String programType) {
		ProgramType = programType;
	}

	public String getProgramDescription() {
		return ProgramDescription;
	}

	public void setProgramDescription(String programDescription) {
		ProgramDescription = programDescription;
	}

	public String getProgramBizSection() {
		return ProgramBizSection;
	}

	public void setProgramBizSection(String programBizSection) {
		ProgramBizSection = programBizSection;
	}

	public String getKo() {
		return Ko;
	}

	public void setKo(String ko) {
		Ko = ko;
	}

	public String getEn() {
		return En;
	}

	public void setEn(String en) {
		En = en;
	}

	public String getJa() {
		return Ja;
	}

	public void setJa(String ja) {
		Ja = ja;
	}

	public String getZh() {
		return Zh;
	}

	public void setZh(String zh) {
		Zh = zh;
	}

	public String getReserved1() {
		return Reserved1;
	}

	public void setReserved1(String reserved1) {
		Reserved1 = reserved1;
	}

	public String getReserved2() {
		return Reserved2;
	}

	public void setReserved2(String reserved2) {
		Reserved2 = reserved2;
	}
	

}
