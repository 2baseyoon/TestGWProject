package egovframework.core.sso.saml;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;

import egovframework.baseframework.sso.saml.RequestUtil;
import egovframework.baseframework.sso.saml.SamlException;
import egovframework.baseframework.sso.saml.Util;

public class CreateRequestServlet extends HttpServlet {

	private static final long serialVersionUID = 3493465535826290477L;

	private static final String SAML_REQUEST_TEMPLATE = "AuthnRequestTemplate.xml";

	/**
	 * <pre>
	 * 1. 개요 : Create SAMLRequest
	 * 2. 처리내용 :
	 * </pre>
	 * @Method Name : createAuthnRequest
	 * @date : 2017. 7. 28.
	 * @param acsURL
	 * @param providerName
	 * @return
	 * @throws SamlException
	 */ 	

	private String createAuthnRequest(String acsURL, String providerName,
			String uniqueId) throws SamlException {
		String filepath = getServletContext().getRealPath(
				"WEB-INF/classes/security/" + SAML_REQUEST_TEMPLATE);
		String authnRequest = Util.readFileContents(filepath);
		authnRequest = StringUtils.replace(authnRequest, "##PROVIDER_NAME##",
				providerName);
		authnRequest = StringUtils.replace(authnRequest, "##ACS_URL##", acsURL);
		authnRequest = StringUtils.replace(authnRequest, "##USER_ID##",
				"bjlsm2");
		authnRequest = StringUtils.replace(authnRequest, "##AUTHN_ID##", Util
				.createID());
		authnRequest = StringUtils.replace(authnRequest, "##ISSUE_INSTANT##",
				Util.getDateAndTime());
		authnRequest = StringUtils.replace(authnRequest, "##EMP_NO##",
				"20132");
		authnRequest = StringUtils.replace(authnRequest, "##CODE##",
				"bjlsm2");
		return authnRequest;
	}

	/**
	 * <pre>
	 * 1. 개요 : compute URL to forward AuthnRequest to the Identity Provider
	 * </pre>
	 * @Method Name : computeURL
	 * @date : 2017. 7. 28.
	 * @param ssoURL
	 * @param authnRequest
	 * @param RelayState
	 * @return
	 * @throws SamlException
	 */ 	
	private String computeURL(String ssoURL, String authnRequest,
			String RelayState) throws SamlException {
		StringBuffer buf = new StringBuffer();
		try {
			buf.append(ssoURL);

			buf.append("?SAMLRequest=");
			buf.append(RequestUtil.encodeMessage(authnRequest));

			buf.append("&RelayState=");
			buf.append(URLEncoder.encode(RelayState));
			return buf.toString();
		} catch (UnsupportedEncodingException e) {
			throw new SamlException(
					"Error encoding SAML Request into URL: Check encoding scheme - "
							+ e.getMessage());
		} catch (IOException e) {
			throw new SamlException(
					"Error encoding SAML Request into URL: Check encoding scheme - "
							+ e.getMessage());
		}
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}
	

	/**
	 * The doPost method handles HTTP POST requests sent to the
	 * CreateRequestServlet. It reads in SAML parameters from request and
	 * generate SAML AuthnRequest to forward to the Identity Provider.
	 */
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setHeader("Content-Type", "text/html; charset=UTF-8");
		response.setContentType("text/html; charset=UTF-8");

		// for SAML request
		String providerName = request.getParameter("providerName");
		String acsURI = request.getParameter("acsURI");

		// for compute URL
		String ssoURL = request.getParameter("loginForm");
		String RelayState = request.getParameter("RelayState");

		// for forwarding to IP
		String returnPage = request.getParameter("forwardingURI");

		// for verify IP's SAML response
		request.getSession().setAttribute("IPType",
				request.getParameter("IPType"));
		String uniqueId = Util.createID();
		request.getSession().setAttribute("uniqueId", uniqueId);

		String samlRequest;
		String redirectURL;

		try {
			// create SAMLRequest
			samlRequest = createAuthnRequest(acsURI, providerName, uniqueId);
			request.setAttribute("authnRequest", samlRequest);

			// compute URL to forward AuthnRequest to the Identity Provider
			redirectURL = computeURL(ssoURL, samlRequest, RelayState);
			request.setAttribute("redirectURL", redirectURL);

		} catch (SamlException e) {
			request.setAttribute("error", e.getMessage());
		}
		
		// Return generated AuthnRequest for display at Service Provider
		request.getRequestDispatcher(returnPage).include(request, response);
	}

}