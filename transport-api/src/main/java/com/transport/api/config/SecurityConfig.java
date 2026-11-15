package com.transport.api.config;

import com.transport.api.security.JwtAuthFilter;
import com.transport.api.security.RateLimitFilter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthFilter jwtAuthFilter;

    @Autowired
    private RateLimitFilter rateLimitFilter;

    

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                
                // Routes publiques
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/trajets/search").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/trajets", "/api/trajets/{id}").permitAll()

                // Lecture (GET) accessible à tous les connectés
                .requestMatchers(HttpMethod.GET, "/api/**").authenticated()

                // Agences — seul Super Admin peut créer/modifier/supprimer
                .requestMatchers(HttpMethod.POST, "/api/agences/**").hasRole("SUPER_ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/agences/**").hasRole("SUPER_ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/agences/**").hasRole("SUPER_ADMIN")

                // Bus, Trajets, Chauffeurs — Admin Agence ou Super Admin
                .requestMatchers(HttpMethod.POST, "/api/bus/**", "/api/trajets/**", "/api/chauffeurs/**")
                    .hasAnyRole("ADMIN_AGENCE", "SUPER_ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/bus/**", "/api/trajets/**", "/api/chauffeurs/**")
                    .hasAnyRole("ADMIN_AGENCE", "SUPER_ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/bus/**", "/api/trajets/**", "/api/chauffeurs/**")
                    .hasAnyRole("ADMIN_AGENCE", "SUPER_ADMIN")

                // Users — suppression réservée au Super Admin
                .requestMatchers(HttpMethod.DELETE, "/api/users/**").hasRole("SUPER_ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/users/*/self").authenticated()
    

                // Reservations, Paiements, Avis, Notifications — tout user connecté peut créer les siens
                .requestMatchers(HttpMethod.POST, "/api/reservations/**", "/api/paiements/**", "/api/avis/**")
                    .authenticated()


                //Pour les favoris

                .requestMatchers(HttpMethod.POST, "/api/favoris/**", "/api/reservations/**", "/api/paiements/**", "/api/avis/**")
                    .authenticated()


                    

                .anyRequest().authenticated()
            )
            .addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

