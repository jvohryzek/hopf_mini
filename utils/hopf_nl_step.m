function z = hopf_nl_step(z, wC, sumC, omega, noise_scale, config)
% Apply one nonlinear Hopf Euler-Maruyama update step.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Adapted and simplified from code by Yonatan Sanz Perl and Gustavo Deco.

suma = wC * z - sumC .* z;
zz = z(:, end:-1:1);
nonlinear_drift = config.a .* z + zz .* omega - z .* (z .* z + zz .* zz) + suma;
z = z + config.dt * nonlinear_drift + noise_scale * randn(size(z));
end
