close all;

parallelOn=true;

mkdir('results');
folder=strcat('results/', datestr(now, 'yyyy.mm.dd-HH.MM.SS'));
mkdir(folder);

desc = input('Enter test description\n', 's');
file=fopen(strcat(folder, '/', 'readme.txt'), 'w');
fprintf(file, desc);
fclose(file);

duplicateNumber=2;

% parameters
Ts=1.2:1.2;
Rs=1:1;
Ps=0:0;
Ss=0:0;


L=100; % grid size

emptySiteProps=0.4:0.4;
cooperatorProps=0.4:0.4;

rProbs=0.00:0.00; % strategy reset probability
qProbs=0.05:0.05; % cooperation prefer probability
alphas=0.5:0.5;
gammas=500:500;

models=0:4;

iterationNumber=20;


l = length(Ts)*length(Rs)*length(Ps)*length(Ss)*length(emptySiteProps)*length(cooperatorProps)*length(rProbs)*length(qProbs)*length(alphas)*length(gammas);
disp(strcat('We will run ', int2str(l), ' rounds, with ', int2str(length(models)), ' models each.'));

cooperatorLevels = [];
i=1;
for T=Ts;
for R=Rs;
for S=Ss;
for P=Ps;
    payoff=[R S;T P];
    
    for rProb=rProbs;
    for qProb=qProbs;
    for alpha=alphas;
    for gamma=gammas;
        for emptySiteProp=emptySiteProps;
        for cooperatorProp=cooperatorProps;
            
            disp(num2str(i,'Starting round %d'))
            
            path = strcat(folder, '/', int2str(i), '/');
            mkdir(path);
            file=fopen(strcat(path, 'info.txt'), 'w');
            fprintf(file, 'T=%.2f\n', T);
            fprintf(file, 'R=%.2f\n', R);
            fprintf(file, 'P=%.2f\n', P);
            fprintf(file, 'S=%.2f\n\n', S);
            fprintf(file, 'emptySiteProp=%.2f\n', emptySiteProp);
            fprintf(file, 'cooperatorProp=%.2f\n\n', cooperatorProp);
            fprintf(file, 'rProb=%.2f\n', rProb);
            fprintf(file, 'qProb=%.2f\n\n', qProb);
            fprintf(file, 'alpha=%.2f\n', alpha);
            fprintf(file, 'gamma=%.2f\n', gamma);
            fprintf(file, 'iterationNumber=%d\n', iterationNumber);
            fclose(file);
            
            levels = zeros(1,5);
            iterLevels = zeros(iterationNumber + 1, 5);

            if parallelOn;
                parfor model=models;
                    levels(model+1) = cooperation(iterationNumber, L, payoff, emptySiteProp, cooperatorProp, rProb, qProb, alpha, gamma, model, path);                    
                    disp(sprintf('  Finished model %d', model));
                end
                
            else
                for model=models;
                    levels(model+1) = cooperation(iterationNumber, L, payoff, emptySiteProp, cooperatorProp, rProb, qProb, alpha, gamma, model, path);
                    disp(sprintf('  Finished model %d', model));
                end
            end
                for model=models;
                    iterLevels(:, model+1) = csvread(strcat(path, 'iterLevels-model', int2str(model), '.dat'));
                end
                str = 'Cooperator ratio evolution';
                fig = figure('Name',str);
                set(fig, 'visible','off')
                plot(1:iterationNumber+1, iterLevels(:,1), 1:iterationNumber+1, iterLevels(:,2), 1:iterationNumber+1, iterLevels(:,3), 1:iterationNumber+1, iterLevels(:,4), 1:iterationNumber+1, iterLevels(:,5))
                legend('Immitation only', 'Success driven migration only', 'Success driven migration and immitation', 'Reputation-based migration only', 'Immitation and success-driven and reputation-based migration')
                ylabel('Cooperator ratio');
                xlabel('Iterations');
                print(strcat(path, '/cooperator-ratio-evolution'), '-depsc');
                
            cooperatorLevels = [cooperatorLevels; levels];
            i=i+1;
        end
        end
    end
    end 
    end
    end
end
end
end
end

xAxis = cooperatorProps;
name = 'cooperatorProps';

str = 'Cooperator ratio';
figure('Name',str);
plot(xAxis, cooperatorLevels(:,1), xAxis, cooperatorLevels(:, 2), xAxis, cooperatorLevels(:, 3), xAxis, cooperatorLevels(:, 4), xAxis, cooperatorLevels(:, 5))
legend('Immitation only', 'Success driven migration only', 'Success driven migration and immitation', 'Reputation-based migration only', 'Immitation and success-driven and reputation-based migration')
ylabel('Cooperator ratio');
xlabel(name);
print(strcat(folder, '/cooperator-ratio'), '-depsc');

str = 'Cooperator ratio log';
fig = figure('Name',str);
semilogy(xAxis, cooperatorLevels(:,1), xAxis, cooperatorLevels(:, 2), xAxis, cooperatorLevels(:, 3), xAxis, cooperatorLevels(:, 4), xAxis, cooperatorLevels(:, 5))
legend('Immitation only', 'Success driven migration only', 'Success driven migration and immitation', 'Reputation-based migration only', 'Immitation and success-driven and reputation-based migration')
ylabel('Cooperator ratio');
xlabel(name);
print(strcat(folder, '/cooperator-ratio-log'), '-depsc');

% You can reimport this data with the command
%   cooperatorLevels = csvread('<path_to_cooperatorLevels>.dat')
csvwrite(strcat(folder, '/', 'cooperatorLevels.dat'), cooperatorLevels);
csvwrite(strcat(folder, '/', name, '.dat'), xAxis);
    
    