package no.minid.updater.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.annotation.Validated;

import javax.validation.Valid;

@SuppressWarnings("ConfigurationProperties")
@Configuration
@ConfigurationProperties
@Validated
@Data
public class ConfigProvider {

    @Valid
    private Audit audit = new Audit();
    private Event event = new Event();

    /**
     * Audit log config
     */
    @Data
    public static class Audit {

        private String logDir;
        private String logFile;
    }

    @Data
    public static class Event {

        private String jmsUrl;
        private String jmsQueue;
    }

}
