function [D] = smartstart( A,B,m,itmax )

[totv,~]=size(A);
n=totv-m;

A12=A(1:m,m+1:m+n);
A21=A(m+1:m+n,1:m);
A22=A(m+1:m+n,m+1:m+n);
B12=B(1:m,m+1:m+n);
B21=B(m+1:m+n,1:m);
B22=B(m+1:m+n,m+1:m+n);

eyen=eye(n);

scale = 100000;

patience=itmax;
tol=.999;
P = ones(n,n)/n;


a1 =A12'*A12;
a2=A22'*A22;
b1=B21*B21';
b2=B22*B22';
c1=A21*B21';
c2=A12'*B12;
toggle=1;
iter=0;
while (toggle==1)&&(iter<patience)
%
% here is where the big change is
%	
    iter=iter+1;
    c3 =A22*P*B22';
    c4 =A22'*P*B22;
    size(c4)
    size(P)
    
    Grad=(a1+a2)*P+P*(b1+b2)-c1-c2-c3-c4;
    ind = lapjv( -Grad, scale );%YiCaoHungarian(-Grad);%
    T=eyen(ind,:);
    cc4=A22'*T*B22;
    x=P*P'-P*T'-T*P'+T*T';
    y=P'*P-P'*T-T'*P+T'*T ;
    alpha2=(a1+a2)*x+(b1+b2)*y-2*c4*P'-2*cc4*T'+2*c4*T'+2*cc4*P';
    alpha2=trace(alpha2);
    xx=P*T'+T*P'-2*T*T';
    yy=P'*T+T'*P-2*T'*T;
    alpha=(a1+a2)*xx+(b1+b2)*yy-2*P'*(c1+c2)+2*T'*(c1+c2)+4*cc4*T'-2*c4*T'-2*cc4*P';
    alpha=trace(alpha);
    f0=0;
    f1=alpha2+alpha;
    if( alpha2==0)
      if (alpha<0)
      	toggle<-0;
      else
      	P<-T;
      end
    else
      f0<-0;
  	end
    crit= -alpha/(2*alpha2);
    f1= alpha2+alpha;
    fcrit=alpha2*crit^2+alpha*crit;
    if (crit < 1) && (crit > 0) && (fcrit < f0) && (fcrit < f1)
      P= crit*P+(1-crit)*T;
    elseif f0 < f1
      P=T;
    else
      toggle=0;
    end
end
D=blkdiag(eye(m),P);
