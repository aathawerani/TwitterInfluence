function [symbols] = SMProject(trainlabelspath)

users = 10;
peruserrecord = 71;
trainingrecords = 50;
maxiter = 10000;
tolerance = 1/10;
testingrecords = peruserrecord - trainingrecords;
totaldata = 710;
twitterdata = importdata([trainlabelspath '\SMfinal.csv'],',',totaldata);
SYMBOLS = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];

trainingsymbols = [];
testingsymbols = [];
for i=1:users
    train = [];
    test = [];
    for j=1:peruserrecord
        %display(twitterdata{((i-1)*users) + j}(1,length(twitterdata{((i-1)*users) + j})-1))
        %display(twitterdata{((i-1)*users) + j}(1,length(twitterdata{((i-1)*users) + j})))
        t1 = double(twitterdata{((i-1)*users) + j}(1,length(twitterdata{((i-1)*users) + j}))) - 48;
        if(strcmp(twitterdata{((i-1)*users) + j}(1,length(twitterdata{((i-1)*users) + j})-1), '1') > 0)
            t1 = t1+10;
        end
        if(j <= trainingrecords)
            train = [train t1];
        else
            test = [test t1];
        end
    end
    trainingsymbols = [trainingsymbols train'];
    testingsymbols = [testingsymbols test'];
end

trans = [0.5,0.5,0,0;
         0.33,0.33,0.33,0;
         0,0.33,0.33,0.33;
         0,0,0.5,0.5];

emis = [1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16;
    1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16;
    1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16;
    1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16 1/16];

TP = zeros(4, testingrecords);
FP = zeros(4, testingrecords);
FN = zeros(4, testingrecords);

for k=1:users
    [trans,emis] = hmmtrain(trainingsymbols(:,k)',trans,emis,'maxiterations',maxiter,'tolerance',tolerance);
    [PSTATES,logpseq] = hmmdecode(trainingsymbols(:,k)',trans,emis);
    
    fprintf('done with user %d training \n', k);
    
    trainingsample = trainingsymbols(:,k)';
    sample = [trainingsample testingsymbols(1,k)];
    [PSTATES,logpseq] = hmmdecode(sample,trans,emis);
    [M, maxPsd] = max(PSTATES(:,size(sample,2)));
    buzzSeq = [];
    buzzObservation = [];
    for T=2:testingrecords
        fprintf('user %d iteration %d ', k, T);
        [M, buzzObs] = max(emis(maxPsd, :));
        buzzObservation = [buzzObservation buzzObs];
        [M, buzzState] = max(trans(maxPsd, :));
        buzzSeq = [buzzSeq buzzState];

        if(buzzState == maxPsd)
            TP(buzzState, T) = TP(buzzState, T) + 1;
        else
            FP(buzzState, T) = FP(buzzState, T) + 1;
            FN(maxPsd, T) = FN(maxPsd, T) + 1;
        end
        
        sample = [sample testingsymbols(T,k)];
        [trans,emis] = hmmtrain(sample,trans,emis,'maxiterations',maxiter,'tolerance',tolerance,'Symbols',SYMBOLS);
        [PSTATES,logpseq] = hmmdecode(sample,trans,emis);
        [M, maxPsd] = max(PSTATES(:,T));
    end
    
    fprintf('done with user %d prediction \n', k);

end


F1score = zeros(4, testingrecords);
for c=1:4
    for b=1:testingrecords-1
        tp = TP(c, b); fp = FP(c, b); fn = FN(c, b);
        if(tp > 0)
            precision = TP(c, b) / (TP(c, b) + FP(c, b));
            recall = TP(c, b) / (TP(c, b) + FN(c, b));
        else
            if(fp == 0)
                precision = 1;
            else
                precision = 0;
            end
            if(fn == 0)
                recall = 1;
            else
                recall = 0;
            end
        end
        f1 = (precision * recall) / (precision + recall);
        F1score(c,b) = f1;
    end
end

display(F1score);