package egovframework.covision.groupware.google;

import com.google.gson.Gson;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;

@Controller
public class CalendarAPI {
	
	private Logger LOGGER = LogManager.getLogger(CalendarAPI.class);

    @RequestMapping(value = "calendar/eventlist.do", method = RequestMethod.GET)
    public @ResponseBody CoviMap googleEventList(HttpServletRequest request, @RequestParam(value = "domainID", required = false , defaultValue = "") String domainID) throws Exception {
        CoviMap jsonObject = null;
        
        try {
        	String key = StringUtil.isEmpty(domainID) ? RedisDataUtil.getBaseConfig("GoogleApiKey") : RedisDataUtil.getBaseConfig("GoogleApiKey", domainID);
            String calendarId = "ko.south_korea%23holiday%40group.v.calendar.google.com";
            String url = "https://www.googleapis.com/calendar/v3/calendars/"+calendarId+"/events?key="+key;

            HttpClient client = HttpClientBuilder.create().build(); // HttpClient 생성
            HttpGet getRequest = new HttpGet(url); // GET 메소드 URL 생성
            //getRequest.addHeader("x-api-key", RedisDataUtil.getBaseConfig("GoogleApiKey")); //KEY 입력

            HttpResponse response = client.execute(getRequest);

            //Response 출력
            if (response.getStatusLine().getStatusCode() == 200) {
                ResponseHandler<String> handler = new BasicResponseHandler();
                String body = handler.handleResponse(response);
                Gson gson = new Gson();
                jsonObject = gson.fromJson(body, CoviMap.class);
            } else {
            	LOGGER.error("response is error : {}", response.getStatusLine().getStatusCode());
            }
        } catch (NullPointerException e){
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e){
        	LOGGER.error(e.getLocalizedMessage(), e);
        }
        return  jsonObject;
    }
}
