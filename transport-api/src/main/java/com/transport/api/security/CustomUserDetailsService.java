package com.transport.api.security;

import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String telephone) throws UsernameNotFoundException {
        User user = userRepository.findByTelephone(telephone)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé"));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getTelephone())
                .password(user.getMotDePasse())
                .authorities(List.of(new SimpleGrantedAuthority("ROLE_" + user.getRole().toUpperCase())))
                .build();
    }
}