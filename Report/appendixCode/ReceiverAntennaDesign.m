%% Defining the known design parameters	
f = 864*10^6; v = 299792458; 
Er = 4.5; h = 1.5*10^(-3); Zc = 50; Rin = 50;

%% Calculate the With of the patch
W = (v/(2*f)) * sqrt( 2/(Er+1));  

%% Calculate the Lenght of the patch from the effective relative permittivity
Ereff = (Er+1)*(1/2)+((Er-1)*(1/2))/sqrt(1+12*h/W); 
Ld = 0.412*h*(Ereff+.3)*(W/h+0.264)/((Ereff-0.258)*(W/h+0.8)); 
L = v/(2*f*sqrt(Ereff))-2*Ld; 

%% Defining two equations in order to find the width of the antenna strip
syms EstripX; syms WoX;
eq1 = EstripX == (Er+1)*(1/2)+((Er-1)*(1/2))/sqrt(1+12*h/WoX);
eq2 = Zc == 120*pi/(sqrt(EstripX)*(WoX/h+1.393+.667*log(WoX/h+1.444)));
answer = solve([eq1,eq2],[EstripX,WoX]);
Wo = answer.WoX; 

%% finding the lengt of the feed sloths from the input impedance
lambda = v/f; 
G1 = W*(1-(1/24)*(2*pi*h/lambda)^2)/(120*lambda); 
Zin = 1/(2*G1);
yo = acos(sqrt(Zin*Rin)/Zin)*L/pi;

%% Printing all the vaules in mm to the command window
PatchWidth = round((W*1000), 4)
PatchLength = round((L*1000), 4)
StripWidth = Wo*1000
FeedSlothLength = round((yo*1000), 4) 