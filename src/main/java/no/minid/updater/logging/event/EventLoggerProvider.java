package no.minid.updater.logging.event;

import no.difi.resilience.spring.ResilientJmsTemplate;
import no.idporten.log.event.EventLogger;
import no.idporten.log.event.EventLoggerImpl;
import no.minid.updater.config.ConfigProvider;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;

import javax.jms.ConnectionFactory;


@Configuration
public class EventLoggerProvider {

    private ConfigProvider configProvider;

    @Autowired
    public EventLoggerProvider(ConfigProvider configProvider) {
        this.configProvider = configProvider;
    }

    @Bean
    public EventLogger eventLogger() {
        return new EventLoggerImpl(eventQueueJmsTemplate());
    }

    @Bean
    public JmsTemplate eventQueueJmsTemplate() {
        JmsTemplate jmsTemplate = new ResilientJmsTemplate("HK_Hendelseskø");
        jmsTemplate.setConnectionFactory(eventQueueJmsConnectionFactory());
        jmsTemplate.setDefaultDestination(new ActiveMQQueue(configProvider.getEvent().getJmsQueue()));
        return jmsTemplate;
    }

    @Bean
    public ConnectionFactory eventQueueJmsConnectionFactory() {
        ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory();
        connectionFactory.setBrokerURL(configProvider.getEvent().getJmsUrl());
        CachingConnectionFactory cachingConnectionFactory = new CachingConnectionFactory();
        cachingConnectionFactory.setTargetConnectionFactory(connectionFactory);
        cachingConnectionFactory.setSessionCacheSize(10);
        return cachingConnectionFactory;
    }

}
