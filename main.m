%%  Modelling hospital-acquired infections
%   Agent-based modelling course project
%   Singapore-ETH Centre (SEC)
%   Future Resilient Systems
%   Date: 23 October 2015
%   Version: 1.0
%   Authors:
%       *   Mateusz Iwo Dubaniowski
%       *   Tianyin Sun

display('Start simulation...');     %Started!

%% Initilization
TIMESTEPS = 10;
PROPERTIES = 4;
NSTAFF = 10;
NPATIENTS = 30;
WARDSMAP = [1 2 3 2 1; 1 1 2 3 3; 2 2 -1 2 3; 3 2 0 1 3; 2 2 1 3 1;]
dimensions = size(WARDSMAP);
wards = zeros(dimensions(1), dimensions(2));
agents = zeros(NSTAFF+NPATIENTS, PROPERTIES);
% Probabilities
infectionPatient=0.1;
infectionStaff=0.01;
recoverPatient=0.2;
recoverStaff=0.5;
susceptiblePatient=0.8;
susceptibleStaff=0.4;
movementProbMat = rand(dimensions(1)*dimensions(2), dimensions(1)*dimensions(2));
for i=1:1:dimensions(1)*dimensions(2)
    if (WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1)>0)
        movementProbMat(:,i)=movementProbMat(:,i)*WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1);
    end
end
for i=1:1:dimensions(1)*dimensions(2)
    movementProbMat(i,:) = movementProbMat(i,:)/sum(movementProbMat(i,:));
end


%% Iterate over time

for tstep=1:1:TIMESTEPS
    tstep

%% Iterate over agents


%% Update agents

end

%% Save data


% Completed!
display('Success! Simulation completed!');