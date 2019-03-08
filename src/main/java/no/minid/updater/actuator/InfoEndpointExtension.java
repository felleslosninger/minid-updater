package no.minid.updater.actuator;

import org.apache.catalina.util.ServerInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.boot.actuate.endpoint.web.annotation.EndpointWebExtension;
import org.springframework.boot.actuate.info.InfoEndpoint;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
@EndpointWebExtension(endpoint = InfoEndpoint.class)
public class InfoEndpointExtension {

    @Autowired
    private InfoEndpoint delegate;

    @ReadOperation
    public  Map<String, Object> info() {
        Map<String, Object> infoMap = new HashMap<>(this.delegate.info());
        infoMap.put("java", getJavaInfo());
        infoMap.put("tomcat", getTomcatInfo());
        return infoMap;
    }

    private Map<String, String> getJavaInfo() {
        Map<String, String> javaInfoMap = new HashMap<>();
        javaInfoMap.put("vendor", System.getProperty("java.vendor"));
        javaInfoMap.put("runtime.version", System.getProperty("java.runtime.version"));
        javaInfoMap.put("home", System.getProperty("java.home"));
        return javaInfoMap;
    }

    private Map<String, String> getTomcatInfo() {
        Map<String, String> tomcatInfo = new HashMap<>();
        tomcatInfo.put("version", ServerInfo.getServerNumber());
        tomcatInfo.put("built", ServerInfo.getServerBuilt());
        tomcatInfo.put("info", ServerInfo.getServerInfo());
        return tomcatInfo;
    }

}
