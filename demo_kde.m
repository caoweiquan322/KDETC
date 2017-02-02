randn('seed',1) % use for reproducibility
data=[randn(100,1)-10;randn(100,1)+10]; % normal mixture with two humps
n=length(data); % number of samples
h=std(data)*(4/3/n)^(1/5); % Silverman's rule of thumb
phi=@(x)(exp(-.5*x.^2)/sqrt(2*pi)); % normal pdf
ksden=@(x)mean(phi((x-data)/h)/h); % kernel density 
fplot(ksden,[-25,25],'k') % plot kernel density with rule of thumb 
hold on 
fplot(@(x)(phi(x-10)/2+phi(x+10)/2),[-25,25],'b') % plot the true density
[bandwidth, density, xmesh, cdf] = kde(data); % plot kde with solve-the-equation bandwidth
hist(data);