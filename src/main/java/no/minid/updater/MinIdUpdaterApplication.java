package no.minid.updater;

import no.minid.service.MinIDService;
import no.minid.service.impl.MinIDServiceImpl;
import no.minid.updater.jms.UserUpdateMessageListener;
import no.minid.updater.service.UpdaterService;
import no.minid.updater.service.impl.UpdaterServiceImpl;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.listener.DefaultMessageListenerContainer;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@EnableWebMvc
@SpringBootApplication
@Configuration
public class MinIdUpdaterApplication {

    public static void main(String[] args) {
        SpringApplication.run(MinIdUpdaterApplication.class, args);
    }

    @Value("${update.jms.queue}")
    private String queueName;

    @Value("${event.jmsUrl}")
    private String eventlogJmsUrl;

    @Value("${update.jms.concurrentConsumers}")
    private Integer jmsConcurrentConsumers;

    @Value("${update.jms.maxConcurrentConsumers}")
    private Integer jmsMaxConcurrentConsumers;

    @Bean
    MinIDService minIDService() {
        return new MinIDServiceImpl();
    }

    @Bean
    UpdaterService updaterService() {
        return new UpdaterServiceImpl(minIDService());
    }

    @Bean
    UserUpdateMessageListener minIdUserUpdateMessageListener() {
        return new UserUpdateMessageListener(updaterService());
    }

    @Bean
    ActiveMQQueue minIdUpdaterDestination() {
        return new ActiveMQQueue(queueName);
    }

    @Bean
    ActiveMQConnectionFactory minIdUpdaterAmqConnectionFactoryBroker() {
        ActiveMQConnectionFactory activeMQConnectionFactory = new ActiveMQConnectionFactory();
        activeMQConnectionFactory.setBrokerURL(eventlogJmsUrl);
        return activeMQConnectionFactory;
    }

    @Bean
    CachingConnectionFactory minIdUpdaterCachedConnectionFactoryBroker() {
        CachingConnectionFactory cachingConnectionFactory = new CachingConnectionFactory();
        cachingConnectionFactory.setTargetConnectionFactory(minIdUpdaterAmqConnectionFactoryBroker());
        cachingConnectionFactory.setSessionCacheSize(100);
        return cachingConnectionFactory;
    }

    @Bean
    DefaultMessageListenerContainer minIdUpdaterJmsContainerInstanceBroker() {
        DefaultMessageListenerContainer defaultMessageListenerContainer = new DefaultMessageListenerContainer();
        defaultMessageListenerContainer.setConnectionFactory(minIdUpdaterCachedConnectionFactoryBroker());
        defaultMessageListenerContainer.setDestination(minIdUpdaterDestination());
        defaultMessageListenerContainer.setMessageListener(minIdUserUpdateMessageListener());
        defaultMessageListenerContainer.setConcurrentConsumers(jmsConcurrentConsumers);
        defaultMessageListenerContainer.setMaxConcurrentConsumers(jmsMaxConcurrentConsumers);
        defaultMessageListenerContainer.setSessionTransacted(true);
        return defaultMessageListenerContainer;
    }

}
