package egovframework.covision.groupware.portal.admin.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Resource;




import org.apache.commons.codec.binary.Base64;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.covision.groupware.portal.admin.service.WebpartSettingSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("webpartSettingService")
public class WebpartSettingSvcImpl extends EgovAbstractServiceImpl implements WebpartSettingSvc{
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getLayoutList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.portal.selectSettingLayoutList", params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list,"LayoutID,DisplayName,LayoutTag,LayoutThumbNail,IsDefault,LayoutType,SettingLayoutTag"));
		
		return resultList;
	}

	@Override
	public CoviMap getWebpartList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("admin.portal.selectSettingWebpartList", params);
		CoviList webpartList  = CoviSelectSet.coviSelectJSON(list,"WebpartID,WebpartName,CompanyName,MinHeight,BizSection,Description");
		
		for(int i = 0 ; i < webpartList.size(); i++){
			String webpartID = webpartList.getJSONObject(i).getString("WebpartID");
			String bizSection = webpartList.getJSONObject(i).getString("BizSection");
			String webpartName = webpartList.getJSONObject(i).getString("WebpartName");
			/*webpartList.getJSONObject(i).put("WebpartName", (DicHelper.getDic("WP_"+webpartID)==""? webpartName :DicHelper.getDic("WP_"+webpartID)));*/
			webpartList.getJSONObject(i).put("BizSection", (DicHelper.getDic("BizSection_"+bizSection).equals("") ? bizSection :DicHelper.getDic("BizSection_"+bizSection)));
		}
		
		resultList.put("list", webpartList);
		
		return resultList;
	}

	@Override
	public CoviMap getPortalSettingData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list;
		
		list = coviMapperOne.list("admin.portal.selectPortalLayoutData", params);
		resultList.put("layout", CoviSelectSet.coviSelectJSON(list, "DisplayName,LayoutID,DisplayName,IsDefault,LayoutType"));
		
		list = coviMapperOne.list("admin.portal.selectPortalWebpartData", params);
		resultList.put("webpart", CoviSelectSet.coviSelectJSON(list, "WebpartID,LayoutDivNumber,LayoutDivSort,WebpartOrder"));
		
		list = coviMapperOne.list("admin.portal.selectPortalData", params);
		resultList.put("portal", CoviSelectSet.coviSelectJSON(list, "DisplayName,PortalTag,BizSection,PortalType,LayoutSizeTag"));
		
		return resultList;
	}

	@Override
	public int setPortalData(CoviMap params) throws Exception {
		int cnt = 0;
		String webpartList = params.getString("webpartList");
		String[] webpartListArr = webpartList.split(";");
		
		//기존에 지정되어 있던 웹파트 삭제
		cnt += coviMapperOne.delete("admin.portal.deletePortalWebpartData",params);
		if(!webpartList.equals("")){
			for(int i = 0; i < webpartListArr.length; i++){
				String[] webpartInfo = webpartListArr[i].split("[|]");
				CoviMap webpartParam = new CoviMap();
				
				webpartParam.put("portalID", params.getString("portalID"));
				webpartParam.put("webpartID",webpartInfo[1]);
				webpartParam.put("layoutDivNumber",webpartInfo[0]);
				webpartParam.put("layoutDivSort",webpartInfo[2]);
				webpartParam.put("webpartOrder",webpartInfo[3]);
				
				cnt += coviMapperOne.insert("admin.portal.insertPortalWebpartData",webpartParam);
			}
		}
		
		cnt += coviMapperOne.update("admin.portal.updateSettingPortalData",params);
		
		return cnt;
	}

	@SuppressWarnings("unchecked")
	@Override
	public CoviList getPreviewWebpartList(CoviMap params) throws Exception {
		String[] webparts = params.getString("webparts").split(";");
		CoviList webpartIDs = new CoviList();
		CoviList retSortedWebpartList = new CoviList();
		
		if(!params.getString("webparts").equals("")){
			for(String webpart : webparts){
				String webpartID = webpart.split("[|]")[1];
				webpartIDs.add(webpartID);
			}
		
			CoviMap webpartParam = new CoviMap();
			webpartParam.put("webpartList", webpartIDs);
			
			CoviList list = coviMapperOne.list("admin.portal.selectPreviewWebpart", webpartParam);
			CoviList webpartList = CoviSelectSet.coviSelectJSON(list, "WebpartID,DisplayName,HtmlFilePath,JsFilePath,JsModuleName,Preview,Resource,ScriptMethod,MinHeight,DataJSON,ExtentionJSON");
			
			List<CoviMap> sortList = new ArrayList<>();
			for(int i = 0 ; i < webpartList.size(); i++){
				CoviMap obj = webpartList.getJSONObject(i);
				for(String webpart : webparts){
					if(obj.getString("WebpartID").equals( webpart.split("[|]")[1] )){
						obj.put("LayoutDivNumber", webpart.split("[|]")[0]);
						obj.put("LayoutDivSort", webpart.split("[|]")[2]);
						obj.put("WebpartOrder", webpart.split("[|]")[3]);
						sortList.add(obj);
					}
				}
				
			}
			
			Collections.sort( sortList, new Comparator<CoviMap>() {
			    public int compare(CoviMap a, CoviMap b) {
			        int valA , valB;
	
		            valA = a.getInt("LayoutDivSort");
		            valB = b.getInt("LayoutDivSort");
	
			        return valA > valB ? 1 : (valA < valB ? -1 : 0);
			    }
			});
			
			
			 for (int i = 0; i < sortList.size(); i++) {
			        retSortedWebpartList.add(sortList.get(i));
			 }
		}
		
		return retSortedWebpartList;
	}

	@Override
	public String getLayoutTemplate(CoviList webpartList, CoviMap params) throws Exception {
		Pattern p = null;
		Matcher m = null;
		
		String layoutHTML = "";
		
		layoutHTML = params.getString("layoutTag");
		
		layoutHTML = new String(Base64.decodeBase64(layoutHTML), StandardCharsets.UTF_8); 
		
		StringBuilder builder = new StringBuilder(layoutHTML);

		p = Pattern.compile("\\{\\{\\s*doc.layout.div(\\d+)\\s*\\}\\}");
		m = p.matcher(builder.toString());

		StringBuffer layoutResult = new StringBuffer(builder.length());
		
		while(m.find()){ 
			StringBuilder divHtml = new StringBuilder("");
			for(int i = 0;i<webpartList.size();i++){
				CoviMap webpart = webpartList.getJSONObject(i);
				
				if(webpart.getString("LayoutDivNumber").equals(m.group(1))){
					String webpartID = webpart.getString("WebpartID");
					String preview = new String(Base64.decodeBase64(webpart.getString("Preview")), StandardCharsets.UTF_8);
					int minHeight = webpart.getInt("MinHeight");
					
					
					if(webpart.getString("WebpartOrder").indexOf('-')>-1){ //Server-Rendering
						divHtml.append(String.format("<div id=\"WP%s\" style=\"min-height:%dpx;\">%s</div>",webpartID, minHeight, preview));
					}else{  //Client-Rendering
						divHtml.append(String.format("<div id=\"WP%s\" style=\"min-height:%dpx;\" ><center>%s</center></div>", webpartID, minHeight, preview));
					}
				}
				
			}
			m.appendReplacement(layoutResult,divHtml.toString());
		}
		m.appendTail(layoutResult);
		
		return layoutResult.toString();
	}
}
