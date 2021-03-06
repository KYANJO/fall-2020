% Numerical approximation to Poisson's equation over the square [a,b]x[a,b] with
% Dirichlet boundary conditions.  Uses a uniform mesh with (n+2)x(n+2) total
% points (i.e, n interior grid points).
% Input:
%     ffun : the RHS of poisson equation (i.e. the Laplacian of u).
%     gfun : the boundary function representing the Dirichlet B.C.
%      a,b : the interval defining the square
%        m : m+2 is the number of points in either direction of the mesh.
% Ouput:
%        u : the numerical solution of Poisson equation at the mesh points.
%      x,y : the uniform mesh.
m = (2^6) - 1;
a=0; b=1;
h = (b-a)/(m+1); %mesh spacing

w = 2/(1+sin(pi*h)); %optimal relaxation parameter

[x,y] = meshgrid(a:h:b); %Uniform mesh, including boundary points.

% Laplacian(u) = f
f = @(x,y) 10*pi^2*(1+cos(4*pi*(x+2*y))-2*sin(2*pi*(x+2*y))).*exp(sin(2*pi*(x+2*y)));  
% u = g on Boundary
g = @(x,y) exp(sin(2*pi*(x+2*y)));           

% Exact solution is g.
uexact = @(x,y) g(x,y);

% Laplacian(u) = f
% u = g on Boundary
% Exact solution is g.
% Compute and time the solution
tic
[u,x,y] = sor(f,g,a,b,m,w);
gedirect = toc;
fprintf('SOR take %d s\n',gedirect);

% Plot solution
figure, set(gcf,'DefaultAxesFontSize',10,'PaperPosition', [0 0 3.5 3.5]),
surf(x,y,u), xlabel('x'), ylabel('y'), zlabel('u(x,y)'),
title(strcat('Numerical Solution to Poisson Equation, h=',num2str(h)));

% Plot error
figure, set(gcf,'DefaultAxesFontSize',10,'PaperPosition', [0 0 3.5 3.5]),
surf(x,y,u-uexact(x,y)),xlabel('x'),ylabel('y'), zlabel('Error'),
title(strcat('Error, h=',num2str(h)));



function [u,x,y] = sor(ffun,gfun,a,b,m,w)

h = (b-a)/(m+1); %mesh spacing

tol = 1e-10;   %relative residual

maxiter = 10000;  %maximum value of k

[x,y] = meshgrid(a:h:b); %Uniform mesh, including boundary points.

idx = 2:m+1;
idy = 2:m+1;
dx = 1:m+2;
dy = 1:m+2;

u = zeros(m+2);

% Compute boundary terms, south, north, east, west
u(1,1:m+2)    = feval(gfun,x(1,1:m+2),y(1,1:m+2));        % Include corners
u(m+2, 1:m+2) = feval(gfun,x(m+2,1:m+2),y(m+2,1:m+2)); % Include corners
u(idy,m+2)    = feval(gfun,x(idx,m+2),y(idy,m+2));        % No corners
u(idy,1)      = feval(gfun,x(idy,1),y(idy,1));              % No corners

% Evaluate the RHS of Poisson's equation at the interior points.
f = feval(ffun,x(dy,dx),y(dy,dx));

for k = 0:maxiter
    %Iterate
    for j = 2:m+1
        for i = 2:m+1
            u(i,j) = (1-w)*u(i,j)+(w/5)*(u(i-1,j)+u(i+1,j)+u(i,j-1)+u(i,j+1))...
                +(w/20)*(u(i-1,j-1)+u(i+1,j-1)+u(i+1,j+1)+u(i-1,j+1))...
            -(h^2/20)*w*(4*f(i,j)+0.5*(f(i-1,j)+f(i+1,j)+f(i,j-1)+f(i,j+1)));
        end
    end
    
    %Compute the residual
    residual = zeros(m+2);
    
    for j = 2:m+1
        for i = 2:m+1
            residual(i,j) = -20*u(i,j)+4*(u(i-1,j)+u(i+1,j)+u(i,j-1)+u(i,j+1))...
            +(u(i-1,j-1)+u(i+1,j-1)+u(i+1,j+1)+u(i-1,j+1))...
            -(h^2)*(4*f(i,j)+0.5*(f(i-1,j)+f(i+1,j)+f(i,j-1)+f(i,j+1)));
        end
    end
    
    %Determine if convergence has been reached
	if norm(residual(:),2) < tol*norm(f(:),2)
		break
    end
end
end
