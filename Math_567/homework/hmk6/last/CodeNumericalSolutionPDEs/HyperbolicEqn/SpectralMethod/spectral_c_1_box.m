%% spectral_c_1_box.m

%% Author: Louise Olsen-Kettle (email: l.kettle1@uq.edu.au, @DrOlsen-Kettle)
%% Code to supplement lecture notes by Louise Olsen-Kettle:
%% Numerical solution of Partial Differential Equations (PDEs)
%% Webpage: http://espace.library.uq.edu.au/view/UQ:239427
%% ISBN: 978-1-74272-149-1

% using the spectral method for the flux conservative problem: U_t = -c U_x
% the spectral method is not very accurate for "rough" functions

 
c=1.;

x1=0;
a = 2.*pi; % length in x-direction
x2=a;

T = 5.; % length of time for solution

n = 512;   % no of grid points Xn

dx = a/(2.*n); % grid spacing in x direction

dt = dx/4.;

m = round(T/dt); 

t=0.; % initial time = 0

% set up mesh in x-direction:
x = linspace(x1,x2-dx, 2*n)';

% matlab stores wave numbers differently from us:
nu = [0:n  -n+1:-1]';

% define U^0 at t_k = 0 
U_tk_1 = zeros(2*n,1);
for i = 1:2*n
    if x(i) >= 0.5
       if x(i) <= 1.
          U_tk_1(i) = 1;
       end
    end
end
 

% define U^(-1) at t_k = -1
% using U^(-1) = U^0(x-dt) since c=1:
U_tk_2 = zeros(2*n,1);
for i = 1:2*n
    if x(i) - dt >= 0.5
       if x(i) - dt <= 1.
          U_tk_2(i) = 1;
       end
    end
end



figure(1)
plot (x,U_tk_2,'-')
%axis ([0 2*pi 0 2])
title ('Initial condition for U')
xlabel ('x')
ylabel ('U')

% store solution for each time in matrix U(nxm):

U=zeros(2*n,round(m/400));
tvec=zeros(round(m/400),1);

U(:,1) = U_tk_1;
tvec(1) = t;

U_tk = zeros(2*n,1);

kk=1;
% now march solution forward in time using U_tk+1 = U_tk-1 - 2*i*dt*(c(x)*ifft(nu*fft(U_tk))) :

for k = 1:m-1
    t = t+dt;

    uhat = fft(U_tk_1);
    what = 1i*nu.*(uhat);
    w = real(ifft(what));
    U_tk = U_tk_2 - 2*dt*c.*w ;
    % for next time step:
    U_tk_2 = U_tk_1;
    U_tk_1 = U_tk;

    if mod(k,400)==0
       U(:,kk+1) = U_tk;
       tvec(kk+1) = t;
       kk=kk+1;
    end

end


figure(2)

plot(x,c,'-')
title ('Constant wave speed')
xlabel ('x')
ylabel ('Constant wave speed c(x)')



figure(3)
waterfall(x,tvec,U')
%axis ([0 1 0 2 0 1.1])
title ('Variation of U with time')
xlabel ('x')
ylabel ('t')
zlabel ('U')


figure(4)
plot (x,U_tk)
%axis ([0 2 0 1.1])
title('Final solution at t=5')
xlabel ('x')
ylabel ('U')
































