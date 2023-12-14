package egovframework.covision.groupware.community.admin.web;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.community.admin.service.CommunitySvc;

@Controller
public class CommunityAPICon {
	
	private Logger LOGGER = LogManager.getLogger(CommunityAPICon.class);
	
	@Autowired
	CommunitySvc communitySvc;
	
	
	// 사용자 커뮤니티 - 사용자 포인트 산정
	@RequestMapping(value = "layout/community/api/communityMemberActivity.do" )
	public void communityMemberActivity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		List list = new ArrayList();
		
		String beforeID = "";
		int grade = 1;
		
		list = communitySvc.communityMemberActivity(params);
		
		if(list.size() > 0 ){
		
			for(int i=0; i < list.size(); i++)
			{
				params = (CoviMap) list.get(i);
				
				if(!beforeID.equals(params.get("CU_ID").toString())){
					beforeID = params.get("CU_ID").toString();
					grade = 1;
					params.put("num", grade);
				}else{
					grade++;
					params.put("num", grade);
				}
				
				if(communitySvc.communityMemberActivityPoint(params)){
					//성공 실패 없음
				}
				
				if(communitySvc.communityMemberActivityPointHistory(params)){
					//성공 실패 없음
				}
				
			}
		
		}
		
	}

	// 사용자 커뮤니티 - 커뮤니티 포인트 산정
	@RequestMapping(value = "layout/community/api/communityActivity.do" )
	public void communityActivity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		List list = new ArrayList();
		
		list = communitySvc.communityActivity(params);
		
		String beforePoint = "";
		int grade = 0;
		int beforeDomain = 0;
		
		if(list.size() > 0){
		
			for(int i = 0; i < list.size(); i++)
			{
				params = (CoviMap) list.get(i);
				
				if(beforeDomain != params.getInt("DN_ID")){
					beforeDomain = params.getInt("DN_ID");
					grade = 1;
					params.put("num", grade);
				}else if(beforePoint.equals(params.get("TotalPoint").toString())){
					params.put("num", grade);
				}else{
					grade++;
					beforePoint = params.get("TotalPoint").toString();
					params.put("num", grade);
				}
				
				if(communitySvc.communityActivityPoint(params)){
					//성공 실패 없음
				}
				
				if(communitySvc.communityActivityPointHistory(params)){
					//성공 실패 없음
				}	
				
			}
		
		}
		
	}
	
	/*//covisso 확인용.
	@RequestMapping(value = "layout/community/api/test2.do" )
	public void test2(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviSSO covisso = new CoviSSO();
		Log.info("V : "+covisso.Validation(request)); 
		Log.info("I : "+covisso.getID(request)); 
		Log.info("E : "+covisso.getEN(request)); 
		Log.info("D :"+covisso.getDN(request)); 
	}*/
	
}


