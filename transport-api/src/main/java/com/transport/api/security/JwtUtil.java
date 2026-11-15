package com.transport.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    // Générer un token pour un user (identifiant + rôle)
    public String generateToken(String identifiant, String role, Integer tokenVersion) {
        return Jwts.builder()
                .subject(identifiant)
                .claim("role", role)
                .claim("tokenVersion", tokenVersion)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSigningKey())
                .compact();
    }

    public Integer extractTokenVersion(String token) {
        return extractClaim(token, claims -> claims.get("tokenVersion", Integer.class));
    }

    // Extraire l'identifiant depuis un token
    public String extractIdentifiant(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // Extraire le rôle depuis un token
    public String extractRole(String token) {
        return extractClaim(token, claims -> claims.get("role", String.class));
    }

    // Vérifier si le token est expiré
    public boolean isTokenExpired(String token) {
        return extractClaim(token, Claims::getExpiration).before(new Date());
    }

    // Valider un token
    public boolean validateToken(String token) {
        try {
            return !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    private <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        Claims claims = Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return claimsResolver.apply(claims);
    }
}