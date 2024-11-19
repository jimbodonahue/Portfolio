clear all; clc;
tic;
## Initialize starting values
rng(42); # set seed
t = 100; # periods, here assumed to be days
n = 5000; # population
v = 66; # period of vaccine development
prox = 8; # proximity of contagion (integer << n)
s = ones(n,1); # susceptible
ishare0 = 0.07; # share of initially infected
istart = floor(ishare0*n); # number of people initially infected, must be <n
i0 = zeros(n,1);
pos = randperm(n,istart); # randomizes infected agents
  for k = 1:istart,
    i0(pos(1,k),:)= 1;
  end
s0 = s - i0;
s = s0; # copy var to iterate on, suppress t subscript
it = i0; # keep t to not confuse matlab with i or inf
r = zeros(n,1); # recovered
d = zeros(n,1); # deceased

pI = 0.015*ones(n,1); # basic chance for all infected
pR = 0.05*ones(n,1); # chance for infected to recover
pD = 0.005*ones(n,1); # chance for infected to succumb

## Adjust probabilities of infection/recovery
# All factors between 0 and 1, to be multiplied times the probability
# Therefore 0 is fully effective, 1 is no effect
mask = 0.8;
dist = 0.7;
quar = 0.5; # reduces chance of I from quick quarantiners
vacI = 0.5; # vaccine efficacy to prevent infection
vacD = 0.5; # vaccine efficacy to prevent death if infected
vacR = 0.5; # vaccine efficacy to improve recovery
padj = ones(n,1); # initiate vector for adjustment of infection probability
# Randomize places of agents using each measure
maskshare = 0.5; # fraction of population wearing masks
maskers = floor(maskshare*n); # share of population, round down
masked = ones(n,1);
posM = randperm(n,maskers); # randomizes masked agents
  for k = 1:maskers,
    masked(posM(1,k),:) = mask;
  end
distshare = 0.8; # share practicing social distance
distancers = floor(distshare*n);
distanced = ones(n,1);
posD = randperm(n,distancers); # randomizes distance
  for k = 1:distancers,
    distanced(posD(1,k),:) = dist;
  end
quickshare = 0.4; # share who quarantine quickly
quickquar = floor(quickshare*n);
quarred = ones(n,1);
posQ = randperm(n,quickquar);
  for k = 1:quickquar,
    quarred(posQ(1,k),:) = quar;
  end
vaxshare = 0.7; # share vaccinated (assumes immediate rollout)
vaxers = floor(vaxshare*n);
vaxed = ones(n,1);
posV = randperm(n, vaxers);
  for k = 1:vaxers,
    vaxed(posV(1,k),:) = 1;
  end

## Compute individual chances of infection
sird = [1 sum(s) sum(it) 0 0]; # matrix to store results
pI = pI.*masked.*distanced.*quarred;


## Iterate from time 2
for i = 2:t,
  if (i == v), # adjust probabilities on vaccine date
    pI = pI.*vacI;
    pR = 1 - (1 - vacR).*(1 - pR); # reduces chance of staying infected by vacR
    pD = pD.*vacD;
  end
  ## Here I adjust probabilities based on status and proximity to infected
  proxvec = zeros(n,1); # create proximity vector
  for p = 1:n,
    proxvec(p,1) = sum(it(max(1,p-prox):min(n,p+prox)));
  end
  prob = rand(n,1);
  ni = 1 - s.*pI.*proxvec; # newly infected chance, etc
  nr = 1 - it.*pR;
  nd = 1 - it.*(pD+pR); # because 0:pR was already used
    ## Loop for transition of states
    for j = 1:n,
      if s(j) == 1 && prob(j) > ni(j), # s -> i
        s(j) = 0;
        it(j) = 1;
      elseif it(j) == 1 && prob(j) > nr(j), # i -> r
        it(j) = 0;
        r(j) = 1;
      elseif it(j) == 1 && prob(j) > nd(j), # i -> d
        it(j) = 0;
        d(j) = 1;
      end
    end
  sird = [sird; j sum(s) sum(it) sum(r) sum(d)]; # collect results
end
toc
## Split sird into variable paths and plot
sp = sird(:,2);
ip = sird(:,3);
rp = sird(:,4);
dp = sird(:,5);
cmap = (colormap (viridis (64)));
plot(sp, "-+;Suceptible;", "linewidth", 2, ip, "--o;Infected;", "linewidth", 2, rp, ":x;Recovered;", "linewidth", 2, dp, "-.d;Deceased;", "linewidth", 2)
set(gca, "fontsize", 32)
title ("SIRD Model");
xlabel("Weeks");
ylabel("Cases");
text(sp, n, "Final Cases")
