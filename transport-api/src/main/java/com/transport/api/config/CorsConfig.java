package com.transport.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

@Configuration
public class CorsConfig {

  @Bean
  public CorsFilter corsFilter(){
    CorsConfiguration config = new CorsConfiguration();

    //En-développement , autoriser toutes les origines
    // ⚠️ TODO futur : restreindre à votre vrai domaine avant mise en production

    config.setAllowedOriginPatterns(List.of("*"));
    config.setAllowedMethods(List.of("GET","PUT","POST","DELETE","OPTIONS"));
    config.setAllowedHeaders(List.of("*"));
    config.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);

    return new CorsFilter(source);


  }
  
}
