close all;

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

emptySiteProps=0.3:0.3;
cooperatorProps=0.39:0.39;

rProbs=0.00:0.00; % strategy reset probability
qProbs=0.05:0.05; % cooperation prefer probability
alphas=0.5:0.5;
gammas=500:500;

models=[1,2,3];

iterationNumber=10;


l = length(Ts)*length(Rs)*length(Ps)*length(Ss)*length(emptySiteProps)*length(cooperatorProps)*length(rProbs)*length(qProbs)*length(alphas)*length(gammas);
disp(strcat('We will run ', int2str(l), ' rounds, with ', int2str(length(models)), ' models each.'));

cooperatorLevels = [];
i=1;
for T=Ts;
for R=Rs;
for S=Rs;
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
            
            levels = zeros(1,4);
            
            for model=models
                levels(model+1) = cooperation(iterationNumber, L, payoff, emptySiteProp, cooperatorProp, rProb, qProb, alpha, gamma, model, path);
            end
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

csvwrite(strcat(folder, '/', 'cooperatorLevels.dat'), cooperatorLevels); 
    
    