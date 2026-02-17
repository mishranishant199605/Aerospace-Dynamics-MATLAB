%% Program for Earth's gravity assist for installing a space probe in martian orbit, saving money and time

clear all
close all
clc
 
mu  = 398600.44; % km^3/s^2
re  = 6378.137; % km

%% Earth plot

figure(1)
hold on
load('orbit_example.mat')
imData = imread('2_no_clouds_4k.jpg');
[xS,yS,zS] = sphere(50);

xSE = re*xS;
ySE = re*yS;
zSE = re*zS;

% Plot the Earth Sphere
surface(xSE,ySE,zSE);
axis equal

ch = get(gca,'children');
set(ch,'facecolor','texturemap','cdata',flipud(imData),'edgecolor','none');

% Add the axis labelsclear all
grid on
xlabel('Inertial x (m)')
ylabel('Inertial y (m)')
zlabel('Inertial z (m)')
grid on
hold on

%% properties of the inintial orbit of space probe in Low Earth Orbit

 ai = 6778; % km        initial semi major axis
rai = 6913.56; % km     initial radius at apogee 
 rp = 6642.44; % km      radius at perigee
 nu =  0;%               true anomaly

   ra = zeros(1,5);
ra(1) = rai; 

    a = zeros(1,5);
 a(1) = ai;

   en = zeros(1,5);
en(1) = .02;

    i = 29;

    O = zeros(1,5);
 O(1) = 0;

    w = zeros(1,5);
 w(1) = 30;   

    ct=1;

%% Loop for the number of orbit to be executed 
for j = 1:5
      
         Tp(j) = (2*pi*(a(j)^(3/2)))/(mu^.5);
          P(j) = a(j)*(1-en(j)^2);

     rP(j,1:3) = [rp*cosd(nu)  rp*sind(nu)  0];
     vP(j,1:3) = [-((mu/rp)^.5)*sind(nu)  sqrt(mu*((2/rp)-(1/a(j))))  0];

Apn1 = [cosd(O(j))*cosd(w(j))-sind(O(j))*sind(w(j))*cosd(i) -cosd(O(j))*sind(w(j))-sind(O(j))*cosd(w(j))*cosd(i) sind(O(j))*sind(i) 
        sind(O(j))*cosd(w(j))+cosd(O(j))*sind(w(j))*cosd(i) -sind(O(j))*sind(w(j))+cosd(O(j))*cosd(w(j))*cosd(i) -cosd(O(j))*sind(i) 
        sind(w(j))*sind(i) cosd(w(j))*sind(i) cosd(i)];

      rN(j,1:3) = (Apn1*rP(j,1:3)')';
      vN(j,1:3) = (Apn1*vP(j,1:3)')';
      

        options = odeset('RelTol',1e-10,'AbsTol',1e-10);
        [Ti,Ri] = ode45(@(t,z) MEV(t,z,mu), [0 Tp(j)] , [rN(j,1);rN(j,2);rN(j,3);vN(j,1);vN(j,2);vN(j,3)], options);

  %    If needed the path of the orbit can also be plotted using the command below 
  %    plot3(Ri(:,1),Ri(:,2),Ri(:,3),'LineWidth',.5,'Color','r','MarkerSize',2)

%% Loop for storing every oreintation in separate frames


        for l = 1:10:length(Ri)
           plot3(Ri(l,1),Ri(l,2),Ri(l,3),'*','MarkerSize',5,'Color','r')
           xlabel("Inertial x-axis")
           ylabel("Inertial y-axis")
           zlabel("Inertial z-axis")
           title("Satellite maneuver path")
           pause(.03)
           M(ct) = getframe(gcf);
           ct=ct+1;
           rotate3d on
        end

%% updating the values
       % ct = 1;
        h(j,1:3)  = cross(rN(j,1:3),vN(j,1:3));
        e(j,1:3)  = (1/mu)*(cross(vN(j,1:3),h(j,1:3))) - (1/ra(j))*rN(j,1:3);
        n(j,1:3)  = cross([0 0 1],h(j,1:3));

         en(j+1)  = norm(e(j,1:3));
          O(j+1)  = acosd(n(j)/norm(n(j,1:3)));
          w(j+1)  = acosd(dot(e(j,1:3),n(j,1:3))/(norm(e(j,1:3))*norm(n(j,1:3))));    


          ra(j+1) = ra(j)+5000;
           a(j+1) = (rp+ra(j+1))/2;

end
%% Movie formation
        movie(M)
        videofile = VideoWriter('Earth Gravity assist.avi','Uncompressed AVI');
        open(videofile)
        writeVideo(videofile,M)
        close(videofile)

%% function formation
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
