clear all; 
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       Pperiod=9*1e-06;
       T=25;  %cels
       omega0=10e-6;
       L=1e-3;
       P1=1e7;
       lamv=(1:0.0005:1.1).*1e-6;
       deff=14.9e-12*3e4/(4*pi); %ppktp d33

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       c=3e8;

       dx=20e-6;
       dy=20e-6;
       dz=0.15e-6;
       
       
   
       MaxX=200e-6; MaxY=200e-6; 
       [X,Y] = meshgrid(-MaxX:dx:MaxX,-MaxY:dy:MaxY);
       X2=X ;  X1=X;  Y2=Y;  Y1=Y;
       
     
      
          Lcord=-L/2:dz:L/2; 
          zz=sign(sin(2*pi.*Lcord./Pperiod));
        
         lam=0;
        
         for lambda1 = lamv;
             tic
             lam=lam+1
         lambda2=lambda1/2;
       
            % n1 =n_ktp_5g(lambda1*1e6)+dn_dtz(T,lambda1*1e6);
            % n2 =n_ktp_5g(lambda2*1e6)+dn_dtz(T,lambda2*1e6);

            [np,n1,ni]=ktpzyz(1.*1e6,lambda1.*1e6,1.*1e6,T);
            [np,n2,ni]=ktpzyz(1.*1e6,lambda2.*1e6,1.*1e6,T);
              
            w1 = 2*pi*c/lambda1;
            k1=  2*pi*n1/lambda1;
                    
            w2 = 2*pi*c/lambda2;      
            k2 = 2*pi*n2/lambda2;
            
 % zz=[zz,zz];
       
           E2w=zeros(size(X2));
%           E2_L = zeros(size(Z2));          
           ni_x = (X2./dx)./size(X2,2)/dx;   %scale change
           ni_y = (Y2./dy)./size(Y2,1)/dy;   %scale change
           B = ni_x.^2+ni_y.^2;
 
 
 % The Gaussian transfer function 
 %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
          H0=1; 
          TransFact =i*2*pi*((n2/lambda2)^2-B).^0.5;
          H2=H0.*exp(TransFact*(dz)); % H2 is the transfer function for SH propagation
          E2out=zeros(size(X2));
          

   
        Y1 = Y2;   
        X1 = X2 ;
        Z1 = 3e-3;
        
   %_________________________________________________________
   
   
            b = omega0^2*k1;
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
            
            %Electric field coefficients
            E0 = sqrt(16*P1/(c*n1*omega0^2));
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

E1out=[];

       flag=0;
   
    for  z_slice=Lcord; 
      
        flag=flag+1;
        xi=2*z_slice/b ;                             
        tau=1/(1+sqrt(-1)*xi);
       
       
        E1 = (E0*tau)*exp(sqrt(-1)*k1*z_slice).*exp(-(X1.^2+Y1.^2)./(omega0^2).*tau);
        Poling_sign=zz(flag);
        dE2_dz=(2*pi*i*w2/(c*n2))*deff*E1.^2.*Poling_sign;
        
        %the added contribution of every slab to the generated field
        f2=dE2_dz*dz+E2out;
        
        %propagating SH
        
        F2=fftshift(fft2(f2));
        G2=H2.*F2;
        E2out=ifft2(ifftshift(G2));
      
   
    end     
       po2w(lam)= n2*c/(8*pi)*sum(abs(E2out(:)).^2)*dx*dy;
       toc
    end 
       
           
figure;
plot(lamv,po2w)
       