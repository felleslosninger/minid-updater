package no.minid.updater.logging.audit;

import no.idporten.log.audit.AuditLogger;
import no.idporten.log.audit.AuditLoggerELFImpl;
import no.idporten.log.elf.ELFWriter;
import no.idporten.log.elf.FileRollerDailyImpl;
import no.idporten.log.elf.WriterCreator;
import no.minid.updater.config.ConfigProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AuditLoggerProvider {

    @Bean
    @Autowired
    public AuditLogger auditLogger(ConfigProvider configProvider) {
        ELFWriter elfWriter = new ELFWriter(
                new FileRollerDailyImpl(configProvider.getAudit().getLogDir(), configProvider.getAudit().getLogFile()),
                new WriterCreator()
        );
        AuditLoggerELFImpl logger = new AuditLoggerELFImpl();
        logger.setELFWriter(elfWriter);
        logger.setDataSeparator("|");
        return logger;
    }

}
