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

WARDSMAP = [3 3 3 3 -1; 3 2 2 3 1; 3 3 -1 1 3; 1 3 0 1 1; 3 2 -1 2 1;]      % Map of the hospital floor

NPATIENTS = sum(sum(WARDSMAP))+1;           % Total 
dimensions = size(WARDSMAP);
CLEANROOM = 13;                             %Basic cleanroom room no.
wards = zeros(dimensions(1), dimensions(2));
agents = zeros(NSTAFF+NPATIENTS, PROPERTIES);       % Agents' properties matrix
agents(1, 3)=1;
new_agents=agents;                                  % Agents' properties matrix for changing of state to a new state
agents(1:1:NPATIENTS, 1)=1;                                         % Assigning patients property to patients
for i=NPATIENTS+1:1:NPATIENTS+NSTAFF
    agents(i, 2)=round((rand*(dimensions(1)*dimensions(2)))+0.5);   % Assigining staff to wards randomly in the beginning
end
% Assigning patients to rooms
temppatient=1;
for i=1:1:dimensions(1)*dimensions(2)
    for j=1:1:WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1)
        agents(temppatient, 2)=i;
        temppatient=temppatient+1;
    end
end
% Probabilities of various events
infectionPatient=0.1;
infectionStaff=0.05;
recoverPatient=0.1;
recoverStaff=0.8;
recoverStaffCleanRoom=1;
susceptiblePatient=0.8;
susceptibleStaff=0.92;
movementProbMat = rand(dimensions(1)*dimensions(2), dimensions(1)*dimensions(2));
for i=1:1:dimensions(1)*dimensions(2)
    if (WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1)>0)
        movementProbMat(:,i)=movementProbMat(:,i)*WARDSMAP(floor((i-1)/dimensions(1))+1, mod((i-1), dimensions(2))+1);
    end
end
% Normalizing the movement probability matrix
for i=1:1:dimensions(1)*dimensions(2)
    movementProbMat(i,:) = movementProbMat(i,:)/sum(movementProbMat(i,:));
    for j=dimensions(1)*dimensions(2):-1:1
       movementProbMat(i,j) = sum(movementProbMat(i,1:1:j));
    end
end
status_data=zeros(TIMESTEPS+1, 3);

%% Iterate over time
new_agents=agents;

% Keeping data for visualisation
status_data(1, 1)=sum(agents(:,3)==0);
status_data(1, 2)=sum(agents(:,3)==1);
status_data(1, 3)=sum(agents(:,3)==2);
for tstep=1:1:TIMESTEPS
    tstep

%% Iterate over agents
    for agent=1:1:NSTAFF+NPATIENTS
    
%% Update agents
        % Susceptible agents
        if(agents(agent,3)==0)
           if(agents(agent,1)==0)   % infect from staff in the same room
               sameroom=find(agents(:,2)==agents(agent,2));
               for i=1:1:length(sameroom)
                   if(agents(i, 3)==1 && rand<infectionStaff)
                       new_agents(agent,3)=1;
                   end
               end
           else                     %infect from other patients in the same room
               sameroom=find(agents(:,2)==agents(agent,2));
               for i=1:1:length(sameroom)
                   if(agents(i, 3)==1 && rand<infectionPatient)
                       new_agents(agent,3)=1;
                   end
               end
           end
        end
        
        % Infected agents 
        if(agents(agent,3)==1)
            if(agents(agent,1)==0)  %recover (lose infection/clean) for staff
                tempRecoverStaff=recoverStaff;
                %Adjust recovery probability for staff in clean room
                if(WARDSMAP(floor((agents(agent, 2)-1)/dimensions(1))+1, mod(agents(agent, 2)-1, dimensions(2))+1)==-1)
                    tempRecoverStaff=recoverStaffCleanRoom;
                    agents(agent, 4)=0;
                end
                if(rand<tempRecoverStaff)
                    new_agents(agent,3)=2;
                end
            else                    %recover for patients
                 if(rand<recoverPatient)
                    new_agents(agent,3)=2;
                 end
            end
        end
        
        %Recovered agents
        if(agents(agent,3)==2)
            if(agents(agent,1)==0)  %become susceptible again for staff
                if(rand<susceptibleStaff)
                    new_agents(agent,3)=0;
                end
            else                    %become susceptible again for patients
                 if(rand<susceptiblePatient)
                    new_agents(agent,3)=0;
                 end
            end
        end
        
        %increase patients visited since cleanroom
        if(agents(agent,1)==0)
            agents(agent, 4)=agents(agent, 4)+1;
        end
        
        %Move staff around according to the movement probability matrix
        if(agents(agent,1)==0)
            new_agents(agent,2)=find(movementProbMat(agents(agent,2),:)>rand, 1);
        end
        
        if(agents(agent,1)==0)
            if(agents(agent, 4)/40>rand)
                new_agents(agent,2)=CLEANROOM;     %Additional probability to go to CLEAN ROOM proportional to number of patients since last cleaning
            end
        end
    end
    agents=new_agents;

    % Visualizing the data    
    heatmapMat=zeros(dimensions(1), dimensions(2));
    for localtemp=1:1:dimensions(1)*dimensions(2)
        heatmapMat(floor((localtemp-1)/dimensions(1))+1, mod(localtemp-1, dimensions(2))+1)=sum(and(agents(:,3)==1, and(agents(:,2)==localtemp, agents(:,1)==1)));
    end
subplot(2, 1, 1);
imagesc(heatmapMat);        %creating the heatmap
caxis([0 max(max(WARDSMAP))]);
colorbar;
title('Just the patients heatmap');

%% Save data
status_data(tstep+1, 1)=sum(agents(:,3)==0);
status_data(tstep+1, 2)=sum(agents(:,3)==1);
status_data(tstep+1, 3)=sum(agents(:,3)==2);

subplot(2, 1, 2);
plot(status_data(1:tstep, :));  %creating the graph
axis([0, TIMESTEPS, 0, NPATIENTS+NSTAFF]);
title('All agents summary plot');
legend('Susceptible', 'Infected', 'Recovered');

pause(0.001);

end

plot(status_data);
axis([0, TIMESTEPS, 0, NPATIENTS+NSTAFF]);
title('All agents summary plot');
legend('Susceptible', 'Infected', 'Recovered');

% Completed!
display('Success! Simulation completed!');