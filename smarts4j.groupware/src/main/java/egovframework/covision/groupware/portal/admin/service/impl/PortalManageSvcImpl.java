package egovframework.covision.groupware.portal.admin.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.vo.ObjectAcl;
import egovframework.covision.groupware.portal.admin.service.PortalManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("portalManageService")
public class PortalManageSvcImpl extends EgovAbstractServiceImpl implements PortalManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getPortalList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("admin.portal.selectPortalListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.portal.selectPortalList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "PortalID,PortalType,PortalTypeName,BizSection,BizSectionName,SortKey,DisplayName,IsUse,CompanyCond,RegistDate,LayoutName,RegisterName,aclDisplayName,aclDisplayCount"));
		resultList.put("page",page);
		
		return resultList;
	}

	@Override
	public CoviMap getLayoutList() throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.portal.selectPortalLayoutList",new CoviMap());
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "optionText,optionValue"));
		
		CoviMap item = new CoviMap();
		item.put("optionValue", "");
		item.put("optionText", DicHelper.getDic("lbl_selection") );
		resultList.getJSONArray("list").add(0,item);
		
		return resultList;
	}

	@Override
	public CoviMap getThemeList() throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.portal.selectPortalThemeList",new CoviMap());
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "optionText,optionValue"));
		
		/*JSONObject item = new CoviMap();
		item.put("optionValue", "");
		item.put("optionText", DicHelper.getDic("lbl_selection") );
		resultList.getJSONArray("list").add(0,item);*/
		
		return resultList;
	}

	@Override
	public int insertPortalData(CoviMap params) throws Exception {
		int retCnt = 0;
		retCnt += coviMapperOne.insert("admin.portal.insertPortalData", params);
		
		retCnt += insertACLData(params); //권한 추가
		//retCnt += insertPortalDictionary(params); //다국어 추가
		
		if(params.getString("mode").equals("copy")){
			coviMapperOne.insert("admin.portal.copyPortalLayoutWebpart",params);
		}
		
		return retCnt;
	}
	
	/*
	public String getLayoutHtml(String file, String encoding) throws IOException{
		String[] bits = file.split("/");
		String fileName = bits[bits.length-1];
		String layoutTemplateKey = "portalLayout_"+fileName;
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String isSaveRedisTemplate = PropertiesUtil.getDBProperties().getProperty("db.redis.isSaveRedisPortal");
		
		if(isSaveRedisTemplate.equals("false") || instance.get(layoutTemplateKey) == null){		// 개발시에만 false
			try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), encoding)))
			{
				StringBuilder builder = new StringBuilder();
				String sCurrentLine;
				
				while ((sCurrentLine = br.readLine()) != null) {
					builder.append(sCurrentLine + System.getProperty("line.separator"));
				}
				String text = builder.toString();
				
				return text;
			} catch (IOException e) {
				throw e;
			}
		}else{
			return instance.get(layoutTemplateKey);
		}
	}
	*/
	
	public int insertACLData(CoviMap params) throws Exception {
		int retCnt = 0;
		
		CoviList items = new CoviList();
		CoviMap permission, item;
		ObjectAcl newAcl = new ObjectAcl();
		
		permission = CoviMap.fromObject(params.get("permission"));
		if(permission.has("item")){
			if(permission.get("item") instanceof CoviMap){
				items.add(permission.getJSONObject("item"));
    		}else{
    			items = permission.getJSONArray("item");
    		}
			
			for(int i = 0; i<items.size(); i++){
				item = items.getJSONObject(i);
				if(item.getString("Permission").equals("A")){
					newAcl.setAclList("____EV_");
				}else{
					newAcl.setAclList("____E__");
				}
				newAcl.setObjectID(params.getInt("portalID"));
				newAcl.setObjectType("PT");
				newAcl.setSubjectCode(item.getString("AN"));
				newAcl.setSubjectType(item.getString("ObjectType_A"));
				newAcl.setRegisterCode(params.getString("USERID"));
				
				coviMapperOne.delete("admin.portal.deleteOldAcl",newAcl);
				retCnt+=coviMapperOne.insert("admin.portal.insertNewAcl", newAcl);
			}
		}
		
		return retCnt;
	}

	/*public int insertPortalDictionary(CoviMap params) throws Exception {
		int retCnt = 0;
		CoviMap dicParam = new CoviMap();
		String dicCode = "PT_"+params.getString("portalID");
		String ko="", en="", ja="", zh="";
		
		
		try { ko = params.getString("dicPortalName").split(";")[0]; } catch(Exception e) {ko=""; }
		try { en = params.getString("dicPortalName").split(";")[1]; } catch(Exception e) {en=""; }
		try { ja = params.getString("dicPortalName").split(";")[2]; } catch(Exception e) {ja=""; }
		try { zh = params.getString("dicPortalName").split(";")[3]; } catch(Exception e) {zh=""; }
		
		dicParam.put("dicCode",dicCode);
		dicParam.put("ko", ko);
		dicParam.put("en", en);
		dicParam.put("ja", ja);
		dicParam.put("zh", zh);
		dicParam.put("userCode",params.getString("userCode"));
		
		
		int cnt = (int) coviMapperOne.getNumber("admin.portal.selectDictionaryData", dicParam);
		
		if(cnt>0){
			retCnt = coviMapperOne.update("admin.portal.updatePortalDictionary", dicParam);
		}else{
			retCnt = coviMapperOne.insert("admin.portal.insertPortalDictionary", dicParam);
		}
		
		return retCnt;
	}*/

	@Override
	public CoviMap getPortalData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList acl = new CoviList();
		
		CoviMap baseData = coviMapperOne.select("admin.portal.selectPortalData", params);
		resultList.put("portal",CoviSelectSet.coviSelectJSON(baseData, "PortalID,LayoutID,CompanyCode,DisplayName,MultiDisplayName,PortalType,ThemeCode,SortKey,PortalCode,URL,Description,BizSection").getJSONObject(0));
		
		CoviList aclData = coviMapperOne.list("admin.portal.selectAclData",params);
		CoviList tempAcl  = CoviSelectSet.coviSelectJSON(aclData, "SubjectType,SubjectCode,View,MultiDisplayName,CompanyCode");
		
		for(int i = 0; i <tempAcl.size(); i++){
			CoviMap aclItem = new CoviMap();
			CoviMap temp = tempAcl.getJSONObject(i);
			
			String permission = temp.getString("View").equals("V")?"A":"D";
			if(temp.getString("SubjectType").equals("UR")){
				aclItem.put("itemType", "user");
				aclItem.put("DN", temp.getString("MultiDisplayName"));
				aclItem.put("ExDisplayName", temp.getString("MultiDisplayName"));
			}else{
				aclItem.put("itemType", "group");
				aclItem.put("GroupName", temp.getString("MultiDisplayName"));
				if(temp.getString("SubjectType").equals("CM")){
					aclItem.put("GroupType", "Company");
				}else{
					aclItem.put("GroupType", "Dept");
				}
			}
			aclItem.put("AN", temp.getString("SubjectCode"));
			aclItem.put("ObjectType_A", temp.getString("SubjectType"));
			aclItem.put("DN_Code", temp.getString("CompanyCode"));
			aclItem.put("Permission", permission);
			
			acl.add(aclItem);
		}
		
		resultList.put("item",acl);
		
		return resultList;
	}

	@Override
	public int updatePortalData(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("admin.portal.updatePortalData",params);
		
		retCnt += updateACLData(params); //권한 수정
		//retCnt += insertPortalDictionary(params); //다국어 수정
	
		return retCnt;
	}

	public int updateACLData(CoviMap params) throws Exception {
		int retCnt = 0;
		
		CoviMap delParam = new CoviMap();
		delParam.put("objectID", params.getString("portalID"));
		delParam.put("objectType","PT");
		
		retCnt += coviMapperOne.delete("admin.portal.deleteAllAcl",delParam);
		
		CoviList items = new CoviList();
		CoviMap permission, item;
		ObjectAcl newAcl = new ObjectAcl();
		permission = (CoviMap)params.getJSONObject("permission");
		
		if(permission.has("item")){
			if(permission.get("item") instanceof CoviMap){
				items.add(permission.getJSONObject("item"));
    		}else{
    			items = permission.getJSONArray("item");
    		}
			
			for(int i = 0; i<items.size(); i++){
				item = items.getJSONObject(i);
				if(item.getString("Permission").equals("A")){
					newAcl.setAclList("_____V_");
				}else{
					newAcl.setAclList("_______");
				}
				newAcl.setObjectID(params.getInt("portalID"));
				newAcl.setObjectType("PT");
				newAcl.setSubjectCode(item.getString("AN"));
				newAcl.setSubjectType(item.getString("ObjectType_A"));
				newAcl.setRegisterCode(params.getString("USERID"));
				
				retCnt+=coviMapperOne.insert("admin.portal.insertNewAcl", newAcl);
			}
		}
		
		return retCnt;
	}

	@Override
	public int deletePortalData(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt += deleteACLData(params); //권한 삭제

		retCnt += coviMapperOne.delete("admin.portal.deletePortalData",params);
		
		return retCnt;
	}

	public int deleteACLData(CoviMap params) throws Exception {
		int retCnt = 0;
		
		CoviMap delParam = new CoviMap();
		delParam.put("arrObjectID", params.get("arrPortalID"));
		delParam.put("objectType","PT");
		
		retCnt += coviMapperOne.delete("admin.portal.deleteAllAcl",delParam);
		
		return retCnt;
	}

	@Override
	public int chnagePortalIsUse(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt += coviMapperOne.update("admin.portal.updatePortalIsUse",params);
		
		String isUse = coviMapperOne.selectOne("admin.portal.selectPortalIsUse",params);
		
		if(isUse.equals("N")){
			coviMapperOne.update("admin.portal.updateUserInitPortal",params);
		}
		
		
		return retCnt;
	}

	
}
