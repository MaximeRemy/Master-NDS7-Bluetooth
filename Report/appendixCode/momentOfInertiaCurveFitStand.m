clear all;
%% DEFINE KNOWN PARAMETERS
Ra = 33.5;
La = 2.1*10^(-3); 
Ke = .58; 
Kt = .43; 
Bm = 0.9e-3;
Bs = 0.017;
Jm = 0.00024;
N = 4.643;

%% READ MEASURED DATA
[FileA,PathA]=uigetfile('*','Select measured frequency response file');
FullFileA = fullfile(PathA,FileA);
[Time Voltage Current]=textread(FullFileA,'%f%f%f', 'headerlines',2);

Current = -1 *Current;

vinit=mean(Voltage(1:497));
iainit=mean(Current(1:497));
omegasinit = (vinit-(iainit*Ra))/(Ke*N);

%Cropping time, current and voltage curves, to start at the voltage step
t = Time(497:end)-Time(497);
I = Current(497:end);
Voltcrop = Voltage(497:end);

%Cropping out the part of the signal that doesn't follow the model.
Icrop = [I(1:4) ; I(80:end)];
tcrop = [t(1:4) ; t(80:end)];

% The input signal (voltage) is approximated by an exponential function.
v_inf = 11.93;
tau = 0.0025; %The time at v = (v_inf-vinit) * 0.6321 + vinit
v = v_inf-(v_inf-vinit).*exp((-t)/(tau));

syms s t2;
vlaplace = laplace(v_inf-(v_inf-vinit).*exp((-t2)/(tau)),t2,s);

%% CURVE FITTING
 fun = 	@(Js) double(ilaplace( ((-Ke.*N.*omegasinit./La+((Jm.*s+Bm).*N.^2+Js.*s+Bs).*iainit ./(Jm.*N.^2+Js)+((Jm.*s+Bm).*N.^2+Js.*s+Bs).*vlaplace./(La.*(Jm.*N.^2+Js))) ./(s.^2+((Bm.*N.^2+Bs).*La+Ra.*(Jm.*N.^2+Js)).*s./(La.*(Jm.*N.^2+Js))+ (Bm.*N.^2.*Ra+Ke.*Kt.*N.^2+Bs.*Ra)./(La.*(Jm.*N.^2+Js)))),s,tcrop))-Icrop;
 x0 = [0.001];
 lb = [0.001];  % Lower bounds
 ub = [0.1];  % Upper bounds
 lsqoptions = optimoptions('lsqnonlin');
 lsqoptions.FunctionTolerance = 1e-6;
 lsqoptions.StepTolerance = 1e-6;
 x = lsqnonlin(fun,x0,lb,ub,lsqoptions)%lsqoptions
	
%% CALCULATING EXPECTED RESPONSE
Js=0.012; %Empirically chosen value.
i_calcX = double(ilaplace( ((-Ke.*N.*omegasinit./La+((Jm.*s+Bm).*N.^2+x.*s+Bs).*iainit ./(Jm.*N.^2+x)+((Jm.*s+Bm).*N.^2+x.*s+Bs).*vlaplace./(La.*(Jm.*N.^2+x))) ./(s.^2+((Bm.*N.^2+Bs).*La+Ra.*(Jm.*N.^2+x)).*s./(La.*(Jm.*N.^2+x))+ (Bm.*N.^2.*Ra+Ke.*Kt.*N.^2+Bs.*Ra)./(La.*(Jm.*N.^2+x)))),s,t));
i_calcJs = double(ilaplace( ((-Ke.*N.*omegasinit./La+((Jm.*s+Bm).*N.^2+Js.*s+Bs).*iainit ./(Jm.*N.^2+Js)+((Jm.*s+Bm).*N.^2+Js.*s+Bs).*vlaplace./(La.*(Jm.*N.^2+Js))) ./(s.^2+((Bm.*N.^2+Bs).*La+Ra.*(Jm.*N.^2+Js)).*s./(La.*(Jm.*N.^2+Js))+ (Bm.*N.^2.*Ra+Ke.*Kt.*N.^2+Bs.*Ra)./(La.*(Jm.*N.^2+Js)))),s,t));

%% PLOTTING
figure(1);
subplot(2,1,1);
plot(t,Voltcrop, 'b',t,v,'r--');
xlabel('Time [s]'); ylabel('Voltage [V]');
legend('Measured','Approximated')
axis tight;
grid;
subplot(2,1,2);
plot(t,I,'b', t, i_calcJs,'r--',t, i_calcX,'k:');
xlabel('Time [s]'); ylabel('Current [A]');
legend('Measured','Calculated with Js = 1.2e-2', 'Calculated with Js = 0.49e-2')
axis tight;
grid;