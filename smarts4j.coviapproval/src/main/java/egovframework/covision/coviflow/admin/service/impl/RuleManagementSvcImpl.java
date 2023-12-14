package egovframework.covision.coviflow.admin.service.impl;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Iterator;

import javax.annotation.Resource;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.RuleManagementSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("ruleManagementSvc")
public class RuleManagementSvcImpl extends EgovAbstractServiceImpl implements RuleManagementSvc {
	private static final Logger LOGGER = LogManager.getLogger(RuleManagementSvcImpl.class);
			
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getMasterManagementList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.ruleManagement.selectMasterManagementCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.ruleManagement.selectMasterManagementList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "RuleID,EntCode,RuleName,RuleType,MappingNames,MappingCode,DN_ID"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public int insertMasterManagement(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.ruleManagement.insertMasterManagement", params);
	}
		
	@Override
	public int updateMasterManagement(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.ruleManagement.updateMasterManagement", params);
	}
	
	@Override
	public int deleteMasterManagement(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("admin.ruleManagement.deleteMasterManagement", params);
		if (cnt > 0) {
			coviMapperOne.delete("admin.ruleManagement.deleteMapping", params);
		}		
		return cnt;
	}
	
	@Override
	public CoviMap getMappingList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectMappingList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MappingID,MappingCode,MappingName"));
		return resultList;
	} 
	
	@Override
	public int insertMapping(CoviMap params) throws Exception {
		String[] paramArr = (String[]) params.get("paramArr");
		int cnt = 0;
		for (String str : paramArr) {
			String[] strArr = str.split("\\|");
			params.put("ruleId", strArr[0]);
			params.put("mappingCode", strArr[1]);
			params.put("mappingName", strArr[2]);
			cnt += coviMapperOne.insert("admin.ruleManagement.insertMapping", params); 
		}		
		return cnt;
	}
	
	@Override
	public int deleteMapping(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.ruleManagement.deleteMapping", params);
	}
	
	@Override
	public CoviMap getRankList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectRankList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "JobPositionID,JobPositionCode,JobPositionName"));
		return resultList;
	}
	
	@Override
	public CoviMap getRuleTreeList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectRuleTreeList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "id,no,nodeName,pid,pno,pcode,url,DocKind,ItemDesc,type,MaxAmount,code,SortNum"));
		return resultList;
	}
	
	@Override
	public int insertRuleTree(CoviMap params) throws Exception {
		int cnt = 0;		
		String[] maxAmountArr = params.getString("MaxAmount").split(";");
		for(int i = 0; i < maxAmountArr.length; i++) {
			params.put("MaxAmount", maxAmountArr[i]);
			cnt = coviMapperOne.insert("admin.ruleManagement.insertRuleTree", params);
		}		
		return cnt; 
	}
	
	@Override
	public int updateRuleTree(CoviMap params) throws Exception {
		int cnt = 0;		
		String[] maxAmountArr = params.getString("MaxAmount").split(";");
		for(int i = 0; i < maxAmountArr.length; i++) {
			params.put("MaxAmount", maxAmountArr[i]);
			cnt = coviMapperOne.update("admin.ruleManagement.updateRuleTree", params);
		}		
		return cnt; 
	}
	
	@Override
	public int deleteRuleTree(CoviMap params) throws Exception {
		coviMapperOne.delete("admin.ruleManagement.deleteRuleManagement", params);		
		return coviMapperOne.delete("admin.ruleManagement.deleteRuleTree", params);
	}
	
	@Override
	public CoviMap getRuleGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.ruleManagement.selectRuleGridCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.ruleManagement.selectRuleGridList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ApvID,ItemName,ItemID,ApvName,RuleName,RuleID,ApvType,ApvDesc,Sort"));
		resultList.put("page", pagingData);
		
		return resultList;
	}

	@Override
	public CoviMap selectRuleManagement(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectRuleManagement", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ApvName,ItemID,ItemCode,RuleID,ApvType,Sort,ApvDesc,ApvClass,ApvClassAtt01"));
		return resultList;
	}
	
	@Override
	public int insertRuleManagement(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.ruleManagement.insertRuleManagement", params);
	}
	
	@Override
	public int updateRuleManagement(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.ruleManagement.updateRuleManagement", params);
	}
	
	@Override
	public int deleteRuleManagement(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.ruleManagement.deleteRuleManagement", params);
	}
	
	@Override
	public CoviMap getRuleForSelBox(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectRuleForSelBox", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "RuleID,RuleName,RuleType"));
		return resultList;
	}
	
	@Override
	public CoviMap getRuleForForm(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectRuleForForm", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ItemID,ItemCode,EntCode,ItemName,ItemDesc,MaxAmount,path"));
		return resultList;
	}
	
	@Override
	public CoviMap getApvRuleList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectApvRuleList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ItemID,ItemDesc,MaxAmount,PATH,ApvNames,draftNm,CNT,ItemCode"));
		return resultList;
	}
	
	@Override
	public CoviMap getApvRuleListForForm(CoviMap params) throws Exception {
		CoviList oCoviList = coviMapperOne.list("admin.ruleManagement.selectApvRuleListForForm", params);

		CoviMap joList = new CoviMap();
		joList.put("list", CoviSelectSet.coviSelectJSON(oCoviList, "ApvID,ApvName,ItemID,RuleID,ApvType,Sort,RuleType,ApvClass,ApvClassAtt01,MappingCode"));
		
		CoviList jaList = (CoviList)joList.get("list");
		int nLength = jaList.size();
		
		CoviList targetList = new CoviList();
		for (int i = 0; i < nLength; i++) {
			CoviMap joTemp = jaList.getJSONObject(i);
			
			String sApvID = joTemp.optString("ApvID");
			String sApvName = joTemp.optString("ApvName");
			String sItemID = joTemp.optString("ItemID");
			String sRuleID = joTemp.optString("RuleID");
			String sApvType = joTemp.optString("ApvType");
			String sSort = joTemp.optString("Sort");
			String sRuleType = joTemp.optString("RuleType");
			String sApvClass = joTemp.optString("ApvClass");
			String sApvClassAtt01 = joTemp.optString("ApvClassAtt01");
			String sMappingCode = joTemp.optString("MappingCode");

			CoviList tempList = new CoviList();
			
			CoviMap cmParam = new CoviMap();
			cmParam.put("apvType", sApvType);
			switch(sRuleType) {
				case "0":// 팀장
					cmParam.put("grCode", params.get("grCode"));
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeZero", cmParam);
					break;
				case "1":// 부서장
					cmParam.put("grCode", params.get("grCode"));
					cmParam.put("ruleId", sRuleID);
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeOne", cmParam);
					break;
				case "2":// 직위
					cmParam.put("grCode", params.get("grCode"));
					cmParam.put("ruleId", sRuleID);
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeTwo", cmParam);
					break;
				case "3":// 사람
					cmParam.put("ruleType", sRuleType);
					cmParam.put("mappingCode", sMappingCode);
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeThree", cmParam);
					break;
				case "4":// 부서
					cmParam.put("mappingCode", sMappingCode);
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeFour", cmParam);
					break;
				case "5":// 특정부서팀장
					cmParam.put("mappingCode", sMappingCode);
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeFive", cmParam);
					break;
				case "6":// 담당업무
					cmParam.put("mappingCode", sMappingCode);
					tempList = coviMapperOne.list("admin.ruleManagement.selectRuleTypeSix", cmParam);
					break;
				default:
					if ((sApvClass.equals("DRAFTER")) ||
						(sApvClass.equals("DFIELD"))) {
						CoviMap oCoviMap = new CoviMap();
						oCoviMap.put("ApvType", sApvType);
						oCoviMap.put("ExternalMailAddress", "");
						oCoviMap.put("JobLevelCode", "");
						oCoviMap.put("JobLevelName", "");
						oCoviMap.put("JobPositionCode", "");
						oCoviMap.put("JobPositionName", "");
						oCoviMap.put("JobTitleCode", "");
						oCoviMap.put("JobTitleName", "");
						oCoviMap.put("ObjectCode", "");
						oCoviMap.put("ObjectType", "person");
						oCoviMap.put("UR_Code", "");
						oCoviMap.put("UR_Name", sApvName);
						oCoviMap.put("grCode", "");
						oCoviMap.put("grName", "");
						oCoviMap.put("ApvClass", sApvClass);
						oCoviMap.put("ApvClassAtt01", sApvClassAtt01);
						
						tempList.add(oCoviMap);
					}
					else {
						continue;
					}
					break;
			}
			
			targetList.addAll(tempList);
		}
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(targetList, "ApvType,ObjectCode,ObjectType,grName,grCode,UR_Code,ExternalMailAddress,UR_Name,JobTitleCode,JobTitleName,JobLevelCode,JobLevelName,JobPositionCode,JobPositionName,ApvClass,ApvClassAtt01"));
		return resultList;
	}	
	
	@Override
	public CoviMap getItemMoreInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.ruleManagement.selectItemMoreInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ItemID,ItemName,ItemDesc,ItemType,PATH,AccountCode,AccountName,StandardBriefID,StandardBriefName,GroupCode,GroupName,MaxAmount"));
		return resultList;
	}	
	
	@Override
	public CoviMap getNextItemCode(CoviMap params) throws Exception {
		CoviList list =  new CoviList(); 
		
		if(params.get("depth").equals("1")) {
			list = coviMapperOne.list("admin.ruleManagement.selectNextItemCode", params);
		}
		else if(params.get("depth").equals("2")) {
			list = coviMapperOne.list("admin.ruleManagement.selectNextItemCode2", params);
		}
		else if(params.get("depth").equals("3")) {
			list = coviMapperOne.list("admin.ruleManagement.selectNextItemCode3", params);
		}
		else if(params.get("depth").equals("4")) {
			list = coviMapperOne.list("admin.ruleManagement.selectNextItemCode4", params);
		}
		else if(params.get("depth").equals("5")) {
			list = coviMapperOne.list("admin.ruleManagement.selectNextItemCode5", params);
		}
		
		if(list.isEmpty()) {
			list = null;
		}
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "NextItemCode"));
		return resultList;
	}		
		
	//결재자 타입체크,ysyi
	public boolean chkapvtype(String apvtype) {
		String[] apvtypelist = {"approve","ccinfo","consult","consult-parallel","receive","initiator","assist-parallel","assist"};//결재자타입 유형
		int num=0;		
        for (int i = 0; i < apvtypelist.length; i++) {
        	 if(apvtypelist[i].equals(apvtype)) {
        		 num++;
        	 }
        }        
        return (num>0);
	}
	
	//코드 글자수 맞춤
	public String chkcode(String code) {
		String returncode="";		
		if( code == null || code.length() == 0) {
			returncode = "00";
		} else {
			returncode = code;
		}	
		return returncode;
	}
	
	//결재타입 문자 변경
	public String chkname(String name, String entcode, String insertUser) {
		String returname="";
		String apvname ="";
		String ruetype ="0";//0:팀장
		String apvtype ="";//결재타입 (approve, consult)
		String ruleid="";
		
		int rulecodeCnt =0;//등록된 마스터 코드 
		int verNum =0;// 최신 버전 번호 조회
		CoviMap paramItem = new CoviMap();
		
         if(name.indexOf("(합의")>-1) {
        	returname = name;
        	apvname =  name.replace("(합의)", "");
        	apvtype ="consult";
        }
         else if(name.indexOf("(병렬합의")>-1) {
        	returname = name;
        	apvname =  name.replace("(병렬합의)", "");
        	apvtype ="consult-parallel";
        }         
         else if(name.indexOf("(협조")>-1) {
        	returname = name;
        	apvname =  name.replace("(협조)", "");
        	apvtype ="assist";
        }  
         else if(name.indexOf("(병렬협조")>-1) {
        	returname = name;
        	apvname =  name.replace("(병렬협조)", "");
        	apvtype ="assist-parallel";
        }
         else if(name.indexOf("(수신")>-1) {
        	returname = name;
        	apvname =  name.replace("(수신)", "");
        	apvtype ="receive";
        } 
         else if(name.indexOf("(참조")>-1) {
        	returname = name;
        	apvname =  name.replace("(참조)", "");
        	apvtype ="ccinfo";
        }          
        else {
        	returname = name;
        	apvname = name;
        	apvtype ="approve";
        }    
        
        rulecodeCnt = coviMapperOne.selectOne("admin.ruleManagement.selectRuleIdCnt", apvname);
        verNum =  coviMapperOne.selectOne("admin.ruleManagement.selectRuleVerNum", "");
 
        paramItem.put("entcode", entcode);
        paramItem.put("rulename", apvname);
        paramItem.put("ruletype", ruetype);
        paramItem.put("vernum", verNum);
        paramItem.put("insertuser", insertUser);
        
        
       if(rulecodeCnt==0) {
           coviMapperOne.insert("admin.ruleManagement.insertRulMaster", paramItem);
           
			if(paramItem.getString("RuleID") != null) { 
				ruleid = paramItem.getString("RuleID");
			}
       } else {	
    	   ruleid = Integer.toString(coviMapperOne.selectOne("admin.ruleManagement.selectRuleId", apvname));
       }
        
		return returname+","+apvtype+","+ruleid;
	}
	
	
	// 전결규정 엑셀 업로드,ysyi
	@Override
	public CoviList insertRuleManageData(CoviMap params) throws Exception {
		String entcode =  params.optString("EntCode");
		String insertUser =  params.optString("InsertUser");//등록자
		
		ArrayList<ArrayList<Object>> dataList = extractionExcelData(params, 0);	// 엑셀 데이터 추출
		CoviList resultData = new CoviList();
		CoviMap paramMap = new CoviMap();
		CoviMap paramItem = new CoviMap();
		
		String[][] apvItems = new String[11][4];
		
		coviMapperOne.delete("admin.ruleManagement.deleteRulTemp", paramItem);
		int verNum =  coviMapperOne.selectOne("admin.ruleManagement.selectRuleVerNumUse", "");// 사용 버전 번호 조회
		int verNumTop =  coviMapperOne.selectOne("admin.ruleManagement.selectRuleVerNum", "");// 최신 버전 번호 조회
		coviMapperOne.delete("admin.ruleManagement.deleteRulApvItem", entcode);
		
		for (ArrayList<?> list : dataList) {
			if(!list.isEmpty()){
				String code01 = list.get(0).toString();
				String code02 = list.get(1).toString();
				String code03 = list.get(2).toString();
				String code04 = list.get(3).toString();
				String code05 = list.get(4).toString();
				String name01 = list.get(5).toString();
				String name02 = list.get(6).toString();
				String name03 = list.get(7).toString();		
				String name04 = list.get(8).toString();
				String name05 = list.get(9).toString();
				String charge = list.get(10).toString();
				String approval01 = list.get(11).toString();
				String approval02 = list.get(12).toString();
				String approval03 = list.get(13).toString();
				String approval04 = list.get(14).toString();
				String approval05 = list.get(15).toString();
				String approval06 = list.get(16).toString();
				String approval07 = list.get(17).toString();
				String approval08 = list.get(18).toString();
				String approval09 = list.get(19).toString();
				String approval10 = list.get(20).toString();
				String fullcode =  code01+code02+chkcode(code03)+chkcode(code04)+chkcode(code05);
				String[] strcharge= chkname(charge,entcode,insertUser).split(",");
				String[] strapproval01= chkname(approval01,entcode,insertUser).split(",");
				String[] strapproval02= chkname(approval02,entcode,insertUser).split(",");
				String[] strapproval03= chkname(approval03,entcode,insertUser).split(",");
				String[] strapproval04= chkname(approval04,entcode,insertUser).split(",");
				String[] strapproval05= chkname(approval05,entcode,insertUser).split(",");
				String[] strapproval06= chkname(approval06,entcode,insertUser).split(",");
				String[] strapproval07= chkname(approval07,entcode,insertUser).split(",");
				String[] strapproval08= chkname(approval08,entcode,insertUser).split(",");
				String[] strapproval09= chkname(approval09,entcode,insertUser).split(",");
				String[] strapproval10= chkname(approval10,entcode,insertUser).split(",");
				
				 //########  결재선 정보
				//1번째(기안자)
				 apvItems[0][0] = strcharge[0];//결재자 명칭				
	             apvItems[0][1] = "";//마스터 코드                			
	             apvItems[0][2] = "initiator"; //결재자 타입             
	             apvItems[0][3] = fullcode;  //아이템코드 
				//2번째(결재자)
				 apvItems[1][0] = strapproval01[0]; 				
	             apvItems[1][1] = strapproval01[2];               			
	             apvItems[1][2] = strapproval01[1];              
	             apvItems[1][3] = fullcode;   
					//3번째
				 apvItems[2][0] = strapproval02[0]; 				
	             apvItems[2][1] = strapproval02[2];               			
	             apvItems[2][2] = strapproval02[1];              
	             apvItems[2][3] = fullcode;   	             
					//4번째
				 apvItems[3][0] = strapproval03[0]; 				
	             apvItems[3][1] = strapproval03[2];               			
	             apvItems[3][2] = strapproval03[1];              
	             apvItems[3][3] = fullcode; 
					//5번째
				 apvItems[4][0] = strapproval04[0]; 				
	             apvItems[4][1] = strapproval04[2];               			
	             apvItems[4][2] = strapproval04[1];              
	             apvItems[4][3] = fullcode; 	
					//6번째
				 apvItems[5][0] = strapproval05[0]; 				
	             apvItems[5][1] = strapproval05[2];               			
	             apvItems[5][2] = strapproval05[1];              
	             apvItems[5][3] = fullcode; 
					//7번째
				 apvItems[6][0] = strapproval06[0]; 				
	             apvItems[6][1] = strapproval06[2];               			
	             apvItems[6][2] = strapproval06[1];              
	             apvItems[6][3] = fullcode; 
					//8번째
				 apvItems[7][0] = strapproval07[0]; 				
	             apvItems[7][1] = strapproval07[2];               			
	             apvItems[7][2] = strapproval07[1];              
	             apvItems[7][3] = fullcode; 	             
					//9번째
				 apvItems[8][0] = strapproval08[0]; 				
	             apvItems[8][1] = strapproval08[2];               			
	             apvItems[8][2] = strapproval08[1];              
	             apvItems[8][3] = fullcode; 	   
					//10번째
				 apvItems[9][0] = strapproval09[0]; 				
	             apvItems[9][1] = strapproval09[2];               			
	             apvItems[9][2] = strapproval09[1];              
	             apvItems[9][3] = fullcode; 	
	             
					//11번째
				 apvItems[10][0] = strapproval10[0]; 				
	             apvItems[10][1] = strapproval10[2];               			
	             apvItems[10][2] = strapproval10[1];              
	             apvItems[10][3] = fullcode; 	             
									
				paramMap.put("code01", code01);
				paramMap.put("code02", code02);
				paramMap.put("code03", code03);
				paramMap.put("code04", code04);
				paramMap.put("code05", code05);
				paramMap.put("name01", name01);
				paramMap.put("name02", name02);
				paramMap.put("name03", name03);
				paramMap.put("name04", name04);
				paramMap.put("name05", name05);
				paramMap.put("charge", charge);
				paramMap.put("approval01", approval01);
				paramMap.put("approval02", approval02);
				paramMap.put("approval03", approval03);
				paramMap.put("approval04", approval04);
				paramMap.put("approval05", approval05);
				paramMap.put("approval06", approval06);
				paramMap.put("approval07", approval07);
				paramMap.put("approval08", approval08);
				paramMap.put("approval09", approval09);
				paramMap.put("approval10", approval10);
				paramMap.put("fullcode", fullcode);
				paramMap.put("entcode", entcode);
				paramMap.put("insertuser", insertUser);
				
				coviMapperOne.insert("admin.ruleManagement.insertRulTemp", paramMap);		
				
				//결재선 아이템 insert
				for(int i=0; i<10; i++){
				   if(apvItems[i][0] != null && !apvItems[i][0].equals("")){
				   		paramItem.put("ApvName", apvItems[i][0]);
						paramItem.put("RuleId", apvItems[i][1]);
						paramItem.put("ApvType", apvItems[i][2]);
						paramItem.put("ItemCode", apvItems[i][3]);
						paramItem.put("Sort", i);
						paramItem.put("vernum", verNumTop);
						paramItem.put("insertuser", insertUser);
						
					  
				       coviMapperOne.insert("admin.ruleManagement.insertRulApvItem", paramItem);	
				       coviMapperOne.insert("admin.ruleManagement.insertRulApvItemHistory", paramItem);	
				   }
				}	
				
			}						
		}
		
		paramItem.put("entcode", entcode);
		
		coviMapperOne.delete("admin.ruleManagement.deleteRulItem", verNum-1);
		
		coviMapperOne.insert("admin.ruleManagement.insertRulItem01", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem02", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem03", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem04", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem05", paramItem);
		
		coviMapperOne.insert("admin.ruleManagement.insertRulItem01History", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem02History", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem03History", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem04History", paramItem);	
		coviMapperOne.insert("admin.ruleManagement.insertRulItem05History", paramItem);		
		
		coviMapperOne.update("admin.ruleManagement.updateRuleHistoryDataInit", paramItem);

		coviMapperOne.update("admin.ruleManagement.updateRuleApvItemID", paramItem);
		coviMapperOne.update("admin.ruleManagement.updateRuleItemUpperItemID", paramItem);
		
		paramItem.put("vernumtop", verNumTop);
		coviMapperOne.insert("admin.ruleManagement.insertRulMainHistory", paramItem);

   		return resultData;
	}
	
	// 엑셀 데이터 추출,ysyi
	private ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성

		Workbook wb = null;
		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
		ArrayList<Object> tempList = null;
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			Iterator<Row> rowIterator = sheet.iterator();
			
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				if (row.getRowNum() > (headerCnt)) {	// header 제외
					tempList = new ArrayList<>();
					Iterator<Cell> cellIterator = row.cellIterator();
					while (cellIterator.hasNext()) {
						Cell cell = cellIterator.next();
						
						switch (cell.getCellType()) {
						case Cell.CELL_TYPE_BOOLEAN :
							tempList.add(cell.getBooleanCellValue());
							break;
						case Cell.CELL_TYPE_NUMERIC : 
							tempList.add( (int)cell.getNumericCellValue());//ysyi 수정, 천만 단위 오류 및 코스트센터 소수점 표시 오류 건
							break;
						case Cell.CELL_TYPE_STRING : 
							tempList.add(cell.getStringCellValue());
							break;
						case Cell.CELL_TYPE_FORMULA : 
							tempList.add(cell.getCellFormula());
							break;
						default :
							tempList.add(cell.getStringCellValue());
							break;
						}
					}
					returnList.add(tempList);
				}
			}
		} catch (IOException e) {
				LOGGER.debug(e);
		} catch (NullPointerException npE) {
			LOGGER.debug(npE);
		} catch (Exception e) {
			LOGGER.debug(e);
		} finally {
			if (file != null) {
				try {
					Files.delete(file.toPath());
				}catch (IOException e) {
					LOGGER.debug(e);
				}catch (NullPointerException npE) {
					LOGGER.debug(npE);
				}catch (Exception e) {
					LOGGER.debug("Failed to delete file.[" + file.getAbsolutePath() + "]");
				}
			}
			if(wb != null) {
				wb.close();
			}
		}
		
		return returnList;
	}	
	
	// 임시파일 생성,ysyi
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	try {
	        		Files.delete(tmp.toPath());
				} catch (NullPointerException npE) {
					try {
						LoggerHelper.errorLogger(npE, this.getClass().getCanonicalName(), "RUN");
					}catch(NullPointerException npE2) {
						LOGGER.debug(npE2);
					}catch(Exception e) {
						LOGGER.debug(e);
					}
				}catch (Exception e) {
					try {
						LoggerHelper.errorLogger(e, this.getClass().getCanonicalName(), "RUN");
					}catch(NullPointerException npE) {
						LOGGER.debug(npE);
					}catch(Exception e2) {
						LOGGER.debug(e2);
					}
				}
	        }
	        throw ioE;
	    }
	}
	
	// 전결규정 엑셀 다운로드
	@Override
	public CoviMap geRulManageExcel(CoviMap params) throws Exception{
		CoviList list = null;
		coviMapperOne.delete("admin.ruleManagement.deleteRulTemp", params);
		coviMapperOne.insert("admin.ruleManagement.insertRulExcelTemp", params);	//템프테이블 insert 
		
		list = coviMapperOne.list("admin.ruleManagement.selectRulManageExcel", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "code01,code02,code03,code04,code05,name01,name02,name03,name04,name05,charge,approval01,approval02,approval03,approval04,approval05,approval06,approval07,approval08,approval09,approval10"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getRulHistoryList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int cnt = (int) coviMapperOne.getNumber("admin.ruleManagement.selectRulHistorycnt", params);

		pagingData = ComUtils.setPagingData(params, cnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.ruleManagement.selectRulHistoryList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "VerNum,EntCode,InsertDate,InsertUser,Updatedate,UpdateUser,Description,IsUse"));
		resultList.put("page",pagingData);
		
		return resultList;
	}	
	
	@Override
	public CoviMap getRulHistoryData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.ruleManagement.selectRuleHistoryData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "VerNum,EntCode,InsertDate,InsertUser,Description,IsUse,Updatedate,UpdateUser"));	
		
		return resultList;
	}
	
	@Override
	public int updateRulHistoryData(CoviMap params) throws Exception {
		int cnt =0;
		int choVerNum =Integer.parseInt(params.optString("VerNum"));
		String isUse = params.optString("IsUse");
			
		if(isUse.equals("Y")) {
			cnt += coviMapperOne.update("admin.ruleManagement.updateRuleHistoryDataInit", params);	
			cnt += coviMapperOne.update("admin.ruleManagement.updateRuleHistoryData", params);
			
			int curVerNum =  coviMapperOne.selectOne("admin.ruleManagement.selectRuleVerNumUse", "");// 현재 버전 조회
			
			//cnt = coviMapperOne.delete("admin.ruleManagement.deleteRulItemCur", curVerNum);	//현재 버전 데이터 삭제
			//cnt = coviMapperOne.delete("admin.ruleManagement.deleteRulApvItemCur", curVerNum);	 
			cnt += coviMapperOne.delete("admin.ruleManagement.deleteRulApvItem", curVerNum);	 
			cnt += coviMapperOne.delete("admin.ruleManagement.deleteRulItem", curVerNum);	//등록되어 있는 전결아이템 삭제
			
			cnt += coviMapperOne.insert("admin.ruleManagement.insertRulItemVer", choVerNum); //선택 버전으로 데이터 추가
			cnt += coviMapperOne.insert("admin.ruleManagement.insertRulApvItemVer", choVerNum);	

			cnt += coviMapperOne.update("admin.ruleManagement.updateRuleApvItemID", params);
			cnt += coviMapperOne.update("admin.ruleManagement.updateRuleItemUpperItemID", params);
		}
		else {
			cnt += coviMapperOne.update("admin.ruleManagement.updateRuleHistoryData", params);
		}
		return cnt;
	}

	@Override
	public int getRuleCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("admin.ruleManagement.getRuleCount", params);
	}	
	
}
