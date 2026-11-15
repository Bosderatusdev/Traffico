package com.transport.api.security;

import java.io.IOException;
import java.time.Duration;
import java.util.Iterator;
import java.util.List;
import java.util.Arrays;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

  //un "bucket" (compteur ) par adresse IP
  private final ConcurrentMap<String, Bucket> buckets = new ConcurrentHashMap<>();

  //Routes sensibles à protéger contre le brute force

  private static final List<String> ROUTES_PROTEGEES = Arrays.asList(
    "/api/auth/login",
    "/api/auth/verify-phone",
    "/api/auth/verify-email",
    "/api/auth/forgot-password",
    "/api/auth/reset-password",
    "/api/auth/resend-code"
  );

  private Bucket createNewBucket(){
    //5 tentatives autorisées , puis une nouvelle tentative accordée après tous les 2minutes
    
    Bandwidth limit = Bandwidth.builder()
                .capacity(5)
                .refillGreedy(5, Duration.ofMinutes(2))
                .build();

    return Bucket.builder().addLimit(limit).build();
  }

  //vérifier si le chemein demandé fait parti des routes protégées via un itérator

  private Boolean estRouteProtegee(String path){
    Iterator<String> iterator = ROUTES_PROTEGEES.iterator();
    while (iterator.hasNext()) {
      String route = iterator.next();
      if(path.equals(route)){ return true ;}
      
    }

    return false;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response , FilterChain filterChain)
  throws ServletException , IOException{
    String path = request.getRequestURI();

    if(estRouteProtegee(path)){
      String ip = request.getRemoteAddr();
      Bucket bucket = buckets.computeIfAbsent(ip, k -> createNewBucket());

      if(!bucket.tryConsume(1)){
        response.setStatus(429); //too many request
        response.setContentType("application/json");
        response.getWriter().write("{\"error\":\"Trop de tentatives. Réessayez dans quelques minutes.\"}");
        return;

      }
    }

    filterChain.doFilter(request, response);
  }

  
}
