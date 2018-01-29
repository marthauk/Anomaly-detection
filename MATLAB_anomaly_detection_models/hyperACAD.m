function [d_acad, anomalies_detected] = hyperACAD(M)
%HYPERRX Adaptive Causal Anomaly detector
%   hyperLRxDetector performs the Adaptive Causal detector using
%   correlation matrix
% It is adaptive in the sense that it removes the previously detected
% anomalies from the correlation set

% Usage
%   [result] = hyperACAD(M)
% Inputs
%   M  - 2D data matrix (p x N)
%   K  - Size of the kernel window, K x K
% Outputs
%   result - Detector output (1 x N)
%   sigma - Correlation matrix (p x p)
%   anomalies_detected - (1 x t_an) 




% t_an is the number of anomalies detected. Since MatLab is 1-index, T is
% initially set to 1, not 0.
t_an=1;

% bheta is the ratio of the entire image size to the size of anomaly
bheta = 100;
% p is number of spectral bands, N is number of pixels
[p, N] = size(M);

% anomalies_detected is the growing set of anomalies detected in the image.
% Numbers of anomalies will not exceed N/2. Even that is way to much.
% Starting point N/2. Need to include the pixel it was found, j. Make some
% kind of map
anomalies_detected=zeros(p,N/2);

% anomalies_detected_transpose_sum is the sum of the transposes taken on
% anomalous pixels
anomalies_detected_transpose_sum = 0;

% n_acad is used in the process of setting the threshold for finding an
% anomaly
n_acad = (N/bheta);

% u_k is the expected value/causal mean in the image. Initial value is set
% to the first pixel
u_k = M(:,1);

% tresh is the treshold value used to consider if the pixel is an anomaly
% or not. I think that it the anomaly detection will be normalized...(???)
% Grubbs test for setting treshold?
tresh = 15;

% adaptive_autocorr_inv is the inverse causal autocorrelation for each pixel n in the
% set N
%adaptive_autocorr_inv_n_acad = zeros(floor(n_acad),p,p);
%adaptive_autocorr_inv = zeros(N,1);


% d_acad is the result of Adapative Causal anomaly detection
d_acad = zeros(N, 1);
sum_d_acad = 0;

%waitbar for progress monitoring
h = waitbar(0,'Initializing waitbar ..');

% Since this is causal, it is useful to have the value prev_autocorr
prev_autocorr = 0;

% Causality
prev_u_k = 0;

%local_corr_inv 
local_corr_inv = zeros(p,p);

% for all N= m x n pixels
for j=1:N
        autocorr = prev_autocorr + hyperCausalCorr(M,j);
        prev_autocorr = autocorr;
        % Normalizing
        autocorr = autocorr/j;
        % Since anomalies_detected_transpose is firstly initialized to
        % zero, this will sum N/2 elements being zero. This is not
        % necessary, and will cost computation time. Find fix
        adaptive_autocorr_inv = inv(autocorr - anomalies_detected_transpose_sum);
        
        %if(j>floor(n_acad))
            % circshift does a circular shift. Only left shift is really
            % needed
        %    circshift(adaptive_autocorr_inv_n_acad,[0,-1]);
        %    adaptive_autocorr_inv_n_acad(mod(floor(n_acad),j),:,:) = adaptive_autocorr_inv;
        %else
        %    adaptive_autocorr_inv_n_acad(j,:,:) = adaptive_autocorr_inv;
        %end
        %disp(adaptive_autocorr(j,:,:));
        
        d_acad(j)= M(:,j).' * adaptive_autocorr_inv * M(:,j);
        d_acad = abs(d_acad);
        % There is an optimization to be done here
        %for i=j-floor(n_acad): j-1
        %for i = 1:floor(n_acad)    
            %if i< 1
            %   local_corr_inv = 0;
            %else 
          %     local_corr_inv = adaptive_autocorr_inv_n_acad(i,:,:);%d_acad(i);
         %      local_corr_inv = squeeze(local_corr_inv);
            %end
        %sum_d_acad = sum_d_acad + M(:,j+i-1).'* local_corr_inv * M(:,j+i-1);
        %end
        if(j>floor(n_acad))
            u_k_un_normalized = prev_u_k + d_acad(j) - d_acad(j-floor(n_acad));
        else 
            u_k_un_normalized = prev_u_k + d_acad(j);
        end
        u_k  = (1/n_acad) * u_k_un_normalized;
        u_k = abs(u_k);
        % something is wrong with u_k
        %disp(d_acad(j)-u_k);
        if (d_acad(j) - u_k) > tresh
            % This pixel is an anomaly! Add it to the set of anomalies
            disp('hello');
            anomalies_detected(:,t_an) = M(:,j);
            anomalies_detected_transpose_sum = M(:,j)* M(:,j).' + anomalies_detected_transpose_sum;
            t_an = t_an + 1;
        end
        %sum_d_acad = 0;
        prev_u_k = u_k_un_normalized;
        disp(j);
        disp(j/N);
        waitbar(j/N,h,'Updated progress');
end
return;