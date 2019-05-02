package no.minid.updater.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.Min;

/**
 * LDAP config
 */
@Configuration
@ConfigurationProperties("spring.ldap")
@Validated
@Data
public class LdapConfig {

    private String urls;
    private String username;
    private String password;
    private String base;
    @Min(1)
    private int maxConnections;
    @Min(1)
    private long maxWait;
}