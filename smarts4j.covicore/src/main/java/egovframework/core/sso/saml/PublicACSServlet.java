package egovframework.core.sso.saml;

import java.io.IOException;
import java.security.interfaces.RSAPublicKey;
import java.util.Iterator;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.SystemUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom.Content;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.filter.ElementFilter;

import egovframework.baseframework.sso.saml.SAMLVerifier;
import egovframework.baseframework.sso.saml.SamlException;
import egovframework.baseframework.sso.saml.Util;
import egovframework.coviframework.util.StringUtil;

public class PublicACSServlet extends HttpServlet {
	private static final Logger LOGGER = LogManager.getLogger(PublicACSServlet.class);
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String samlResponse = request.getParameter("SAMLResponse");
		String relayState = request.getParameter("RelayState");
		String domainName = request.getParameter("domainName");
		// acs knows public key only.
		try {
			String loginid = null;
			Document doc = Util.createJdomDoc(samlResponse);

			Iterator itr = doc.getDescendants();

			itr = doc.getDescendants(new ElementFilter());
			while (itr.hasNext()) {
				Content c = (Content) itr.next();
				if (c instanceof Element) {
					Element e = (Element) c;

					if ("NameID".equals(e.getName())) {
						loginid = e.getText().trim();
						break;
					}
				}
			}

			String ipType = (String) request.getSession()
					.getAttribute("IPType");

			String publicKeyFilePath = null;

			if (StringUtil.replaceNull(domainName).equals("PAYGATE")) {
				publicKeyFilePath = getServletContext().getRealPath(
						"WEB-INF/cert/" + getPublicKeyPath(ipType)
								+ "pubkey_share.der");
			} else {
				// not allowed domain name!!!
				publicKeyFilePath = getServletContext().getRealPath(
						"WEB-INF/cert/pubkey_share.der");
			}

			RSAPublicKey publicKey;
			publicKey = (RSAPublicKey) Util.getPublicKey(publicKeyFilePath,
					"RSA");

			boolean isVerified = SAMLVerifier
					.verifyXML(samlResponse, publicKey);

			if (isVerified) {

				request.setAttribute("RelayState", relayState);

				request.getSession().setAttribute("ssoUserId", loginid);

				response.setContentType("text/html; charset=UTF-8");
				request.getRequestDispatcher("/t/sso/sp/acs_proc.jsp").include(
						request, response);
			} else {
				return;
			}

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (SamlException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

	}

	
	private String getPublicKeyPath(String ipType) {
		// ipType => Test Identity Provider

		if ("Test Identity Provider".equals(ipType))
			return "";

		return "";
	}
}