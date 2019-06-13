%% Simulate visual detection task with a virtual subject
% This script simulates the presentation of a visual target
% logarithimically spaced isis and a subject with an average hit rate of
% 0.75 and a fals alarm rate of 0.10

% Ingredients:
% Stimulus events: Luminance change in one of the five LEDs; 
% ISI are sampled from an PDF with a mean ISI of 2 seconds;

% Create series of stimulus events
n=330; % number of stimuli 
lowerbnd = 1500;% minimal time (ms) between stimuli
upperbnd = 7000;% maximal time (ms) between stimuli
mu = 5;% params for lognormal distribution
sigma = 0.5;
pd = makedist('lognormal', mu, sigma);
r = random(pd,n,1);
r = (r./(max(r)))*(upperbnd-lowerbnd);
isis=round(r+lowerbnd);% generate 330 events with isis as per the above pdf

% Create Reaction Times from lognormal distribution
lowerbnd = 200;% minimal RT
upperbnd = 1200;% maximal RT
mu = 10;% params for lognormal distribution
sigma = 0.6;
pd = makedist('lognormal', mu, sigma);
r = random(pd,n,1);
r = (r./(max(r)))*(upperbnd-lowerbnd);
rt_dist=round(r+lowerbnd);% generate 330 events with isis as per the above pdf


ntrls=length(isis);
t=0;
dt=1;
trl=1;
time=t:dt:(sum(isis)+2000);
stim=zeros(1,length(time));
idx=cumsum(isis);
stim(idx)=1;
behav=zeros(1,length(time));
FAs=randperm(length(time),33);
behav(1,FAs)=1;
for n=1:length(idx)
    tmp_id=idx(n);
    tmp_rt=rt_dist(n);
    det=rand(1,1);
    if det >=0.25
       behav(1,tmp_id+tmp_rt)=1;
    end
            
end

%% Analyse Data to get D-Prime and Response Bias
% d-prime = z(hits)-z(FAs)
% response bias: c=z(hits)+z(FAs)

% Get hits by looping through stimulus presentations and check for button
% presses in a time window from 0 to 1200ms after stim presentation
idx_stim=idx;
idx_behav=find(behav==1);
hits=0;
for n=1:length(idx_stim)
    tmp_idx=[idx_stim(n) idx_stim(n)+1200];
    tmp_beh=find(behav(1,tmp_idx(1):tmp_idx(2)));
    if ~isempty(tmp_beh)
        hits=hits+1;
        rts(hits,1)=tmp_beh(1);
    end    
end
    
HR=hits/ntrls;% Hit rate
zHR=icdf('normal',HR,0,1);% z-transformed hit rate

% Get FAs by looping through button presses and check for stimulus onsets 
% in a time window from -1200 to 0 ms before button press

fas=0;
for n=1:length(idx_behav)
    tmp_idx=[idx_behav(n)-1200 idx_behav(n)];
    tmp_stim=find(stim(1,tmp_idx(1):tmp_idx(2)));
    if isempty(tmp_stim)
        fas=fas+1;
    end    
end

FAR=fas/ntrls;
zFAR=icdf('normal',FAR,0,1);% z-transformed FA rate

Dprime=zHR-zFAR;% D-prime
C=-(zHR+zFAR)/2;% Response Bias

%% Plot results

figure;
subplot(2,20,1:10);hist(isis,20);title('InterStim Intervals');
subplot(2,20,11:20);hist(rts,20);title('RT distribution');
subplot(2,20,21:33);plot(time,[stim;behav]);xlim([0 30000]);legend stimulus buttonpress; title('Stimulus Onsets and Button Presses');
subplot(2,20,34:40);bar([Dprime;C]);title('D-prime and Response Bias');

