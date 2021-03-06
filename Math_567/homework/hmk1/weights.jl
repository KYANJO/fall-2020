"""
c = weights(z,x,m)
Calculate finite difference weights of up to order m.
Input: 
    z  location where approximations are to be accurate,
    x  vector with x-coordinates for the grid points
    m  highest derivative that we want to find weights for
Output:
    c  array size m+1, length(x) containing (as output) in 
       successive rows the weights for derivatives 0,1,...,m.
Example:  To generate the 2nd order centered FD formula for the zeroth, first,
          and second derivative, we make the following call to weights:
                   c = weights(0,[-1 0 1],2);
"""
function weights(z,x,m)

n = length(x);
c = zeros(m+1,n);
c1 = 1;
c4 = x[1] - z;
c[1,1]= 1;
for i = 2:n
   mn = min(i,m+1);
   c2 = 1;
   c5 = c4;
   c4 = x[i] - z;
   for j = 1:i-1
      c3 = x[i] - x[j];
      c2 = c2*c3;
      if j == i - 1
         c[2:mn,i] = c1*((1:mn-1).*c[1:mn-1,i-1]-c5*c[2:mn,i-1])/c2;
         c[1,i] = -c1*c5*c[1,i-1]/c2;
      end
      c[2:mn,j] = (c4*c[2:mn,j]-(1:mn-1).*c[1:mn-1,j])/c3;
      c[1,j]=c4*c[1,j]/c3;
   end
   c1 = c2;
end
return c
end