function levelCooperator = cooperation(iterationNumber, gridSize, payoff, emptySiteProp, cooperatorProp, rProb, qProb, alpha, gamma, model, path)



L=gridSize; % grid size
L2=L^2;
defectorProp=1.0-cooperatorProp;
cooperator=1;
defector=2;
m=4; % # of von Neumann neighbors
M=1; % Moore neighborhood


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Model 0 : imitation only = true, false, false, false
% Model 1 : success-driven migration only = false, true, false, false
% Model 2 : reputation-based migration only = true, false, true, true
% Model 3 : our model = true, true, true, false;
if model == 0
    imitationOn=true;
    successMigrationOn=false;
    reputationOn=false;
    randomMigrationOn=false;
elseif model == 1
    imitationOn=false;
    successMigrationOn=true;
    reputationOn=false;
    randomMigrationOn=false;
elseif model == 2
    imitationOn=true;
    successMigrationOn=false;
    reputationOn=true;
    randomMigrationOn=true;
elseif model == 3
    imitationOn=true;
    successMigrationOn=true;
    reputationOn=true;
    randomMigrationOn=false;
else
    error('Model does not exist');
end


grid=uint8(zeros(L));
overallPayoff=zeros(L); % accumulated
reputation=zeros(L);

% initialize
rng(1); % for reproduction
occupiedSize=round(L2*(1-emptySiteProp));
sitePos=randperm(L2,occupiedSize);
cooperatorSize=round(occupiedSize*cooperatorProp);
defectorSize=occupiedSize-cooperatorSize;
cooperatorPos=sitePos(1:cooperatorSize);
defectorPos=sitePos(cooperatorSize+1:end);

grid(cooperatorPos)=cooperator;
grid(defectorPos)=defector;

% moore neighbor index
MN=[0];
for i=1:M
    MN=[MN -i i];
end

levelCooperator=sum(sum(grid==cooperator))/size(sitePos,2);
levelDefector=1-levelCooperator;


str='Grid, t=0';
% colormap, w:empth, b:cooperator, r:defector
cmap = [1, 1, 1,
    0, 0, 1,
    1, 0, 0];
