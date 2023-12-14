package egovframework.core.sevice.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.core.sevice.OrgChartSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;

import org.apache.commons.lang3.StringUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("OrgChartService")
public class OrgChartSvcImpl extends EgovAbstractServiceImpl implements OrgChartSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	
	/**
	 * 부서 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviList getDeptList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		params.put("isSaaS", (isSaaS) ? "Y" : "N");
		CoviList list = coviMapperOne.list("control.orgchart.selectDeptList", params);
		
		CoviList resultList = new CoviList();
		CoviList deptList = CoviSelectSet.coviSelectJSON(list, "itemType,CompanyCode,GroupCode,GroupType,CompanyName,GroupName,PrimaryMail,MemberOf,AN,DN,EM,ETID,ETNM,SGAN,SGDN,RCV,SortPath,GroupPath,GroupID,hasChild,GroupFullPath");

		for(Object dept : deptList){
			CoviMap deptObj = new CoviMap();
							
			deptObj = (CoviMap) dept;
			
			// 트리를 그리기 위한 데이터
			//dbOrgDeptData.put("type", "0") 폴더 아이콘 사용 안함;
			deptObj.put("no", deptObj.getString("AN"));
			deptObj.put("nodeName", DicHelper.getDicInfo(deptObj.getString("GroupName"),lang));
			deptObj.put("nodeValue", deptObj.get("GroupCode"));
			deptObj.put("groupID", deptObj.get("GroupID"));
			deptObj.put("isLoad", "Y");
			deptObj.put("pno", deptObj.getString("SGAN"));
			deptObj.put("chk", "Y");
			deptObj.put("rdo", "N");
			//deptObj.put("url", "javascript:coviOrg.getUserOfGroupList(\"" + deptObj.get("GroupCode") + "\");");
		
			resultList.add(deptObj);
		}
		
		
		return resultList;
	}
	
	/**
	 * 그룹 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviList getGroupList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		CoviList list = coviMapperOne.list("control.orgchart.selectGroupList", params);
		
		CoviList resultList = new CoviList();
		CoviList groupList = CoviSelectSet.coviSelectJSON(list, "itemType,CompanyCode,GroupCode,GroupType,CompanyName,GroupName,PrimaryMail,MemberOf,AN,DN,EM,ETID,ETNM,SGAN,SGDN,RCV,SortPath,GroupPath,GroupID,hasChild,GroupFullPath");
		
		
		for(Object group : groupList){
			CoviMap groupObj = new CoviMap();
			
			groupObj = (CoviMap) group;
			
			// 트리를 그리기 위한 데이터
			groupObj.put("no",  groupObj.getString("AN"));
			groupObj.put("nodeName", DicHelper.getDicInfo(groupObj.getString("GroupName"),lang));
			groupObj.put("nodeValue", groupObj.get("GroupCode"));
			groupObj.put("groupID", groupObj.get("GroupID"));
			groupObj.put("pno", groupObj.getString("SGAN"));
			
			if(groupObj.getString("GroupType").equalsIgnoreCase("COMPANY") || groupObj.getString("GroupType").equalsIgnoreCase("DIVISION") ){
				groupObj.put("chk", "N");
			}else{
				groupObj.put("chk", "Y");
			}
			
			groupObj.put("rdo", "N");
			
			/*if(groupObj.getString("GroupType").equalsIgnoreCase("COMPANY") ){ //회사는 클릭 X
				groupObj.put("url", "javascript:void(0);");
			}else{
				groupObj.put("url", "javascript:coviOrg.getUserOfGroupList(\"" + groupObj.get("GroupCode") + "\");");
			}*/
			
			resultList.add(groupObj);
		}
		
		
		return resultList;
	}

	/**
	 * 부서 사용자 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getUserList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("control.orgchart.selectUserList", params);

		CoviMap resultList = new CoviMap();
		CoviList userList = CoviSelectSet.coviSelectJSON(list, "itemType,so,UserID,AN,DN,LV,TL,PO,MT,Mobile,FAX,EM,OT,USEC,RG,SG,RGNM,SGNM,ETID,ETNM,JobType,UserCode,ExDisplayName,ExGroupName,PhoneNumberInter,ChargeBusiness,PhotoPath,AbsenseUseYN,AbsenseType,AbsenseDuty,AbsenseReason,AbsenseTermStart,AbsenseTermEnd,AttendStatus,VacStatus,JobStatus,DomainID");
		
		for(Object user : userList){
			((CoviMap)user).put("po",((CoviMap)user).getString("PO").replace("|", ";"));
			((CoviMap)user).put("lv",((CoviMap)user).getString("LV").replace("|", ";"));
			((CoviMap)user).put("tl",((CoviMap)user).getString("TL").replace("|", ";"));
		}
		
		resultList.put("list",userList);
		
		return resultList;
	}
	
	/**
	 * 그룹 사용자 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getGroupUserList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("control.orgchart.selectGroupUserList", params);
		
		CoviMap resultList = new CoviMap();
		CoviList userList = CoviSelectSet.coviSelectJSON(list, "itemType,so,UserID,AN,DN,LV,TL,PO,MT,Mobile,FAX,EM,OT,USEC,RG,SG,RGNM,SGNM,ETID,ETNM,JobType,UserCode,ExDisplayName,ExGroupName,PhoneNumberInter,ChargeBusiness,PhotoPath,AbsenseUseYN,AbsenseType,AbsenseReason,AttendStatus,VacStatus,JobStatus");
		
		for(Object user : userList){
			((CoviMap)user).put("po",((CoviMap)user).getString("PO").replace("|", ";"));
			((CoviMap)user).put("lv",((CoviMap)user).getString("LV").replace("|", ";"));
			((CoviMap)user).put("tl",((CoviMap)user).getString("TL").replace("|", ";"));
		}
		
		resultList.put("list",userList);
		
		return resultList;
	}

	/**
	 * 도메인 바인딩
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getCompanyList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		CoviList list = coviMapperOne.list("control.orgchart.selectCompanyList", params);

		CoviMap resultList = new CoviMap();
		CoviList companyList =  CoviSelectSet.coviSelectJSON(list, "GroupID,GroupCode,MultiDisplayName");
		
		for(Object company : companyList){
			((CoviMap)company).put("DisplayName",DicHelper.getDicInfo( ((CoviMap)company).getString("MultiDisplayName"), lang) );
		}
		
		resultList.put("list", companyList);
		
		return resultList;
	}

	@Override
	public CoviList getAllUserAutoTagList(CoviMap params) throws Exception {
		String columnName = "";
		if(params.getString("haveDept").equals("Y")){
			columnName = "UserCode,UserName,DeptName,MailAddress,Mobile,DomainID";
		}else{
			columnName = "UserCode,UserName,MailAddress,Mobile,DomainID";
		}
		
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		if(isSaaS) 	params.put("CompanyCode",  SessionHelper.getSession("DN_Code"));
		CoviList list = coviMapperOne.list("control.orgchart.selectUserAutoTagList", params);
		
		return CoviSelectSet.coviSelectJSON(list, columnName);
	}
	
	@Override
	public CoviList getAllUserGroupAutoTagList(CoviMap params) throws Exception {
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code"));
		CoviList list = coviMapperOne.list("control.orgchart.selectUserGroupAutoTagList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "Code,Name,Type,DeptName,JobLevelName,PhotoPath");
	}

	@Override
	public CoviList getInitOrgTreeList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		List<String> loadList = new ArrayList<String>();
		
		loadList.add(params.getString("companyCode"));
		if(params.getString("groupType").equalsIgnoreCase("DEPT") && !params.getString("defaultValue").equals("")){
			params.put("arrGroupPath", new String[]{params.getString("defaultValue")});
			CoviList list = coviMapperOne.list("control.orgchart.getOrgPathInfo", params);
			String defaultValueGroupPath = list.getJSONObject(0).getString("GroupPath");
			
			params.put("defaultValueGroupPath", ";"+defaultValueGroupPath.substring(0,defaultValueGroupPath.indexOf(params.getString("defaultValue")+";")));
			loadList.addAll(Arrays.asList(defaultValueGroupPath.split(";")));
			loadList.remove(params.getString("defaultValue"));
		}
		
		if(params.getString("groupType").equalsIgnoreCase("DEPT") && params.getString("loadMyDept").equals("Y")){
			String userGroupPath = SessionHelper.getSession("GR_GroupPath");
			
			params.put("userGroupPath", ";"+userGroupPath.substring(0,userGroupPath.indexOf(SessionHelper.getSession("GR_Code")+";")));
			loadList.addAll(Arrays.asList(userGroupPath.split(";")));
			loadList.remove(SessionHelper.getSession("GR_Code"));
		}
		
		params.put("lang", lang);
		if(params.getString("onlyMyDept").equals("Y")) {
			params.put("onlyMyDept", params.getString("onlyMyDept"));
			params.put("myGroupPath", SessionHelper.getSession("GR_GroupPath"));
		}	
		
		CoviList list = coviMapperOne.list("control.orgchart.selectInitOrgTreeList", params);
		
		CoviList resultList = new CoviList();
		String checkGroupCode = ";";
		
	    for(Object jsonObject : list){
			CoviMap groupData = (CoviMap) jsonObject;
			if(groupData.getString("MemberOf") == null || groupData.getString("MemberOf").equals("") || groupData.getString("MemberOf").equalsIgnoreCase("orgroot") || checkGroupCode.indexOf(";" + groupData.getString("MemberOf") + ";") > -1) {
				checkGroupCode += groupData.getString("GroupCode") + ";";
				resultList.add(groupData);
			}
		}
		
		CoviList result = new CoviList();
		CoviList deptList = CoviSelectSet.coviSelectJSON(resultList, "itemType,CompanyCode,GroupCode,GroupType,CompanyName,GroupName,PrimaryMail,MemberOf,AN,DN,EM,ETID,ETNM,SGAN,SGDN,RCV,SortPath,GroupPath,GroupID,hasChild,GroupFullPath,Approvable,Receivable,IsMail");

		for(Object dept : deptList){
			CoviMap deptObj = new CoviMap();
							
			deptObj = (CoviMap) dept;
			
			// 트리를 그리기 위한 데이터
			deptObj.put("no", deptObj.getString("AN"));
			deptObj.put("nodeName", DicHelper.getDicInfo(deptObj.getString("GroupName"),lang));
			deptObj.put("nodeValue", deptObj.get("GroupCode"));
			deptObj.put("groupID", deptObj.get("GroupID"));
			deptObj.put("pno", deptObj.getString("SGAN"));
			deptObj.put("isLoad", loadList.contains(deptObj.getString("AN"))? "Y": "N");
			deptObj.put("haveChild", deptObj.getInt("hasChild") > 0 ? "Y" : "N");
			deptObj.put("chk", "Y");
			deptObj.put("rdo", "N");
		
			result.add(deptObj);
		}
		
		
		return result;
	}

	@Override
	public CoviList getChildrenData(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		CoviList list = coviMapperOne.list("control.orgchart.selectChildrenData", params);
		
		CoviList resultList = new CoviList();
		CoviList deptList = CoviSelectSet.coviSelectJSON(list, "itemType,CompanyCode,GroupCode,GroupType,CompanyName,GroupName,PrimaryMail,MemberOf,AN,DN,EM,ETID,ETNM,SGAN,SGDN,RCV,SortPath,GroupPath,GroupID,hasChild,GroupFullPath,Approvable,Receivable,IsMail");

		for(Object dept : deptList){
			CoviMap deptObj = new CoviMap();
							
			deptObj = (CoviMap) dept;
			
			// 트리를 그리기 위한 데이터
			deptObj.put("no", deptObj.getString("AN"));
			deptObj.put("nodeName", DicHelper.getDicInfo(deptObj.getString("GroupName"),lang));
			deptObj.put("nodeValue", deptObj.get("GroupCode"));
			deptObj.put("groupID", deptObj.get("GroupID"));
			deptObj.put("pno", deptObj.getString("SGAN"));
			deptObj.put("isLoad", "N" );
			deptObj.put("haveChild", deptObj.getInt("hasChild") > 0 ? "Y" : "N");
			deptObj.put("chk", "Y");
			deptObj.put("rdo", "N");
		
			resultList.add(deptObj);
		}
		
		
		return resultList;
	}
	
	/**
	 * getOrgPathInfo
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getOrgPathInfo(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		CoviList list = coviMapperOne.list("control.orgchart.getOrgPathInfo", params);

		CoviMap resultList = new CoviMap();
		CoviList pathlist =  CoviSelectSet.coviSelectJSON(list, "CompanyCode,GroupCode,GroupPath,MultiDisplayName");
		
		for(Object path : pathlist){
			((CoviMap)path).put("DisplayName",DicHelper.getDicInfo( ((CoviMap)path).getString("MultiDisplayName"), lang) );
		}
		
		resultList.put("list", pathlist);
		
		return resultList;
	}
	
	@Override
	public CoviList getGovOrgTreeList(CoviMap params) throws Exception {
		CoviList list = new CoviList();
		String TOuCode = "";
		
		if(params.has("searchText") && StringUtils.isNotEmpty(params.getString("searchText"))) {
			list = coviMapperOne.list("control.orgchart.selectSearchGovOrgTreeList", params);
		}else {
			list = coviMapperOne.list("control.orgchart.selectGovOrgTreeList", params);
		}
		
		CoviList resultList = new CoviList();
		CoviList deptList = CoviSelectSet.coviSelectJSON(list, "OUCODE,OUORDER,UCORGFULLNAME,OU,TOPOUCODE,DN,REPOUCODE,PARENTOUCODE,PARENTOUNAME,OULEVEL,ISUSE,USEYN,UCCHIEFTITLE,DISPLAY_UCCHIEFTITLE,HASSUBOU,AN,OUSTEP");

		for(Object dept : deptList){
			CoviMap deptObj = new CoviMap();
							
			deptObj = (CoviMap) dept;
			
			TOuCode = deptObj.getString("TOPOUCODE");
			
			CoviMap paramsObj = new CoviMap();
			paramsObj.put("POuCode", TOuCode);
			String POuName = coviMapperOne.selectOne("control.orgchart.selectParentGovOrgTree", paramsObj);
			
			
			// 트리를 그리기 위한 데이터
			deptObj.put("no", deptObj.getString("OUCODE"));
			deptObj.put("nodeName", deptObj.getString("OU"));
			deptObj.put("nodeValue", deptObj.get("OUCODE"));
			deptObj.put("groupID", deptObj.get("OUCODE"));
			deptObj.put("pno", deptObj.getString("PARENTOUCODE"));
			deptObj.put("pon", POuName == null? "" : POuName);
			deptObj.put("isLoad", "N");
			deptObj.put("haveChild", (deptObj.getInt("HASSUBOU") > 0 ? "Y": "N"));
			deptObj.put("chk", deptObj.getString("USEYN"));
			deptObj.put("rdo", "N");
			deptObj.put("ouStep", deptObj.getString("OUSTEP"));
		
			resultList.add(deptObj);
		}
		
		return resultList;
	}
	
	@Override
	public CoviList getGov24OrgTreeList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("control.orgchart.selectGov24OrgTreeList", params);
		
		CoviList resultList = new CoviList();
		CoviList deptList = CoviSelectSet.coviSelectJSON(list, "ORGCD,CMPNYNM,SENDERNM,BIZNO,ADRES,DELETEFLAG,HASSUBOU,PARENTOUCODE,AN,DN,OUSTEP,DISPLAY_UCCHIEFTITLE");

		for(Object dept : deptList){
			CoviMap deptObj = new CoviMap();
							
			deptObj = (CoviMap) dept;	
			
			// 트리를 그리기 위한 데이터
			deptObj.put("no", deptObj.getString("ORGCD"));
			deptObj.put("nodeName", deptObj.getString("CMPNYNM"));
			deptObj.put("nodeValue", deptObj.get("ORGCD"));
			deptObj.put("groupID", deptObj.get("ORGCD"));
			deptObj.put("pno", deptObj.getString("PARENTOUCODE"));
			deptObj.put("isLoad", "N");
			deptObj.put("haveChild", (deptObj.getInt("HASSUBOU") > 0 ? "Y": "N"));
			deptObj.put("chk", "N");
			deptObj.put("rdo", "Y");
			deptObj.put("ouStep", deptObj.getString("OUSTEP"));
		
			resultList.add(deptObj);
		}
		
		return resultList;
	}
	
	/**
	 * 조직도에서 선택한 사용자 목록 조회
	 * @param params - CoviMap
	 * @return resultMap - CoviMap
	 * @throws Exception
	 */
	@Override
	public CoviMap getSelectedUserList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("control.orgchart.getSelectedUserList", params);

		CoviMap resultMap = new CoviMap();
		
		CoviList userList = CoviSelectSet.coviSelectJSON(list, "itemType,so,UserID,AN,DN,LV,TL,PO,MT,Mobile,FAX,EM,OT,USEC,RG,SG,RGNM,SGNM,ETID,ETNM,JobType,UserCode,ExDisplayName,ExGroupName,PhoneNumberInter,ChargeBusiness,PhotoPath,AbsenseUseYN,AbsenseType,AbsenseReason,AttendStatus,VacStatus,JobStatus");
		for(Object user : userList){
			((CoviMap)user).put("po",((CoviMap)user).getString("PO").replace("|", ";"));
			((CoviMap)user).put("lv",((CoviMap)user).getString("LV").replace("|", ";"));
			((CoviMap)user).put("tl",((CoviMap)user).getString("TL").replace("|", ";"));
		}
		
		resultMap.put("list",userList);
		resultMap.put("status", Return.SUCCESS);
		
		return resultMap;
	}
	
	/**
	 * 조직도에서 선택한 부서 목록 조회
	 * @param params - CoviMap
	 * @return resultMap - CoviMap
	 * @throws Exception
	 */
	@Override
	public CoviMap getSelectedDeptList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("control.orgchart.getSelectedDeptList", params);

		CoviMap resultMap = new CoviMap();
		
		CoviList deptList = CoviSelectSet.coviSelectJSON(list, "itemType,CompanyCode,GroupCode,GroupType,CompanyName,GroupName,PrimaryMail,MemberOf,AN,DN,EM,ETID,ETNM,SGAN,SGDN,RCV,SortPath,GroupPath,GroupID,hasChild,GroupFullPath");
		resultMap.put("list",deptList);
		resultMap.put("status", Return.SUCCESS);
		
		return resultMap;
	}
}
