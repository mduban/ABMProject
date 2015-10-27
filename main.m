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
TIMESTEPS = 200;
PROPERTIES = 4;         % Properties: 1 - patient(1)/staff(0), 2 - room no., 3 - status: 0 - S, 1 - I, 2 - R
NSTAFF = 15;

WARDSMAP = [3 1 1 1 1; 1 1 1 1 1; 1 1 -1 1 1; 1 1 0 1 1; 1 1 1 1 1;]
NPATIENTS = sum(sum(WARDSMAP))+1;
dimensions = size(WARDSMAP);
wards = zeros(dimensions(1), dimensions(2));
agents = zeros(NSTAFF+NPATIENTS, PROPERTIES);
agents(1, 3)=1;
new_agents=agents;
agents(1:1:NPATIENTS, 1)=1;
for i=NPATIENTS+1:1:NPATIENTS+NSTAFF
    agents(i, 2)=round((rand*(dimensions(1)*dimensions(2)))+0.5);
end
temppatient=1;
for i=1:1:dimensions(1)*dimensions(2)
    for j=1:1:WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1)
        agents(temppatient, 2)=i;
        temppatient=temppatient+1;
    end
end
% Probabilities
infectionPatient=0.1;
infectionStaff=0.05;
recoverPatient=0.1;
recoverStaff=0.9;
susceptiblePatient=0.8;
susceptibleStaff=0.9;
movementProbMat = rand(dimensions(1)*dimensions(2), dimensions(1)*dimensions(2));
for i=1:1:dimensions(1)*dimensions(2)
    if (WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1)>0)
        movementProbMat(:,i)=movementProbMat(:,i)*WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1);
    end
end
for i=1:1:dimensions(1)*dimensions(2)
    movementProbMat(i,:) = movementProbMat(i,:)/sum(movementProbMat(i,:));
    for j=dimensions(1)*dimensions(2):-1:1
       movementProbMat(i,j) = sum(movementProbMat(i,1:1:j));
    end
end
status_data=zeros(TIMESTEPS+1, 3);

%% Iterate over time
new_agents=agents;
status_data(1, 1)=sum(agents(:,3)==0);
status_data(1, 2)=sum(agents(:,3)==1);
status_data(1, 3)=sum(agents(:,3)==2);
for tstep=1:1:TIMESTEPS
    tstep

%% Iterate over agents
    for agent=1:1:NSTAFF+NPATIENTS
    
%% Update agents
        if(agents(agent,3)==0)
           if(agents(agent,1)==0)
               sameroom=find(agents(:,2)==agents(agent,2));
               for i=1:1:length(sameroom)
                   if(agents(i, 3)==1 && rand<infectionStaff)
                       new_agents(agent,3)=1;
                   end
               end
           else
               sameroom=find(agents(:,2)==agents(agent,2));
               for i=1:1:length(sameroom)
                   if(agents(i, 3)==1 && rand<infectionPatient)
                       new_agents(agent,3)=1;
                   end
               end
           end
        end
        if(agents(agent,3)==1)
            if(agents(agent,1)==0)
                if(rand<recoverStaff)
                    new_agents(agent,3)=2;
                end
            else
                 if(rand<recoverPatient)
                    new_agents(agent,3)=2;
                 end
            end
        end
        if(agents(agent,3)==2)
            if(agents(agent,1)==0)
                if(rand<susceptibleStaff)
                    new_agents(agent,3)=0;
                end
            else
                 if(rand<susceptiblePatient)
                    new_agents(agent,3)=0;
                 end
            end
        end
        if(agents(agent,1)==0)
            new_agents(agent,2)=find(movementProbMat(agents(agent,2),:)>rand, 1);
        end
    end
    agents=new_agents;


%% Save data
status_data(tstep+1, 1)=sum(agents(:,3)==0);
status_data(tstep+1, 2)=sum(agents(:,3)==1);
status_data(tstep+1, 3)=sum(agents(:,3)==2);

end

plot(status_data);
legend('Susceptible', 'Infected', 'Recovered');

% Completed!
display('Success! Simulation completed!');