package egovframework.covision.groupware.schedule.user.web;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.google.api.client.auth.oauth2.Credential;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.groupware.schedule.user.service.GoogleCalendarSvc;


@Controller
public class GoogleCalendarCon {
	@Autowired
	private GoogleCalendarSvc googleCalendarSvc;
	
    //private static final JsonFactory JSON_FACTORY =JacksonFactory.getDefaultInstance();
    //private static HttpTransport HTTP_TRANSPORT;
    //private static final java.util.List<String> SCOPES =Arrays.asList(CalendarScopes.CALENDAR);
    
    static com.google.api.services.calendar.Calendar service = null;
    static Credential credential = null;
    final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
    
    @RequestMapping(value = "schedule/googleView.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView googleView() throws Exception{
		//System.out.println("page view");
		String returnURL = "user/schedule/google_view";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
    @RequestMapping(value = "schedule/googleOauth.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap googleOauth() throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			googleCalendarSvc.googleOauth();
			
			returnList.put("status", Return.SUCCESS);
				
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			}
		return returnList;
	}
    @RequestMapping(value = "/Callback.do", method = RequestMethod.GET)
    public @ResponseBody ModelAndView callback(HttpServletRequest request){ 
    	String returnURL = "core/devhelper/googleOauthFinish";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
    }
	@RequestMapping(value = "schedule/googleAdd.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap googleAdd(HttpServletRequest request, 
			@RequestParam(value = "summary", required = true, defaultValue = "") String summary,
			@RequestParam(value = "location", required = true, defaultValue = "") String location,
			@RequestParam(value = "description", required = true, defaultValue = "") String description,
			@RequestParam(value = "startTime", required = true, defaultValue = "") String startTime,
			@RequestParam(value = "startTimeZone", required = true, defaultValue = "") String startTimeZone,
			@RequestParam(value = "endTime", required = true, defaultValue = "") String endTime,
			@RequestParam(value = "endTimeZone", required = true, defaultValue = "") String endTimeZone,
			@RequestParam(value = "method", required = true, defaultValue = "") String method,
			@RequestParam(value = "rrule", required = true, defaultValue = "") String rrule,
			@RequestParam(value = "attendee", required = true, defaultValue = "") String attendee,
			@RequestParam(value = "minute", required = true, defaultValue = "") String minute) throws Exception{
		
		CoviMap jObject = new CoviMap();
		jObject.put("summary", summary);
		jObject.put("location", location);
		jObject.put("description", description);
		jObject.put("startTime", startTime);
		jObject.put("startTimeZone", startTimeZone);
		jObject.put("endTime", endTime);
		jObject.put("endTimeZone", endTimeZone);
		jObject.put("method", method);
		jObject.put("rrule", rrule);
		jObject.put("attendee", attendee);
		jObject.put("minute", minute);
		
		CoviMap returnList = new CoviMap();
		try{
			googleCalendarSvc.googleAdd(jObject);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	@RequestMapping(value = "schedule/googleListAll.do", method=RequestMethod.POST)
	public @ResponseBody CoviList googleListAll() throws Exception{
		CoviList returnList = new CoviList();
		
		returnList = googleCalendarSvc.googleListAll();
		
		return returnList;
		
	}@RequestMapping(value = "schedule/googleListSingle.do", method=RequestMethod.POST)
	public @ResponseBody ModelAndView googleListSingle() throws Exception{
		return null;
		
	}
	@RequestMapping(value = "schedule/googleDelete.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap googleDelete
	(HttpServletRequest request, @RequestParam(value = "eventId", required = true, defaultValue = "") String eventId) throws Exception{
		CoviMap eventObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		eventObj.put("eventId", eventId);
		try{
			googleCalendarSvc.googleDelete(eventObj);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	@RequestMapping(value = "schedule/googleUpdate.do", method=RequestMethod.POST)
	public @ResponseBody void googleUpdate(HttpServletRequest request, 
			@RequestParam(value = "summary", required = true, defaultValue = "") String summary,
			@RequestParam(value = "location", required = true, defaultValue = "") String location,
			@RequestParam(value = "description", required = true, defaultValue = "") String description,
			@RequestParam(value = "startTime", required = true, defaultValue = "") String startTime,
			@RequestParam(value = "startTimeZone", required = true, defaultValue = "") String startTimeZone,
			@RequestParam(value = "endTime", required = true, defaultValue = "") String endTime,
			@RequestParam(value = "endTimeZone", required = true, defaultValue = "") String endTimeZone,
			@RequestParam(value = "method", required = true, defaultValue = "") String method,
			@RequestParam(value = "rrule", required = true, defaultValue = "") String rrule,
			@RequestParam(value = "attendee", required = true, defaultValue = "") String attendee,
			@RequestParam(value = "minute", required = true, defaultValue = "") String minute,
			@RequestParam(value = "eventId", required = true, defaultValue = "") String eventId) throws Exception{
		
		CoviMap jObject = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		jObject.put("summary", summary);
		jObject.put("location", location);
		jObject.put("description", description);
		jObject.put("startTime", startTime);
		jObject.put("startTimeZone", startTimeZone);
		jObject.put("endTime", endTime);
		jObject.put("endTimeZone", endTimeZone);
		jObject.put("method", method);
		jObject.put("rrule", rrule);
		jObject.put("attendee", attendee);
		jObject.put("minute", minute);
		jObject.put("eventId", eventId);
		try{
			googleCalendarSvc.googleUpdate(jObject);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
	}
	
	
}
