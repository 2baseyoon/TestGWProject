package egovframework.coviframework.vo;

import java.text.SimpleDateFormat;
import java.util.Date;

import egovframework.baseframework.data.CoviMap;



public class ObjectAcl {
	
	private int objectID = 0; 				// 권한을 설정할 개체 ID
    private String objectType = ""; 		// 권한을 설정할 개체 Type
    private String subjectCode = ""; 		// 권한이 적용 대상(사람/그룹) 코드
    private String subjectType = ""; 		// 권한 적용 대상
    private String aclList = "";			// 접근 권한 (SCDMEVR) - 권한이 없는 경우 _로 표시 
    private String security = ""; 			// 보안 권한(S)
    private String create = ""; 			// 생성 권한(C)
    private String delete = ""; 			// 삭제 권한(D)
    private String modify = ""; 			// 수정 권한(M)
    private String execute = ""; 			// 실행 권한(E)
    private String view = ""; 				// 표시 권한(V)
    private String read = ""; 				// 읽기 권한(R)
    private String description= "";			// 설명
    private String registerCode= "";		// 등록자 코드
    private String registDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());	// 등록 일시
    
    
	public int getObjectID() {
		return objectID;
	}
	public void setObjectID(int objectID) {
		this.objectID = objectID;
	}
	public String getObjectType() {
		return objectType;
	}
	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}
	public String getSubjectCode() {
		return subjectCode;
	}
	public void setSubjectCode(String subjectCode) {
		this.subjectCode = subjectCode;
	}
	public String getSubjectType() {
		return subjectType;
	}
	public void setSubjectType(String subjectType) {
		this.subjectType = subjectType;
	}
	
	public String getAclList() {
		return aclList;
	}
	
	public void setAclList(String aclList) {
		//접근 권한 (SCDMEVR) - 권한이 없는 경우 _로 표시 
		
		this.aclList = aclList;
		
		this.security = (this.aclList.substring(0,1).equals("S"))?"S":"_";
		this.create = (this.aclList.substring(1,2).equals("C"))?"C":"_";			
		this. delete = (this.aclList.substring(2,3).equals("D"))?"D":"_"; 			
		this. modify = (this.aclList.substring(3,4).equals("M"))?"M":"_";			
		this.execute = (this.aclList.substring(4,5).equals("E"))?"E":"_";		
		this.view = (this.aclList.substring(5,6).equals("V"))?"V":"_"; 				
		this.read = (this.aclList.substring(6,7).equals("R"))?"R":"_";
	}
	
	public String getSecurity() {
		return security;
	}
	public void setSecurity(String security) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.security = security.equals("S")?security:"_";
		this.aclList = security+this.aclList.substring(1);
	}
	
	public String getCreate() {
		return create;
	}
	public void setCreate(String create) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.create = create.equals("C")?create:"_";
		this.aclList = this.aclList.substring(0,1) + create + this.aclList.substring(2);
	}
	
	public String getDelete() {
		return delete;
	}
	public void setDelete(String delete) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.delete = delete.equals("D")?delete:"_";
		this.aclList = this.aclList.substring(0,2) + delete + this.aclList.substring(3);
	}
	
	public String getModify() {
		return modify;
	}
	public void setModify(String modify) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.modify = modify.equals("M")?modify:"_";
		this.aclList = this.aclList.substring(0,3) + modify + this.aclList.substring(4);

	}
	
	public String getExecute() {
		return execute;
	}
	public void setExecute(String execute) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.execute = execute.equals("E")?execute:"_";
		this.aclList = this.aclList.substring(0,4) + execute + this.aclList.substring(5);
	}
	
	public String getView() {
		return view;
	}
	public void setView(String view) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.view = view.equals("V")?view:"_";
		this.aclList = this.aclList.substring(0,5) + view + this.aclList.substring(6);
	}
	
	public String getRead() {
		return read;
	}
	public void setRead(String read) {
		if(this.aclList.length()<7){
			this.init();
		}
		
		this.read = read.equals("V")?read:"_";
		this.aclList = this.aclList.substring(0,6) + read + this.aclList.substring(7);
	}
	
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	
	public String getRegisterCode() {
		return registerCode;
	}
	public void setRegisterCode(String registerCode) {
		this.registerCode = registerCode;
	}
	
	public String getRegistDate() {
		return registDate;
	}
	public void setRegistDate(Date registDate) {
		this.registDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(registDate);	// 등록 일시
	}
	
	//권한 초기화(모두 허용하지 않음)
	public void init(){
		this.aclList = "_______";
		
		this.security = "_";
		this.create = "_";	
		this. delete = "_";
		this. modify = "_";
		this.execute = "_";	
		this.view = "_"; 				
		this.read = "_";
	}
	
	
	public void setBaseAcl(CoviMap aclObj)
    {
        this.objectID = Integer.parseInt(aclObj.getString("ObjectID")==null?"0":aclObj.getString("ObjectID"));
        this.objectType = aclObj.getString("ObjectType")==null?"":aclObj.getString("ObjectType");
        this.subjectCode = aclObj.getString("ObjectType")==null?"":aclObj.getString("ObjectType");
        this.subjectType = aclObj.getString("ObjectType")==null?"":aclObj.getString("ObjectType");
        this.aclList = aclObj.getString("ObjectType")==null?"":aclObj.getString("ObjectType");
        this.security = aclObj.getString("Security")==null?"":aclObj.getString("Security");
        this.create = aclObj.getString("Create")==null?"":aclObj.getString("Create");
        this.delete = aclObj.getString("Delete")==null?"":aclObj.getString("Delete");
        this.modify = aclObj.getString("Modify")==null?"":aclObj.getString("Modify");
        this.execute =aclObj.getString("Execute")==null?"":aclObj.getString("Execute");
        this.view = aclObj.getString("View")==null?"":aclObj.getString("View");
        this.read = aclObj.getString("Read")==null?"":aclObj.getString("Read");
        this.description = aclObj.getString("Description")==null?"":aclObj.getString("Description");
        this.registerCode = aclObj.getString("RegisterCode")==null?"":aclObj.getString("RegisterCode");
        this.registDate = aclObj.getString("RegistDate")==null?"":aclObj.getString("RegistDate");	// 등록 일시
    }
    
}
