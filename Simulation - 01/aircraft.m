clear all
close all
clc
%% 3D object file 

hf = figure('units','normalized','outerposition',[0 0 1 1]);
gm = importGeometry('Airplane_v1_l1.stl');
% subplot(1,2,1)
pdegplot(gm)
t = gca;
t.CameraPosition = [-4750 7000 5000];
c = t.Children;
l = c(1);
p = c(2);

%% channging the properties of current axis and figure

yl = t.XLabel;
xl = t.YLabel;
zl = t.ZLabel;
yl.String = "X-Axis(mm)";
xl.String = "Y-Axis(mm)";
zl.String = "Z-Axis(mm)";
t.XGrid = 'on';
t.YGrid = 'on';
t.ZGrid = 'on';
p.FaceColor = [ 0.5843 0.6157 0.7882];
T = t.Title;
T.String = "3D animation of aircraft";
b = zeros(1474,3);

%% Data obtained from the tracker 

% A = table2array(airplane35(9:end-1,3:8));
data = importdata("airplane 35.csv",',',5);
data = data.data(:,3:end);
A = data(:,:);
vert_save = p.Vertices;

RXd = A(:,1).*(180/pi);
RYd = A(:,2).*(180/pi);
RZd = A(:,3).*(180/pi);

Xd_save = get(l,'XData').';
Yd_save = get(l,'YData').';
Zd_save = get(l,'ZData').';


ct = 1;
%cc = 0;

t1=[];
p1=[];
s1=[];


for ii = 1:size(A,1)

    % extract values
    RX = A(:,1);
    RY = A(:,2);
    RZ = A(:,3);
    x = A(ii,4);
    y = A(ii,5);
    z = A(ii,6);
    format short e

%% rotation matrix with 1-2-3 rotation sequence as provided by tracker

  RVB = [cos(RY(ii))*cos(RZ(ii))   sin(RX(ii))*sin(RY(ii))*cos(RZ(ii))+cos(RX(ii))*sin(RZ(ii))   -cos(RX(ii))*sin(RY(ii))*cos(RZ(ii))+sin(RX(ii))*sin(RZ(ii))
        -cos(RY(ii))*sin(RZ(ii))  -sin(RX(ii))*sin(RY(ii))*sin(RZ(ii))+cos(RX(ii))*cos(RZ(ii))    cos(RX(ii))*sin(RY(ii))*sin(RZ(ii))+sin(RX(ii))*cos(RZ(ii))
         sin(RY(ii))              -cos(RY(ii))*sin(RX(ii))                                        cos(RX(ii))*cos(RY(ii))];

   RBV = RVB.';
%% Taking the matrix to standard 3-2-1 euler angle sequence

s1(ii) = atan2(RVB(1,2),RVB(1,1));
t1(ii) = asin(-RVB(1,3));
p1(ii) = atan2(RVB(2,3),RVB(3,3));


%% Rotation of the inertial frame to LAB frame 

  % move the patch
  set(p,'Vertices',((vert_save*RVB).' + [x;y;z]).');

  % move the outline
  planePts = [Xd_save,Yd_save,Zd_save].';
  temp = RBV*planePts+[x;y;z];
    set(l,'XData',temp(1,:))
    set(l,'YData',temp(2,:))
    set(l,'ZData',temp(3,:))

    axis([-500 12000 -3000 3000 -400 3000])

  % getting individual frames 
    drawnow
    pause(0.001)
     M(ct) = getframe(gca);
     ct = ct+1;

%      bb = -450000:5:2800;
% 
%     tf = subplot(1,2,2);
%      axis off
% 
%            title("3-2-1 Euler angles and location of COM of the aircraft")
% 
%            text(0,bb(end),'Ø(deg)')
%            text(2000,bb(end),'Ѳ(deg)')
%            text(4000,bb(end),'Ѱ(deg)')
%            text(6000,bb(end),'x(m)')
%            text(8000,bb(end),'y(m)')
%            text(10000,bb(end),'z(m)')
% 
%            if ii==1
%            RXH = text(0,bb((end-30)-30*ii),num2str(p1(ii)*(180/pi)));
%            RYH = text(2000,bb((end-30)-30*ii),num2str(t1(ii)*(180/pi)));
%            RZH = text(4000,bb((end-30)-30*ii),num2str(s1(ii)*(180/pi)));
%            TXH = text(6000,bb((end-30)-30*ii),num2str(A(ii,4)/1000));
%            TYH = text(8000,bb((end-30)-30*ii),num2str(A(ii,5)/1000));
%            TZH = text(10000,bb((end-30)-30*ii),num2str(A(ii,6)/1000));
%            else
% 
%            set(RXH,'String',num2str(p1(ii)*(180/pi)))
%             set(RYH,'String',num2str(t1(ii)*(180/pi)))
%              set(RZH,'String',num2str(s1(ii)*(180/pi)))
%               set(TXH,'String',num2str(A(ii,4)/1000))
%                set(TYH,'String',num2str(A(ii,5)/1000))
%                 set(TZH,'String',num2str(A(ii,6)/1000))
% 
%            end

    
end

movie(M)
video7 = VideoWriter('3D animation of aircraft1','Uncompressed AVI');
open(video7)
writeVideo(video7,M)
close(video7)