fig = figure('Name',str);
set(fig, 'visible','off')
imagesc(grid);
colormap(cmap);
axis square
saveas(fig, strcat(path, 'm', int2str(model), '-t0.jpg'));

    
% start simulation
for t=1:iterationNumber
    %disp(num2str(t,'iter=%d'));
    
    % update order
    [R, C]=ind2sub([L L],randperm(L2));
    
    for i=1:L2
        r=R(i);
        c=C(i);
        focal=grid(r,c);
        
        if focal==0 % empty
            continue;
        end
        
        leaving_prob = 1;
        if reputationOn      
            % sum reputations
            sum_reputation = 0;
            for MNr=MN
                rr=r+MNr;
                if rr < 1 || rr > L
                   continue;
                end
                for MNc=MN
                    cc=c+MNc;
                    
                    if cc < 1 || cc > L || ...
                       grid(rr,cc) == 0 % empty
                       continue;
                    end
                    
                    sum_reputation = sum_reputation + reputation(rr,cc)^gamma;
                end
            end
            
            if sum_reputation > 0
                leaving_prob = reputation(r,c)^gamma / sum_reputation;
            else
                leaving_prob = 0; % initial state
            end
            
            % update reputation, 
            reputation(r,c) = reputation(r,c)*alpha;
            if cooperator
                reputation(r,c) = reputation(r,c) + 1;
            end
        end
        
        
        op=getOverallPayoff(focal,r,c,L,grid,payoff);
        
        % migration
        leave = rand();
        if successMigrationOn && leave <= leaving_prob
            highestPayoff=op;
            highestrc=[r c];

            % test interaction
            for MNr=MN
                rr=r+MNr;
                if rr < 1 || rr > L
                   continue;
                end
                for MNc=MN
                    cc=c+MNc;

                    if cc < 1 || cc > L || ...
                        (rr == r && cc == c) || ... % itself
                        grid(rr,cc) ~= 0 % empty
                       continue;
                    end

                    % fictitious payoff
                    op=getOverallPayoff(focal,rr,cc,L,grid,payoff);

                    if op>highestPayoff
                        highestPayoff=op;
                        highestrc=[rr cc];
                    end
                end
            end

            % migrate to the candidate site
            if highestrc(1) ~= r || highestrc(2) ~= c
                grid(highestrc(1),highestrc(2))=grid(r,c);
                grid(r,c)=0;
                r=highestrc(1);
                c=highestrc(2);
            end

            op=highestPayoff;
            
        elseif randomMigrationOn && leave <= leaving_prob
            % gather empty sites
            empty_sites = [];
            for MNr=MN
                rr=r+MNr;
                if rr < 1 || rr > L
                   continue;
                end
                for MNc=MN
                    cc=c+MNc;

                    if cc < 1 || cc > L || ...
                        (rr == r && cc == c) || ... % itself
                        grid(rr,cc) ~= 0 % empty
                       continue;
                    end
                    
                    empty_sites = [empty_sites; rr cc];
                end
            end
                    
            if size(empty_sites,1) > 0
                % select an empty place randomly
                rc = randi([1,size(empty_sites,1)]);
                rr = empty_sites(rc, 1);
                cc = empty_sites(rc, 2);

                % migrate to there
                op=getOverallPayoff(focal,rr,cc,L,grid,payoff);
                grid(rr,cc)=grid(r,c);
                grid(r,c)=0;
                r=rr;
                c=cc;
            end
        end
               
        
        % update
        overallPayoff(r,c)=overallPayoff(r,c)+op;
               
        % strategy mutation
        if imitationOn
            % compare overall payoff with von Neumann neighbors
            highestPayoff=overallPayoff(r,c);
            highestrc=[r c];
            for rr=r-1:r+1
                if rr < 1 || rr > L
                   continue;
                end
                for cc=c-1:c+1
                    if cc < 1 || cc > L || ...
                        (rr == r && cc == c) || ... % itself
                        ((rr==(r-1) || rr==(r+1)) && (cc~=c)) % diagonal
                       continue;                       
                    end
                    
                    neighbor=grid(rr,cc);
                    if neighbor==0  % empty
                        continue;
                    end

                    if overallPayoff(rr,cc)>highestPayoff
                        highestPayoff=overallPayoff(rr,cc);
                        highestrc=[rr cc];
                    end
                end
            end

            % imitate the strategy
            if highestrc(1) ~= r || highestrc(2) ~= c
                grid(r,c)=grid(highestrc(1),highestrc(2));
            end
        end
    
        % noise 1
        reset = rand();
        if reset <= rProb % random strategy change
            if rand() <= qProb
                grid(r,c)=cooperator;
            else
                grid(r,c)=defector;
            end
        end
    end
    
%     str=num2str(t,'Grid, t=%d');
%     figure('Name',str)
%     imagesc(grid);
%     colormap(cmap);
%     axis square
end

levelCooperator=sum(sum(grid==cooperator))/size(sitePos,2);
levelDefector=1-levelCooperator;

str=num2str(t,'Grid, t=%d');
fig=figure('Name',str);
set(fig, 'visible','off')
imagesc(grid);
colormap(cmap);
axis square
saveas(fig, strcat(path, 'm', int2str(model), '-t', int2str(t), '.jpg'));

end

function op = getOverallPayoff(focal, r, c, L, grid, payoff)

op=0;

% interact with von Neumann neighbors
for rr=r-1:r+1
    if rr < 1 || rr > L
       continue;
    end
    for cc=c-1:c+1
        if cc < 1 || cc > L || ...
            (rr == r && cc == c) || ... % itself
            ((rr==(r-1) || rr==(r+1)) && (cc~=c)) % diagonal
           continue;                       
        end
        
        neighbor=grid(rr,cc);
        if neighbor==0  % empty
            continue;
        end

        op=op+payoff(focal, neighbor);
    end
end

end