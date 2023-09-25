% Title: Generation of Parameters for CEST Pools
% Description: This function is responsible for generating the parameters of
% CEST pools. It initiates the parameters for a set number of pools, 
% and then, based on user-defined limits and ranges, it populates the 
% parameters needed for each pool such as relaxation and concentration 
% parameters, exchange rates, and ppm values relative to the reference pool.
% The generated parameters are crucial for simulating CEST spectra and 
% further analyses in CEST MRI studies.

function [CEST_Parameter] = generateCESTPoolParams(max_num_of_pools, ppm_range)

    %% Pool A
    CEST_Parameter=init_Sim(struct());
    CEST_Parameter.dwA=0;
    
    num_of_pools = max_num_of_pools; %randi(max_num_of_pools);
    
    if max_num_of_pools == 1
        R1 = 1 /3;
        R2 = 1 / 1.2;
    else
        R1 = 1 / randi([500,1200]) * 1000;
        R2 = 1 / randi([60,300]) * 1000;
    end
     
    CEST_Parameter.R1A=R1;  % PBS
    CEST_Parameter.R2A=R2;    % PBS
    
    % first CEST pool B
    if num_of_pools >= 2
        CEST_Parameter.fB=get_random_rel_conc();  % rel. conc 10mM/111M
        CEST_Parameter.kBA=get_random_exchange_rate();   % exchange rate in Hz ( the fast one, kBA is calculated by this and fB)
        CEST_Parameter.dwB=get_rel_ppm(ppm_range);     % ppm  relative to dwA
        CEST_Parameter.R1B=get_relaxation_rate_T1();      % R1B relaxation rate [Hz]
        CEST_Parameter.R2B=get_relaxation_rate_T2();     % R2B relaxation rate [Hz]
    end
    
    % second CEST pool D
    if num_of_pools >= 3
        CEST_Parameter.fD=get_random_rel_conc();  % rel. conc 10mM/111M
        CEST_Parameter.kDA=get_random_exchange_rate();   % exchange rate in Hz ( the fast one, kBA is calculated by this and fB)
        CEST_Parameter.dwD=get_rel_ppm(ppm_range);     % ppm  relative to dwA
        CEST_Parameter.R1D=get_relaxation_rate_T1();      % R1B relaxation rate [Hz]
        CEST_Parameter.R2D=get_relaxation_rate_T2();     % R2B relaxation rate [Hz]
    end
    
    % third CEST pool E
    if num_of_pools >= 4
        CEST_Parameter.fE=get_random_rel_conc();  % rel. conc 10mM/111M
        CEST_Parameter.kEA=get_random_exchange_rate();   % exchange rate in Hz ( the fast one, kBA is calculated by this and fB)
        CEST_Parameter.dwE=get_rel_ppm(ppm_range);     % ppm  relative to dwA
        CEST_Parameter.R1E=get_relaxation_rate_T1();      % R1B relaxation rate [Hz]
        CEST_Parameter.R2E=get_relaxation_rate_T2();     % R2B relaxation rate [Hz]
    end
    
    % forth CEST pool F
    if num_of_pools >= 5
        CEST_Parameter.fF=get_random_rel_conc();  % rel. conc 10mM/111M
        CEST_Parameter.kFA=get_random_exchange_rate();   % exchange rate in Hz ( the fast one, kBA is calculated by this and fB)
        CEST_Parameter.dwF=get_rel_ppm(ppm_range);     % ppm  relative to dwA
        CEST_Parameter.R1F=get_relaxation_rate_T1();      % R1B relaxation rate [Hz]
        CEST_Parameter.R2F=get_relaxation_rate_T2();     % R2B relaxation rate [Hz]
    end
    
    CEST_Parameter.n_cest_pool=num_of_pools-1;
    CEST_Parameter.MT        = 0;

end


% Additional auxiliary functions are defined below to aid the generation of random parameters.

function [f] = get_random_rel_conc()
    % rel. conc X mM/111M - X in range 0 - 400 (Quelle ??)
    f = (rand(1) + 0.5) ^ 2 * 800 / 1000 / 111;
end

function [k] = get_random_exchange_rate()
    % exchange rate in Hz 50 - 2050  (Quelle ??)
    k = rand(1) * 2000 + 50;
end

function [ppm] = get_rel_ppm(ppm_range)
    % ppm rel to dwA in range - max(ppm) to max(ppm) % Delta 0.5 ppm 
    ppm = randi([-100 * ppm_range, 100 * ppm_range])/ 100;
end

function [R] = get_relaxation_rate_T1()
    % T1 0.5 - 2.5 s %Quelle 
    T1 = 2 * rand(1) + 0.5;
    R = 1/T1;
end

function [R] = get_relaxation_rate_T2()
    % T2 = 0.01 - 0.2 sec = 1 ms - 20 ms  %Quelle 
    T2 = 0.02 * rand(1) + 0.001;
    R = 1/T2;
end