/**
 * SynchronizeWebServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package egovframework.covision.coviflow.api.SynchronizeWebService;

public class SynchronizeWebServiceLocator extends org.apache.axis.client.Service implements egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebService {

    public SynchronizeWebServiceLocator() {
    }


    public SynchronizeWebServiceLocator(org.apache.axis.EngineConfiguration config) {
        super(config);
    }

    public SynchronizeWebServiceLocator(java.lang.String wsdlLoc, javax.xml.namespace.QName sName) throws javax.xml.rpc.ServiceException {
        super(wsdlLoc, sName);
    }

    // Use to get a proxy class for SynchronizeWebServiceSoap
    private java.lang.String SynchronizeWebServiceSoap_address = "http://gw.covision.co.kr/WebSite/zAdmin/Organization/control/SynchronizeWebService.asmx";

    public java.lang.String getSynchronizeWebServiceSoapAddress() {
        return SynchronizeWebServiceSoap_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String SynchronizeWebServiceSoapWSDDServiceName = "SynchronizeWebServiceSoap";

    public java.lang.String getSynchronizeWebServiceSoapWSDDServiceName() {
        return SynchronizeWebServiceSoapWSDDServiceName;
    }

    public void setSynchronizeWebServiceSoapWSDDServiceName(java.lang.String name) {
        SynchronizeWebServiceSoapWSDDServiceName = name;
    }

    public egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoap getSynchronizeWebServiceSoap() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(SynchronizeWebServiceSoap_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getSynchronizeWebServiceSoap(endpoint);
    }

    public egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoap getSynchronizeWebServiceSoap(java.net.URL portAddress) throws javax.xml.rpc.ServiceException {
        try {
            egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoapStub _stub = new egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoapStub(portAddress, this);
            _stub.setPortName(getSynchronizeWebServiceSoapWSDDServiceName());
            return _stub;
        }
        catch (org.apache.axis.AxisFault e) {
            return null;
        }
    }

    public void setSynchronizeWebServiceSoapEndpointAddress(java.lang.String address) {
        SynchronizeWebServiceSoap_address = address;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoap.class.isAssignableFrom(serviceEndpointInterface)) {
                egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoapStub _stub = new egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoapStub(new java.net.URL(SynchronizeWebServiceSoap_address), this);
                _stub.setPortName(getSynchronizeWebServiceSoapWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        java.lang.String inputPortName = portName.getLocalPart();
        if ("SynchronizeWebServiceSoap".equals(inputPortName)) {
            return getSynchronizeWebServiceSoap();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://tempuri.org/", "SynchronizeWebService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("http://tempuri.org/", "SynchronizeWebServiceSoap"));
        }
        return ports.iterator();
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(java.lang.String portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        
if ("SynchronizeWebServiceSoap".equals(portName)) {
            setSynchronizeWebServiceSoapEndpointAddress(address);
        }
        else 
{ // Unknown Port Name
            throw new javax.xml.rpc.ServiceException(" Cannot set Endpoint Address for Unknown Port" + portName);
        }
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(javax.xml.namespace.QName portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        setEndpointAddress(portName.getLocalPart(), address);
    }

}
