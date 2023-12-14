package egovframework.core.properties.web;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.core.properties.dto.StandardSettingListRequest;
import egovframework.core.properties.dto.StandardSettingSaveRequest;
import egovframework.core.properties.service.StandardSettingSvc;

@Controller
public class StandardSettingCon {
	
	@Autowired
	private StandardSettingSvc standardSettingSvc;
	
	@GetMapping(value = "/standardSetting.do")
	public ModelAndView standardSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView("core/propertiesManage/standardSetting");
		
		CoviMap params = new CoviMap();
		// DB Type 
		params.put("codeGroup", "property_dbtype");
		mav.addObject("dbList", standardSettingSvc.selectCodeList(params));
		
		// Was Type
		params.put("codeGroup", "property_wasType");
		mav.addObject("wasList", standardSettingSvc.selectCodeList(params));		
		
		// Standard Type
		params.put("codeGroup", "property_standardtype");
		mav.addObject("standardList", standardSettingSvc.selectStandardCodeList(params));
		
		// Context Type
		params.put("codeGroup", "property_standardtype");
		mav.addObject("contextList", standardSettingSvc.selectContextCodeList(params));		
		
		// Infra Type
		params.put("codeGroup", "property_standardtype");
		mav.addObject("infraList", standardSettingSvc.selectInfraCodeList(params));		
		
		return mav;
	}
	
	@GetMapping(value = "/standardSettingPopup.do")
	public ModelAndView standardSettingPopup(@RequestParam(defaultValue = "") String id) throws Exception {
		ModelAndView mav = new ModelAndView("core/propertiesManage/standardSettingPopup");
		
		CoviMap params = new CoviMap();
		// DB Type 
		params.put("codeGroup", "property_dbtype");
		mav.addObject("dbList", standardSettingSvc.selectCodeList(params));
		
		// Was Type
		params.put("codeGroup", "property_wasType");
		mav.addObject("wasList", standardSettingSvc.selectCodeList(params));		
		
		// Properties Type
		params.put("codeGroup", "property_standardtype");
		mav.addObject("propertiesList", standardSettingSvc.selectCodeList(params));
		
		params.put("id", id);
		mav.addObject("standardSetting", standardSettingSvc.findById(params));
		
		return mav;
	}
	
	@PostMapping("/standardSetting/list.do")
	public @ResponseBody CoviMap list(@ModelAttribute StandardSettingListRequest standardSettingListRequest) throws Exception {
		return standardSettingSvc.list(standardSettingListRequest);
	}
	
	@PostMapping("/standardSetting/save.do")
	public @ResponseBody CoviMap list(@RequestBody StandardSettingSaveRequest standardSettingSaveRequest) throws Exception {
		return standardSettingSvc.save(standardSettingSaveRequest);
	}
	
	@DeleteMapping("/standardSetting/delete.do")
	public @ResponseBody CoviMap delete(@RequestBody List<Integer> ids) throws Exception {
		CoviMap params = new CoviMap();
		
		try {
			standardSettingSvc.delete(ids);
			
			params.put("status", "success");
		} catch (RuntimeException e) {
			params.put("status", "fail");
		}
		
		return params;
	}
}
