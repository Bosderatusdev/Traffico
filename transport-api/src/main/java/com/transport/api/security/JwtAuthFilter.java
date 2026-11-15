package com.transport.api.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;

import java.io.IOException;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        String telephone = null;
        String jwt = null;

        // Le token doit être au format : "Bearer eyJhbGci..."
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            jwt = authHeader.substring(7);
            try {
                telephone = jwtUtil.extractIdentifiant(jwt);
            } catch (Exception e) {
                // Token invalide, on laisse passer sans authentifier
            }
        }

        // Si on a un téléphone extrait ET que personne n'est encore authentifié
        if (telephone != null && SecurityContextHolder.getContext().getAuthentication() == null) {

            UserDetails userDetails = userDetailsService.loadUserByUsername(telephone);

            if (jwtUtil.validateToken(jwt)) {

                Integer tokenVersion = jwtUtil.extractTokenVersion(jwt);
                Integer versionActuelle = userRepository.findByTelephone(telephone)
                                    .map(User::getTokenVersion)
                                    .orElse(null);


                if(tokenVersion !=null && tokenVersion.equals(versionActuelle)){

                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities());
            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authToken);
                }
        
                //sinon implique que le token est valide cryptographiqt mais obsolète
            }
        }

        filterChain.doFilter(request, response);
    }
}