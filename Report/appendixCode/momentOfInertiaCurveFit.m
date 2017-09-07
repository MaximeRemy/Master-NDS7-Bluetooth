clear all;
%% DEFINE KNOWN PARAMETERS
R = 33.5;
L = 2.1*10^(-3); 
Ke = .58; 
Kt = .43; 
B = 0.9e-3;
vinit = 2;
iinit = 0.0105;
omegainit = (vinit-(iinit*R))/Ke;

%% READ MEASURED DATA
[FileA,PathA]=uigetfile('*','Select measured frequency response file');
FullFileA = fullfile(PathA,FileA);
[Time Voltage Current]=textread(FullFileA,'%f%f%f', 'headerlines',2);

%Cropping time, current and voltage curves to remove spikes from the curve fitting and shift the time axis.
t = Time(278:end)-Time(278);
t1 = [t(1:13) ; t(49:end)];

I = Current(278:end);
I1 = [I(1:13) ; I(49:end)];

Voltcrop = Voltage(278:end);

% The input signal (voltage) is approximated by an exponential function.
v_inf = 9.925;
tau = 0.0025;
v = v_inf-(v_inf-vinit).*exp((-t)/(tau));

syms s t2;
vlaplace = laplace(v_inf-(v_inf-vinit).*exp((-t2)/(tau)),t2,s);

%% CURVE FITTING
 fun = 	@(Jm) double(ilaplace( ((Jm.*L.*iinit.*s+B.*L.*iinit-Jm.*Ke.*omegainit+Jm.*s.*vlaplace+B.*vlaplace) ./(Jm.*L.*s.^2+B.*L.*s+Jm.*R.*s+B.*R+Ke.*Kt)),s,t1))- I1;
 x0 = [0.001];
 lb = [0];  % Lower bounds
 ub = [1];  % Upper bounds
 lsqoptions = optimoptions('lsqnonlin');
 lsqoptions.FunctionTolerance = 1e-6;
 lsqoptions.StepTolerance = 1e-6;
 x = lsqnonlin(fun,x0,lb,ub,lsqoptions)%lsqoptions
	
%% CALCULATING EXPECTED RESPONSE
Jm=2.4e-04; %Empirically chosen value.
i_calcX = double(ilaplace( ((x.*L.*iinit.*s+B.*L.*iinit-x.*Ke.*omegainit+x.*s.*vlaplace+B.*vlaplace) ./(x.*L.*s.^2+B.*L.*s+x.*R.*s+B.*R+Ke.*Kt)),s,t));
i_calcJm = double(ilaplace( ((Jm.*L.*iinit.*s+B.*L.*iinit-Jm.*Ke.*omegainit+Jm.*s.*vlaplace+B.*vlaplace) ./(Jm.*L.*s.^2+B.*L.*s+Jm.*R.*s+B.*R+Ke.*Kt)),s,t));
 
%% PLOTTING
figure(1);
subplot(2,1,1);
plot(t(1:300),Voltcrop(1:300), 'b',t(1:300),v(1:300),'r--');
xlabel('Time [s]'); ylabel('Voltage [V]');
legend('Measured','Approximated')
axis tight;
grid;
subplot(2,1,2);
plot(t(1:300),I(1:300),'b', t(1:300), i_calcJm(1:300),'r--',t(1:300), i_calcX(1:300),'k:');
xlabel('Time [s]'); ylabel('Current [A]');
legend('Measured','Calculated with Jm = 2,4e-04', 'Calculated with Jm = 1,89891e-04')
axis tight;
grid;
