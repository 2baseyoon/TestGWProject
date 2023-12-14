package egovframework.covision.coviflow.govdocs.ldap.service.impl;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.govdocs.ldap.service.Gov24ReceiveListSvc;



@Service("gDocReceiveListSvc")
public class Gov24ReceiveListImpl implements Gov24ReceiveListSvc{
	private Logger LOGGER = LogManager.getLogger(Gov24ReceiveListImpl.class);

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	//수신처 url요청
	public void doReciveListData() throws Exception {
		String URL = "http://doc24-service.saas.gcloud.go.kr";
		String operation = "/rest/lnk/cop/cmpnys";  //행정망 기관용(IFDOC005), 인터넷 기관용(/rest/lnk/cop/cmpnys)
		String apiKey = ""; 
		String batchDay = new SimpleDateFormat("yyyyMMdd").format(new Date()); //배치 요청일자(YYYYMMDD)
		String deleteFlag = "N"; // Y : 삭제건포함, N : 제외
		
		CoviMap resultList;
		HttpURLConnection conn = null;
		
		OutputStreamWriter osw = null;
		BufferedWriter bw = null;
		
		try {
			URL strurl = new URL(URL+operation);
			conn = (HttpURLConnection) strurl.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/json");
			conn.setDoOutput(true);
			osw = new OutputStreamWriter(conn.getOutputStream(), StandardCharsets.UTF_8);
			bw = new BufferedWriter(osw);
			
			
			CoviMap setObj = new CoviMap();
			setObj.put("API_KEY", apiKey);
			setObj.put("batchDay", batchDay);
			setObj.put("deleteFlag", deleteFlag);
			
			bw.write(setObj.toString());
			bw.flush(); 
			conn.connect();
			
			int responseCode = conn.getResponseCode();
			
			StringBuilder sb = new StringBuilder();
			if(responseCode == 200) {
				try(
						InputStreamReader isr = new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8);
						BufferedReader br = new BufferedReader(isr);
					) {
					String line;
					while ((line = br.readLine()) != null) {
						sb.append(line);
					}
				}
				
				if(!sb.toString().equals("")) {
					resultList = CoviMap.fromObject(sb.toString());
					getrecevieList(resultList);
				}
			}
		} catch (IOException ioE){
			LOGGER.error("doReciveListData : {}", ioE.getLocalizedMessage());
			throw ioE;
		} catch (NullPointerException npE){
			LOGGER.error("doReciveListData : {}", npE.getLocalizedMessage());
			throw npE;
		} catch (Exception e){
			LOGGER.error("doReciveListData : {}", e.getLocalizedMessage());
			throw e;
		}
		finally{
			if(osw != null) {
				try {
					osw.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if(bw != null) {
				try {
					bw.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if(conn != null){
				try {
					conn.disconnect();
					conn = null;
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			
		}
	}	
	
	//수신처 목록
	private void getrecevieList(CoviMap dataObj) throws Exception {
		CoviList getresultArr = null;
		
		CoviList tempList = new CoviList();
		CoviMap rParam;
		if(dataObj.has("header")) {
			CoviMap getheaderObj = (CoviMap) dataObj.get("header");
			String responseCode = (String) getheaderObj.get("code");
			String responseMsg = (String) getheaderObj.get("message");
		
			if("LNK000000".equals(responseCode)) { //성공
				try {
					getresultArr = (CoviList) dataObj.get("body");	
					for (Object obj : getresultArr) {
	
						CoviMap resultObj = (CoviMap) obj;
					
						rParam = new CoviMap();
						rParam.put("orgCd", resultObj.getString("orgCd"));
						rParam.put("cmpnyNm", resultObj.getString("cmpnyNm"));
						rParam.put("senderNm", resultObj.getString("senderNm"));
						rParam.put("bizrno", resultObj.getString("bizrno"));
						rParam.put("adres", resultObj.getString("adres"));
						rParam.put("deleteFlag", resultObj.getString("deleteFlag"));
						rParam.put("updateDe", resultObj.getString("updateDe"));
						rParam.put("deleteDe", resultObj.getString("deleteDe"));
	
						tempList.add(rParam);
					}			
				} catch (NullPointerException npE) {
					LOGGER.error(npE);
					throw npE;
				} catch (Exception ex) {
					LOGGER.error(ex);
					throw ex;
				}
			}else{
				LOGGER.error("Gov24ReceiveListImpl : {}", responseMsg);
			}
		}
		gov24recevieListUpdate(tempList);
	}
	
	private void gov24recevieListUpdate(CoviList list) throws Exception {
		if(!list.isEmpty()) {
			int interval = 1000;
			coviMapperOne.delete("service.ldap.deleteGov24TempAll", null);
			
			CoviMap map = new CoviMap(); 
			for(int i = 0, tot = list.size(); i < tot; i += interval){
				List subList = list.subList( i , (i+interval) < tot ? (i+interval) :  list.size() );
				map.put("list", subList);
				map.put("size", subList.size()-1);
				coviMapperOne.insert("service.ldap.insertGov24Temp", map);
			}
			coviMapperOne.delete("service.ldap.deleteGov24All", null);
			coviMapperOne.insert("service.ldap.insertGov24Copy", null);
		}
	}
}