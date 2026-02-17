function [Zdot] = MEV(t,z,mu)
Zdot = zeros(6,1);
r_mag = norm(z(1:3));
Zdot(1) = z(4);
Zdot(2) = z(5);
Zdot(3) = z(6);
Zdot(4) = -(mu/r_mag^3)*z(1);
Zdot(5) = -(mu/r_mag^3)*z(2);
Zdot(6) = -(mu/r_mag^3)*z(3);
end
